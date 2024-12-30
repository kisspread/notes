title: UE5 handle Path
comments:true
---

`FPackageName` 类提供了丰富的静态方法，用于处理各种类型的路径转换和操作，包括本地路径、长包名、短包名、对象路径和导出文本路径之间的相互转换，以及对路径的分解、组合、校验等操作。 掌握这些方法，可以帮助你在 Unreal Engine 中高效地管理和操作资源。

## 1. 基本概念

### 路径类型
- **Object Path**: 完整对象路径，如 `/Game/MyAsset.MyAsset:SubObject.AnotherObject`
- **Package Path**: 包路径，如 `/Game/MyAsset`
- **Local Path**: 本地文件系统路径

### 路径组成部分
- Mount Point (挂载点): 如 `/Game/`, `/Engine/` 等
- Relative Path (相对路径): 从挂载点到具体资源的路径
- Object Name (对象名): 资源内的具体对象
- SubObject Name (子对象名): 对象内的子对象

## 2. FPackageName 路径转换方法 

### 路径类型说明

几种常见的路径类型：

*   **Local Path (本地路径):** 文件系统上的绝对或相对路径，例如: `C:\MyProject\Content\Maps\MyMap.umap` 或 `Content/Blueprints/MyBlueprint.uasset`
*   **Long Package Name (长包名):**  以 "/" 开头的逻辑路径，用于在引擎内部引用资源，例如: `/Game/Maps/MyMap`, `/Engine/EditorResources/S_Actor.uasset`
*   **Short Package Name (短包名):** 长包名的叶子节点，例如: `MyMap`
*   **Object Path (对象路径):** 包含包名、对象名以及可能的子对象名的路径，例如: `/Game/MyAsset.MyAsset:SubObject.AnotherObject`
*   **Export Text Path (导出文本路径):** 类似于对象路径，但包含类名，用于文本序列化，例如: `StaticMesh'/Game/MyAsset.MyAsset'`
*   **VersePath:** Verse 模块中使用的路径，用于引用 Verse 资源。

###  路径转换相关方法

##### 1. 本地路径 (Local Path) 转 长包名 (Long Package Name)

*   **`TryConvertFilenameToLongPackageName`**

    ```cpp
    // 尝试将文件名转换为长包名
    // 示例:
    //   "C:/MyProject/Content/Maps/MyMap.umap" -> "/Game/Maps/MyMap" (如果 C:/MyProject/Content 挂载为 /Game)
    //   "Content/Blueprints/MyBlueprint.uasset" -> "/Game/Blueprints/MyBlueprint" (如果 Content 挂载为 /Game)
    static COREUOBJECT_API bool TryConvertFilenameToLongPackageName(const FString& InFilename, FString& OutPackageName,
    	FString* OutFailureReason = nullptr, const EConvertFlags Flags = EConvertFlags::None);
    ```

    *   `InFilename`: 要转换的本地路径。
    *   `OutPackageName`: 转换后的长包名。
    *   `OutFailureReason`: (可选) 如果转换失败，返回错误原因。
    *   `Flags`: (可选) 转换标志，例如 `EConvertFlags::AllowDots` 用于处理带 `*.*.*` 的通配符模式。
    *   返回值: `true` 如果转换成功, 否则 `false`。

*   **`FilenameToLongPackageName`**

    ```cpp
     // 将文件名转换为长包名
     //  示例:
    //   "C:/MyProject/Content/Maps/MyMap.umap" -> "/Game/Maps/MyMap" (如果 C:/MyProject/Content 挂载为 /Game)
    static COREUOBJECT_API FString FilenameToLongPackageName(const FString& InFilename);
    ```

    *   `InFilename`: 要转换的本地路径。
    *   返回值：转换后的长包名，如果转换失败，抛出致命错误。

##### 2. 长包名 (Long Package Name) 转 本地路径 (Local Path)

