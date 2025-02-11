---
title: MassEntity 中级篇
comments: true
---

# MassEntity 中级篇

## 常用概念

### Subsystem

#### 1. Subsystem 并行描述

**Subsystem需要告知Mass系统，它的并发特性。**

使用结构体模板TMassExternalSubsystemTraits来“特化” UMyWorldSubsystem：
```cpp
template<>
struct TMassExternalSubsystemTraits<UMyWorldSubsystem> final
{
    enum
    {
        ThreadSafeRead = true,  // 是否支持多线程读取
        ThreadSafeWrite = false, // 是否支持多线程写入
    };
};

```

因为在Mass中，Processors通常是并行执行的（利用多线程）。为了确保数据安全和避免竞争条件，Mass需要知道每个Processor会如何访问Subsystems（子系统）
- 让Mass系统知道该Subsystem可以在哪些线程上访问
- 帮助Mass系统计算处理器(Processor)和查询(Query)的依赖关系

完整例子：
```cpp
// 一个支持并行读取但不支持并行写入的Subsystem
class UMyWorldSubsystem : public UWorldSubsystem 
{
public:
    void Write(int32 InNumber)  // 写操作需要互斥访问
    {
        UE_MT_SCOPED_WRITE_ACCESS(AccessDetector);
        Number = InNumber;
    }

    int32 Read() const  // 读操作可以并行
    {
        UE_MT_SCOPED_READ_ACCESS(AccessDetector);
        return Number;
    }
};

// 为该Subsystem定义traits
template<>
struct TMassExternalSubsystemTraits<UMyWorldSubsystem> final
{
    enum
    {
        ThreadSafeRead = true,   // 允许并行读取
        ThreadSafeWrite = false, // 不允许并行写入
    };
};

```
:::details AccessDetector 宏
源码里提供很多AccessDetector宏，用来描述访问的互斥性。需要慢慢研究：
```cpp
#define UE_MT_DECLARE_RW_ACCESS_DETECTOR(AccessDetector) FRWAccessDetector AccessDetector;
#define UE_MT_DECLARE_RW_RECURSIVE_ACCESS_DETECTOR(AccessDetector) FRWRecursiveAccessDetector AccessDetector;
#define UE_MT_DECLARE_RW_FULLY_RECURSIVE_ACCESS_DETECTOR(AccessDetector) FRWFullyRecursiveAccessDetector AccessDetector;
#define UE_MT_DECLARE_MRSW_RECURSIVE_ACCESS_DETECTOR(AccessDetector) FMRSWRecursiveAccessDetector AccessDetector;

#define UE_MT_SCOPED_READ_ACCESS(AccessDetector) const FBaseScopedAccessDetector& PREPROCESSOR_JOIN(ScopedMTAccessDetector_,__LINE__) = MakeScopedReaderAccessDetector(AccessDetector);
#define UE_MT_SCOPED_WRITE_ACCESS(AccessDetector) const FBaseScopedAccessDetector& PREPROCESSOR_JOIN(ScopedMTAccessDetector_,__LINE__) = MakeScopedWriterAccessDetector(AccessDetector);

#define UE_MT_ACQUIRE_READ_ACCESS(AccessDetector) (AccessDetector).AcquireReadAccess();
#define UE_MT_RELEASE_READ_ACCESS(AccessDetector) (AccessDetector).ReleaseReadAccess();
#define UE_MT_ACQUIRE_WRITE_ACCESS(AccessDetector) (AccessDetector).AcquireWriteAccess();
#define UE_MT_RELEASE_WRITE_ACCESS(AccessDetector) (AccessDetector).ReleaseWriteAccess();

```
:::

:::tip 模板元编程
这种利用Traits来描述能力的写法，并非Mass特有。

UE内部有非常多类似的用法，如：
```cpp
template<>
struct TStructOpsTypeTraits<FHitResult> : public TStructOpsTypeTraitsBase2<FHitResult>
{
	enum
	{
		WithNetSerializer = true,
	};
};

```

