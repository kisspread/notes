# UE5 任务系统 TaskSystem 

### TaskSystem 简介

UE5 引入了一个新的任务系统(TaskSystem)，它是对底层 TaskGraph 系统的高层封装。这个新系统提供了更简单、更直观的 API，使得异步任务的管理变得更加容易。TaskSystem 的目标是简化常见的异步编程模式，并提供更细粒度的任务控制。

### 任务优先级

任务系统支持两种优先级系统，允许开发者根据任务的重要性调整其执行顺序：

1. **基本优先级 (`ETaskPriority`)：** 提供两种通用的优先级。
   ```cpp
   enum class ETaskPriority
   {
       Normal,  // 普通优先级 (默认)
       High,    // 高优先级
   };
   ```

2. **扩展优先级 (`EExtendedTaskPriority`)：** 提供更精细的控制，可以将任务绑定到特定的游戏引擎线程。
   ```cpp
   enum class EExtendedTaskPriority
   {
       None,      // 无特殊优先级 (默认)
       Inline,    // 内联执行：在当前线程同步执行。注意在某些上下文中，例如在被 Pipe 管理的任务中，内联任务依然遵循 FIFO 顺序。
       TaskEvent, // 任务事件优先级：可能与任务事件的触发相关联。
       // 游戏线程相关
       GameThreadNormalPri, // 绑定到游戏线程，普通优先级
       GameThreadHiPri,   // 绑定到游戏线程，高优先级
       // 渲染线程相关
       RenderThreadNormalPri, // 绑定到渲染线程，普通优先级
       RenderThreadHiPri,   // 绑定到渲染线程，高优先级
       // RHI线程相关
       RHIThreadNormalPri, // 绑定到 RHI 线程，普通优先级
       RHIThreadHiPri,   // 绑定到 RHI 线程，高优先级
   };
   ```
   使用扩展优先级可以将特定任务绑定到如游戏线程、渲染线程或 RHI 线程执行，这对于需要访问特定线程上下文的数据或资源的任务非常有用。

### 任务状态

任务在其生命周期中可能处于以下几种状态：

* **等待执行 (Pending):** 任务已创建但尚未开始执行。
* **正在执行 (Running):** 任务正在被线程池中的一个工作线程执行。
* **已完成 (Completed):** 任务已成功执行完毕。
* **已取消 (Canceled):** 任务在执行完成前被取消。

### TaskSystem 基本用法

TaskSystem 提供了简洁的 API 来创建和管理异步任务。以下是一些核心用法示例：

#### 1. 创建并启动简单任务

最简单的任务创建方式，使用 lambda 表达式定义任务体：

```cpp
// 启动一个默认优先级的简单任务
auto Task = UE::Tasks::Launch(
    UE_SOURCE_LOCATION,  // 用于调试的位置信息
    []{
        UE_LOG(LogTemp, Log, TEXT("Hello from Task!"));
    }
);

// 等待任务完成（阻塞当前线程直到任务执行结束）
Task.Wait();
```
你也可以不持有 `FTask` 句柄来启动并“忘记”任务，但这会失去对任务状态的控制。在多线程环境下，任务依然会被调度执行。

#### 2. 创建带返回值的任务

可以使用 `TTask<T>` 来处理带有返回值的任务。任务体需要返回指定类型的值。

```cpp
// 创建一个返回整数的任务
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
`GetResult()` 方法会阻塞当前线程直到任务完成并返回结果。

#### 3. 设置任务优先级

可以在启动任务时指定其优先级。

```cpp
auto Task = UE::Tasks::Launch(
    UE_SOURCE_LOCATION,
    []{ /* 任务代码 */ },
    ETaskPriority::High,  // 设置基本优先级为高
    EExtendedTaskPriority::None  // 设置扩展优先级为无特殊
);

// 使用 FTaskPriorityCVar 从 CVar 读取优先级
UE::Tasks::FTaskPriorityCVar PriorityCVar{ TEXT("MyTaskPriority"), TEXT("任务优先级控制"), ETaskPriority::Normal, EExtendedTaskPriority::None };
auto CVarTask = UE::Tasks::Launch(
    UE_SOURCE_LOCATION,
    []{ /* 任务代码 */ },
    PriorityCVar.GetTaskPriority(),
    PriorityCVar.GetExtendedTaskPriority()
);
```

#### 4. 创建有依赖关系的任務

可以使用 `UE::Tasks::Prerequisites` 来指定任务的前置条件。依赖任务完成后，后续任务才会被调度执行。

```cpp
// 创建第一个任务
auto Task1 = UE::Tasks::Launch(
    UE_SOURCE_LOCATION,
    []{ /* 任务 1 代码 */ }
);

