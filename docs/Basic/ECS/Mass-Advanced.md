---
title: MassEntity 高级篇
comments: true
---

 # MassEntity 高级篇
 ![alt text](../../assets/images/Mass-Advanced_image.webp){width=320px}

（并非有多高级，主要是涉及实际应用场景，模块代码众多，如 MassGamePlay 的使用）

（未完成，持续记录中）

## MassEntity 工具补充

### FMassDebugger
::: warning 5.6 重新设计了MassDebugger 界面更好看了
![alt text](../../assets/images/Mass-Advanced_image-4.webp){width=50%}
:::

`\Engine\Source\Runtime\MassEntity\Private\MassDebugger.cpp`

调试工具，这里面有大量Entity相关的调试命令。也有一些调试方法，其中比较好用的是`SelectEntity`。它带了一个`OnEntitySelectedDelegate`，可以注册一个回调函数，当选中Entity时会触发。

```cpp
void FMassDebugger::SelectEntity(const FMassEntityManager& EntityManager, const FMassEntityHandle EntityHandle)
{
	UE::Mass::Debug::SetDebugEntityRange(EntityHandle.Index, EntityHandle.Index);

	const int32 Index = ActiveEnvironments.IndexOfByPredicate([WeakManager = EntityManager.AsWeak()](const FEnvironment& Element)
		{
			return Element.EntityManager == WeakManager;
		});
	if (ensure(Index != INDEX_NONE))
	{
		ActiveEnvironments[Index].SelectedEntity = EntityHandle;
	}

	OnEntitySelectedDelegate.Broadcast(EntityManager, EntityHandle);
}
// 用法
FMassDebugger::OnEntitySelectedDelegate.AddUObject(this, &UMassDebuggerSubsystem::OnEntitySelected);
```

### FMassProcessingPhaseManager
`\Engine\Source\Runtime\MassEntity\Private\MassProcessingPhaseManager.cpp`

默认情况下，MassProcessor是不会自动运行的，需要通过`FMassProcessingPhaseManager`来驱动。



### UMassSubsystemBase
`\Engine\Source\Runtime\MassEntity\Public\MassSubsystemBase.h`

建议自定义的MassSubsystem都继承自`UMassSubsystemBase`，它提供了统一的`ShouldCreateSubsystem`判断。不建议继承`UMassEntitySubsystem`, 这个类应该不是给继承用的，继承它有很多bug。



## MassGamePlay

MassGamePlay提供了一整套基于MassEntity的组件，方便UE编辑器配置MassEntity。方便是方便，但灵活性还是得自己写，不过确实提供非常多值得参考的代码。

路径：`UnrealEngine\Engine\Plugins\Runtime\MassGameplay`

| 模块名 | 描述 |
| 模块名 | 描述 |
|--------|------|
| MassCommon | 基础片段，如`FTransformFragment` |
| MassMovement | 包含重要的`UMassApplyMovementProcessor`处理器，基于实体的速度和力进行移动 |
| MassRepresentation | 用于在世界中渲染实体的处理器和片段。通常使用ISMC进行渲染，也可以在用户指定的距离将实体替换为完整的Unreal actors |
| MassSpawner | 高度可配置的actor类型，可以在指定位置生成特定实体。内置两种选择位置的方式：一种使用Environmental Query System资产，另一种使用基于标签的ZoneGraph查询。Mass Spawner actor似乎主要用于一次性初始生成的对象，如NPC、树木等，而不是动态生成的对象（如投射物） |
| MassActors | UE5 actor框架和Mass之间的桥梁。一种将实体转换为"Agents"的片段类型，可以在两个方向（或双向）交换数据 |
| MassLOD | LOD处理器，可以管理不同类型的细节级别，从渲染到基于片段设置的不同速率的tick。目前用于可视化和复制 |
| MassReplication | Mass的复制支持！其他模块通过重写`UMassReplicatorBase`来复制内容。实体被赋予一个单独的Network ID用于网络传输，而不是EntityHandle |
| MassSignals | 允许实体之间发送命名信号的系统 |
| MassSmartObjects | 让实体可以"声明"SmartObjects以与之交互 |


### 一些重要的模块
个人认为比较重要的，记录在下面
#### MassRepresentation
`\Engine\Plugins\Runtime\MassGameplay\Source\MassRepresentation`

包含自动Actor转ISM的逻辑，各种LOD优化

