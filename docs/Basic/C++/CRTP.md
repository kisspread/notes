---
title: UE5 里的 奇异递归模板
comments: true
---

# UE5 里的 奇异递归模板

## 引子

假设我们有这样的代码：

```C++{16}
class Base {
public:
    virtual void foo() { }
};

class Derived1 : public Base {
    virtual void foo() override { }
};

class Derived2 : public Base {
    virtual void foo() override { }
};

int main() {
    Base* ptr = new Derived1();
    ptr->foo();  // 如何知道调用哪个foo？
}
```

关键问题是：**编译器在编译时不知道 ptr 实际指向的对象类型。**

### 虚函数的查表逻辑

为了解决这个问题，在 C++ 中，虚函数（virtual function）的实现是通过 虚表（vtable） 和 虚表指针（vptr） 机制完成的。即使编译器在编译时不知道 ptr 具体指向哪个派生类对象，也能在运行时通过这个机制动态确定要调用的函数。

**虚表（vtable）的生成**

- 每个包含虚函数的类（或从包含虚函数的类派生的类）都会在编译时生成一个 虚表
- 虚表 是一个隐藏的静态数组，存储了该类所有虚函数的实际地址
  ```cpp
  // Derived1 的虚表
  [ &Derived1::foo ]  // 第一个槽位指向 Derived1::foo

  // Derived2 的虚表
  [ &Derived2::foo ]  // 第一个槽位指向 Derived2::foo
  ```
 **虚表指针（vptr）的注入**

 - 每个对象实例在内存中会隐式包含一个 **虚表指针（vptr）** 
 - 当创建对象时，构造函数会隐式初始化 vptr：
   ```cpp
   Derived1* d1 = new Derived1();
   // d1 的 vptr 指向 Derived1 的虚表

   Base* ptr = d1; 
   // ptr 的静态类型是 Base*，但 vptr 仍然指向 Derived1 的虚表
   ```

综上，虚函数是在编译时构造虚表和虚表指针，然后在运行时根据 vptr 找到虚表，再根据虚表找到要调用的函数地址, 所以又叫做**运行时多态**。

::: details 虚函数在JVM里的情况
首先，Java中所有方法默认都是"虚"的

```java
class Base {
    public void foo() { }  // 自动是virtual的
}

class Derived extends Base {
    @Override
    public void foo() { }  // 覆盖父类方法
}
```
JVM的内部实现和C++都使用表格查找来实现运行时多态

- Java的实现更复杂，但提供更多运行时优化机会
- C++的实现更简单直接，运行时开销更可预测
- Java的JIT可以在某些情况下实现比C++更好的性能
- 但Java需要更多的内存和预热时间

// 优势
- JIT可以根据运行时信息优化
- 可以进行激进的内联
- 可以基于概率进行投机优化

// 劣势
- 初始解释执行较慢
- 需要预热时间
- 内存开销较大

:::

### 虚函数的性能影响

**虚函数调用**比普通函数调用多一次指针间接寻址（访问虚表）和一次函数地址跳转。通常会有 1~2 个 CPU 周期的额外开销，但在大多数场景下可以忽略不计。

但在游戏领域，对性能要求非常高的场景，（如数学库、游戏引擎），例如矩阵/向量的运算这种优化是必须的。

**大致有两种优化：**
- 依赖编译器在编译时自动进行优化（据说有些情况下支持自动内联， 去虚化（Devirtualization））
- 手动优化，这篇文章中的主角：**奇异递归模板模式**

## 奇异递归模板模式

```cpp
template <typename T>
class CRTP {
protected:
    T* self() { return static_cast<T*>(this); }
};

//形如都可以叫做 CRTP
template <typename T>
class B { ... };
class D : public B<D> { ... };

```

CRTP（Curiously Recurring Template Pattern，奇异递归模板模式）是一种通过模板继承实现编译期多态和代码复用的技术。它的核心思想是让基类通过模板参数知道派生类的类型，从而在编译期实现类型相关的操作，避免了运行时虚函数调用的开销。

#### CRTP 的好处

- 模板类会在编译期根据模板参数自动展开，内联到调用者的代码中，避免了运行时虚函数调用的开销。
- 基类可以为所有派生类提供统一的功能，无需在每个派生类中重复实现, 类似其他语言的拓展方法。
- 实现编译期多态的接口
::: code-group

```cpp [例子1：静态多态（编译期多态）]
//避免虚函数开销
template <typename T>
class VectorBase {
public:
    T operator+(const T& other) const {
        T result;
        for (int i = 0; i < T::Size; ++i) {
            result[i] = static_cast<const T*>(this)->data[i] + other.data[i];
        }
        return result;
    }
};

class Vec3 : public VectorBase<Vec3> {
public:
    static const int Size = 3;
    float data[3];
};

// 使用
Vec3 a{1, 2, 3}, b{4, 5, 6};
Vec3 c = a + b;  // 编译期展开，无运行时开销
```

```cpp [例子2：构建链式调用接口]
//在编译期构建链式的多态接口
template <typename T>
class Chainable {
public:
    T& SetX(int x) {
        static_cast<T*>(this)->x = x;
        return *static_cast<T*>(this);
    }
    T& SetY(int y) {
        static_cast<T*>(this)->y = y;
        return *static_cast<T*>(this);
    }
};

class Point : public Chainable<Point> {
public:
    int x, y;
};

// 使用
Point p;
p.SetX(10).SetY(20);  // 链式调用
```

