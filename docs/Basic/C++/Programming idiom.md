---
title: UE Programming idiom
comments: true
---
 
# 这里记录一些 常见的UE/C++ 编程习惯，设计模式

## RAII

RAII (Resource Acquisition Is Initialization) 是一种 C++ 编程习惯，由 Bjarne Stroustrup (C++之父)  在 1980 年提出。全称资源获取即初始化,它是在一些面向对象语言中的一种惯用法。RAII 适合管理临时资源（如锁、事务等），强调资源使用的确定性

### RAII 的主要特点：

- 资源获取与对象生命周期绑定：资源在构造时获取，在析构时释放
- 自动管理：不需要手动释放资源
- 异常安全：即使发生异常，析构函数也会被调用，确保资源释放

### UE 中常见的 RAII 模式：

GAS 里，用于保护 Abilites 列表的 “资源锁”，实现原理类似智能智能的引用计数，区别在于RAII离开作用域时就会自动释放资源，计数器自动减一，当计数为0时，释放资源。

#### UE GAS里使用宏来保护Ability列表：

涉及到对Ability列表操作的时候的，都用FScopedAbilityListLock 来确保安全。

UE 还提供了创建它的宏： ABILITYLIST_SCOPE_LOCK()  

![alt text](<../../assets/images/Programming idiom_image-1.png>)

#### FScopedAbilityListLock 实现过程解析

```cpp
class FScopedAbilityListLock
{
public:
    // 构造函数中获取资源
    FScopedAbilityListLock(UAbilitySystemComponent& InAbilitySystemComponent)
        : AbilitySystemComponent(InAbilitySystemComponent)
    {
        AbilitySystemComponent.IncrementAbilityListLock(); // 获取锁
    }

    // 析构函数中释放资源
    ~FScopedAbilityListLock()
    {
        AbilitySystemComponent.DecrementAbilityListLock(); // 释放锁
    }

private:
    UAbilitySystemComponent& AbilitySystemComponent;
};
```

每创建一个FScopedAbilityListLock 对象，都会增加 AbilitySystemComponent 的 AbilityScopeLockCount，当对象销毁时，会减少 AbilityScopeLockCount。当 AbilityScopeLockCount 为0时， 才会执行所有AbilityPendingAdds 和 AbilityPendingRemoves，来确保列表操作是原子的，也就是确保for循环，删除操作是安全的。


UAbilitySystemComponent 内部对Ability列表的操作，全部是添加到 pending列表里。所以有AbilityPendingAdds 和 AbilityPendingRemoves，他们只进行add即可。因为锁的作用域结束后，会来这里“用完”pending，并清空他们。

当 AbilityScopeLockCount 为0时的部分关键代码：
![alt text](<../../assets/images/Programming idiom_image.png>)

所以，FScopedAbilityListLock 作用
- 防止在遍历 Ability 列表时移除 Ability
- 保护 Ability 系统组件中的关键操作，确保原子性
- 处理异步操作和并发访问的安全性


另外上面这段代码的注释还提到了：
- 优先级问题：
  当同时存在"添加能力"和"清除所有能力"的操作时，系统优先执行"清除所有能力"
  这是基于一个假设：ClearAllAbilities() 通常用于生命周期结束时的清理工作
- 特殊情况：
  可能存在一些情况，开发者在同一个能力作用域锁中故意调用：
   - 先调用 ClearAllAbilities()
   - 然后调用 GiveAbility()

  比如：一个能力的功能是"移除所有能力并授予一个新能力"

当在同一个作用域锁中同时调用 ClearAllAbilities() 和 GiveAbility() 时，会有警告：

```cpp
if (bAbilityPendingClearAll)
{
    ClearAllAbilities();

    if (AbilityPendingAdds.Num() > 0)
    {
        ABILITY_LOG(Warning, TEXT("GiveAbility and ClearAllAbilities were both called within an ability scope lock. Prioritizing clear all abilities by ignoring pending adds."));
        AbilityPendingAdds.Reset(); // 关键点：直接清空了待添加列表
    }

    // Pending removes are no longer relevant since all abilities have been removed
    AbilityPendingRemoves.Reset();
}
```

目前的解决办法：应该在 ClearAllAbilities() 完成后，在新的作用域锁中调用 GiveAbility()









