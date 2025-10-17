---
title: 缓存行
comments: true
---

# 缓存行

缓存行是CPU缓存中的最小传输单位。当CPU需要读取内存时，不会只读取需要的那个字节，而是会读取一整个缓存行的数据。

这个固定大小的块就是 缓存行。常见的缓存行大小是 64 字节（如 x86 和大部分 ARM 架构），但苹果的 ARM64 芯片（如 M1/M2）使用 128 字节。

**缓存行也是ECS中非常重要的知识点，需要熟悉。**

## 概念

### 内存访问的层次结构
```sh
CPU     寄存器 -> L1 缓存 -> L2 缓存 -> L3 缓存 -> 主内存(RAM)
速度：     快 ---------------------------------> 慢
容量：     小 ---------------------------------> 大
```

### 典型的多核心缓存层次结构
```sh
              Core 1                Core 2
            ┌────────┐            ┌────────┐
L1 Cache:   │ I$ | D$│            │ I$ | D$│     (私有，最快)
            └────────┘            └────────┘
                 │                     │
L2 Cache:   ┌────────┐            ┌────────┐     (私有)
            └────────┘            └────────┘
                 │                     │
L3 Cache:   ┌──────────────────────────────┐     (共享)
            └──────────────────────────────┘
                           │
            ┌─────────────────────────────┐
Main RAM:   │             RAM             │      (共享)
            └─────────────────────────────┘ 
```

### 各级缓存特点

L1 缓存：

```C++
// 典型大小：32KB-64KB
// 分为：
- L1i (指令缓存)
- L1d (数据缓存)

// 示例：访问L1缓存中的数据
int value = someArray[0];  // 如果数据在L1缓存中，访问速度约4-5个时钟周期
```

L2 缓存：

```C++
// 典型大小：256KB-512KB
// 特点：
- 每个核心私有 (L2 缓存通常是核心私有的，但在某些架构中可能被多个核心共享。)
- 统一存储指令和数据
- 访问延迟：约12个时钟周期
```

L3 缓存：

```C++
// 典型大小：数MB到数十MB
// 特点：
- 所有核心共享
- 访问延迟：约40个时钟周期
- 作为主内存和L1/L2的缓冲区
```

我的电脑16核心，L1总大小1MB:
![alt text](../../assets/images/cacheline_image.webp)

也就是，每个核心分配到64KB。
```sh
每个核心的L1缓存分配：
- L1 指令缓存 (L1i): 32KB
- L1 数据缓存 (L1d): 32KB
总计每核心：64KB

16个核心总共：1MB L1缓存
```
每个核心能处理的缓存行数：

$$\text{缓存行数} = \frac{\text{Lid大小}}{\text{缓存行大小}}$$

$$\frac{\text{32KB}}{64} = 512$$

假如全核心不偷懒，能同时处理的缓存行大小：
$$512\times16\text{核} = 2^{9}\times2^{4}= 2^{13} =8192$$


### 缓存行的数据流向

```cpp
struct Data {
    int value;
} data;

// 假设数据最初在主内存中
void processData() {
    // 1. 首次访问，数据从主内存加载到各级缓存
    int val = data.value;  // 缓存行加载过程：
                          // RAM -> L3 -> L2 -> L1
    
    // 2. 修改数据
    data.value = 42;      // 写入过程：
                          // L1 修改 -> L2 更新 -> L3 更新 -> 最终写回RAM
}


// 当缓存满时，需要决定替换哪个缓存行
// 常见的策略有：
- LRU (最近最少使用)
- PLRU (伪LRU)
- Random (随机替换)

// 示例：
for(int i = 0; i < HUGE_NUMBER; i++) {
    process(array[i]);
    // 当新的缓存行加载时
    // 最老的（最少使用的）缓存行会被替换出去
}
```
> [!TIP]
> "L1 修改 -> L2 更新 -> L3 更新 -> 最终写回RAM"
>
> - 现代 CPU 通常采用 **写回（Write-back）** 策略，数据不会立即写回内存，而是在缓存行被替换时写回。
> 
> - 缓存行在缓存中的存储位置由关联性策略决定。常见的组相联策略中，每个内存地址只能映射到特定组的缓存行，若组已满则触发替换。



### 缓存的局部性优化

顺序访问时 CPU 会自动 **预取** 后续缓存行，提升性能。

- 缓存会倾向于局部加载，也称为局部空间性
```cpp
// 好的访问模式
for(int i = 0; i < 100; i++) {
    sum += data[i].a;  // 顺序访问，充分利用缓存行
}

// 不好的访问模式
for(int i = 0; i < 100; i += 16) {
    sum += data[i].a;  // 跳跃访问，浪费缓存行中的数据
}

// 二维数组访问
const int SIZE = 1024;
int matrix[SIZE][SIZE];

// 效率低（跳跃访问）
for(int i = 0; i < SIZE; i++)
    for(int j = 0; j < SIZE; j++)
        sum += matrix[j][i];  // 缓存不友好

// 效率高（连续访问）
for(int i = 0; i < SIZE; i++)
    for(int j = 0; j < SIZE; j++)
        sum += matrix[i][j];  // 缓存友好
```

::: details L1足够大的情况
- 即使L1足够大，全部命中的情况下，顺序访问的效率比跳跃访问的效率更高一点点。

