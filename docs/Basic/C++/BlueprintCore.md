---
title: UE 蓝图类：UBlueprintCore
---

# UE 蓝图类：UBlueprintCore 分析记录

## UWidgetBlueprint 解析

#### 类继承
- 继承自 `UBlueprint`
- 专门用于处理 UMG（Unreal Motion Graphics）Widget 蓝图

#### 关键特性
1. **蓝图生成类**
   - 生成 `UWidgetBlueprintGeneratedClass`
   - 支持动态属性绑定
   - 管理 Widget 的生命周期和初始化

2. **性能相关属性**
   - `TickFrequency`：用户设置的 Widget 刷新频率
   - `TickPrediction`：编译时预测的 Widget 刷新策略
   - `TickPredictionReason`：刷新的原因说明

3. **编译和验证机制**
   - 支持检测循环引用
   - 验证 Widget 名称冲突
   - 支持属性绑定
   - 自定义编译器上下文

4. **生命周期管理**
   - 支持命名插槽继承
   - 管理 Widget 树和动画
   - 处理 Widget 初始化和销毁

#### 主要方法
- `GetBlueprintClass()`：获取蓝图对应的类
- `AllowsDynamicBinding()`：是否允许动态绑定
- `SupportsInputEvents()`：是否支持输入事件
- `HasCircularReferences()`：检测循环引用
- `UpdateTickabilityStats()`：更新可刷新状态统计

#### 使用场景
- 创建复杂的交互式用户界面
- 定义可重用的 UI 组件
- 实现动态 UI 逻辑和属性绑定

### UBlueprintCore 中的生成类

#### SkeletonGeneratedClass vs GeneratedClass

1. **SkeletonGeneratedClass（骨架生成类）**
   - 在添加成员变量或函数时重新生成
   - 通常是不完整的类
   - 不包含完整的代码实现
   - 不包含隐藏的自动生成变量
   - 主要用于编辑器中的结构预览和基本类型信息

2. **GeneratedClass（完全生成类）**
   - 指向最近完全生成的类
   - 包含完整的代码实现
   - 包含所有自动生成的变量和方法
   - 可以直接用于运行时执行

#### 生成过程示意
```
编辑蓝图 -> 修改成员 -> 更新 SkeletonGeneratedClass
                    -> 完全编译 -> 更新 GeneratedClass
```

#### 关键区别
- **SkeletonGeneratedClass**
  - 轻量级
  - 快速更新
  - 编辑器预览使用
  - 不可直接执行

- **GeneratedClass**
  - 完整实现
  - 编译后生成
  - 运行时使用
  - 可直接实例化和执行

#### 使用场景
- 编辑器快速反馈
- 增量编译支持
- 保持类型一致性
- 支持热重载机制

### UE 蓝图类命名规则

#### 类名生成规则

1. **实现类（GeneratedClass）**
   - 格式：`W_ConfirmationDialog_C`
   - 前缀 `W_` 表示 Widget
   - 主类名 `ConfirmationDialog`
   - 后缀 `_C` 表示这是一个生成的类（Compiled Class）

2. **骨架类（SkeletonGeneratedClass）**
   - 格式：`SKEL_W_ConfirmationDialog_C`
   - 前缀 `SKEL_` 表示骨架类（Skeleton）
   - 保留原始类的基本结构和命名

#### 命名约定的意义
- 明确区分生成类和骨架类
- 保持类型追踪的一致性
- 支持编辑器的增量编译机制

#### 内部标志（InternalFlags）
- `ReachabilityFlag1`：对象可达性标记
- `AsyncLoadingPhase1`：异步加载阶段
- `Async`：异步处理标记

#### 实际示例
```
实现类：W_ConfirmationDialog_C
骨架类：SKEL_W_ConfirmationDialog_C
原始类：W_ConfirmationDialog
```

#### 使用场景
- 编辑器类型管理
- 运行时类型识别
- 支持热重载和增量编译

### Widget Blueprint 创建流程

