title:Gas Common Pitfalls
comments:true

## GASComponent

### gameplaytag 和 gameplay effect 的 replication policy
- **过早调用`waitGameplayTag`会导致注册失败**：The initialization of GASComponent is after `BeginPlay`. If a node like `WaitGameplay` is called after `BeginPlay`, it usually can't register events to GAS because the GAS Component is null. This applies to both the server and client. 所有应该在on commponent created 之后调用。
   ![alt text](<../assets/images/4GAS Trap_image.png>)

- `WaitGameplay`, the event "WaitGameplay" will be register to all roles: ROLE_Authority (server), ROLE_AutonomousProxy (your character),So, always pay attention to which role the current code is running under. 由于gameplaytag 是多端复制的，所以只要监听正确，所有端都能接受到 waitgampeplay event.如果NPC不需要这个回调，要当心。

- 多人游戏里，如果角色在不同client的视角里表现不一致（**自己能看到，别人看不到**），可能是对GE网络复制的理解错误，导致写出了错误的逻辑:
  In a multiple player game, the Player's GE Replicate Mode is Mixed, while NPC is set to Minimal. 这说明，“当前玩家”的GE只复制到“当前玩家”的电脑上，同时玩家电脑里的NPC不会接受到任何GE网络复制。
   ![alt text](<../assets/images/4GAS Trap_image-1.png>)
  so the ROLE_SimulatedProxy (your game partner) will not have any Active Effects because the server does not replicate GE to them. So in this case, the node `Get Active Effects with All Tags` will always return an empty array. The same goes for NPCs.也就是说，你无法通过这个方法来获取到其他玩家（或者NPC）的Active Gameplay Effects。它只能获得当前玩家active GEs.

 - 总结，通过GameplayTag来判断某个角色是否有激活的GE是最妥当的，因为它是多端复制的，而无法通过actor 是否有激活的GE来判断。


### GameplayTask

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

!!! note 
    很多时候会想当然地认为，改变量会在构造函数里被引用，所以只写局部变量，导致类似的错误。
 