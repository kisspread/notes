---
title: UE C++ 里的内存对齐
comments: true
---

# UE C++ 里的内存对齐

## 基础

### struct 和 class 的内存大小
两个决定因素：

- 每个成员变量占据一定的字节数
- 成员变量之间的padding，内存对齐

一个简单的结构体示例：
```cpp
struct Example2 {
    char a;      // 1 byte
    double b;    // 8 bytes
    int c;       // 4 bytes
};
```
它的sizeof 是 24 bytes, alignof 是 8 bytes。

它的内存布局可以看出，它是用最大的成员（double b）来对齐的：

```txt
偏移量: 0    1    2    3    4    5    6    7    8    9    10   11   12   13   14   15   16   17   18   19   20   21   22   23
       +----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+
内容:   | a  |pad |pad |pad |pad |pad |pad |pad | b  | b  | b  | b  | b  | b  | b  | b  | c  | c  | c  | c  |pad |pad |pad |pad |
       +----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+
说明:   |<-- char -->|<------ padding ----->|<---------- double ---------->|<---- int ---->|<---- padding ---->|
       |<-------------------------- 24 bytes total --------------------------->|
```

这造成了非常多无用的padding，导致内存浪费。可以调整成员变量的位置来减少浪费：

```cpp
struct Example2Optimized {
    double b;    // 8 bytes
    int c;       // 4 bytes
    char a;      // 1 byte
    // 只需要 3 字节的填充
};
```

优化后的内存布局：
```txt
偏移量: 0    1    2    3    4    5    6    7    8    9    10   11   12   13   14   15
       +----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+
内容:   | b  | b  | b  | b  | b  | b  | b  | b  | c  | c  | c  | c  | a  |pad |pad |pad |
       +----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+
       |<---------- double ---------->|<---- int ---->|<-char->|<-padding->|
       |<---------------------- 16 bytes total ---------------------->|
```       

它的sizeof 是 16 bytes, alignof 是 8 bytes。大大减少了内存浪费。

尽量将大尺寸类型放在前面可以减少填充字节。

### C++ 11 的 alignas 和 alignof
上面的示例可以看出，alignof 通常返回成员变量中最大的成员的大小。
`alignas` 是一个 C++11引入的关键字，可以用来显式指定 `class` 或 `struct` 的对齐方式。

示例：
```cpp
#include <iostream>
#include <cstddef>

alignas(16) class AlignedExample {
    char c;  // 1字节
    int i;   // 4字节
};

int main() {
    std::cout << "Alignment of AlignedExample: " << alignof(AlignedExample) << std::endl; // 输出 16
    return 0;
}
```

上述代码中，alignas(16) 强制 AlignedExample 的对齐为 16 字节。

还可以：

```cpp
alignas(8) uint8 Data[14];  // Data数组起始地址将按8字节对齐
struct alignas(16) VectorRegister4Double { ... }  // 结构体按16字节对齐 
class alignas(16) FAABBVectorized { ... }  // 类按16字节对齐
```

用于指定变量的内存对齐时：

```
// 假设我们在内存中连续声明以下变量
uint8 normalVar;          // 假设被分配到地址 1001
alignas(8) uint8 alignedData[14];  // 会被分配到第一个能被8整除的地址，比如 1008
uint8 anotherVar;        // 假设被分配到地址 1022
```

图解说明：
```txt
内存地址:  1001 1002 1003 1004 1005 1006 1007 1008 1009 1010 1011 ...  1021 1022
                                            |
                                            +----- alignedData的起始地址
                                                  (确保是8的倍数)

看下每个变量的位置：
1001: normalVar 
1008: alignedData[0]    <-- 注意这里是8的倍数
1009: alignedData[1]
1010: alignedData[2]
...
1021: alignedData[13]
1022: anotherVar
```

## UE 的 Align 模板函数


简单地说，这个函数用于将一个值向上对齐到Alignment的倍数。比如:

- Align(5, 4) = 8
- Align(8, 4) = 8
- Align(9, 4) = 12

这段代码确保ComponentDataPtr按照**缓存行**大小对齐:
```cpp
uint8 Alignment = FMath::Max<uint8>(PLATFORM_CACHE_LINE_SIZE, TypeInfo.Alignment);
ComponentDataPtr = Align(ComponentDataPtr, Alignment);
```

假设 ComponentDataPtr 当前指向地址 1005

Alignment 是 8

那么 Align(1005, 8) 会返回 1008

```txt
// 内存示意图：
// 地址:    1000 1001 1002 1003 1004 1005 1006 1007 1008 1009
//                                    ^                 ^
//                                    |                 |
//                               当前位置          对齐后位置
```

其他对齐：

看不太懂，暂时不理会
```cpp
// PLATFORM_CACHE_LINE_SIZE 通常是 64 或 128 字节（取决于CPU架构）

struct MS_ALIGN(PLATFORM_CACHE_LINE_SIZE) FAlignedDecomposedValue  // MSVC编译器使用
{
    FDecomposedValue Value;
} GCC_ALIGN(PLATFORM_CACHE_LINE_SIZE);    // GCC编译器使用
```