// 创建依赖于 Task1 的任务
auto Task2 = UE::Tasks::Launch(
    UE_SOURCE_LOCATION,
    []{ /* 任务 2 代码 */ },
    UE::Tasks::Prerequisites(Task1)  // Task2 会等待 Task1 完成后才开始执行
);

// 可以指定多个前置任务
auto Task3 = UE::Tasks::Launch(
    UE_SOURCE_LOCATION,
    []{ /* 任务 3 代码 */ },
    UE::Tasks::Prerequisites(Task1, Task2)
);

// 可以使用容器来管理前置条件
TArray<UE::Tasks::FTask> PrerequisiteTasks = { Task1, Task2 };
auto Task4 = UE::Tasks::Launch(
    UE_SOURCE_LOCATION,
    []{ /* 任务 4 代码 */ },
    Prerequisites(PrerequisiteTasks)
);

// 可以使用 FTaskEvent 作为前置条件
UE::Tasks::FTaskEvent Event{ UE_SOURCE_LOCATION };
auto Task5 = UE::Tasks::Launch(
    UE_SOURCE_LOCATION,
    []{ /* 任务 5 代码 */ },
    Prerequisites(Event)
);
Event.Trigger(); // 触发事件以允许 Task5 执行
```

#### 5. 使用不同的可调用对象

虽然 lambda 函数是最常见的选择，但 TaskSystem 也支持其他可调用对象，如函数指针和仿函数。

```cpp
void Func() { UE_LOG(LogTemp, Log, TEXT("Function executed!")); }
UE::Tasks::Launch(UE_SOURCE_LOCATION, &Func);

struct FFunctor
{
    void operator()() { UE_LOG(LogTemp, Log, TEXT("Functor executed!")); }
};
UE::Tasks::Launch(UE_SOURCE_LOCATION, FFunctor{});
```

#### 6. 管理 `FTask` 的生命周期

`FTask` 类似于智能指针，使用引用计数来管理其生命周期。启动任务会启动其生命周期并分配所需的资源。要释放持有的引用，可以“重置”任务句柄。这对于在任务完成后清理资源非常重要，尤其是在 `FTask` 实例作为成员变量持有的时候。

```cpp
UE::Tasks::FTask Task = UE::Tasks::Launch(UE_SOURCE_LOCATION, []{});
Task.Wait(); // 确保任务完成
Task = {}; // 释放引用，允许系统回收资源
```
当 `FTask` 实例被销毁或赋值时，其内部的引用计数会递减。当引用计数降为零时，相关的资源会被释放。

#### 7. 嵌套任务

一个任务在其执行过程中可以启动新的任务。可以使用 `UE::Tasks::AddNested` 将内部任务标记为当前任务的子任务。父任务会等待所有通过 `AddNested` 添加的子任务完成后才算完成。

```cpp
UE::Tasks::Launch(UE_SOURCE_LOCATION,
    []
    {
        UE::Tasks::FTask NestedTask = UE::Tasks::Launch(UE_SOURCE_LOCATION, [] {});
        UE::Tasks::AddNested(NestedTask);
        NestedTask.Wait();
    }
).Wait();
```
父任务可以通过 `IsAwaitable()` 检查自身是否可以安全地被等待，通常在父任务内部等待其嵌套任务完成是有风险的，可能导致死锁。

### FPipe 高级用法

`FPipe` 是 TaskSystem 中的一个重要组件，用于确保任务按顺序执行，并提供了一种管理相互依赖任务的机制。同一个 `FPipe` 中启动的任务会按照先进先出 (FIFO) 的顺序执行，但与其他 `FPipe` 或使用 `Launch` 直接启动的任务并行执行。

#### 1. 基本的 Pipe 使用

```cpp
// 创建一个命名的 pipe
UE::Tasks::FPipe Pipe{ UE_SOURCE_LOCATION };

