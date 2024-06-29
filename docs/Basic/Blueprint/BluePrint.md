Title:  Blueprint Relevant
comments: true

不限于蓝图，C++也有。记录一下


## Meta记录

### EditCondition

可以用来隐藏feature，支持的时候，才显示。可以是上下文相关
```cpp
	/** 
	 *	The enhanced input action that is bound to this button. The common input manager will trigger this button to 
	 *	click if the action was pressed 
	 */
	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = Input, meta = (EditCondition = "CommonInput.CommonInputSettings.IsEnhancedInputSupportEnabled", EditConditionHides))
	TObjectPtr<UInputAction> TriggeringEnhancedInputAction;

    /** Press and Hold values used for Keyboard and Mouse, Gamepad and Touch, depending on the current input type */
	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Input|Hold", meta = (EditCondition="bRequiresHold", ExposeOnSpawn = true))
	TSubclassOf<UCommonUIHoldData> HoldData;
```

### Camp
限制数值, 其中UIMin UIMax 只是显示效果，不影响实际代码
``` cpp
	UPROPERTY(EditAnywhere, config, Category = "VisualLogger", meta = (ClampMin = "10", ClampMax = "1000", UIMin = "10", UIMax = "1000"))
	float DefaultCameraDistance;

```


## 属性标记（注解）

0. **`Transient`**
    - Transient是一个属性标记，用于指示特定变量不应被序列化或者保存到磁盘上。这意味着当你标记一个变量为Transient时，它的值不会在游戏保存时被保留，也不会在编辑器关闭和重新打开后被恢复。这个标记通常用于运行时的临时数据。
        ```cpp
        UPROPERTY(Transient)
        TObjectPtr<UMaterialInstanceDynamic> ProgressDynamicMaterial;
        ```

1. **`NonPIEDuplicateTransient`**：
   - 这个标记用于指示属性在非PIE（Play In Editor）场景中不应被复制。通常用于避免在编辑器模式下不必要的数据复制。
   
     ```cpp
     UPROPERTY(NonPIEDuplicateTransient)
     TObjectPtr<UMaterialInstanceDynamic> MyMaterial;
     ```

2. **`DuplicateTransient`**：
   - 属性在对象被复制时不会被复制。通常用于指示运行时的临时数据。
   
     ```cpp
     UPROPERTY(DuplicateTransient)
     TObjectPtr<UTexture> RuntimeTexture;
     ```

3. **`TextExportTransient`**：
   - 属性在文本导出过程中不会被导出。通常用于数据不需要在文本格式中保存的场景。
   
     ```cpp
     UPROPERTY(TextExportTransient)
     int32 TemporaryData;
     ```

4. **`SkipSerialization`**：
   - 完全跳过序列化过程，属性不会被序列化或反序列化。
   
     ```cpp
     UPROPERTY(SkipSerialization)
     FString SecretData;
     ```

5. **`AssetRegistrySearchable`**：
   - 属性会被添加到资产注册表中，允许通过资产注册表进行搜索。通常用于需要在内容浏览器中快速找到特定资产的场景。
   
     ```cpp
     UPROPERTY(AssetRegistrySearchable)
     FString AssetTag;
     ```