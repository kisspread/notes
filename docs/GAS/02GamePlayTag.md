title: Using macro to define Native Gameplay Tag
comments:true

!!! note 
    This post base on Aura GAS Course

---
## GamePlayTag

这里记录 gameplay tag的一些用法

### 获取GameplayTag最后一个节点的名字
通常最后一个节点是个经常要用的string 或者 KEY，很有用
```cpp
FName UAuraAbilitySystemLibrary::GetTagLastNodeName(const FGameplayTag& Tag)
{
	if (!Tag.IsValid()) return NAME_None;
	const UGameplayTagsManager& Manager = UGameplayTagsManager::Get();
	return  Manager.FindTagNode(Tag)->GetSimpleTagName();
}
```

### 找出所有的子tag

这里返回 所有 **Attribute.Primary.*** 的tag

```cpp
//自定义一个函数方便获取
FGameplayTagContainer RequestAllGameplayTags(const FGameplayTag ParentTag)
	{
		const UGameplayTagsManager& Manager = UGameplayTagsManager::Get();
		return Manager.RequestGameplayTagChildren(ParentTag);
	}

//或者
const UGameplayTagsManager& Manager = UGameplayTagsManager::Get();
const FGameplayTagContainer PrimaryTags = Manager.RequestGameplayTagChildren(FGameplayTag::RequestGameplayTag("Attribute.Primary", false));

```		


