#include "AssetToolsModule.h"
#include "AuraEditor.h"
#include "ContentBrowserMenuContexts.h"
#include "FileHelpers.h"
#include "GameplayTagsEditorModule.h"
#include "AbilitySystem/Abilities/AuraGameplayAbility.h"
#include "AssetRegistry/AssetRegistryModule.h"
#include "Factories/BlueprintFactory.h"
#include "Framework/Notifications/NotificationManager.h"
#include "GameplayEffectComponents/TargetTagsGameplayEffectComponent.h"
#include "Kismet2/KismetEditorUtilities.h"
#include "Widgets/Notifications/SNotificationList.h"
#define LOCTEXT_NAMESPACE "AuraEditor"

const static FName DefaultTagINI = "DefaultGameplayTags.ini";

// Menu Extensions
//--------------------------------------------------------------------

namespace MenuExtension_GenSimpleCooldownGE
{
	TSharedPtr<SNotificationItem> NotificationItem = nullptr;

	static void TryCreateEditorGameplayTag(const FString& TagName, FGameplayTag& OutTag)
	{
		if (NotificationItem.IsValid())
		{
			NotificationItem->SetVisibility(EVisibility::Collapsed);
		}
		const UGameplayTagsManager& Manager = UGameplayTagsManager::Get();

		// Only support adding tags via ini file
		if (Manager.ShouldImportTagsFromINI() == false)
		{
			return;
		}

		if (TagName.IsEmpty())
		{
			FNotificationInfo Info(LOCTEXT("NoTagName", "You must specify tag name."));
			Info.ExpireDuration = 10.f;
			Info.bUseSuccessFailIcons = true;
			Info.Image = FAppStyle::GetBrush(TEXT("MessageLog.Error"));
			NotificationItem = FSlateNotificationManager::Get().AddNotification(Info);

			return;
		}

		// if no exist, create a new one in ini file.
		FName CooldownTagName(*TagName);
		const TSharedPtr<FGameplayTagNode> TagNode = Manager.FindTagNode(CooldownTagName);
		if (!TagNode.IsValid())
		{
			const FString TagComment = FString::Format(TEXT("Auto Gen Cooldown Tag for {0}"), {TagName});
			IGameplayTagsEditorModule::Get().AddNewGameplayTagToINI(TagName, TagComment, DefaultTagINI);
		}
		OutTag = Manager.RequestGameplayTag(CooldownTagName, false);
	}

	static void SetCooldownGameplayEffectClass(UBlueprint* AbilityBlueprint, UClass* GeneratedClass)
	{
		if (!AbilityBlueprint || !GeneratedClass)
		{
			UE_LOG(LogAuraED, Error, TEXT("Invalid Blueprint or GameplayEffect class"));
			return;
		}

		// 获取蓝图的默认对象
		UObject* GeneratedCDO = AbilityBlueprint->GeneratedClass->GetDefaultObject();

		// 查找属性
		UClass* BlueprintClass = AbilityBlueprint->GeneratedClass;
		FProperty* CooldownProperty = BlueprintClass->FindPropertyByName(FName("CooldownGameplayEffectClass"));

		if (CooldownProperty)
		{
			// 确保属性类型正确
			if (FClassProperty* ClassProperty = CastField<FClassProperty>(CooldownProperty))
			{
				// 设置新的值
				ClassProperty->SetPropertyValue_InContainer(GeneratedCDO, GeneratedClass);
				// 标记蓝图为已修改
				AbilityBlueprint->Modify();

				// 编译蓝图
				FKismetEditorUtilities::CompileBlueprint(AbilityBlueprint);

				// 保存蓝图
				// TArray<UPackage*> PackagesToSave;
				// PackagesToSave.Add(TargetBlueprint->GetOutermost());
				// FEditorFileUtils::PromptForCheckoutAndSave(PackagesToSave, false, false);
				UE_LOG(LogAuraED, Log, TEXT("Successfully set CooldownGameplayEffectClass for blueprint %s"), *AbilityBlueprint->GetName());
			}
			else
			{
				UE_LOG(LogAuraED, Error, TEXT("CooldownGameplayEffectClass is not of the expected type"));
			}
		}
		else
		{
			UE_LOG(LogAuraED, Error, TEXT("Could not find CooldownGameplayEffectClass property in blueprint"));
		}
	}


