title: EnhancedInput 和 commonUI 配合的数据配置
comments= true

本篇是记录向，没做阅读优化，慎看，仅供参考。

---
## InputAction

![usersettting](../../assets/images/EnhancedInput_image.png)
这里可以配置Metadata，作为输入的“元数据”

默认的“元数据” 只有两个字段，NavBarPriority 和 bIsGenericInputAction
```cpp
class COMMONUI_API UCommonInputMetadata : public UObject
{
	GENERATED_BODY()

public:

	/** Priority in nav-bar */
	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "CommonInput")
	int32 NavBarPriority = 0;

	/** 
	 * Generic actions like accept or face button top will be subscribed to by multiple
	 * UI elements. These actions will not broadcast enhanced input action delegates
	 * such as "Triggered, Ongoing, Canceled, or Completed." Since those delegates
	 * would be fired by multiple UI elements.
	 * 
	 * Non-generic input actions will fire Enhanced Input events. However they will 
	 * not fire CommonUI action bindings (Since those can be manually fired in BP).
	 */
	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "CommonInput")
	bool bIsGenericInputAction = true;
};
```

### 默认metadata的作用
- NavBarPriority 用于ActionBar的排序，Router会收集所有活动的Action，然后通知`UCommonBoundActionBar::HandleDeferredDisplayUpdate()`进行更新
  ![alt text](../../assets/images/EnhancedInput_image-1.png) 
- bIsGenericInputAction 如果是通用输入，则不会注入 enhanced input的逻辑，具体代码在 `auto TryConsumeInput = [&](const FKey& InKey, const UInputAction* InInputAction)`
    ![alt text](../../assets/images/EnhancedInput_image-2.png)
    也就是widget里 自定义的enhanced input action不会被系统触发。
    ![alt text](../../assets/images/EnhancedInput_image-6.png)

综上，使用ActionBar 和 EnhancedInput 配置上面这两个字段还是非常重要的。 
bIsGenericInputAction默认值是true，会导致widget里普通的enhanced input 不绑定。

## Process Input
上面提到的TryConsumeInput是`FActionRouterBindingCollection::ProcessNormalInput`的临时内部函数，这里的处理比较复杂，尝试记录一下我的理解
### input 的来源
- 键盘输入：从application 一路去到 GameViewPort Client, 最终由 ActionRouter 进行最后的分发
  ![alt text](../../assets/images/EnhancedInput_image-3.png)
- 鼠标输入：大致相同
  ![alt text](../../assets/images/EnhancedInput_image-4.png)
- 手柄输入：
  ![alt text](../../assets/images/EnhancedInput_image-5.png)

### 开始处理
系统传给ActionRouter 的input是 KEY 和 InputEvet（按下，释放）， ActionRouter会结合当前的 ActiveMode进行处理。目前定义了2+1 种。

```cpp
enum class ECommonInputMode : uint8
{
	Menu	UMETA(Tooltip = "Input is received by the UI only"),
	Game	UMETA(Tooltip = "Input is received by the Game only"),
	All		UMETA(Tooltip = "Input is received by UI and the Game"),

	MAX UMETA(Hidden)
};
```

ActivatableWidget（通常是各种菜单的最外层）可以对InputConfig进行配置：这里配置的InputMode就是ECommonInputMode，从而影响 ActionRouter对事件的分发。
![alt text](../../assets/images/EnhancedInput_image-8.png)

另外，CommonBaseButton 可以对自身绑定的Input进行覆盖
![alt text](../../assets/images/EnhancedInput_image-7.png)

可以看到，处理输入时，是根据当前InputMode是否匹配，才会进行处理。如果输入不起作用，很可能是Mode没有设置正确。

