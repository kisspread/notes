title: Subsystem 

了解 subsystem的构建过程非常重要，比如很多Subsystem不需要手动创建和调用，只需直接继承它，运行时就会被调用。Subsystem本身是一套生命周期绑定机制，就像Android的Activity有非常多的生命周期，如果功能都写在activitiy里面，就会变得非常臃肿，难以迁移和优化, 于是Android推出很多 lifecycle 关联机制，这个subsystem是异曲同工的，不过我感觉subsystem的设计理念更加优雅。
这里简单记录

更多参考:[https://www.cnblogs.com/shiroe/p/14819721.html](https://www.cnblogs.com/shiroe/p/14819721.html)

---

### Subsystem 初始化
- 获取派生类的工具方法
    ```cpp
    /**
    * Returns an array of classes that were derived from the specified class.
    *
    * @param	ClassToLookFor				The parent class of the classes to return.
    * @param	Results						An output list of child classes of the specified parent class.
    * @param	bRecursive					If true, the results will include children of the children classes, recursively. Otherwise, only direct decedents will be included.
    */
    COREUOBJECT_API void GetDerivedClasses(const UClass* ClassToLookFor, TArray<UClass *>& Results, bool bRecursive = true);
    ```

- 递归获取派生类，加入初始化列表
    ```cpp title='SubsystemCollection.cpp'
    TArray<UClass*> SubsystemClasses;
    GetDerivedClasses(BaseType, SubsystemClasses, true);

    for (UClass* SubsystemClass : SubsystemClasses)
    {
        AddAndInitializeSubsystem(SubsystemClass);
    }
    ```
- 开始初始化，调用该类CDO 的ShouldCreateSubSystem 来判断是不是要实例化。
    ```cpp
    const USubsystem* CDO = SubsystemClass->GetDefaultObject<USubsystem>();
    if (CDO->ShouldCreateSubsystem(Outer))
    {
        USubsystem* Subsystem = NewObject<USubsystem>(Outer, SubsystemClass);
        SubsystemMap.Add(SubsystemClass,Subsystem);
        Subsystem->InternalOwningSubsystem = this;
        Subsystem->Initialize(*this);
    ```
- 如果只想最外层的的派生类被实例化，可以参考：
    ```cpp title='UCommonUIActionRouterBase.cpp'
    bool UCommonUIActionRouterBase::ShouldCreateSubsystem(UObject* Outer) const
    {
        TArray<UClass*> ChildClasses;
        GetDerivedClasses(GetClass(), ChildClasses, false);

        UE_LOG(LogUIActionRouter, Display, TEXT("Found %i derived classes when attemping to create action router (%s)"), ChildClasses.Num(), *GetClass()->GetName());

        // Only create an instance if there is no override implementation defined elsewhere
        return ChildClasses.Num() == 0;
    }
    ```