```cpp [例子3：代码复用]
//通过 CRTP，基类可以为所有派生类提供统一的功能，无需在每个派生类中重复实现。
//示例：自动生成 operator==
template <typename T>
class EqualityComparable {
public:
    bool operator!=(const T& other) const {
        return !(static_cast<const T*>(this)->operator==(other));
    }
};

class Point : public EqualityComparable<Point> {
public:
    int x, y;
    bool operator==(const Point& other) const {
        return x == other.x && y == other.y;
    }
};

// 使用
Point p1{1, 2}, p2{1, 2};
std::cout << (p1 == p2);  // true
std::cout << (p1 != p2);  // false（自动生成）
```
:::

## UE5 里的 奇异递归模板（CRTP）

### 智能指针模板类 `TSharedFromThis`

该模板类属于拓展类的能力，赋予该类拥有 智能指针的能力

**智能指针典型的例子：** 通过引用计数来管理对象的生命周期

```cpp
class DownloadManager : public TSharedFromThis<DownloadManager, ESPMode::ThreadSafe> 
{
public:
    void StartDownload(const FString& URL) 
    {
        // 场景1：危险的做法 - 使用裸指针
        AsyncTask(ENamedThreads::AnyBackgroundThreadNormal, [this]() {
            // 危险！此时 DownloadManager 可能已经被销毁
            ProcessDownload();  
        });

        // 场景2：安全的做法 - 使用 AsShared()
        TSharedRef<DownloadManager> SafeThis = AsShared();
        AsyncTask(ENamedThreads::AnyBackgroundThreadNormal, [SafeThis]() {
            // 安全！因为 lambda 捕获了 SafeThis，引用计数会保持对象存活
            SafeThis->ProcessDownload(); 
            //作用域结束， 任务完成，释放SafeThis（refcount=0）
        });
    }
};

void Example()
{
    {
        // 注意，必须使用 MakeShared 来创建智能指针
        TSharedRef<DownloadManager> Manager = MakeShared<DownloadManager>(); //MakeShared()创建对象（refcount=1）
        Manager->StartDownload("http://example.com/file.zip"); //内部AsShared()获得SafeThis（refcount=2）
    } // <- 作用域结束, (refcount=2-1=1）

    // 场景1：如果使用 this，此时 DownloadManager 已经被销毁，后台任务访问无效内存
    // 场景2：如果使用 SafeThis，即使这里离开了作用域：
    //       - lambda 仍然持有 SafeThis 的引用
    //       - 引用计数 > 0，对象继续存活
    //       - 直到后台任务完成，lambda 销毁，引用计数归零，对象才会被删除
}
```

### 排名第二多是 `TCommands` 模板类

它其实也是`TSharedFromThis`的派生类，提供快速注册slate命令（回调）的接口

- CRTP 确保每个 `TCommands<CommandContextType>` 子类拥有独立的静态 Instance，避免类型混淆。

::: code-group
```cpp [FMyCommands]
class FMyCommands : public TCommands<FMyCommands>
{
public:
    FMyCommands()
        : TCommands<FMyCommands>(
            TEXT("MyModule"),
            NSLOCTEXT("Contexts", "MyModule", "My Module"),
            NAME_None,
            FMyStyle::GetStyleSetName()  // 确保样式集已注册
        )
    {}

    // 声明命令
    TSharedPtr<FUICommandInfo> Command_Save;

    virtual void RegisterCommands() override
    {
        UI_COMMAND(
            Command_Save,              // 命令变量
            "Save",                    // 命令显示名称
            "Save current content",    // 工具提示
            EUserInterfaceActionType::Button,  // 命令类型
            FInputChord(EKeys::S, EModifierKey::Control)  // 可选：快捷键
        );
    }
};
```
```cpp [FMyModule]
// 在模块启动时
void FMyModule::StartupModule()
{
    // 注册命令
    FMyCommands::Register();

    // 创建命令列表并绑定执行函数
    CommandList = MakeShareable(new FUICommandList);
    CommandList->MapAction(
        FMyCommands::Get().Command_Save,
        FExecuteAction::CreateRaw(this, &FMyModule::OnSave),
        FCanExecuteAction::CreateRaw(this, &FMyModule::CanSave)
    );
}

// 执行函数
void FMyModule::OnSave()
{
    // 实现保存逻辑
}

// 可执行条件检查函数（可选）
bool FMyModule::CanSave() const
{
    return true; // 返回是否可以执行保存操作
}
```
```cpp [FMyModule：工具栏]
// 可选
//创建工具栏
TSharedRef<SWidget> FMyModule::CreateToolbar()
{
    FToolBarBuilder ToolbarBuilder(CommandList, FMultiBoxCustomization::None);
    
    ToolbarBuilder.BeginSection("File");
    {
        ToolbarBuilder.AddToolBarButton(
            FMyCommands::Get().Command_Save,
            NAME_None,
            TAttribute<FText>(),  // 使用命令中定义的文本
            TAttribute<FText>(),  // 使用命令中定义的提示
            FSlateIcon(FMyStyle::GetStyleSetName(), "Icons.Save")
        );
    }
    ToolbarBuilder.EndSection();

    return ToolbarBuilder.MakeWidget();
}
```
:::

## References

- [shuo-ouyang: 奇异递归模板模式](https://www.cnblogs.com/shuo-ouyang/p/15773193.html)