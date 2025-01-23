---
title: UE C++ Usage
comments: true
---

## 类型转换

### static_cast

效率高，但不安全。

`static_cast` 的转换逻辑完全由编译器在编译阶段决定，不涉及任何运行时检查。它的本质是告诉编译器：

> “我知道这两个类型在逻辑上是兼容的，请直接按目标类型重新解释这段内存。”

- **`static_cast` 的潜在危险**
```cpp
class Base { /* 无虚函数 */ };
class Derived : public Base { int data; };

Base* b = new Base();
Derived* d = static_cast<Derived*>(b); // 编译通过，但危险！
d->data = 42; // 未定义行为：访问不存在的内存！

// 另外 ，如果是向上转换，会隐藏子类的成员的可视性。 
Derived* d = new Derived();
Base* b = static_cast<Base*>(d); // 上行转换
// 内存布局
|-----------------------------|
| Base 子对象（空）            | <-- b 指向这里
|-----------------------------|
| Derived::data (int)         | <-- data 实际存在，但无法通过 b 直接访问
|-----------------------------|
```
- **底层行为**：
  - 编译器直接将 `b` 的地址当作 `Derived*` 使用。
  - `Derived` 的内存布局要求 `data` 成员位于基类子对象之后，但 `Base` 对象并没有这部分内存。
  - 写入 `d->data` 会覆盖未知内存区域，可能导致程序崩溃或数据损坏。

### dynamic_cast
效率低但安全。

`dynamic_cast` 的转换逻辑**依赖运行时类型信息（RTTI）**，通过查询对象的虚函数表（vtable）中的类型信息，验证转换的合法性

- **`dynamic_cast` 的安全性**

```cpp
class Base { virtual void f() {} }; // 有虚函数
class Derived : public Base {};

Base* b = new Base();
Derived* d = dynamic_cast<Derived*>(b); // 返回 nullptr
if (d) {
    d->doSomething(); // 安全：不会执行
}
```
- **底层行为**：
  - 通过 `b` 的 vptr 找到 RTTI，发现实际类型是 `Base`，与 `Derived` 无继承关系。
  - 返回 `nullptr`，避免非法访问。

---

### **底层对比总结**
| 特性                  | `static_cast`                            | `dynamic_cast`                          |
|-----------------------|------------------------------------------|------------------------------------------|
| **类型检查时机**       | 编译时（依赖程序员知识）                 | 运行时（依赖 RTTI）                      |
| **指针/引用调整**      | 仅处理编译时已知的偏移（如上行转换）     | 运行时计算实际偏移（如多重继承）         |
| **虚函数表依赖**       | 不需要                                   | 必须存在（否则无法获取 RTTI）            |
| **典型指令**           | 直接赋值或简单算术运算（如类型截断）     | 调用运行时库函数（如 `__dynamic_cast`）  |
| **安全性**             | 不安全（除非程序员确保正确性）           | 安全（但可能因 RTTI 未开启而失败）       |

---


## lambda 捕获
这里记录一个lambda捕获问题作为lambda捕获的谨记内容。

