---
title: GAS GE Custom Calculation
comments:  true
---


![alt text](../assets/images/6GE_Calculation_image-1.png)

### 简介

- 单值设置，继承 `UGameplayModMagnitudeCalculation` 对应蓝图里的Modifiers，支持属性改变时自动触发更新（Infinite）
- 多值设置，继承 `UGameplayEffectExecutionCalculation` 对应蓝图里的Executions，不支持Infinite，需要设置一个period.

#### UGameplayModMagnitudeCalculation

这是修改器自定义计算的实现类，修改器（modifier）是针对单个属性进行设置的，自定义即使也只是允许捕获多个值。
蓝图里只能捕获一个属性，用了个这个类，可以允许捕获多个值。

MMCs can be used in any duration of GameplayEffects - Instant, Duration, Infinite, or Periodic.
支持任何持续时间，包括持续、无限、周期。


- CalculateBaseMagnitude：用于设置基础值计算规则， base value,也就是说最终值是由基础值和pre/post系数计算出来的。这还是个BlueprintNativeEvent方法。
 >  coeffecient and pre/post multiply adds
```cpp
	/**
	 * Calculate the base magnitude of the gameplay effect modifier, given the specified spec. Note that the owning spec def can still modify this base value
	 * with a coeffecient and pre/post multiply adds. see FCustomCalculationBasedFloat::CalculateMagnitude for details.
	 * 
	 * @param Spec	Gameplay effect spec to use to calculate the magnitude with
	 * 
	 * @return Computed magnitude of the modifier
	 */
	UFUNCTION(BlueprintNativeEvent, Category="Calculation")
	float CalculateBaseMagnitude(const FGameplayEffectSpec& Spec) const;
```    
- GetExternalModifierDependencyMulticast: 如果计算结果依赖于游戏代码特定的条件，可以重写这个方法提供一个多播委托，当依赖条件改变时触发重新计算。

#### UGameplayEffectExecutionCalculation

 这是执行器自定义计算的实现类，执行器（execution）允许修改多个值，捕获多个值。

 该类提供了高度的灵活性，可以处理几乎所有你能想到的与游戏效果相关的逻辑。
 
 ExecutionCalculations can only be used with Instant and Periodic GameplayEffects. Anything with the word 'Execute' in it typically refers to these two types of GameplayEffects.
 仅支持Instant和Periodic GameplayEffects.需要设置一个period.比如 period = 1.0f;

 - 使用ExecutionParams 的AttemptCalculateCapturedAttributeMagnitude来捕获值
    ```cpp
    float TargetArmor = 0.f;
        ExecutionParams.AttemptCalculateCapturedAttributeMagnitude(DamageStatics().ArmorDef, EvaluationParameters, TargetArmor);
    ```
- 系数也是自己设定，最终输出的是一个修改器，里面包含的值就是最终值。
    ```cpp
    Damage *= (100 - EffectiveArmor * EffectiveArmorCoefficient) / 100;

	const FGameplayModifierEvaluatedData DamageData(UAuraAttributeSet::GetIncomingDamageAttribute(), EGameplayModOp::Additive, Damage);
	OutExecutionOutput.AddOutputModifier(DamageData);
    ```

#### 补充 EXecutionCalculation 还有自己的Modifier

![alt text](../assets/images/6GE_Calculation_image.png)

作用和UGameplayModMagnitudeCalculation是一样的，对自定义的CalculationClass的结果，进一步修改。

#### 同个GE里他们的执行顺序
```sh
[2024.08.17-21.24.25:574][327]LogAura: Warning: UMMC_MaxHealth::CalculateBaseMagnitude_Implementation
[2024.08.17-21.24.25:574][327]LogAura: Warning: UExeCalc_Resistance::Execute_Implementation
```
测试结果，modifier先于execution.

#### Period 为 0 时的区别

当 GameplayEffect (GE) 设置为 Infinite Duration 时，Period 为 0这意味着 Execution 只会执行一次，而不是周期性执行。

Modifier 和 Execution 的区别：

Modifier（ UGameplayModMagnitudeCalculation）：这些在属性变化时会持续评估和应用，既主动触发更新。
Execution（ UGameplayEffectExecutionCalculation）：默认情况下，只在 GE 首次应用时执行一次。

当GE里同时存在Modifier 和 Execution 时，Modifier会自动更新，而execution会周期性执行。


### 理解为何是这样设计

GE是的数值游戏，GE可以看成是一个数值计算函数。比如`GE_FireDamage(A,B)`,必然有参与的双方A和B，其中A是源属性，B是目标属性。那么计算过程就要获得A的火属性伤害，和B的火属性防御。

#### 实际样子
UE不传递AttributeSet本身，而是传递字段的引用。
所以，这个函数在UE里是类似这样的：
`GE_FireDamage(FireDamgeFromARef,FireResistanceFromBRef)`

这里FireDamgeFromARef的形式，就类似“捕获”。也可以理解成路径。

