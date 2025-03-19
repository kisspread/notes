---
title: MassEntity 和Chaos的集成
comments: true
---
# Mass Entities 物理系统实现思路

Mass Entities 框架通过与 Chaos 物理系统的集成来实现物理效果 

## 核心组件

### 1. Fragment 与 Tag 定义

核心物理片段和标记的定义：

```cpp
// 核心物理片段，包含指向 Chaos 物理粒子 
USTRUCT(BlueprintType)
struct MASSCOMMUNITYSAMPLE_API FMSMassPhysicsFragment : public FMassFragment 
{
    GENERATED_BODY()

    FMSMassPhysicsFragment() = default;
    FPhysicsActorHandle SingleParticlePhysicsProxy;

    FMSMassPhysicsFragment(const FPhysicsActorHandle& ParticlePhysicsProxy)
    {
        SingleParticlePhysicsProxy = ParticlePhysicsProxy;
    };
};

// 物理相关标记
USTRUCT(BlueprintType)
struct MASSCOMMUNITYSAMPLE_API FMSSimulatesPhysicsTag : public FMassTag
{
    GENERATED_BODY()
};

USTRUCT(BlueprintType)
struct MASSCOMMUNITYSAMPLE_API FMSUpdateKinematicFromSimulationTag : public FMassTag
{
    GENERATED_BODY()
};

USTRUCT(BlueprintType)
struct MASSCOMMUNITYSAMPLE_API FMSChaosToMassTag : public FMassTag
{
    GENERATED_BODY()
};

USTRUCT(BlueprintType)
struct MASSCOMMUNITYSAMPLE_API FMSMassToChaosTag : public FMassTag
{
    GENERATED_BODY()
};
```

### 2. 碰撞数据管理

碰撞设置片段的定义：

```cpp
// 共享碰撞设置片段
USTRUCT(BlueprintType)
struct FSharedCollisionSettingsFragment : public FMassSharedFragment
{
    GENERATED_BODY()

    UPROPERTY(EditAnywhere)
    FBodyInstance BodyInstance;
    
    UPROPERTY(EditAnywhere)
    FKAggregateGeom Geometry;
};
```

## 工作流程

### 1. 初始化处理器 (UMSPhysicsInitProcessor)

初始化处理器的实现：

```cpp
UCLASS()
class MASSCOMMUNITYSAMPLE_API UMSPhysicsInitProcessor : public UMassObserverProcessor
{
    GENERATED_BODY()
    
    UMSPhysicsInitProcessor()
    {
        ObservedType = FMSMassPhysicsFragment::StaticStruct();
        Operation = EMassObservedOperation::Add;
        bRequiresGameThreadExecution = true;
    }

    virtual void ConfigureQueries() override
    {
        EntityQuery.AddRequirement<FMSMassPhysicsFragment>(EMassFragmentAccess::ReadWrite);
        EntityQuery.AddRequirement<FTransformFragment>(EMassFragmentAccess::ReadOnly);
        EntityQuery.AddSharedRequirement<FSharedCollisionSettingsFragment>(EMassFragmentAccess::ReadWrite, EMassFragmentPresence::Optional);
        EntityQuery.AddConstSharedRequirement<FMSSharedStaticMesh>(EMassFragmentPresence::Optional);
        EntityQuery.RegisterWithProcessor(*this);
    }
};
```

物理体创建的核心函数：

```cpp
FPhysicsActorHandle InitAndAddNewChaosBody(FActorCreationParams& ActorParams, 
    const FBodyCollisionData& CollisionData, 
    FKAggregateGeom* AggregateGeom,
    float Density)
{
    FPhysicsActorHandle NewPhysHandle;
    FPhysicsInterface::CreateActor(ActorParams, NewPhysHandle);

    // 设置物理属性
    FPhysicsInterface::SetCcdEnabled_AssumesLocked(NewPhysHandle, false);
    FPhysicsInterface::SetSmoothEdgeCollisionsEnabled_AssumesLocked(NewPhysHandle, false);
    FPhysicsInterface::SetInertiaConditioningEnabled_AssumesLocked(NewPhysHandle, true);
    FPhysicsInterface::SetIsKinematic_AssumesLocked(NewPhysHandle, !ActorParams.bSimulatePhysics);
    FPhysicsInterface::SetMaxLinearVelocity_AssumesLocked(NewPhysHandle, MAX_flt);

    // 创建几何体
    FGeometryAddParams CreateGeometryParams;
    CreateGeometryParams.Geometry = AggregateGeom;
    CreateGeometryParams.CollisionData = CollisionData;
    CreateGeometryParams.Scale = FVector::One();
    CreateGeometryParams.LocalTransform = Chaos::FRigidTransform3::Identity;
    CreateGeometryParams.WorldTransform = ActorParams.InitialTM;

    // 创建形状
    TArray<Chaos::FImplicitObjectPtr> Geoms;
    Chaos::FShapesArray Shapes;
    ChaosInterface::CreateGeometry(CreateGeometryParams, Geoms, Shapes);

    // 设置几何体和形状
    Chaos::FRigidBodyHandle_External& Body_External = NewPhysHandle->GetGameThreadAPI();
    if (Geoms.Num() > 0)
    {
        if (Body_External.GetGeometry())
        {
            Body_External.MergeGeometry(MoveTemp(Geoms));
        }
        else
        {
            Chaos::FImplicitObjectUnion ChaosUnionPtr = Chaos::FImplicitObjectUnion(MoveTemp(Geoms));
            Body_External.SetGeometry(ChaosUnionPtr.CopyGeometry());
        }
    }

    // 更新形状边界
    for (auto& Shape : Shapes)
    {
        Chaos::FRigidTransform3 WorldTransform = Chaos::FRigidTransform3(Body_External.X(), Body_External.R());
        Shape->UpdateShapeBounds(WorldTransform);
    }
    Body_External.MergeShapesArray(MoveTemp(Shapes));

    return NewPhysHandle;
}
```

