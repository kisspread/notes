---
title: MassEntity 中级篇
comments: true
---

# MassEntity 中级篇

## 常用概念

### Subsystem

#### 1. Subsystem 并行描述

**Subsystem需要告知Mass系统，它的并发特性。**

源码里使用模板描述自身能力的例子，TMassExternalSubsystemTraits“特化”：
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



## References
- [Mass社区Sample](https://github.com/Megafunk/MassSample/)