### UE里实现的捕获
为了更灵活地获取属性值，在运行过程中读取出来，供后续去使用。这个过程就叫做捕获。

先看样例代码
```cpp
	VigorDef.AttributeToCapture = UAuraAttributeSet::GetVigorAttribute();
	VigorDef.AttributeSource = EGameplayEffectAttributeCaptureSource::Target;
	VigorDef.bSnapshot = false;

	RelevantAttributesToCapture.Add(VigorDef);
```    
VigorDef是一个`FGameplayEffectAttributeCaptureDefinition`

#### FGameplayEffectAttributeCaptureDefinition

用于描述GAS属性捕获定义，包含捕获源和目标属性，以及是否使用快照。
```cpp
	/** Gameplay attribute to capture */
	UPROPERTY(EditDefaultsOnly, Category=Capture)
	FGameplayAttribute AttributeToCapture;

	/** Source of the gameplay attribute */
	UPROPERTY(EditDefaultsOnly, Category=Capture)
	EGameplayEffectAttributeCaptureSource AttributeSource;

	/** Whether the attribute should be snapshotted or not */
	UPROPERTY(EditDefaultsOnly, Category=Capture)
	bool bSnapshot;
```

#### 快照（Snapshot）的概念：
快照决定了我们是使用效果应用时的属性值，还是随时间变化的当前值。就是说：捕获的属性值是否“定格”在破获时那一刻。

for example:

想象一个角色有一个"力量"属性，初始值为10。现在我们要创建一个持续30秒的增强效果，增加该角色50%的伤害。

- 情况1：不使用快照（bSnapshot = false）

	效果开始时，角色力量为10，伤害增加50%，即15。
	如果在效果持续期间，角色的力量提升到20，伤害会随之增加到30。
	效果会始终使用当前的力量值来计算伤害。

- 情况2：使用快照（bSnapshot = true）

	效果开始时，角色力量为10，伤害增加50%，即15。
	即使在效果持续期间角色的力量提升到20，伤害仍然保持在15。
	效果会使用应用时捕获的力量值（10）来计算伤害，不受后续力量变化的影响。

#### UAttributeSet::GetXXXAttribute()

GetXXXAttribute 实际上返回的 FProperty指针，是UE反射机制里的 对象字段元数据。
例子里`VigorDef.AttributeToCapture = UAuraAttributeSet::GetVigorAttribute();`这个赋值操作，实际上的调用了`FGameplayAttribute(FProperty *NewProperty)`构造函数。

Def里面有了这个元数据，就相当于知道了该字段的“路径”。可在后续拿到相应的AttributeSet实例后，根据理解查找到想要的值。


#### 如何创建 Def

除了上面的手动创建，引擎还提供了相关的宏：
```cpp
// -------------------------------------------------------------------------
//	Helper macros for declaring attribute captures 
// -------------------------------------------------------------------------

#define DECLARE_ATTRIBUTE_CAPTUREDEF(P) \
	FProperty* P##Property; \
	FGameplayEffectAttributeCaptureDefinition P##Def; \

#define DEFINE_ATTRIBUTE_CAPTUREDEF(S, P, T, B) \
{ \
	P##Property = FindFieldChecked<FProperty>(S::StaticClass(), GET_MEMBER_NAME_CHECKED(S, P)); \
	P##Def = FGameplayEffectAttributeCaptureDefinition(P##Property, EGameplayEffectAttributeCaptureSource::T, B); \
}

// 使用
DECLARE_ATTRIBUTE_CAPTUREDEF(ResistanceFire);
DEFINE_ATTRIBUTE_CAPTUREDEF(UAuraAttributeSet, ResistanceFire, Target, false);

```



###  是怎么根据AttributeToCapture 来捕获值的？
AttributeToCapture 是FGameplayAttribute，是我们定义 AttributeSet时的用macro自动生成的该属性描述。
#### FGameplayAttribute 和 FGameplayAttributeData
通过上述分析，FGameplayAttribute包装了FProperty指针，这个指针指向我们定义的FGameplayAttributeData。

FGameplayAttribute还提供帮助函数，该函数通过反射机制，找个它所描述的那个FGameplayAttributeData
```cpp
const FGameplayAttributeData* FGameplayAttribute::GetGameplayAttributeData(const UAttributeSet* Src) const
{
	if (Src && IsGameplayAttributeDataProperty(Attribute.Get()))
	{
		FStructProperty* StructProperty = CastField<FStructProperty>(Attribute.Get());
		check(StructProperty);
		MARK_PROPERTY_DIRTY(Src, StructProperty);
		return StructProperty->ContainerPtrToValuePtr<FGameplayAttributeData>(Src);
	}

	return nullptr;
}
```
总得来说，`AttributeToCapture` 是一个包装了 `FProperty` 指针的 `FGameplayAttribute`，它描述了属性的元数据。在实际使用时，通过 `Spec` 找到具体的 `AttributeSet` 实例，然后根据 `FProperty` 指针，从 `AttributeSet` 实例中查找并获取属性的实际值。





    
