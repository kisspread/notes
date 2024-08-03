title: GAS GE Custom Calculation
comments:true


### 使用方式

- 简单计算，继承 `UGameplayModMagnitudeCalculation`
- 复杂计算，继承 `UGameplayEffectExecutionCalculation`

#### UGameplayModMagnitudeCalculation

- CalculateBaseMagnitude：用于设置基础值计算规则， base value,也就是说最终值是由基础值和pre/post系数计算出来的。
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
 该类提供了高度的灵活性，可以处理几乎所有你能想到的与游戏效果相关的逻辑。
 基本上蓝图配置 GE 各种 modified，都可以直接在 继承该C++类 实现。

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
### 理解为何是这样设计

GE是的数值游戏，GE可以看成是一个数值计算函数。比如`GE_FireDamage(A,B)`,必然有参与的双方A和B，其中A是源属性，B是目标属性。那么计算过程就要获得A的火属性伤害，和B的火属性防御。

#### 实际样子
出于性能考虑，这个函数最好不要把A和B的整个AttributeSet 传进来。
所以，这个函数应该是类似这样的：
`GE_FireDamage(FireDamgeFromARef,FireResistanceFromBRef)`

这里FireDamgeFromARef的形式，就类似“捕获”。也可以理解成路径。

### UE里实现的捕获
由于不想操作整个AttributeSet，所以就得知道这个函数需要用到哪些属性，运行过程中读取出来，供后续去使用。这个过程就叫做捕获。

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
AttributeToCapture 是FGameplayAttribute，是我们定义 AttributeSet时的最小单元。
#### FGameplayAttribute 和 FGameplayAttributeData
通过上述分析，实际上 FGameplayAttribute也只是包装了FProperty指针而已，内部字段并没有包含真正的属性值。查看源码发现FGameplayAttributeData 才是真正的属性值。

该函数通过反射机制，很神奇地变成了FGameplayAttributeData，里面的baseValeu和CurrentValue就是真正的值。 过程过于复杂不敢再深究，了解即可。
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





    
