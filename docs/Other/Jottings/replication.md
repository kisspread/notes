---
title: Replication
comments:  true
---

## 资料搜集

### Network Prediction plugin
![alt text](../../assets/images/jottings_image.png)
从提交记录上看，该插件2021年已经停更，后面的都是小改动。主程序员(Dave Ratti)已经离职epic.

NP插件需要和Mover 2.0 配合使用会比较好。

GAS  和 CMC 都和 NP 不太兼容，必须考虑 NP 插件中存在的缓冲时间。如果不这样做，所有 CMC/GAS 功能的执行速度都会比 NP 代码更快，并且您将看到明显的执行延迟。



The Network Prediction plugin (which can also be found in Engine/Plugins/Runtime/NetworkPrediction) – Sign up here if you don’t have Git access – is available in a default Unreal Engine installation but is still experimental at the time of writing this article and progress has been halted due to the main programmer (Dave Ratti) no longer working at Epic. Through personal extensive testing it is in a good state to be used though and solves a few of the issues mentioned here such as packet buffering/ordering, client/server frame syncing and desync/reconciling tools along with providing some other nice to have features. Epic have mentioned on UDN that they’re still working on a version of the Character Movement Component which is compatible with the NP plugin but it is yet to be announced (It might be the Mover 2.0 component?). It’s also worth mentioning that if you’re using the Gameplay Ability System in your project it will also not be compatible and you’ll have to create your own alternative using the NP plugin if you want accurate results.

Note: If you do try to use this plugin alongside GAS or CMC you’ll have to account for the buffer time which exists in the NP plugin. If you don’t all CMC/GAS functionality will execute sooner than NP code and you’ll see a visible delay in execution.

