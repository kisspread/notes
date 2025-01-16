# Lyra 插件系统分析

Lyra 示例游戏包含了多个插件，每个插件都具有特定的功能和用途。以下是对各插件的详细分析：

## AsyncMixin
异步操作混入插件，提供了一套异步操作的工具集，用于处理游戏中的异步任务，如资源加载、网络请求等。

### 主要功能和用法

1. **基本继承使用**
```cpp
// 继承 FAsyncMixin
class YourClass : public FAsyncMixin 
{
    // 你的类实现
};
```

2. **核心函数**

#### 异步加载相关
```cpp
// 异步加载单个资源
AsyncLoad(TSoftObjectPtr<T> SoftObject, TFunction<void(T*)>&& Callback);

// 异步加载类
AsyncLoad(TSoftClassPtr<T> SoftClass, TFunction<void(TSubclassOf<T>)>&& Callback);

// 异步加载多个资源
AsyncLoad(const TArray<FSoftObjectPath>& SoftObjectPaths, const FSimpleDelegate& Callback);

// 异步预加载主要资源和包
AsyncPreloadPrimaryAssetsAndBundles(const TArray<FPrimaryAssetId>& AssetIds, 
                                  const TArray<FName>& LoadBundles, 
                                  const FSimpleDelegate& Callback);
```

#### 控制流程相关
```cpp
// 开始异步加载
StartAsyncLoading();

// 取消异步加载
CancelAsyncLoading();

// 添加异步事件
AsyncEvent(TFunction<void()>&& Callback);

// 添加异步条件
AsyncCondition(TSharedRef<FAsyncCondition> Condition, const FSimpleDelegate& Callback);
```

3. **使用示例**
```cpp
// 取消之前的加载
CancelAsyncLoading();

// 加载第一个资产
AsyncLoad(ItemOne, [this](UObject* LoadedItem) {
    // 处理加载完成的第一个资产
});

// 加载第二个资产
AsyncLoad(ItemTwo, [this](UObject* LoadedItem) {
    // 处理加载完成的第二个资产
});

// 开始异步加载
StartAsyncLoading();
```

4. **特点和优势**
- 无需手动管理内存，使用静态 TMap 存储异步请求状态
- 保证按顺序执行回调，即使资源已经加载完成
- 支持安全地在 lambda 中捕获 this 指针
- 自动处理对象销毁时的清理工作
- 支持调试日志（使用 `-LogCmds="LogAsyncMixin Verbose"` 命令行参数）

5. **生命周期回调**
```cpp
virtual void OnStartedLoading() { }  // 加载开始时调用
virtual void OnFinishedLoading() { } // 所有加载完成时调用
```

### 使用建议
1. 在重用对象时（如列表项），记得调用 `CancelAsyncLoading()` 取消之前的加载
2. 尽量在设置完所有加载后立即调用 `StartAsyncLoading()`，避免加载指示器闪烁
3. 使用 `AsyncEvent` 处理可选资产的加载序列
4. 合理利用 `AsyncCondition` 处理复杂的加载依赖关系

## CommonGame
通用游戏功能插件，提供了一系列基础游戏功能的实现。这个插件依赖于 CommonUI、CommonUser、ModularGameplayActors 和 OnlineFramework 插件。

### 主要组件

1. **GameInstance 相关**
```cpp
// 基础游戏实例类
class UCommonGameInstance : public UGameInstance
{
public:
    // 初始化游戏实例
    virtual void Init() override;
    
    // 返回主菜单
    virtual void ReturnToMainMenu() override;
    
    // 处理用户系统消息
    UFUNCTION()
    virtual void HandleSystemMessage();
    
    // 处理权限变更
    UFUNCTION()
    virtual void HandlePrivilegeChanged();
};
```

2. **UI 管理系统**
```cpp
// UI 管理器子系统
class UGameUIManagerSubsystem : public UGameInstanceSubsystem
{
public:
    // 获取当前 UI 策略
    UGameUIPolicy* GetCurrentUIPolicy() const;
    
    // 切换 UI 策略
    void SwitchToPolicy(UGameUIPolicy* InPolicy);
};

// 主游戏布局
class UPrimaryGameLayout : public UCommonUserWidget
{
public:
    // 获取主游戏布局
    static UPrimaryGameLayout* GetPrimaryGameLayout(ULocalPlayer* LocalPlayer);
    
    // 获取主游戏布局（通过玩家控制器）
    static UPrimaryGameLayout* GetPrimaryGameLayout(APlayerController* PlayerController);
};
```

3. **消息系统**
```cpp
// 消息子系统
class UCommonMessagingSubsystem : public ULocalPlayerSubsystem
{
public:
    // 显示错误信息
    void ShowError(UCommonGameDialogDescriptor* DialogDescriptor, 
                  FCommonMessagingResultDelegate ResultCallback);
};

// 游戏对话框描述符
class UCommonGameDialogDescriptor : public UObject
{
public:
    // 对话框标题
    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    FText Header;
    
    // 对话框内容
    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    FText Body;
    
    // 按钮动作
    UPROPERTY(BlueprintReadWrite)
    TArray<FConfirmationDialogAction> ButtonActions;
};
```

4. **玩家相关类**
```cpp
// 通用本地玩家类
class UCommonLocalPlayer : public ULocalPlayer
{
public:
    // 玩家控制器设置委托
    FPlayerControllerSetDelegate OnPlayerControllerSet;
    
    // 玩家状态设置委托
    FPlayerStateSetDelegate OnPlayerStateSet;
    
    // 玩家 Pawn 设置委托
    FPlayerPawnSetDelegate OnPlayerPawnSet;
};

// 通用玩家控制器
class ACommonPlayerController : public AModularPlayerController
{
    // 提供基础的玩家控制功能
};
```

### 主要功能

1. **游戏实例管理**
- 提供基础游戏实例实现
- 处理用户系统消息和权限变更
- 管理主玩家和会话

2. **UI 系统**
- 提供可扩展的 UI 管理系统
- 支持多玩家交互模式
- 管理游戏布局和 UI 层级

3. **消息和对话框系统**
- 提供统一的消息显示接口
- 支持可配置的对话框系统
- 处理用户交互结果

4. **玩家管理**
- 提供增强的本地玩家功能
- 支持模块化的玩家控制器
- 处理玩家状态变更事件

### 使用建议
1. 继承 `UCommonGameInstance` 来创建自定义游戏实例
2. 使用 `UGameUIManagerSubsystem` 管理游戏 UI
3. 通过 `UCommonMessagingSubsystem` 显示游戏消息和对话框
4. 利用 `UCommonLocalPlayer` 和 `ACommonPlayerController` 处理玩家相关功能

## CommonLoadingScreen
通用加载界面插件，负责管理游戏中加载界面的创建和显示。该插件包含两个主要模块：CommonLoadingScreen（运行时）和 CommonStartupLoadingScreen（仅客户端）。

### 主要组件

1. **加载界面管理器**
```cpp
// 加载界面管理器
class ULoadingScreenManager : public UGameInstanceSubsystem, public FTickableGameObject
{
public:
    // 注册加载处理器
    void RegisterLoadingProcessor(const TScriptInterface<ILoadingProcessInterface>& Processor);
    
    // 取消注册加载处理器
    void UnregisterLoadingProcessor(const TScriptInterface<ILoadingProcessInterface>& Processor);
    
    // 加载界面可见性变更委托
    FOnLoadingScreenVisibilityChangedDelegate LoadingScreenVisibilityChanged;

protected:
    // 检查是否需要显示加载界面
    bool CheckForAnyNeedToShowLoadingScreen();
    
    // 显示加载界面
    void ShowLoadingScreen();
    
    // 隐藏加载界面
    void HideLoadingScreen();
};
```

