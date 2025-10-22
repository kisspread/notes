---
title: PCG 高级篇
comments: true
---

# PCG 高级篇 运用案例

## 蓝图自定义节点

蓝图节点可以用于处理PCG Graph中不方便操作的数据。

主要分为3个步骤：获取数据，处理数据，输出数据。

节点的输入输出的**数据包装类型都是`TaggedData`**，带标签的数据，数据可能有多种类型，可能是 点类型，参数类型，设置类型等，所以需要判断到底是哪种类型。

默认输入输出的Pin 分别是 `In` 和 `Out`，但可以定义更多的Pin，所以需要用Pin的Label来获取特定的数据。

Pin、Label、Tags 在中文里都容易翻译为**标签**，所以很容易造成混淆。

Pin的和Tags 不是同个东西，Pin是**键**，Data是**值**，而Tags则是可选的**标签**。

Pin 和 Data 也不是 一一对应的关系，因为节点里，一个pin可以连入多份数据，所以各种`GetXX`,`GetInputsByXX`的接口返回的都是`TaggedData`的数组。

```cpp
// 创建TaggedData
FPCGTaggedData TaggedData;
TaggedData.Data = Data;
TaggedData.Tags = Tags;
TaggedData.Pin = Pin;
```

这些`TaggedData` 最终会被打包放进去`FPCGDataCollection`里面， 交给蓝图节点处理。



### 获取数据

实现`execute`函数，获取输入数据
![alt text](../assets/images/03PCG_Advanced_image.png)

如果只有一个输入Pin,直接调用

输入的`Input` 是一个`FPCGDataCollection`类型，提供了一系列的接口来获取输入数据，这些方法本质都是过滤出想要的`TaggedData`：

:::details `FPCGDataCollection`接口
```cpp
/** Returns all spatial data in the collection */
	UE_DEPRECATED(5.6, "Use GetAllSpatialInputs for only spatial inputs, or use GetAllInputs.")
	UE_API TArray<FPCGTaggedData> GetInputs() const;

	/** Returns all spatial data in the collection. */
	UE_API TArray<FPCGTaggedData> GetAllSpatialInputs() const;

	/** Returns all inputs in the collection. */
	const TArray<FPCGTaggedData>& GetAllInputs() const { return TaggedData; }

	/** Returns all data on a given pin. */
	UE_API TArray<FPCGTaggedData> GetInputsByPin(const FName& InPinLabel) const;
	/** Returns all spatial data on a given pin */
	UE_API TArray<FPCGTaggedData> GetSpatialInputsByPin(const FName& InPinLabel) const;

 // 具体实现

TArray<FPCGTaggedData> FPCGDataCollection::GetTaggedInputs(const FString& InTag) const
{
	return GetTaggedTypedInputs<UPCGSpatialData>(InTag);
}

TArray<FPCGTaggedData> FPCGDataCollection::GetAllSettings() const
{
	return TaggedData.FilterByPredicate([](const FPCGTaggedData& Data) {
		return Cast<UPCGSettings>(Data.Data) != nullptr;
		});
}

TArray<FPCGTaggedData> FPCGDataCollection::GetAllParams() const
{
	return TaggedData.FilterByPredicate([](const FPCGTaggedData& Data) {
		return Cast<UPCGParamData>(Data.Data) != nullptr;
	});
}

TArray<FPCGTaggedData> FPCGDataCollection::GetParamsByPin(const FName& InPinLabel) const
{
	return TaggedData.FilterByPredicate([&InPinLabel](const FPCGTaggedData& Data) {
		return Data.Pin == InPinLabel && Cast<UPCGParamData>(Data.Data);
		});
}

TArray<FPCGTaggedData> FPCGDataCollection::GetTaggedParams(const FString& InTag) const
{
	return TaggedData.FilterByPredicate([&InTag](const FPCGTaggedData& Data) {
		return Data.Tags.Contains(InTag) && Cast<UPCGParamData>(Data.Data) != nullptr;
		});
}
```
:::

骚操作：把输入的数据合并到一起（没什么意义，方便理解）：
![alt text](../assets/images/03PCG_Advanced_image-2.png)
于是结果里面既有Point Data，又有Attribute Data
![alt text](../assets/images/03PCG_Advanced_image-1.png){width=40%}

### 处理数据