#### MassSimulation
`\Engine\Plugins\Runtime\MassGameplay\Source\MassSimulation`

这是官方驱动Mass Processor 运行的模块，主要调用了FMassProcessingPhaseManager 驱动全部Mass Processors的配置。
```cpp
	TConstArrayView<FMassProcessingPhaseConfig> ProcessingPhasesConfig = GET_MASS_CONFIG_VALUE(GetProcessingPhasesConfig());
	FString DependencyGraphFileName;

#if WITH_EDITOR
	const UWorld* World = GetWorld();
	const UMassEntitySettings* Settings = GetMutableDefault<UMassEntitySettings>();
	if (World != nullptr && Settings != nullptr && !Settings->DumpDependencyGraphFileName.IsEmpty())
	{
		DependencyGraphFileName = FString::Printf(TEXT("%s_%s"), *Settings->DumpDependencyGraphFileName, *ToString(World->GetNetMode()));
	}
#endif // WITH_EDITOR

	PhaseManager.Initialize(*this, ProcessingPhasesConfig, DependencyGraphFileName);
```

#### MassSpawner
`\Engine\Plugins\Runtime\MassGameplay\Source\MassSpawner`

这里是Mass 运行的第一推动力，有个手动调用的 ` UE::Mass::Executor::RunProcessorsView`,  输入初始数据，驱动后续的Mass Processors自动运行
```cpp
// 1. Create required number of entities with EntityTemplate.Archetype
TArray<FMassEntityHandle> SpawnedEntities;
TSharedRef<FMassEntityManager::FEntityCreationContext> CreationContext
    = EntityManager->BatchCreateEntities(EntityTemplate.GetArchetype(), EntityTemplate.GetSharedFragmentValues(), NumToSpawn, SpawnedEntities);

// 2. Copy data from FMassEntityTemplate.Fragments.
//		a. @todo, could be done as part of creation?
TConstArrayView<FInstancedStruct> FragmentInstances = EntityTemplate.GetInitialFragmentValues();
EntityManager->BatchSetEntityFragmentsValues(CreationContext->GetEntityCollections(), FragmentInstances);

// 3. Run SpawnDataInitializer, if set. This is a special type of processor that operates on the entities to initialize them.
// e.g., will run UInstancedActorsInitializerProcessor for Mass InstancedActors
UMassProcessor* SpawnDataInitializer = SpawnData.IsValid() 
    ? GetSpawnDataInitializer(InitializerClass) 
    : nullptr;

if (SpawnDataInitializer)
{
    FMassProcessingContext ProcessingContext(EntityManager, /*TimeDelta=*/0.0f);
    ProcessingContext.AuxData = SpawnData;
    UE::Mass::Executor::RunProcessorsView(MakeArrayView(&SpawnDataInitializer, 1), ProcessingContext, CreationContext->GetEntityCollections());
}

OutEntities.Append(MoveTemp(SpawnedEntities));
```

#### MassSignals
`\Engine\Plugins\Runtime\MassGameplay\Source\MassSignals`

类比ObserverProcessor，MassSignals提供了一种在Entity之间传递信号的机制。可以主动发出信号。




### Traits

MassGameplay中，最重要的概念就是`Traits`, 通过Traits 可以在UE编辑器里快速配置不同的 原型变体。



## Mass AI

一些系列AI功能的总称

![alt text](../../assets/images/Mass-Advanced_image-1.webp)
（Mass AI和 Mass Crowd是两个模块， Mass Crowd 内部引入了 Mass AI 和 ）

| 插件名 | 描述 | 路径 |
|--------|------|------|
| ZoneGraph | 使用配置定义的车道来引导zonegraph路径的关卡内样条线和形状！主要用于Mass Crowd成员的移动，如人行道、道路等 |\UnrealEngine\Engine\Plugins\Runtime\ZoneGraph|
| StateTree | 一个可以与Mass配合使用的新型轻量级通用状态机。其中之一用于在示例中为锥形物体提供移动目标 |\UnrealEngine\Engine\Plugins\Runtime\StateTree|
| MassAI | 给Mass Entity 提供一系列 AI 功能 |UnrealEngine\Engine\Plugins\AI\MassAI|
| MassCrowd | 集大成者，包含了上面全部插件 |\UnrealEngine\Engine\Plugins\AI\MassCrowd|