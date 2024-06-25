title: using macro to define Native Gameplay Tag
comments:true

!!! note 
    This post base on Aura GAS Course

---
## GamePlayTag
Instead of using an object instance to hold all of the gameplay tags, it's better to use a macro. This is how Lyra did it:

  ```c++ title='Tags.h'
  namespace AuraGameplayTags
  {
	
	UE_DECLARE_GAMEPLAY_TAG_EXTERN(Attribute_Primary_Intelligence);
	UE_DECLARE_GAMEPLAY_TAG_EXTERN(Attribute_Primary_Strength);
	UE_DECLARE_GAMEPLAY_TAG_EXTERN(Attribute_Primary_Vigor);
	UE_DECLARE_GAMEPLAY_TAG_EXTERN(Attribute_Primary_Resilience);
  }
  ```


  ```c++ title='Tags.cpp'
    namespace AuraGameplayTags
    {
        UE_DEFINE_GAMEPLAY_TAG_COMMENT(Attribute_Primary_Intelligence, "Attribute.Primary.Intelligence", "Increase spell damage")
        UE_DEFINE_GAMEPLAY_TAG_COMMENT(Attribute_Primary_Strength, "Attribute.Primary.Strength", "Increase Physical damage")
        UE_DEFINE_GAMEPLAY_TAG_COMMENT(Attribute_Primary_Vigor, "Attribute.Primary.Vigor", "Increase max health")
        UE_DEFINE_GAMEPLAY_TAG_COMMENT(Attribute_Primary_Resilience, "Attribute.Primary.Resilience", "Increase armor and armor penetration")
  ```

## Remove TagsToAttributes
we don't need this mapping now. The magic is

`Attribute.AttributeGetter = FindFieldChecked<FProperty>(UAuraAttributeSet::StaticClass(), AttributeName);`

we can save attributeGet in Our DataAsset:
```c++
USTRUCT(BlueprintType)
struct FAttributeInfo
{
    GENERATED_BODY()

    UPROPERTY(EditDefaultsOnly, BlueprintReadOnly)
    FGameplayTag AttributeTag;

    UPROPERTY(EditDefaultsOnly, BlueprintReadOnly)
    FText AttributeName;

    UPROPERTY(EditDefaultsOnly, BlueprintReadOnly)
    FText AttributeDescription;

    UPROPERTY(BlueprintReadOnly)
    mutable float AttributeValue = 0.f;

    UPROPERTY(BlueprintReadOnly)
    FGameplayAttribute  AttributeGetter;
    
};
```


`TMap<FGameplayTag,TAttrFunctionPrt<FGameplayAttribute()>> TagsToAttributes;`

then, auto init all data  row, like so:
```c++
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


## How it look like
let me share my use cases:

```cpp title='UExecCalc_Damage.cpp'
struct DamageStatics
{
	DECLARE_ATTRIBUTE_CAPTUREDEF(Armor);
	DECLARE_ATTRIBUTE_CAPTUREDEF(ArmorPenetration);
	DECLARE_ATTRIBUTE_CAPTUREDEF(BlockChance);
	DECLARE_ATTRIBUTE_CAPTUREDEF(CriticalHitChance);
	DECLARE_ATTRIBUTE_CAPTUREDEF(CriticalHitDamage);
	DECLARE_ATTRIBUTE_CAPTUREDEF(CriticalHitResistance);

	DECLARE_ATTRIBUTE_CAPTUREDEF(ResistanceFire);
	DECLARE_ATTRIBUTE_CAPTUREDEF(ResistanceLightning);
	DECLARE_ATTRIBUTE_CAPTUREDEF(ResistanceArcane);
	DECLARE_ATTRIBUTE_CAPTUREDEF(ResistancePhysical);

	TMap<FGameplayTag, FGameplayEffectAttributeCaptureDefinition> TagsToCaptures;

