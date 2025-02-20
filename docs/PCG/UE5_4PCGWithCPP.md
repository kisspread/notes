---
title:  UE5.4 PCG 自定义节点 C++常用类（English）
comments: true
---

## **UPCGData**
- Equivalent to the "UObject" of PCG, most PCG classes are derived from it.

## **FPCGPoint**
- The meta-structure of a PCG point, representing the point information displayed during blueprint debugging, such as Position, Density, Bound, etc.

## **FPCGContext**
- The context during execution (the number of connections can be obtained through it).

## **UPCGSettings**
- Most PCG nodes come with UPCGSettings. Custom nodes also inherit this class, which is a wrapper for the entire node configuration and is used to generate IPCGElement, the nodes we see in the blueprint. Execution is done through IPCGElement::Execute, which calls the `UPCGSettings::ExecuteInternal` method. `ExecuteInternal` is where we write our custom logic.
- Custom variables are written here, so they can be configured in the graph node.
- This class also derives from UPCGData.
- Two important structures are used in Settings:

    ### **FPCGPinProperties**
    - The property class for pins, used to describe the attributes of Input/Output pins of UPCGSettings, such as whether they are advanced, whether they are required (EPCGPinStatus::Required), etc.
    - The data type that the pin accepts is configured using EPCGDataType, with the most common types being Point and Param. Param corresponds to the Attribute Set type in blueprints.
    
    ### **FPCGTaggedData**
    - The data class for pins, used to describe the data of the pins. When executed, it is necessary to obtain the incoming data from FPCGContext. "The number of connections corresponds to the number of FPCGTaggedData."
    - There is a data field `TObjectPtr<const UPCGData> Data`, which can be cast to the desired derived class as needed.
    - To link input data, use `Outputs.Add_GetRef(Input)`:
        ```cpp
        // Step 1: Obtain Outputs from the execution context
        TArray<FPCGTaggedData>& Outputs = Context->OutputData.TaggedData;
        // Step 2: Link Input
        FPCGTaggedData& ChosenTaggedData = Outputs.Add_GetRef(Input);
        // Step 3: Complete configuration
        ChosenTaggedData.Data = ChosenPointsData;
        ChosenTaggedData.Pin = PCGRandomChoiceSettings::ChosenPointsLabel;
        ```

## **UPCGPointData**
- A wrapper class for the Point type, inheriting from UPCGData, and encapsulating FPCGPoint.
- One of the data type options for FPCGTaggedData.
- After creation, it usually needs to be initialized from the Input PointData, as the incoming PointData contains some context that should not be lost:
    ```cpp
    UPCGPointData* ChosenPointsData = NewObject<UPCGPointData>();
    ChosenPointsData->InitializeFromData(PointData);
    TArray<FPCGPoint>& ChosenPoints = ChosenPointsData->GetMutablePoints();
    // Reserve memory space
    ChosenPoints.Reserve(NumberOfElementsToKeep);
    ```

## **UPCGParamData**
- The Attribute Set type in blueprints, and another data type option for FPCGTaggedData.
- Example code for creating an int32 type, resembling a Key-Value structure:
    ```cpp
    // Create Attribute set
    UPCGParamData* ParamData = NewObject<UPCGParamData>();
    // Create an int32 attribute
    FPCGMetadataAttribute<int32>* Attribute = ParamData->Metadata->CreateAttribute<int32>(TEXT("ChosenPointsNum"), NumberOfElementsToKeep, true, true);
    // Assign value
    Attribute->SetValue(ParamData->Metadata->AddEntry(), NumberOfElementsToKeep);
    ```