2. **加载过程接口**
```cpp
// 加载过程接口
class ILoadingProcessInterface
{
public:
    // 检查是否应该显示加载界面
    virtual bool ShouldShowLoadingScreen(FString& OutReason) const;
    
    // 静态检查方法
    static bool ShouldShowLoadingScreen(UObject* TestObject, FString& OutReason);
};
```

3. **加载任务**
```cpp
// 加载任务
class ULoadingProcessTask : public UObject, public ILoadingProcessInterface
{
public:
    // 创建加载界面处理任务
    static ULoadingProcessTask* CreateLoadingScreenProcessTask(
        UObject* WorldContextObject, 
        const FString& ShowLoadingScreenReason
    );
};
```

### 主要功能

1. **加载界面管理**
- 自动检测并显示/隐藏加载界面
- 支持多种加载触发条件
- 处理加载界面的输入阻断
- 管理加载界面的性能设置

2. **加载状态检测**
- 地图加载状态
- 无缝旅行状态
- 游戏状态检查
- 玩家控制器状态

3. **可配置选项**
```cpp
class UCommonLoadingScreenSettings : public UDeveloperSettingsBackedByCVars
{
public:
    // 加载界面小部件类
    UPROPERTY(config)
    TSoftClassPtr<UUserWidget> LoadingScreenWidget;
    
    // 加载界面显示顺序
    UPROPERTY(config)
    int32 LoadingScreenZOrder;
    
    // 额外保持加载界面显示的时间
    UPROPERTY(config)
    float HoldLoadingScreenAdditionalSecs;
    
    // 加载界面心跳检测超时时间
    UPROPERTY(config)
    float LoadingScreenHeartbeatHangDuration;
};
```

### 使用建议

1. **基本使用**
```cpp
// 创建加载任务
ULoadingProcessTask* LoadingTask = ULoadingProcessTask::CreateLoadingScreenProcessTask(
    WorldContextObject, 
    TEXT("正在加载资源...")
);

// 注册加载处理器
UGameInstance* GameInstance = GetGameInstance();
if (ULoadingScreenManager* Manager = GameInstance->GetSubsystem<ULoadingScreenManager>())
{
    Manager->RegisterLoadingProcessor(LoadingTask);
}
```

2. **自定义加载界面**
- 创建继承自 `UUserWidget` 的加载界面类
- 在项目设置中配置 `LoadingScreenWidget`
- 实现所需的加载动画和提示

3. **性能优化**
- 合理设置 `HoldLoadingScreenAdditionalSecs` 以优化资源流送
- 使用 `LoadingScreenHeartbeatHangDuration` 监控加载卡顿
- 在编辑器中使用 `CommonLoadingScreen.AlwaysShow` 调试加载界面

4. **调试技巧**
- 使用 `CommonLoadingScreen.LogLoadingScreenReasonEveryFrame` 跟踪加载原因
- 设置 `LogLoadingScreenHeartbeatInterval` 监控加载进度
- 在编辑器中使用 `HoldLoadingScreenAdditionalSecsEvenInEditor` 测试加载界面

## CommonUser
用户管理插件，提供游戏和平台在线操作的包装器。该插件依赖于 OnlineSubsystem、OnlineSubsystemUtils 和 OnlineServices 插件。

### 主要组件

1. **用户子系统**
```cpp
// 用户子系统
class UCommonUserSubsystem : public UGameInstanceSubsystem
{
public:
    // 获取本地玩家用户信息
    const UCommonUserInfo* GetUserInfoForLocalPlayerIndex(int32 LocalPlayerIndex) const;
    
    // 获取平台用户信息
    const UCommonUserInfo* GetUserInfoForPlatformUser(FPlatformUserId PlatformUser) const;
    
    // 尝试初始化用户
    bool TryToInitializeUser(FCommonUserInitializeParams Params);
    
    // 登出本地用户
    void LogOutLocalUser(FPlatformUserId PlatformUser);
    
protected:
    // 处理用户初始化
    void HandleLoginForUserInitialize(
        const UCommonUserInfo* UserInfo,
        ELoginStatusType NewStatus,
        FUniqueNetIdRepl NetId,
        const TOptional<FOnlineErrorType>& Error,
        ECommonUserOnlineContext Context,
        FCommonUserInitializeParams Params
    );
};
```

2. **用户初始化参数**
```cpp
// 用户初始化参数
struct FCommonUserInitializeParams
{
    // 本地玩家索引
    int32 LocalPlayerIndex = 0;
    
    // 主输入设备
    FInputDeviceId PrimaryInputDevice;
    
    // 是否可以使用访客登录
    bool bCanUseGuestLogin = false;
    
    // 是否可以创建新的本地玩家
    bool bCanCreateNewLocalPlayer = true;
    
    // 请求的权限
    ECommonUserPrivilege RequestedPrivilege = ECommonUserPrivilege::CanPlay;
    
    // 在线上下文
    ECommonUserOnlineContext OnlineContext = ECommonUserOnlineContext::Game;
};
```

3. **用户信息类**
```cpp
// 用户信息类
class UCommonUserInfo : public UObject
{
public:
    // 获取网络 ID
    FUniqueNetIdRepl GetNetId(ECommonUserOnlineContext Context) const;
    
    // 获取权限可用性
    ECommonUserAvailability GetPrivilegeAvailability(ECommonUserPrivilege Privilege) const;
    
    // 是否已登录
    bool IsLoggedIn() const;
    
    // 是否正在登录
    bool IsDoingLogin() const;
};
```

### 主要功能

1. **用户管理**
- 本地玩家创建和管理
- 平台用户身份验证
- 访客用户支持
- 用户权限管理

2. **登录流程**
- 自动登录处理
- 平台认证转移
- 登录 UI 显示
- 登录状态追踪

3. **会话管理**
```cpp
// 会话子系统
class UCommonSessionSubsystem : public UGameInstanceSubsystem
{
public:
    // 创建在线会话
    void CreateOnlineSessionInternal(ULocalPlayer* LocalPlayer, UCommonSession_HostSessionRequest* Request);
    
    // 查找会话完成回调
    void OnFindSessionsComplete(bool bWasSuccessful);
    
    // 会话信息更新通知
    void NotifySessionInformationUpdated(
        ECommonSessionInformationState SessionStatus,
        const FString& GameMode,
        const FString& MapName
    );
};
```

### 使用建议

1. **基本用户初始化**
```cpp
// 本地游戏初始化
UAsyncAction_CommonUserInitialize* Action = UAsyncAction_CommonUserInitialize::InitializeForLocalPlay(
    UserSubsystem,
    LocalPlayerIndex,
    PrimaryInputDevice,
    bCanUseGuestLogin
);

// 在线游戏初始化
UAsyncAction_CommonUserInitialize* Action = UAsyncAction_CommonUserInitialize::LoginForOnlinePlay(
    UserSubsystem,
    LocalPlayerIndex
);
```

2. **用户状态监控**
- 使用 `GetUserInfoForLocalPlayerIndex` 获取本地玩家信息
- 监听 `OnUserInitializeComplete` 委托处理初始化结果
- 通过 `GetPrivilegeAvailability` 检查用户权限

