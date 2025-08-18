---
title: UE5 AI MoveTo
comments: true
---

# UE5 AI MoveTo

## 虚幻引擎里面有好几个 AI Move To
1. `class AIGRAPH_API UK2Node_AIMoveTo : public UK2Node_BaseAsyncTask`
2. `class UAITask_MoveTo : public UAITask`
3. `struct FStateTreeMoveToTask : public FStateTreeAIActionTaskBase`

他们的底层实现，目前是相同的。都是使用`FAIMoveRequest`发起Move To请求。

UK2Node_AIMoveTo 调用的是：
```c++
class UAIBlueprintHelperLibrary : public UBlueprintFunctionLibrary
{
	GENERATED_UCLASS_BODY()

	UFUNCTION(BlueprintCallable, meta=(WorldContext="WorldContextObject", BlueprintInternalUseOnly = "TRUE"))
	static AIMODULE_API UAIAsyncTaskBlueprintProxy* CreateMoveToProxyObject(UObject* WorldContextObject, APawn* Pawn, FVector Destination, AActor* TargetActor = NULL, float AcceptanceRadius = 5.f, bool bStopOnOverlap = false);
}
```

UAITask_MoveTo 则是一个`UGameplayTask`，是更加现代化的写法。
```c++
UAITask_MoveTo::UAITask_MoveTo(const FObjectInitializer& ObjectInitializer)
	: Super(ObjectInitializer)
{
	bIsPausable = true;
	MoveRequestID = FAIRequestID::InvalidRequest;

	MoveRequest.SetAcceptanceRadius(GET_AI_CONFIG_VAR(AcceptanceRadius));
	MoveRequest.SetReachTestIncludesAgentRadius(GET_AI_CONFIG_VAR(bFinishMoveOnGoalOverlap));
	MoveRequest.SetAllowPartialPath(GET_AI_CONFIG_VAR(bAcceptPartialPaths));
	MoveRequest.SetUsePathfinding(true);

	AddRequiredResource(UAIResource_Movement::StaticClass());
	AddClaimedResource(UAIResource_Movement::StaticClass());
	
	MoveResult = EPathFollowingResult::Invalid;
	bUseContinuousTracking = false;
}
```

FStateTreeMoveToTask 是StateTree提供的Task，是StateTree的写法, 而它内部调用的是`UAITask_MoveTo`
```c++
UAITask_MoveTo* FStateTreeMoveToTask::PrepareMoveToTask(FStateTreeExecutionContext& Context, AAIController& Controller, UAITask_MoveTo* ExistingTask, FAIMoveRequest& MoveRequest) const
{
	FInstanceDataType& InstanceData = Context.GetInstanceData(*this);
	UAITask_MoveTo* MoveTask = ExistingTask ? ExistingTask : UAITask::NewAITask<UAITask_MoveTo>(Controller, *InstanceData.TaskOwner);
	if (MoveTask)
	{
		MoveTask->SetUp(&Controller, MoveRequest);
	}

	return MoveTask;
}
```

综上，`UK2Node_AIMoveTo` 是比较古老的写法，能配置的参数很少，建议不要使用。

## StateTree MoveTo 分析

### 追踪Actor 还是Location 
```c++
if (InstanceData.TargetActor)
	{
		if (InstanceData.bTrackMovingGoal)
		{
			MoveReq.SetGoalActor(InstanceData.TargetActor);
		}
		else
		{
			MoveReq.SetGoalLocation(InstanceData.TargetActor->GetActorLocation());
		}
	}
	else
	{
		MoveReq.SetGoalLocation(InstanceData.Destination);
	}
```
既支持Actor目标，也支持Location目标， 当追踪Actor时，只有勾选了`Track Moving Goal`才会追踪Actor，否则退回成Actor的Location。

### Tick

```c++
EStateTreeRunStatus FStateTreeMoveToTask::Tick(FStateTreeExecutionContext& Context, const float DeltaTime) const
{
	FInstanceDataType& InstanceData = Context.GetInstanceData(*this);
	if (InstanceData.MoveToTask)
	{
		if (InstanceData.MoveToTask->GetState() == EGameplayTaskState::Finished)
		{
			return InstanceData.MoveToTask->WasMoveSuccessful() ? EStateTreeRunStatus::Succeeded : EStateTreeRunStatus::Failed;
		}

		if (InstanceData.bTrackMovingGoal && !InstanceData.TargetActor)
		{
			const FVector CurrentDestination = InstanceData.MoveToTask->GetMoveRequestRef().GetDestination();
			if (FVector::DistSquared(CurrentDestination, InstanceData.Destination) > (InstanceData.DestinationMoveTolerance * InstanceData.DestinationMoveTolerance))
			{
				UE_VLOG(Context.GetOwner(), LogStateTree, Log, TEXT("FStateTreeMoveToTask destination has moved enough. Restarting task."));
				return PerformMoveTask(Context, *InstanceData.AIController);
			}
		}
		return EStateTreeRunStatus::Running;
	}
	return EStateTreeRunStatus::Failed;
}
```

可以看出，如果是追踪Actor，路径是更新是 FAIMoveRequest 内部传达的，但如果是追踪Location，则Tick会重新调用`UAITask_MoveTo::PerformMoveTask`，重新发起Move To请求。


## Move To 可能遇到的问题

### 角色动画是RootMotion时，Move To可能会停不下来
RootMotion 由动画驱动位移，需要把相关控制权交出来，比如旋转，否则RootMotion 只会沿着一个方向前进，导致永远去不到目标位置。 如果不是Root Motion 就不会有这种问题

解决方法：
 
1.允许Yaw被控制，`bUseControllerRotationYaw = true`



