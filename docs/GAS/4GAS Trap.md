---
title: Gas Common Pitfalls
comments:  true
---

# 一些踩过的GAS陷阱，误区

### 1. AvatarActor 客户端和服务端 类型不一致

容易先入为主地认为，主角的GAS Component 里，AvatarActor是Character，OwnerActor是PlayerState，并且整个生命周期都保持相同，其实是错误的。

#### AvatarActor 的基本概念:

  - AvatarActor 是 ASC(AbilitySystemComponent)的物理表现 Actor
  - 它与 OwnerActor(拥有 ASC 的 Actor)可以是同一个 Actor,也可以是不同的 Actor

#### 典型使用场景:

  - 简单的 AI 小兵:OwnerActor 和 AvatarActor 是同一个 Actor
  - MOBA 游戏中的英雄:OwnerActor 是 PlayerState,AvatarActor 是英雄的 Character 类

#### 初始化相关:

  - ASC 需要在服务器和客户端都进行初始化,设置 OwnerActor 和 AvatarActor
  - 初始化通常在 Pawn 被控制后进行(在 possession 之后)

#### 对于玩家控制的角色:

  - 服务器端在 Pawn 的 PossessedBy() 函数中初始化
  - 客户端在 Pawn 的 OnRep_PlayerState() 函数中初始化

::: warning
这里有个陷阱，当PlayerState 拥有ASC时，ASC默认的AvatarActor和OwnerActor都是PlayerState！！！因为源码就是这样赋值的：请看下面代码
![alt text](<../assets/images/4GAS Trap_image-3.png>)

因此，ASC 在beginplay的时候，获得是AvatarActor是PS而不是Character。

调试的时候会发现，BeginPlay里，服务端和客户端AvatarActor的类型不一致，同样的代码出现了不同的表现。

BeginPlay是个很尴尬的生命周期，只有PossessedBy和OnRep_PlayerState能保证ASC的AvatarActor和OwnerActor是正确设置的。最好是重写InitAbilityActorInfo，在这里进行判断。
::: 

### 2. gameplaytag 和 replication policy

::: tip
多人游戏里，不要相信任何BeginPlay，这是个很尴尬的生命周期
:::

- **过早调用`waitGameplayTag`会导致注册失败**：The initialization of GASComponent is after `BeginPlay`. If a node like `WaitGameplay` is called after `BeginPlay`, it usually can't register events to GAS because the GAS Component is null. This applies to both the server and client. 所有应该在on commponent created 之后调用。
   ![alt text](<../assets/images/4GAS Trap_image.png>)


- 多人游戏里，如果角色在不同client的视角里表现不一致（**自己能看到，别人看不到**），可能是对GE网络复制的理解错误，导致写出了错误的逻辑:
  In a multiple player game, the Player's GE Replicate Mode is Mixed, while NPC is set to Minimal. 这说明，“当前玩家”的GE只复制到“当前玩家”的电脑上，同时玩家电脑里的NPC不会接受到任何GE网络复制。
   ![alt text](<../assets/images/4GAS Trap_image-1.png>)
  so the ROLE_SimulatedProxy (your game partner) will not have any Active Effects because the server does not replicate GE to them. So in this case, the node `Get Active Effects with All Tags` will always return an empty array. The same goes for NPCs.也就是说，你无法通过这个方法来获取到其他玩家（或者NPC）的Active Gameplay Effects。它只能获得当前玩家active GEs.

 - 总结，通过GameplayTag来判断某个角色是否有激活的GE是最妥当的，因为它是多端复制的，而无法通过actor 是否有激活的GE来判断。


### 3. GameplayTask

Ability是永久，但某个Task一段时间后无法收到回调，看起来像自动自动结束了

问题代码：

```c++
void UAuraListenEventAbility::WaitBaseTagsEvent()
{
UAbilityTask_WaitGameplayEvent* WaitGpEventTask = UAbilityTask_WaitGameplayEvent::WaitGameplayEvent(this, BaseTag, nullptr, false, false);
WaitGpEventTask->EventReceived.AddUniqueDynamic(this,&UAuraListenEventAbility::OnNewEvent);
WaitGpEventTask->Activate();
}
```

原因：创建出来的Task并没有被Ability引用，这里只是局部变量，一段时间后就会被垃圾回收。改成类成员变量即可。

::: warning
很多时候会想当然地认为，改变量会在构造函数里被引用，所以只写局部变量，导致类似的错误。
:::


### 4. UAudioComponent

::: tip
服务端很多视效，音效相关的组件，都不会在DedicatedServer创建。
:::

UAudioComponent 不会在DedicatedServer创建，调用以下代码只会返回空指针，而其他端正常创建。
```cpp
LoopingAudioComponent = UGameplayStatics::SpawnSoundAttached(FlyingSound, GetRootComponent());
```
所以这类组件都要进行非空判断再做操作。