3. **多玩家支持**
- 合理设置 `MaxNumberOfLocalPlayers` 限制本地玩家数量
- 使用 `bCanUseGuestLogin` 控制访客登录功能
- 处理好玩家控制器和输入设备的映射关系

4. **在线功能集成**
- 根据需要选择合适的在线上下文（Game/Platform/Service）
- 正确处理平台认证和会话管理
- 实现必要的在线状态同步和更新

5. **调试技巧**
- 使用 `bSuppressLoginErrors` 控制登录错误显示
- 监控 `InitializationState` 追踪用户状态
- 利用日志系统记录关键操作和状态变化

## GameFeatures
游戏特性插件系统，用于管理和加载游戏功能模块。在 Lyra 中，包含了多个基于 GameFeatures 的插件，如 ShooterCore、ShooterMaps、TopDownArena 等。

### 主要组件

1. **ShooterCore**
```cpp
// 射击游戏核心功能插件
class ShooterCoreRuntime : public ModuleRules
{
    // 依赖模块
    PublicDependencyModuleNames:
    - Core
    - LyraGame
    - ModularGameplay
    - CommonGame

    PrivateDependencyModuleNames:
    - GameplayAbilities
    - GameplayTags
    - GameplayTasks
    - GameplayMessageRuntime
    - EnhancedInput
    - AIModule
    // ...
}
```

2. **TopDownArena**
```cpp
// 俯视角竞技场游戏模式插件
class TopDownArenaRuntime : public ModuleRules
{
    // 依赖模块
    PublicDependencyModuleNames:
    - Core
    - LyraGame

    PrivateDependencyModuleNames:
    - GameplayAbilities
    - GameplayTags
    - Niagara
    // ...
}
```

### 主要功能

1. **游戏模式管理**
- 支持多种游戏模式的动态加载和切换
- 每个游戏模式可以独立定义自己的规则和逻辑
- 提供模块化的游戏功能扩展机制

2. **射击游戏功能**
- 瞄准辅助系统
```cpp
// 瞄准辅助输入修改器
class UAimAssistInputModifier
{
    // 修改输入值
    FInputActionValue ModifyRaw_Implementation(
        const UEnhancedPlayerInput* PlayerInput,
        FInputActionValue CurrentValue,
        float DeltaTime
    );

    // 更新目标数据
    void UpdateTargetData(float DeltaTime);

    // 计算目标强度
    void CalculateTargetStrengths(
        const FLyraAimAssistTarget& Target,
        float& OutPullStrength,
        float& OutSlowStrength
    );
}
```

- 击杀统计系统
```cpp
// 击杀连续系统
class UElimChainProcessor
{
    // 处理击杀消息
    void OnEliminationMessage(
        FGameplayTag Channel,
        const FLyraVerbMessage& Payload
    );
}

// 击杀助攻系统
class UAssistProcessor
{
    // 处理助攻消息
    void OnEliminationMessage(
        FGameplayTag Channel,
        const FLyraVerbMessage& Payload
    );
}
```

3. **玩家生成管理**
```cpp
// 团队死斗玩家生成管理
class UTDM_PlayerSpawningManagmentComponent
{
    // 选择玩家生成点
    AActor* OnChoosePlayerStart(
        AController* Player,
        TArray<ALyraPlayerStart*>& PlayerStarts
    );
}
```

### 插件特性

1. **ShooterCore**
- 基础射击游戏功能
- 瞄准和武器系统
- 玩家状态和团队管理
- 游戏消息处理

2. **ShooterMaps**
- 射击游戏地图集合
- 依赖 ShooterCore
- 包含示例内容

3. **TopDownArena**
- 俯视角游戏模式
- 独立的游戏玩法系统
- 支持特效和粒子系统

4. **ShooterTests**
- 射击游戏测试功能
- 依赖 ShooterCore
- 提供自动化测试支持

### 使用建议

1. **功能模块化**
- 将游戏功能按照逻辑划分到不同的 GameFeatures 插件中
- 使用插件依赖关系管理功能复用
- 遵循模块化设计原则，减少耦合

2. **游戏模式扩展**
- 创建新的 GameFeatures 插件来添加新的游戏模式
- 继承和扩展现有功能
- 保持良好的兼容性和可维护性

3. **测试和调试**
- 利用 ShooterTests 进行功能测试
- 使用调试工具和日志系统
- 关注性能和内存使用

4. **资源管理**
- 合理组织地图和内容资源
- 控制插件的加载时机
- 优化资源依赖关系

5. **开发流程**
- 遵循插件开发规范
- 保持文档和注释的完整性
- 定期进行代码审查和优化

## GameSettings
游戏设置系统插件，提供了一个灵活的框架来定义和管理游戏特定的设置，并将它们暴露给UI。该插件依赖于 CommonUI 插件。

### 主要功能和用法

1. **设置注册表系统**
```cpp
// 设置注册表类
class UGameSettingRegistry : public UObject
{
    // 顶层设置
    UPROPERTY(Transient)
    TArray<TObjectPtr<UGameSetting>> TopLevelSettings;

    // 已注册的所有设置
    UPROPERTY(Transient)
    TArray<TObjectPtr<UGameSetting>> RegisteredSettings;
};
```

2. **设置值类型**

#### 标量设置（Scalar Settings）
```cpp
// 动态标量设置
class UGameSettingValueScalarDynamic : public UGameSettingValueScalar
{
public:
    // 设置值范围
    void SetSourceRange(const TRange<double>& InSourceRange, double InSourceStep);
    
    // 设置最大最小限制
    void SetMinimumLimit(const TOptional<double>& InMinimum);
    void SetMaximumLimit(const TOptional<double>& InMaximum);
    
    // 设置默认值
    void SetDefaultValue(double InValue);
};
```

#### 离散设置（Discrete Settings）
```cpp
// 动态离散设置
class UGameSettingValueDiscreteDynamic : public UGameSettingValueDiscrete
{
public:
    // 获取离散选项
    TArray<FText> GetDiscreteOptions() const;
    
    // 获取默认选项索引
    int32 GetDiscreteOptionDefaultIndex() const;
    
    // 添加/移除动态选项
    void AddDynamicOption(FString OptionValue, FText DisplayText);
    void RemoveDynamicOption(FString OptionValue);
};
```

3. **UI组件**

#### 设置面板
```cpp
// 设置面板类
class UGameSettingPanel : public UCommonUserWidget
{
protected:
    // 设置列表视图
    UPROPERTY(BlueprintReadOnly, meta = (BindWidget))
    TObjectPtr<UGameSettingListView> ListView_Settings;
    
    // 设置详情视图
    UPROPERTY(BlueprintReadOnly, meta = (BindWidget))
    TObjectPtr<UGameSettingDetailView> Details_Settings;
};
```

4. **设置变更追踪**
```cpp
// 设置变更追踪器
class FGameSettingRegistryChangeTracker
{
public:
    // 应用变更
    void ApplyChanges();
    
    // 处理设置变更
    void HandleSettingChanged(UGameSetting* Setting, EGameSettingChangeReason Reason);
    
private:
    bool bSettingsChanged = false;
    TMap<FObjectKey, TWeakObjectPtr<UGameSetting>> DirtySettings;
};
```

5. **设置过滤系统**
```cpp
// 设置过滤状态
class FGameSettingFilterState
{
public:
    // 获取根设置列表
    const TArray<UGameSetting*>& GetSettingRootList() const;
    
    // 检查设置是否通过过滤
    bool DoesSettingPassFilter(const UGameSetting& Setting) const;
};
```