*   **`TryConvertLongPackageNameToFilename`**

    ```cpp
    // 尝试将长包名转换为文件名
     // 示例:
    //   "/Game/Maps/MyMap"  -> "C:/MyProject/Content/Maps/MyMap.umap" (如果 C:/MyProject/Content 挂载为 /Game, 且umap是默认扩展名)
    //   "/Game/Maps/MyMap", ".uasset" -> "C:/MyProject/Content/Maps/MyMap.uasset"
    static COREUOBJECT_API bool TryConvertLongPackageNameToFilename(const FString& InLongPackageName, FString& OutFilename, const FString& InExtension = TEXT(""));
    ```

    *   `InLongPackageName`: 要转换的长包名。
    *   `OutFilename`: 转换后的本地路径。
    *   `InExtension`: (可选) 要使用的扩展名。
    *   返回值: `true` 如果转换成功, 否则 `false`。

*   **`LongPackageNameToFilename`**

    ```cpp
    // 将长包名转换为文件名
    // 示例:
    //   "/Game/Maps/MyMap"  -> "C:/MyProject/Content/Maps/MyMap.umap" (如果 C:/MyProject/Content 挂载为 /Game, 且umap是默认扩展名)
    static COREUOBJECT_API FString LongPackageNameToFilename(const FString& InLongPackageName, const FString& InExtension = TEXT(""));
    ```

    *   `InLongPackageName`: 要转换的长包名。
    *   `InExtension`: (可选) 要使用的扩展名。
    *   返回值：转换后的本地路径，如果转换失败，抛出致命错误。

##### 3.  长包名 (Long Package Name) 相关操作

*   **`GetLongPackagePath`**

    ```cpp
    // 获取长包名的路径部分，不包含叶子节点
     // 示例:
    //   "/Game/Maps/MyMap" -> "/Game/Maps"
    static COREUOBJECT_API FString GetLongPackagePath(const FString& InLongPackageName);
    ```
     *   `InLongPackageName`: 输入的长包名。
     *   返回值：长包名的路径部分。

*   **`GetLongPackageAssetName`**

    ```cpp
     // 获取长包名的资源名（短名），不包含路径
     // 示例:
    //  "/Game/Maps/MyMap" -> "MyMap"
    static COREUOBJECT_API FString GetLongPackageAssetName(const FString& InLongPackageName);
    ```
     *   `InLongPackageName`: 输入的长包名。
     *   返回值：长包名的资源名。

*   **`SplitLongPackageName`**

    ```cpp
    // 将长包名分解为根、路径和名称组件
    // 示例:
    //  "/Game/Maps/MyMap.umap" -> ("/Game/", "Maps/", "MyMap.umap")
    static COREUOBJECT_API bool SplitLongPackageName(const FString& InLongPackageName, FString& OutPackageRoot, FString& OutPackagePath, FString& OutPackageName, const bool bStripRootLeadingSlash = false);
    ```

    *   `InLongPackageName`: 要分解的长包名。
    *   `OutPackageRoot`: 包的根路径，例如 `/Game/`。
    *   `OutPackagePath`: 包相对于挂载点的路径，例如 `Maps/`。
    *   `OutPackageName`: 包的名称，包括扩展名，例如 `MyMap.umap`。
    *   `bStripRootLeadingSlash`: 是否删除返回的根路径的开头斜杠。
    *   返回值: `true` 如果分解成功, 否则 `false`。

*   **`IsValidLongPackageName`**

    ```cpp
     // 检查长包名是否有效
    //  示例:
    //   "/Game/Maps/MyMap" -> true
    //   "InvalidName" -> false
    static COREUOBJECT_API bool IsValidLongPackageName(FStringView InLongPackageName, bool bIncludeReadOnlyRoots = false, EErrorCode* OutReason = nullptr);
    ```
     *   `InLongPackageName`: 要检查的长包名。
     *   `bIncludeReadOnlyRoots`: 是否包含只读根路径，例如 `/Temp/`, `/Script/`。
     *   `OutReason`: (可选) 如果无效，返回错误码。
     *    返回值：`true` 如果有效, 否则 `false`。

##### 4.  短包名 (Short Package Name) 相关操作

