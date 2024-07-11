title: Use AbilityAsync Instead of UBlueprintAsyncActionBase
comments:true


GAS Course introduces UBlueprintAsyncActionBase, I found some subClass maybe useful.
![alt text](../assets/images/3AbilityAsync_image.png)

Derived from UAbilityAsync, we can reduce some code.

```cpp title='AbilityAsync_WaitCooldown.h'
#pragma once

#include "CoreMinimal.h"
#include "Abilities/Async/AbilityAsync.h"
#include "AbilityAsync_WaitCooldown.generated.h"

DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnCooldownDelegate, float, TimeRemaining);

/**
 * 
 */
UCLASS()
class AURA_API UAbilityAsync_WaitCooldown : public UAbilityAsync
{
	GENERATED_BODY()
public:
	UPROPERTY(BlueprintAssignable)
	FOnCooldownDelegate CooldownStart;

	UPROPERTY(BlueprintAssignable)
	FOnCooldownDelegate CooldownEnd;

	UFUNCTION(BlueprintCallable, meta = (BlueprintInternalUseOnly = "true"))
	static UAbilityAsync_WaitCooldown* WaitCooldown(UAbilitySystemComponent* InASC, FGameplayTag InCooldownTag);

    virtual void EndAction() override;

	void CooldownTagChanged(FGameplayTag GameplayTag, int32 Count );
	void OnGE_ApplyToSelf(UAbilitySystemComponent* ASC, const FGameplayEffectSpec& GESpec, FActiveGameplayEffectHandle ActiveGameplayEffectHandle);
	virtual void Activate() override;

	
protected:

	FGameplayTag CooldownTag;

};

```