```cpp
// TLB缓存虚拟地址到物理地址的映射
// 即使数据在L1中，也需要地址转换

// 连续访问对TLB友好
for(int i = 0; i < 1000; i++) {
    process(array[i]);  // 可能只需要少量TLB条目
    // - 步长固定为1
    // - 分支预测器容易预测
    // - 流水线利用率高
}

// 跳跃访问可能导致更多TLB缺失
for(int i = 0; i < 1000; i += 16) {
    process(array[i]);  // 可能需要更多TLB条目
    // - 步长较大
    // - 可能影响某些CPU的分支预测
    // - 可能影响指令流水线效率
}
```
:::


### 缓存一致性协议 MESI

由于我们的电脑基本都是多核，而 L1缓存又是每个核心“私有的”,所以对主内存的某块数据进行并行操作时，该数据会进入不同核心的缓存行里。但他们都指向同一个内存块，这就需要缓存一致性协议，来保证数据的一致性。


MESI，既缓存行可能处于以下四种状态之一：

- **M (Modified):** 缓存行被当前核心修改，且数据尚未写回主内存，其他核心的缓存行无效。
- **E (Exclusive):** 当前核心独占此缓存行，数据与主内存一致。
- **S (Shared):** 多个核心共享此缓存行，且数据与主内存一致。
- **I (Invalid):** 当前核心的缓存行无效，需要从其他核心或主内存获取最新数据。

### 伪共享（False Sharing）
- 在多线程环境下，每个核心的某个缓存行很可能指向同一个内存块，就像“多位一体”，分身。为了维持分身的数据一致性，就用到了上面提到的 MESI 协议。一旦其中一个分身的数据被修改，就会通知其他核心“嘿，你的这块缓存行失效了，得用我这份！”， 这就是伪共享（False Sharing）问题，需要重新读取数据，导致性能下降。

解决这个问题也很简单，那就是把数据的大小，对齐到缓存行的大小，**典型的空间换时间**。

**假设一个缓存行大小为 64 字节：**

- **并发下的伪共享例子：**
```cpp
struct FCounter {
    uint32 Count = 0;  // 4字节
};

// 在多线程环境下：
FCounter counters[100];  // 连续存储

// 两个线程同时访问相邻的计数器
Thread1: counters[0].Count++;  // 修改前4字节
Thread2: counters[1].Count++;  // 修改相邻的4字节
```
多核心下，显然这里修改的是“同一个缓存行”,造成伪共享。


- **用内存对齐来解决：**
```cpp
struct alignas(64) FCounter {
    uint32 Count = 0;    // 4字节
   // uint8 padding[60];   //或者手动添加 60字节填充
};  // 总大小64字节

// 现在：
Thread1: counters[0].Count++;  // 在缓存行1
Thread2: counters[1].Count++;  // 在缓存行2
```
::: details Benchmark 例子 
可以测试一下差异：

```cpp
// 测试代码示意
void BenchmarkCounters()
{
    // 不对齐的计数器
    struct SmallCounter { uint32 Count; };
    // 对齐的计数器
    struct alignas(64) AlignedCounter { uint32 Count; };

    // 假设有4个线程同时增加计数
    // 不对齐版本可能需要上百个时钟周期
    // 对齐版本可能只需要几个时钟周期
}
```
:::

::: details 这个FCouter里，感觉太浪费内存怎么办？

可以在避免为共享的情况下，支持更多的Counter了，比如100个counter的例子：

```cpp
class FOptimizedCounterSystem {
    alignas(64) struct CounterBlock {
        uint32 Counts[16];  // 64字节,刚好容纳16个计数器
    };
    
    CounterBlock Blocks[7];  // 16*7 = 112, 支持100多个计数器的存储

public:
    void Increment(uint32 CounterIndex) {
        uint32 BlockIndex = CounterIndex / 16;
        uint32 CountInBlock = CounterIndex % 16;
        
        // 仍然避免了伪共享,因为不同核心会访问不同的缓存行
        Blocks[BlockIndex].Counts[CountInBlock]++;
    }
};

// 原始方式 (对每个计数器都对齐):
sizeof(FCounter) * 100 = 64 * 100 = 6400字节

// 优化方式 (每16个计数器共享一个对齐):
sizeof(FCounterGroup) * 7 = 64 * 7 = 448字节 
```

:::




### 总结
缓存行是“量子化的”

- 缓存行就像物理理论中的“量子”：最小的、不可分割的数据传递单位。
- 并发下，同个物理地址的缓存行是“纠缠的”，修改其中一个其他就会被要求同步。

## UE5里的缓存行

**UE5中，缓存行大小的定义：**
```cpp
#ifdef PLATFORM_MAC_ARM64
#define PLATFORM_CACHE_LINE_SIZE	128
#else
#define PLATFORM_CACHE_LINE_SIZE	64
#endif
```
除了苹果的Arm64是128，其他平台的缓存行大小都是64字节。

**缓存行大小经常用于显式地约束结构体的对齐大小**：
```cpp
//别名
#define T_ALIGN alignas(PLATFORM_CACHE_LINE_SIZE)

//结构体对齐到缓存行，优化多线程访问
struct alignas(PLATFORM_CACHE_LINE_SIZE) FCounter
{
			uint32 Count = 0;
		};
```

防止不知道，也可以手动添加一个成员，如 `uint8 padding[60];` 来手动对齐
