---
title: Make DataAsset setup with Default Values
comments:  true
---

::: warning
This post base on Aura GAS Course
::: 

---

In the Aura Course, we have to manually input all the RPG Attribute Items into the DataAsset, which is pretty boring and repetitive. So, I believe we can generate default values based on the existing information, eliminating the need for manual input and achieving semi-automation.

## TLDR
- Utilize `FindFieldChecked<FProperty>(UAuraAttributeSet::StaticClass(), AttributeName)` to save FGameplayAttribute in DataAsset
- Use `GetDerivedClasses` to obtain all subclasses of UGameplayAbility.

## Auto Collect All Attributes
- Utilize `UGameplayTagsManager.RequestGameplayTagChildren` to locate all the Sub Tags.
- Utilize `FindFieldChecked<FProperty>(UAuraAttributeSet::StaticClass(), AttributeName)` to retrieve the AttributeGetter and store it in DataAssets for future use.

```cpp
    UAuraAttributeDataAsset::UAuraAttributeDataAsset()
{
	// init default attributes from tag manager with parent tag is "Attribute.*"
	const UGameplayTagsManager& Manager = UGameplayTagsManager::Get();
	const FGameplayTagContainer PrimaryTags = Manager.RequestGameplayTagChildren(FGameplayTag::RequestGameplayTag("Attribute.Primary", false));
	const FGameplayTagContainer SecondaryTags = Manager.RequestGameplayTagChildren(FGameplayTag::RequestGameplayTag("Attribute.Secondary", false));
	const FGameplayTagContainer ResistanceTags = Manager.RequestGameplayTagChildren(FGameplayTag::RequestGameplayTag("Attribute.Resistance", false));
	AddDefaultAttributeInfos(PrimaryTags);
	AddDefaultAttributeInfos(SecondaryTags);
	AddDefaultAttributeInfos(ResistanceTags, true);
}

void UAuraAttributeDataAsset::AddDefaultAttributeInfos(const FGameplayTagContainer& Tags, const bool bIsResistance)
{
	for (const FGameplayTag& Tag : Tags)
	{
		FAttributeInfo Attribute;
		Attribute.AttributeTag = Tag;
		// split tag name by '.' and get the last part, tag example: "Attribute.Primary.Intelligence", we only need "Intelligence"
		FString TagName = Tag.ToString();
		int32 LastDotIndex;
		if (TagName.FindLastChar('.', LastDotIndex))
		{
			TagName = TagName.Mid(LastDotIndex + 1);
		}
		Attribute.AttributeName = FText::FromString(bIsResistance ? TagName + " Resistance" : TagName);
#if WITH_EDITORONLY_DATA
		Attribute.AttributeDescription = FText::FromString(UGameplayTagsManager::Get().FindTagNode(AuraGameplayTags::Attribute_Primary_Intelligence).Get()->GetDevComment());
#endif
		Attribute.AttributeValue = 0.f;
		const FName AttributeName = bIsResistance ? FName(*("Resistance" + TagName)) : FName(*TagName);
		Attribute.AttributeGetter = FindFieldChecked<FProperty>(UAuraAttributeSet::StaticClass(), AttributeName);
		Attributes.Add(Attribute);
	}
}
```
## Auto Collect All Offensive Abilities
In the Aura Course, all the offensive abilities have an Input Tag, so we can leverage this to identify all offensive spells.

- Use `GetDerivedClasses` to obtain all subclasses of UGameplayAbility.

```cpp
UAuraAbilitiesDataAsset::UAuraAbilitiesDataAsset()
{
	TArray<UClass*> AbilityClasses;
	GetDerivedClasses(UAuraGameplayAbility::StaticClass(), AbilityClasses, true);
	for (UClass* AbilityClass : AbilityClasses)
	{
		UAuraGameplayAbility* Ability = Cast<UAuraGameplayAbility>(AbilityClass->GetDefaultObject());
		// has a press key tag means it's a player triggered spell
		if (Ability && Ability->PlayerKeyPressTag.IsValid())
		{
			FAbilityInfo Info;
			Info.InputTag = Ability->PlayerKeyPressTag;
			if (Ability->AbilityTags.Num() > 0)
			{
				Info.AbilityTag = Ability->AbilityTags.First();
			}
			Info.Ability = AbilityClass;
			AbilityInformation.Add(Info);
		}
	}
}
```