如果是简单的运算，在`Execute`函数中，直接计算然后调用`MakePCGDataCollection`输出即可。
需要注意，最好不能把输入的数据直接输出，而是要重新创建TaggedData一份， 否则会破坏上游节点的输出数据。

#### 给数据增加属性`Metadata`
构造 `MutableMetadata`, 持有Metadata, 调用 `AddEntry` 并持有 Entry的Key
![alt text](../assets/images/03PCG_Advanced_image-3.png)

填充原本的输入数据的属性，再用上一步的EntryKey 添加新的属性
![alt text](../assets/images/03PCG_Advanced_image-4.png)
这个图展示创建具体的属性类型：
![alt text](../assets/images/03PCG_Advanced_image-5.png)


#### 循环处理点数据

普通数据使用蓝图的`For Each`节点问题不大，但点数据通常非常多，PCG提供了特殊的并发循环节点，它们被设计为在后台线程中并行执行 (multi-threaded / 并行化)，以极高的效率处理大量数据。
![alt text](../assets/images/03PCG_Advanced_image-6.png){width=50%}

一个最简单的例子，给全部点设置一个统一的颜色，并全部保留：
![alt text](../assets/images/03PCG_Advanced_image-7.png)

通常只需要用到`PointLoopBody`，即可；其他都是补充用法。

| 函数 (Function) | 核心思想 | 输入 -\> 输出  | 类比 |
| :--- | :--- | :--- | :--- |
| **`PointLoopBody`** | 变换 / 过滤 | 1 : 1 (或 1 : 0) | `map` + `filter` |
| **`VariableLoopBody`** | 扩展 / 生成 | 1 : N | `flatMap` / `SelectMany` |
| **`NestedLoopBody`** | 组合 / 关系 | (M x N) : 1 (或 0) | 双层 `for` 循环 |
| **`IterationLoopBody`** | 创造 / 迭代 | 0 : N | 单个 `for (i=0; i<N; i++)` |

（1:1是一份对一份的意思，如果存在filter，依旧当作一份。）
（1：N,每棵树生成随机个果实）

需要注意的是，这些循环都是并发的，无法进行类似`Reduce`的累积、求平均操作，这些依旧要使用蓝图的`For Each`节点。

### 输出数据

输出到多个Pin：
![alt text](../assets/images/03PCG_Advanced_image-8.png)

最终输出的Collection:
![alt text](../assets/images/03PCG_Advanced_image-9.png)





---
---
## PCG 案例

记录一些PCG的细节使用

### 闭合样条线判断内角外角
闭合的直线样条线，形成的凸包有时需要判断拐角使用内角还是外角，因为拐角模型也是存在“手性”的， 内外需要区别判断或者使用不同模型。这个问题可以转换为，样条线的下一个点是左拐还是右拐。左右问题，可以使用`Cross Product`来判断。
![alt text](../assets/images/03PCG_Advanced_image-24.webp)


### PCG Spawn Mesh 时假装指定Pivot点
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
  ![alt text](../assets/images/03PCG_Advanced_image-14.webp)

- 由于偏移量是个本地向量，而PCG点的位置是世界位置，还不能直接减去PivotOffset，先使用`Transform.TransformDirection`来换算 
  ![alt text](../assets/images/03PCG_Advanced_image-15.webp)

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
![alt text](../assets/images/03PCG_Advanced_image-16.webp){width=80%}
最终，这个调整向量是本地坐标系下的，需要使用Transform.TransformDirection转换到世界坐标系，然后`+`到PCG点的Position。


### PCG自适应铺地板
![alt text](../assets/images/03PCG_Advanced_image-8.webp)
地板宽度通常是固定，所以对应输入的样条线区域，还需进行调整，有以下步骤：

#### 获取全部楼层(poly line 类型), 传入子图，在子图执行全部逻辑
![alt text](../assets/images/03PCG_Advanced_image.webp){width=60%}
![alt text](../assets/images/03PCG_Advanced_image-2.webp){width=60%}

#### 使用 `Filter data by index` 筛选出需要地板的楼层
![alt text](../assets/images/03PCG_Advanced_image-1.webp){width=60%}
![alt text](../assets/images/03PCG_Advanced_image-3.webp){width=60%}

#### 把点映射到世界零点，方便后续计算：
![alt text](../assets/images/03PCG_Advanced_image-4.webp){width=60%}
1. 创建一个原点
2. 每个点减去原点，就映射回世界零点。
3. 对每个点 使用 `abs` 取绝对值，全部射到第一象限。


