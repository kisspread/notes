---
title: CommonUI 控件组
comments:  true
---


### UCommonWidgetGroupBase

控件组类似 Android的 RadioGroup，（可选组，单选多选）。

不同的的是：控件组 不是 UserWidget，不是控件，而是逻辑对象。 它继承与 UObject。用于统一逻辑调度，并暴露方法给蓝图和C++使用

Android的RadioGroup是控件, 并没有单独抽象出“可选组”的逻辑，相似的控件无法复用逻辑代码，导致Android必须额外实现TabLayout这种东西。



![alt text](../../assets/images/09WidgetGroup_image.webp)

控件组基类 只提供 增删功能，非常简洁。





### UCommonButtonGroupBase 是具体实现，也是目前唯一的实现。

目前只有TabList 和 CarouseNavBar 使用。

提供了：
- 增删查 的各种接口，相应的回调监听
- 单选
- 多选 // 不是特别支持
- 循环切换
- 弃选

![alt text](../../assets/images/09WidgetGroup_image-1.webp)


#### 由于是纯逻辑对象，布局操作交给开发者自定义实现


参考UCommonTabListWidgetBase : public UCommonUserWidget的实现：

它又包装了一下，主要的这两个函数
```cpp
	UFUNCTION(BlueprintNativeEvent, Category = TabList, meta = (BlueprintProtected = "true"))
	void HandleTabCreation(FName TabNameID, UCommonButtonBase* TabButton);

	UFUNCTION(BlueprintNativeEvent, Category = TabList, meta = (BlueprintProtected = "true"))
	void HandleTabRemoval(FName TabNameID, UCommonButtonBase* TabButton);
```

UI蓝图里，需要自己指定Button的布局容器。这里的 Add Tab用了 Horizon Box 来布局

![alt text](../../assets/images/09WidgetGroup_image-2.webp)





#### 一些需要注意的细节

当只有一个子widget的时候，会默认调用“选中”方法。在219行

（默认没有声音）

所以第一个add进来的widget，默认是一定会选中的，除非不满足 相关条件。


![alt text](../../assets/images/commonui_image.webp)