---
title: PCG 常用节点记录
comments:  true
---

# PCG 常用节点记录

比较随意的记录。

## Merge 合并
![alt text](../assets/images/PCGNode_image-4.png)
```js
//类似数组合并
merge([a,a] ,[b]) = [a,a,b]
```

## Copy Points
![alt text](../assets/images/PCGNode_image-5.png)
这是很迷惑的名字，直面意思是复制点，实际上的意思大概是：

> Copy Points 节点是PCG系统中一个重要的点操作节点，其主要功能是将源点（Source Points）复制到目标点（Target Points）上。这个节点最常见的使用场景是：以相对位置的方式，将输入源的点附加到目标点上，其中目标点作为输入源点的轴心点（Pivot）。

详细用法参考B站Up [ZzxxH](https://space.bilibili.com/19131632/) 总结的图：
![alt text](../assets/images/PCGNode_image-6.png)

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




## Grammar相关节点
[Grammar相关节点](./01PCG_Mid.md#grammar浅析)


## Difference 差集
[详情](./PCG_Base.md#节点分析)

## Intersection 交集
可以添加多个secondary input
![alt text](../assets/images/PCGNode_image-3.png)
 
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
 