#### 根据长度，计算地板数量
![alt text](../assets/images/03PCG_Advanced_image-5.webp){width=60%}

1. 假如地板宽度为500，那么这里的分段可以取500的倍数，这里写1000就是每段至少2个地板
2. 除出来后，如果2.3个地板，必须向上取整变成3，才能符合“容纳”的要求。
3. 还原回原点。
4. 最后一个add 把结果写入Postion，最终更新了整个样条线的大小，让其符合地板宽度的要求。


#### 输出地板数据
![alt text](../assets/images/03PCG_Advanced_image-6.webp){width=60%}

1. 创建新的，大小已经合适的Spline ，选择在内部模式且无边际必须打勾
2. 采样距离设置为500（会报错但不影响使用，不必理会，应该是bug）


## PCG 自动样条线Mesh
![alt text](../assets/images/03PCG_Advanced_image-7.webp)
主要都是 Attract节点的用法， Attract的主要功能的搜索和关联

#### 用2个Attract 配合，创建起点和终点
![alt text](../assets/images/03PCG_Advanced_image-9.webp){width=75%}
1. 让球面点，搜索半径1200范围内，可以关联的点，模式为 最近点
2. 能搜索到的“关联点”的球面点，会被attract节点输出，对于关联点来说，形成了1对多的关系
3. 把第一个 Attract节点的权重设置为0，输出的就是源点的位置（图里就是球面点）
4. 把第二个 Attract节点的权重设置为1，输出的就是关联点的位置（图里关联点是天花板或者地面的灯柱）
5. 第二个 Attract节点的的搜索模式，改成`from index`模式 来获取即可，不用搜索，加快速度

#### 计算指向终点的向量
![alt text](../assets/images/03PCG_Advanced_image-10.webp){width=75%}
1. 这里的离开方向没用上，可以忽略

#### 分别计算终点和起点对应的俯仰角度
![alt text](../assets/images/03PCG_Advanced_image-12.webp){width=45%}
![alt text](../assets/images/03PCG_Advanced_image-11.webp){width=75%}

1. 如果某些关联点存在放大，就用reduce节点来获取放大值最大的值，作为基准。越大的点，偏转角度越大，体现“电线”越重。
2. 因此，这里的Angle 是一个比例值，在和和定义的最大角度80相乘，让每条线都有自己的偏转角度

#### 连接起点和终点，生成样条线Mesh
![alt text](../assets/images/03PCG_Advanced_image-13.webp){width=75%}
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


## PCG 填坑记录

### 结构体崩溃： 如果涉及自定义结构体的修改，最好打开一张空白的地图，没有加载任何东西的时候去修改结构体才是安全的，且要分步骤进行。 但最稳妥的办法还是先进行版本控制，比如commit一次临时的版本快照，等改好了再amend 一次即可。否则，可能面临编辑器崩溃，已有的默认值全部丢失。这是非常严重的事情，并且我估计这种bug是无法修复的。
   **具体步骤**
   - 进行一次版本控制，commit一次临时的版本快照
   - 打开一张空白的地图，没有加载任何东西的时候去修改结构体，避免引用缓存对象未释放，否则一改就崩
   - 新增变量一定要放在结构体的最后，不能放在中间，否则内存布局会改变，导致已有的默认值全部丢失
     > 原理：
     >  - 假设旧结构体是 MyStruct { float A; bool B; }。它在内存和文件中的布局可能是 [4字节的A] [1字节的B]。
     >  - 如果在中间插入一个int C，新结构体变成 MyStruct { float A; int C; bool B; }，布局变为 [4字节的A] [4字节的C] [1字节的B]。
     >  - 当UE尝试用新的布局去读取旧的数据 [4字节的A] [1字节的B] 时，它会把原本属于 B 的1字节数据（以及后面的垃圾数据）错误地解析成 C 的值，而 B 的值则会从更后面的内存去读取，导致数据彻底错乱。这就是默认值全部丢失的根本原因。
     >  - 追加到末尾: 如果将 int C 加到末尾，新结构体为 MyStruct { float A; bool B; int C; }。当UE读取旧数据时，它能正确地把 [4字节的A] 赋给 A，[1字节的B] 赋给 B。由于旧数据里没有 C 的信息，UE会为 C 赋予其类型的默认值（对int来说就是0）。这个过程是**向后兼容（backward-compatible）**的。
   - 新增好了，把涉及到的蓝图全部手动编译保存。可选：使用`UCompileAllBlueprintsCommandlet`工具编译全部蓝图（比较耗时）
   - 往上上面步骤后，检查没有任何错误或者数据丢失，有丢失就关闭UE，git 重置到commit的版本。没有问题就可以进行结构体的顺序调整了,此时内存布局大小不变，可以安全的进行顺序调整，不会触发崩溃。再次重新编译保存即可。
     > 原理：此时，结构体的总大小（sizeof）已经稳定。在这个基础上再去调整成员顺序，UE的**属性重定向（Property Redirection）**机制有更高的成功率来正确匹配新旧顺序的变量，因为它是在内存大小已经匹配的情况下进行“内部挪动”。


   - 最后功能完成，amend 说明改动即可。
   
   