### 使用建议
1. 使用 `UGameSettingRegistry` 作为设置的中央管理器
2. 对于数值类型的设置，使用 `UGameSettingValueScalarDynamic`
3. 对于选项类型的设置，使用 `UGameSettingValueDiscreteDynamic`
4. 利用 `FGameSettingRegistryChangeTracker` 追踪设置变更
5. 使用 `GameSettingPanel` 和相关UI组件构建设置界面
6. 合理使用过滤系统组织和展示设置

### 特点和优势
- 提供完整的设置管理框架
- 支持多种设置类型（标量、离散）
- 内置UI组件支持
- 变更追踪和保存机制
- 灵活的过滤和组织系统
- 支持运行时动态更新选项

## GameSubtitles
游戏字幕系统插件，提供：
- 游戏内字幕显示功能
- 多语言支持
- 字幕时间轴管理

### 主要组件

1. **字幕显示选项**
```cpp
// 字幕文本大小枚举
enum class ESubtitleDisplayTextSize
{
    ExtraSmall,
    Small,
    Medium,
    Large,
    ExtraLarge
};

// 字幕文本颜色枚举
enum class ESubtitleDisplayTextColor
{
    White,
    Yellow
};

// 字幕文本边框样式枚举
enum class ESubtitleDisplayTextBorder
{
    None,
    Outline,
    DropShadow
};

// 字幕背景不透明度枚举
enum class ESubtitleDisplayBackgroundOpacity
{
    Clear,
    Low,
    Medium,
    High,
    Solid
};
```

2. **字幕显示子系统**
```cpp
// 字幕格式结构体
struct FSubtitleFormat
{
    // 字幕文本大小
    ESubtitleDisplayTextSize SubtitleTextSize;
    
    // 字幕文本颜色
    ESubtitleDisplayTextColor SubtitleTextColor;
    
    // 字幕文本边框
    ESubtitleDisplayTextBorder SubtitleTextBorder;
    
    // 字幕背景不透明度
    ESubtitleDisplayBackgroundOpacity SubtitleBackgroundOpacity;
};

// 字幕显示子系统
class USubtitleDisplaySubsystem : public UGameInstanceSubsystem
{
public:
    // 字幕显示格式变更事件
    FDisplayFormatChangedEvent DisplayFormatChangedEvent;
    
    // 设置字幕显示选项
    void SetSubtitleDisplayOptions(const FSubtitleFormat& InOptions);
    
    // 获取字幕显示选项
    const FSubtitleFormat& GetSubtitleDisplayOptions() const;
};
```

3. **字幕显示UI组件**
```cpp
// 字幕显示Widget
class USubtitleDisplay : public UWidget
{
public:
    // 字幕格式
    FSubtitleFormat Format;
    
    // 字幕显示选项
    TObjectPtr<USubtitleDisplayOptions> Options;
    
    // 文本换行宽度
    float WrapTextAt;
    
    // 检查是否有字幕
    bool HasSubtitles() const;
    
    // 预览模式相关
    bool bPreviewMode;
    FText PreviewText;
};
```

### 主要功能

1. **字幕格式化**
- 支持多种文本大小选项
- 提供白色和黄色两种文本颜色
- 支持无边框、轮廓和阴影三种边框样式
- 提供从完全透明到完全不透明的背景选项

2. **字幕显示管理**
- 通过游戏实例子系统统一管理字幕显示
- 支持动态更新字幕显示格式
- 提供字幕格式变更事件通知机制

3. **UI集成**
- 提供可自定义的字幕显示Widget
- 支持文本自动换行
- 包含预览模式，方便在编辑器中设计UI

### 使用示例

1. **基本字幕设置**
```cpp
// 获取字幕子系统
UGameSubtitlesSystem* SubtitlesSystem = GEngine->GetGameInstance()->GetSubsystem<UGameSubtitlesSystem>();

// 设置字幕显示选项
FSubtitleFormat SubtitleFormat;
SubtitleFormat.BackgroundOpacity = 0.8f;
SubtitleFormat.TextSize = 20.0f;
SubtitlesSystem->SetSubtitleFormat(SubtitleFormat);

// 显示字幕
FSubtitleEntry SubtitleEntry;
SubtitleEntry.Text = FText::FromString("Hello World");
SubtitleEntry.Duration = 3.0f;
SubtitlesSystem->DisplaySubtitle(SubtitleEntry);
```

2. **本地化支持**
```cpp
// 添加本地化字幕
FSubtitleEntry LocalizedSubtitle;
LocalizedSubtitle.Text = LOCTEXT("SubtitleKey", "Localized Message");
LocalizedSubtitle.Duration = 2.0f;
LocalizedSubtitle.Sound = SoundCue;
SubtitlesSystem->DisplaySubtitle(LocalizedSubtitle);
```

3. **字幕队列管理**
```cpp
// 清除所有字幕
SubtitlesSystem->ClearSubtitles();

// 暂停/恢复字幕显示
SubtitlesSystem->SetSubtitlesEnabled(false);
SubtitlesSystem->SetSubtitlesEnabled(true);
```

## PocketWorlds

PocketWorlds 插件提供了创建和管理独立的小型世界(Pocket Worlds)的功能。这些小型世界可以用于各种用途，如训练室、加载屏幕或独立的游戏空间。

### 主要功能

1. **世界管理**
- 创建和销毁小型世界
- 管理世界生命周期
- 提供世界间的通信机制

2. **资源控制**
- 智能资源加载和卸载
- 内存使用优化
- 异步加载支持

3. **状态同步**
- 世界状态的保存和恢复
- 跨世界数据传输
- 玩家状态同步

### 关键类和接口

1. **UPocketWorldSubsystem**
- 管理所有小型世界的创建和销毁
- 提供世界查询和遍历功能
- 处理世界间的转换

2. **FPocketWorldInstance**
- 表示一个小型世界实例
- 包含世界特定的设置和状态
- 管理实例生命周期

### 使用示例

1. **创建和管理小型世界**
```cpp
// 获取子系统
UPocketWorldSubsystem* PocketSystem = GEngine->GetWorld()->GetGameInstance()->GetSubsystem<UPocketWorldSubsystem>();

// 创建小型世界
UWorld* TrainingWorld = PocketSystem->CreatePocketWorld("/Game/Maps/TrainingRoom");

// 检查是否是小型世界
bool bIsPocket = PocketSystem->IsPocketWorld(TrainingWorld);

// 完成后销毁
PocketSystem->DestroyPocketWorld(TrainingWorld);
```

2. **使用过渡组件**
```cpp
// 在蓝图中：
// 1. 添加 PocketTransitionComponent 到 Actor
// 2. 调用 TransitionToPocketWorld 进入小型世界
// 3. 使用 ReturnToMainWorld 返回主世界
// 4. 绑定 OnTransitionComplete 处理过渡完成事件
```

### 使用建议
1. 合理规划小型世界的资源使用
2. 注意处理世界切换时的状态保存
3. 使用异步加载避免性能问题
4. 及时清理不再使用的小型世界

## UIExtension
UI扩展插件，提供了一个灵活的框架来管理和扩展用户界面。该插件支持动态UI加载、UI扩展点系统和UI元素的优先级管理。

### 主要组件