另外，奇异递归模板也属于 元编程。详见 [奇异递归模板](../C++/CRTP.md)
:::

#### 2. Processors中使用自定义UWorldSubsystem

从UE 5.1开始，Mass增强了API，允许你在Processors中直接使用UWorldSubsystem。这提供了一种创建封装功能的强大方式，可以用来操作实体（Entities）或其他游戏逻辑。

简单地说，就是Query里允许查询相关的Subsystem，然后在Executor中使用Subsystem， 如修改 Subsystem中的变量。


```cpp
// MyProcessor.cpp
#include "MyProcessor.h"
#include "MyWorldSubsystem.h" // 包含你的Subsystem的头文件

UMyProcessor::UMyProcessor()
{
	bAutoRegisterWithProcessingPhases = true;
	ExecutionFlags = (int32)(EProcessorExecutionFlags::All);
    ProcessingPhase = EMassProcessingPhase::PrePhysics;
}

void UMyProcessor::ConfigureQueries()
{
	// 添加Subsystem要求
	MyEntityQuery.AddSubsystemRequirement<UMyWorldSubsystem>(EMassFragmentAccess::ReadWrite);
	MyEntityQuery.RegisterWithProcessor(*this);
    //ProcessorRequirements也需要添加
    ProcessorRequirements.AddSubsystemRequirement<UMyWorldSubsystem>(EMassFragmentAccess::ReadWrite);
}

void UMyProcessor::Execute(FMassEntityManager& EntityManager, FMassExecutionContext& Context)
{
    // UWorld* World = EntityManager.GetWorld(); //在lambda外获取world
	MyEntityQuery.ForEachEntityChunk(EntityManager, Context, [/*World*/](FMassExecutionContext& Context)
	{
		// 获取你的Subsystem
        // 在lambda里面, 使用Context.GetMutableSubsystemChecked, 无需传入World
		UMyWorldSubsystem* MySubsystem = Context.GetMutableSubsystemChecked<UMyWorldSubsystem>();

		// 使用你的Subsystem
		MySubsystem->Write(42);
		int32 Value = MySubsystem->Read();

		// ... 其他逻辑 ...
	});
}

```

注意：ProcessorRequirements也需要添加Subsystem, 否则会报错





### Fragment FQA

首先，放个Mass Sample的一个案例：
```cpp
// 这是一个成员比较多的Fragment
USTRUCT(BlueprintType)
struct MASSCOMMUNITYSAMPLE_API FInterpLocationFragment : public FMassFragment
{
	GENERATED_BODY()

	UPROPERTY(EditAnywhere)
	FVector TargetLocation = FVector::ZeroVector; // Target location for interpolation

	UPROPERTY(EditAnywhere)
	FVector StartingLocation = FVector::ZeroVector; // Starting location for interpolation

	UPROPERTY(EditAnywhere)
	float Duration = 1.0f; // Duration of the interpolation

	bool bForwardDirection = true; // Flag to indicate the direction of interpolation

	float Time = 0.0f; // Current time of the interpolation
};
// MovementProcessor执行

void UMSInterpMovementProcessor::Execute(FMassEntityManager& EntityManager, FMassExecutionContext& Context)
{
	EntityQuery.ForEachEntityChunk(EntityManager, Context, [&,this](FMassExecutionContext& Context)
	{
		const int32 QueryLength = Context.GetNumEntities();

		// Get mutable views of the required fragments.
		TArrayView<FInterpLocationFragment> InterpLocations = Context.GetMutableFragmentView<FInterpLocationFragment>();
		TArrayView<FTransformFragment> Transforms = Context.GetMutableFragmentView<FTransformFragment>();
		TConstArrayView<FOriginalTransformFragment> OriginalTransforms = Context.GetFragmentView<FOriginalTransformFragment>();

		for (int32 i = 0; i < QueryLength; ++i)
		{
			FInterpLocationFragment& InterpFragment = InterpLocations[i];
			FTransform& Transform = Transforms[i].GetMutableTransform();

			const float DeltaTime = Context.GetDeltaTimeSeconds();
			// Update interpolation time
			InterpFragment.Time = InterpFragment.Time+(DeltaTime/InterpFragment.Duration);
			
			// reverse direction and swap
			if (InterpFragment.Time > 1.0f)
			{
				InterpFragment.bForwardDirection = !InterpFragment.bForwardDirection;
				InterpFragment.Time = FMath::Abs(InterpFragment.Time-InterpFragment.Duration);
				Swap(InterpFragment.StartingLocation,InterpFragment.TargetLocation);
			}

			// Calculate new Location.
			auto NewLocation = FMath::Lerp<FVector>(
				InterpFragment.StartingLocation,
				InterpFragment.TargetLocation,
				InterpFragment.Time) + OriginalTransforms[i].Transform.GetLocation();
			
			// set new location
			Transform.SetLocation(NewLocation);
		}
	});
}
```
#### 如何分析内存布局

