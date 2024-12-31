---
title: UE C++ Actor Usage
comments: true
---

### Actor Lifecycle

来自官网生命周期区别图：
![alt text](../../assets/images/actor_image.png)

总得来说，不同方式创建的actor，会经历不太相同的生命周期。

1. 在关卡里播放，会经历一个 复制事件。
1. 把actor拖进去关卡编辑器，会经历 加载事件。
1. 代码调用 spawn actor，会经历 spawn 事件。
1. 延迟spawn actor，会经历 延迟spawn 事件。

----


### actor component lifecycle
有两个比较常用的回调
#### OnRegister
这个函数开始调用，说明 component已经可用了，各种参数都有值，不管是什么模式下创建的actor，都会通知component 已经准备好的通知。所以各种设置值，都可以在里面完成。

#### InitializeComponent
相当自己决定注册合适完成。
首先，bWantsInitializeComponent = true
然后在完成自己要的初始化后，调用 RegisterComponent();进行通知。

```cpp
	/**
	 * Initializes the component.  Occurs at level startup or actor spawn. This is before BeginPlay (Actor or Component).  
	 * All Components in the level will be Initialized on load before any Actor/Component gets BeginPlay
	 * Requires component to be registered, and bWantsInitializeComponent to be true.
	 */
	ENGINE_API virtual void InitializeComponent();
 ```