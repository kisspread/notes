 # UE 提示与最佳实践
 
 [Source](https://ari.games/)
 
 
 **🧠  前置提示！为你所学的知识创建自己的文档（txt文件、google doc等）。Unreal Engine 功能繁多，有许多特性、选项、旋钮、按钮和复选框，不可能全部记在脑子里。**
 
 :::details 更多
 # 子页面
 
 [查找依赖项](https://www.notion.so/Finding-dependencies-28d011a87cae8101895fe28a20a7937b?pvs=21)
 
 [每个Actor一个文件 - 命名规范](https://www.notion.so/One-File-Per-Actor-Naming-28d011a87cae81269801dd5ad073d388?pvs=21)
 
 [在C++中加载资源](https://www.notion.so/Loading-assets-in-C-28d011a87cae81ceb1aadaf01b137a2e?pvs=21)
 
 [反射](https://www.notion.so/Reflection-28d011a87cae81f4ace5f5ad17244cc3?pvs=21)
 
 [PSO预缓存调查](https://www.notion.so/PSO-Precache-Investigating-28d011a87cae81d0b8b4f5815f90dba4?pvs=21) 
 :::
 
 # 编辑器可用性
 
 - CTRL+P或SHIFT+ALT+O快速打开对话框。
 - CTRL+B跳转到资源。
 - 按住右键+WASD导航视口时，可以滚动鼠标来加速/减速。
 - 按住CTRL键，使用滚轮可以在图表中进一步放大三个级别。
 - 蓝图高级搜索
   - “+”表示精确匹配：`Nodes( Name = +"SetTransform" )`
   - `Nodes(Name=PrintString) && Path=Gameplay/Enemies/MyBoss`
   - `ParentClass=BP_EnemyWeapon && All(Name=EventTick)`
 - 内容浏览器高级搜索
   - `ParentClass=BP_EnemyWeapon`（搜索父类为BP_EnemyWeapon的资源）
   - `Vertices > 50`（搜索顶点数大于50的资源）
   - 更多细节见[这篇文章](https://www.unrealdirective.com/unreal-search-syntax/)。
 - 设计关卡时使用书签（按ctrl+[0-9]添加书签，按[0-9]跳转）。书签会保存到关卡中并与团队成员共享。
 - [样条线生成面板](https://twitter.com/TheRealSpoonDog/status/1232082595959033857?s=20)是创建基本样条线形状的超快速便捷方式。
 - 在编辑器中，按ALT+F切换雾效可见性，按G切换编辑器/游戏视图，按T切换半透明选择。
 - ALT+R可[切换灯光半径指示器](https://twitter.com/unrealdirective/status/1482536530207920128)。
 - 使用属性矩阵进行多资源编辑。
 - 使用开发者文件夹存放需要同步到版本控制但不应作为项目一部分发布的内容。
 - 根据需要在内容浏览器中使用"显示C++/引擎内容/开发者文件夹/插件内容"选项。
 - 右键点击.uproject文件→启动游戏，或从VS或命令行使用"-game"参数启动编辑器，可在不进行完整构建的情况下打开游戏（不算作PIE会话）。
 - 无需制作完整打包构建即可测试非编辑器构建。在Unreal编辑器中只需选择平台→Windows→烘焙内容，关闭编辑器，然后从Visual Studio以任何非编辑器配置（如`Development`而非`Development Editor`）启动游戏。
 - 设置个人编辑器启动地图：`编辑器首选项`→`常规`→`加载与保存`→`启动`→`启动时加载关卡`：最近打开/项目默认/空关卡。此设置不会影响团队其他成员。
 - 控制PIE游戏是否默认获取鼠标控制：`编辑器首选项`→`关卡编辑器播放`→`游戏获取鼠标控制`。
 - 你可以点击属性旁的箭头来设置资源在世界中的缩放/旋转/位置是绝对还是相对的。
 - 要在编辑器窗口顶部显示编辑器帧率、内存和UObject计数：`编辑器首选项`→`常规`→`性能`→`显示帧率和内存`。
 - 要更改新蓝图中默认创建的BP节点（如Event BeginPlay等），可在`DefaultEditorPerProjectUserSettings.ini`中覆盖`[DefaultEventNodes] Node`设置（详见`BaseEditorPerProjectUserSettings.ini`中的默认值）。
 - 要能够检查仅在运行时添加到Actor的组件，取消勾选`编辑器首选项`→`内容编辑器`→`蓝图编辑器`→`在细节视图中隐藏构造脚本组件`。[示例图片](https://twitter.com/flassari/status/1428291066483068928)。
 - 对于程序员：每次从Visual Studio启动游戏/编辑器时，它都会花费时间为每个加载的模块加载符号。你可以在VS中将自动符号加载设置为`仅指定模块`，并关闭`始终加载模块旁的符号`。
   - 没有加载符号的模块不会命中断点，但你可以将这些模块添加到`仅指定模块`设置中。
   - 你可以在VS的模块窗口或调用堆栈中加载模块符号。
   - 更多信息见[这篇文章](https://devblogs.microsoft.com/devops/understanding-symbol-files-and-visual-studios-symbol-settings/)的下半部分。
 - 在游戏项目中，波浪号(~)是打开控制台的默认键（Escape下方的按钮）。使用其他语言环境的国家在UE中默认有针对自己键盘的覆盖设置，但如果你的非美式键盘按钮不起作用，可以在电脑上为所有游戏重新绑定：`我的文档/Unreal Engine/Engine/Config/UserInput.ini`：`[/Script/Engine.InputSettings] +ConsoleKeys=Insert`（或任何你喜欢的按钮）。
 - 要使BP窗口在特定计算机上的所有项目中默认始终停靠，创建`我的文档/Unreal Engine/Engine/Config/UserEditorPerProjectUserSettings.ini`并放入`[/Script/UnrealEd.EditorStyleSettings] AssetEditorOpenLocation=MainWindow`。
 注意：在5.1之前，类别是`[/Script/**EditorStyle**.EditorStyleSettings]`。
 - 禁用"NTFS最后访问时间"可提高Windows文件操作性能。
   - 以管理员权限启动cmd并运行`fsutil behavior set disablelastaccess 3`。恢复时运行`fsutil behavior set disablelastaccess 2`。
   - Unreal现在有一个插件会通知你是否启用了此功能；为项目启用**编辑器系统配置助手**插件，团队成员若启用了最后访问时间会收到快速修复按钮提示。
 
 # 扩展编辑器
 
 - 使用[编辑器工具窗口小部件](https://docs.unrealengine.com/en-US/InteractiveExperiences/UMG/UserGuide/EditorUtilityWidgets/index.html)通过蓝图和UMG轻松创建自己的编辑器面板。
 - 你可以通过子类化`EditorUtilityToolMenuEntry`在BP中扩展编辑器菜单和工具栏。[查看方法](https://twitter.com/MilkyEngineer/status/1379644279480446982)。
   - 另一种查看扩展点的方法是检查`编辑器首选项`→`常规`→`杂项`→`开发者工具`→`显示UI扩展点`（需要重启）。[查看方法](https://twitter.com/flassari/status/1428295285743276036)。
 
 # 性能
 
 - 你需要观看这两个演讲：
   - [优化UE5：为高质量视觉效果重新思考性能范式 - 第1部分：Nanite和Lumen](https://dev.epicgames.com/community/learning/talks-and-demos/Vpv2/unreal-engine-optimizing-ue5-rethinking-performance-paradigms-for-high-quality-visuals-part-1-nanite-and-lumen-unreal-fest-2023)
   - [优化UE5：为高质量视觉效果重新思考性能范式 - 第2部分：支持系统](https://dev.epicgames.com/community/learning/talks-and-demos/VlO2/unreal-engine-optimizing-ue5-rethinking-performance-paradigms-for-high-quality-visuals-pt-2-supporting-systems-unreal-fest-2023)
 - "Epic"（默认）画质等级通常由Epic Games调整为在新一代平台或高端PC上以30fps运行。"High"画质等级调整为60fps。如果你尝试将"Epic"画质等级调整为60fps，将会面临很大挑战。[来源](https://www.youtube.com/watch?v=Cb63bHkWkwk&t=5035s)。
 - 尽可能使用"仅在渲染时 tick"。
 - 并非所有内容都需要每帧tick，特别是距离较远或不可见的对象。
 - 蓝图默认在`PrePhysics` Tick Group中tick。如果你不需要读取或设置任何变换或碰撞，将tick移至`DuringPhysics`以优化帧时间。
 - 利用重要性管理器（Significance Manager）。
 - 如果网格体不需要复杂物理，使用简单物理。
 - 如果网格体不需要物理碰撞，禁用它。
 - 构造脚本仅在编辑器中或烘焙时运行（动态生成的Actor除外），并被序列化到关卡中，它们可以执行你不希望在运行时影响性能的繁重工作。
 - 游戏线程非常重要，不要阻塞它。如果你能在加载时不阻塞它，就能无卡顿地加载游戏部分，意味着可以在其他内容运行时加载（如蜘蛛侠的地铁场景，或通过视频隐藏加载屏幕，甚至在游戏过程中）。
 - 如果你想在其他线程中进行计算，除非你了解GC在线程方面的复杂性（如Async标志防止收集、生命周期和锁），否则应避免创建或操作UObject。最安全的方式是使用不含UObject的FStruct，然后在游戏线程上将结果转换到UE环境中。
 - 保持UObject数量较低，如果数量过多会减慢垃圾回收。使用`obj list`等命令（如`obj list class=xx`）查找问题对象。更多关于垃圾回收性能和故障排除的内容见‣。
   - 你可以添加-CountSort按UObject数量排序。
   - 大型AAA游戏应能在打包游戏中保持30万以下对象。
 - 考虑为游戏进行*配置文件引导优化*构建。虽然很少有人这样做，但可能会有效果。
 - 如果你有很多仅针对玩家的触发体积，考虑使用PlayerOnly碰撞，而不是与所有对象碰撞然后转换为玩家来检查是否命中。[来源](https://youtu.be/xIQI6nXFygA?si=DCouHVY7PNcam9O-&t=1976)。
   - [一个优秀的演讲](https://www.youtube.com/watch?v=xIQI6nXFygA)关于管理物理碰撞设置和查询。
 
 # 规范
 
 - 使用大小映射（右键点击资源，"大小映射"）查看资源通过依赖项加载的大小。
 - Unreal的内部资源路径始终以`/Game`（或`/PluginName`）开头，即使驱动器上的文件夹名为`/Content`。
 - 不要使用 widget 绑定，使用事件调度器。
   - 查看新的[ViewModel插件](https://docs.unrealengine.com/5.3/en-US/umg-viewmodel/)作为将数据发送到widget的首选方式。
 - 使用并扩展Cheat Manager。
 - 使用`#if UE_WITH_CHEAT_MANAGER`在发布构建中剥离不需要编译的作弊函数。
 - 能够从任何地图开始游戏。构建你的蓝图和管理器以支持这一点。能够跳转到游戏的任何部分开始玩是非常有用的。
 - 使用数据验证器，你也可以在蓝图中创建它们。([文档](https://docs.unrealengine.com/4.26/en-US/ProgrammingAndScripting/ProgrammingWithCPP/Assets/DataValidation/)，[示例Twitter线程](https://twitter.com/MilkyEngineer/status/1187362686998237184))
   - `UObject::IsDataValid`显然也有效。
   - 开启`bValidateAssetsWhileSavingForCook`使验证器在烘焙时运行。
   - **DefaultEditor.ini**：
   `[/Script/DataValidation.DataValidationSettings]
   bValidateOnSave=true`（保存资产时运行验证，推荐）
   `[/Script/DataValidation.EditorValidatorSubsystem]
   bValidateAssetsWhileSavingForCook=true`（烘焙游戏时运行验证，推荐）
   `bAllowBlueprintValidators=true`（允许在蓝图中创建验证器）
 - 在整个项目中保持性能检查，这使开发更容易，特别是对于设计师的平衡工作。
 - 删除不需要的资产。它们占用空间，使UE版本升级困难，当父BP或代码更改时可能会损坏，并在DDC烘焙时花费时间。
 - 考虑禁用Actor上的"允许播放前tick"。
 - 不要通过硬编码C++代码路径加载资产，使用`UPROPERTIES`或Primary Assets。尤其不要在类C++构造函数中使用ConstructorHelpers加载资产，它们会非常早地加载并添加到"GC忽略列表"中，永远不会被垃圾回收。如果它们后来引用非忽略GC的资产，还会导致崩溃。更多内容见[在C++中加载资产](https://www.notion.so/Loading-assets-in-C-28d011a87cae81ceb1aadaf01b137a2e?pvs=21)。
 - 切换关卡、关闭游戏或结束PIE会话时，Actor的`Destroy`和`EndPlay`也会被调用。考虑添加`GetWorld()->bIsTearingDown`检查来跳过在这种情况下不需要的工作（如生成新Actor），当退出PIE或退出游戏时调用EndPlay函数，此值为true。
 - 始终将`BeginPlay`与`EndPlay`配对使用（而不是`OnDestroy`），因为在调用Destroy之前，Actor可能会在关卡范围内切换可见性。因此，`BeginPlay`可以被多次调用，但总会与`EndPlay`调用配对。
 - 保持重定向器（redirectors）正常。
   - 在内容浏览器中显示重定向器，并记得定期修复它们。
   - 对于较大的团队，修复重定向器可能有风险，因为未提交的更改可能仍引用它们。保留重定向器，仅在假期前后运行ResavePackagesCommandlet后清理它们，这会修复所有资产中对它们的引用。
 
 # 烘焙
 
 - 默认情况下，没有资产被标记为需要烘焙。但同样默认情况下，如果没有资产被标记为需要烘焙，则**所有**资产都会被标记为需要烘焙。这会严重膨胀你的游戏，因为未引用的资产也会包含在构建中。[信息Twitter线程](https://x.com/flassari/status/1799104280726741036)。
   - 在`项目设置`→`游戏`→`资产管理器`→`PrimaryAssetTypesToScan`数组中，你可以将Maps的`CookRule`更改为`AlwaysCook`并禁用`EditorOnly`。这样只有`/Content/Maps`文件夹（和/或你在该规则中定义的任何其他文件夹）中的地图会被烘焙，以及它们引用的任何其他资产。**在我看来这是最佳选择。**
   - 创建一个新的`PrimaryAssetTypesToScan`规则，将`CookRule`设置为`AlwaysCook`也足以防止所有内容被烘焙，只要它添加了实际资产。
   - 如果你希望游戏中的所有地图（无论哪个文件夹或插件）都被烘焙，以及它们引用的任何其他资产，你也可以启用`项目设置`→`项目`→`打包`→`高级`→`仅烘焙地图（仅影响cookall）`。你还需要启用`CookAll`，否则如果你手动添加任何要烘焙的资产，此设置将被忽略。
   - 最后，较大的项目/工作室通常会覆盖`AssetManager`类，以更详细地控制其资产管理和烘焙。如果`AssetManager`添加了任何要烘焙的资产，则会阻止默认行为。
 - 不要使用`DirectoriesToAlwaysCook`烘焙整个文件夹，除非是仅从代码加载的原始数据。相反，将动态加载的资产定义为Primary Assets。
   - 你也可以使用`UAssetManager`并根据需要覆盖它（并非所有项目都需要）。
   - 对于整个文件夹，你可以使用`Primary Asset Labels`。
 - 仅在本地修改蓝图时使用迭代烘焙。不要在CI构建服务器上使用，它不是很稳定，特别是代码更改时。
   - 我们正在为Unreal 5.5+开发新的真正增量烘焙系统。[更多信息](https://youtube.com/watch?t=2782s&v=y98YGAr_Qis)。
 - 保持烘焙的确定性。蓝图构造函数尤其应该是确定性的。如果你需要随机化，使其基于种子或某些其他静态信息，如Actor的位置。使用相同的资产，你的构建不会不同，并且可以像某些平台那样使用资产的文件哈希进行更新。
 - 找到一种方法进行"小子集"烘焙（即我只想烘焙测试关卡和运行它所需的足够资产），当游戏增长时，这将帮助你找出"仅在烘焙构建中"的问题。通常通过仅烘焙某些地图来完成，确保引用有序，不会"拉入"游戏的其他部分。
   - 当[增量烘焙](https://youtube.com/watch?t=2782s&v=y98YGAr_Qis)准备好后，这将不再是问题。
 - 要烘焙单个地图甚至单个资产，运行`run=cook -targetplatform=<platform> -cooksinglepackagenorefs -map=<map or asset path>`。[来源](https://twitter.com/hublan2/status/1742620741995258295)。
 - **要让烘焙器记录哪些资产被烘焙，以及哪个依赖项触发了它，这有助于了解哪些资产出错和警告**，可以执行以下操作之一：
 - `项目设置`→`引擎`→`烘焙器`→`烘焙器`→`烘焙器进度显示模式` = `Instigators and Names (and Count)`。
 - DefaultEngine.ini: `[Script/UnrealEd.CookOnTheFlyServer] cook.displaymode=6`
 - 启动选项: `-ExecCmds="cook.displaymode 6"`
 - 控制台命令: `cook.displaymode=6` 
 (0: 不显示, 1: 显示剩余包数量, 2: 显示每个包名称, 3: 名称和数量, 4: 触发者, 5: 触发者和数量, 6: 触发者和名称, 7: 触发者、名称和数量)
 - 如果你有一些不打算随游戏发布的测试地图，不要将它们放在/Maps文件夹中。项目通常会标记该文件夹中的所有地图进行烘焙。将它们放在其他文件夹中，更好的是，将它们放在`DirectoriesToNeverCook`配置中标记的文件夹中。
 - 你可以将`Meta`属性`Untracked`添加到`SoftObjectPointer`/`SoftClassPointer`，使其不被视为依赖项。
   - 你可以修改引擎以支持`Untracked`数组，并使用户能够在BP编辑器中执行此操作：‣。
 
 # 项目设置
 
 - 对于从源代码构建UE的项目，你的项目文件夹应位于你使用的Unreal Engine的同一父文件夹中，以被视为"原生项目"（有时在文档中称为"非外来"项目）。如果它在其他位置，则被视为"外来"（或非原生）项目，与许多构建工具（如Horde）的兼容性不如原生项目。更多信息[这里](https://docs.unrealengine.com/managing-game-code-in-unreal-engine/)。（我个人注意到外来项目上的增量烘焙有问题）。
 首选的"原生"项目结构是：
 - 📂 `ParentFolder_P4`
    - 📁 `Engine`
    - 📁 `Project1`
    - 📁 `ProjectN`
    - 参见[项目文件夹结构 - 以Epic方式设置Unreal Engine工作室 | Epic开发者社区 (epicgames.com)](https://dev.epicgames.com/community/learning/tutorials/8JYW/setting-up-an-unreal-engine-studio-the-epic-way#projectfolderstructure)了解更多信息。
 - 遵循[ue4.style](http://ue4.style/)项目风格指南。
   - 查看Linter v2。
 - 遵循Epic的[编码标准](https://docs.unrealengine.com/en-US/ProductionPipelines/DevelopmentSetup/CodingStandard/index.html)。
 - 使用崩溃报告器获取崩溃信息。
   - 查看像[Sentry](https://docs.sentry.io/platforms/unreal/)、[Backtrace](https://support.backtrace.io/hc/en-us/articles/360040106172-Unreal-Integration-Guide)、[BugSplat](https://docs.bugsplat.com/introduction/getting-started/integrations/game-development/unreal-engine)、[BugSnag](https://www.bugsnag.com/platforms/unreal-engine-error-monitoring)（仅Android/iOS/Switch）这样的服务，它们允许你开箱即用地处理数据。在[这个演讲](https://www.youtube.com/watch?v=ow__LgMF5gE)中了解如何操作。
   - 注意崩溃报告器配置在`GameName\\Engine\\Programs\\CrashReportClient\\Config\\DefaultEngine.ini`中，而不是游戏的配置目录中。（不确定这是否仍然正确）
 - 为工作文件夹（或工作驱动器）设置防病毒例外以提高速度。
 - 将UE编辑器连接到源代码控制以进行资产锁定。Perforce/Plastic/SVN都是不错的选择。[Git不是](https://youtu.be/SGPleVfrPyo?t=1666)，除非你是单独工作。
 - 打开"在PIE期间提升输出日志警告"以轻松捕获警告。
 - 使用开发者文件夹存放不应发布的资产。在项目设置中将该文件夹标记为NeverCook。
 - 考虑使用Unreal Game Sync (UGS)作为项目的Perforce前端。这是"Unreal"方式，也是大多数AAA工作室使用的方式。
   - 参见[以Epic方式设置Unreal Engine工作室 | Epic开发者社区 (epicgames.com)](https://dev.epicgames.com/community/learning/tutorials/8JYW/setting-up-an-unreal-engine-studio-the-epic-way)了解更多信息。
 
 # 构建
 
 - 编译编辑器时，你很少需要制作编辑器的"已安装构建"，因为这非常耗时（数小时），你需要为每个平台的每个配置编译引擎和每个插件，这需要很长时间。相反，使用UnrealGameSync（Epic和AAA工作室的做法）或直接从Visual Studio编译项目，这也只编译你的一个平台和配置的编辑器（几分钟）。
   - 参见[以Epic方式设置Unreal Engine工作室 | Epic开发者社区 (epicgames.com)](https://dev.epicgames.com/community/learning/tutorials/8JYW/setting-up-an-unreal-engine-studio-the-epic-way)了解更多信息。
 - 添加"-buildmachine -nocodesign"或仅添加"-showallwarnings"以在日志末尾获取所有烘焙/构建警告/错误的转储。否则它会在达到一定数量后截断它们。
 - 为编辑器和游戏二进制文件版本化。通过UGS的Perforce构建会自动执行此操作。
 - 使用`DevelopmentAssetRegistry.bin`报告烘焙游戏大小，你可以将其输入到资产审计窗口。
 - 通常，编译C++代码或烘焙时，你的计算机每个硬件线程应具有2GB内存。
   - Unreal Build Tool编译时每个1.5GB**可用**内存使用一个进程。对于8核处理器，只有当你有至少12GB**可用**内存时，它才会充分利用所有8核，超线程情况下需要24GB。
 - 通常，你应该始终将编辑器构建为`Development Editor`。如果你的代码优化得难以调试，也可以使用`DebugGame Editor`。
   - 仅在进行非常繁重的引擎调试时才使用`Debug Editor`，我甚至很少需要这个。注意，这会使编辑器中的所有内容变得非常慢。
   - 在调试部分查看更多关于为特定文件或模块禁用优化的提示。
 - 你可以在`*.Target.cs`文件中使用`PreBuildSteps`和`PostBuildSteps`添加自定义的构建前或构建后步骤/钩子。查看这些属性的注释以获取更多信息。请注意，这些仅在C++项目构建时运行，如果你打包项目且无需重建，则不会运行。如果从CI服务器使用BuildGraph构建，也可以考虑将这些额外步骤放入BuildGraph文件中。
   - 你也可以让UGS执行自定义构建步骤，这可能是更好的选择。
 
 # 内容创建
 
 - 考虑使用[Gameplay Ability System](https://dev.epicgames.com/documentation/en-us/unreal-engine/gameplay-ability-system)。
 - 考虑使用[Game Feature Plugins](https://dev.epicgames.com/documentation/en-us/unreal-engine/game-features-and-modular-gameplay-in-unreal-engine)。
 - 考虑使用UE的编辑器内雕刻工具进行关卡灰盒制作。
 - 自动保存很好，它保存为备份副本，而不是资产本身。
 - 使用软引用和接口！
   - 在C++中，软引用对UClass有比较运算符重载，因此你可以检查`TArray`软引用是否包含`UClass`。
   - 软对象引用可以指向其他（子）关卡中的其他Actor，即使它们未加载。这非常重要！
   - 不要创建`Soft Class Path`或`Soft Object Path`类型的变量，而应使用`Object`→`Soft Object/Class Reference`。
   - 更多信息见‣。
 - 不要让临时内容在没有易于查找的方式的情况下进入playtest。
   - 使用"仅编辑器"标记。
   - 永远不要使用粗鲁/受版权保护的临时内容！你会惊讶于这些内容多么容易被遗忘并发布。
 - Actor可以没有根组件，适合不需要变换的管理器。只需在C++构造函数中置空根组件或扩展`AInfo`。
 - 使你的材质和其他资产考虑质量设置（中等、Epic等）
 - 厌倦了所有空Actor都有的默认白色球体？将`DefaultRootComponent`替换为普通的`Scene Component`，它就会消失。
 - 使用[核心重定向](https://docs.unrealengine.com/en-US/ProgrammingAndScripting/ProgrammingWithCPP/Assets/CoreRedirects/index.html)（类、属性等重定向器），而不是在替换类时必须编辑大量旧资产。
 - 在项目设置中减少着色器排列以减少编译的着色器数量。
 - 使用`AssetRegistrySearchable`标志通过Asset Manager添加可查询的资产属性，而无需先加载它们。
 - 尽早考虑持久性，你的游戏的部分/关卡需要加载和卸载，敌人/物品/世界状态需要保存/恢复。
   - 考虑使用[Level Streaming Persistence插件](https://portal.productboard.com/epicgames/1-unreal-engine-public-roadmap/c/1098-level-streaming-persistence-experimental)而不是自己编写。
 - 在游戏玩法和电影相机之间混合是可能的，但如果你不知道要寻找什么，这会非常不直观。[说明在这里](https://www.stevestreeting.com/2021/10/15/ue4-smoothly-transitioning-between-gameplay-sequencer-cutscenes/)。
 
 # 代码
 
 - 安装[UnrealVS](https://docs.unrealengine.com/en-US/ProductionPipelines/DevelopmentSetup/VisualStudioSetup/UnrealVS/index.html) Visual Studio扩展，以便能够轻松修改和切换以前的应用程序启动参数。非常适合快速添加`-game`、`-ExecCmds=""`等。
   - Rider现在也对UE有很好的支持，可以作为VS的替代品，尽管我发现Visual Studio 2022现在没有Visual Assist或类似工具也相当不错。
 - 在Visual Studio安装程序中安装"Unreal Engine的Visual Studio工具"组件以获得BP支持，该支持显示代码中的BP引用。Rider已经内置了此功能。
 - 设置环境变量"UE_NAME_PROJECT_AFTER_FOLDER=1"，使解决方案文件以父文件夹命名，而不是默认的"UE5.sln"。当你有多个项目时非常有用。
   - 你也可以在BuildConfiguration.xml文件中添加`<ProjectFileGenerator><bPrimaryProjectNameFromFolder>true</..>`。
 - Microsoft有一个关于为UE开发设置Visual Studio的精彩视频[这里](https://www.youtube.com/watch?v=AiLDnFppRIA)。
 - 尽量避免使用STD框架。UE对大多数功能都有自己的等效实现。
 - Actor.h中有关于Actor初始化的重要可重写虚函数的很好参考注释，[见这里](https://twitter.com/flassari/status/1744094317956755716)。
 - 使用`GENERATED_BODY()`，而不是`GENERATED_UCLASS_BODY()`或`GENERATED USTRUCT_BODY()`，它们是遗留的。
 - 使用普通构造函数：`AMyClassName()`，而不是带有对象初始化器的构造函数，那是遗留的。
 - 你的代码也应该在关闭PCH和没有Unity构建的情况下编译。在‣视频中查看更多信息。
 - 了解`#if WITH_EDITOR`（仅在编辑器中运行）和`#if WITH_EDITOR_DATA`（仅用于编辑器专用类属性，跳过烘焙它们）之间的区别。
 - `#ifdef WITH_EDITOR`是不正确的，`#if WITH_EDITOR`是正确的。`WITH_EDITOR`始终被定义，但它的值为0或1。
 - 始终用`UPROPERTY()`装饰指向`UObject`的成员变量。否则，如果垃圾回收器运行，它们将指向无效数据，因为GC不会为你置空非UPROPERTY变量。
   - 当你不希望它随资产序列化/保存时，使用"Transient"。
   - 当你不希望它保持引用活动时，使用`TWeakObjectPtr<T>`，这时你不需要使用`UPROPERTY`。更多信息见‣。
 - 知道如何使用‣。
 - 使用[子系统](https://docs.unrealengine.com/en-US/ProgrammingAndScripting/Subsystems/index.html)。
 - 了解`F(StructOfAnyType)`、`UObject`和`AActor`的生命周期和GC之间的区别。
   - 你自己管理`F(StructOfAnyType)`的生命周期，它用于智能指针如`UniquePtr`和`SharedPtr`。
   - `UObjects`只有在没有引用时才会被垃圾回收销毁，或者（很少）如果你添加了`PendingKill`标志。永远不要在它们上使用`UniquePtr`或`SharedPtr`等生命周期管理智能指针。
   - `AActors`是特殊的UObjects，可以被`Destroy()`销毁，这会将它们从世界中移除，但仍需等待垃圾回收器完成清理。这就是为什么你需要使用`IsValid()`检查Actor是否有效。
 - 理解CDO的工作原理。
   - 对于C++构造函数，只有描述CDO的代码应该放在那里（设置对象、其组件、子对象、默认值等）。没有其他内容。
   - 不要在那里注册委托，CDO不应该做任何事情，并且（除非它们是瞬态的）它们会被序列化（动态委托）并且难以移除。
 - `TArrays`可以使用堆栈分配器。
 - 使用[实时编码](https://docs.unrealengine.com/using-live-coding-to-recompile-unreal-engine-applications-at-runtime/)。
 - 使用UE的[C++代码片段](https://github.com/EpicGames/UnrealEngine/blob/release/Engine/Extras/VisualStudioSnippets/README.md)。
 - 使用`TitleProperty` `UPROPERTY`说明符使数组在蓝图中[更易于阅读](https://www.tomlooman.com/title-property-better-array-unreal/)。
 - 使用`OverloadName` `UPROPERTY` `meta`说明符为BP公开的函数添加重载。[见示例](https://unrealbuddies.bettermode.io/questions/post/function-overloading-in-unreal-8WwGkPP4xGLMqa8)。
 - 考虑在`编辑器首选项`→`杂项`选项卡中关闭"自动编译新添加的C++类"。通常你只想在修改它们之后编译。
 - 如果你需要在UE中使用线程任务构建一些大数据集，那么使用`TChunkedArray`收集它们比`TArray`好得多。
 - 使用“`UPARAM(ref) UMyObjectType*& MyObjectParam`”格式使蓝图参数成为必填项。
 - 如果你在代码中为`UENUM`条目添加注释，请记住将它们放在上面的单独行中。如果你在同一行注释，Unreal会解析错误并生成错位的工具提示。
 - 永远不要在C++构造函数中添加动态委托（或任何）监听器，它会被序列化为UPROPERTY。委托应该在`BeginPlay`中注册。
   - 如果已经发生这种情况，使委托UPROPERTY为`Transient`并重新保存资产。
 - 不要使用阻塞加载函数调用（除非在编辑器工具中），特别是异步加载其他资产时，因为它会强制阻塞刷新它们。
 - 除了我们自己的[文档](https://docs.unrealengine.com/4.27/en-US/ProgrammingAndScripting/GameplayArchitecture/Properties/Specifiers/)，还有很棒的第三方资源关于UPROPERTY和META说明符，如[ben🌱ui的网站](https://benui.ca/unreal/uproperty/)和[Unrealistic.dev的Spectacle](https://unrealistic.dev/spectacle/)。
 
 # 蓝图
 
 - 将变量拖到另一个变量的现有get/set节点上以替换它。
 - 蓝图有"编译时保存"选项。
 - 通过"Base Classes to Allow Recompiling During Play in Editor"编辑器设置允许在编辑器中播放时重新编译蓝图。
 - 你可以在分解后隐藏结构中不需要的引脚。但你不能在绿色标题的分解结构中这样做。
 - 按住CTRL同时拖动引脚可移动多连接引脚。
 - 使用蓝图节点创建键盘快捷键，如`A`（数组获取节点）、`B`（分支）、`C`（注释）、`D`（延迟）、`F`（循环）、`P`（开始播放）。
   - 在`DefaultEditorPerProjectUserSettings.ini`中使用`[BlueprintSpawnNodes] +Node=[..]`创建自己的快捷键（详见`BaseEditorPerProjectUserSettings.ini`中的默认值）。
 - 你可以比较蓝图。你也可以比较关卡蓝图（文件->比较）。
 - 蓝图构造脚本被烘焙到关卡中（或在动态实例化BP时运行）。利用这一点在构造脚本中进行繁重计算，而不是在BeginPlay中。
 - 开启`Blueprint Break On Exceptions`设置，更容易捕获和调试蓝图错误。
 - 蓝图中的函数输入参数可以作为局部变量引用，而不是从函数节点绘制线到它们。
 - 如果任何内容引用蓝图库中的任何函数，则该库引用的所有内容也会被硬引用。
 - 你可以通过禁用蓝图节点或使其仅在开发时使用。在`编辑器首选项→内容编辑器→蓝图编辑器→实验→允许显式禁用不纯节点`中启用该功能。你需要关闭`项目设置→引擎→烘焙器→Compile Blueprints in Development Mode`，以便开发节点在发布构建中被禁用。
 - 你可以通过将蓝图事件标记为"在编辑器中调用"，使其可在细节面板中直接从编辑器调用。非常适合调试。
 
 # 材质
 
 - 使用材质节点创建键盘快捷键，如`A`（添加）、`D`（除）、`I`（如果）、`M`（乘）、`N`（归一化）、`S`（标量参数）、`T`（纹理采样）、`U`（UV）、`1`/`2`/`3`/`4`（创建N维常量）。
   - 在`DefaultEditorPerProjectUserSettings.ini`中使用`[MaterialEditorSpawnNodes] +Node=[..]`创建自己的快捷键（详见`BaseEditorPerProjectUserSettings.ini`中的默认值）。
 - 你可以[创建自己的自定义视图模式](https://twitter.com/dtorkar/status/1470819476937527310)到缓冲区可视化中。
 
 # 纹理
 
 - 如果你使用非alpha通道（即RGB）进行通道打包数据（如遮罩等），请记住关闭sRGB。sRGB会将颜色值转换为Gamma 2.2，这不是你最初输入的线性0-100%值。Alpha通道没有此问题，但有时你可能希望使用RGB通道进行遮罩或其他操作，以更好地控制通道压缩。
 - 非流式纹理只要被引用就会完全加载到内存中。你可以在属性视图中查看纹理是否流式。UI纹理通常不流式，因为我们不希望UI看起来模糊。但这意味着你需要小心有选择地加载UI部分，因为如果主UI引用了所有UI纹理，它们可能会一直加载。
   - `memreport`控制台命令将列出游戏中当前加载的所有非流式纹理。
 
 # 网格体
 
 - 你可以[向静态网格体添加插槽](https://docs.unrealengine.com/4.26/en-US/WorkingWithContent/Types/StaticMeshes/HowTo/Sockets/)，然后用于附件或从BP/C++查询。然后你可以让不同的网格体实现相同名称的插槽。
 
 # 物理
 
 - 主动管理碰撞设置。这个演讲有很多关于碰撞设置和查询的很棒的技巧，强烈推荐：[UE5中的碰撞数据：管理碰撞设置和查询的实用技巧 | Unreal Fest 2023 - YouTube](https://www.youtube.com/watch?v=xIQI6nXFygA)
 
 # 调试
 
 - 查看[Unreal Engine中的高级调试 | Epic开发者社区 (epicgames.com)](https://dev.epicgames.com/community/learning/tutorials/dXl5/advanced-debugging-in-unreal-engine)。
 - 你可以从Visual Studio启动游戏，就像它在另一个目录中一样（非常适合调试已打包的Shipping构建，如Steam中的构建），使用`-basedir=E:\\path\\to\\GameName\\Binaries\\Win64`。**这是一个非常重要和有用的提示，不要只是匆匆看过！**
   - 你可以使用`-WaitForAttach`命令行参数启动游戏或编辑器，它将在启动流程开始时暂停，等待调试器附加到进程后再继续。但我更喜欢在可能的情况下使用`-basedir`，工作流程更好更快。
   - Unreal的AutomationTool（.NET）项目使用`-WaitForDebugger`。
 - `[Kismet] ScriptStackOnWarnings=true`或`-ScriptStackOnWarnings`在日志中显示蓝图堆栈警告。
 - 你可以使用[蓝图调试器](https://docs.unrealengine.com/blueprint-debugger-in-unreal-engine/)调试蓝图。通过`工具`→`调试`→`蓝图调试器`打开。使用它你可以单步执行、进入和退出BP函数。
 - 你可以在打包游戏或编辑器中的任何时候按F12，如果已附加调试器，将立即在Visual Studio中中断。
 - 调试蓝图时，你可能需要打开`编辑器首选项`→`常规-实验`→`蓝图`→`Blueprint Break on Exceptions`。这会在BP调试器中在BP异常处中断BP代码。
 - 通过将蓝图事件标记为`Call in Editor`，可以直接从编辑器的细节面板调用任何蓝图事件。非常适合调试。BP函数和C++函数都可以这样做。
 - 通过BP函数Print String在屏幕上打印调试信息时，给它一个Key，用相同Key替换屏幕上的现有日志行。
 - 始终打开符号：`项目设置→项目→打包→项目→包含调试文件`。没有调试文件的Shipping构建无法调试崩溃。**但不要随游戏一起发布它们**，将它们存储在其他地方，如符号服务器。
 - 设置符号服务器（只是一个文件夹，不涉及"服务器"）来存档所有构建的符号。然后你可以下载并调试崩溃转储，无需麻烦。
   - [自定义符号存储和符号服务器 - Windows驱动程序 | Microsoft Learn](https://learn.microsoft.com/en-us/windows-hardware/drivers/debugger/symbol-stores-and-symbol-servers)
   - [这篇文章中有很多信息](https://randomascii.wordpress.com/2013/03/09/symbols-the-microsoft-way/)。
 - 每次崩溃都保存到`Saved/Crashes`。无论是编辑器崩溃还是所有游戏崩溃，甚至Shipping版本。它包含一个带有大量相关信息的xml文件和一个minidump文件，你可以将其拖到Visual Studio中查看崩溃点的断点（需要前面提示中的调试文件👆）。
   - 查看我的演讲[Crashing With Style in Unreal Engine](https://www.youtube.com/watch?v=ow__LgMF5gE)了解崩溃处理和崩溃报告器自定义。
     - 通过`项目设置`→`项目`→`打包`→`打包`→（显示高级）→`包含崩溃报告器`，将崩溃报告器包含在游戏中，使用户能够将崩溃上传给你（仅Windows）。
       - [Sentry](https://docs.sentry.io/platforms/native/guides/ue4/)、[Backtrace](https://support.backtrace.io/hc/en-us/articles/360040106172-Unreal-Integration-Guide)和[BugSplat](https://docs.bugsplat.com/introduction/getting-started/integrations/game-development/unreal-engine)都可以通过一些配置文件更改直接从崩溃报告器接收崩溃。
       - 崩溃报告器有一些对Epic的引用，你应该自定义。我的上述演讲涵盖了这一点，[BugSplat也有一个很好的教程](https://www.bugsplat.com/blog/game-dev/customizing-ue4-crash-dialog/)。
             - 要设置崩溃报告器将崩溃发送到哪里，你应该在构建游戏后在**构建的**游戏目录中创建此文件：`STAGED_BUILD/Engine/Config/Windows/WindowsEngine.ini`，并将以下内容放入其中：`[CrashReportClient] DataRouterUrl="https://your.url.here"`
                 - 目前无法从项目设置中设置数据路由器URL，你必须在每次构建后创建此文件。最好将此作为持续集成过程的一部分自动化。
                 - 你可以使用`DefaultEngine.ini`使崩溃报告器自动发送报告：`[CrashReportClient] bImplicitSend=true`。
                     - 令人困惑的是，这是在你的**游戏项目**的`DefaultEngine.ini`中，而不是你设置`DataRouterUrl`属性的构建版本中的那个。
                     - 如果你没有事先获得用户同意，确保不发送任何可识别的用户数据。检查当地隐私法。
     - 你可以随时调用`FGenericCrashContext::SetGameData`设置任意字符串键/值对，这些键/值对将保存到崩溃的`CrashContext.runtime-xml`文件中。
     - 使用`FUserActivityTracking::SetActivity(FUserActivity(TEXT("In Main Menu"), EUserActivityContext::Game));`设置`CrashContext.runtime-xml`中的`UserActivityHint`字段。
     - 附加调试器时不会生成崩溃报告。要强制即使在调试时也生成崩溃报告，请提供`-crashreports`参数。适合调试崩溃流程。
     - Ensures（断言）也会创建崩溃文件夹，代价是游戏卡顿，并通过崩溃报告器自动发送，代价是创建minidump文件的卡顿。
         - 要关闭此功能，将`[/Script/UnrealEd.CrashReportsPrivacySettings] bSendUnattendedBugReports=false`添加到游戏的`DefaultEngine.ini`中。
 - 你可以使用`UE_ADD_CRASH_CONTEXT_SCOPE`添加其他作用域崩溃文件（参见UnrealEngine.cpp中的示例用法）。仅桌面平台。
 - [这个提示](https://www.notion.so/UE-Tips-Best-Practices-28d011a87cae81cfbd9dfeb7e6f7d059?pvs=21)值得重复；安装[UnrealVS](https://docs.unrealengine.com/en-US/ProductionPipelines/DevelopmentSetup/VisualStudioSetup/UnrealVS/index.html) Visual Studio扩展。
 - 学习如何进行[远程调试](https://docs.microsoft.com/en-us/visualstudio/debugger/remote-debugging-cpp?view=vs-2019)，你可以附加到同一网络上任何计算机或控制台上的游戏（甚至如果他们在同一VPN上，可以连接到家里的人）。
   - 你可以使非Shipping构建在崩溃或断言前等待程序员远程附加到进程并查看情况。
       
       ![Untitled](../../../assets/images/Untitled.png)
       
   - 通过配置，在`DefaultEngine.ini`中：`[Engine.ErrorHandling] bPromptForRemoteDebugging=True`或`[Engine.ErrorHandling] bPromptForRemoteDebugOnEnsure=True`。
   - 通过命令行：`-PromptRemoteDebug`或`-PromptRemoteDebugEnsure.`
 - 支持调试相机，即不要编写无法使用或切换到调试相机时会崩溃的游戏代码。`ToggleDebugCamera`控制台命令。
   - 使用"What is This"信息进行调试。更多信息见[Unreal Engine中的高级调试 | Epic开发者社区 (epicgames.com)](https://dev.epicgames.com/community/learning/tutorials/dXl5/advanced-debugging-in-unreal-engine)。
 - 要在Visual Studio调试时打印当前蓝图堆栈，在即时窗口中为编辑器构建键入`UnrealEditor-Core!PrintScriptCallstack()`，为单体构建键入`::PrintScriptCallstack()`。[来源](https://www.unrealengine.com/en-US/tech-blog/debugging-ufunction-invoke)。
   - 格式`{,,UnrealEditor-Core}::PrintScriptCallstack()`也有效，Rider仅支持该格式。
   - 在UE4中，模块名为`UE4Editor-Core`。
   - 在Visual Studio的命令窗口中创建别名：`alias bp eval UnrealEditor-Core!PrintScriptCallstack()`。然后在即时或控制台窗口中用`>bp`触发。别名将在运行之间保持。
 - 要在代码中获取当前蓝图堆栈，使用`FFrame::GetScriptCallstack()`。它使用来自`FBlueprintExceptionTracker`的堆栈，也可以直接使用，例如将堆栈注入自己的变量进行调试。
   - 你也可以调用`StackTrace` BP节点来执行相同操作。
 - 生活质量：当你将鼠标悬停在变量上时，数据提示（小数据弹出窗口）很容易在稍微移开时消失。要保持它们展开直到点击关闭，进入Visual Studio选项并打开`调试`→`常规`→`保持展开的数据提示打开直到点击关闭`。
 - 使用`TrackAsyncLoadRequests.Enable 1`捕获每个异步加载请求的堆栈跟踪，然后使用`TrackAsyncLoadRequests.Dump`将它们全部打印到输出窗口，或`TrackAsyncLoadRequests.DumpToFile`将它们转储到/Saved文件夹。来自[Unreal Engine 5: 迭代改进的新功能介绍](https://epicgames.ent.box.com/s/4llmcn14777g5fgekz8vk4bon0li02f4)。
 - 在Visual Studio中，你可以通过`调试`→`新建断点`→`函数断点 (Ctrl+K, B)`仅基于函数名创建函数断点。
   - 你甚至可以使用通配符，如`FYourClass::*`。
 - 要查看哪些资产被加载、何时加载以及由谁加载：`log LogStreaming Verbose`（或`VeryVerbose`获取更多信息）。
   - 更好的是，使用Unreal Insights并添加`-trace=default,file,loadtime`。
   - 对于较大的项目，日志记录可能很耗时。你可以通过使用命令`-s.VerbosePackageNames="/Game/PackageA/Game/PackageB0xABCD1234ABCD1234"`设置所选包名称或包ID来过滤特定包的日志。[来源](https://docs.unrealengine.com/5.3/en-US/zen-loader-in-unreal-engine/)。
   - 如果你附加了调试器，你可以使用命令`-s.DebugPackageNames`提供指定包的某些加载阶段的自动断点。[来源](https://docs.unrealengine.com/5.3/en-US/zen-loader-in-unreal-engine/)。
 - 要查看每个资产的加载时间，在控制台中输入`Loadtimes.Dumpreport`。在启用STATS的所有构建上启用。可选提供`FILE`将其写入/Saved/LoadReports，`-AlphaSort`按字母顺序排序以便比较，`LOWTIME=0.05`让你设置输出阈值。
   - 更好的是，使用Insights并添加`-trace=default,file,loadtime`，并在Timing Insights面板中打开资产加载轨道(`L`)。
 - 充分利用日志命令
   - `-LogCmds="LogStreaming Verbose"`
   - `-LogCmds="Global Error, LogCook Verbose"`
   - `-LogCmds="Global None, LogCook Verbose"`
   - 在控制台中输入`log`查看日志系统的详细文档。
 - 了解`Outer`是什么以及如何使用它。
   - 对于地图中的任何Actor/组件等，其外部链将始终以地图的`UPackage`结束。
   - 如果你动态加载对象（但不实例化它，如加载CDO），其最外层将是该资产的UPackage。
   - 通过`NewObject`实例化对象时，你必须自己提供outer。如果不提供，它将被设置为`TransientPackage`。
   - 通过蓝图创建新对象时，所有者的级别将成为新的outer。
 - `DrawDebugString`将在3D世界中绘制临时字符串。
 - `Debug Float History`在图表上绘制浮点值。[推文](https://twitter.com/HighlySpammable/status/1540306860292849667)。
 - `UE_VLOG_CAPSULE`等
 - `memreport -full`用于比较。使用`-log`将其打印到输出日志，否则它会保存到`Saved\\Profiling\\MemReports`文件夹中的新文件中
 - 使用[Visual Logger](https://www.youtube.com/watch?v=hWpbco3F4L4)。
 - 注意C++在调试模式下使用的不同调试内存位模式（如`0xCCCCCCCC`：未初始化的堆栈值，`0xdddddddd`：已释放），[更多信息在这里](https://www.softwareverify.com/memory-bit-patterns.php)。
 - `if (debugCondition) { UE_DEBUG_BREAK(); }`在当前连接的调试器中中断。
 - `while (!FPlatformMisc::IsDebuggerPresent()); UE_DEBUG_BREAK();`等待调试器附加。
 - 你可以在Visual Studio中为FStrings和FNames使用以下格式的条件断点：
   - FString: `wcsstr((wchar_t*)MyFString.Data.AllocatorInstance.Data, L"Search substring")`
   - FName: `strstr(((FNameEntry&)GNameBlocksDebug[MyFName.DisplayIndex.Value >> FNameDebugVisualizer::OffsetBits][FNameDebugVisualizer::EntryStride * (MyFName.DisplayIndex.Value & FNameDebugVisualizer::OffsetMask)]).AnsiName, "Search substring")`
   - 但这相当复杂，通常更容易更改源代码并创建如下条件断点：
     - `if (MyFName.ToString().Contains("Your Substring Here")) { UE_DEBUG_BREAK(); }`
 - 你可以使用`-ini`可执行参数为（非Shipping）打包构建覆盖任何ini设置，即使是控制台上的构建：`-ini:Game:[/Script/ModuleName.ClassName]:ConfigVarName=NewValue`
   - 参见`FConfigFile::OverrideFromCommandline`实现。
 - 你也可以对CVars（仍然仅非Shipping构建）使用设备配置文件cvar覆盖参数：`-DPCVars=r.cvarname=foo,anothercvar=bar`。
   - 不幸的是，不适用于Cheat变量。
 - 如果你的游戏或编辑器冻结，对于没有Visual Studio的人来说，快速查看问题的方法是运行[Very Sleepy](http://www.codersnotes.com/sleepy/)捕获并检查`WinMain`堆栈正在做什么。
 - 要使用内存踩踏调试内存分配器，使用`-stompmalloc`启动游戏
 - 尝试让你的错误和日志具有描述性。`GetFullNameSafe`是你的朋友。
 - 如果不应该为空，不要只做空检查。确保或崩溃以更快地发现错误。让它自动向团队报告所有错误以快速修复。
 - Windows上的调试器附加到运行进程时，限制为加载500个模块的符号，少于UE拥有的数量。可以通过添加以下注册表项并重启PC来增加限制：`HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Session Manager` - `DWORD DebuggerMaxModuleMsgs = 2048`。[来源](https://forums.unrealengine.com/t/increase-the-number-of-modules-loaded-when-attaching-the-debugger/661624)。
 - 你可以使用`debug`控制台命令强制引擎出错/崩溃，适合测试崩溃报告：
   - `debug gpf`：触发一般保护错误（访问冲突）。
   - `debug oom`：每帧持续分配1MB。
   - 还有很多其他的，如`eatmem`、`stackoverflow`、`ensure`、`hitch`等。查看`UEngine::PerformError`了解更多。
 - 调试GPU问题：
   - 设置`r.RHISetGPUCaptureOptions 1`以在运行`ProfileGPU`（ctrl+shift+逗号）时获取更详细的GPU时间。
     - （现在这是自动的吗？）
   - `DumpGPU`将转储单帧的所有内部资源，作为交互式html页面供检查。你可以启动它来检查绘制调用及其内部缓冲区。
   - 使用`-gpucrashdebugging`或`-d3ddebug`运行引擎（不要同时使用两者）。
   - 使用`-onethread -forcerhibypass`运行。这将强制UE仅使用一个线程，并有助于确定问题是否是线程/时序问题。
   - 使用`r.RDG.Debug=1`，这可能会给你有关未正确设置的渲染通道的信息。
   - 使用`r.RDG.ImmediateMode=1`，这将强制渲染图（RDG）在创建后立即执行通道，并可以给你更有意义的调用堆栈（这实际上会改变其他方面，可能是误导，但仍然值得尝试）。
   - 如果你有权限，更多内容在这篇[UDN文章](https://udn.unrealengine.com/s/article/dealing-with-GPU-crashes)中。
   - 查看这个很棒的Unreal Fest演讲：[Unreal Engine中的GPU崩溃调试：工具、技术和最佳实践 | Unreal Fest 2023 (youtube.com)](https://www.youtube.com/watch?v=CyrGLMmVUAI)
 - 了解四种构建配置的区别：
   
   | Debug | Development | Test | Shipping |
   | --- | --- | --- | --- |
   | 设置`UE_BUILD_DEBUG=1` | 设置`UE_BUILD_DEVELOPMENT=1` | 设置`UE_BUILD_TEST=1` | 设置`UE_BUILD_SHIPPING=1` |
   | 可在IDE中调试 | 可在IDE中调试 | 可在IDE中调试 | 可在IDE中调试 |
   | 代码未优化 | 代码已优化$^1$ | 代码已优化$^1$ | 代码已优化$^1$ |
   | 符号复制到分阶段构建 | 符号复制到分阶段构建 | 符号复制到分阶段构建 | 符号不复制，除非`IncludeDebugFiles=true` |
   | 控制台已启用 | 控制台已启用 | 控制台已启用 | 无控制台，除非`ALLOW_CONSOLE_IN_SHIPPING=1` |
   | Cheat Manager已启用 | Cheat Manager已启用 | Cheat Manager已启用 | 无Cheat Manager，除非`UE_WITH_CHEAT_MANAGER=1` |
   | Insights和Visual Logger已启用 | Insights和Visual Logger已启用 | Insights和Visual Logger已启用 | 无Insights或Visual Logger，除非`UE_TRACE_ENABLED=1` |
   | 慢速和正常检查/确保 | 正常检查/确保 | 无检查/确保，除非`bUseChecksInShipping=true.` | 无检查/确保，除非`bUseChecksInShipping=true` |
   | 日志已启用 | 日志已启用 | 无日志，除非`bUseLoggingInShipping=true` | 无日志，除非`bUseLoggingInShipping=true` |
   | 调试绘制已启用 | 调试绘制已启用 | 无调试绘制，除非`UE_ENABLE_DEBUG_DRAWING=1` | 无调试绘制，除非`UE_ENABLE_DEBUG_DRAWING=1` |
   - 你将定义（`ALL_CAPS=1`）放入***.Target.cs**文件的`GlobalDefinitions`数组中。将`bCamelNamedVars=true`直接放入***.Target.cs**文件中。
   - 所有构建配置都可以在IDE（Visual Studio、Rider等）中调试，但前提是你有其符号。
   - `Development`、`Test`和`Shipping`配置都应用相同级别的代码优化。
   - `DebugGame` "配置"对游戏模块使用`Debug`，对引擎模块使用`Development`。
   - $^1$：可以强制不优化：
     - 单个C++文件：
       - 通过自适应unity构建检出（即可写，使用P4时）C++文件
         - BuildConfiguration.xml: `<BuildConfiguration><bAdaptiveUnityDisablesOptimizations>true</..>`。
         - Target.cs: `bAdaptiveUnityDisablesOptimizations = true;`。
     - 每个模块：
       - BuildConfiguration.xml: `<ModuleConfiguration><DisableOptimizeCode><Item>ModuleName</..>`。
       - Build.cs: `OptimizeCode = CodeOptimization.InShippingBuildsOnly`或`CodeOptimization.Never`。
       - Target.cs: `DisableOptimizeCodeForModules`数组。
     - 代码块：
       - `UE_DISABLE_OPTIMIZATION/UE_ENABLE_OPTIMIZATION`。
         - 这些不应该发布，建议在持续集成构建中添加定义`UE_CHECK_DISABLE_OPTIMIZATION=1`，这样就不会意外发布未优化的代码。
         - 如果一段代码应该发布为未优化，你可以通过使用`UE_DISABLE/ENABLE_OPTIMIZATION_SHIP`来表明意图。
 - 你可以使用[hw_break](https://github.com/biocomp/hw_break)库以编程方式设置硬件数据断点。
 - 你可以使用[UnrealNetImgui](https://github.com/sammyfreg/UnrealNetImgui)库让远程Imgui客户端显示游戏中的调试值。如果你不想混乱游戏屏幕，这很好。
 
 # 性能分析
 
 - 查看[最大化你的游戏在Unreal Engine中的性能](https://www.youtube.com/watch?v=GuIav71867E)。
 - 查看[The Great Hitch Hunt: Tracking Down Every Frame Drop](https://dev.epicgames.com/community/learning/tutorials/6XW8/unreal-engine-the-great-hitch-hunt-tracking-down-every-frame-drop)。
 - 有关新内存分析工具的信息，查看[Insights的新功能：Unreal Engine的内置分析工具](https://www.youtube.com/watch?v=af_M38Z325I&t=498s)。
 - 查看[Budgeting in a Post-Polycount World | Unreal Fest 2024](https://www.youtube.com/watch?v=q28KMKjUZkI)。
 - 你需要使用[Unreal Insights](https://docs.unrealengine.com/TestingAndOptimization/PerformanceAndProfiling/UnrealInsights/)满足大多数内置分析需求。
   - 首先编译`UnrealInsights`项目（如果运行源代码构建），并在启动游戏或编辑器之前启动它。
   - 然后使用`-trace=default,memory,(和/或其他你希望分析的通道)`启动项目，以跟踪模式启动它并指定通道。
     - 一些可用的跟踪通道是，`CPU`、`GPU`、`Trace`、`Log`、`Task`、`Frame`、`LoadTime`、`File`、`Net`、`Memory`、`Bookmark`。
       - 参见[Unreal Insights参考](https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-insights-reference-in-unreal-engine-5)文档页面了解可以启用哪些通道。
     - 使用`-statnamedevents`获取更多CPU遥测函数报告。
     - 只需提供`-trace`或`-trace=default`，它将默认为`-trace=cpu,gpu,frame,log,bookmark`。
     - 你也可以在`DefaultEngine.ini`中通过以下方式创建自定义跟踪通道组：`[Trace.ChannelPresets] MyChannelSet=log,frame`
     - 搜索`UE_TRACE_CHANNEL(`或`UE_TRACE_CHANNEL_DEFINE`查看更多可用通道。
     - 使用`Task`通道进行多线程分析，然后你可以跟踪任务依赖链。[Twitter示例](https://x.com/flassari/status/1819328037978079356)。
   - 可选使用`-tracehost=address`如果你想将跟踪发送到另一台进行分析的计算机。
 - 对于Windows上的CPU采样分析，我真的推荐[Superluminal](https://superluminal.eu/)。
 - 使用像Superluminal这样的采样分析器时，你可以使用`-Superluminal`启动参数添加UE特定遥测数据以及采样数据。其他支持的参数有`-PIX`、`-VTune`、`-VSPerf`、`-ConcurrencyViewer`、`-AQTime`和`-Instruments`（用于Mac）。
   - 游戏必须使用superluminal分析支持编译，只有当构建计算机在构建时安装了Superluminal时才会自动发生（参见Core.Build.cs并搜索"Superluminal"）。
 - 在任何代码块中使用`SCOPED_NAMED_EVENT`使其显示在Unreal Insights的CPU分析器中。
 - 使用`TRACE_BOOKMARK(Format, Args)`创建自己的自定义书签，显示在Unreal Insights中。
 - 你可以通过在DefaultEngine.ini中添加以下内容来自定义`stat unit`中显示的时间颜色（对于60fps）：
 `[/Script/Engine.RendererSettings]
 t.TargetFrameTimeThreshold=16.7
 t.UnacceptableFrameTimeThreshold=33.9`
 - 你可以使用`r.ScreenPercentage`降低分辨率，查看像素着色器是否占用了大部分GPU时间，但最好使用Insights和ProfileGPU命令获取实际数值。
 - 开发期间的GPU分析应禁用动态分辨率（`r.DynamicRes.OperationMode=0`）以获得一致的数值。
 - 对于GPU分析：
   - `r.RHISetGPUCaptureOptions 1`是以下三个选项的快捷方式：
     - `r.rhicmdbypass 1`
     `r.rhithread.enable 0`
     `r.showmaterialdrawevents -1`
     `profilegpu`
     - 更多信息见[https://docs.unrealengine.com/shader-debugging-workflows-unreal-engine/](https://docs.unrealengine.com/shader-debugging-workflows-unreal-engine/)
   - GPU Profile现在显示每个材质的绘制成本。不总是准确且仅桌面版，但这是一个很好的早期测试。” - 来源：[https://twitter.com/sirwyeth/status/1446566692998590466?s=21](https://twitter.com/sirwyeth/status/1446566692998590466?s=21)
 
 # Slate / UMG
 
 - 查看ben🌱ui的[UI介绍](https://benui.ca/unreal/intro-making-uis-video)。
 - 使用Widget反射器调试UMG/Widgets的状态。
 - UMG的Bind按钮不是实际的绑定，它们只是每帧检查属性，效率低下。相反，通过`项目设置`→`编辑器`→`Widget Designer (Team)`→`编译器`→`默认编译器选项`→`属性绑定规则`→`阻止并出错`禁用`Bind`按钮，并使用事件或[View Model](https://dev.epicgames.com/documentation/en-us/unreal-engine/umg-viewmodel)代替。
 - 使用`BindWidget` `UPROPERTY` [设置子Widget C++属性访问](https://benui.ca/unreal/ui-bindwidget/)。
 - Widget的`PreConstruct`事件有一个"设计时"标志，用于创建模拟数据，以便在编辑器中更容易进行UI设计和测试。
 - 启用`FastPath`的Widget会向内存添加大量预热的UObject，确保只在实际显示或即将显示时加载Widget。
 
 # 垃圾回收
 
 - 销毁的Actor在实际被垃圾回收之前不会被置空引用。这就是`IsValid`用于检查的原因。
 - `UObject`的引用将在其`Destroy`被调用**之后**，`BeginDestroy`和`EndPlay`被调用**之前**被GC全部清除。
 - `UObject`指针容器（`TArray`等）除非标记有`UPROPERTY`，否则也不会将项目置空。
 - 提交前自我检查：所有`UObject`（包括Actor）类成员引用或包含它们的容器都应标记有`UPROPERTY`。
 - 尽量避免生成大量短生命周期的`UObject`。如果必须这样做，考虑将它们放入GC集群以减少垃圾回收开销。（编辑：GC集群[毕竟不是那么多性能节省](https://forums.unrealengine.com/t/knowledge-base-garbage-collector-internals/501800/6?u=ari_epic)）
 - 手动调用`Collector.AddReferencedObjects`时，记得始终包含`this`作为第二个参数用于GC调试。
   - 但我想说根本不要调用该函数，而是在`UPROPERTY`中使用GC感知属性或容器，如果不想被序列化，使用`Transient`。
 - `MarkPendingKill`设置一个标志，该标志将在垃圾回收引用遍历时使用。如果引用指向被标记为`PendingKill`的对象，它将置空该属性而不是认为该对象可达。被留下的不可达对象将在GC运行结束时被清除。
 
 # 内存
 
 - 编辑器右上角的"对象计数"是游戏中每个`UObject`的计数。
   - `编辑器首选项`→`常规`→`性能`→`显示帧率和内存`以打开。
   - 如果它不断增长，使用`obj list forget`、`obj list`查看当前创建的对象。
   - `obj list class=x`查看该类每个对象的全名（仍然尊重forget命令）。
   - `obj refs name=/full/name/of/item.item shortest`查看为什么它仍然存在（或如果没有引用则见‣）。
 - `memreport`和`memreport -full`可以在`DefaultEngine.ini`中通过`[MemReportCommands]`和`[MemReportFullCommands]`类别自定义。详见`BaseEngine.ini`中的默认命令。
 - Unreal Insights具有全栈每个分配跟踪。在我的演讲[Maximizing Your Game’s Performance in Unreal Engine](https://www.youtube.com/watch?v=GuIav71867E)中了解更多信息。
 - 你可以通过为非Shipping构建提供以下启动参数之一来强制Unreal使用特定的内存分配器。详见`EMemoryAllocatorToUse`和`FWindowsPlatformMemory::BaseAllocator`（或任何其他平台内存类的`BaseAllocator`函数）。
   - `-ansimalloc`：使用ANSI C内存分配器。跳过使用Unreal的分箱内存，直接从OS获取分配。如果你想使用外部内存分析工具而不是Unreal Insights，这很方便。但它较慢，可能导致内存碎片。添加`GlobalDefinitions.Add("FORCE_ANSI_ALLOCATOR=1");`到Target文件以在所有构建（包括Shipping）中强制启用。
   - `-binnedmalloc`、`-binnedmalloc2`、`-binnedmalloc3`：Unreal的分箱内存分配器。可能时默认使用。Binned1是旧的，Binned2是较新的，`-binnedmalloc3`是用于64位系统的最新基于VM的分配器。Unreal将始终为每个平台使用最佳分配器，你不需要手动覆盖这些。
   - `-stompmalloc`：调试内存分配器，如果检测到代码踩踏它标记的内存，会抛出异常。占用更多内存且慢得多。仅在桌面平台可用。
   - 查看`BaseAllocator`函数了解其他更罕见的分配器。
 
 # 工具
 
 - 有几种设置cvars的方法：
   - 运行时，在控制台中：`cvarname 0`
     - 你可以使用`|`字符将多个控制台命令链接在一起。
   - 作为编辑器启动参数：`-DPCVars="cvarname=0,othercvar=2"`
   - 在`DefaultEngine.ini`中设置为每次启动：
   `[SystemSettings]
   s.EnforcePackageCompatibleVersionCheck=0`
     - 有一种使用`ConsoleVariables.ini`进行引擎范围更改的方法，但在我看来这是**不良实践**，因为它会影响使用该引擎的所有项目，并可能意外签入，不要这样做。
 - 要在引擎启动时调用任何命令，使用`-ExecCmds="Command1,command2"`启动。
   - 还有一个`-EXEC=`，显然需要文件路径，它将使用exec（Unreal命令行命令）运行该文件，该命令将文件解释为换行分隔的命令。
   - 这些在启动过程中发生得稍晚，可能对某些目的来说不够早。
   - 你可以使用它来设置cvars，但`-DPCVars`语法更好，因为它在启动流程中发生得更早。
 - 你可以设置环境变量`UE-CmdLineArgs`，它将命令行参数附加到所有UE进程。仅在非Shipping（仅编辑器？）中。
 - 对于非桌面平台（如移动和控制台），你可以通过填充`UECommandLine.txt`文件设置启动命令行。
 - 让CI编译所有蓝图：`UE4Editor-Cmd.exe "AbsolutePath_to_.uproject" -run=CompileAllBlueprints -IgnoreFolder=/Game/Developers`（但不会编译关卡蓝图）。
 - 使用"编辑器工具任务"进行不会阻塞编辑器的长时间运行的Blutilities。创建一个扩展`EditorUtilityTask`的新`Editor Utility Blueprint`，覆盖`BeginExecution`，并在末尾调用`FinishExecutingTask`。[带图片的说明](https://twitter.com/jack_knobel/status/1377176550009753603)。
   - 你可以在BP中使用`EditorUtilitySubsystem`中的`RegisterAndExecuteTask`触发这些任务。
 - 编辑器不会自动收集垃圾，仅在某些操作（如保存地图）时收集。如果你的工具打开并处理大量资产，请记住每隔一段时间手动调用垃圾收集器，以免编辑器OOM。
   - 不要使用`GEngine->ForceGarbageCollection`，它只会告诉GC在下一帧收集。对于长时间运行的操作，没有帧计时，因此你可以通过调用`CollectGarbage(GARBAGE_COLLECTION_KEEPFLAGS)`强制立即垃圾收集。
   - 编辑器中的垃圾收集作用不大。编辑器自动为所有资产添加永不收集的标志。
 - 从4.26开始，你可以使用蓝图扩展编辑器菜单和工具栏。[带图片的说明](https://twitter.com/MilkyEngineer/status/1379644279480446982)。
 - 你可以通过在`DefaultEditorPerProjectUserSettings.ini`中注册蓝图，使其`Run`函数在编辑器启动时自动运行：`[/Script/Blutility.EditorUtilitySubsystem]
 +StartupObjects=/Game/Editor/BP_YourBlutility`
 - 有一个名为`DiffAssetsCommandlet`的命令行工具，带有`ExportFilesToTextAndDiff`命令。你可以用它做任何你想做的事情🤷‍♂️。
 
 # 版本控制
 
 - Unreal编辑器内置了蓝图差异工具，你也可以直接从命令行启动它。将其用作版本控制客户端中*.uasset文件的差异查看器。
   - `UnrealEngine.exe [Uproject路径] -diff [选项] left right`用于差异比较。`left`和`right`是文件路径。
   - `UnrealEngine.exe [Uproject路径] -diff [选项] remote local base result`用于合并。
   - 参见`EditorCommandLineUtilsImpl::RunAssetDiffCommand`了解更多信息。
   - 如果你使用Plastic SCM作为源代码控制，查看[此页面](https://github.com/PlasticSCM/UEPlasticPlugin#configure-visual-diff-of-blueprints-from-plastic-scm-gui)。
 - [Perforce在UE项目上的快速入门介绍](https://www.youtube.com/watch?v=oqCj52bFK7c)。
   - PerforceU的目录主要与UE相关：[https://perforceu.perforce.com/catalogue](https://perforceu.perforce.com/catalogue)
 - Git不是Unreal项目的良好版本控制。[原因在这里](https://www.youtube.com/watch?v=SGPleVfrPyo&t=1666s)。
 - 你可以使用[此插件](https://github.com/BraceYourselfGames/UE-BYGCrossBranchLock)在Perforce中启用跨分支锁定。
 
 # 输入
 
 - 始终使用绑定，从不直接查询按钮。
 - `Enhanced Input Plugin`现在是Unreal中处理输入的推荐方式，如果你还没有查看过，请检查一下。
 
 # 关卡流送
 
 - 关卡流送的帧预算是高度可定制的，查看[UDN线程](https://udn.unrealengine.com/s/question/0D52L00004ludzoSAA/level-streaming-async-settings)。
   
   ![](../../../assets/images/Untitled_1.png)
   
 - 始终使用`EndPlay`而不是`UnloadEvent`进行游戏逻辑。
 如果你曾经禁用cvar`s.ForceGCAfterLevelStreamedOut`以消除关卡卸载时的卡顿，这将延迟关卡卸载直到GC运行，而不是立即卸载。`UnloadEvent`仅在关卡实际卸载时调用，因此禁用cvar后，它可能在GC决定运行时发生，最多可能延迟一分钟。只需使用`EndPlay`清理即可解决该问题。
   - 使用World Partition时，`s.ForceGCAfterLevelStreamedOut`默认关闭。
 - 当你通过`ULevelStreaming`手动显示/隐藏关卡时，`BeginPlay`和`EndPlay`可以在对象生命周期中被多次调用。
 
 # 世界分区
 
 - 要打开调试流送网格：`wp.Runtime.ToggleDrawRuntimeHash2D`
   - 默认显示级别0，你可以使用`wp.Runtime.ShowRuntimeSpatialHashGridLevel <level_number>`更改网格级别
   - 你也可以使用`wp.Runtime.ShowRuntimeSpatialHashGridLevelCount <level_count>`同时显示多个网格级别
 
 # 多人游戏
 
 查看[多人网络纲要 | Cedric Neukirchen的Unreal Engine博客 (cedric-neukirchen.net)](https://cedric-neukirchen.net/docs/category/multiplayer-network-compendium/)和[Unreal Engine多人游戏提示和技巧 - WizardCell](https://wizardcell.com/unreal/multiplayer-tips-and-tricks/)。
 
 # 注意事项
 
 - 用户可以在Asset Registry完成资产发现之前启动Play-In-Editor (PIE)会话。如果你在游戏早期使用Primary Assets和/或尝试查询/加载资产注册表，在编辑器中它可能尚未填充（打包构建没有此问题，它们会在开始游戏前同步加载资产注册表）。仅在编辑器中游戏开始时查询资产注册表的加载状态，如果发生这种情况，强制等待。]]