1. **UIExtensionSystem**
```cpp
// UI扩展系统
class UUIExtensionSystem : public UGameInstanceSubsystem
{
public:
    // 注册UI扩展点
    void RegisterExtensionPoint(
        const FGameplayTag& ExtensionPointTag,
        const FUIExtensionPointHandle& Handle
    );
    
    // 注册UI扩展
    FUIExtensionHandle RegisterExtension(
        const FGameplayTag& ExtensionPointTag,
        const TSubclassOf<UUserWidget>& WidgetClass,
        int32 Priority = 0
    );
    
    // 移除UI扩展
    void RemoveExtension(const FUIExtensionHandle& Handle);
};
```

2. **UIExtensionPointWidget**
```cpp
// UI扩展点Widget
class UUIExtensionPointWidget : public UWidget
{
public:
    // 扩展点标签
    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "UI Extension")
    FGameplayTag ExtensionPointTag;
    
    // 获取当前扩展
    TArray<UUserWidget*> GetExtensions() const;
    
    // 扩展变更委托
    UPROPERTY(BlueprintAssignable, Category = "UI Extension")
    FOnExtensionsChanged OnExtensionsChanged;
};
```

3. **UIExtensionSubsystem**
```cpp
// UI扩展子系统
class UUIExtensionSubsystem : public ULocalPlayerSubsystem
{
public:
    // 添加动态扩展
    FUIExtensionHandle AddExtensionWidget(
        const FGameplayTag& ExtensionPointTag,
        const TSubclassOf<UUserWidget>& WidgetClass,
        const FUIExtensionContext& Context
    );
    
    // 移除动态扩展
    void RemoveExtensionWidget(const FUIExtensionHandle& Handle);
};
```

### 主要功能

1. **扩展点系统**
- 基于GameplayTag的扩展点注册
- 支持优先级排序
- 动态扩展管理

2. **UI组件管理**
- 动态加载UI组件
- 自动布局支持
- 生命周期管理

3. **上下文系统**
```cpp
// UI扩展上下文
struct FUIExtensionContext
{
    // 数据上下文
    UObject* DataContext;
    
    // 布局数据
    FUIExtensionLayoutData LayoutData;
    
    // 优先级
    int32 Priority;
};
```

### 使用示例

1. **注册扩展点**
```cpp
// 在Widget蓝图中：
// 1. 添加 UIExtensionPointWidget
// 2. 设置 ExtensionPointTag
// 3. 绑定 OnExtensionsChanged 事件
```

2. **添加UI扩展**
```cpp
// 获取子系统
UUIExtensionSubsystem* ExtensionSystem = GetLocalPlayerSubsystem<UUIExtensionSubsystem>();

// 创建扩展上下文
FUIExtensionContext Context;
Context.DataContext = SomeDataObject;
Context.Priority = 10;

// 添加扩展
FUIExtensionHandle Handle = ExtensionSystem->AddExtensionWidget(
    FGameplayTag::RequestGameplayTag(TEXT("UI.HUD.TopRight")),
    UMyWidgetClass::StaticClass(),
    Context
);
```

### 使用建议
1. 使用有意义的GameplayTag命名扩展点
2. 合理设置扩展优先级
3. 注意及时清理不再使用的扩展
4. 使用上下文系统传递必要的数据

## ModularGameplayActors
这个插件提供了一系列基础的游戏Actor类，这些类都支持通过游戏特性插件进行扩展。该插件依赖于ModularGameplay插件。

### 主要类和功能

1. **ModularCharacter**
```cpp
// 支持游戏特性插件扩展的基础角色类
class AModularCharacter : public ACharacter
{
    // 生命周期函数
    virtual void PreInitializeComponents() override;
    virtual void BeginPlay() override;
    virtual void EndPlay() override;
};
```

2. **ModularPlayerController**
```cpp
// 支持游戏特性插件扩展的玩家控制器类
class AModularPlayerController : public APlayerController
{
    // 生命周期函数
    virtual void PreInitializeComponents() override;
    virtual void EndPlay() override;
    virtual void ReceivedPlayer() override;
    virtual void PlayerTick(float DeltaTime) override;
};
```

3. **ModularPlayerState**
```cpp
// 支持游戏特性插件扩展的玩家状态类
class AModularPlayerState : public APlayerState
{
    // 生命周期函数
    virtual void PreInitializeComponents() override;
    virtual void BeginPlay() override;
    virtual void EndPlay() override;
    virtual void Reset() override;
    virtual void CopyProperties(APlayerState* PlayerState) override;
};
```

4. **ModularPawn**
```cpp
// 支持游戏特性插件扩展的Pawn类
class AModularPawn : public APawn
{
    // 生命周期函数
    virtual void PreInitializeComponents() override;
    virtual void BeginPlay() override;
    virtual void EndPlay() override;
};
```

5. **ModularAIController**
```cpp
// 支持游戏特性插件扩展的AI控制器类
class AModularAIController : public AAIController
{
    // 生命周期函数
    virtual void PreInitializeComponents() override;
    virtual void BeginPlay() override;
    virtual void EndPlay() override;
};
```

6. **ModularGameMode和ModularGameState**
```cpp
// 基础游戏模式类
class AModularGameModeBase : public AGameModeBase { };
class AModularGameMode : public AGameMode { };

// 游戏状态类
class AModularGameStateBase : public AGameStateBase
{
    // 生命周期函数
    virtual void PreInitializeComponents() override;
    virtual void BeginPlay() override;
    virtual void EndPlay() override;
};

class AModularGameState : public AGameState
{
    // 生命周期函数
    virtual void PreInitializeComponents() override;
    virtual void BeginPlay() override;
    virtual void EndPlay() override;
    virtual void HandleMatchHasStarted() override;
};
```

### 主要功能

1. **组件管理**
- 所有模块化Actor类都支持GameFrameworkComponentManager
- 在PreInitializeComponents中注册为接收者
- 在EndPlay中移除接收者
- 在BeginPlay中发送GameActorReady事件

2. **生命周期管理**
- 统一的组件初始化和清理流程
- 支持游戏特性插件的动态加载和卸载
- 保证组件的正确生命周期管理

3. **模块化设计**
- 所有类都支持通过游戏特性插件进行扩展
- 提供完整的生命周期事件支持
- 保持基类的简洁性，便于扩展

### 使用建议
1. 在创建新的游戏Actor时，优先继承这些模块化基类
2. 利用GameFrameworkComponentManager来管理组件的生命周期
3. 使用游戏特性插件来扩展这些基类的功能
4. 注意正确处理组件的初始化和清理流程

## GameplayMessageRouter
游戏消息路由插件，提供了一个灵活的消息传递系统，用于处理游戏中的各种事件和通知。

### 消息路由模式和最佳实践

1. **Channel-Based Routing**
```cpp
// 定义消息通道
const FGameplayTag Channel_Elimination("Game.Message.Elimination");
const FGameplayTag Channel_Damage("Game.Message.Damage");

// 监听特定通道的消息
FGameplayMessageListenerHandle ListenForMessage(
    UGameplayMessageSubsystem& MessageSystem,
    const FGameplayTag& Channel,
    const TFunction<void(const FGameplayTag&, const FMessage&)>& Handler)
{
    return MessageSystem.RegisterListener(Channel, Handler);
}
```

2. **消息广播模式**
```cpp
// 消息子系统
class UGameplayMessageSubsystem
{
public:
    // 直接广播 - 最简单但最不灵活
    void BroadcastMessage(const FGameplayTag& Channel, const FMessage& Message);

    // 带返回值的广播 - 允许监听者修改或处理消息
    template<typename T>
    T BroadcastMessageWithReturn(const FGameplayTag& Channel, const T& Message);

    // 异步广播 - 适用于不需要立即处理的消息
    void BroadcastMessageAsync(const FGameplayTag& Channel, const FMessage& Message);
};
```