```cpp
EProcessHoldActionResult FActionRouterBindingCollection::ProcessHoldInput(ECommonInputMode ActiveInputMode, FKey Key, EInputEvent InputEvent) const
{
	for (FUIActionBindingHandle BindingHandle : ActionBindings)
	{
		if (TSharedPtr<FUIActionBinding> Binding = FUIActionBinding::FindBinding(BindingHandle))
		{
			if (ActiveInputMode == ECommonInputMode::All || ActiveInputMode == Binding->InputMode)

```
每当 ActionRouter Tick的时候，会判断是否有pending Widget 需要注册事件。支持 CommonInputAction的widget 都会在创建的时候，注册需要绑定的事件, 供ActionRouter在tick的时候进行绑定。
![alt text](../../assets/images/EnhancedInput_image-9.png)
按下按键的时候，由ViewPort接受事件，调用ActionRouter进行处理 `UCommonGameViewportClient::HandleRerouteInput`
![alt text](../../assets/images/EnhancedInput_image-12.png)
绑定的事件，最终在Process Input细分，优先处理HoldInput，然后才是normal Input， 逐层handle，逐层消费。
PersistentActions的处理优先级最高，然后才是ActiveRootNode（它是一个FActivatableTreeNode : public FActionRouterBindingCollection）,接着是domain，这个不是enhanced input，不讨论。
![alt text](../../assets/images/EnhancedInput_image-11.png)

 Press和 Release的Input Action 大体上相同，只是入口不一样，下图是Pressed 和 Relased最开始的地方。调用ProcessKeyDownEvent 和 ProcessKeyUpEvent 分别处理。
![FSlateApplication::OnControllerButtonPressed](../../assets/images/EnhancedInput_image-13.png)
不同之处在于，Release阶段 还有后续处理，依旧是用ProcessInput 细分处理。
`ActionRouter.ProcessInput(InKeyEvent.GetKey(), IE_Released) == ERouteUIInputResult::Handled`。如果结果是没有任何widget handle action，就会调用`FAnalogCursor::HandleKeyUpEvent(SlateApp, InKeyEvent);`构建虚拟鼠标事件。

### Hold Threshold
按住有个最小时间的设定，是写死的，默认是四分之一秒,否则就会要求下一步生成一个Press 事件

``` cpp
static const float PressToHoldThreshold = 0.25f;
if (SecondsHeld <= PressToHoldThreshold && SecondsHeld < HoldMapping.HoldTime)
{
    ProcessResult = EProcessHoldActionResult::GeneratePress;
}

```


### AnalogCursor 处理
这是一个模拟鼠标点击的工具
``` cpp
bool FCommonAnalogCursor::HandleKeyUpEvent(FSlateApplication& SlateApp, const FKeyEvent& InKeyEvent)

//最终通过
SlateApp.ProcessMouseButtonUpEvent(MouseEvent); //模拟

```
## 默认KEY

```cpp
/** Remap a given key to something else if necessary. */
	FORCEINLINE static FKey RemapKey(FKey Key) { return Key; }

	static FKey GetGamepadAcceptKey()
	{
		return EKeys::Gamepad_FaceButton_Bottom;
	}

	static FKey GetGamepadBackKey()
	{
		return EKeys::Gamepad_FaceButton_Right;
	}

	static FKey GetPlatformDeleteKey()
	{
		return EKeys::Delete;
	}
```
经过上面的分析得知，当Input（抬起key）没有任何 Widget 去Care的时候，会执行默认行为：
其中box手柄的 face button Bottom ，也就是A按钮，会构造一个鼠标左键行为（按下或者按住）。
![alt text](../../assets/images/EnhancedInput_image-10.png)
所以，如果想要屏蔽默认的A键点击动作，有两个办法
- 处理这个A键，绑定它
- 改个isRepeat = true给它。
- 看起来可以 remap key, 但还没实现，知道的大佬分享一下：
    ``` cpp
    /** Remap a given key to something else if necessary. */
    FORCEINLINE static FKey RemapKey(FKey Key) { return Key; }
    ```

## 疑问 1
- 为什么修改了Enhance default Click Action ，只有图标改变，Action 还是 Faceb Button Bottom ? 
  ![alt text](../../assets/images/EnhancedInput_image-14.png)
  因为 首先默认 GetGamepadAcceptKey 是写死的A，其次并没有显式注册  default Click Action
