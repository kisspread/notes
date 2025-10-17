---
title: CommonUI 使用总结
comments:  true
---

# CommonUI 使用总结

这几天使用CommonUI 进行小界面搭建，发现还是存在许多要注意的问题，重新记录一下，之前的笔记虽然也提到了相关知识点，但比较散乱，没突出重点。

## 配置

1. 启用插件 YourProject.uproject
```json
{
    "Name": "CommonUI",
    "Enabled": true
},
```
2. 使用CommonUI自带的GameViewportClient, 这步不能漏，它是CommonUI模拟输入的核心实现
```ini
[/Script/Engine.Engine]
GameViewportClientClassName=/Script/CommonUI.CommonGameViewportClient  
```
![alt text](../../assets/images/000CommonUI_image-1.webp)

3. 启用EnhancedInput支持
```ini
DefaultPlayerInputClass=/Script/EnhancedInput.EnhancedPlayerInput
DefaultInputComponentClass=/Script/EnhancedInput.EnhancedInputComponent
```

4. 启用 CommonUI 的EnhancedInput支持 和 默认前进后退热键配置
```ini
[/Script/CommonInput.CommonInputSettings]
bEnableEnhancedInputSupport=True
InputData=/Game/Blueprints/Inputs/CommonInput/B_CommonUI_DefaultAction.B_CommonUI_DefaultAction_C
bAllowOutOfFocusDeviceInput=True
```
创建两个InputAction，默认的前进后退
![alt text](../../assets/images/000CommonUI_image-2.webp){width=70%}

5. 配置CommonUI 平台相关的图标
```ini
# windows 平台配置
[CommonInputPlatformSettings_Windows CommonInputPlatformSettings]
DefaultInputType=MouseAndKeyboard
bSupportsMouseAndKeyboard=True
bSupportsTouch=False
bSupportsGamepad=True
DefaultGamepadName=XSX #这个名字不能错要和下面ControllerData里面的名字对应， 否则小图标无法生效
bCanChangeGamepadType=True
+ControllerData=/Game/Blueprints/Inputs/Platform/GamepadXboxSeriesX/CommonInput_Gamepad_XSX.CommonInput_Gamepad_XSX_C
+ControllerData=/Game/Blueprints/Inputs/Platform/KeyboardMouse/CommonInput_KeyboardMouse.CommonInput_KeyboardMouse_C
```
注意：DefaultGamepadName=XSX 和这里的名字要对应
![alt text](../../assets/images/000CommonUI_image-5.webp){width=40%}

4-5 都在这里配置：
![alt text](../../assets/images/000CommonUI_image.webp){width=75%}


## 配置自响应输入模式

没有使用CommonUI时，需要自己手动调用 `setInputMode`相关的方法，来决定当前操作是游戏还是UI。如，显示菜单时，需要显示鼠标和忽略角色的移动控制。

CommonUI 使用 `Activatable Widget` 来自动响应输入模式。[详细](./00How%20to%20setup%20CommonUI%20in%20UE5.4.2_zh.md)

我们可以把 每一个 `Activatable Widget` 都当做一个页面（不过一个屏幕里可能同时存在多个），每个页面在视图顶部既“激活时”，它的输入配置将被自动应用到全局。当他们不是激活状态时，后一个页面的输入配置将被应用到全局。

一种最简单的设计就是，最底层放一个 HUB的页面，它的配置设计为 “Game”或者“ALL”，然后其他Menu页面都配置为“UI”。

这样菜单显示的时候，就会自动切换到 “UI”模式，菜单隐藏的时候，就会切换回 “Game”模式。

### 构建一个主页面

最简单的做法，只创建一个stack。
- 创建一个RootLayout，放置一个`UCommonActivatableWidgetStack`, 设置沾满全屏
- 写个Push方法，支持把其他页面推入栈顶

### HUB 页面配置
- 需要的话，还可以勾选隐藏鼠标
![image](<../../assets/images/How to setup CommonUI in UE5.4.2_image-3.png>)

### Menu 页面配置
- 需要注意，Menu模式的页面 必须选择 NO Capture, 否则有点小问题
![image](<../../assets/images/How to setup CommonUI in UE5.4.2_image-2.png>)

### 自动响应的前提
也就是在stack的栈顶的时候 自动激活。

- 派生自 `Activatable Widget`
- “Support Activation Focus”设置为true。
- 支持回退响应 和 自动激活
  ![alt text](../../assets/images/000CommonUI_image-3.webp)
- 有必要的话，可以重写回退方法，如弹窗暂停窗口，默认的回退方法就是“出栈”  


## 常见问题

### 回退响应不生效

明明配置了 全局的 InputMapping Config, 发现一旦回退过一次，输入配置被卸载，按键不响应了。

原因：CommonUI 可响应页面 取消激活时，也会把输入配置卸载，内部是一个Map结构，如果key相同，也会把全局的输入配置里面的相同的key，也一起卸载。
![alt text](../../assets/images/000CommonUI_image-4.webp){width=70%}

解决方法 : 
- 全局配置不要和CommonUI配置重复，否则会导致输入配置被卸载。 
- 或者 全部页面维护一份通用的输入配置（包含常见操作，前进回退等），保证永远有一个激活的页面，就永远有输入配置。