3. **消息处理最佳实践**
- 使用层级化的GameplayTag来组织消息通道
- 实现消息的优先级处理
- 合理使用消息过滤器
```cpp
// 消息过滤示例
FGameplayMessageListenerHandle RegisterListener(
    const FGameplayTag& Channel,
    const TFunction<void(const FGameplayTag&, const FMessage&)>& Handler,
    const TFunction<bool(const FMessage&)>& Filter)
{
    return MessageSystem.RegisterListenerWithFilter(Channel, Handler, Filter);
}
```

### 与Gameplay Ability System集成

1. **能力触发和响应**
```cpp
// 在Gameplay Ability中发送消息
void UMyGameplayAbility::ActivateAbility()
{
    Super::ActivateAbility();

    // 发送能力激活消息
    FAbilityActivatedMessage Msg;
    Msg.AbilityClass = GetClass();
    Msg.TargetActor = GetTargetActor();
    
    UGameplayMessageSubsystem::Get(GetWorld()).BroadcastMessage(
        TAG_AbilityActivated, 
        Msg
    );
}

// 响应能力消息
void AMyCharacter::SetupMessageHandlers()
{
    UGameplayMessageSubsystem& MessageSystem = UGameplayMessageSubsystem::Get(GetWorld());
    
    // 监听能力激活消息
    MessageSystem.RegisterListener(
        TAG_AbilityActivated,
        this,
        &AMyCharacter::HandleAbilityActivated
    );
}
```

2. **GameplayEffect集成**
```cpp
// 使用消息系统通知GameplayEffect的应用
void UMyGameplayEffect::PostGameplayEffectExecute(
    const FGameplayEffectModCallbackData& Data)
{
    Super::PostGameplayEffectExecute(Data);

    FEffectAppliedMessage Msg;
    Msg.EffectClass = GetClass();
    Msg.Magnitude = Data.EvaluatedData.Magnitude;
    
    UGameplayMessageSubsystem::Get(GetWorld()).BroadcastMessage(
        TAG_EffectApplied, 
        Msg
    );
}
```

3. **属性变化通知**
```cpp
// 监听属性变化并广播消息
void UMyAttributeSet::PostGameplayEffectExecute(
    const FGameplayEffectModCallbackData& Data)
{
    Super::PostGameplayEffectExecute(Data);

    if (Data.EvaluatedData.Attribute == GetHealthAttribute())
    {
        FAttributeChangedMessage Msg;
        Msg.AttributeName = TEXT("Health");
        Msg.NewValue = GetHealth();
        Msg.OldValue = GetHealth() - Data.EvaluatedData.Magnitude;
        
        UGameplayMessageSubsystem::Get(GetWorld()).BroadcastMessage(
            TAG_AttributeChanged, 
            Msg
        );
    }
}
```

### 性能优化考虑

1. **消息队列优化**
```cpp
// 消息批处理
class FMessageBatchProcessor
{
public:
    // 添加消息到批处理队列
    void QueueMessage(const FGameplayTag& Channel, const FMessage& Message)
    {
        MessageQueue.Enqueue(FQueuedMessage{Channel, Message});
    }
    
    // 批量处理消息
    void ProcessMessageBatch()
    {
        const int32 MaxMessagesPerFrame = 100;
        int32 ProcessedCount = 0;
        
        FQueuedMessage Message;
        while (ProcessedCount < MaxMessagesPerFrame && MessageQueue.Dequeue(Message))
        {
            MessageSystem.BroadcastMessage(Message.Channel, Message.Message);
            ProcessedCount++;
        }
    }

private:
    TQueue<FQueuedMessage> MessageQueue;
};
```

2. **监听器管理**
```cpp
// 高效的监听器管理
class FGameplayMessageRegistry
{
public:
    // 使用哈希表加速监听器查找
    TMap<FGameplayTag, TArray<FMessageListener>> ListenerMap;
    
    // 使用对象池减少内存分配
    FMessageListenerPool ListenerPool;
    
    // 定期清理失效的监听器
    void CleanupStaleListeners()
    {
        for (auto& Pair : ListenerMap)
        {
            Pair.Value.RemoveAll([](const FMessageListener& Listener)
            {
                return !Listener.IsValid();
            });
        }
    }
};
```

3. **性能监控**
```cpp
// 消息系统性能监控
class FMessageSystemStats
{
public:
    // 跟踪消息处理时间
    void TrackMessageProcessing(const FGameplayTag& Channel)
    {
        double StartTime = FPlatformTime::Seconds();
        
        // 处理消息...
        
        double ProcessingTime = FPlatformTime::Seconds() - StartTime;
        UpdateChannelStats(Channel, ProcessingTime);
    }
    
    // 记录通道统计信息
    void UpdateChannelStats(const FGameplayTag& Channel, double ProcessingTime)
    {
        FChannelStats& Stats = ChannelStats.FindOrAdd(Channel);
        Stats.TotalMessages++;
        Stats.TotalProcessingTime += ProcessingTime;
        Stats.AverageProcessingTime = Stats.TotalProcessingTime / Stats.TotalMessages;
    }
    
private:
    TMap<FGameplayTag, FChannelStats> ChannelStats;
};
```

4. **最佳实践建议**
- 使用消息批处理来减少每帧的处理开销
- 实现消息优先级系统，确保重要消息优先处理
- 合理使用消息过滤器减少不必要的消息传递
- 定期清理未使用的监听器
- 监控消息系统性能，及时发现和解决性能瓶颈
- 考虑使用对象池来减少频繁的内存分配和释放

 
## GameFeatures（补充）

### GameFeatures与模块化Gameplay框架的关系

1. **架构设计**
```cpp
// GameFeature插件模块基类
class FGameFeaturePluginModule : public IModuleInterface
{
public:
    // 插件生命周期管理
    virtual void StartupModule() override;
    virtual void ShutdownModule() override;
    
    // 注册游戏特性行为
    void RegisterGameFeatureActions(
        const FString& FeatureName,
        const TArray<UGameFeatureAction*>& Actions
    );
};

// 游戏特性子系统
class UGameFeaturesSubsystem : public UEngineSubsystem
{
public:
    // 加载游戏特性
    void LoadGameFeaturePlugin(
        const FString& PluginName,
        const FGameFeaturePluginRequestOptions& Options
    );
    
    // 激活游戏特性
    void ActivateGameFeaturePlugin(
        const FString& PluginName,
        const FGameFeaturePluginRequestOptions& Options
    );
};
```

2. **与ModularGameplay的集成**
```cpp
// 游戏特性组件管理器
class UGameFeatureComponentManager : public UGameInstanceSubsystem
{
public:
    // 添加组件到Actor
    template<class T>
    T* AddComponentToActor(
        AActor* Actor,
        const FGameFeatureComponentEntry& ComponentEntry
    );
    
    // 处理组件依赖
    void HandleComponentDependencies(
        AActor* Actor,
        const TArray<FGameFeatureComponentEntry>& ComponentEntries
    );
};

// 游戏特性世界系统
class UGameFeatureWorldSystem : public UWorldSubsystem
{
public:
    // 注册世界事件监听器
    void RegisterWorldEventListener(
        const FGameFeatureWorldEventListener& Listener
    );
    
    // 处理世界状态变化
    void HandleWorldStateChange(
        const FWorldStateChangeEvent& Event
    );
};
```