- 为什么图标更新了？这不是说明能拿到 default Click Action吗？
  因为 图标是CommonActionWidget 设置的，在CommonBaseButton Hovered的时候，会获取`HoverEnhancedInputAction = ICommonInputModule::GetSettings().GetEnhancedInputClickAction();`
  ![alt text](../../assets/images/EnhancedInput_image-15.png)
  这里只是为了设置Icon，并没有把绑定事件给Button

    BaseButton代码显示，它是通过判断IsHovered，来决定是否创建HoverEnhancedInputAction
    ```cpp
    UInputAction* HoverEnhancedInputAction = nullptr;
                if (IsHovered())
                {
                    if (bIsEnhancedInputSupportEnabled)
                    {
                        HoverEnhancedInputAction = ICommonInputModule::GetSettings().GetEnhancedInputClickAction();
                    }
                    else
                    {
                        HoverStateHandle = ICommonInputModule::GetSettings().GetDefaultClickAction();
                    }
                }
                //并设置给Icon Widget
                if (bIsEnhancedInputSupportEnabled)
                {
                    InputActionWidget->SetEnhancedInputAction(HoverEnhancedInputAction);
                }

    ```
    变通解法就是，在OnHovered 和 UnHoverd 获取 Action widget 的Enhanced Input，适当的时候手动绑定。和取消绑定。

 ## 疑问 2
- 为什么Enhanced Input 作为 Trigger Action的时候，Hold 无法正确生效？
    
    因为缺少HoldMapping，这里必须有HoldMapping，才会执行到for内部
    ![alt text](../../assets/images/EnhancedInput_image-16.png)
    
    然而在处理HoldMapping的时候，偏偏不处理Enhanced Input的。注释说，不在这里处理HoldMapping，但我没发现其他地方有给它设置。全局搜索都搜不到。
    ``` cpp title='UIActionRouterTypes.cpp'
    else if (CommonUI::IsEnhancedInputSupportEnabled() && BindArgs.InputAction.IsValid())
        {
            // Nothing else to do if we have an enhanced input action,
            // the input action itself will be queried against for keys later
        }
    ```
    一种解法是：用UIActionTag来解决，因为代码里会给有Tag的Action进行HoldMapping绑定。但Action要定义在这图里的设置里。而且根本不是enhanced input。
    ![alt text](../../assets/images/EnhancedInput_image-17.png)

     我看到有人依旧提交了相关[Pull Request](https://github.com/EpicGames/UnrealEngine/pull/11985), 他的改动很多，感觉官方没那么快合并。

     我实现了一种不用修改源码的办法：
    ```cpp
    void UWidgetLibraryHelp::AddHoldBinding(const TSharedPtr<FUIActionBinding>& ActionBinding, UInputAction* BEnhancedInputAction, const ULocalPlayer* LocalPlayer)

    {
        if (const UEnhancedInputLocalPlayerSubsystem* InputSystem = LocalPlayer->GetSubsystem<UEnhancedInputLocalPlayerSubsystem>())
        {
            for (const FEnhancedActionKeyMapping& Mapping : InputSystem->GetAllPlayerMappableActionKeyMappings())
            {
                if (Mapping.Action == BEnhancedInputAction)
                {
                    UInputTriggerHold* Trigger = nullptr;
                    Mapping.Action->Triggers.FindItemByClass(&Trigger);
                    if (Trigger)
                    {
                        FUIActionKeyMapping KeyMapping(Mapping.Key, Trigger->HoldTimeThreshold, Trigger->HoldTimeThreshold);
                        ActionBinding->HoldMappings.Add(KeyMapping);
                    }
                    else
                    {
                        FUIActionKeyMapping KeyMapping(Mapping.Key, 0.75f, 0.75f);
                        ActionBinding->HoldMappings.Add(KeyMapping);
                    }
                }
            }
        }
    }

    // 调用
    UWidgetLibraryHelp::AddHoldBinding(ActionBinding, YourEnhancedInputAction, GetOwningLocalPlayer());
  ```
  




## 疑问 3

- 为什么 Enhanced trigger 的Pressed和 BaseButton 的 Pressed没有关联？ 也就是键盘 按下的时候，界面里 Button的 Pressed 并没有出现按下的状态？(默认点击按钮除外，face Button A 是构建虚拟鼠标按下)

  因为 它们不是双向关联的，目前的单向的。 我们给界面按钮 设置一个 Enhanced Trigger，我们把这个trigger当作一种快捷键的话，那么这个按钮在构建的时候，就会去绑定绑定这个快捷键的事件。但快捷键按下的时候，激活自身的点击事件。但这个点击事件，并不会激活stale 原始点击。猜测如果激活，可能导致死循环，因为原始点击事件 是用来 触发 按钮自身的点击事件的。
  目前没有好的办法，一种做法是 在 CommonBaseButton 的子类里，自己实现按住和抬起的 style 切换，比较麻烦。







