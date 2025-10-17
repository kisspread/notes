---
title: CommonActionWidget ActionBar Support 'Hold'
comments:  true
---


同样的问题，Enhanced Input 默认情况，不支持ActionBar 里的 BoundButton 通过 Enhanced Trigger 的 Hold 来触发。

于是我实现了一个控件，支持在蓝图 动态给 ActionBar 添加 Button，并且 支持 选择是否需要Hold。


---

![alt text](<../../assets/images/ActionBar Support Hold_image.webp>)

### 蓝图配置

- 支持一个默认动作：
    ![alt text](<../../assets/images/ActionBar Support Hold_image-1.webp>)

- 支持动态添加动作：
    ![alt text](<../../assets/images/ActionBar Support Hold_image-2.webp>)

### 代码

```cpp title='UAuraActivatableWidget.h'
USTRUCT(BlueprintType)
struct FHoldSupportAction
{
	GENERATED_BODY()
	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "Input")
	TObjectPtr<UInputAction> EnhancedInputAction;

	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "Input")
	bool bHoldEnabled = false;
};

/**
 * 
 */
UCLASS()
class AURA_API UAuraActivatableWidget : public UCommonActivatableWidget
{
	GENERATED_BODY()

public:
	UFUNCTION(BlueprintCallable)
	virtual void SetWidgetController(UObject* InWidgetController);

	UFUNCTION(BlueprintImplementableEvent)
	void HandleDefaultActionPress();

	UFUNCTION(BlueprintCallable, Category = "Aura|UI")
	void RegisterEnhancedActionToActionBar(const FHoldSupportAction& HoldSupportAction, const FSupportEventDelegate& HoldEventDelegate);

	UFUNCTION(BlueprintImplementableEvent)
	void OnMenuEmpty();

protected:
	virtual void NativeOnInitialized() override;

	UFUNCTION(BlueprintImplementableEvent, Category = "Aura|UI")
	void DefaultHoldComplete();

	void AddHoldBinding(const FUIActionBindingHandle& ActionBindingHandle, UInputAction* BEnhancedInputAction, const FSupportEventDelegate& HoldEventDelegate);

	UPROPERTY(BlueprintReadOnly)
	TObjectPtr<UObject> AuraWidgetController;


	UFUNCTION(BlueprintImplementableEvent)
	void OnWidgetControllerSet();

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = Input, meta = (EditCondition = "CommonInput.CommonInputSettings.IsEnhancedInputSupportEnabled", EditConditionHides))
	FHoldSupportAction DefaultEnhancedInputAction;
 
	
 
private:

	FUIActionBindingHandle DefaultActionHandle;

	 
	
};
``` 

```cpp title='UAuraActivatableWidget.cpp'
void UAuraActivatableWidget::SetWidgetController(UObject* InWidgetController)
{
	if (InWidgetController)
	{
		AuraWidgetController = InWidgetController;
		OnWidgetControllerSet();
		UWidgetLibraryHelp::SetWidgetController(InWidgetController, WidgetTree);
	}
}


void UAuraActivatableWidget::AddHoldBinding(const FUIActionBindingHandle& ActionBindingHandle, UInputAction* BEnhancedInputAction, const FSupportEventDelegate& HoldEventDelegate)
{
	if (!GetOwningLocalPlayer()) return;
	if (!BEnhancedInputAction) return;
	const TSharedPtr<FUIActionBinding> ActionBinding = FUIActionBinding::FindBinding(ActionBindingHandle);
	if (!ActionBinding.IsValid()) return;

	ActionBinding->OnHoldActionProgressed.AddLambda([HoldEventDelegate](const float HoldProgress)
	{
		if (HoldProgress >= 1.0f)
		{
			HoldEventDelegate.ExecuteIfBound();
		}
	});

	if (const UEnhancedInputLocalPlayerSubsystem* InputSystem = GetOwningLocalPlayer()->GetSubsystem<UEnhancedInputLocalPlayerSubsystem>())
	{
		for (const FEnhancedActionKeyMapping& Mapping : InputSystem->GetAllPlayerMappableActionKeyMappings())
		{
			if (Mapping.Action == BEnhancedInputAction)
			{
				UInputTriggerHold* Trigger = nullptr;
				Mapping.Action->Triggers.FindItemByClass(&Trigger);
				if (Trigger)
				{
					FUIActionKeyMapping KeyMapping(Mapping.Key, Trigger->HoldTimeThreshold, Trigger->HoldTimeThreshold);
					ActionBinding->HoldMappings.Add(KeyMapping);
				}
				else
				{
					FUIActionKeyMapping KeyMapping(Mapping.Key, 0.75f, 0.75f);
					ActionBinding->HoldMappings.Add(KeyMapping);
				}
			}
		}
	}
}




void UAuraActivatableWidget::RegisterEnhancedActionToActionBar(const FHoldSupportAction& HoldSupportAction, const FSupportEventDelegate& HoldEventDelegate)
{
	const FUIActionBindingHandle ActionBindingHandle = RegisterUIActionBinding(FBindUIActionArgs(HoldSupportAction.EnhancedInputAction, true,
	                                                                                             FSimpleDelegate::CreateLambda([HoldSupportAction,HoldEventDelegate]()
	                                                                                             {
		                                                                                             if (!HoldSupportAction.bHoldEnabled)
		                                                                                             {
			                                                                                             HoldEventDelegate.ExecuteIfBound();
		                                                                                             }
	                                                                                             })));
	if (HoldSupportAction.bHoldEnabled)
	{
		AddHoldBinding(ActionBindingHandle, HoldSupportAction.EnhancedInputAction, HoldEventDelegate);
	}
}

```

