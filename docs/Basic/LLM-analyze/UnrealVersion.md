tile:UAsset 版本feature 判断


`Summary.GetFileVersionUE() >= EUnrealEngineObjectUE5Version::ADD_SOFTOBJECTPATH_LIST` 这种比较方法的原理，以及它在 Unreal Engine 中所起的作用。

**核心概念：版本控制和兼容性**

在 Unreal Engine 中，为了保证不同版本编辑器和运行时之间的数据兼容性，引入了版本控制系统。这允许在引擎升级时，旧版本创建的资源仍然可以在新版本中加载和使用，同时也能确保新版本的功能不会破坏旧版本资源的正确性。

**`FPackageFileVersion` 结构体**

`FPackageFileVersion` 结构体是用于存储和比较版本信息的核心组件。它包含了两个主要的版本号：

*   `FileVersionUE4`: 代表 Unreal Engine 4 的版本号。
*   `FileVersionUE5`: 代表 Unreal Engine 5 的版本号。

这样做的好处是，UE4 和 UE5 的版本控制可以独立进行，互不干扰，允许未来在 UE4 代码库中做出版本更改，同时仍然保持与 UE5 代码库的兼容性。

`FPackageFileVersion` 还提供了方便的运算符重载，以便进行版本比较，包括：

*   `>=`, `<`: 可以直接与 `EUnrealEngineObjectUE4Version` 或 `EUnrealEngineObjectUE5Version` 枚举值进行比较。
*   `==`, `!=`: 可以直接与其他 `FPackageFileVersion` 对象进行比较。
*  `IsCompatible`:可以用来判断当前包的版本兼容性

**`EUnrealEngineObjectUE5Version` 枚举**

`EUnrealEngineObjectUE5Version` 是一个枚举类型，定义了 UE5 版本号。每个枚举值代表一个特定的引擎特性或修改被引入的版本。例如：

*   `INITIAL_VERSION`: UE5 的初始版本。
*   `ADD_SOFTOBJECTPATH_LIST`: 在此版本中，package summary 中添加了 soft object path 列表。
*  等等，每个版本都会记录一个引擎的特性修改或者版本更迭

**比较操作的含义**

`Summary.GetFileVersionUE() >= EUnrealEngineObjectUE5Version::ADD_SOFTOBJECTPATH_LIST` 这行代码的含义如下：

1.  `Summary.GetFileVersionUE()`: 从 `FPackageFileSummary` 结构体中获取 `FPackageFileVersion`，它包含了当前 package 文件的版本信息。
2.  `EUnrealEngineObjectUE5Version::ADD_SOFTOBJECTPATH_LIST`: 获取 `EUnrealEngineObjectUE5Version` 枚举中 `ADD_SOFTOBJECTPATH_LIST` 对应的值，它代表了 soft object path 列表特性被引入的版本。
3.  `>=`:  使用 `>=` 运算符比较 package 文件版本是否 **大于等于** `ADD_SOFTOBJECTPATH_LIST` 版本。

**工作原理**

比较操作的本质是：

*   如果 **当前 package 文件的 UE5 版本号大于等于** `ADD_SOFTOBJECTPATH_LIST`，则比较结果为 `true`，意味着此 package 文件 **包含** soft object path 列表。
*   如果 **当前 package 文件的 UE5 版本号小于** `ADD_SOFTOBJECTPATH_LIST`，则比较结果为 `false`，意味着此 package 文件 **不包含** soft object path 列表。

**实际应用场景**

在 Unreal Engine 的代码中，这种比较方式经常用于：

*   **读取 package 文件**：在读取 package 文件数据时，根据版本号来判断文件是否包含某个特定的数据结构或特性。如果版本号较低，则可能需要采用旧的读取方式；如果版本号较高，则可以使用新的读取方式。
*   **写入 package 文件**：在写入 package 文件时，会根据当前引擎的版本号来确定需要写入哪些数据。例如，如果引擎版本支持 soft object path 列表，则在保存 package 文件时会包含这个列表。
*   **兼容性检查**：在加载资源时，引擎需要检查资源的最低版本是否满足需求。如果资源的版本过低，可能会加载失败或表现不正常。
*  **代码逻辑分支** ：根据版本号决定代码的执行路径，以此来处理不同的资源版本。


**Example**

FileVersionUE5 = 1004 意味着，这个文件在 UE5 环境下，已经经历了4个版本迭代。

在 EUnrealEngineObjectUE5Version 枚举中，从 INITIAL_VERSION 开始：

INITIAL_VERSION = 1000

NAMES_REFERENCED_FROM_EXPORT_DATA = 1001

PAYLOAD_TOC = 1002

OPTIONAL_RESOURCES = 1003

LARGE_WORLD_COORDINATES = 1004

这意味着你的 uasset 文件：

支持 了 NAMES_REFERENCED_FROM_EXPORT_DATA

支持 了 PAYLOAD_TOC

支持 了 OPTIONAL_RESOURCES

支持 了 LARGE_WORLD_COORDINATES

它不一定支持 比 LARGE_WORLD_COORDINATES 更新的特性，例如 REMOVE_OBJECT_EXPORT_PACKAGE_GUID，因为它是在 1005 版本中引入的。

**总结**

`Summary.GetFileVersionUE() >= EUnrealEngineObjectUE5Version::ADD_SOFTOBJECTPATH_LIST`  这行代码的核心作用是根据 package 文件的版本信息来 **有条件地执行代码**。它利用了 `FPackageFileVersion` 和 `EUnrealEngineObjectUE5Version` 来进行版本的比较，从而保证了不同版本 Unreal Engine 之间的资源兼容性和代码的鲁棒性。

这种版本控制方式，使得 Unreal Engine 能够平滑地进行升级，同时最大限度地减少因版本不兼容而导致的问题。