[source](https://www.kierannewland.co.uk/the-problems-with-unreal-engines-default-networking/)


[Using The Network Prediction Plugin In Unreal
](https://www.kierannewland.co.uk/using-the-network-prediction-plugin/)

### Iris

Iris 复制系统对比旧复制系统，性能更好，拓展性更强，维护更容易。

在大量玩家的游戏里，他对服务端更加友好，内存占用减少，能支持更多的玩家。

官方建议尽可能避免创建自定义序列化程序，因为未来的Iris版本可能会提供更详细的属性来描述如何复制属性，包括要使用的序列化程序、该序列化程序的参数以及复制条件。


It is recommended to avoid creating custom serializers when possible. A planned feature for Iris is to provide more detailed attributes to describe how properties are replicated, including which serializer to use, parameters for that serializer, and replication conditions. The goal is to give projects greater control over their replicated data without the need to write custom serializers, as well as allowing for features such as delta compression to be automatically supported.

[source](https://dev.epicgames.com/community/learning/tutorials/z08b/unreal-engine-iris-faq)


### GAS Prediction

Dave Ratti 在2019年回答了GAS存在的一些问题，这里是第8个提问和回答。他认为GAS已经非常稳定，当前版本的GAS不会有大改动。长远地看，如果有V2版本将会统一客户端预测，比如CMC；支持GE移除的预测，支持延迟高延迟的GE重新对账；优化RPC网络数据，把堡垒之夜中进行了大量优化带给UE。

21年左右Dave Ratti已经离职。

目前的情况，现在还有2个月就2025了，Mover 2.0 应该是新的CMC，还是实验性；NP插件是beta 版本。
Iris 在5.4 中仍将标记为实验性。GAS没啥新的动静，估计等待上面这些大哥稳定，才会有有改动吧。

What is Epic’s roadmap for the GameplayAbilitySystem plugin? Which features does
Epic plan to add in 2019 and beyond?

>We feel that overall the system is pretty stable at this point and we don’t have anyone working
on major new features. Bug fixes and small improvements occasionally are made for Fortnite or
from UDN/pull requests, but that is it right now.
Longer term, I think we will eventually do a “V2” or some big changes. We learned a lot from
writing this system and feel we got a lot right and a lot wrong. I would love a chance to correct
those mistakes and improve some of the fatal flaws that were pointed out above.
If a V2 was to ever come, providing an upgrade path would be of utmost importance. We would
never make a V2 and leave Fortnite on V1 forever: there would be some path or procedures
that would automatically migrate as much as possible, though there would still almost certainly
be some manual remaking required.
The high priority fixes would be:
● Better interoperability with the character movement system. Unifying client prediction.
● GE removal prediction (question #4)
● GE latency reconciliation (question #8)
● Generalized network optimizations such as batching RPCs and proxy structures. Mostly
the stuff that we’ve done for Fortnite but find ways to break it down into more
generalized form, at least so that games can write their own game specific optimizations
more easily.
The more general refactor type of changes I would consider making:
● I would like to look at fundamentally moving away from having GEs reference
spreadsheet values directly, instead they would be able to emit parameters and those
parameters could be filled by some higher level object that is bound to spreadsheet
values. The problem with the current model is that GEs become unsharable due to their
tight coupling with the curve table rows. I think a generalized system for
parameterization could be written and be the underpinning of a V2 system.
● Reduce number of “policies” on UGameplayAbility. I would remove ReplicationPolicy
InstancingPolicy. Replication is, imo, almost never actually needed and causes
confusion. InstancingPolicy should be replaced instead by making
FGameplayAbilitySpec a UObject that can be subclassed. This should have been the
“non instantiated ability object” that has events and is blueprintable. The
UGameplayAbility should be the “instanced per execution” object. It could be optional if
you need to actually instantiate: instead “non instanced” abilities would be implemented
via the new UGameplayAbilitySpec object.
● The system should provide more “middle level” constructs such as “filtered GE
application container” (data drive what GEs to apply to which actors with higher level
gameplay logic), “Overlapping volume support” (apply the “Filtered GE application
container” based on collision primitive overlap events), etc.These are building blocks that
every project ends up implementing in their own way. Getting them right is non trivial so I
think we should do a better job providing some basic implementations.
● In general, reducing boilerplate needed to get your project up and running. Possibly a
separate module “Ex library” or whatever that could provide things like passive abilities
or basic hitscan weapons out of the box. This module would be optional but would get
you up and running quickly.
● I would like to move GameplayCues to a separate module that is not coupled with the
ability system. I think there are a lot of improvements that could be made here.
This is only my personal opinion and not a commitment from anyone. I think the most realistic
course of action will be as new engine tech initiatives come through, the ability system will need
to be updated and that will be a time to do this sort of thing. These initiatives could be related to
scripting, networking, or physics/character movement. This is all very far looking ahead though
so I cannot give commitments or estimates on timelines.



好的，根据您提供的网址信息，我对 Network Prediction 插件、GAS Prediction 和 Iris 这三者的关系进行分析，并探讨您在使用 GAS 后可能面临的网络框架更新问题。

## 三者关系分析

1.  **GAS Prediction (GAS 内置的预测功能)**:

      * 这并非一个独立的系统，而是 **Gameplay Ability System (GAS) 内部自带的网络预测机制**。它主要负责预测 `GameplayEffect` 的添加/移除和 `GameplayAbility` 的执行。
      * 根据文章信息，其主要开发者 Dave Ratti 已于2021年离开 Epic，导致原计划中旨在统一客户端预测、支持预测性移除 GE、优化网络数据的 "V2" 版本前景不明。这意味着 **当前版本的 GAS 预测功能相对稳定，但短期内可能不会有重大更新**。

2.  **Network Prediction (独立的预测插件)**:

      * 这是一个 **实验性 (Experimental) 的、通用的客户端预测插件**。它的目标是提供一个比 GAS 更底层的、更通用的预测框架，例如与新的 `Mover 2.0` 组件结合使用。
      * **关键问题**：该插件与 GAS 和传统的 Character Movement Component (CMC) **不完全兼容**。因为它使用的缓冲机制可能导致 GAS/CMC 的功能执行延迟。
      * **现状**：由于核心开发者离职，该插件的开发也已于2021年停滞。虽然文章作者（不是我）认为其解决了报文缓冲/排序、客户端/服务器帧同步等问题，状态尚可，但其 **实验性质和兼容性问题** 是一个很大的风险。

3.  **Iris (新一代复制系统)**:

      * Iris 是一个 **全新的、高性能的数据复制系统 (Replication System)**，旨在替代 UE 默认的、旧的复制系统。
      * 它的重点在于 **如何高效地序列化数据并通过网络传输**，而不是如何做客户端预测。它通过更优的数据结构和算法，显著降低了服务器的内存占用和性能开销，尤其适合大量玩家和复制对象的场景。
      * Iris 和 GAS/Network Prediction 是 **不同层面的东西**。Iris 是底层的“运输系统”，而 GAS Prediction 和 Network Prediction 是上层的“乘客”（具体的预测逻辑）。你可以用 Iris 来承载 GAS 的数据复制，也可以用旧的复制系统。

**关系总结:**

  * **GAS Prediction** 是 GAS 框架内的**上层应用逻辑预测**。
  * **Network Prediction** 是一个独立的、实验性的**通用预测框架**，试图提供更底层的预测能力，但与 GAS 兼容性不佳且已停止开发。
  * **Iris** 是一个底层的**数据传输系统**，负责将数据（包括 GAS 的数据）高效地在服务器和客户端之间同步。它与你使用哪种预测逻辑没有直接的冲突关系。

### 使用 GAS 后可能面临的网络框架更新问题

如果决定全面使用 GAS，那么在网络框架层面需要考虑以下几点：

1.  **预测方案的选择：大概率只能依赖 GAS 自带的预测**

      * 由于 `Network Prediction` 插件已停止开发并与 GAS 存在兼容性问题，**强烈不建议**将它作为新项目的基础。这意味着，客户端预测将主要依赖 GAS 自身提供的能力。
      * 需要接受 GAS 当前的预测限制，比如对 `GameplayEffect` 移除的预测支持不完善等问题。未来这些问题能否得到官方解决，存在不确定性。您可能需要自己编写一些代码来绕过或增强这些限制。

2.  **底层复制系统的选择：是否要升级到 Iris？**

      * 这是一个独立于 GAS 的决策，但却是一个重要的架构决策。
      * **如果项目...**
          * 是一个新项目。
          * 预计有大量的玩家或网络对象（例如，大世界MMO、百人对战等）。
          * 对服务器性能和带宽有很高的要求。
          * **那么，强烈建议您直接采用 Iris**。它是未来的方向，性能优势巨大。虽然上手有一定学习成本，但长期来看是值得的。
      * **如果项目...**
          * 是一个已经在使用旧复制系统的老项目。
          * 玩家数量不多（例如，4-8人的合作游戏）。
          * 开发周期紧张，没有时间去学习和适配新的复制系统。
          * **那么，可以继续使用 UE 默认的复制系统**。它与 GAS 的配合已经经过了大量项目的验证，非常成熟稳定。

### 结论与建议

对于团队来说，在决定使用 GAS 后，网络框架的核心决策路径如下：

1.  **预测层**：基本确定使用 **GAS 内置的预测功能**。放弃使用实验性的 `Network Prediction` 插件，并为 GAS 现有的一些预测局限性做好技术预案。
2.  **复制层**：评估项目需求，在 **UE 默认复制系统** 和 **Iris 复制系统** 之间做出选择。这是一个关于性能、可扩展性和开发成本的权衡。对于新项目，尤其是对性能要求高的项目，Iris 是更优选。

总而言之，采用 GAS 意味着您在“游戏逻辑如何预测”上做出了选择。接下来，您还需要为这些被预测的数据选择一个“运输系统”（默认复制系统或 Iris），这将是您需要做的下一个关键决策。