// 在 pipe 中启动两个任务，它们会按顺序执行
UE::Tasks::FTask Task1 = Pipe.Launch(UE_SOURCE_LOCATION, [] {});
UE::Tasks::FTask Task2 = Pipe.Launch(UE_SOURCE_LOCATION, [] {});
Task2.Wait(); // 等待 Task2 完成，这也意味着 Task1 已经完成
```

#### 2. 验证执行顺序

```cpp
UE::Tasks::FPipe Pipe{ UE_SOURCE_LOCATION };
bool bTask1Done = false;

// 第一个任务会延迟完成
UE::Tasks::FTask Task1 = Pipe.Launch(UE_SOURCE_LOCATION,
    [&bTask1Done]
    {
        FPlatformProcess::Sleep(0.1f);
        bTask1Done = true;
    }
);

// 第二个任务会验证第一个任务已完成
Pipe.Launch(UE_SOURCE_LOCATION, [&bTask1Done] {
    check(bTask1Done);
}).Wait();
```

#### 3. Pipe 阻塞示例

可以通过 `FTaskEvent` 来阻塞 Pipe 中的任务执行。

```cpp
UE::Tasks::FPipe Pipe{ UE_SOURCE_LOCATION };
std::atomic<bool> bBlocked;
UE::Tasks::FTaskEvent Event{ UE_SOURCE_LOCATION };

// 启动一个会阻塞的任务
UE::Tasks::FTask Task = Pipe.Launch(UE_SOURCE_LOCATION,
    [&bBlocked, &Event]
    {
        bBlocked = true;
        Event.Wait(); // 任务在这里阻塞
    }
);

// 等待任务进入阻塞状态
while (!bBlocked)
{
}

// 此时任务已阻塞
ensure(!Task.Wait(FTimespan::FromMilliseconds(100)));

Event.Trigger(); // 解除阻塞
Task.Wait();
```

#### 4. 内联任务的 FIFO 顺序

即使是内联执行的任务，在同一个 `FPipe` 中也会保持 FIFO 的执行顺序。

```cpp
UE::Tasks::FPipe Pipe{ UE_SOURCE_LOCATION };
UE::Tasks::FTaskEvent Block{ UE_SOURCE_LOCATION };
bool bFirstDone = false;
bool bSecondDone = false;

// 启动两个内联任务，验证它们的执行顺序
UE::Tasks::FTask Task1 = Pipe.Launch(UE_SOURCE_LOCATION,
    [&] {
        check(!bSecondDone);
        bFirstDone = true;
    },
    Prerequisites(Block),
    ETaskPriority::Normal,
    EExtendedTaskPriority::Inline
);

UE::Tasks::FTask Task2 = Pipe.Launch(UE_SOURCE_LOCATION,
    [&] {
        check(bFirstDone);
        bSecondDone = true;
    },
    Prerequisites(Block),
    ETaskPriority::Normal,
    EExtendedTaskPriority::Inline
);

Block.Trigger();
UE::Tasks::Wait(TArray{ Task1, Task2 });
```

#### 5. 线程安全的异步接口 (Actor 模式)

`FPipe` 可以用来构建线程安全的异步接口，类似于简化版的 Actor 模型。所有通过同一个 `FPipe` 启动的任务都会串行执行，从而避免竞态条件。

```cpp
class FAsyncClass
{
public:
    // 返回带结果的异步操作
    UE::Tasks::TTask<bool> DoSomething()
    {
        return Pipe.Launch(TEXT("DoSomething()"), [this] { return DoSomethingImpl(); });
    }

    // 返回无结果的异步操作
    UE::Tasks::FTask DoSomethingElse()
    {
        return Pipe.Launch(TEXT("DoSomethingElse()"), [this] { DoSomethingElseImpl(); });
    }

private:
    bool DoSomethingImpl() { return false; }
    void DoSomethingElseImpl() {}

    UE::Tasks::FPipe Pipe{ UE_SOURCE_LOCATION };  // 使用 Pipe 确保线程安全
};