### 5. 先后问题
服务端SpawnActor后，立即对它执行网络多播操作，在多人游戏里可能导致先后问题。
这里log显示客户端的beginplay比SpeedUpProjectile慢。
```js
LogAura: Warning: DedicatedServer:Projectile BeginPlay
LogAura: Warning: DedicatedServer:SpeedUpProjectile
LogAura: Warning: Client:SpeedUpProjectile
LogAura: Warning: Client:Projectile BeginPlay 
```
解决方法：
- 如果可以spawn actor后，不要立即执行。
- 如果必须立即执行，只能在BeginPlay里做记号，写额外的逻辑处理。因为网络先后问题是不能避免的。

### 6. PIE模式 dedicated server anim notify 有概率丢失

经过多次测试，这种问题，只在PIE模式下出现，在独立窗口下不会出现。（PIE模式总能测出各种隐藏bug，找bug神器）

省流：Montage Tick Type	设置为 BranchingPoint即可解决。

调试日志,摘取一段OnReceivedMontageAttackAction只在client出现的片段：
```js
LogAura: Warning: Client         ,UAuraGameplayAbility::PlayDefaultMontage ,Is WaitGamplayEventFinished? :false
LogAura: Warning: DedicatedServer,UAuraGameplayAbility::PlayDefaultMontage ,Is WaitGamplayEventFinished? :false
LogAura: Warning: Client         ,UAuraGameplayAbility::OnReceivedMontageAttackAction ,Is WaitGamplayEventFinished? :false
LogAura: Warning: Client         ,UAuraGameplayAbility::OnMontageBlendOut ,Is WaitGamplayEventFinished? :false
LogAura: Warning: Client         ,UAuraGameplayAbility::EndAbility ,Is WaitGamplayEventFinished?:true
LogAura: Warning: DedicatedServer,UAuraGameplayAbility::OnMontageBlendOut ,Is WaitGamplayEventFinished? :false
LogAura: Warning: DedicatedServer,UAuraGameplayAbility::EndAbility ,Is WaitGamplayEventFinished?:true
```
可以看到 task 并没有结束，但就是收不到 蒙太奇发出的事件通知。而且是有概率的。

![alt text](<../assets/images/4GAS Trap_image-2.png>)

Notify Trigger Chance =1, 设置通知概率是100%执行。

TirggerWeightThreshold = 0.000001 这个值是说，动画混合了多少比重后，允许触发该Notify。越小越容易触发。

这两个值都是正确的设置的，那么问题就出在 **MontageNotifyTickType**上。经过多次测试，改成branchingpoint 模式，就一直稳定触发该Notify。

内部注释是这样说的：

```cpp
/** Ticking method for AnimNotifies in AnimMontages. /
UENUM()
namespace EMontageNotifyTickType
{
enum Type : int
{
/* Queue notifies, and trigger them at the end of the evaluation phase (faster). Not suitable for changing sections or montage position. /
Queued,
/* Trigger notifies as they are encountered (Slower). Suitable for changing sections or montage position. */
BranchingPoint,
};
}
```
Queued vs BranchingPoint:

- Queued: 通知被排队，并在评估阶段结束时触发。这种方式更快，但不适合改变节段或蒙太奇位置。
- BranchingPoint: 通知在遇到时立即触发。虽然较慢，但适合改变节段或蒙太奇位置。

太简短，看看官方文档的版本：
> https://dev.epicgames.com/documentation/en-us/unreal-engine/animation-notifies-in-unreal-engine

大致就是说：Queued模式效率高，但容忍有不精确的情况，BranchingPoint模式低效，但精确。但也没有解释为什么会有概率丢失。

::: details AI 总结


**Montage Tick Type 有两个选项**：

**Queued（队列模式）:**

特点：异步、性能更好，但精确度较低。
工作方式：通知被添加到队列中，在评估阶段结束时一起处理。

适用场景：

对帧精确度要求不高的情况。
通知执行有轻微帧不准确是可以接受的。
适合用于非关键的视觉或音效触发。

**优点**：性能开销较小，适合处理大量非关键通知。

**缺点**：可能导致轻微的时间不准确，不适合精确的游戏逻辑控制。

**Branching Point（分支点模式）:**

特点：同步、精确度高，但性能开销较大。

工作方式：通知在遇到时立即执行，确保最大的帧精确度。

适用场景：

需要精确控制执行时间的情况。
通知用于执行其他事件的受控序列。
用于做出影响游戏玩法的决策。
例如：基于此通知进行分支决策。

**优点**：

  - 提供最高的帧精确度。
  - 适合复杂的游戏逻辑和精确的事件序列。

**缺点**：相对较高的性能开销，特别是在处理大量通知时。

选择建议：

对于大多数视觉和音效通知，Queued 模式通常就足够了。
对于涉及重要游戏逻辑、需要精确时间控制的通知，或者在通知基础上进行复杂决策的情况，应该使用 Branching Point 模式。
在开发过程中，如果发现通知的时间精确度问题，可以考虑从 Queued 切换到 Branching Point。

总结：

**Queued**：适合一般用途，性能好但精确度较低。
**Branching Point**：适合需要高精度控制的情况，特别是在影响游戏玩法或进行复杂决策时。
asdf
:::  