### 不生成，缓存错误，可以试试按住 Ctrl + 再点击 重新生成。
![alt text](../assets/images/03PCG_Advanced_image-18.webp)

### 尽量使用PCG Stamp, 而不是PCG 原始 Actor，否则可能存在潜在的崩溃问题。
![alt text](../assets/images/03PCG_Advanced_image-23.webp)




### PCG (编辑器时)回调内存泄露

官方的PCG回调，比如OnGenerated, 通过编辑器详情页面创建一个Event，是有问题的。会导致内存泄露，每次编译一次，都会创建一个新的Event，导致回调次数递增。

一种解决方案是：手动绑定Event，而不是通过编辑器详情页面创建。

### PCG 样条线采样器的一些说明
![alt text](../assets/images/blueprints_image.webp){width=80%}

NextDirectionDelta： 是用当前点，来记录它的下一个点的方向变化增量，对比的轴是UpVector, 增量是用本地坐标系来对比（），增量被归一化为-1到1

-1表示 ForwardVector绕UpVector向右旋转90度 （顺时针）

0表示 ForwardVector 和下一个点方向一致

1表示 ForwardVector绕UpVector向左旋转90度 （逆时针）

（没看源码，NextDirectionDelta 极有可能是通过计算 下一个点的前进向量 (NextForwardVector) 与 当前点的左侧向量 之间的点乘得到的）

最后一个点没有下一个点，所以NextDirectionDelta为0


## Runtime PCG 

大多数情况下，只需要在编辑器模式下使用PCG来构建数据，运行时使用这些构建好的数据即可。但需要和游戏环境互动的，就需要Runtime PCG了。

比如走到哪就生成到哪，需要根据玩家位置来生成数据，或者根据场景内其他动态数据来生成数据。

但运行时PCG其实BUG很多，毕竟感觉使用的人很少，很多问题要使用后才能发现，选择运行时PCG需要谨慎。

### 一些运行时PCG遇到的问题记录

#### 1. 部分LevelStream 关卡重新加载，需要刷新PCG缓存，否则生成的数据会出错
![alt text](../assets/images/03PCG_Advanced_image-17.webp)

#### 2. 运行时PCG和编辑器PCG 存在不同逻辑，如运行时int32类型其实是按float类型处理的，导致精度问题。
![alt text](../assets/images/03PCG_Advanced_image-19.webp)

编辑器时，显示的数据，全是int32类型：
![alt text](../assets/images/03PCG_Advanced_image-20.webp)

运行时，显示的数据，全是float类型，导致运行时生成结果和编辑器存在严重偏差：
 ![alt text](../assets/images/03PCG_Advanced_image-21.webp)

最终附加一个round节点，可以解决这个问题：
![alt text](../assets/images/03PCG_Advanced_image-22.webp)


## PCG 5.6 之前创建 spline 数据丢失的问题
5.5 bug 重现如下：
1. 创建多组数据（多张表），查看Symbol，Size 数据 添加正常
![alt text](../assets/images/03PCG_Advanced_image-25.webp)

2. 从点里面创建spline，刚刚添加的自定义数据全部丢失
![alt text](../assets/images/03PCG_Advanced_image-26.webp)

5.6 正常：
自定义数据没有丢失，也无需复制
![alt text](../assets/images/03PCG_Advanced_image-27.webp)

但下一步 Sline line to Segments，自定义数据会丢失, 使用 copy all domain 可以解决
![alt text](../assets/images/03PCG_Advanced_image-28.webp)