	DamageStatics()
	{
		DEFINE_ATTRIBUTE_CAPTUREDEF(UAuraAttributeSet, Armor, Target, false);
		DEFINE_ATTRIBUTE_CAPTUREDEF(UAuraAttributeSet, ArmorPenetration, Source, false);
		DEFINE_ATTRIBUTE_CAPTUREDEF(UAuraAttributeSet, BlockChance, Target, false);

		DEFINE_ATTRIBUTE_CAPTUREDEF(UAuraAttributeSet, CriticalHitChance, Source, false);
		DEFINE_ATTRIBUTE_CAPTUREDEF(UAuraAttributeSet, CriticalHitDamage, Source, false);
		DEFINE_ATTRIBUTE_CAPTUREDEF(UAuraAttributeSet, CriticalHitResistance, Target, false);

		DEFINE_ATTRIBUTE_CAPTUREDEF(UAuraAttributeSet, ResistanceFire, Target, false);
		DEFINE_ATTRIBUTE_CAPTUREDEF(UAuraAttributeSet, ResistanceLightning, Target, false);
		DEFINE_ATTRIBUTE_CAPTUREDEF(UAuraAttributeSet, ResistanceArcane, Target, false);
		DEFINE_ATTRIBUTE_CAPTUREDEF(UAuraAttributeSet, ResistancePhysical, Target, false);

		TagsToCaptures.Add(AuraGameplayTags::Attribute_Secondary_Armor, ArmorDef);
		TagsToCaptures.Add(AuraGameplayTags::Attribute_Secondary_ArmorPenetration, ArmorPenetrationDef);
		TagsToCaptures.Add(AuraGameplayTags::Attribute_Secondary_BlockChance, BlockChanceDef);

		TagsToCaptures.Add(AuraGameplayTags::Attribute_Secondary_CriticalHitChance, CriticalHitChanceDef);
		TagsToCaptures.Add(AuraGameplayTags::Attribute_Secondary_CriticalHitDamage, CriticalHitDamageDef);
		TagsToCaptures.Add(AuraGameplayTags::Attribute_Secondary_CriticalHitResistance, CriticalHitResistanceDef);

		TagsToCaptures.Add(AuraGameplayTags::Attribute_Resistance_Fire, ResistanceFireDef);
		TagsToCaptures.Add(AuraGameplayTags::Attribute_Resistance_Lightning, ResistanceLightningDef);
		TagsToCaptures.Add(AuraGameplayTags::Attribute_Resistance_Arcane, ResistanceArcaneDef);
		TagsToCaptures.Add(AuraGameplayTags::Attribute_Resistance_Physical, ResistancePhysicalDef);
	}
};

UExecCalc_Damage::UExecCalc_Damage()
{
	RelevantAttributesToCapture.Add(DamageStatics().ArmorDef);
	RelevantAttributesToCapture.Add(DamageStatics().ArmorPenetrationDef);
	RelevantAttributesToCapture.Add(DamageStatics().BlockChanceDef);

	RelevantAttributesToCapture.Add(DamageStatics().CriticalHitChanceDef);
	RelevantAttributesToCapture.Add(DamageStatics().CriticalHitDamageDef);
	RelevantAttributesToCapture.Add(DamageStatics().CriticalHitResistanceDef);

	RelevantAttributesToCapture.Add(DamageStatics().ResistanceFireDef);
	RelevantAttributesToCapture.Add(DamageStatics().ResistanceLightningDef);
	RelevantAttributesToCapture.Add(DamageStatics().ResistanceArcaneDef);
	RelevantAttributesToCapture.Add(DamageStatics().ResistancePhysicalDef);
}
```

a Tag Mapping Helper Function:
```cpp
	TMap<FGameplayTag, FGameplayTag>& AuraGameplayTags::GetDamageTypeToResistanceMap()
	{
		static TMap<FGameplayTag, FGameplayTag> DamageTypeToResistanceMap = {
			{AuraGameplayTags::Damage_Fire, AuraGameplayTags::Attribute_Resistance_Fire},
			{AuraGameplayTags::Damage_Lightning, AuraGameplayTags::Attribute_Resistance_Lightning},
			{AuraGameplayTags::Damage_Arcane, AuraGameplayTags::Attribute_Resistance_Arcane},
			{AuraGameplayTags::Damage_Physical, AuraGameplayTags::Attribute_Resistance_Physical}
		};
		return DamageTypeToResistanceMap;
	}
```