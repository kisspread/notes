---
title: 一些概念和简写搜集
comments:  true
---

## Abbreviation

- SELinux(Security-Enhanced Linux) 安全增强型 Linux ( SELinux ) 是一个Linux 内核 安全模块，它提供了一种支持访问控制安全策略的机制，包括强制访问控制(MAC)。
  - The key concepts underlying SELinux can be traced to several earlier projects by the United States National Security Agency (NSA).
  - SELinux 背后的关键概念可以追溯到美国国家安全局 (NSA) 的几个早期项目
  - 即使是root用户也要受到SELinux限制

- RHI (Rendering Hardware Interface): 将引擎的渲染命令转换为具体图形API的调用(如DirectX、Vulkan、OpenGL等)

- AOS(Array of Structures) 每个粒子的所有属性都连续存储
- SOA(Struct of Arrays)  同类型的属性连续存储

- SIMD (Single Instruction Multiple Data) 单指令多数据
  - 内存对齐以优化访问效率
  - SIMD指令进行向量化运算,很类似GPU的工作方式
  ```txt
    CPU SIMD (Single Instruction Multiple Data):
    [数据1][数据2][数据3][数据4] -> 单条指令同时处理4个数据
    |_______________________________|
        一个SIMD寄存器(如SSE/AVX)

    GPU SIMT (Single Instruction Multiple Threads):
    [线程1][线程2][线程3][线程4]....[线程32] -> 一个波前(Wavefront)
    |_______________________________________|
        一个Warp/Wavefront
  ```

::: details

[source](https://forums.unrealengine.com/t/multithreading-and-performance-in-unreal/1216417)

#### ***函数***

众所周知，SIMD 的学习和实现非常棘手，花时间理解 [Intrinsic](https://learn.microsoft.com/zh-cn/cpp/intrinsics/x86-intrinsics-list?view=msvc-170) 可能会让人望而却步；撰写关于 SIMD 实现的摘要可能和本文档的长度一样，所以我们就不展开讨论了。

Unreal 通过 `FMath` 封装了许多 SSE Intrinsic，例如 `Math::RoundToInt(float)` 内部调用了 `UE4::SSE::RoundToInt()` (如果可用，则调用 `SSE4`)，而后者本身又使用了 `_mm_cvt_ss2si()`。

据我所知，在 Unreal 的实现中，Intrinsic 从来都不是直接使用的，它们总是通过像 `FMath` 这样的包装器，以便检查平台可用性。如果你想了解更多，我建议你使用 IDE 在源代码文件中搜索 "SSE" 和 "AVX"；同时也可以看看 `sse_mathfun.h` 和 `Align()` 函数。

MSVC 提供了一个 [optimize pragma](https://learn.microsoft.com/zh-cn/cpp/preprocessor/optimize?view=msvc-170)  可以在函数定义之前放置。由于默认工具链使用的标志，或者可能使用了默认已启用的优化，它可能根本不起作用，或者可能已经开启了默认优化。我对此没有做深入研究。

#### ***库***

向量指令的“默认”方法是通过 Intrinsics；它最底层且最抽象。Intel Intrinsics 可用于 Intel 和 AMD 的 CPU，因为它们的底层架构相似，但是 ARM（移动）平台则使用 [Neon Intrinsics](https://developer.arm.com/documentation/102581/latest) 代替。

主流编译器具有向量化 pragma 和函数的扩展：

* MSVC 中的 [OpenMP](https://learn.microsoft.com/zh-cn/cpp/parallel/openmp/openmp-simd?view=msvc-170)。[/openmp](https://learn.microsoft.com/zh-cn/cpp/build/reference/openmp-enable-openmp-2-0-support?view=msvc-170) 编译器选项在 Unreal 中可能默认被禁用，需要从源代码重新编译。
* GCC 中的 [std::simd](https://github.com/VcDevel/std-simd)。

也存在一些第三方库，用来抽象 Intrinsics 的一些复杂性：

* [Intel ISPC](https://www.youtube.com/watch?v=OZwfVgnslDE) for Unreal：在引擎的源代码中使用。更多信息请看 [这里](https://www.intel.com/content/www/us/en/developer/videos/simple-single-instruction-multiple-data-simd.html), [这里](https://www.intel.com/content/dam/develop/external/us/en/documents/simd-made-easy-with-intel-ispc.pdf) 和 [这里](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-software-engineers-assist-with-unreal-engine-419-optimizations.html)。
* [OpenCL for Unreal](https://github.com/getnamo/opencl-ue4): 一种具有广泛 SIMD 功能的独立语言。
* [Light SIMD](https://github.com/AlbertoBoldrini/simd-cpp) 和 [Pure SIMD](https://github.com/eatingtomatoes/pure_simd)：SIMD 功能的包装器。

在所有情况下，请确保你想要做的事情不是已经可以通过 Unreal 提供的与平台无关的类来实现的。 

:::

- AOT (Ahead Of Time): 一种编译技术，指的是"提前编译"
- JIT（Just In Time): 即时编译
- SPH (Smoothed Particle Hydrodynamics): 光滑粒子流体动力学,一种用于流体模拟的数值计算方法
- TBB （Threading Building Blocks）：Intel的TBB 是一个 C++ 模板库 用于简化并行程序的开发


- UMA (Universal Memory Architecture): 统一内存架构


## Concept

- L1 距离，也叫曼哈顿距离（Manhattan Distance）
  - 曼哈顿距离的命名原因是从规划为方型建筑区块的城市（如曼哈顿）间，最短的行车路径而来
  - 也叫方格线距离，$\displaystyle d(x,y)=\left|x_{1}-x_{2}\right|+\left|y_{1}-y_{2}\right|.$

- L2 距离，也叫欧几里得距离（Euclidean Distance），是计算两点之间最直线距离的一种方法，在数学和计算机科学中非常常用，尤其是在机器学习、图像处理和数据分析领域。

- Hamming distance : 汉明距离，指的是两个字符串之间的不同位数
  - 汉明距离也等于n维超正方体两个顶点之间的曼哈顿距离
  - 比如顶点 (0, 0, 1) 和 (1, 1, 0) 的曼哈顿距离：|0-1| + |0-1| + |1-0| = 1 + 1 + 1 = 3

- Octree: 八叉树搜索算法。它是一种三维空间划分的数据结构和搜索算法，主要3D场景管理,碰撞检测,点云数据处理