---
title: CommonUI Debug 
comments:  true
---

## 按键绑定调试技巧记录

common UI 经常遇到 绑定好了按键后，手柄无效，键盘有效，或者都无效，各自诡异的问题。

### 控制台
- ShowDebug EnhancedInput 这个命令可以实时看到key触发的到底是哪个action，以及用灰色表示被覆盖的action
![alt text](../../assets/images/01CUIHowDebug_image-1.png)


### 断点位置

如果实在不行，看不出为何action绑定失败，断点是最快的解决方法。

如果要调试的源码里面包含lambda，rider调试异常，无法正确获得信息。经常会显示：illegal name block 或者错误的值，或者根本无法读取。

解决方案：
- 修改源码，把lambda用函数代替，然后用git 保存临时提交备用。（推荐）
- 编译方案使用 Debug 而不是 DebugGame 这种方案的好处是不用修改源码，代价是帧率特别低。（不推荐）
  ![alt text](../../assets/images/01CUIHowDebug_image-2.png)


### 调试案例

- 绑定按键按下没反应 ：
  调试位置：UIActionRouterTypes.cpp line:705
 `bool FActionRouterBindingCollection::ProcessNormalInput(ECommonInputMode ActiveInputMode, FKey Key, EInputEvent InputEvent) const`

  最需要调试的是`TryConsumeInput`方法，它是一个lambda，决定是否触发action的回调，各种不调用的疑难杂症都能在这里找到。
  
- 手柄扳机键没反应
  调试后发现原因，录制按键时只会把扳机键录制为 RightTriggerAxis
  ![alt text](../../assets/images/01CUIHowDebug_image.png)
  而游戏过程种，得到的值却是RightTrigger，导致无法触发action。
  
  根本原因是，对于Enhanced Input来说，就不应该存在 axis （轴映射）这种东西，它只有action。但编辑器在开启 enhanced input 时，还是录制到了 legacy的axis 键位，其实是引擎的BUG 



