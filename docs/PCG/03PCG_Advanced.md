---
title: PCG 高级篇
comments: true
---

# PCG 高级篇 运用案例

记录以下相关应用

## PCG Spawn Mesh 时假装指定Pivot点
PCG Spawn Mesh的时，Mesh的的pivot点是会和PCG的Position重合。但Mesh的Pivot多种多样，有的在中心，有的在边界，有的在角落，总之乱七八糟的，重新修改Mesh又费时费力，所以应该想办法在直接在PCG中调整。

那么，只要知道Mesh的Bound 和 它当前的Pivot，只要能根据目标位置，计算出一个偏移量，就能假装调整了Mesh 的Pivot

#### 前提节点`BoundsFromMesh`
该节点可以获取到Mesh的包围盒信息，包括最小值、最大值、中心点等。有了它就能计算出Pivot点的偏移量。
 
#### Pivot 原理
默认情况下，Mesh 最原始的 Pivot点就是（0，0，0）,此时 pivot点就是包围盒的中心。假设这就是我们需要的理想状态（Pivot在BoundsBox中心）。
$$
LocalCenter = \vec{Pivot} = (0,0,0) =  (BoundsMax + BoundsMin) /2 
$$

乱七八糟的Pivot点，是通过偏移量来实现的：
$$
NewLocalCenter = Offset + Pivot(0,0,0) = PivotOffset
$$ 

所以，PCG的LocalCenter属性如果非0，就说明是被动过手脚的Pivot。

知道了原理，就可以通过减去PivotOffset来让Pivot点回到Bounds的中心，回到理想状态。

最后，因为这个偏移量是个本地向量，而PCG点的Position都是世界坐标，且都有自己的Transform属性，所以得对`PivotOffset`进行`Transform.TransformDirection`来应用方向转换。（PivotOffset是一个相对量，只需要方向变换，不需要位置变换）

#### 任意位置的Pivot居中调整
- 使用`$LocalCenter`记录Mesh的几何中心，如果是0代表没有任何偏移，如果是其他值，说明是乱七八糟的Pivot点
  ![alt text](../assets/images/03PCG_Advanced_image-14.png)

- 由于偏移量是个本地向量，而PCG点的位置是世界位置，还不能直接减去PivotOffset，先使用`Transform.TransformDirection`来换算 
  ![alt text](../assets/images/03PCG_Advanced_image-15.png)

#### 任意位置的Pivot，调整到X方向最边界，Y方向居中

默认情况下，Mesh的Pivot点在包围盒中心，即LocalCenter = (0,0,0)。

如果我们想要将Pivot调整到X方向的最边界（可以是最左或最右），Y方向居中，Z方向保持原样，需要计算从当前Pivot位置到目标位置的偏移量。
既：
$$
目标向量 = ((Xmin - Xmax)/2, 0, 0) = 已有偏移量(LocalCenter) + 调整向量
$$

1. 包围盒中心到X最左边界的向量是：
   ```
   目标向量 = 左边界向量 = (Xmin - (Xmax+Xmin)/2, 0, 0) = ((Xmin - Xmax)/2, 0, 0) = -$Extents.X
   ```
2. 如果Pivot已有偏移(LocalCenter)，我们需要计算额外的调整向量：
   ```
   
   调整向量 = 目标向量 - LocalCenter
   ```
   其中，目标向量可以是左边界向量或右边界向量，取决于我们想要将Pivot调整到哪一侧。
![alt text](../assets/images/03PCG_Advanced_image-16.png){width=80%}
最终，这个调整向量是本地坐标系下的，需要使用Transform.TransformDirection转换到世界坐标系，然后`+`到PCG点的Position。


## PCG自适应铺地板
![alt text](../assets/images/03PCG_Advanced_image-8.png)
地板宽度通常是固定，所以对应输入的样条线区域，还需进行调整，有以下步骤：

