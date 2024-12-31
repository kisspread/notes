---
title: UE5 使用UInputAction 代替 FDataTableRowHandle
comments:  true
----

开启EnhancedInput支持，这样就可以在CommonUI中使用EnhancedInputAction（就是UInputAction）

目前，（UE5.5分支）Lyra 的源码里，还在用旧版写法（FDataTableRowHandle）。

### 开关：

`CommonInput.CommonInputSettings.IsEnhancedInputSupportEnabled`

### 使用 

```cpp
	/** 
	 *	The enhanced input action that is bound to this button. The common input manager will trigger this button to 
	 *	click if the action was pressed 
	 */
	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = Input, meta = (EditCondition = "CommonInput.CommonInputSettings.IsEnhancedInputSupportEnabled", EditConditionHides))
	TObjectPtr<UInputAction> TriggeringEnhancedInputAction;
 ```   

 而不是`FDataTableRowHandle TriggeringInputAction;`

这个Action, 可以设置给 CommonUI的CommonBaseButton，完成绑定。


同时，在Button内部，TriggeringEnhancedInputAction 会通过SetEnhancedInputAction设置给InputActionWidget，用于显示快捷键。InputActionWidget不是必须的，这是一个可选项。

```cpp
	UPROPERTY(BlueprintReadOnly, Category = Input, meta = (BindWidget, OptionalWidget = true, AllowPrivateAccess = true))
	TObjectPtr<UCommonActionWidget> InputActionWidget;
```

这样，就完成和CommonUI的“快捷键绑定”。


更多用法：[让CommonButton支持Hold](./03Hold%20Support%20For%20Enhnaced%20Input.md)