当创建新的 Widget 蓝图时，[UWidgetBlueprintFactory](cci:2://file:///x:/UnrealEngine/Engine/Source/Editor/UMGEditor/Private/WidgetBlueprintFactory.cpp:155:0-211:1) 的 [FactoryCreateNew](cci:1://file:///x:/UnrealEngine/Engine/Source/Editor/UMGEditor/Private/WidgetBlueprintFactory.cpp:155:0-211:1) 函数负责初始化过程：

1. 调用 `FKismetEditorUtilities::CreateBlueprint` 创建蓝图对象
2. 检查 `WidgetTree->RootWidget` 是否为空
3. 如果为空，创建默认的根 Widget（通常是 Panel Widget）
4. 将新创建的 Widget 设置为 `RootWidget`

这就解释了为什么每个新创建的 Widget 蓝图都会有一个默认的根 Widget（通常是 Canvas Panel）作为其他 Widget 的容器。



### Blueprint 编译管理器中的 Widget Tree 处理

在 [FBlueprintCompilationManagerImpl](cci:2://file:///x:/UnrealEngine/Engine/Source/Editor/Kismet/Private/BlueprintCompilationManager.cpp:83:0-3662:1) 中，Widget Tree 的处理是通过多阶段编译过程完成的：

1. **编译队列处理**
   - 在 `FlushCompilationQueueImpl` 函数中，当获取到 `QueuedBP` 时，其内部的 `WidgetTree` 已经具有值
   - 这是因为 Widget Tree 在蓝图资产加载时就已经被反序列化和初始化

2. **编译阶段**
   - STAGE I (GATHER): 收集所有需要编译的蓝图
   - STAGE II (FILTER): 过滤数据类型和接口蓝图
   - STAGE III (SORT): 根据依赖关系排序
   - STAGE VIII (RECOMPILE SKELETON): 重新编译骨架类，这个阶段会处理 Widget Tree 的基础结构
   - STAGE XI (CREATE UPDATED CLASS HIERARCHY): 创建更新后的类层次结构
   - STAGE XII (COMPILE CLASS LAYOUT): 编译类布局，包括 Widget Tree 的属性
   - STAGE XIII (COMPILE CLASS FUNCTIONS): 编译类函数

3. **多线程处理**
   ```cpp
   // 编译管理器使用锁来确保线程安全
   #if WITH_EDITOR
   FCriticalSection Lock;
   #endif
   ```
   - 编译过程可能涉及多个线程
   - 使用 `FCriticalSection` 确保线程安全
   - Widget Tree 的访问和修改都在适当的锁保护下进行

4. **编译数据管理**
   ```cpp
   struct FCompilerData
   {
       UBlueprint* BP;
       FCompilerResultsLog* ActiveResultsLog;
       TSharedPtr<FKismetCompilerContext> Compiler;
       FKismetCompilerOptions InternalOptions;
       // ...
   };
   ```
   - 每个编译任务都有自己的 `FCompilerData` 实例
   - 包含了蓝图、编译器上下文和选项等信息
   - Widget Tree 的编译状态被保存在这些数据中

这种多阶段的编译过程确保了 Widget Tree 在蓝图编译过程中的正确初始化和更新。Widget Tree 的值在蓝图加载时就已存在，编译过程主要是处理其结构更新和功能编译。

## Widget Tree 加载分析

### PostLoad 分析

1. `UWidgetTree::PostLoad()` 的实现非常简单:
```cpp
void UWidgetTree::PostLoad()
{
    Super::PostLoad();

#if WITH_EDITORONLY_DATA
    AllWidgets.Empty();
#endif
}
```
它主要是清空编辑器数据中的 AllWidgets 缓存。

2. `UWidgetBlueprintGeneratedClass::PostLoad()` 的实现:
```cpp
void UWidgetBlueprintGeneratedClass::PostLoad()
{
    Super::PostLoad();

    if (WidgetTree)
    {
        // We don't want any of these flags to carry over from the WidgetBlueprint
        WidgetTree->ClearFlags(RF_Public | RF_ArchetypeObject | RF_DefaultSubObject);

#if !WITH_EDITOR
        WidgetTree->AddToCluster(this, true);
#endif
    }

#if WITH_EDITOR
    // 处理旧版本的 Visibility 属性名称兼容
    if ( GetLinkerUEVersion() < VER_UE4_RENAME_WIDGET_VISIBILITY )
    {
        static const FName Visiblity(TEXT("Visiblity"));
        static const FName Visibility(TEXT("Visibility"));

        for ( FDelegateRuntimeBinding& Binding : Bindings )
        {
            if ( Binding.PropertyName == Visiblity )
            {
                Binding.PropertyName = Visibility;
            }
        }
    }
#endif
```

主要做了两件事:
1. 清除 WidgetTree 的一些标记位:
   - RF_Public: 表示对象是公开的
   - RF_ArchetypeObject: 表示对象是原型对象
   - RF_DefaultSubObject: 表示对象是默认子对象
   
2. 在非编辑器模式下,将 WidgetTree 添加到当前类的 Cluster 中,这是为了优化内存管理。

3. 在编辑器模式下,处理旧版本的兼容性问题,将错误拼写的 "Visiblity" 属性名修正为 "Visibility"。