	static void ExecuteActionForGenSimpleCooldownGE(const FToolMenuContext& InContext)
	{
		const UContentBrowserAssetContextMenuContext* Context = UContentBrowserAssetContextMenuContext::FindContextWithAssets(InContext);
		if (!Context) return;
		for (UBlueprint* LoadedInstance : Context->LoadSelectedObjects<UBlueprint>())
		{
			UAuraGameplayAbility* AuraGameplayAbility = LoadedInstance->GeneratedClass ? Cast<UAuraGameplayAbility>(LoadedInstance->GeneratedClass->GetDefaultObject()) : nullptr;
			if (!AuraGameplayAbility) continue;
			FString AbilityName = FPaths::GetBaseFilename(AuraGameplayAbility->GetPathName());
			FString CooldownGEName = FString::Printf(TEXT("GE_Cooldown_%s"), *AbilityName);
			FString FileBasePath = FPaths::GetPath(AuraGameplayAbility->GetPathName());
			FString NewGEPath = FString::Format(TEXT("{0}/Cooldown"), {FileBasePath});

			// create GE asset.
			FAssetToolsModule& AssetToolsModule = FModuleManager::GetModuleChecked<FAssetToolsModule>("AssetTools");
			FString AssetPath = NewGEPath + "/" + CooldownGEName;
			// try to load this Asset if existed, or just create a new one.
			UBlueprint* ExistingBlueprint = LoadObject<UBlueprint>(nullptr, *AssetPath);
			UBlueprint* GE_Blueprint = nullptr;
			if (ExistingBlueprint)
			{
				GE_Blueprint = ExistingBlueprint;
				UE_LOG(LogAuraED, Log, TEXT("Using existing blueprint: %s"), *AssetPath);
			}
			else
			{
				UBlueprintFactory* BlueprintFactory = NewObject<UBlueprintFactory>();
				BlueprintFactory->ParentClass = UGameplayEffect::StaticClass();
				// do not Use GE directly
				// UGameplayEffect* NewGE = Cast<UGameplayEffect>(AssetToolsModule.Get().CreateAsset(CooldownGEName, NewGEPath, UGameplayEffect::StaticClass(), nullptr));
				UObject* CreatedAsset = AssetToolsModule.Get().CreateAsset(CooldownGEName, NewGEPath, UBlueprint::StaticClass(), BlueprintFactory);
				GE_Blueprint = Cast<UBlueprint>(CreatedAsset);
			}

			if (!GE_Blueprint) return;
			// GE Blueprint Asset Class
			UClass* GeneratedClass = GE_Blueprint->GeneratedClass;
			// use the CDO, not New Object
			UGameplayEffect* NewGE = Cast<UGameplayEffect>(GeneratedClass->GetDefaultObject());
			if (NewGE)
			{
				// bind tag to new ge
				FInheritedTagContainer TagContainerMods;
				FGameplayTag AbilityTag = AuraGameplayAbility->AbilityTags.First();
				FString NewCooldownTagName = FString::Printf(TEXT("Cooldown.%s"), *AbilityTag.ToString());
				FGameplayTag CooldownTag = AuraGameplayAbility->CooldownTag;
				if (!CooldownTag.IsValid())
				{
					//create tag for this newGE
					TryCreateEditorGameplayTag(NewCooldownTagName, CooldownTag);
				}
				TagContainerMods.AddTag(CooldownTag);
				UTargetTagsGameplayEffectComponent& TargetTagsComponent = NewGE->FindOrAddComponent<UTargetTagsGameplayEffectComponent>();
				TargetTagsComponent.SetAndApplyTargetTagChanges(TagContainerMods);
				// set duration fot this newGE
				NewGE->DurationPolicy = EGameplayEffectDurationType::HasDuration;
				NewGE->DurationMagnitude = FScalableFloat(AuraGameplayAbility->CooldownDuration);
				// NewGE->DurationMagnitude = FGameplayEffectModifierMagnitude(AuraGameplayAbility->CooldownDuration);
				// NewGE->Period = 1.f;
				// save asset GE Blueprint asset
				GE_Blueprint->Modify();
				FKismetEditorUtilities::CompileBlueprint(GE_Blueprint);
				TArray<UPackage*> PackagesToSave;
				PackagesToSave.Add(GE_Blueprint->GetOutermost());
				FEditorFileUtils::PromptForCheckoutAndSave(PackagesToSave, false, false);
				FAssetRegistryModule::AssetCreated(GE_Blueprint);
				UE_LOG(LogAuraED, Log, TEXT("Successfully modified GameplayEffect blueprint. Remember to save your changes."));
				//start set this GE Asset to Aura Ability blueprint
				SetCooldownGameplayEffectClass(LoadedInstance, GeneratedClass);
			}
		}
	}


