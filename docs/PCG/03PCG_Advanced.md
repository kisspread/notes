---
title: PCG 高级篇
comments: true
---

# PCG 高级篇 运用案例

记录以下相关应用

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