#### 获取全部楼层(poly line 类型), 传入子图，在子图执行全部逻辑
![alt text](../assets/images/03PCG_Advanced_image.png){width=60%}
![alt text](../assets/images/03PCG_Advanced_image-2.png){width=60%}

#### 使用 `Filter data by index` 筛选出需要地板的楼层
![alt text](../assets/images/03PCG_Advanced_image-1.png){width=60%}
![alt text](../assets/images/03PCG_Advanced_image-3.png){width=60%}

#### 把点映射到世界零点，方便后续计算：
![alt text](../assets/images/03PCG_Advanced_image-4.png){width=60%}
1. 创建一个原点
2. 每个点减去原点，就映射回世界零点。
3. 对每个点 使用 `abs` 取绝对值，全部射到第一象限。


#### 根据长度，计算地板数量
![alt text](../assets/images/03PCG_Advanced_image-5.png){width=60%}

1. 假如地板宽度为500，那么这里的分段可以取500的倍数，这里写1000就是每段至少2个地板
2. 除出来后，如果2.3个地板，必须向上取整变成3，才能符合“容纳”的要求。
3. 还原回原点。
4. 最后一个add 把结果写入Postion，最终更新了整个样条线的大小，让其符合地板宽度的要求。


#### 输出地板数据
![alt text](../assets/images/03PCG_Advanced_image-6.png){width=60%}

1. 创建新的，大小已经合适的Spline ，选择在内部模式且无边际必须打勾
2. 采样距离设置为500（会报错但不影响使用，不必理会，应该是bug）


## PCG 自动样条线Mesh
![alt text](../assets/images/03PCG_Advanced_image-7.png)
主要都是 Attract节点的用法， Attract的主要功能的搜索和关联

#### 用2个Attract 配合，创建起点和终点
![alt text](../assets/images/03PCG_Advanced_image-9.png){width=75%}
1. 让球面点，搜索半径1200范围内，可以关联的点，模式为 最近点
2. 能搜索到的“关联点”的球面点，会被attract节点输出，对于关联点来说，形成了1对多的关系
3. 把第一个 Attract节点的权重设置为0，输出的就是源点的位置（图里就是球面点）
4. 把第二个 Attract节点的权重设置为1，输出的就是关联点的位置（图里关联点是天花板或者地面的灯柱）
5. 第二个 Attract节点的的搜索模式，改成`from index`模式 来获取即可，不用搜索，加快速度

#### 计算指向终点的向量
![alt text](../assets/images/03PCG_Advanced_image-10.png){width=75%}
1. 这里的离开方向没用上，可以忽略

#### 分别计算终点和起点对应的俯仰角度
![alt text](../assets/images/03PCG_Advanced_image-12.png){width=45%}
![alt text](../assets/images/03PCG_Advanced_image-11.png){width=75%}

1. 如果某些关联点存在放大，就用reduce节点来获取放大值最大的值，作为基准。越大的点，偏转角度越大，体现“电线”越重。
2. 因此，这里的Angle 是一个比例值，在和和定义的最大角度80相乘，让每条线都有自己的偏转角度

#### 连接起点和终点，生成样条线Mesh
![alt text](../assets/images/03PCG_Advanced_image-13.png){width=75%}
1. 先根据关联点归组，关联点是1对多的关系，归组后，每一列输出的就是拥有共同关联点的的球面点。
2. 由于之前合并过起点和终点，所以此时的数据，index相同的已经两两成对。（ 到了这里会发现其实第一步不需要也可以）
3. 因此，再次根据index归组，归组后面跟着另一个归组，这是一个类似flatmap的操作，把每一列的产生两两成对都输出到主序列。
5. 最后使用`Spawn Spline Mesh`节点生成样条线Mesh

:::details flatmap
```kotlin
val list = listOf("123", "45")
println(list.flatMap { it.toList() }) // [1, 2, 3, 4, 5] 
```
:::
