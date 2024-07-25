title:Auto Created Cooldown GE
comments:true

大部分技能的冷却都是非常简单的配置，我不想每个简单的GE 都去手动创建，所以这里我写了一个自动创建的 Asset Action。

大概200多行代码，可以作为其他Action的模板，过程中我学到了很多东西，我会附上这个功能的完整代码，希望它对你也有帮助。

![alt text](../assets/images/01EditorModule_image-4.png)

---

### 思路
!!! note
    之前的实践告诉我，我们最好不要在运行时[动态创建GE](../GAS/5CooldownGE.md),所以这里就直接用Asset Action自动创建。

在Gamepaly Ability 里面定义冷却时间字段，然后右键 找个自定义 Action然后自动创建一个GE。除了创建GE本身，还有创建一个对应的cool down Tag.

### Editor Module

由于对 Asset经常操作，是属于 Editor Module的内容，所以需要先创建一个 Editor Module，

- 使用Rider可以很好地帮我们创建
  ![alt text](../assets/images/01EditorModule_image.png)

- 添加依赖 (private 还是 public 写的过程中Rider自动添加我没去管)
  ![alt text](../assets/images/01EditorModule.zh_image.png)

### 自定义AssetDefinition
 原本是使用 UAssetDefinitionDefault 来实现 asset action的，但注释提示说，这个类已经过时了，需要用AssetDefinition

一开始我直接 UGameplayAbility 对创建AssetDefinition，但发现 UGameplayAbility其实是属于 blueprint asset，而 blueprint asset 必然是已经在引擎内部实现了，自己实现的会覆盖掉引擎内部的实现，可能要继承，但情况就变得复杂。好在看到内部的例子，AssetDefinition 不是一定要实现的。可参考【GameplayAbilityAudit】的实现。

### 自定义MenuExtension_xxx

`namespace MenuExtension_YourActions`

只需要在命名空间里实现 一个叫做 **延迟注册**的方法即可。 

`static FDelayedAutoRegisterHelper DelayedAutoRegister(EDelayedRegisterRunPhase::EndOfEngineInit, []`

### 实现细节

有两个主要细节：
 - 创建GE 的蓝图资产
 - 创建GameplayTag 并保存到 .ini 文件里

#### 创建GE
`FAssetToolsModule& AssetToolsModule = FModuleManager::GetModuleChecked<FAssetToolsModule>("AssetTools");`

首先获得AssetToolsModule 

```cpp
UBlueprintFactory* BlueprintFactory = NewObject<UBlueprintFactory>();
BlueprintFactory->ParentClass = UGameplayEffect::StaticClass();
// do not Use GE directly
// UGameplayEffect* NewGE = Cast<UGameplayEffect>(AssetToolsModule.Get().CreateAsset(CooldownGEName, NewGEPath, UGameplayEffect::StaticClass(), nullptr));
UObject* CreatedAsset = AssetToolsModule.Get().CreateAsset(CooldownGEName, NewGEPath, UBlueprint::StaticClass(), BlueprintFactory);

```

创建GE的蓝图资产，这里需要使用BlueprintFactory，而不是直接用UGameplayEffect来创建，不然只会获得UGameplayEffect的默认类型，而不是它蓝图资产。

```cpp
// GE Blueprint Asset Class
UClass* GeneratedClass = GE_Blueprint->GeneratedClass;
// use the CDO, not New Object
UGameplayEffect* NewGE = Cast<UGameplayEffect>(GeneratedClass->GetDefaultObject());

```

然后就是获得该蓝图里的GeneratedClass，以及内部的CDO，才能用代码给他赋值。

#### 创建GameplayTag

需用用到IGameplayTagsEditorModule，所以必须先添加依赖。用法比较简单：

- 判断项目是否允许通过ini 文件来创建GameplayTag
    ```cpp
    const UGameplayTagsManager& Manager = UGameplayTagsManager::Get();
    // Only support adding tags via ini file
    if (Manager.ShouldImportTagsFromINI() == false)
    {
        return;
    }
    ```
 - 创建GameplayTag, `static FName DefaultTagINI = "DefaultGameplayTags.ini";` 文件名暂时默认为 `DefaultGameplayTags.ini`
    ```cpp
    const TSharedPtr<FGameplayTagNode> TagNode = Manager.FindTagNode(CooldownTagName);
		if (!TagNode.IsValid())
		{
			const FString TagComment = FString::Format(TEXT("Auto Gen Cooldown Tag for {0}"), {TagName});
			IGameplayTagsEditorModule::Get().AddNewGameplayTagToINI(TagName, TagComment, DefaultTagINI);
		}
    ```    


#### 完整代码
[GamePlayAbilityGenCooldownGE](https://github.com/kisspread/notes/blob/main/sample code/CustomAssesAction/GamePlayAbilityGenCooldownGE.cpp)


### 其他尝试

#### blueprint editor script

![alt text](../assets/images/01EditorModule_image-3.png)

我进行过尝试，但只能创建GE文件，赋值部分暂时没找到方法。
Set Editor Property 我不知道如何操作，如果有人知道，请留言。

![alt text](../assets/images/01EditorModule_image-2.png)