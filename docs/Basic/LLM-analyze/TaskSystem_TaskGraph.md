# UE5 任务系统 TaskSystem VS TaskGraph

## TaskGraph系统

### TaskGraph简介

TaskGraph是虚幻引擎的底层任务系统，提供了强大的任务依赖管理和执行控制能力。它是引擎内部许多系统的基础，如渲染、物理模拟等。

### TaskGraph基本用法

#### 1. 任务类型

TaskGraph支持几种主要的任务类型：
```cpp
// 1. 普通任务
FGraphTask::CreateTask().ConstructAndDispatchWhenReady([]() {
    // 任务代码
});

// 2. 带名称的任务
FGraphTask::CreateTask(nullptr, ENamedThreads::AnyThread)
    .ConstructAndDispatchWhenReady([]() {
        // 任务代码
    }, TStatId());

// 3. 带依赖的任务
FGraphEventRef Event = FGraphTask::CreateTask(Prerequisites, ENamedThreads::AnyThread)
    .ConstructAndDispatchWhenReady([]() {
        // 任务代码
    }, TStatId());
```

#### 2. 线程类型

TaskGraph提供了详细的线程控制：
```cpp
enum ENamedThreads::Type
{
    AnyThread,           // 任意工作线程
    GameThread,          // 游戏线程
    RenderThread,        // 渲染线程
    RHIThread,          // RHI线程
    // ... 其他专用线程
};
```

#### 3. 任务依赖

```cpp
// 创建前置任务
FGraphEventRef Prerequisite = FGraphTask::CreateTask().ConstructAndDispatchWhenReady([]() {
    // 前置任务代码
});

// 创建依赖任务数组
FGraphEventArray Prerequisites;
Prerequisites.Add(Prerequisite);

// 创建依赖于前置任务的新任务
FGraphEventRef DependentTask = FGraphTask::CreateTask(&Prerequisites, ENamedThreads::AnyThread)
    .ConstructAndDispatchWhenReady([]() {
        // 依赖任务代码
    }, TStatId());
```

### TaskGraph高级功能

#### 1. 任务优先级

```cpp
// 高优先级任务
FGraphTask::CreateTask(nullptr, ENamedThreads::AnyHiPriThreadHiPriTask)
    .ConstructAndDispatchWhenReady([]() {
        // 高优先级任务代码
    });

// 普通优先级任务
FGraphTask::CreateTask(nullptr, ENamedThreads::AnyThread)
    .ConstructAndDispatchWhenReady([]() {
        // 普通优先级任务代码
    });
```

#### 2. 等待任务完成

```cpp
// 等待单个任务
FTaskGraphInterface::Get().WaitUntilTaskCompletes(TaskEvent);

// 等待多个任务
FTaskGraphInterface::Get().WaitUntilTasksComplete(TaskEvents);
```

#### 3. 条件执行

```cpp
// 条件任务创建
if (bShouldCreateTask)
{
    FGraphTask::CreateTask().ConstructAndDispatchWhenReady([]() {
        // 条件任务代码
    });
}
```

### TaskGraph使用场景

TaskGraph特别适合以下场景：

1. 引擎核心系统
   - 渲染管线
   - 物理模拟
   - 动画系统

2. 复杂的任务依赖关系
   - 多阶段处理
   - 复杂的并行计算

3. 特定线程要求
   - 需要在特定线程执行的任务
   - 跨线程同步操作

## TaskSystem系统

### TaskSystem简介

UE5引入了一个新的任务系统(TaskSystem)，它是对底层TaskGraph系统的高层封装。这个新系统提供了更简单、更直观的API，使得异步任务的管理变得更加容易。

### 任务优先级

任务系统支持两种优先级系统：

1. 基本优先级(`ETaskPriority`)：
```cpp
enum class ETaskPriority 
{
    Normal,  // 普通优先级
    High,    // 高优先级
}
```

