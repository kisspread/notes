---
title: 草稿
comments:  true
---

### 编辑器地图里的Actor，数组无法add元素

开发编辑器功能时，在编辑器地图里的Actor，如果属性改变，Actor会重写调用构造函数。这会导致私有变量的值被重置，比如进行数组的add操作，会发现元素根本无法添加，因为一直在刷新，重置。

正确的做法是：
把变量暴露出来，公开，公开的变量不会被重置，这样就能正常add了。



### PCG 回调内存泄露

官方的PCG回调，比如OnGenerated, 通过编辑器详情页面创建一个Event，是有问题的。会导致内存泄露，每次编译一次，都会创建一个新的Event，导致回调次数递增。

一种解决方案是：手动绑定Event，而不是通过编辑器详情页面创建。

### PCG 样条线采样器的一些说明
![alt text](../../assets/images/blueprints_image.png){width=80%}

NextDirectionDelta： 是用当前点，来记录它的下一个点的方向变化增量，对比的轴是UpVector, 增量是用本地坐标系来对比（），增量被归一化为-1到1

-1表示 ForwardVector绕UpVector向右旋转90度 （顺时针）

0表示 ForwardVector 和下一个点方向一致

1表示 ForwardVector绕UpVector向左旋转90度 （逆时针）

（没看源码，NextDirectionDelta 极有可能是通过计算 下一个点的前进向量 (NextForwardVector) 与 当前点的左侧向量 之间的点乘得到的）

最后一个点没有下一个点，所以NextDirectionDelta为0