3. **数据驱动的游戏逻辑**
```cpp
// 游戏特性数据资产
class UGameFeatureData : public UPrimaryDataAsset
{
public:
    // 游戏特性行为
    UPROPERTY(EditAnywhere, Instanced, Category = "Actions")
    TArray<UGameFeatureAction*> Actions;
    
    // 依赖的其他游戏特性
    UPROPERTY(EditAnywhere, Category = "Dependencies")
    TArray<FString> GameFeatureDependencies;
    
    // 所需的插件依赖
    UPROPERTY(EditAnywhere, Category = "Dependencies")
    TArray<FString> PluginDependencies;
};
```

### 插件依赖管理

1. **依赖声明和验证**
```cpp
// 插件描述符
struct FGameFeaturePluginDescriptor
{
    // 插件基本信息
    FString PluginName;
    FString Version;
    
    // 依赖信息
    TArray<FGameFeatureDependency> Dependencies;
    
    // 验证依赖
    bool ValidateDependencies(FString& OutError) const
    {
        for (const auto& Dependency : Dependencies)
        {
            if (!IsDependencyAvailable(Dependency))
            {
                OutError = FString::Printf(
                    TEXT("Missing dependency: %s (version %s)"),
                    *Dependency.PluginName,
                    *Dependency.Version
                );
                return false;
            }
        }
        return true;
    }
};
```

2. **运行时依赖加载**
```cpp
// 依赖加载器
class FGameFeatureDependencyLoader
{
public:
    // 加载所有依赖
    bool LoadDependencies(
        const FGameFeaturePluginDescriptor& Descriptor,
        const FGameFeatureLoadingContext& Context
    )
    {
        // 构建依赖图
        TArray<FGameFeatureDependency> OrderedDependencies;
        if (!BuildDependencyGraph(Descriptor, OrderedDependencies))
        {
            return false;
        }
        
        // 按顺序加载依赖
        for (const auto& Dependency : OrderedDependencies)
        {
            if (!LoadSingleDependency(Dependency, Context))
            {
                return false;
            }
        }
        
        return true;
    }
    
protected:
    // 加载单个依赖
    bool LoadSingleDependency(
        const FGameFeatureDependency& Dependency,
        const FGameFeatureLoadingContext& Context
    );
    
    // 构建依赖图
    bool BuildDependencyGraph(
        const FGameFeaturePluginDescriptor& Descriptor,
        TArray<FGameFeatureDependency>& OutOrderedDependencies
    );
};
```

3. **版本兼容性管理**
```cpp
// 版本兼容性检查器
class FGameFeatureVersionChecker
{
public:
    // 检查版本兼容性
    bool CheckVersionCompatibility(
        const FString& RequiredVersion,
        const FString& AvailableVersion
    )
    {
        FVersionNumber Required, Available;
        if (FVersionNumber::Parse(RequiredVersion, Required) &&
            FVersionNumber::Parse(AvailableVersion, Available))
        {
            return Available >= Required;
        }
        return false;
    }
    
    // 获取兼容版本范围
    void GetCompatibleVersionRange(
        const FString& Version,
        FString& OutMinVersion,
        FString& OutMaxVersion
    );
};
```

### 创建新游戏特性插件的最佳实践

1. **插件结构组织**
```
MyGameFeature/
├── Config/
│   └── DefaultGameFeatureData.ini
├── Content/
│   └── Data/
│       └── DA_MyGameFeature.uasset
├── Source/
│   ├── Public/
│   │   └── MyGameFeatureModule.h
│   └── Private/
│       └── MyGameFeatureModule.cpp
└── MyGameFeature.uplugin
```

2. **初始化和清理**
```cpp
// 游戏特性模块实现
class FMyGameFeatureModule : public FGameFeaturePluginModule
{
public:
    // 模块初始化
    virtual void StartupModule() override
    {
        // 1. 注册自定义行为
        RegisterCustomActions();
        
        // 2. 设置资源引用
        SetupAssetReferences();
        
        // 3. 注册组件扩展
        RegisterComponentExtensions();
    }
    
    // 模块清理
    virtual void ShutdownModule() override
    {
        // 1. 清理组件扩展
        UnregisterComponentExtensions();
        
        // 2. 清理资源引用
        CleanupAssetReferences();
        
        // 3. 注销自定义行为
        UnregisterCustomActions();
    }
    
protected:
    // 注册自定义行为
    void RegisterCustomActions()
    {
        // 实现自定义游戏特性行为
    }
    
    // 设置资源引用
    void SetupAssetReferences()
    {
        // 处理资源加载和引用
    }
    
    // 注册组件扩展
    void RegisterComponentExtensions()
    {
        // 注册组件到扩展系统
    }
};
```

3. **配置和数据管理**
```cpp
// 游戏特性数据资产
class UMyGameFeatureData : public UGameFeatureData
{
    GENERATED_BODY()
    
public:
    // 自定义配置数据
    UPROPERTY(EditAnywhere, Category = "Configuration")
    FMyFeatureConfig FeatureConfig;
    
    // 扩展点配置
    UPROPERTY(EditAnywhere, Category = "Extensions")
    TArray<FGameFeatureExtensionPoint> ExtensionPoints;
    
    // 验证配置
    virtual bool ValidateConfiguration(FString& OutError) const override;
};

// 特性配置结构体
USTRUCT()
struct FMyFeatureConfig
{
    GENERATED_BODY()
    
    // 配置项
    UPROPERTY(EditAnywhere)
    bool bEnabled;
    
    UPROPERTY(EditAnywhere)
    float ConfigValue;
    
    // 验证配置
    bool Validate(FString& OutError) const;
};
```

4. **最佳实践建议**

- **模块化设计**
  - 将功能划分为独立的模块
  - 使用接口定义模块间的交互
  - 避免硬编码依赖

- **资源管理**
  - 使用异步加载优化性能
  - 实现资源引用计数
  - 使用软引用管理资源
  - 及时释放未使用的资源

- **扩展性考虑**
  - 提供清晰的扩展点
  - 使用数据驱动的配置
  - 支持运行时的动态加载

- **测试和调试**
  - 编写单元测试
  - 实现调试工具和日志
  - 提供配置验证机制

- **文档和版本控制**
  - 维护清晰的文档
  - 使用语义化版本号
  - 记录API变更历史


## CommonUser（补充）

### 平台特定实现

1. **平台用户系统适配**
```cpp
// 平台特定的用户系统实现
class FPlatformUserSystem
{
public:
    // Steam平台实现
    class FSteamUserSystem : public FPlatformUserSystem
    {
        // Steam特定的用户认证
        virtual bool AuthenticateUser(
            const FSteamAuthParams& AuthParams,
            const FOnAuthComplete& OnComplete
        ) override;
        
        // Steam好友系统集成
        virtual void GetFriendsList(
            const FString& UserId,
            const FOnGetFriendsComplete& OnComplete
        ) override;
    };
    
    // Epic在线服务实现
    class FEOSUserSystem : public FPlatformUserSystem
    {
        // EOS特定的用户认证
        virtual bool AuthenticateUser(
            const FEOSAuthParams& AuthParams,
            const FOnAuthComplete& OnComplete
        ) override;
        
        // EOS社交功能集成
        virtual void GetSocialPresence(
            const FString& UserId,
            const FOnGetPresenceComplete& OnComplete
        ) override;
    };
    
    // 控制台平台实现
    class FConsoleUserSystem : public FPlatformUserSystem
    {
        // 控制台特定的用户管理
        virtual void HandleControllerPairingChanged(
            const FUniqueNetId& UserId,
            const FControllerPairingChangedParams& Params
        ) override;
        
        // 控制台特定的权限检查
        virtual bool CheckPrivileges(
            const FUniqueNetId& UserId,
            const EUserPrivileges::Type Privilege
        ) override;
    };
};
```