*   **`IsShortPackageName`**

    ```cpp
    // 检查字符串是否是短包名
     // 示例:
    //  "MyMap" -> true
    //  "/Game/MyMap" -> false
    static COREUOBJECT_API bool IsShortPackageName(const FString& PossiblyLongName);
    ```
    *   `PossiblyLongName`: 要检查的字符串。
    *   返回值: `true` 如果是短包名, 否则 `false`。

*   **`GetShortName`**

    ```cpp
    // 从长包名或包中获取短包名
     // 示例:
    //   "/Game/Maps/MyMap" -> "MyMap"
    static COREUOBJECT_API FString GetShortName(const FString& LongName);
    static COREUOBJECT_API FString GetShortName(const UPackage* Package);
    ```

    *   `LongName` / `Package`: 要获取短包名的长包名或包。
    *    返回值：短包名。

*   **`GetShortFName`**
     ```cpp
     // 从长包名或包中获取短包名 FName 类型
     // 示例:
     //   "/Game/Maps/MyMap" -> "MyMap"
    static COREUOBJECT_API FName GetShortFName(const FString& LongName);
    ```
    *  `LongName`: 要获取短包名的长包名。
    *  返回值：短包名(FName类型)。

##### 5.  对象路径 (Object Path) 相关操作

*   **`SplitFullObjectPath`**

    ```cpp
    // 将完整的对象路径分解为类名、包名、对象名和子对象名
     // 示例:
    //  "Class /Game/MyAsset.MyAsset:SubObject.AnotherObject" -> ("Class", "/Game/MyAsset", "MyAsset", "SubObject.AnotherObject")
    //  "/Game/MyAsset.MyAsset:SubObject" -> ("", "/Game/MyAsset", "MyAsset", "SubObject")
    static COREUOBJECT_API void SplitFullObjectPath(const FString& InFullObjectPath, FString& OutClassName,
    	FString& OutPackageName, FString& OutObjectName, FString& OutSubObjectName, bool bDetectClassName = true);
    ```
    *   `InFullObjectPath`: 要分解的完整对象路径。
    *   `OutClassName`:  类名，可能为空。
    *   `OutPackageName`:  包名。
    *   `OutObjectName`:  对象名。
    *   `OutSubObjectName`:  子对象名，可能为空。
    *    `bDetectClassName`: 是否尝试检测类名。
*   **`ObjectPathToPackageName`**

    ```cpp
    // 从对象路径获取包名
    // 示例:
    // "/Game/MyAsset.MyAsset:SubObject.AnotherObject" -> "/Game/MyAsset"
    // "/Game/MyAsset.MyAsset:SubObject"               -> "/Game/MyAsset"
    // "/Game/MyAsset.MyAsset"                         -> "/Game/MyAsset"
    // "/Game/MyAsset"                                 -> "/Game/MyAsset"
    static COREUOBJECT_API FString ObjectPathToPackageName(const FString& InObjectPath);
    ```
    *   `InObjectPath`: 要提取包名的对象路径。
    *   返回值：对象路径对应的包名。
 *  **`ObjectPathToPathWithinPackage`**

    ```cpp
    // 从对象路径中提取包内的路径部分
    // 示例:
    // "/Game/MyAsset.MyAsset:SubObject.AnotherObject" -> "MyAsset:SubObject.AnotherObject"
    // "/Game/MyAsset.MyAsset:SubObject"               -> "MyAsset:SubObject"
    // "/Game/MyAsset.MyAsset"                         -> "MyAsset"
    // "/Game/MyAsset"                                 -> ""
    static COREUOBJECT_API FString ObjectPathToPathWithinPackage(const FString& InObjectPath);
    ```
    *   `InObjectPath`: 要提取包内路径的对象路径。
    *   返回值：对象路径中包内的路径部分。

*   **`ObjectPathToOuterPath`**

    ```cpp
    // 从对象路径获取外部路径
    // 示例:
    // "/Game/MyAsset.MyAsset:SubObject.AnotherObject" -> "/Game/MyAsset.MyAsset:SubObject"
    // "/Game/MyAsset.MyAsset:SubObject"               -> "/Game/MyAsset.MyAsset"
    // "/Game/MyAsset.MyAsset"                         -> "/Game/MyAsset"
    // "/Game/MyAsset"                                 -> ""
    static COREUOBJECT_API FString ObjectPathToOuterPath(const FString& InObjectPath);
    ```
    *   `InObjectPath`: 要提取外部路径的对象路径。
    *   返回值：对象路径对应的外部路径。

