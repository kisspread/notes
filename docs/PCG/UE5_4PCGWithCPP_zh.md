---
title: UE5.4 PCG 自定义节点 C++常用类 浅析
comments: true
---

## **UPCGData** 

- 相当于 PGC的“UObject”, 大部分PCG的类都派生于它。

## **FPCGPoint**

- PCG 点的元结构，就是蓝图里调试时显示的点信息，Position, Density, Bound 等待。

## **FPCGContext**

- 执行时的上下文（有多少线连进来可以通过它获取)

## **UPCGSettings** 

- 大部分PCG 节点都是带UPCGSettings的，自定义节点也继承这个类，是对整个节点配置的包装，用于生成IPCGElement就是蓝图里我们看到的节点，外部通过IPCGElement::Execute来执行`UPCGSettings::ExecuteInternal`方法。ExecuteInternal就是我们自定义逻辑的地方。
- 自定义变量写在这里，就可以在graph 节点里配置
- 该类也是派生于UPCGData
- Settings里会用到两个重要的结构体

    ### **FPCGPinProperties**

    - 是Pin的属性类，用于描述UPCGSettings的Input/Output Pin 的属性，比如是否为高级，是否必须设置(EPCGPinStatus::Required) 等
    - 通过EPCGDataType来配置Pin接受的数据类型，最常用的类型是Point 和 Param, Param就是蓝图里的Attribute Set类型
    
    ### **FPCGTaggedData**

    - Pin的数据类，用于描述Pin的数据。被执行时，需要从FPCGContext获得连接进来的数据。“有多少线连进来，就有多少FPCGTaggedData”
    - 有个数据字段`TObjectPtr<const UPCGData> Data`，可以根据自己的需要，cast 成自己要的派生类
    - 使用 `Outputs.Add_GetRef(Input)` 来添加输出
  
        ``` cpp
        //step1 从执行的上下文里获得Outputs
        TArray<FPCGTaggedData>& Outputs = Context->OutputData.TaggedData;
        //step2 以Input 为模板，创建并添加到Outputs
        FPCGTaggedData& ChosenTaggedData = Outputs.Add_GetRef(Input);
        //step3 完成配置
        ChosenTaggedData.Data = ChosenPointsData;
        ChosenTaggedData.Pin = PCGRandomChoiceSettings::ChosenPointsLabel;
        ```

## **UPCGPointData**

- Point类型的包装类，继承于UPCGData，包装了FPCGPoint
- FPCGTaggedData 的Data 类型选项之一
- 创建后通常要用Input PointData 来InitializeFromData它,因为 进来的PointData包含了一些上下文不能丢失
    ```cpp
    UPCGPointData* ChosenPointsData = NewObject<UPCGPointData>();
    ChosenPointsData->InitializeFromData(PointData);
    TArray<FPCGPoint>& ChosenPoints = ChosenPointsData->GetMutablePoints();
    //分配内存空间大小
    ChosenPoints.Reserve(NumberOfElementsToKeep);
    ```
## **UPCGParamData**
  - 是蓝图里的Attribute Set类型, 参数 类型
  - 创建一个int32 类型 代码示例，形式有点像Key-Value
  
    ``` cpp
        // Create Attribute set
        UPCGParamData* ParamData = NewObject<UPCGParamData>();
        //通过CreateAttribute创建 int32, 
        FPCGMetadataAttribute<int32>* Attribute = ParamData->Metadata->CreateAttribute<int32>(TEXT("ChosenPointsNum"), NumberOfElementsToKeep, true, true);
        //赋值
        Attribute->SetValue(ParamData->Metadata->AddEntry(), NumberOfElementsToKeep);
    ```

    
    
    





