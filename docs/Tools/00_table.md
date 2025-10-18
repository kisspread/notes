 
# Awesome UE5 Tools
Including open source and non-open source, commercial and non-commercial.

> 是否awesome，需要根据个人需求来判断。另外，第三方工具选择需要慎重~

 

### **目录**
*   [Editor Tools](#editor-tools)
*   [Animation](#animation)
*   [Niagara](#niagara)
*   [Gameplay](#gameplay)
*   [Character](#character)
*   [UI](#ui)
*   [Shader](#shader)
*   [NetWork](#network)
*   [Framework](#framework)
*   [Tools](#tools)
*   [Engine](#engine)
*   [Script](#script)
*   [Python](#python)
*   [Projects](#projects)

---
### **Editor Tools**
| 地址名字 | 原项目说明 | Note | img |
| :--- | :--- | :--- | :--- |
| [K2PostIt](https://github.com/HomerJohnston/K2PostIt) | A small plugin which is intended to look down upon Unreal's very annoying "Comment" node. | 一个更加强大，好看的注释工具，支持Markdown。 | ![K2PostIt](../assets/images/00_image-80.webp) |
| [Yap](https://github.com/HomerJohnston/Yap) | Yap is a project-agnostic dialogue engine running on FlowGraph. | 一个基于FlowGraph的对话引擎，支持蓝图和C++。 | ![Yap](../assets/images/00_image-83.webp) |
| [CustomShortcuts](https://github.com/Adrien-Lucas/CustomShortcuts) | Custom Shortcuts is a plugin initially released to UE5 to allow designers to make their own editor shortcuts by executing blueprint editor code. | 允许设计师通过执行蓝图编辑器代码来制作自己的编辑器快捷方式。 | ![CustomShortcuts](../assets/images/00_image-84.webp) |
| [EnhancedPalettePlugin](https://github.com/aquanox/EnhancedPalettePlugin) | Enhanced Palette Plugin for Unreal Engine extends capabilities of Place Actors panel. | 该插件扩展了虚幻编辑器 Place Actors 面板的功能，允许从编辑器设置中进行自定义，并授予动态生成类别内容的能力。 | ![EnhancedPalettePlugin](../assets/images/00_image-82.webp) |
| [MDViewModel](https://github.com/DoubleDeez/MDViewModel) | An Unreal Engine 5 Model-View-ViewModel Plugin with automatic data binding to use in UMG Widget, Actor, and Object Blueprints. | 另一个UE的MVVM框架，支持actor、blueprint、UMG、object blueprints。 | <img src="../assets/images/00_image-77.webp" alt="MDViewModel" > |
| [SubsystemBrowserPlugin](https://github.com/aquanox/SubsystemBrowserPlugin) | Plugin that adds a Subsystem Browser panel for Unreal Engine Editor to explore running subsystems and edit their properties. | 一个查看 Subsystem 的工具,用于探索正在运行的子系统并编辑其属性。 | <img src="../assets/images/00_image-79.webp" alt="SubsystemBrowserPlugin" > |
| [BlueprintComponentReferencePlugin](https://github.com/aquanox/BlueprintComponentReferencePlugin) | Provides a struct and set of accessors that allow referencing actor components from blueprint editor details view with a component picker. | 在编辑器里，当你有一个 UPROPERTY 要保存某个组件引用时，这个插件能自动列出目标 Actor 的组件选项供你选择，而不是手动输入或硬编码。 | ![BlueprintComponentReferencePlugin](../assets/images/00_image-75.webp) |
| [QuickActions](https://github.com/outoftheboxplugins/QuickActions) | Find Anything Inside Unreal Editor Quick. | - 仿MacOS的快捷操作，类似JetBrains的双击shift搜索。<br>- 除了查找各种资产，还可以执行各种内置的命令，动作。<br>- Fab: [Link](https://www.fab.com/listings/7b9e1f59-9367-4851-8aaf-a0479cd976be)<br>- 文档: [Link](https://outofthebox-plugins.notion.site/Quick-Actions-28b7a364109441779f11d1e6f5f75658)<br><details><summary>作者赠言</summary>If you want to:<br>Find and execute actions within Unreal in seconds without using your mouse<br><br>Increase your productivity by quickly accessing recent and favorite commands<br><br>Interact with Unreal's built-in functionality in a more user-friendly manner<br><br>Learn more about the tools by viewing their assigned shortcuts & detailed tooltips<br><br>Create your own automation scripts to simplify your workflows<br><br>Then I encourage you to keep reading, this product might be for you.<br><br>The true reason people love Apple products<br><br>"Apple products just work."<br><br>If you ask Apple users why they why they made their choice, there is a 80% chance this is the answer you will get.<br><br>After running this experiment on Twitter one day, I can confirmed that's the case.<br><br>The next day I went to the closest Apple Store to test out a MacBook 16inch Pro.<br><br>That's when I discovered the Spotlight Search.<br><br>That tool was so fast, fun and reliable to use.<br><br>I thought to myself: "This is the best thing ever, I need to bring it to Unreal Engine".<br><br>I have to admit, it was a lot more complicated than I anticipated and required much more work.<br><br>After a few months of late nights and a few more research trips to the Apple Store, I finally had something to show.<br><br>It wasn't anywhere near perfect, but the feedback I got from the community was incredible. It confirmed my assumption people will love it.<br><br>The reactions were enough to keep me going and I pour more and more time into it. <br><br>My Dream<br><br>On my journey to develop this tool, I've met some incredible people along the way. I am grateful for every single like, comment, retweet, dm or feedback received.<br><br>I hope one day this amazing tool will get fully integrated in the Unreal Engine.<br><br>Until that day, this plugin will remain here on the marketplace for free and open-sourced on GitHub.<br><br>I realized this is a much bigger project than I can take on my own.<br><br>Feel free to Contribute, steal, or do whatever you please with it.</details> | <img src="../assets/images/00_image-74.webp" alt="QuickActions" > |
| [SlateStyleBrowser](https://github.com/sirjofri/SlateStyleBrowser) | This small tool lets you browse Unreal Engine's Slate styles easily, search for specific ones and copy slate code for the selected style or brush. | 这个小工具可以让你轻松浏览虚幻引擎的Slate样式，搜索特定的样式，并复制选定样式或笔刷的Slate代码。 | <img src="../assets/images/00_image-73.webp" alt="SlateStyleBrowser" > |
| [PropertyWatcher](https://github.com/guitarfreak/PropertyWatcher) | A runtime variable watch window for Unreal Engine using ImGui. | 不是插件，是一个Imgui使用的代码案例。 | <img src="../assets/images/00_image-76.webp" alt="PropertyWatcher" > |
| [ImGuiPlugin](https://github.com/amuTBKT/ImGuiPlugin) | A simple plugin for integrating Dear ImGui in Unreal Engine 5. | - 来自 [amu_mhr](https://x.com/amu_mhr) 的 UE5 ImGui 集成。<br>- 和其他 ImGui Plugin 不同的是，它通过套了一层 Slate Widget 来实现类型原生widget的dock效果。<br>- 更好看的UIShader。<br>- 附带一个 example： [ImGuiExamples](https://github.com/amuTBKT/ImGuiExamples) | <video controls src="../assets/images/amutbk_imgui3.mp4" title="ImGuiPlugin Demo"></video> |
| [ImGui (VesCodes)](https://github.com/VesCodes/ImGui) | Supercharge your Unreal Engine development with Dear ImGui. | - 另一个imgui，支持Multiple Viewports, Docking, Editor Support, Play-in-Editor, Remote Drawing。<br>- 这里的docking是指 `Dear ImGui` 的原生docking功能，而不是通过 Slate Widget 实现的。<br>- 多视口功能允许您将 Dear ImGui 窗口无缝地从主渲染上下文中提取出来。 | ![VesCodes ImGui](../assets/images/00_image-78.webp) |
| [UnrealImGui](https://github.com/IDI-Systems/UnrealImGui) | Unreal plug-in that integrates Dear ImGui framework into Unreal Engine 4/5. | IDI-Systems 的 ImGui 集成,最多人用的版本。 | |
| [RaylibUE](https://github.com/DarknessFX/RaylibUE) | Bridge Raylib's easy-to-use drawing API with Unreal Engine's intuitive Blueprint nodes. | 特定场景下有用：用一个独立的渲染叠加层（overlay） 在 Unreal 的游戏视口上渲染。 | |
| [DFoundryFX](https://github.com/DarknessFX/DFoundryFX) | Plugin with Dear ImGUI, customizable performance metric charts, Shader compiler monitoring and STAT commands control panel. | - 提供一个面板来控制常用的 STAT 命令，更方便在 Game Viewport 里直接切换／查看。<br>- 可以看到 Shader 编译过程／状态。 | |
| [PropertyHistory](https://github.com/VoxelPlugin/PropertyHistory) | Property History allows you to quickly see the history of a property. | 快速查看属性的修改历史，支持actors, material nodes, material instances等。 | <img src="../assets/images/00_image-67.webp" alt="PropertyHistory" > |
| [ProjectCleaner](https://github.com/ashe23/ProjectCleaner) | Unreal engine plugin for managing all unused assets and empty folders in project. | 用于清理未使用的资源和空文件夹。 | ![ProjectCleaner](../assets/images/00_image-60.webp) |
| [UEToolboxPlugin_Dev](https://github.com/gradientspace/UEToolboxPlugin_Dev) | Contains a development setup for the Gradientspace UEToolbox plugin. | - 作者是Modeling Mode和Geometry Script的核心开发者。<br>- 该插件从闭源到开源的心路历程，值得细品：[UEToolbox, Parametric Assets, and Open-Source](https://www.gradientspace.com/tutorials/2025/8/3/uetoolbox-parametric-assets-and-opensource)<br><blockquote>不幸的是，就我个人的抱负而言，Epic Games Inc 对“运行时工具”方面并不特别感兴趣...<br>在 Epic 的 Lyra 项目中，我们拼凑了一个系统...完全是黑客行为。</blockquote> | ![UEToolboxPlugin_Dev](../assets/images/00_image-56.webp) |
| [NodeToCode](https://github.com/protospatial/NodeToCode) | Translate Unreal Engine Blueprints to C++ in seconds. Not hours. | 由 LLM 提供支持的插件，一键将蓝图图表转换为简洁、结构化的 C++ 代码。 | ![NodeToCode Demo](https://github.com/protospatial/NodeToCode/raw/main/assets/Image_NodeToCode_BlueprintTranslation.gif) |
| [BlueprintRetarget](https://github.com/PipeRift/BlueprintRetarget) | An small tool that allows retargeting invalid blueprints when its parent class is missing on UE4. | 当父类丢失时，用于重定向失效蓝图的小工具。 | |
| [RVisualNarrative](https://github.com/Srkmn/RVisualNarrative) | A cross-version dialogue state machine editor plugin for Unreal Engine. | 为虚幻引擎开发的跨版本对话状态机编辑器插件，旨在提供可视化、灵活且高效的剧情对话编辑或者状态机解决方案。 | |
| [CrystalNodes](https://github.com/SkylakeOfficial/CrystalNodes/wiki) | Crystal Nodes contains a simple module that changes your blueprint graph style. | 一个简单的模块，可以更改您的蓝图图形样式。它使用自定义材质作为slate笔刷，并与蓝图布线插件兼容。 | <img src="../assets/images/00_image-68.webp" alt="CrystalNodes" > |
| [UE_TAPython](https://github.com/cgerchenhp/UE_TAPython_Plugin_Release) | An editor plugin for Unreal Engine that provides a framework for creating python editor tools. | 并非开源项目，但免费使用。提供了超过200个编辑器工具接口，使创建菜单和UE原生Slate UI变得更加容易和快速。 | <img src="../assets/images/00_image-7.webp" alt="UE_TAPython" > |
| [BPCorruptionFix](https://github.com/rweber89/BPCorruptionFix) | Fixes corrupted Blueprints due to Actor Component changes. | 有用，但不常用。用于修复因Actor组件更改而损坏的蓝图。 | |
| [AdvancedUI](https://github.com/nikkomiu/AdvancedUI) | Allows setting a custom and persistent UI scale for the editor. | 修改并保存UE编辑器的默认缩放比例。目前只有这一个功能。 | |
| [UE-ProgramBrowser](https://github.com/SkecisAI/UE-ProgramBrowser) | Create, Build, Package an Unreal Engine Standalone Program Application. | 使用虚幻引擎资源创建独立应用程序（而非游戏），实现从创建到打包的一键式流程管理。<br>更多参考: [知乎文章](https://zhuanlan.zhihu.com/p/391228179) | <img src="../assets/images/00_image-8.webp" alt="UE-ProgramBrowser 1" ><br><img src="../assets/images/00_image-9.webp" alt="UE-ProgramBrowser 2" > |
| [UEGitPlugin](https://github.com/ProjectBorealis/UEGitPlugin) | Unreal Engine Git Source Control Plugin (refactored). | 重构版的UE Git源码控制插件。 | |
| [PCG Assets](https://github.com/TimChen1383/PCGAsset.git) | A collection of custom PCG C++ nodes. | 大量PCG C++自定义节点资产。 | ![PCG Assets](../assets/images/00_image-11.webp) |
| [WFCLevelCreator](https://github.com/alwayswinder/WFCLevelCreator) | UE5 WFC algorithm for map generation. | UE5 WFC 算法生成地图。<br>还可以参考作者自定义slate ui的实现，干货很多: [Bilibili Video](https://www.bilibili.com/video/BV1jz421C7bS/) | <img src="../assets/images/00_image-10.webp" alt="WFCLevelCreator" > |
| [动画纹理](https://github.com/neil3d/UAnimatedTexture4) | This plugin allows you to import animated GIF into your Unreal Engine 4 project as a new AnimatedTexture asset type. | 直接把GIF作为一种资产导入。 | <img src="../assets/images/00_image-12.webp" alt="动画纹理" > |
| [Renom](https://github.com/UnrealisticDev/Renom) | A simple tool to rename Unreal Engine projects. | UE5改名工具。(实测不是很好用, 可能是项目自身原因) | |
| [MDMetaDataEditor](https://github.com/DoubleDeez/MDMetaDataEditor) | Plugin to enable editing meta data of Blueprint Properties, Functions, and Parameters. | 支持使用蓝图修改、配置元数据。 | |
| [RefreshAllNodes](https://github.com/nachomonkey/RefreshAllNodes) | Unreal Engine plugin that refreshes and compiles all of your blueprints. | 该插件在编辑器中创建一个按钮，它将在所有蓝图上运行内置的“刷新所有节点”命令。 | |
| [Cog](https://github.com/arnaud-jamin/Cog) | A set of debug tools for Unreal Engine built on top of Dear ImGui. | 基于Dear ImGui的UE调试工具集合。提供比UE原版更好用的GAS、EnhancedInput、行为树、CheatMenu等调试工具。 | <img src="../assets/images/00_image-13.webp" alt="Cog" > |
| [Minesweeper](https://github.com/GapingPixel/Minesweeper) | Minesweeper Editor Tool. Fully made with Slate. | Slate 实现的扫雷游戏。 | <img src="../assets/images/00_image-4.webp" alt="Minesweeper" > |

---
### **Animation**
| 地址名字 | 原项目说明 | Note | img |
| :--- | :--- | :--- | :--- |
| [TurboSequence](https://github.com/LukasFratzl/TurboSequence) | Skeletal Based GPU Crowds for UE5 🚀 | 用GPU加速骨骼动画。 | ![TurboSequence](../assets/images/00_image-14.webp) |
| [mixamo_converter](https://github.com/enziop/mixamo_converter) | Blender addon for converting mixamo animations to Unreal 4 rootmotion. | mixamo 根动画转换神器。 | |
| [ALSXT](https://github.com/Voidware-Prohibited/ALSXT) | Advanced Locomotion System Refactored with expanded Character States, Improved Foot Print system, Sliding, Vaulting and Wallrunning(XT). | 高级运动系统重构版，增加了角色状态、改进的脚印系统、滑动、翻越和跑墙。 | ![ALSXT](../assets/images/00_image-16.webp) |
| [风动骨骼布料物理](https://github.com/SPARK-inc/SPCRJointDynamicsUE4) | Real looking cloth physics engine for Unreal. | 看起来非常真实的布料物理引擎。 | ![SPCRJointDynamicsUE4](../assets/images/00_image-15.webp) |
| [KawaiiPhysics](https://github.com/pafuhana1213/KawaiiPhysics) | A pseudo-physics plugin for Unreal Engine 4 and 5. It allows you to create simple and cute animations for objects like hair, skirts, and breasts. | 低计算成本物理动画模拟。 | <img src="../assets/images/00_image-17.webp" alt="KawaiiPhysics" > |
| [ThreepeatAnimTools](https://github.com/threepeatgames/ThreepeatAnimTools) | Contains Unreal 5.4+ curve editor filters and a heavily-modified MetaHuman character picker. | 包含 UE 5.4+ 曲线编辑器过滤器和经过大量修改的 MetaHuman 角色选择器，适用于 Metahuman 和 UE5-Mannequin 控制装置。 | <img src="../assets/images/00_image-18.webp" alt="ThreepeatAnimTools" > |
| [ProceduraAnim](https://github.com/alwayswinder/ProceduraAnim) | UE5 procedural animation example, four-legged robot demo. | UE5程序化动画例子，四足机器人演示。<br>林佬作品，干货很多: [Bilibili Video](https://www.bilibili.com/video/BV1xY2NYUEau/) | <img src="../assets/images/00_image-19.webp" alt="ProceduraAnim" > |
| [SimpleRideControl](https://github.com/alwayswinder/SimpleRideControl) | Imitating Elden Ring's horse mounting animation and camera control. | 仿老头环上马动画和镜头控制。<br>演示视频: [Bilibili Video](https://www.bilibili.com/video/BV1nw411s7fU/) | <img src="../assets/images/00_image-20.webp" alt="SimpleRideControl" > |

---
### **Niagara**
| 地址名字 | 原项目说明 | Note | img |
| :--- | :--- | :--- | :--- |
| [Niagara Destruction Driver](https://github.com/eanticev/niagara-destruction-driver) | Turn CHAOS destructibles into performant GPU simulated destructible static meshes driven by Niagara particles. | 使用Niagara驱动chaos破坏的网格体，用GPU提高性能，非常好的学习资源。 | ![Niagara Destruction Driver](../assets/images/00_image-21.webp) |
| [SpawnToNiagara](https://github.com/aggressivemastery/SpawnToNiagara) | This sample provides blueprint code and levels examples on how to spawn specific textured particles to a single niagara system. | GameDevMicah 是GiantessPlayground的作者：[@gamedevmicah](https://x.com/gamedevmicah)<br>相关项目：[NaniteMaterialUnification](https://github.com/aggressivemastery/NaniteMaterialUnification) 演示如何使用 PerInstanceCustomData 和 CustomPrimititiveData 在单个主材质中驱动纹理选择。 | |

---
### **Gameplay**
| 地址名字 | 原项目说明 | Note | img |
| :--- | :--- | :--- | :--- |
| [GameItemsPlugin](https://github.com/bohdon/GameItemsPlugin) | An Unreal plugin with classes and tools for creating gameplay items, inventories and equipment. | Lyra 的扩展，GAS相关，MVVM，可以学习一下相关写法。 | |
| [GameExperiencesPlugin](https://github.com/bohdon/GameExperiencesPlugin) | An Unreal plugin for defining modular extensions to game modes that leverage the GameFeatures plugin. Based on Lyra experiences. | 一系列游戏功能操作，用于模块化添加技能、控件等。 | |
| [ExtendedGameplayAbilitiesPlugin](https://github.com/bohdon/ExtendedGameplayAbilitiesPlugin) | Unreal plugins that extend gameplay abilities and related systems. | GAS的一些扩展，可以参考学习一下。 | |
| [Starfire](https://github.com/MagForceSeven/Starfire) | A collection of UE5 plugins that I've developed over the course of my hobby development. | 作者在业余开发过程中开发的一系列UE5插件。 | |
| [UE-Portals](https://github.com/rchaucha/UE-Portals) | This plugin has been developed for the study of visual properties only. | 主要用于视觉属性研究的传送门插件，传送功能是次要的。 | ![UE-Portals](../assets/images/00_image-65.webp) |
| [Array-Utils](https://github.com/pyoneerC/Array-Utils) | STL utilities for Unreal Engine Arrays. | 为UE的TArray提供类似STL的实用功能。 | ![Array-Utils](../assets/images/00_image-64.webp) |
| [SharedCoolingAbility](https://github.com/hbdjzwl/SharedCoolingAbility) | A concise, out-of-the-box shared cooling plugin that supports single-player and online play. | 简洁式开箱即用支持单机、联机的共享冷却插件，无需写代码，不耦合项目。 | ![SharedCoolingAbility](../assets/images/00_image-63.webp) |
| [ue-gameplay-work-balancer](https://github.com/eanticev/ue-gameplay-work-balancer) | Unreal Engine Plugin that helps you spread work (time slice it) across multiple frames so your game maintains a stable frame rate (FPS). | 帮助您将工作分散到多个帧上（时间切片），以保持稳定的帧率。 | ![ue-gameplay-work-balancer](../assets/images/00_image-22.webp) |
| [VoxelPlugin](https://github.com/VoxelPlugin/VoxelCore) | Open-source plugin with the Core module of Voxel Plugin. | 虚幻引擎5的体素插件。个人免费使用，目前只开源了1.0，2.0预览版需要付费。官网: [voxelplugin.com](https://voxelplugin.com/) | ![VoxelPlugin](../assets/images/00_image-23.webp) |
| [FutureExtensions](https://github.com/splash-damage/future-extensions) | Unreal Engine plugin for async task programming. | 用于异步任务编程的UE插件。 | |
| [UE5Coro](https://github.com/landelare/ue5coro) | UE5Coro implements C++20 coroutine support for Unreal Engine 5 with a focus on gameplay logic, convenience, and seamless integration. | - 为UE5实现C++20协程支持。<br>- 让蓝图也支持协程函数。<br>- wrap了多个module, 使用方便。 | |
| [FlowGraph](https://github.com/MothCocoon/FlowGraph) | Design-agnostic node system for scripting game’s flow in Unreal Engine. | 用于在UE中编写游戏流程脚本的、与设计无关的节点系统。 | ![FlowGraph](../assets/images/00_image-24.webp) |
| [Dialogue Plugin](https://github.com/NotYetGames/DlgSystem) | Dialogue Plugin System for Unreal Engine. | UE对话插件系统。 | |
| [SPUD](https://github.com/sinbad/SPUD) | SPUD is a save game and streaming level persistence solution for Unreal Engine 5. | 易用的存档系统和流式关卡持久化解决方案。 | |
| [stream-chat-unreal](https://github.com/GetStream/stream-chat-unreal) | The official Unreal SDK for Stream Chat, a service for building chat and messaging games and applications. | 聊天框架，源码值得学习。该stream不是那个steam。 | <img src="../assets/images/00_image-25.webp" alt="stream-chat-unreal" > |

---
### **Character**
| 地址名字 | 原项目说明 | Note | img |
| :--- | :--- | :--- | :--- |
| [Mutable](https://github.com/anticto/Mutable-Documentation/wiki/Use-Cases) | Mutable generates skeletal meshes at runtime in your game. | 角色自定义系统。它可以在运行时生成任何类型的骨骼网格体，包括动物、道具和武器。 | ![Mutable](../assets/images/00_image-26.webp) |

---
### **UI**
| 地址名字 | 原项目说明 | Note | img |
| :--- | :--- | :--- | :--- |
| [UMG3dRenderWidget](https://github.com/krojew/UMG3dRenderWidget) | The UMG3dRenderWidget plugin provides the bridge between the PocketWorlds plugin from Epic and UE projects. | Lyra的扩展，可以将3D场景渲染到UMG中。适合在UI中展示独立世界（如角色选择界面）。 | |
| [Game UI Assets Guide](https://github.com/miltoncandelero/game-ui-assets-guide) | A guide for UI/UX artists and designers when they need to send their exported files to the programmers. | 给艺术家和设计师的UI资产导出指南，方便和程序员沟通。 | |
| [DeferredPainter](https://github.com/Sharundaar/DeferredPainter) | An UMG exposed deferred paint container for Unreal. | 延迟绘制容器，可以绕过常规绘制流程，在所有常规UI绘制完毕后最后再绘制容器内的内容。 | |
| [MDFastBinding](https://github.com/DoubleDeez/MDFastBinding) | A versatile and performant alternative to UMG property bindings for designer-friendly workflows. | 一个多功能且高效的 UMG 属性绑定替代方案，允许在编辑器内将原始数据转换为可驱动视觉效果的形式，同时保持高性能。 | ![MDFastBinding](../assets/images/00_image-72.webp) |
| [UIDatasource](https://github.com/Sharundaar/UIDatasource) | Light MVVM plugin for UI development. | 轻量级的UI开发MVVM插件。 | <img src="../assets/images/00_image-71.webp" alt="UIDatasource" > |
| [CowNodes](https://github.com/sleepCOW/CowNodes) | Improved Version of Epic's CreateWidget and CreateWidgetAsync (from CommonGame). | 异步创建widget。 | |
| [WidgetSplineSystem](https://github.com/ArmainAP/Unreal-Engine-Widget-Spline-System) | A free and open-source plugin for Unreal Engine that introduces a powerful spline widget. | 可编辑的样条线绘制widget，可以在 UMG 编辑器和运行时轻松绘制和编辑 2D 线条。 | |
| [NiagaraUIRenderer](https://github.com/SourySK/NiagaraUIRenderer) | Niagara UI Renderer | Free Plugin for Unreal Engine. | 在UI中渲染Niagara粒子效果的免费插件。 | <img src="../assets/images/00_image-27.webp" alt="NiagaraUIRenderer" > |
| [MeshWidgetExample](https://github.com/dantreble/MeshWidgetExample) | SMeshWidget Example. | SMeshWidget 示例。 | |
| [UINavigation](https://github.com/goncasmage1/UINavigation) | A UE4/5 plugin designed to help easily make UMG menus navigated by mouse, keyboard and gamepad. | 不想用CommonUI可以考虑这个，方便制作支持鼠标、键盘和手柄导航的UMG菜单。 | |
| [UE-BYGRichText](https://github.com/BraceYourselfGames/UE-BYGRichText) | Rich text library supporting customizable Markdown formatting. | <details><summary>功能对比</summary><table><thead><tr><th>Feature</th><th>Unreal Rich Text</th><th>BYG Rich Text</th></tr></thead><tbody><tr><td>Nested styles</td><td>:x:</td><td>:heavy_check_mark:</td></tr><tr><td>Customizable syntax</td><td>:x:</td><td>:heavy_check_mark:</td></tr><tr><td>Markdown-like shortcuts</td><td>:x:</td><td>:heavy_check_mark:</td></tr><tr><td>Inline images</td><td>:heavy_check_mark:</td><td>:heavy_check_mark:</td></tr><tr><td>Style-based justification</td><td>:x: (block only)</td><td>:heavy_check_mark:</td></tr><tr><td>Style-base margins</td><td>:x: (block only)</td><td>:heavy_check_mark:</td></tr><tr><td>Inline tooltips</td><td>:heavy_check_mark:</td><td>:heavy_check_mark:</td></tr><tr><td>Customizable paragraph separator</td><td>:x:</td><td>:heavy_check_mark:</td></tr><tr><td>XML-like syntax</td><td>:heavy_check_mark:</td><td>:heavy_check_mark:</td></tr><tr><td>Datatable-based stylesheet</td><td>:heavy_check_mark:</td><td>:x:</td></tr><tr><td>Blueprint code support</td><td>:heavy_check_mark:</td><td>:x:</td></tr></tbody></table></details> | |
| [ElementUI-UMG-Kit](https://github.com/rdelian/ElementUI-UMG-Kit) | An easy way to change the style of your elements that extends beyond the default ones the Common UI provides. | 提供比Common UI默认样式更丰富的元素样式扩展。 | ![ElementUI-UMG-Kit](../assets/images/00_image-28.webp) |
| [UI Tweening Libary for UE4/UMG](https://github.com/benui-dev/UE-BUITween) | Unreal 4 UMG UI tweening plugin in C++. | UI 补间动画，方便C++ 使用。 | |
| [UEImgui](https://github.com/ZhuRong-HomoStation/UEImgui) | IMGUI usage, supports code editor. | IMGUI的使用，支持代码编辑器。 | ![UEImgui](../assets/images/00_image-29.webp) |
| [运行时图片加载器](https://github.com/RaiaN/RuntimeImageLoader) | Load images and GIFs into Unreal at runtime without hitches. | 支持GIF，webp 格式。 | ![RuntimeImageLoader](../assets/images/00_image-30.webp) |

---
### **Shader**
| 地址名字 | 原项目说明 | Note | img |
| :--- | :--- | :--- | :--- |
| [RTMSDF](https://github.com/rtm223/RTMSDF) | 2D signed distance field generators & importers for Unreal Engine 5. | 提供导入器，用于从.svg和各种纹理源文件生成2D SDF。 | ![RTMSDF](../assets/images/00_image-81.webp) |
| [SceneViewExtensionTemplate](https://github.com/A57R4L/SceneViewExtensionTemplate) | Unreal Engine 5 plugin template for adding a custom rending pass into the engine with a SceneViewExtension. | 在不改引擎源码的前提下，向渲染管线里注入自定义渲染pass的插件模板。 | |
| [UE5_Tut_5_Custom_Material_Node](https://github.com/RyanSweeney987/UE5_Tut_5_Custom_Material_Node) | Tutorial code for how you can create your own material nodes for use in any material. | 创建自定义材质节点的教程代码，示例是一个简单的去饱和度节点。 | |
| [MaterialMaker](https://github.com/RodZill4/material-maker) | A procedural textures authoring and 3D model painting tool based on the Godot game engine. | 虽然说支持 Unreal Engine，但是测试发现生成的hlsl 依然代码存在很多报错 (2025.7.30)。 | ![MaterialMaker](../assets/images/00_image-58.webp) |
| [ProceduralDrawingMaterialSamples](https://github.com/EmbarrassingMoment/ProceduralDrawingMaterialSamples) | A collection of procedural drawing material samples for Unreal Engine (UE5). | UE5的程序化绘制材质示例集合，可用于学习技术美术和项目参考。 | ![Snow](https://github.com/EmbarrassingMoment/ProceduralDrawingMaterialSamples/raw/master/gif/Snow.gif)<br>![Animation](https://github.com/EmbarrassingMoment/ProceduralDrawingMaterialSamples/raw/master/gif/Animation.gif) |
| [DarknessFX/UEMaterials](https://github.com/DarknessFX/UEMaterials) | DarknessFX Collection of Unreal Engine Materials. | DarknessFX的UE材质集合。 | ![UEMaterials](../assets/images/00_image-32.webp) |

---
### **NetWork**
| 地址名字 | 原项目说明 | Note | img |
| :--- | :--- | :--- | :--- |
| [UE5.5-SteamSessionHelper](https://github.com/Sohel160202/UE5.5-SteamSessionHelper) | Blueprint-friendly fix for Steam hosting/joining issues in Unreal Engine 5.5. | 修复了UE 5.5中OnlineSubsystemSteam引入的一些问题，恢复了可靠的Steam多人游戏工作流程。 | ![UE5.5-SteamSessionHelper](../assets/images/00_image-85.webp) |
| [VaRest](https://github.com/ufna/VaRest) | REST API plugin for Unreal Engine 4 - we love restfull backend and JSON communications! | 该项目作者已经停止维护，推荐自己fork后使用。<br>但Fab版本依然在更新，且免费: [Fab Link](https://www.fab.com/listings/5b751595-fe3e-4e85-b217-9b5496ab6d3f) | |

---
### **Framework**
| 地址名字 | 原项目说明 | Note | img |
| :--- | :--- | :--- | :--- |
| [PCGExtendedToolkit](https://github.com/Nebukam/PCGExtendedToolkit) | PCGEx is a free (libre) Unreal 5 plugin that expands PCG capabilities. | 比官方PCG更强大的PCG工具。<br>示例项目: [PCGExExampleProject](https://github.com/Nebukam/PCGExExampleProject)<br>文档: [PCGEx Docs](https://nebukam.github.io/PCGExtendedToolkit/) | ![PCGExtendedToolkit](../assets/images/00_image-33.webp) |
| [imgui](https://github.com/ocornut/imgui) | Dear ImGui: Bloat-free Graphical User interface for C++ with minimal dependencies. | 代码驱动的UI开发方式，对程序员非常友好，非常适合做游戏内调试工具、编辑器扩展。 | ![imgui](../assets/images/00_image-34.webp) |
| [Taichi](https://github.com/taichi-dev/taichi) | Productive, portable, and performant GPU programming in Python. | 并行计算框架，适合计算密集型任务。可以很容易地集成到UE中，利用其高性能并行计算和UE的Python支持。 | ![Taichi](../assets/images/00_image-35.webp) |
| [spine-runtimes](https://github.com/EsotericSoftware/spine-runtimes) | Runtimes for Spine, a 2D skeletal animation tool for games. | Spine 是一款针对游戏开发的 2D 骨骼动画编辑工具, 支持虚幻。 | |
| [MassSample](https://github.com/Megafunk/MassSample) | A small sample project for understanding of Unreal Engine 5's experimental ECS plugin. | 用于理解UE5实验性ECS插件的小型示例项目。 | ![MassSample](../assets/images/00_image-36.webp) |
| [MassAIExample](https://github.com/Ji-Rath/MassAIExample) | A project primarily used to experiment with Mass, an ECS Framework. | 主要用于试验Mass（ECS框架）的项目。 | ![MassAIExample 1](../assets/images/00_image-37.webp)<br>![MassAIExample 2](../assets/images/00_image-38.webp) |
| [MaaassParticle](https://github.com/DevDingDangDong/MaaassParticle.git) | A UE5 plugin that renders large-scale crowds through Niagara and can control them via state management. | 通过Niagara渲染大规模人群并通过状态管理进行控制的UE5插件。 | ![MaaassParticle](../assets/images/00_image-39.webp) |
| [UnrealLibretro](https://github.com/N7Alpha/UnrealLibretro) | A Libretro Frontend for Unreal Engine. It lets you run emulators within Unreal Engine. | Libretro 游戏模拟器。它允许您在UE中运行Libretro核心（模拟器）。 | ![UnrealLibretro](../assets/images/00_image-40.webp) |

---
### **Tools**
| 地址名字 | 原项目说明 | Note | img |
| :--- | :--- | :--- | :--- |
| [UnrealEngine-UpdateTracker](https://github.com/pafuhana1213/UnrealEngine-UpdateTracker) | An automated service that monitors updates to Unreal Engine's private GitHub repository and summarizes important changes using AI. | 使用 Gemini AI 自动化分析 Unreal Engine 的更新，并将报告发布到GitHub Discussions。 | |
| [UE-Modding-Tools](https://github.com/Buckminsterfullerene02/UE-Modding-Tools) | A databank of every UE modding tool & guide that have potential to be used across multiple UE games. | 这是一个涵盖所有可能适用于多款虚幻引擎游戏的模组工具的数据库。 | |
| [UETools-GUI](https://github.com/Cranch-fur/UETools-GUI) | Dumper-7 (SDK) based solution for rapid debugging of Unreal Engine powered titles. | 一个基于 Dumper-7 的运行时调试 / modding 工具，通过DLL注入到游戏进程。 | |
| [UnrealAnalyzerMCP](https://github.com/ayeletstudioindia/unreal-analyzer-mcp) | A Model Context Protocol (MCP) server that provides powerful source code analysis capabilities for Unreal Engine codebases. | 一个MCP服务器，为UE代码库提供强大的源代码分析能力，使AI助手能够深入理解和分析UE源代码。 | |
| [DreamTranslatePO](https://github.com/TypeDreamMoon/DreamTranslatePO) | An automated translation tool for po localization files or csv localization files. | 虚幻引擎本地化工具，支持PO文件和CSV文件的自动翻译，接入AI。 | ![DreamTranslatePO](../assets/images/00_image-66.webp) |
| [UnrealHeightMap](https://github.com/manticorp/unrealheightmap) | Unreal Engine 16 Bit Grayscale PNG Heightmap Generator. | 在线高度图生成工具，大部分真实地形都能获取。工具地址: [manticorp.github.io/unrealheightmap](https://manticorp.github.io/unrealheightmap/) | |
| [DreamUnrealManager](https://github.com/TypeDreamMoon/DreamUnrealManager) | WinUI3 Unreal Engine Project / Unreal Engine Manager. | UE引擎/项目管理器 + 可视化预编译插件批量构建工具。 | ![DreamUnrealManager](../assets/images/00_image-55.webp) |
| [KeywordGacha](https://github.com/neavo/KeywordGacha) | A next-generation translation assistance tool that uses AI to analyze text content and generate termbases. | 使用 AI 能力分析小说、游戏、字幕等文本内容并生成术语表的次世代翻译辅助工具。 | <img src="../assets/images/00_image-41.webp" alt="KeywordGacha" > |
| [ComfyTextures](https://github.com/AlexanderDzhoganov/ComfyTextures) | Unreal Engine ⚔️ ComfyUI - Automatic texturing using generative diffusion models. | 用扩散模型给3d模型场景自动生成贴图。 | ![ComfyTextures](../assets/images/00_image-42.webp) |
| [RGB↔X](https://github.com/zheng95z/rgbx) | Image Decomposition and Synthesis Using Material- and Lighting-aware Diffusion Models. | AI根据输入图片生成材质。 | ![RGB↔X](../assets/images/00_image-43.webp) |
| [Libretro Shader](https://github.com/libretro/glsl-shaders) | Hand-converted glsl shaders from libretro's common-shaders repo. | 老电视机、老游戏 滤镜。 | ![Libretro Shader](../assets/images/00_image-44.webp) |
| [glslViewer](https://github.com/patriciogonzalezvivo/glslViewer) | Console-based GLSL Sandbox for 2D/3D shaders. | 基于控制台的2D/3D着色器GLSL沙盒。 | ![glslViewer](https://github.com/patriciogonzalezvivo/glslViewer/raw/main/.github/images/03.gif) |
| [UnrealGPUSwarm](https://github.com/timdecode/UnrealGPUSwarm) | A good starting point for learning how to write compute shaders in Unreal. | 学习compute shaders的例子。在GPU上实现了一个boid模拟。 | <video src="https://user-images.githubusercontent.com/980432/132757577-500416e4-5f27-4add-9c50-641889336d69.mp4" controls autoplay loop></video> |

---
### **Engine**
| 地址名字 | 原项目说明 | Note | img |
| :--- | :--- | :--- | :--- |
| [CSLocTools](https://github.com/xabk/CSLocTools) | A plugin and a set of engine patches for Unreal Engine 5 that help with localization and string table management. | 硬核的本地化重构工具，通过修改引擎源码实现。自动将控件中硬编码的文本替换为对字符串表的引用，解决技术债。 | |
| [MooaToon-Engine](https://github.com/Jason-Ma-0012/MooaToon-Engine) | A manga-style cartoon rendering engine. | 漫画风卡通渲染引擎。改了引擎管线，需要作为上游合并到UE5源码。官网: [mooatoon.com](https://mooatoon.com/) | |
| [UnrealEngine-Angelscript](https://github.com/Hazelight/UnrealEngine-Angelscript) | AngelScript Integration for Unreal Engine. | 天使脚本引擎，伟大无需多言。由《It Takes Two》的开发商Hazelight积极开发。官网: [angelscript.hazelight.se](https://angelscript.hazelight.se/) | |
| [NvRTX](https://github.com/NvRTX/UnrealEngine) | An optimized and feature-rich branch that contains all the latest developments in the world of ray tracing. | 虚幻引擎的 NVIDIA RTX 分支，包含光线追踪和神经图形领域的最新进展。官网: [NVIDIA RTX Branch](https://developer.nvidia.com/game-engines/unreal-engine/rtx-branch) | |
| [Moon-Engine](https://github.com/TypeDreamMoon/Moon-Engine) | Angel Script & Toon Rendering & NvRTX Unreal Engine. | 合并了三大上游： AngelScript, Toon Rendering, NvRTX。 | |
| [Unreal-NvRTX5.0-PhysX-ViteStudio](https://github.com/GapingPixel/Unreal-NvRTX5.0-PhysX-ViteStudio) | Fork of NvRTX-5.0 (DDGI Optimized) With PhysX, Tessellation (WIP) and Clang 13 compliance. | 目标是提供性能最高的UE5迭代。基于UE NvRTX 5.0版本，因为新版UE性能下降，该版本移动和碰撞计算速度更快。 | |

---
### **Script**
| 地址名字 | 原项目说明 | Note | img |
| :--- | :--- | :--- | :--- |
| [UnrealSharp](https://github.com/UnrealSharp/UnrealSharp) | A plugin to Unreal Engine 5, which enables developers to create games using C# (.NET 9) with Hot Reload. | 支持热更新和.NET 生态，NativeAOT编译已经在开发中。 | |
| [Puerts](https://github.com/Tencent/puerts) | Let's write your game in UE or Unity with TypeScript. | 在Unity支持 AOT 编译；在UE5 没看到相关说明，估计只能JIT，若平台不支持JIT会退化到解释执行。 | |
| [UnLua](https://github.com/Tencent/UnLua) | A feature-rich, easy-learning and highly optimized Lua scripting plugin for UE. | 功能丰富、易于学习且高度优化的UE Lua脚本插件。 | |

---
### **Python**
| 地址名字 | 原项目说明 | Note | img |
| :--- | :--- | :--- | :--- |
| [PythonSamples](https://github.com/ue4plugins/PythonSamples) | Contains some python samples to script the editor in Unreal Engine. | 包含一些用于在UE编辑器中编写脚本的python示例。 | <img src="../assets/images/00_image-5.webp" alt="PythonSamples" > |
| [UnrealEditorPythonScripts](https://github.com/mamoniem/UnrealEditorPythonScripts) | Some of my personal scripts i made to use for my own projects. | 作者为自己项目制作的一些个人脚本。 | <img src="../assets/images/00_image-6.webp" alt="UnrealEditorPythonScripts" > |

---
### **Projects**
| 地址名字 | 原项目说明 | Note | img |
| :--- | :--- | :--- | :--- |
| [AstralShipwright](https://github.com/strangergwenn/AstralShipwright) | Full game sources for Astral Shipwright, a space sim made with Unreal Engine 5. | 一个用UE5制作的太空模拟游戏的完整源码。 | ![AstralShipwright](../assets/images/00_image-62.webp) |
| [HeliumRain](https://github.com/strangergwenn/HeliumRain) | Full sources for Helium Rain, a realistic space opera using Unreal Engine 4. | 一个用UE4制作的现实主义太空歌剧游戏的完整源码。 | ![HeliumRain](../assets/images/00_image-61.webp) |
| [UE5RuntimeToolsFrameworkDemo](https://github.com/gradientspace/UE5RuntimeToolsFrameworkDemo) | Sample project/code that uses the UE5 InteractiveToolsFramework to provide a small modeling app at Runtime. | 使用UE5 InteractiveToolsFramework在运行时提供小型建模应用的示例项目。 | |
| [StateTreeTest](https://github.com/haktan313/StateTreeTest) | Advanced AI system using Unreal's State Tree. | 使用UE State Tree的高级AI系统。敌人可以施法，切换状态，并在低生命值时使用EQS寻找治疗药水。 | ![StateTreeTest](../assets/images/00_image-59.webp) |
| [FlowField-RVO2](https://github.com/fukeryester/FlowField-RVO2) | A FlowField+RVO2 source code finished with Cursor. | 一个FlowField+RVO2的源码实现。 | |
| [MaxQ](https://github.com/Gamergenic1/MaxQ) | Spaceflight Toolkit for Unreal Engine 5. | 演示了如何使用NASA的行业标准航天工具集（如何引入第三方C语言库）。 | ![MaxQ](../assets/images/00_image-45.webp) |
| [KittensMaze](https://github.com/ukustra/KittensMaze) | A source code of "Kittens' Maze", a free to play game developed in Unreal Engine 4. | 一个GAS项目，《小猫的迷宫》游戏的源码。 | |
| [OnAllFronts-Public](https://github.com/HaywireInteractive/OnAllFronts-Public) | Mass Entity (ECS) framework Demo. | Mass Entity (ECS) 框架演示。可以作为City Sample 项目的插件使用。 | ![OnAllFronts-Public](../assets/images/00_image-46.webp) |
| [ParagonUIPrototyping](https://github.com/roman-dzieciol/ParagonUIPrototyping) | Paragon UI Prototyping using UE4.11 UMG. | 8年前的UE4项目，可用于学习UI构建。 | ![ParagonUIPrototyping](../assets/images/00_image-47.webp) |
| [ActionRPG_UE53](https://github.com/vahabahmadvand/ActionRPG_UE53) | Action RPG sample project upgraded to the latest Unreal Engine 5.5. | 官方GAS项目升级虚幻5的版本。 | ![ActionRPG_UE53](../assets/images/00_image-48.webp) |
| [PixelSpiritDeck](https://github.com/patriciogonzalezvivo/PixelSpiritDeck) | A tool for learning, a library, and an oracle for GLSL shaders. | 大量Shader基础图形用例学习。每张卡片都展示了一个视觉元素及其生成它的GLSL着色器代码。 | ![PixelSpiritDeck](../assets/images/00_image-49.webp) |
| [MeshCuttingGunSample](https://github.com/HoussineMehnik/MeshCuttingGunSample) | Mesh-Cutting/Restoring mechanics. | 演示物理抓取，和对模型的切割还原。<br>作者更多开源项目: [unrealengineresources.com](https://unrealengineresources.com/samples) | ![MeshCuttingGunSample](../assets/images/00_image-50.webp) |
| [XFXInfinityBladeEffects](https://github.com/OurGameOrg/XFXInfinityBladeEffects) | Epic Games Infinity Blade Effects as a plugin. | 将《无尽之剑》的特效作为插件使用。 | ![XFXInfinityBladeEffects](../assets/images/00_image-53.webp) |