2. 扩展优先级(`EExtendedTaskPriority`)：
```cpp
enum class EExtendedTaskPriority
{
    None,      // 无特殊优先级
    Inline,    // 内联执行
    TaskEvent, // 任务事件优先级
    // 游戏线程相关
    GameThreadNormalPri,
    GameThreadHiPri,
    // 渲染线程相关
    RenderThreadNormalPri,
    RenderThreadHiPri,
    // RHI线程相关
    RHIThreadNormalPri,
    RHIThreadHiPri,
}
```

### 任务状态

任务可能处于以下几种状态：
- 等待执行
- 正在执行
- 已完成
- 已取消

### TaskSystem基本用法

#### 1. 创建简单任务

```cpp
// 最简单的任务创建方式
auto Task = UE::Tasks::Launch(
    UE_SOURCE_LOCATION,  // 用于调试的位置信息
    []{ 
        UE_LOG(LogTemp, Log, TEXT("Hello from Task!")); 
    }
);

// 等待任务完成
Task.Wait();
```

#### 2. 带返回值的任务

```cpp
// 创建返回整数的任务
auto Task = UE::Tasks::Launch(
    UE_SOURCE_LOCATION,
    []() -> int { 
        // 执行一些计算
        return 42; 
    }
);

// 获取任务结果（会等待任务完成）
int result = Task.GetResult();
```

#### 3. 设置任务优先级

```cpp
auto Task = UE::Tasks::Launch(
    UE_SOURCE_LOCATION,
    []{ /* 任务代码 */ },
    ETaskPriority::High,  // 设置高优先级
    EExtendedTaskPriority::None  // 无特殊优先级
);
```

#### 4. 任务依赖关系

```cpp
// 创建第一个任务
auto Task1 = UE::Tasks::Launch(
    UE_SOURCE_LOCATION,
    []{ /* 任务1代码 */ }
);

// 创建依赖于Task1的任务
auto Task2 = UE::Tasks::Launch(
    UE_SOURCE_LOCATION,
    []{ /* 任务2代码 */ },
    UE::Tasks::Prerequisites(Task1)  // Task2会等待Task1完成后才开始执行
);
```

#### 5. 更多细节 

虽然任何可调用对象也可以使用，但 lambda 函数通常用作任务体。

```cpp
void Func() {}
        Launch(UE_SOURCE_LOCATION, &Func);

        struct FFunctor
        {
            void operator()() {}
        };
        Launch(UE_SOURCE_LOCATION, FFunctor{});
```

FTask是实际任务的句柄，类似于智能指针。它使用引用计数来管理其生命周期。启动任务会启动其生命周期并分配所需的资源。要释放持有的引用，您可以使用以下命令“重置”任务句柄：

```cpp
FTask Task = Launch(UE_SOURCE_LOCATION, []{});
Task = {}; // release the reference
```



### TaskSystem高级功能

#### 1. 任务事件

任务事件用于同步多个任务：

```cpp
// 创建任务事件
FTaskEvent Event(TEXT("MyEvent"));

// 添加事件的前置条件（可选）
Event.AddPrerequisites(SomePrerequisites);

// 在某个时刻触发事件
Event.Trigger();

// 使用事件作为任务的前置条件
auto Task = UE::Tasks::Launch(
    UE_SOURCE_LOCATION,
    []{ /* 任务代码 */ },
    UE::Tasks::Prerequisites(Event)
);
```

#### 2. 任务取消

```cpp
// 创建取消令牌
FCancellationToken Token;

// 创建可取消的任务
auto Task = UE::Tasks::Launch(
    UE_SOURCE_LOCATION,
    [&Token]{ 
        // 定期检查是否被取消
        if (Token.IsCanceled()) {
            return;
        }
        // ... 继续执行
    }
);

// 在需要时取消任务
Token.Cancel();
```

#### 3. 等待多个任务

```cpp
// 创建任务数组
TArray<FTask> Tasks;

// 添加多个任务
Tasks.Add(UE::Tasks::Launch(/*...*/));
Tasks.Add(UE::Tasks::Launch(/*...*/));

// 等待所有任务完成
UE::Tasks::Wait(Tasks);

// 等待任意一个任务完成
int32 CompletedTaskIndex = UE::Tasks::WaitAny(Tasks);
```

