Title: UE C++ Usage
comments: true

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
    