*   **`ObjectPathToSubObjectPath`**

    ```cpp
     // 从对象路径获取子对象路径
    // 示例:
    // "/Game/MyAsset.MyAsset:SubObject.AnotherObject" -> "SubObject.AnotherObject"
    // "/Game/MyAsset.MyAsset:SubObject"               -> "SubObject"
    // "/Game/MyAsset.MyAsset"                         -> "MyAsset"
    // "/Game/MyAsset"                                 -> "/Game/MyAsset"
    static COREUOBJECT_API FString ObjectPathToSubObjectPath(const FString& InObjectPath);
    ```

    * `InObjectPath`: 要提取子对象路径的对象路径。
    *   返回值：对象路径对应的子对象路径。

*   **`ObjectPathToObjectName`**

    ```cpp
    // 从对象路径获取对象名称
    // 示例:
    // "/Game/MyAsset.MyAsset:SubObject.AnotherObject" -> "AnotherObject"
    // "/Game/MyAsset.MyAsset:SubObject"               -> "SubObject"
    // "/Game/MyAsset.MyAsset"                         -> "MyAsset"
    // "/Game/MyAsset"                                 -> "/Game/MyAsset"
    static COREUOBJECT_API FString ObjectPathToObjectName(const FString& InObjectPath);
    ```

    *   `InObjectPath`: 要提取对象名称的对象路径。
    *   返回值：对象路径对应的对象名称。

*   **`ObjectPathSplitFirstName`**

    ```cpp
    // 将对象路径字符串拆分为第一个组件和其余部分
    // 示例:
    // "/Path/To/A/Package.Object:SubObject" -> { "/Path/To/A/Package", "Object:SubObject" }
    // "Object:SubObject" -> { "Object", "SubObject" }
    // "Object.SubObject" -> { "Object", "SubObject" }
    static COREUOBJECT_API void ObjectPathSplitFirstName(FAnsiStringView Text,
    	FAnsiStringView& OutFirst, FAnsiStringView& OutRemainder);
    ```

    *   `Text`: 要分解的对象路径字符串。
    *   `OutFirst`: 分解后的第一个组件。
    *  `OutRemainder`: 分解后的剩余部分。

*   **`ObjectPathAppend`**

    ```cpp
    // 将对象路径与对象名组合
    //  示例:
    // { "/Package", "Object" } -> "/Package.Object"
    // { "/Package.Object", "SubObject" } -> "/Package.Object:SubObject"
    //  { "/Package.Object:SubObject", "NextSubObject" } -> "/Package.Object:SubObject.NextSubObject"
    //  { "/Package", "Object.SubObject" } -> "/Package.Object:SubObject"
    //  { "/Package", "/OtherPackage.Object:SubObject" } -> "/OtherPackage.Object:SubObject"
    static COREUOBJECT_API void ObjectPathAppend(FStringBuilderBase& ObjectPath, FStringView NextName);
    ```
     *  `ObjectPath`: 要添加到的对象路径。
    *   `NextName`: 要添加的对象名。
    
*   **`ObjectPathCombine`**

    ```cpp
     // 将对象路径与对象名组合，与 `ObjectPathAppend` 类似，但返回结果而不修改输入参数
    static COREUOBJECT_API FString ObjectPathCombine(FStringView ObjectPath, FStringView NextName);
    ```
    *   `ObjectPath`: 要添加到的对象路径。
    *   `NextName`: 要添加的对象名。
     *   返回值：组合后的对象路径。

*   **`IsValidObjectPath`**
    ```cpp
    // 检查对象路径是否有效
     // 示例:
    //  "/Game/MyAsset.MyAsset" -> true
    //   "Class /Game/MyAsset.MyAsset" -> true
    //   "Invalid/Path" -> false
    static COREUOBJECT_API bool IsValidObjectPath(FStringView InObjectPath, FText* OutReason = nullptr);
    ```
    *   `InObjectPath`: 要检查的对象路径。
    *   `OutReason`: (可选) 如果无效，返回错误描述。
    *   返回值: `true` 如果有效，否则 `false`。
    