### TaskSystem使用场景

TaskSystem特别适合以下场景：

1. 一般的游戏逻辑开发
2. 需要快速实现的功能
3. 简单的异步操作
4. 需要良好错误处理
5. 团队开发合作项目

### 引擎内部使用示例

#### 1. 表格合并任务 (TableMergeTask)

这是一个来自引擎Trace系统的实际例子，展示了TaskSystem和TaskGraph如何协同工作：

\Engine\Source\Developer\TraceServices\Private\Model\TableMergeTask.cpp  

```cpp
// 在TraceServices命名空间中
void FTableMergeService::MergeTables(
    const TSharedPtr<IUntypedTable>& TableA, 
    const TSharedPtr<IUntypedTable>& TableB, 
    TableDiffCallback InCallback)
{
    // 使用TaskSystem启动表格合并任务
    UE::Tasks::Launch(
        UE_SOURCE_LOCATION, 
        FTableMergeTask(TableA, TableB, InCallback)
    );
}
```

这个例子展示了几个重要特点：

1. **TaskSystem的简单性**：使用`Launch`函数一行代码就能启动复杂的异步任务

2. **自定义任务对象**：`FTableMergeTask`是一个函数对象，包含：
   - 输入数据（TableA和TableB）
   - 回调函数（用于处理结果）
   - 实现了operator()来执行实际的合并操作

3. **TaskSystem与TaskGraph的集成**：任务完成后，使用TaskGraph将结果转发到游戏线程：
```cpp
// 使用TaskGraph在GameThread上执行回调
FFunctionGraphTask::CreateAndDispatchWhenReady(
    [Callback = this->Callback, Params]()
    {
        Callback(Params);
    },
    TStatId(),
    nullptr,
    ENamedThreads::GameThread
);
```

这个示例很好地展示了：
- 如何使用TaskSystem处理耗时的后台操作
- 如何在需要特定线程上下文时（如UI更新）切换到TaskGraph
- TaskSystem和TaskGraph如何在实际场景中互补使用：
  * TaskSystem处理高层的任务抽象和管理
  * TaskGraph处理底层的线程特定操作

## 系统对比

### API设计
- **TaskGraph**: 
  - 更底层的API
  - 更细粒度的控制
  - 需要更多的样板代码
  - 直接与引擎线程系统集成

- **TaskSystem**: 
  - 更高层的抽象
  - 更简洁的API
  - 更少的样板代码
  - 自动处理大多数常见场景

### 功能特性
- **TaskGraph**:
  - 完全控制任务调度
  - 细粒度的线程控制
  - 直接的性能控制
  - 适合底层系统开发

- **TaskSystem**:
  - 内置任务取消支持
  - 简化的依赖管理
  - 类型安全的任务返回值
  - 更好的错误处理

### 性能特点
- **TaskGraph**:
  - 更少的抽象开销
  - 更直接的内存控制
  - 可以实现更优的性能
  - 需要更多的专业知识

- **TaskSystem**:
  - 略微的抽象开销
  - 自动的内存管理
  - 足够好的性能
  - 更容易避免常见错误

## 选择建议

### 使用TaskGraph的场景
1. 开发引擎级别的功能
2. 需要精确控制任务调度
3. 对性能要求极高的场景
4. 需要深度集成到引擎系统
5. 复杂的线程交互场景

### 使用TaskSystem的场景
1. 一般的游戏逻辑开发
2. 需要快速实现的功能
3. 简单的异步操作
4. 需要良好错误处理
5. 团队开发合作项目

### 最佳实践建议
1. 默认选择TaskSystem
2. 在遇到性能瓶颈时考虑TaskGraph
3. 在需要特殊线程控制时使用TaskGraph
4. 可以在同一项目中混合使用两种系统
5. 根据团队经验水平选择合适的系统