以FInterpLocationFragment为例，假如这就是Entity的全部，那么最大的成员类型是 `FVector` 16 bytes, 既总大小一定是16的倍数。这里把最大的成员类型放在前面，已是最优的内存布局。
- 因为后面的 Duration, bForwardDirection, Time 加起来都不够FVector的大，他们的排列顺序已经无关紧要。
- bForwardDirection 占用了一个字节，但后续的Time是4字节对齐，所以要填充3比特padding。
```sh
+----------------------------------------------+
| Offset 0 - 15    | TargetLocation (FVector)  | // 16 bytes
+----------------------------------------------+
| Offset 16 - 31   | StartingLocation (FVector)| // 16 bytes
+----------------------------------------------+
| Offset 32 - 35   | Duration (float)          | // 4 bytes
+----------------------------------------------+
| Offset 36        | bForwardDirection (bool)  | // 1 byte
+----------------------------------------------+
| Offset 37 - 39   | Padding (alignment)       | // 3 bytes
+----------------------------------------------+
| Offset 40 - 43   | Time (float)              | // 4 bytes
+----------------------------------------------+
| Offset 44 - 47   | Padding (for 16-byte alignment) | // 4 bytes
+----------------------------------------------+
Total size: ~48 bytes

```

#### 合理的Fragment刀法

上面这个例子与我印象中ECS倡导的SOA（Structure of Arrays）设计理念有所不同，它的结构更接近AOS（Array of Structures）布局。

```cpp
// AOS风格（案例方案）
struct FInterpLocationFragment {
    FVector A, B;  // 连续内存
    float FTime;
};

// SOA风格（理论最优）
struct FLocationA { TArray<FVector> Data; };
struct FLocationB { TArray<FVector> Data; };
struct FTime { TArray<float> Data; };
```

但仔细思考，Mass框架底层已经是SOA实现（Chunk内存布局），**因此Fragment内部的AOS设计不会破坏SOA优势**，反而是正确的选择

##### 热数据聚合
当多个字段在同一个Processor中连续访问且存在高频交互时，优先选择聚合，也就是都放在同一个`Archetype` 里面。

问题是：每个变量都切成一个`Fragment`再组合成原型，还是 把 “热数据” 都放进同一个`Fragment`里面再组合成原型？

我感觉实践上，后者会更常见。因为不用创建那么多的Fragment，实际上也不违反 组合优于继承。Archetype 之间最终还要继续排列组合。

##### 冷数据分离

假如有个FHealthFragment, 那么在游戏逻辑里Health的数据更新必然（大概率）和Location的数据更新不在同一个频道（频率）上。

两者之间，互为冷数据，是原型拆分策略的最好选择。

例子：
```
// 移动相关原型 (高频更新)
FMassArchetypeHandle ArchetypeMovement = EntityManager.CreateArchetype({
    FTransformFragment::StaticStruct(), 
    FVelocityFragment::StaticStruct(),
    FObjectBindingTag::StaticStruct() // 绑定到逻辑对象
});

// 状态相关原型 (低频更新)
FMassArchetypeHandle ArchetypeStatus = EntityManager.CreateArchetype({
    FHealthFragment::StaticStruct(),
    FStatusEffectFragment::StaticStruct(),
    FObjectBindingTag::StaticStruct() 
});
```