### 2. 变换同步处理器 (UMSChaosMassTranslationProcessorsProcessors)

变换同步处理器的实现：

```cpp
UCLASS()
class MASSCOMMUNITYSAMPLE_API UMSChaosMassTranslationProcessorsProcessors : public UMassProcessor
{
    GENERATED_BODY()

    UMSChaosMassTranslationProcessorsProcessors()
    {
        ExecutionOrder.ExecuteInGroup = UE::Mass::ProcessorGroupNames::UpdateWorldFromMass;
        ExecutionOrder.ExecuteAfter.Add(UE::Mass::ProcessorGroupNames::Movement);
        bRequiresGameThreadExecution = true;
    }

    virtual void ConfigureQueries() override
    {
        // 配置查询
        ChaosSimToMass = MSMassUtils::Query<FMSChaosToMassTag, const FMSMassPhysicsFragment, FTransformFragment>();
        MassTransformsToChaosBodies = MSMassUtils::Query<FMSMassToChaosTag, FMSMassPhysicsFragment, const FTransformFragment>();
        
        UpdateChaosKinematicTargets = MassTransformsToChaosBodies;
        UpdateChaosKinematicTargets.AddRequirement<FMassForceFragment>(EMassFragmentAccess::ReadOnly);
    }

    virtual void Execute(FMassEntityManager& EntityManager, FMassExecutionContext& Context) override
    {
        // 物理到Mass的同步
        ChaosSimToMass.ForEachEntityChunk(EntityManager, Context, [this](FMassExecutionContext& Context)
        {
            auto PhysicsFragments = Context.GetFragmentView<FMSMassPhysicsFragment>();
            auto Transforms = Context.GetMutableFragmentView<FTransformFragment>();

            for (int32 i = 0; i < Context.GetNumEntities(); i++)
            {
                FPhysicsActorHandle PhysicsHandle = PhysicsFragments[i].SingleParticlePhysicsProxy;
                if (GetWorld()->GetPhysicsScene() && PhysicsHandle)
                {
                    Chaos::FRigidBodyHandle_External& Body_External = PhysicsHandle->GetGameThreadAPI();
                    Transforms[i].GetMutableTransform() = FTransform(Body_External.R(), Body_External.X());
                }
            }
        });

        // 运动学目标更新
        UpdateChaosKinematicTargets.ForEachEntityChunk(EntityManager, Context, [this](FMassExecutionContext& Context)
        {
            const auto& PhysicsFragments = Context.GetFragmentView<FMSMassPhysicsFragment>();
            const auto& Transforms = Context.GetMutableFragmentView<FTransformFragment>();
            const auto& Forces = Context.GetFragmentView<FMassForceFragment>();

            for (int32 i = 0; i < Context.GetNumEntities(); i++)
            {
                FPhysicsActorHandle PhysicsHandle = PhysicsFragments[i].SingleParticlePhysicsProxy;
                if (GetWorld()->GetPhysicsScene() && PhysicsHandle)
                {
                    const FTransform NewPose = Transforms[i].GetTransform();
                    Chaos::FRigidBodyHandle_External& Body_External = PhysicsHandle->GetGameThreadAPI();
                    
                    Body_External.ClearKinematicTarget();
                    if (Body_External.UpdateKinematicFromSimulation())
                    {
                        Body_External.SetKinematicTarget(NewPose + FTransform(Forces[i].Value));
                    }
                }
            }
        });
    }

protected:
    FMassEntityQuery ChaosSimToMass;
    FMassEntityQuery UpdateChaosKinematicTargets;
    FMassEntityQuery MassTransformsToChaosBodies;
};
```

### 3. 清理处理器 (UMSPhysicsCleanupProcessor)

清理处理器的实现：

```cpp
UCLASS()
class MASSCOMMUNITYSAMPLE_API UMSPhysicsCleanupProcessor : public UMassObserverProcessor
{
    GENERATED_BODY()
    
    UMSPhysicsCleanupProcessor()
    {
        ObservedType = FMSMassPhysicsFragment::StaticStruct();
        Operation = EMassObservedOperation::Remove;
        bRequiresGameThreadExecution = true;
    }

    virtual void ConfigureQueries() override
    {
        EntityQuery.AddRequirement<FMSMassPhysicsFragment>(EMassFragmentAccess::ReadWrite);
        EntityQuery.RegisterWithProcessor(*this);
    }

    virtual void Execute(FMassEntityManager& EntityManager, FMassExecutionContext& Context) override
    {
        EntityQuery.ForEachEntityChunk(EntityManager, Context, [this](FMassExecutionContext& Context)
        {
            const auto PhysicsFragments = Context.GetFragmentView<FMSMassPhysicsFragment>();
            for (int32 i = 0; i < Context.GetNumEntities(); i++)
            {
                if (PhysicsFragments[i].SingleParticlePhysicsProxy)
                {
                    GetWorld()->GetPhysicsScene()->RemoveActor(PhysicsFragments[i].SingleParticlePhysicsProxy);
                }
            }
        });
    }
};
```

 
 ## Reference
 - [Mass社区Sample](https://github.com/Megafunk/MassSample/)
 