2. **平台特定UI处理**
```cpp
// 平台登录UI管理器
class FPlatformLoginUIManager
{
public:
    // 显示平台特定的登录UI
    virtual void ShowLoginUI(
        const FShowLoginUIParams& Params,
        const FOnLoginUIComplete& OnComplete
    );
    
    // 处理平台特定的UI事件
    virtual void HandlePlatformUIEvent(
        const FPlatformUIEvent& Event
    );
    
protected:
    // Steam登录UI
    void ShowSteamLoginUI(const FSteamLoginUIParams& Params);
    
    // Epic登录UI
    void ShowEpicLoginUI(const FEpicLoginUIParams& Params);
    
    // 控制台登录UI
    void ShowConsoleLoginUI(const FConsoleLoginUIParams& Params);
};
```

3. **平台特定数据存储**
```cpp
// 平台用户数据管理
class FPlatformUserData
{
public:
    // 保存用户数据到平台特定位置
    virtual bool SaveUserData(
        const FString& UserId,
        const FUserDataPayload& Data
    );
    
    // 从平台特定位置加载用户数据
    virtual bool LoadUserData(
        const FString& UserId,
        FUserDataPayload& OutData
    );
    
protected:
    // Steam云存储实现
    bool SaveToSteamCloud(const FString& UserId, const FUserDataPayload& Data);
    
    // Epic云存储实现
    bool SaveToEpicCloud(const FString& UserId, const FUserDataPayload& Data);
    
    // 控制台存储实现
    bool SaveToConsoleStorage(const FString& UserId, const FUserDataPayload& Data);
};
```

### 错误处理和回退机制

1. **错误处理系统**
```cpp
// 用户系统错误处理
class FCommonUserErrorHandler
{
public:
    // 错误类型枚举
    enum class EUserError
    {
        None,
        NetworkError,
        AuthenticationFailed,
        PrivilegeCheckFailed,
        PlatformServiceUnavailable,
        // ...
    };
    
    // 错误处理接口
    virtual void HandleError(
        const EUserError ErrorType,
        const FString& ErrorMessage,
        const FErrorContext& Context
    );
    
    // 注册错误回调
    void RegisterErrorCallback(
        const FOnUserError& Callback,
        const EUserError ErrorType
    );
    
protected:
    // 实现特定错误的处理逻辑
    virtual void HandleNetworkError(const FErrorContext& Context);
    virtual void HandleAuthError(const FErrorContext& Context);
    virtual void HandlePrivilegeError(const FErrorContext& Context);
};
```

2. **回退机制**
```cpp
// 认证回退系统
class FAuthenticationFallback
{
public:
    // 配置回退选项
    struct FFallbackOptions
    {
        bool bAllowOfflineMode;
        bool bAllowGuestLogin;
        int32 MaxRetryAttempts;
        float RetryDelay;
    };
    
    // 执行认证回退
    void ExecuteFallback(
        const FAuthenticationContext& Context,
        const FFallbackOptions& Options
    );
    
protected:
    // 回退策略实现
    bool TryOfflineMode(const FAuthenticationContext& Context);
    bool TryGuestLogin(const FAuthenticationContext& Context);
    bool ScheduleRetry(const FAuthenticationContext& Context);
};

// 服务可用性检查
class FServiceAvailabilityChecker
{
public:
    // 检查服务状态
    bool CheckServiceStatus(const FString& ServiceName);
    
    // 获取备用服务
    TArray<FString> GetAlternativeServices(const FString& ServiceName);
    
    // 切换到备用服务
    bool SwitchToAlternativeService(const FString& CurrentService);
};
```

3. **恢复机制**
```cpp
// 会话恢复系统
class FSessionRecoverySystem
{
public:
    // 保存会话状态
    void SaveSessionState(const FSessionState& State);
    
    // 尝试恢复会话
    bool TryRecoverSession(
        const FString& UserId,
        const FOnSessionRecovered& OnComplete
    );
    
    // 清理过期会话
    void CleanupExpiredSessions();
    
protected:
    // 验证会话有效性
    bool ValidateSessionState(const FSessionState& State);
    
    // 重建会话数据
    bool ReconstrucSessionData(const FSessionState& State);
};
```

### 与Online Subsystems集成

1. **Online Subsystem接口适配**
```cpp
// Online Subsystem适配器
class FOnlineSubsystemAdapter
{
public:
    // 初始化Online Subsystem
    bool Initialize(const FString& SubsystemName);
    
    // 获取身份接口
    TSharedPtr<IOnlineIdentity> GetIdentityInterface();
    
    // 获取好友接口
    TSharedPtr<IOnlineFriends> GetFriendsInterface();
    
    // 获取会话接口
    TSharedPtr<IOnlineSession> GetSessionInterface();
    
protected:
    // 处理子系统状态变化
    void HandleSubsystemStatusChange(const FString& SubsystemName, bool bIsAvailable);
    
    // 更新子系统接口
    void UpdateSubsystemInterfaces();
};
```

2. **统一身份管理**
```cpp
// 统一身份管理器
class FUnifiedIdentityManager
{
public:
    // 用户登录
    void Login(
        const FLoginParams& Params,
        const FOnLoginComplete& OnComplete
    );
    
    // 用户注销
    void Logout(
        const FString& UserId,
        const FOnLogoutComplete& OnComplete
    );
    
    // 身份验证
    void Authenticate(
        const FAuthParams& Params,
        const FOnAuthComplete& OnComplete
    );
    
protected:
    // 处理多平台身份
    void HandleCrossPlayIdentity(const FCrossPlayIdentityContext& Context);
    
    // 合并用户账户
    bool MergeUserAccounts(
        const FString& PrimaryUserId,
        const FString& SecondaryUserId
    );
};
```

3. **跨平台数据同步**
```cpp
// 跨平台数据同步器
class FCrossPlatformDataSynchronizer
{
public:
    // 同步用户数据
    void SyncUserData(
        const FString& UserId,
        const FOnSyncComplete& OnComplete
    );
    
    // 解决数据冲突
    void ResolveDataConflicts(
        const FString& UserId,
        const TArray<FDataConflict>& Conflicts,
        const FOnConflictResolved& OnComplete
    );
    
protected:
    // 确定主数据源
    EPlatformDataSource DeterminePrimaryDataSource(
        const TArray<FPlatformDataInfo>& DataSources
    );
    
    // 合并数据
    bool MergeData(
        const FUserData& LocalData,
        const FUserData& RemoteData,
        FUserData& OutMergedData
    );
};
```

4. **集成最佳实践**

- **初始化流程**
  - 按优先级初始化Online Subsystems
  - 验证服务可用性
  - 设置默认子系统

- **错误处理**
  - 实现全面的错误日志
  - 提供用户友好的错误提示
  - 实现优雅的服务降级

- **数据管理**
  - 实现数据版本控制
  - 提供数据迁移机制
  - 确保数据一致性

- **性能优化**
  - 实现请求批处理
  - 使用适当的缓存策略
  - 优化网络请求

- **安全考虑**
  - 实现令牌管理
  - 加密敏感数据
  - 防止重放攻击

```
