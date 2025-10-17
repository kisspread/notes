---
title: CommonUI 的Focus 导致的问题
comments:  true
---

::: warning
加入了commonUI后，总有一些意想不到的问题，研究了一下。
:::

总结一下可能遇到的问题：

- Input Mode 和 CommonUI 冲突 
- 导航键（键盘的Tab,手柄的DPad） 被CommonUI占用
- 确认键（FaceButton Bottom） 被CommonUI占用     


---

## TL;DR 太长不看

commonUI 有两个“Focus”, 一个是Widget的Focus，另一个是Input Mode 的Focus。

- 如果当前屏幕里有 focus的widget，那么导航键 就有可能被 CommonUI 吃掉，尤其是 Input Mode是All的情况。取消勾选 Focusable 即可：![alt text](../../assets/images/01Focus_image.webp)
或者，在 OnFocusReceived里面，手动调用	Set Focus to Game Viewport

- CommonUI 没有自动激活相应的 Input Mode，勾选Supports Activation Focus 即可。

- 确认键（FaceButton Bottom） 被CommonUI占用：可以通过 C++ [重写父类判断的方法来解决](./07CustomAnalogCursor.md)


---


## 一些概念

让AI总结了一些

> 在 Unreal Engine 的 Slate 和 UMG 系统中，"Focus Path" 是一个重要的概念，用于管理用户界面中焦点的导航和传递。焦点路径主要用于键盘和游戏手柄等输入设备的焦点管理。
### Focus Path 的定义

**Focus Path** 是指一系列的 Widget，通过这些 Widget 焦点可以顺畅地导航。焦点路径用于管理用户界面中焦点的传递，特别是键盘和游戏手柄等输入设备的焦点管理。

### 注释分析

#### 路由事件

```cpp
/**
 * Route an event along a focus path (as opposed to PointerPath)
 *
 * Focus paths are used focus devices.(e.g. Keyboard or Game Pads)
 * Focus paths change when the user navigates focus (e.g. Tab or
 * Shift Tab, clicks on a focusable widget, or navigation with keyboard/game pad.)
 */
```

这段注释解释了焦点路径与指针路径（PointerPath）的区别。焦点路径专门用于焦点设备（如键盘和游戏手柄）。当用户通过 Tab、Shift Tab、点击一个可以获取焦点的 Widget 或使用键盘/游戏手柄进行导航时，焦点路径会发生变化。

- **PointerPath**：指的是与鼠标指针相关的路径。
- **Focus Path**：指的是与键盘或游戏手柄等焦点设备相关的路径。

#### 焦点路径中的事件

```cpp
/**
 * If focus is gained on on this widget or on a child widget and this widget is added
 * to the focus path, and wasn't previously part of it, this event is called.
 *
 * @param  InFocusEvent  FocusEvent
 */
UFUNCTION(BlueprintImplementableEvent, BlueprintCosmetic, Category="Input")
UMG_API void OnAddedToFocusPath(FFocusEvent InFocusEvent);
```

这段注释和代码解释了当一个 Widget 或其子 Widget 获得焦点，并且该 Widget 被添加到焦点路径中时会触发的事件。具体来说，如果一个 Widget 之前不在焦点路径中，但由于焦点的转移（例如用户按下 Tab 键）而被添加到焦点路径中，就会触发 `OnAddedToFocusPath` 事件。

- **InFocusEvent**：这是一个 `FFocusEvent` 对象，包含了与焦点变化相关的信息。

### RouteAlongFocusPath 方法

`RouteAlongFocusPath` 方法通常用于将事件沿着焦点路径进行传递。它确保焦点路径中的每个 Widget 都能正确地接收到和处理事件。例如，当用户按下 Tab 键时，焦点会从一个 Widget 转移到下一个 Widget，`RouteAlongFocusPath` 方法会确保这个过程顺利进行。

### FocusPath 总结

- **Focus Path** 是一系列可以顺畅导航的 Widget，用于管理键盘和游戏手柄等输入设备的焦点。
- **RouteAlongFocusPath** 方法用于将事件沿着焦点路径进行传递，确保每个 Widget 都能正确处理事件。
- **OnAddedToFocusPath** 事件在 Widget 被添加到焦点路径时触发，用于处理焦点变化。

`FReply` 类是 Unreal Engine 5 中用于处理 Slate 事件响应的一个核心类。它的主要功能是通知系统某个事件是如何被处理的，以及指示系统在处理事件后需要执行的操作。以下是对这个类的分析：

### FReply

所以输入事件的操作，都是通过构造一个FReply对象，并对其设置响应的值，一层一层地传递处理。

`FReply` 类是一个用于在 Slate 系统中处理和响应事件的工具类。它提供了丰富的 API，用于指示系统如何处理鼠标事件、焦点管理、导航、拖拽操作等。通过返回 `FReply` 对象，开发者可以灵活地控制事件处理流程，增强用户交互体验。

1. **事件处理状态**：
   - `Handled()` 和 `Unhandled()` 静态方法用于创建一个表示事件处理状态的 `FReply` 对象。`Handled()` 表示事件已被处理，`Unhandled()` 表示事件未被处理。

2. **鼠标事件处理**：

