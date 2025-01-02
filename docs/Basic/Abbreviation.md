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

- AOT (Ahead Of Time): 一种编译技术，指的是"提前编译"
- JIT（Just In Time): 即时编译
- SPH (Smoothed Particle Hydrodynamics): 光滑粒子流体动力学,一种用于流体模拟的数值计算方法
- TBB （Threading Building Blocks）：Intel的TBB 是一个 C++ 模板库 用于简化并行程序的开发


- UMA (Universal Memory Architecture): 统一内存架构


## 概念

- L1 距离，也叫曼哈顿距离（Manhattan Distance）
  - 曼哈顿距离的命名原因是从规划为方型建筑区块的城市（如曼哈顿）间，最短的行车路径而来
  - 也叫方格线距离，$\displaystyle d(x,y)=\left|x_{1}-x_{2}\right|+\left|y_{1}-y_{2}\right|.$

- L2 距离，也叫欧几里得距离（Euclidean Distance），是计算两点之间最直线距离的一种方法，在数学和计算机科学中非常常用，尤其是在机器学习、图像处理和数据分析领域。

- Hamming distance : 汉明距离，指的是两个字符串之间的不同位数
  - 汉明距离也等于n维超正方体两个顶点之间的曼哈顿距离
  - 比如顶点 (0, 0, 1) 和 (1, 1, 0) 的曼哈顿距离：|0-1| + |0-1| + |1-0| = 1 + 1 + 1 = 3

- Octree: 八叉树搜索算法。它是一种三维空间划分的数据结构和搜索算法，主要3D场景管理,碰撞检测,点云数据处理