// 在多线程中安全地调用 FAsyncClass 的方法
FAsyncClass AsyncInstance;
bool bRes = AsyncInstance.DoSomething().GetResult();
AsyncInstance.DoSomethingElse().Wait();
```

#### 6. 等待 Pipe 变为空

可以使用 `WaitUntilEmpty()` 等待 Pipe 中的所有任务完成。

```cpp
UE::Tasks::FPipe Pipe{ UE_SOURCE_LOCATION };
Pipe.Launch(UE_SOURCE_LOCATION, [] {});
Pipe.Launch(UE_SOURCE_LOCATION, [] {});
Pipe.WaitUntilEmpty();
```

### TaskSystem 高级功能

除了基本的启动和依赖管理外，TaskSystem 还提供了一些高级功能来处理更复杂的异步场景。

#### 1. 任务事件 (FTaskEvent)

`FTaskEvent` 用于同步多个任务的执行。一个任务可以等待一个事件被触发后继续执行。

```cpp
// 创建任务事件
UE::Tasks::FTaskEvent Event(TEXT("MyEvent"));

// 添加事件的前置条件（可选）
// Event.AddPrerequisites(SomePrerequisites);

// 在某个时刻触发事件
Event.Trigger();

// 使用事件作为任务的前置条件
auto Task = UE::Tasks::Launch(
    UE_SOURCE_LOCATION,
    []{ /* 任务代码 */ },
    UE::Tasks::Prerequisites(Event)
);

// 任务可以等待事件被触发
UE::Tasks::FTask WaitingTask = UE::Tasks::Launch(UE_SOURCE_LOCATION,
    [&Event] {
        Event.Wait(); // 任务会在这里阻塞直到事件被触发
        UE_LOG(LogTemp, Log, TEXT("Event triggered, task continuing."));
    }
);
```

#### 2. 任务取消 (CancellationToken)

可以使用 `FCancellationToken` 来取消正在执行或等待执行的任务。

```cpp
// 创建取消令牌
UE::Tasks::FCancellationToken Token;

// 创建可取消的任务
auto Task = UE::Tasks::Launch(
    UE_SOURCE_LOCATION,
    [&Token]{
        // 定期检查是否被取消
        for (int i = 0; i < 10; ++i) {
            if (Token.IsCanceled()) {
                UE_LOG(LogTemp, Warning, TEXT("Task cancelled."));
                return;
            }
            FPlatformProcess::Sleep(0.1f);
            UE_LOG(LogTemp, Log, TEXT("Task running..."));
        }
    }
);

// 在需要时取消任务
Token.Cancel();

// 你可以创建一个已完成的任务
auto CompletedTask = UE::Tasks::MakeCompletedTask<int>(42);
check(CompletedTask.GetResult() == 42);
```

#### 3. 等待多个任务

TaskSystem 提供了等待一个或多个任务完成的便捷方法。

```cpp
// 创建任务数组
TArray<UE::Tasks::FTask> Tasks;

// 添加多个任务
Tasks.Add(UE::Tasks::Launch(UE_SOURCE_LOCATION, []{}));
Tasks.Add(UE::Tasks::Launch(UE_SOURCE_LOCATION, []{}));

// 等待所有任务完成
UE::Tasks::Wait(Tasks);

// 等待任意一个任务完成，返回已完成任务的索引
int32 CompletedTaskIndex = UE::Tasks::WaitAny(Tasks);

// 创建一个等待任意任务完成的 Task
UE::Tasks::FTask AnyTask = UE::Tasks::Any(Tasks);
AnyTask.Wait();
```

#### 4. 任务并发限制器 (FTaskConcurrencyLimiter)

`FTaskConcurrencyLimiter` 允许限制特定类型任务的并发执行数量，这对于控制资源消耗非常有用。

```cpp
UE::Tasks::FTaskConcurrencyLimiter Limiter(4); // 允许最多 4 个任务并发执行

for (int i = 0; i < 10; ++i)
{
    Limiter.Push(UE_SOURCE_LOCATION, [](uint32 Slot) {
        UE_LOG(LogTemp, Log, TEXT("Task executing in slot %d"), Slot);
        FPlatformProcess::Sleep(0.1f);
    });
}

Limiter.Wait(); // 等待所有通过 Limiter 派发的任务完成
```
`Push` 方法接受一个 lambda，该 lambda 接收一个表示当前 slot 的 `uint32` 参数，可以用于区分不同的并发执行单元。

### 总结

UE5 的 TaskSystem 提供了一套强大且灵活的工具，用于管理游戏中的异步操作。无论是简单的后台任务，还是复杂的依赖关系和线程同步，TaskSystem 都能提供合适的 API 来实现。理解其核心概念和高级功能，能帮助开发者更好地利用多核处理器的性能，并创建响应迅速、高效的游戏体验。