---
title: PCG 常用节点记录
comments:  true
---

# PCG 常用节点记录

比较随意的记录。

## Merge 合并
是把多个列表合并成一个列表。
![alt text](../assets/images/PCGNode_image-4.png){width=30%}
```js
//类似数组合并
merge([a,a] ,[b]) = [a,a,b]
```

## Copy Points
![alt text](../assets/images/PCGNode_image-5.png){width=70%}
这是很迷惑的名字，直面意思是复制点，实际上的意思大概是：

> Copy Points 节点是PCG系统中一个重要的点操作节点，其主要功能是将源点（Source Points）复制到目标点（Target Points）上。这个节点最常见的使用场景是：以相对位置的方式，将输入源的点附加到目标点上，其中目标点作为输入源点的轴心点（Pivot）。

详细用法参考B站Up [ZzxxH](https://space.bilibili.com/19131632/) 总结的图：
![alt text](../assets/images/PCGNode_image-6.png){width=70%}

::: details 详细说明
### 点的复制模式

1. **笛卡尔积模式** (bCopyEachSourceOnEveryTarget = true)
```cpp
NumIterations = NumSources * NumTargets;
const int32 SourceIndex = i / NumTargets;
const int32 TargetIndex = i % NumTargets;
```
- 每个源点都会复制到每个目标点上
- 产生 N * M 个输出点

2. **一对一模式** (bCopyEachSourceOnEveryTarget = false)
```cpp
if (NumSources != NumTargets && NumSources != 1 && NumTargets != 1)
{
    // 报错：只支持 N:N, 1:N 和 N:1 操作
}
NumIterations = FMath::Max(NumSources, NumTargets);
```
- 支持 N:N, 1:N 和 N:1 的映射关系
- 产生 max(N, M) 个输出点

### 元数据处理

1. **元数据继承模式**
```cpp
// 五种模式
SourceFirst  // 优先源点元数据，添加目标点独有属性
TargetFirst  // 优先目标点元数据，添加源点独有属性
SourceOnly   // 仅使用源点元数据
TargetOnly   // 仅使用目标点元数据
None         // 不使用元数据
```

2. **属性合并优化**
```cpp
// 使用并行处理来设置属性值
ParallelFor(AttributeCountInCurrentDispatch, [&](int32 WorkerIndex) {
    FPCGMetadataAttributeBase* Attribute = AttributesToSet[AttributeOffset + WorkerIndex];
    Attribute->SetValuesFromValueKeys(Values, false);
});
```
:::


## Attribute Partition 属性分组
这个其实就是 函数式编程里的 `GroupBy`, 根据输入的属性值进行归组
![alt text](../assets/images/04PCGNode_image.png){width=60%}
- Assign Index Partition : 分配一个序号

## Filter Data By Index 和 FilterElementsByIndex
这个节点有个输出，选中的 和 未选中的

Data 是值列表的数组，不是属性集的列表。

如果要获取属性集的列表，可以使用 `FilterElementsByIndex`

![alt text](../assets/images/04PCGNode_image-3.png){width=80%}

都支持选中语法：
- 8   （返回索引为8的值）
- 1:8  （返回索引1到7的值）
- :8   （返回索引0到7的值）
- -1   (返回倒数第一个值）
- -8:   (返回倒数第8到倒数第1)
- 1:5,10:15   （返回索引1到5，索引10到15的值）


## Grammar相关节点
[Grammar相关节点](./01PCG_Mid.md#grammar浅析)

## Attract 吸附节点
给定一个搜索距离，寻找最近或者的的远的点

[案例](./03PCG_Advanced.md#用2个attract-配合创建起点和终点)
![alt text](../assets/images/04PCGNode_image-1.png){width=60%}

支持3个吸引模式：
1. Closest Mode
- 功能：将源点吸引到最近的目标点
- 实现原理：在指定搜索半径内使用点的Position（Transform.Location）计算欧几里得距离
- 使用场景：需要简单的就近吸引时使用

2. MinAttribute Mode
- 功能：吸引到属性值最小的目标点
- 实现原理：在搜索半径内比较目标点的指定属性值，选择最小值
- 支持任何可比较的属性类型
- 使用场景：例如将物体吸引到最低高度的位置

3. MaxAttribute Mode
- 功能：吸引到属性值最大的目标点
- 实现原理：在搜索半径内比较目标点的指定属性值，选择最大值
- 支持任何可比较的属性类型
- 使用场景：例如将物体吸引到密度最大的区域

（目前应该是有bug，选择MinAttribute和MaxAttribute的时候，设置了可以比大小的属性，但还是没有效果。）

所以通常还是用Closest Mode，
使用weight控制位置插值，weight越大，插值越近目标值。

源码：`OutputValue = FMath::Lerp(SourceValue, TargetValue, Alpha);` alpha 就是 weight。

使用weight的时候，这个配置不能没有：
![alt text](../assets/images/04PCGNode_image-2.png){width=60%}

### 参数
- `Distance`: 搜索半径，决定吸引的作用范围
- `Weight`: 吸引强度(0-1)
  - 0: 保持在原始位置（不吸引）
  - 1: 完全吸引到目标位置
- `bRemoveUnattractedPoints`: 是否移除未被吸引的点
- `TargetAttribute`: MinAttribute和MaxAttribute模式下用于比较的属性
- `SourceWeightAttribute`/`TargetWeightAttribute`: 源点和目标点的权重属性



## Difference 差集
[详情](./PCG_Base.md#节点分析)

## Intersection 交集
可以添加多个secondary input
![alt text](../assets/images/PCGNode_image-3.png){width=60%}
 
1. **主输入（Primary Input）**  
   - 主要输入 `Primary Input Pin` 是交集计算的起点，每个输入都会被单独计算。  
   - **每个主输入的数据会与所有其他输入进行交集计算**，并生成新的空间数据。  

2. **次要输入（Secondary Input）**
   - **所有次要输入数据默认会被自动联合（unioned）**，然后才与主输入进行交集计算。  
   - 例如：
     - **输入 A（主输入）**
     - **输入 B1、B2、B3（次要输入）**
     - 在计算时，B1、B2、B3 **会先合并成一个整体 B**，然后 `A ∩ (B1 ∪ B2 ∪ B3)` 进行交集计算。  
   
3. **空数据处理**  
   - **如果某个输入为空（无数据）**，默认情况下，该输入会返回空结果。  
   - 但如果勾选了 `Ignore Empty Secondary Input`，那么空的次要输入将不会影响计算，而是会跳过它们。


## References

- [拆解UE5 PCG 项目《CassiniSample》(一)](https://zhuanlan.zhihu.com/p/25563585263)
 