*  **`IsValidPath`**
    ```cpp
    // 检查路径是否有效，只检查是否以挂载点为开始，不检查object是否有效
      // 示例:
      //   "/Game/MyAsset" -> true
     //   "/Invalid/Path" -> false
    static COREUOBJECT_API bool IsValidPath(FStringView InPath);
    ```
    *   `InPath`: 要检查的路径。
    *   返回值: `true` 如果有效，否则 `false`。

##### 6. 导出文本路径 (Export Text Path) 相关操作

*   **`ParseExportTextPath`**

    ```cpp
    // 解析导出文本路径为类名和对象路径
    // 示例:
    //  "StaticMesh'/Game/MyAsset.MyAsset'" -> ("StaticMesh", "/Game/MyAsset.MyAsset")
    static COREUOBJECT_API bool ParseExportTextPath(const FString& InExportTextPath, FString* OutClassName, FString* OutObjectPath);
    ```

    *   `InExportTextPath`: 要解析的导出文本路径。
    *   `OutClassName`: 解析出的类名。
    *   `OutObjectPath`: 解析出的对象路径。
    *   返回值: `true` 如果解析成功, 否则 `false`。

*   **`ExportTextPathToObjectPath`**

    ```cpp
    // 从导出文本路径提取对象路径
    // 示例:
    //  "StaticMesh'/Game/MyAsset.MyAsset'" -> "/Game/MyAsset.MyAsset"
    static COREUOBJECT_API FString ExportTextPathToObjectPath(const FString& InExportTextPath);
    ```

    *   `InExportTextPath`: 要提取对象路径的导出文本路径。
    *    返回值：提取出的对象路径。

##### 7.  其他类型路径的相关操作

*   **`GetVersePath`**

    ```cpp
    // 获取对象的 VersePath
    static COREUOBJECT_API UE::Core::FVersePath GetVersePath(const FSoftObjectPath& ObjectPath);
    ```

    *   `ObjectPath`: 要获取 VersePath 的软对象路径。
    *   返回值：对象的 VersePath。

##### 8. Mount Point 相关
*   **`TryGetMountPointForPath`**

    ```cpp
    // 查找包含给定本地文件路径或包名的挂载点，并返回 MountPoint 和 RelativePath
    static COREUOBJECT_API bool TryGetMountPointForPath(FStringView InFilePathOrPackageName, FStringBuilderBase& OutMountPointPackageName, FStringBuilderBase& OutMountPointFilePath, FStringBuilderBase& OutRelPath,
        EFlexNameType* OutFlexNameType = nullptr, EErrorCode* OutFailureReason = nullptr);
     ```
    *   `InFilePathOrPackageName`: 要测试的路径，可以是本地文件路径、包名或对象路径。
     *   `OutMountPointPackageName`: 如果找到挂载点，挂载点的包名会被复制到这个变量中，否则会被设置为空字符串。
     *   `OutMountPointFilePath`: 如果找到挂载点，挂载点的本地文件路径会被复制到这个变量中，否则会被设置为空字符串。
    *   `OutRelPath`: 如果找到挂载点，从挂载点到 InFilePathOrPackageName 的相对路径会被复制到这个变量中，否则会被设置为空字符串。如果 InFilePathOrPackageName 是文件路径，则会在复制到 OutRelpath 之前删除扩展名。OutRelPath 对于本地文件路径和包名是相同的。
    *   `OutFlexNameType`: (可选) 如果非空，则会设置为 InFilePathOrPackageName 是包名还是文件名，如果找到挂载点，否则会被设置为 EFlexNameType::Invalid。
     *   `OutFailureReason`: (可选) 如果非空，则会设置为 InPath 无法转换的原因，或者如果函数成功，则会设置为 EErrorCode::Unknown。
    *   返回值:  如果找到 MountPoint，则为 True，否则为 False。

 



 
