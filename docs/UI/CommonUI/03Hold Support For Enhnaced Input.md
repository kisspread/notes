title: Make Enhanced Input Trriger Support "hold" 
comments:true

In the last post, I mentioned that the CommonUI [Enhanced Input Trigger does not support the "Hold" action](./EnhancedInput.md/#2). Here is my solution: create a class derived from "CommonBaseButton" to make the Enhanced Input Trigger support the "Hold" action **without modifying the UE source code.**

---

### HoldSupportBaseButton.h

```cpp
#pragma once

#include "CoreMinimal.h"
#include "CommonButtonBase.h"
#include "HoldSupportBaseButton.generated.h"

class FHoldEventDelegate;
/**
 *  Enhanced Input trigger Hold support button
 */
UCLASS()
class AURA_API UHoldSupportBaseButton : public UCommonButtonBase
{
	GENERATED_BODY()

protected:
	virtual void NativeConstruct() override;

	UFUNCTION()
	void EnhancedHoldProgress(float HoldProgress);

public:

	UFUNCTION(BlueprintImplementableEvent, Category = "Aura|UI")
	void OnHoldComplete();

	UFUNCTION()
	void CheckAndAddHoldBinding();

	FDelegateHandle HoldSupportHandle;
};

```

### HoldSupportBaseButton.cpp

```cpp
#include "UI/Widget/HoldSupportBaseButton.h"
#include "EnhancedActionKeyMapping.h"
#include "EnhancedInputSubsystems.h"
#include "ICommonInputModule.h"
#include "Input/UIActionBinding.h"
#include "UI/Widget/AuraActivatableWidget.h"

void UHoldSupportBaseButton::NativeConstruct()
{
	Super::NativeConstruct();
	CheckAndAddHoldBinding();
	
	if (GetOwningLocalPlayer())
	{
		UEnhancedInputLocalPlayerSubsystem* EnhancedInputSubsystem = GetOwningLocalPlayer()->GetSubsystem<UEnhancedInputLocalPlayerSubsystem>();
		if (EnhancedInputSubsystem)
		{
			// make sure FEnhancedActionKeyMapping is set up correctly
			EnhancedInputSubsystem->ControlMappingsRebuiltDelegate.AddUniqueDynamic(this, &UHoldSupportBaseButton::CheckAndAddHoldBinding);
		}
	}
	
}

/*
 * I don't want to use bRequiresHold for EnhancedInputAction, I want to use the mapping to determine if it requires hold,
 * the bRequiresHold is for Button itself not for a speacific EnhancedInputAction
 * if a EnhancedInputAction has a hold mapping, then it requires hold.
 * 
 */
void UHoldSupportBaseButton::CheckAndAddHoldBinding()
{
	// if (!bRequiresHold) return;
	if (!TriggeringEnhancedInputAction) return;
	if (!TriggeringBindingHandle.IsValid()) return;
	const TSharedPtr<FUIActionBinding> ActionBinding = FUIActionBinding::FindBinding(TriggeringBindingHandle);
	if (!ActionBinding.IsValid()) return ;
	// ActionBinding->OnHoldActionPressed.AddUObject(this, &UHoldSupportBaseButton::NativeOnPressed);
	ActionBinding->OnHoldActionProgressed.Remove(HoldSupportHandle);
	
	HoldSupportHandle = ActionBinding->OnHoldActionProgressed.AddUObject(this,&UHoldSupportBaseButton::EnhancedHoldProgress);
	if (const UEnhancedInputLocalPlayerSubsystem* InputSystem = GetOwningLocalPlayer()->GetSubsystem<UEnhancedInputLocalPlayerSubsystem>())
	{
		for (const FEnhancedActionKeyMapping& Mapping : InputSystem->GetAllPlayerMappableActionKeyMappings())
		{
			if (Mapping.Action == TriggeringEnhancedInputAction)
			{
				UInputTriggerHold* Trigger = nullptr;
				Mapping.Action->Triggers.FindItemByClass(&Trigger);
				if (Trigger)
				{
					FUIActionKeyMapping KeyMapping(Mapping.Key, Trigger->HoldTimeThreshold, Trigger->HoldTimeThreshold);
					ActionBinding->HoldMappings.Add(KeyMapping);
				}
				else  if (HoldData && bRequiresHold)
				{
					const UCommonUIHoldData* CommonUIHoldBehaviorValues =HoldData.GetDefaultObject();
					FUIActionKeyMapping KeyMapping(Mapping.Key, CommonUIHoldBehaviorValues->KeyboardAndMouse.HoldTime, CommonUIHoldBehaviorValues->KeyboardAndMouse.HoldRollbackTime);
					ActionBinding->HoldMappings.Add(KeyMapping);
				}
			}
		}
	}
}



void UHoldSupportBaseButton::EnhancedHoldProgress(const float HoldProgress)
{
	if (HoldProgress >= 1.0f)
	{
		OnHoldComplete();
	}
}
```