##### 如何组合

- Fragment之间的“组合”, 是Mass提供的一种更细的刀法，方便更细粒度的控制，更好地复用数据和函数（参考官方Flower和Crop的例子，两个不同的原型（构成不同），但大量函数如AddItemToGrid和各自System的Execute 都能统一使用）。
- Archetype之间的“组合”, 则是更注重业务逻辑。比如上面的 Health 和 Location, 他都可以是某个对象（Actor）的“部件”。

##### Cache Miss
回到最开始的代码例子:

如果FInterpLocationFragment就是原型的全部， 而在 `ForEachEntityChunk` 中全部该切片全部变量都被“使用”,也就都是“热数据”。那么这个设计就是非常合理的。

理论上,FInterpLocationFragment也必须是该原型的全部构成，如果还有其他Fragment，由于 `Chunk`是根据`Archetype`分类的，那么在上面这个`ForEachEntityChunk`中，必然引入了没用上的变量，导致cache miss。

##### 原型的深意

（原型这个词，非常容易带偏思维，容易误解成“类”，既对事物的抽象，实际上它是对数据运行逻辑的抽象）

综上，原型的真正意思是：驱动特定逻辑所需的最小数据集合。


### Processor

Mass Entity Processor是Mass框架中处理实体的核心组件。它通过组合多个用户定义的查询（queries）来计算和处理实体。

(也就是说，一个Processor可以包含多个Query)

#### 基本特性

1. **自动注册机制**
   - 所有继承自UMassProcessor的类都会自动注册到Mass系统
   - 默认添加到`EMassProcessingPhase::PrePhsysics`处理阶段

2. **处理阶段**
   处理器可以配置在不同的处理阶段执行，对应不同的`ETickingGroup`：

   | 处理阶段 | 对应TickingGroup | 说明 |
   |----------|-----------------|------|
   | PrePhysics | TG_PrePhysics | 物理模拟开始前执行 |
   | StartPhysics | TG_StartPhysics | 开始物理模拟的特殊阶段 |
   | DuringPhysics | TG_DuringPhysics | 与物理模拟并行执行 |
   | EndPhysics | TG_EndPhysics | 结束物理模拟的特殊阶段 |
   | PostPhysics | TG_PostPhysics | 刚体和布料模拟后执行 |
   | FrameEnd | TG_LastDemotable | 帧末尾的兜底阶段 |

#### 配置选项

在处理器的构造函数中，可以配置以下内容：

1. **注册控制**
   ```cpp
   bAutoRegisterWithProcessingPhases = true;  // 是否自动注册到处理阶段
   ```

2. **处理阶段设置**
   ```cpp
   ProcessingPhase = EMassProcessingPhase::PrePhysics;  // 设置处理阶段
   ```

3. **执行顺序控制**
   ```cpp
   // 使用内置的移动处理器组
   ExecutionOrder.ExecuteInGroup = UE::Mass::ProcessorGroupNames::Movement;
   // 设置在指定处理器之后执行
   ExecutionOrder.ExecuteAfter.Add(TEXT("MSMovementProcessor"));
   ```

4. **执行环境控制**
   ```cpp
   // 设置在哪些环境下执行（客户端/服务器/单机）
   ExecutionFlags = (int32)(EProcessorExecutionFlags::Client | EProcessorExecutionFlags::Standalone);
   ```

5. **线程控制**
   ```cpp
   bRequiresGameThreadExecution = true;  // 是否需要在游戏主线程执行
   ```

####  重要说明

1. **依赖图**
   - Mass系统会根据处理器的执行规则创建依赖图
   - 确保处理器按正确的顺序执行
   - 例如：移动处理器需要在其他处理器之前执行

2. **多线程支持**
   - 默认情况下所有处理器都支持多线程
   - 可以通过设置`bRequiresGameThreadExecution = true`强制在主线程执行
   - 需要注意线程安全问题