起初，这里是用按值捕获，AddLambda([this,&AttributeInfo]。因为外部值也是一个引用，引用其实就是一个指针，感觉按值捕获也是一样的。然后发生很诡异的事情，
BroadcastInfo 里 tag和 value都能正常设置。但AttributeChangeDelegate（这是一个动态回调）无法正确执行。

期间一直以为是const 修饰的锅，因为我把AttributeChangeDelegate设置为mutable, 感觉是因为mutable的问题。由于上面两个参数正常，我一直没有怀疑这个lambda捕获的问题。

讲道理的说，const FAttributeInfo& AttributeInfo按值捕获获得是值的副本，离开这for的作用域后原本的“值”就可能被回收。但副本指向的也是原始的AttributeInfo，理应都一样才对，所以我非常不解。 如果有人知道真实原因，请告知。

总的来说，lambda的使用还是要谨慎。

```cpp
void UMenuWidgetController::BindCallBacksToDependence()
{
	for (const FAttributeInfo& AttributeInfo : GetAllAttributes())
	{
		AuraASC()->GetGameplayAttributeValueChangeDelegate(AttributeInfo.AttributeAccessor).AddLambda([this,&AttributeInfo](const FOnAttributeChangeData& OnAttributeChangeData)
			{
				BroadcastInfo(AttributeInfo);
			}
		);
	}
}

void UMenuWidgetController::BroadcastInfo(const FAttributeInfo& AttributeInfo)
{
	const FAttributeInfo& ResultAttr = FindAttributeInfoByTag(AttributeInfo.AttributeTag);
	//update value in data assets.
	ResultAttr.AttributeValue = AttributeInfo.AttributeAccessor.GetNumericValue(AuraAS());
	AttributeInfo.AttributeChangeDelegate.ExecuteIfBound(ResultAttr.AttributeValue);
	
}
```

[更多UE使用lambda的注意事项](https://neil3d.github.io/unreal/mpp-lambda.html)

- 延迟调用的lambda（包括delegates，BindLambda） 要注意悬空引用，离开作用域后，部分已捕获的引用可能被析构。
- 捕获Uobject类型时，尽量用 弱引用TWeakObjectPtr，因为当 Lambda 捕获一个 UObject 指针时，它会创建一个强引用，只要这个lambda一直存在，就会导致Uobject无法正确回收。




## 集合
RemoveSwap 要删除的元素，和末尾交换位置，然后删除它，然后继续找下一个。这种方式不考虑元素的顺序，数组不会整个重排，对比RemoveAt效率高。RemoveSingleSwap是单个的版本。
``` cpp
	/**
	 * Removes all instances of a given item from the array.
	 *
	 * This version is much more efficient, because it uses RemoveAtSwap
	 * internally which is O(Count) instead of RemoveAt which is O(ArrayNum),
	 * but does not preserve the order.
	 *
	 * @param Item The item to remove
	 * @param AllowShrinking Tell if this function can shrink the memory in-use if suitable.
	 *
	 * @returns Number of elements removed.
	 * @see Add, Insert, Remove, RemoveAll, RemoveAllSwap
	 */
	SizeType RemoveSwap(const ElementType& Item, EAllowShrinking AllowShrinking = EAllowShrinking::Yes)
```
还有RemoveAllSwap，for循环对数组长度敏感，如果for里面涉及到删除元素的操作，用RemoveAllSwap是更好的选择。


## 各种Delegate和Event
更多可以参考这个：[https://www.cnblogs.com/kekec/p/10678905.html](https://www.cnblogs.com/kekec/p/10678905.html)
### Delegate 和 Event 
Delegate就是回调， Event是订阅者-观察者模型，支持多个观察者。

- 只能在C++ 使用
- 不能序列化
- 开销小
### dynamic 前缀的Delegate 和 Event 
动态就是蓝图也可以调用，支持两种绑定方式，BindUFunction 和 BindDynamic，其中BindDynamic是一个macro

- 蓝图可以用
- 可序列化
- 开销大

### MULTICAST 前缀的Delegate
多播delegate 就是另一个版本的 Event，Event本身就是多播的，所以没有这个前缀。和Event的区别是，Event需要声明在哪个类里面使用，而多播delegate是全局通用的。MULTICAST前缀让Delegate也变成了订阅者-观察者模型

### 引擎内部用例

普通无参动态Delegate 和函数绑定，使用 BindDynamic，当作回调用
`UDELEGATE()
DECLARE_DYNAMIC_DELEGATE(FWidgetAnimationDynamicEvent);`
![alt text](../../assets/images/C++_image.png)

多播Delegate 和函数绑定, 使用 AddDynamic 
`DECLARE_DYNAMIC_MULTICAST_DELEGATE(FMontageWaitSimpleDelegate);`
![alt text](../../assets/images/C++_image-1.png)

`DECLARE_EVENT(MyClass, FMyEvent)`，第一个参数要指定给哪个类使用
![alt text](../../assets/images/C++_image-2.png)


## UE constants

- **UE_SMALL_NUMBER** when you need to skip some samll number

    ``` cpp
    bool UCommonButtonBase::NativeOnHoldProgress(float DeltaTime)
    {
        if (HoldTime > UE_SMALL_NUMBER)
    ```
    and more:
    ``` cpp
    #define UE_PI 					(3.1415926535897932f)	/* Extra digits if needed: 3.1415926535897932384626433832795f */
    #define UE_SMALL_NUMBER			(1.e-8f)
    #define UE_KINDA_SMALL_NUMBER	(1.e-4f)
    #define UE_BIG_NUMBER			(3.4e+38f)
    #define UE_EULERS_NUMBER		(2.71828182845904523536f)
    #define UE_GOLDEN_RATIO			(1.6180339887498948482045868343656381f)	/* Also known as divine proportion, golden mean, or golden section - related to the Fibonacci Sequence = (1 + sqrt(5)) / 2 */
    #define UE_FLOAT_NON_FRACTIONAL (8388608.f) /* All single-precision floating point numbers greater than or equal to this have no fractional value. */
    ```

## Log

- UE_LOGFMT this very useful for print function name.
    ``` cpp
        UE_LOGFMT(LogSwitchboard, Error, "{Func}: EVP_PKEY_derive_init", __FUNCTION__);    
    ```

- UE_LOGFMT_EX: 更清晰，不如上面实用
   命名参数使日志消息更加清晰和易读。每个字段都需要用 `UE_LOGFMT_FIELD` 宏包装，并提供一个字段名。

    ```cpp
    UE_LOGFMT_EX(LogCore, Warning, "Loading '{Name}' failed with error {Error}",
        UE_LOGFMT_FIELD("Name", Package->GetName()), UE_LOGFMT_FIELD("Error", ErrorCode), UE_LOGFMT_FIELD("Flags", LoadFlags));
    ```

## Tools

- widget pool
    ```cpp
    /**
	 * Gets an instance of a widget of the given class.
	 * The underlying slate is stored automatically as well, so the returned widget is fully constructed and GetCachedWidget will return a valid SWidget.
	 */
    UUserWidget* NewEntryWidget = EntryWidgetPool.GetOrCreateInstance(InEntryClass);
    
    ```

## Macro

- AddUniqueDynamic 像函数一样使用的Marco
  ```cpp
    EnhancedInputSubsystem->ControlMappingsRebuiltDelegate.AddUniqueDynamic(this, &UAuraBaseButton::CheckAndAddHoldBinding);

   //展开后的效果 
    EnhancedInputSubsystem->ControlMappingsRebuiltDelegate.__Internal_AddUniqueDynamic( this, &UAuraBaseButton::CheckAndAddHoldBinding, UE::Delegates::Private::GetTrimmedMemberFunctionName(L"&UAuraBaseButton::CheckAndAddHoldBinding") );
  ```
    