	static FDelayedAutoRegisterHelper DelayedAutoRegister(EDelayedRegisterRunPhase::EndOfEngineInit, []
	{
		UToolMenus::RegisterStartupCallback(FSimpleMulticastDelegate::FDelegate::CreateLambda([]()
		{
			FToolMenuOwnerScoped OwnerScoped(UE_MODULE_NAME);

			UToolMenu* Menu = UE::ContentBrowser::ExtendToolMenu_AssetContextMenu(UBlueprint::StaticClass());

			FToolMenuSection& Section = Menu->FindOrAddSection("GetAssetActions");
			Section.AddDynamicEntry(NAME_None, FNewToolMenuSectionDelegate::CreateLambda([](FToolMenuSection& InSection)
			{
				// Since we're registered to execute on any UBlueprint, we need to ensure we've selected a Gameplay Ability Blueprint
				UContentBrowserAssetContextMenuContext* ContentBrowserContext = InSection.FindContext<UContentBrowserAssetContextMenuContext>();
				if (ContentBrowserContext)
				{
					bool bPassesClassFilter = false;
					for (const FAssetData& AssetData : ContentBrowserContext->GetSelectedAssetsOfType(UBlueprint::StaticClass()))
					{
						if (TSubclassOf<UBlueprint> AssetClass = AssetData.GetClass())
						{
							if (const UClass* BlueprintParentClass = UBlueprint::GetBlueprintParentClassFromAssetTags(AssetData))
							{
								bPassesClassFilter |= BlueprintParentClass->IsChildOf(UAuraGameplayAbility::StaticClass());
							}
						}
					}

					// We aren't a BP that generates a class derived from UGameplayAbility
					if (!bPassesClassFilter)
					{
						return;
					}
				}
				const TAttribute<FText> Label = LOCTEXT("GenSimpleCooldownGE_CreateCooldownGE", "Create Simple Cooldown GE");
				const TAttribute<FText> ToolTip = LOCTEXT("GenSimpleCooldownGE_CreateCooldownGETooltip", "Creates a Simple Cooldown GameplayEffect for this Ability");
				const FSlateIcon Icon = FSlateIcon(FAppStyle::GetAppStyleSetName(), "ClassIcon.Blueprint");
				FToolUIAction UIAction;
				UIAction.ExecuteAction = FToolMenuExecuteAction::CreateStatic(&ExecuteActionForGenSimpleCooldownGE);
				// UIAction.CanExecuteAction = FToolMenuCanExecuteAction::CreateStatic(&CanExecuteActionForGenSimpleCooldownGE);
				InSection.AddMenuEntry("GenSimpleCooldownGE_CreateCooldownGE", Label, ToolTip, Icon, UIAction);
			}));
		}));
	});
}