3. **扩展性**
   - Mass提供了多个基础处理器类型供继承和扩展
   - 例如：可视化处理器和LOD处理器

### 创建Entity 

在Mass中创建Entity有两种主要方式：原始方式（Raw）和延迟方式（Deferred）。通常推荐使用延迟方式，因为它更符合Mass的设计理念。

#### 1. 原始方式（Raw）

这种方式直接操作EntityManager，主要用于演示或特殊场景：

1. **创建Archetype**
   ```cpp
   // 创建包含指定Fragment的Archetype
   FMassArchetype Archetype = EntityManager->CreateArchetype({
       FTransformFragment::StaticStruct(),
       FMassVelocityFragment::StaticStruct()
   });
   ```

2. **创建Entity**
   ```cpp
   // 使用Archetype创建Entity
   FMassEntityHandle NewEntity = EntityManager->CreateEntity(Archetype);
   ```

3. **修改Entity**
   ```cpp
   // 添加Tag
   EntityManager->AddTagToEntity(NewEntity, FMSGravityTag::StaticStruct());
   
   // 添加Fragment
   EntityManager->AddFragmentToEntity(NewEntity, FSampleColorFragment::StaticStruct());
   
   // 修改Fragment数据
   EntityManager->GetFragmentDataChecked<FMassVelocityFragment>(NewEntity).Value = FMath::VRand() * 100.0f;
   EntityManager->GetFragmentDataChecked<FSampleColorFragment>(NewEntity).Color = FColor::Blue;
   ```

#### 2. 延迟方式（Deferred Command）

这是推荐的创建和修改Entity的方式，它通过命令队列来处理操作：



1. **预留Entity**
   ```cpp
   // 预留Entity句柄，防止被其他处理器占用
   FMassEntityHandle ReservedEntity = EntityManager->ReserveEntity();
   ```

2. **创建Entity的不同方式**
   ```cpp
   // 方式1：基础创建
   EntityManager->Defer().PushCommand<FMassCommandBuildEntity>(
       ReservedEntity,
       MyColorFragment
   );

   // 方式2：创建并添加多个Fragment
   EntityManager->Defer().PushCommand<FMassCommandAddFragmentInstances>(
       ReservedEntity,
       MyColorFragment,
       MyTransformFragment
   );

   // 方式3：创建带共享Fragment的Entity
   FMSExampleSharedFragment SharedFragment;
   SharedFragment.SomeKindaOfData = FMath::Rand() * 10000.0f;
   
   // 获取或创建共享Fragment
   const FConstSharedStruct& SharedFragmentStruct = 
       EntityManager->GetOrCreateConstSharedFragment(SharedFragment);
   
   FMassArchetypeSharedFragmentValues SharedValues;
   SharedValues.AddConstSharedFragment(SharedFragmentStruct);

   EntityManager->Defer().PushCommand<FMassCommandBuildEntityWithSharedFragments>(
       ReservedEntity, 
       MoveTemp(SharedValues), 
       MyTransformFragment, 
       MyColorFragment
   );
   ```
:::tip FMassCommandBuildEntityWithSharedFragments 命令
`FMassCommandBuildEntityWithSharedFragments` 是Mass系统中的Command之一

**使用场景**
   - 当需要创建带有共享Fragment的Entity时使用
   - 支持同时添加多个普通Fragment和共享Fragment
```cpp
template<typename TSharedFragmentValues, typename... TOthers>
struct FMassCommandBuildEntityWithSharedFragments : public FMassBatchedCommand
```
:::

3. **刷新命令**
   ```cpp
   // 需要立即执行时，可以手动刷新命令（通常不需要）
   if (!EntityManager->IsProcessing())
   {
       EntityManager->FlushCommands();
   }
   ```

:::tip 调试技巧
在编辑器中使用 `mass.PrintEntityFragments 1` 命令可以查看Entity的Fragment信息。
:::

## References
- [Mass社区Sample](https://github.com/Megafunk/MassSample/)