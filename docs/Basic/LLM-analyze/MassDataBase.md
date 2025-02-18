# Editor Data Storage Plugin (TEDS)

## 概述
Editor Data Storage (TEDS) 是一个基于Mass Entity System的编辑器数据存储插件。它提供了一个中心化的、可扩展的数据存储系统，用于编辑器和相关数据的管理，并支持通过一系列widget进行查看和编辑。

## 核心功能

### 1. 数据存储系统
- 基于Mass Entity System构建
- 支持表格化数据存储（Table-based storage）
  - 数据组织方式：
    - 表（Table）：数据的顶层组织单位，通过TableHandle进行引用
    - 行（Row）：表中的一条记录，通过RowHandle进行引用
    - 列（Column）：基于UScriptStruct定义的数据类型，支持动态生成
  - 主要操作：
    - 表操作：RegisterTable、FindTable
    - 行操作：AddRow、BatchAddRow、RemoveRow
    - 列操作：AddColumn、RemoveColumn、GetColumnData
  - 特点：
    - 强类型：每个列都是基于UScriptStruct的强类型数据
    - 灵活性：支持动态添加/删除列
    - 批量操作：支持批量添加行和列，提高性能
    - 观察者模式：支持数据变更通知（Add/Remove事件）

### 2. 查询系统
- 提供高效的数据查询机制
- 支持不同的查询执行阶段（PreUpdate、Update、PostUpdate）
- 可自定义查询组（Query Groups）和执行顺序

### 3. 数据索引
- 支持数据索引化，提高查询效率
- 提供批量索引操作
- 支持动态重索引

### 4. 工厂系统
- 可扩展的工厂系统，支持自定义数据存储工厂
- 工厂排序机制，确保正确的初始化顺序

### 5. UI支持
- 提供专门的TedsUI模块
- 包含可重用的widget组件
- 支持数据的可视化展示和编辑

## 技术特点

1. **Mass Entity Integration**
   - 与Unreal Engine的Mass Entity System深度集成
   - 利用Mass Entity System的高性能特性
   - 支持实体管理和处理阶段

2. **模块化设计**
   - 核心功能模块（TedsCore）
   - UI展示模块（TedsUI）
   - 清晰的模块间依赖关系

3. **扩展性**
   - 支持自定义数据类型
   - 可扩展的查询系统
   - 插件化的架构设计

4. **性能优化**
   - 批量操作支持
   - 高效的数据索引
   - 优化的内存管理

## 应用场景

1. **编辑器工具开发**
   - 为编辑器工具提供统一的数据存储接口
   - 简化编辑器数据管理

2. **数据驱动的编辑器功能**
   - 支持复杂的数据关系管理
   - 提供高效的数据查询和操作

3. **可视化数据编辑**
   - 通过widget系统提供直观的数据编辑界面
   - 支持自定义数据展示方式

## 使用示例

### 1. 基本数据存储操作

```cpp
// 1. 定义数据结构
USTRUCT()
struct FMyCustomData
{
    GENERATED_BODY()
    
    UPROPERTY()
    FString Name;
    
    UPROPERTY()
    int32 Value;
};

// 2. 注册表
TableHandle MyTable = TedsInterface->RegisterTable(
    {
        FMyCustomData::StaticStruct()
    },
    TEXT("MyCustomTable")
);

// 3. 添加数据行
RowHandle Row = TedsInterface->AddRow(MyTable);

// 4. 添加列数据
TedsInterface->AddColumn(Row, FMyCustomData::StaticStruct());

// 5. 获取和修改数据
if (FMyCustomData* Data = static_cast<FMyCustomData*>(TedsInterface->GetColumnData(Row, FMyCustomData::StaticStruct())))
{
    Data->Name = TEXT("Test");
    Data->Value = 42;
}
```

### 2. 批量操作示例

```cpp
// 批量添加行
auto RowInitCallback = [](RowHandle NewRow)
{
    // 初始化新行的数据
};
TedsInterface->BatchAddRow(MyTable, 100, RowInitCallback);

// 批量添加/删除列
TArray<const UScriptStruct*> ColumnsToAdd = { FMyCustomData::StaticStruct() };
TArray<const UScriptStruct*> ColumnsToRemove;
TedsInterface->BatchAddRemoveColumns(Rows, ColumnsToAdd, ColumnsToRemove);
```

### 3. 数据观察示例

```cpp
// 注册观察者，监听数据变更
QueryHandle Handle = TedsInterface->RegisterQuery(
    Select(
        TEXT("MyObserver"),
        FObserver(FObserver::EEvent::Add, FMyCustomData::StaticStruct()),
        [](IQueryContext& Context, RowHandle Row)
        {
            // 处理数据添加事件
        })
    .Compile()
);
```

### 4. 查询示例

```cpp
// 创建并执行查询
QueryHandle QueryHandle = TedsInterface->RegisterQuery(
    Select(TEXT("MyQuery"))
    .Where(FMyCustomData::StaticStruct())
    .Execute([](IQueryContext& Context, RowHandle Row)
    {
        // 处理查询结果
    })
    .Compile()
);

// 运行查询
TedsInterface->RunQuery(QueryHandle);
```

## 最佳实践

1. **性能优化**
   - 使用批量操作代替单个操作
   - 合理使用索引提高查询效率
   - 避免频繁的列操作

2. **数据组织**
   - 根据数据的关联性合理设计表结构
   - 使用合适的列类型
   - 保持列的数据结构简单和清晰

3. **内存管理**
   - 及时清理不需要的行和列
   - 使用适当的数据类型避免内存浪费
   - 合理使用批量操作减少内存碎片

## 注意事项

1. 该插件目前处于实验阶段（Experimental）
2. 需要了解Mass Entity System的基本概念
3. 建议在开发编辑器工具时使用，不适用于运行时数据存储
