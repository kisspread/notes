// 函数定义在上面

float GetTurnNumber(uint Index, float PointsPerTurn)
{
    // 计算当前点在第几圈
    return Index / PointsPerTurn;
}

float GetAngleInTurn(uint Index, float PointsPerTurn)
{
    // 计算当前点在当前圈的角度位置 (0-1范围内)
    return (Index % (uint)PointsPerTurn) / PointsPerTurn;
}

float3 SpiralPosition(uint Index, float BaseRadius, float RadiusGrowthPerTurn, 
                      float PointsPerTurn, float ObjectSizeGrowthFactor,
                      float HeightPerTurn, float StartHeight,
                      float BaseObjectSize)
{
    // 计算当前点在第几圈
    float TurnNumber = GetTurnNumber(Index, PointsPerTurn);
    
    // 计算当前点在当前圈的角度位置 (0-1范围内)
    float AngleInTurn = GetAngleInTurn(Index, PointsPerTurn);
    
    // 计算当前角度 (0-2π)
    float Angle = (TurnNumber + AngleInTurn) * 2.0f * 3.14159f;
    
    // 计算当前物体大小
    float CurrentObjectSize = BaseObjectSize * (1.0f + ObjectSizeGrowthFactor * TurnNumber);
    
    // 计算当前半径 (基础半径 + 每圈增加的半径 * 圈数)
    // 增加额外的间距以避免重叠 (当前物体大小)
    float Radius = BaseRadius + (RadiusGrowthPerTurn + CurrentObjectSize) * TurnNumber;
    
    // 计算高度
    float Height = StartHeight + TurnNumber * HeightPerTurn;
    
    // 计算最终位置
    float3 Position;
    Position.x = Radius * cos(Angle);
    Position.y = Radius * sin(Angle);
    Position.z = Height;
    
    return Position;
}


// 这里写main函数
float BaseRadius = 300.0f;           // 起始半径 (第一圈的半径)
float RadiusGrowthPerTurn = 50.0f;   // 每圈增加的半径
float PointsPerTurn = 20.0f;         // 每圈的点数
float BaseObjectSize = 500.0f;       // 基础物体大小 (长宽)
float ObjectSizeGrowthFactor = 1.2f; // 物体大小增长因子 (每圈增加20%)
float HeightPerTurn = 50.0f;          // 每圈高度增长 (设为0则为平面螺旋)
float StartHeight = 0.0f;            // 起始高度

// 初始化输出点
Out_InitializePoint(Out_DataIndex, ElementIndex);

// 复制输入点的所有属性到输出点
Out_CopyElementFrom_In(Out_DataIndex, ElementIndex, In_DataIndex, ElementIndex);

// 计算新位置
float3 NewPosition = SpiralPosition(ElementIndex, 
                                    BaseRadius, RadiusGrowthPerTurn,
                                    PointsPerTurn, ObjectSizeGrowthFactor,
                                    HeightPerTurn, StartHeight,
                                    BaseObjectSize);

// 设置新位置
Out_SetPosition(Out_DataIndex, ElementIndex, NewPosition);

// 可选：根据圈数设置点的缩放比例
//float TurnNumber = GetTurnNumber(ElementIndex, PointsPerTurn);
//float ScaleFactor = 1.0f + ObjectSizeGrowthFactor * TurnNumber;
//Out_SetScale(Out_DataIndex, ElementIndex, float3(ScaleFactor, ScaleFactor, ScaleFactor));