注意，这些都是设置相应的值，最终处理是在Tick里。

   - `CaptureMouse(TSharedRef<SWidget> InMouseCaptor)`：请求系统将鼠标事件捕获到指定的 Widget。
   - `UseHighPrecisionMouseMovement(TSharedRef<SWidget> InMouseCaptor)`：请求启用高精度鼠标移动。
   - `SetMousePos(const FIntPoint& NewMousePos)`：请求将鼠标光标移动到指定位置。
   - `LockMouseToWidget(TSharedRef<SWidget> InWidget)`：请求将鼠标锁定在指定 Widget 的范围内。
   - `ReleaseMouseLock()`：请求释放鼠标锁定。
   - `ReleaseMouseCapture()`：请求释放鼠标捕获。

3. **焦点管理**：
   - `SetUserFocus(TSharedRef<SWidget> GiveMeFocus, EFocusCause ReasonFocusIsChanging, bool bInAllUsers)`：请求将用户焦点设置到指定的 Widget。
   - `ClearUserFocus(bool bInAllUsers)` 和 `ClearUserFocus(EFocusCause ReasonFocusIsChanging, bool bInAllUsers)`：请求清除用户焦点。
   - `CancelFocusRequest()`：取消先前的焦点请求。

4. **导航**：
   - `SetNavigation(EUINavigation InNavigationType, const ENavigationGenesis InNavigationGenesis, const ENavigationSource InNavigationSource)`：请求系统尝试进行指定类型的导航。
   - `SetNavigation(TSharedRef<SWidget> InNavigationDestination, const ENavigationGenesis InNavigationGenesis, const ENavigationSource InNavigationSource)`：请求导航到指定的 Widget。

5. **拖拽操作**：
   - `DetectDrag(const TSharedRef<SWidget>& DetectDragInMe, FKey MouseButton)`：请求系统检测指定 Widget 的拖拽操作。
   - `BeginDragDrop(TSharedRef<FDragDropOperation> InDragDropContent)`：开始一个拖拽操作。
   - `EndDragDrop()`：结束当前的拖拽操作。

6. **其他操作**：
   - `PreventThrottling()`：请求在鼠标按下时不进行 UI 响应的节流。

### FCommonAnalogCursor

#### 函数 `IsGameViewportInFocusPathWithoutCapture`

```cpp
/**
 * A ridiculous function name, but we have this exact question in a few places.
 * We don't care about input while our owning player's game viewport isn't involved in the focus path,
 * but we also want to hold off doing anything while that game viewport has full capture.
 * So we need that "relevant, but not exclusive" sweet spot.
 */
bool IsGameViewportInFocusPathWithoutCapture() const;
```

::: warning
官方说这个函数的名字很搞笑。。
:::

这段注释解释了函数 `IsGameViewportInFocusPathWithoutCapture` 的作用：

- **不关心输入**：当拥有玩家的 `GameViewport` 不在焦点路径中时，我们不关心输入。
- **暂停操作**：当 `GameViewport` 完全捕获输入时（即具有全捕获），我们也不做任何操作。
- **理想状态**：我们寻求的是一个“相关但不独占”（“relevant, but not exclusive”）的状态，即 `GameViewport` 在焦点路径中，但没有完全捕获输入。


#### 方法 `Tick`

```cpp
void FCommonAnalogCursor::Tick(const float DeltaTime, FSlateApplication& SlateApp, TSharedRef<ICursor> Cursor)
{
	// Refreshing visibility per tick to address multiplayer p2 cursor visibility getting stuck
	RefreshCursorVisibility();

	// Don't bother trying to do anything while the game viewport has capture
	if (IsUsingGamepad() && IsGameViewportInFocusPathWithoutCapture())
	{
		// 省略其他代码
	}
```

在 `Tick` 方法中，我们可以看到对 `IsGameViewportInFocusPathWithoutCapture` 的调用：

- **刷新光标可见性**：每一帧刷新光标的可见性，以解决多玩家第二个玩家光标可见性卡住的问题。
- **判断条件**：如果正在使用游戏手柄，并且 `GameViewport` 在焦点路径中但没有捕获光标，则执行后续代码。   


 大致了解FReply，在看官方这个图，就好理解很多。
![alt text](../../assets/images/01Focus_image-1.webp)

### 官方说明

When navigation input occurs, the input is handled by the default `SWidget::OnKeyDown` or` SWidget::OnAnalogValueChanged` methods. However, these default methods do not directly change widget focus. Instead, the following occurs:

The navigation method uses either `FSlateApplication::GetNavigationDirectionFromKey` or `FSlateApplication::GetNavigationDirectionFromAnalog` to translate the input into a navigation direction. It takes the Navigation Config for the widget into account when it runs this translation.

The navigation direction is captured and included in the `FReply::Handled` reply, which is sent through` FReply::SetNavigation`.

::: warning
FReply can carry a lot of contextual information. For more see the information on FReply in the Input Routing section below.
:::

Slate starts processing the FReply using `FSlateApplication::ProcessReply`, which causes navigation to occur. If a navigation event is loosely defined by direction, then `_FSlateApplication::AttemptNavigation` _attempts to find the correct widget to navigate to.

If possible, `FSlateApplication::ExecuteNavigation` navigates to the destination widget.

If the destination widget is valid, `FSlateApplication::SetUserFocus` is called on that widget. This happens whether the destination widget was specified directly, or found beforehand.

After the Slate focus navigation occurs, `FCommonAnalogCursor::Tick` automatically moves and centers the synthetic cursor onto the focused widget during the next tick.

This makes it possible to use hover effects when you use a gamepad.