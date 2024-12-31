---
title: Gas Cooldown Effect
comments:  true
---

I dont't want to create Cooldown effect  for every Ability. So I want to find a way to create a Cooldown effect for all spells. To dynamically create a Cooldown effect for all spells. But finilly I found we can't do that. I writon a article about this.

---

## UGameplayAbility
Some related code in UGameplayAbility.cpp. At the beginning, I think we can simply override `GetCooldownGameplayEffect` to return my own Cooldown GE.

```cpp
void UGameplayAbility::ApplyCooldown(const FGameplayAbilitySpecHandle Handle, const FGameplayAbilityActorInfo* ActorInfo, const FGameplayAbilityActivationInfo ActivationInfo) const
{
	UGameplayEffect* CooldownGE = GetCooldownGameplayEffect();
	if (CooldownGE)
	{
		ApplyGameplayEffectToOwner(Handle, ActorInfo, ActivationInfo, CooldownGE, GetAbilityLevel(Handle, ActorInfo));
	}
}

UGameplayEffect* UGameplayAbility::GetCooldownGameplayEffect() const
{
	if ( CooldownGameplayEffectClass )
	{
		return CooldownGameplayEffectClass->GetDefaultObject<UGameplayEffect>();
	}
	else
	{
		return nullptr;
	}
}
```

so I just override `GetCooldownGameplayEffect` to return my own Cooldown GE.

```cpp
UGameplayEffect* UAuraGameplayAbility::GetCooldownGameplayEffect() const
{
	const auto Test =Super::GetCooldownGameplayEffect();
	// has value, using the simple cooldown config.
	if (CooldownDuration != -1.f && CooldownTag.IsValid())
	{
		if (CooldownGE) return CooldownGE;

		CooldownGE = NewObject<UGameplayEffect>();

		CooldownGE->DurationPolicy =EGameplayEffectDurationType::HasDuration;

		UTargetTagsGameplayEffectComponent& TargetTagsComponent = CooldownGE->FindOrAddComponent<UTargetTagsGameplayEffectComponent>();

		CooldownGE->DurationMagnitude = FGameplayEffectModifierMagnitude(FScalableFloat(CooldownDuration));
		CooldownGE->Period = 1.f;
		FInheritedTagContainer TagContainerMods;
		TagContainerMods.AddTag(CooldownTag);
		TargetTagsComponent.SetAndApplyTargetTagChanges(TagContainerMods);
 		return CooldownGE;
	}
	return Test;
}
```

But it doesn't work. So I dive into the source code. 
```cpp
FActiveGameplayEffectHandle UGameplayAbility::ApplyGameplayEffectToOwner(const FGameplayAbilitySpecHandle Handle, const FGameplayAbilityActorInfo* ActorInfo, const FGameplayAbilityActivationInfo ActivationInfo, const UGameplayEffect* GameplayEffect, float GameplayEffectLevel, int32 Stacks) const
{
	if (GameplayEffect && (HasAuthorityOrPredictionKey(ActorInfo, &ActivationInfo)))
	{
		FGameplayEffectSpecHandle SpecHandle = MakeOutgoingGameplayEffectSpec(Handle, ActorInfo, ActivationInfo, GameplayEffect->GetClass(), GameplayEffectLevel);
		if (SpecHandle.IsValid())
		{
			SpecHandle.Data->SetStackCount(Stacks);
			return ApplyGameplayEffectSpecToOwner(Handle, ActorInfo, ActivationInfo, SpecHandle);
		}
	}

	// We cannot apply GameplayEffects in this context. Return an empty handle.
	return FActiveGameplayEffectHandle();
}
```
In `ApplyGameplayEffectToOwner`, we can see that it will call `MakeOutgoingGameplayEffectSpec` to create a `FGameplayEffectSpecHandle`. And then call `ApplyGameplayEffectSpecToOwner` to apply the `FGameplayEffectSpecHandle`. But it not using my own Cooldown GE.`GameplayEffect->GetClass()`, it will get the `CooldownGameplayEffectClass` from `UGameplayAbility`, its the class deflault object.

here is the code show how to create a `FGameplayEffectSpecHandle`:
```cpp
FGameplayEffectSpecHandle UAbilitySystemComponent::MakeOutgoingSpec(TSubclassOf<UGameplayEffect> GameplayEffectClass, float Level, FGameplayEffectContextHandle Context) const
{
	SCOPE_CYCLE_COUNTER(STAT_GetOutgoingSpec);
	if (Context.IsValid() == false)
	{
		Context = MakeEffectContext();
	}

	if (GameplayEffectClass)
	{
		UGameplayEffect* GameplayEffect = GameplayEffectClass->GetDefaultObject<UGameplayEffect>();

		FGameplayEffectSpec* NewSpec = new FGameplayEffectSpec(GameplayEffect, Context, Level);
		return FGameplayEffectSpecHandle(NewSpec);
	}

	return FGameplayEffectSpecHandle(nullptr);
}
```
`UGameplayEffect* GameplayEffect = GameplayEffectClass->GetDefaultObject<UGameplayEffect>();` that is the problem.

### My Opinion
 
I think The reason for this design is...

- Performance optimization: Using GetDefaultObject can help avoid frequently creating and destroying objects, especially when they are used a lot.
- Data consistency: Make sure all GameplayEffects of the same type use the same base configuration.
- Blueprint compatibility: This design makes it easy to create and configure GameplayEffects in Blueprints.
- Network synchronization: Using predefined classes makes it easier to sync effects in multiplayer games.
- Serializability: Predefined classes are easier to serialize and deserialize, which is important for saving game states.


*if you know another way to create a Cooldown effect for all spells, please tell me. I will be very grateful.*

### Other Solution
 - [auto create cooldown effect](../Tools/01EditorModule.md)
