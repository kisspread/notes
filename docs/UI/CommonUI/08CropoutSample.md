---
title: CommonUI In Cropout Demo
comments:  true
---

Cropout是虚幻官方开源的一个类似的RTS的游戏，和Lyra 一样使用了CommonUI，而Cropout是相对简单的纯蓝图项目。

官网:[https://www.unrealengine.com/en-US/blog/cropout-casual-rts-game-sample-project](https://www.unrealengine.com/en-US/blog/cropout-casual-rts-game-sample-project)
 


## Layer

Cropout 和 Lyra 最大的区别，没有将 Game Stack 和 Menu Stack 放在同一个 Root Widget 里，它们分别在互相独立关卡里面。

- GameLayer 通过BP_GM 创建和激活
![alt text](../../assets/images/08CropoutSample_image.webp)

- MenuLayer 通过 BP_MainMenuGM 创建激活
![alt text](../../assets/images/08CropoutSample_image-1.webp)

个人认为，主关卡应该像Lara那样，同时支持两个Stack，不过lyra也是通过蓝图来创建Stack，考虑到stack的结构是几乎不会去改变的，我觉得应该放在C++ 层去实现，分配好Game 和 Menu两个 stack，提供给蓝图使用，减少蓝图使用的复杂度。

- 我的实现：
  ![alt text](../../assets/images/08CropoutSample_image-2.webp)
  
  更多请参考[这里](./00How%20to%20setup%20CommonUI%20in%20UE5.4.2.md)


## Common Input

Cropout 的commonUI没有使用5.4提供的Enhanced Input支持，落后一个版本。

- Project->Game->Common Input Settings:
  ![alt text](../../assets/images/08CropoutSample_image-5.webp)

- 需要DataTable来配置输入数据, 这里显示手柄的确认按钮是A
  ![alt text](../../assets/images/08CropoutSample_image-3.webp)

- 新的不需要dataTable,只需简单配置UI对应的Action：
  ![alt text](../../assets/images/08CropoutSample_image-4.webp)

虽然配置相对麻烦写，但更稳定，没有启用 Enhanced Input Support 后 手柄A键 被吃掉的问题。

### 让它支持EnhanceInput

虽然不需要DataTable，但需要配置一个DataAsset：
- 新建 DataAsset->Common Mapping Context MetaData
  ![alt text](../../assets/images/08CropoutSample_image-6.webp)

- 配置全局默认，和单独指定。[更多](./01EnhancedInput.md#inputaction)
  ![alt text](../../assets/images/08CropoutSample_image-7.webp)

- 根据表格的定义的action，新建enhance input action 
  ![alt text](../../assets/images/08CropoutSample_image-9.webp)
  类似：
  ![alt text](../../assets/images/08CropoutSample_image-8.webp)

 - 找到父布局，把Mapping 设置好

 - 最后，找到对应的BaseButton，Input-> 加入对应的Action即可
 
### Bug
- Cropout 是基于5.2-5.3的，依旧使用 SetInputMode 的方式来切换输入方式。可能会有鼠标控制错乱的bug，详细见[xist的说明](https://www.youtube.com/watch?v=A9dp3cmCFtQ)
![alt text](../../assets/images/08CropoutSample_image-10.webp)

- Cropout到处都是 setinput mode 的切换管理， 特别繁琐
  ![alt text](../../assets/images/08CropoutSample_image-11.webp)

### 用新feature解决

- 搜索全部 SetInputMode,删掉或者不执行

- 设置 对应的 Desired InputConfig

- Game Layer: 设置 支持可激活 ![alt text](../../assets/images/08CropoutSample_image-13.webp)
  
- 效果：InputConfig会自动激活了
  <video src="../../assets/images/08CropoutSample_image-12.mp4" controls autoplay loop> 
    Your browser does not support the video tag.
  </video>
## FaceButton Bottom
由于原项目使用的是 SetInputMode 来设置 输入模式，所以
它的 Xbox手柄 A键 没有被 模拟成 左键点击。

改用新 feature后，成功复现 FaceButton Bottom 被 CommonUI占用的问题。目前是用C++ [重写父类判断的方法来解决](./07CustomAnalogCursor.md)