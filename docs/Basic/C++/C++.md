Title: UE c++ usage
comments: true


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