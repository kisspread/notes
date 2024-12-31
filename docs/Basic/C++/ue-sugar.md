---
title: UE5语法之痛
comments: true
---
# UE5语法之痛

在研究 Unreal Engine 的源码时,经常会看到类似这样的代码:

```cpp
Algo::Transform(ObjectPathStrings, Paths, UE_PROJECTION(FSoftObjectPath));
```

PROJECTION 投射？ 是什么鬼？ 看起来像类型转换，为什么起一个如此奔放的名字？

这其实是 Unreal Engine 中的投影宏,用于简化类型转换和成员访问操作:

UE_PROJECTION(Type):
```cpp
// 等价于 [](const auto& X) { return Type(X); }
Algo::Transform(Source, Dest, UE_PROJECTION(Type));
```

UE_PROJECTION_MEMBER(Member):
```cpp
// 等价于 [](const auto& X) { return X.Member; }
Algo::Transform(Source, Dest, UE_PROJECTION_MEMBER(Member)); 
```

使用投影宏比手写 lambda 更简洁。

需要 transform 对象或访问成员时,这两个宏很有用。它们主要用在算法和容器操作中。

让我们对比 Kotlin 的实现，毕竟它纯原生语法，更好理解:

```kotlin
// 字符串列表转换为路径对象
val paths = strings.map { SoftObjectPath(it) }

// 访问对象成员
val names = users.map { it.name }

// 类型转换
val numbers = strings.map(String::toInt)

// 多重转换和过滤
val validPaths = strings
    .filter { it.isNotEmpty() }
    .map { SoftObjectPath(it) }
```

再看看投射的实现:

```cpp
#define UE_PROJECTION_MEMBER(Type, FuncName) \
	[](auto&& Obj, auto&&... Args) -> decltype(auto) \
	{ \
		return UE::Core::Private::DereferenceIfNecessary<Type>(Forward<decltype(Obj)>(Obj), &Obj).FuncName(Forward<decltype(Args)>(Args)...); \
	}
```        

这种差异让人不禁感慨。UE 开发者们太难了。

## 历史包袱

C++ 作为一门诞生于1983年的语言,虽然在不断进化,但许多现代特性的添加都需要考虑向后兼容。而 UE 引擎本身也有20多年历史,代码库庞大,重构成本高昂。

## 权衡之道

Epic 团队选择用宏来简化这些常见操作:
- UE_PROJECTION 用于类型转换
- UE_PROJECTION_MEMBER 用于成员访问

这是一种务实的做法。虽然不如现代语言优雅,但至少让代码不那么冗长。

 

也许有一天,我们能在 UE 中写出如 Kotlin 一般优雅的代码。在此之前,且行且珍惜这些前辈们为我们铺就的道路。