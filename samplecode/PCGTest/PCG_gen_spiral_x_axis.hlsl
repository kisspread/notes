// 可自定义方向的螺线生成器 - 使用gen points API (无输入)

// 辅助函数
float GetAngle(uint Index, float AngleStep)
{
    // 计算当前角度
    return Index * AngleStep;
}

// 计算任意方向螺线位置
float3 SpiralPositionCustomDirection(uint Index, float Radius, float RadiusGrowthRate, 
                                   float AngleStep, float DistanceStep, 
                                   float3 ForwardDirection, float3 UpDirection)
{
    // 计算当前角度
    float Angle = GetAngle(Index, AngleStep);
    
    // 计算当前半径 (可以随角度增长)
    float CurrentRadius = Radius + RadiusGrowthRate * Angle;
    
    // 计算前进距离 - 随角度线性前进
    float ForwardDistance = DistanceStep * Angle;
    
    // 计算前进方向的标准化向量
    float3 ForwardDir = normalize(ForwardDirection);
    
    // 计算右方向向量 (通过叉积获得垂直于前进和上方向的向量)
    float3 RightDir = normalize(cross(ForwardDir, normalize(UpDirection)));
    
    // 重新计算上方向向量 (确保三个方向相互垂直)
    float3 UpDir = normalize(cross(RightDir, ForwardDir));
    
    // 计算螺线位置
    float3 Position = ForwardDir * ForwardDistance + 
                     RightDir * (CurrentRadius * cos(Angle)) +
                     UpDir * (CurrentRadius * sin(Angle));
    
    return Position;
}

/*** 主程序 - gen points API ***/

// 基础参数设置
const float BaseRadius = 300.0f;          // 基础半径
const float RadiusGrowthRate = 5.0f;      // 半径随角度增长的速率
const float AngleStep = 0.1f;             // 每个点的角度增量
const float DistanceStep = 50.0f;         // 前进方向上的步进距离（每弧度）

// 自定义方向设置 (可以修改为任意方向)
const float3 ForwardDirection = float3(1.0f, 0.0f, 0.0f); // 默认沿X轴前进
const float3 UpDirection = float3(0.0f, 0.0f, 1.0f);      // 默认以Z轴为上方向

// 初始化输出点
Out_InitializePoint(Out_DataIndex, ElementIndex);

// 计算新位置
float3 NewPosition = SpiralPositionCustomDirection(
    ElementIndex, 
    BaseRadius, RadiusGrowthRate,
    AngleStep, DistanceStep,
    ForwardDirection, UpDirection);

// 设置新位置
Out_SetPosition(Out_DataIndex, ElementIndex, NewPosition);

// 设置大小 (可选 - 随角度增长)
float Angle = GetAngle(ElementIndex, AngleStep);
float ScaleFactor = 1.0f + 0.05f * Angle / (2.0f * 3.14159f); // 每转一圈增加5%大小
Out_SetScale(Out_DataIndex, ElementIndex, float3(ScaleFactor, ScaleFactor, ScaleFactor));

// 设置颜色 (可选 - 根据角度循环变化)
float ColorBlend = frac(Angle / (2.0f * 3.14159f * 2.0f)); // 每2π循环一次颜色
float4 Color = float4(ColorBlend, 1.0f - ColorBlend, 0.5f, 1.0f);
Out_SetColor(Out_DataIndex, ElementIndex, Color);
