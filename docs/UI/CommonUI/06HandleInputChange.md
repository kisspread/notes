---
title: CommonUI Gamepad Mouse Missing
comments:  true
---

最近发现，FUIInputConfig设置了不隐藏鼠标，但是一用手柄，鼠标立即消失。

---

## 寻找输入切换的入口
通过 OnInputMethodChangedNative 添加监听
![alt text](../../assets/images/06HandleInputChange_image.webp)

## 切换的处理
在UCommonUIActionRouterBase::ApplyUIInputConfig(const FUIInputConfig& NewConfig, bool bForceRefresh)
阅读这里的代码，尝试理解为什么gamepad模式下 鼠标会消失
![alt text](../../assets/images/06HandleInputChange_image-1.webp)
这里是根据UIInputConfing来切换输入模式，但是调试发现，配置是正确的，和这里无关，GamePad 模式鼠标就是不显示，只好另找高明。

## 柳暗花明
搜索几百次代码，终于让我找到你了！
![alt text](../../assets/images/06HandleInputChange_image-3.webp)
这个RefreshCursorVisibility会在CommonAnalogCursor::Tick里调用。3种情况会显示鼠标：

- bIsAnalogMovementEnabled 这个值没有提供修改接口，不是它
- ActionRouter.ShouldAlwaysShowCursor() 符合总是显示
- ActiveInputMethod == ECommonInputType::MouseAndKeyboard 是键鼠模式



![alt text](../../assets/images/06HandleInputChange_image-2.webp)

而 符合总是显示也有两个条件：

- bAlwaysShowCursor 可以通过控制台修改，就它了。
  ![alt text](../../assets/images/06HandleInputChange_image-4.webp)  
- 同时符合模拟触摸的两个条件。  

## 还是不显示？
如果还是不显示，bEnableGamepadPlatformCursor也要设置为true
```
bool bEnableGamepadPlatformCursor = false;
static const FAutoConsoleVariableRef CVarInputEnableGamepadPlatformCursor
(
	TEXT("CommonInput.EnableGamepadPlatformCursor"),
	bEnableGamepadPlatformCursor,
	TEXT("Should the cursor be allowed to be used during gamepad input")
);

```

## 还有大坑？

-  调试发现，如果点击face button bottom, 会触发点击事件，鼠标会回到屏幕中间！
   ![alt text](../../assets/images/06HandleInputChange_image-7.webp) 

- 这里没有可用的开关变量，点击后一定会被`TargetGeometry.GetAbsolutePositionAtCoordinates(FVector2D(0.5f, 0.5f));` 把鼠标设置回屏幕中间。
而bLinkCursorToGamepadFocus目前是个没用上的虚假占位变量。
   ![alt text](../../assets/images/06HandleInputChange_image-8.webp)
- 然后，还发现要一个好玩的内部测试代码，同时按下这4个按键一秒，会触发隐藏开关，鼠标不会回中间了，但手柄左边变成移动鼠标了。
目前来说，只能修改源码实现。

  ![alt text](../../assets/images/06HandleInputChange_image-6.webp)

## Usage
如果不按face button bottom进行点击事件，功能还是正常的。
tab ` to open console:
``` sh
CommonUI.AlwaysShowCursor true
```

Or blueprint



![alt text](../../assets/images/06HandleInputChange_image-5.webp)


## 后续测试
发现这种强行显示鼠标的方式，还是很多bug, 比如需要等带一段时间，鼠标才会显示出来，而且鼠标移动过程中会突然加速，暂时没空研究。目前先放弃。
