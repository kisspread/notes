# EQS 问题记录

## EQS生成点的逻辑，和NavMesh的强关联的

```cpp
ProjectAndFilterNavPoints(NavLocations, QueryInstance);
StoreNavPoints(NavLocations, QueryInstance);
```
图里这些子类型，如`UEnvQueryGenerator_OnCircle`，必须基于NavMesh来做
![alt text](../../assets/images/EQS_image.png)

如果游戏不是基于NavMesh做导航，图里这些的Generator全部没法用

## EQS的Graph

这个Graph有些迷惑，根本算不上Graph，几乎没有图该有的特征。
![alt text](../../assets/images/EQS_image-1.png)
最应该加的功能，类似PCG的按D调试，它却没有。

![alt text](../../assets/images/EQS_image-2.png)
只有一个作用，打草稿+注释，白线相当于enable，直观些。

## EQS生成器的蓝图子类存在悬垂指针 (Dangling Pointer)

该类型：
```cpp
UCLASS(Abstract, Blueprintable, MinimalAPI)
class UEnvQueryGenerator_BlueprintBase : public UEnvQueryGenerator
```

报错崩溃的位置：

```cpp
void FEnvQueryInstance::ExecuteOneStep(double TimeLimit)
{
	if (!Owner.IsValid())
	{
		MarkAsOwnerLost();
		return;
	}

	check(IsFinished() == false);

	if (!Options.IsValidIndex(OptionIndex))
	{
		NumValidItems = 0;
		FinalizeQuery();
		return;
	}

	SCOPE_CYCLE_COUNTER(STAT_AI_EQS_ExecuteOneStep);

	FEnvQueryOptionInstance& OptionItem = Options[OptionIndex];
	double StepStartTime = FPlatformTime::Seconds();

	const bool bDoingLastTest = (CurrentTest >= OptionItem.Tests.Num() - 1);
	bool bStepDone = true;
	bIsCurrentlyRunningAsync = false;
	CurrentStepTimeLimit = TimeLimit;
	//found a bug here, OptionItem.Generator is null
	 if (!IsValid(OptionItem.Generator))
	 {
		 // generator is null, just return
	 	UE_LOG(LogEQS, Warning, TEXT("Generator is null"));
	 	NumValidItems = 0;
	 	FinalizeQuery();
	 	return;
	 }

	if (CurrentTest < 0)
	{
		bool bRunGenerator = true;
#if USE_EQS_DEBUGGER
		int32 LastValidItems = 0;
#endif
		if (!OptionItem.Generator->IsCurrentlyRunningAsync())
		{
```

程序执行到if (!OptionItem.Generator->IsCurrentlyRunningAsync()) 出了报错崩溃。

编辑器里面，测试的时候有个一个旧实例为 Generator_A，
点击蓝图的“编译”按钮时，UE的后台执行了“热重载 (Hot Reload)” 或更准确地说是“蓝图类重建 (Blueprint Class Recompilation)”。然后，创建一个全新的UClass和新的实例 Generator_B。这个过程也叫"Re-instancing"（实例重构）。
但指针没有更新，FEnvQueryInstance 是一个普通的C++ struct，它并不知道蓝图发生了“身份替换”。它内部的 Generator 指针仍然指向 Generator_A 的内存地址，导致了内存访问冲突，编辑器崩溃。

最可疑的部分就是这个成员变量：
```cpp
private:
    /** this is valid and set only within GenerateItems call */
    mutable FEnvQueryInstance* CachedQueryInstance;

```
它是一个原始指针 (Raw Pointer): FEnvQueryInstance*。它不是 TObjectPtr 或其他智能指针，所以它无法被GC（垃圾回收）系统自动置空。FEnvQueryInstance 本身也不是一个 UObject，它只是一个普通的 struct，所以更谈不上GC管理.

它的生命周期注释非常重要: this is valid and set only within GenerateItems call。这句话是引擎开发者留下的警告，意思是：“这个指针只在 GenerateItems 函数执行期间有效。一旦函数返回，不要相信这个指针指向的任何东西！”



没啥比较好的解决办法，毕竟这个类是引擎内部，修改引擎源代码可能会导致兼容问题，并且修改就得以后都要关注这个类的更新。

我的解决办法是，一旦相关的蓝图之类发生了变化，就不要立马测试，不然编辑器会崩溃。可以先打开另一张地图专门测试这个EQS，这会强制UE重新实例化，解决悬垂指针的问题。

引擎的EQS代码太老了，遇到这种问题，正确的做法应该是用智能指针。

让C++代码对热重载更具抵抗力 (Making C++ More Resilient)
```cpp
// 旧的方式 (Old way, prone to dangling pointers)
UPROPERTY()
UEnvQueryGenerator* MyGenerator;

// 现代UE5的方式 (Modern UE5 way, much safer)
UPROPERTY()
TObjectPtr<UEnvQueryGenerator> MyGenerator;

```

`TObjectPtr` 是一个智能指针包装器 (smart pointer wrapper)，它能被垃圾回收系统 (Garbage Collection, GC) 感知。当它指向的 `UObject` 被销毁时，`TObjectPtr` 会**自动被置为 `nullptr`**！

这就意味着，如果 `FEnvQueryInstance` 内部使用的是 `TObjectPtr<UEnvQueryGenerator>`，那么在蓝图编译导致旧Generator被销毁后，这个指针会自动变空。下一次访问时，`IsValid()` 检查就会失败，程序会走你写的安全退出逻辑，而不是崩溃。