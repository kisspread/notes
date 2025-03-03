---
title: PCG HLSL GPU 并行
comments:  true
---

# PCG HLSL GPU 并行

开坑中

```hlsl
/*** INPUT PER-THREAD CONSTANTS ***/

const uint ThreadIndex;
const uint In_DataIndex;
const uint Out_DataIndex;
const uint ElementIndex;

/*** INPUT DATA FUNCTIONS ***/

// Valid pins: In, InA
uint <pin>_GetNumData();
uint <pin>_GetNumElements();
uint <pin>_GetNumElements(uint DataIndex);

// Valid types: bool, int, float, float2, float3, float4, Rotator (float3), Quat (float4), Transform (float4x4), StringKey (int), Name (uint2)

<type> <pin>_Get<type>(uint DataIndex, uint ElementIndex, int AttributeId);
<type> <pin>_Get<type>(uint DataIndex, uint ElementIndex, 'AttributeName');

/*** INPUT POINT DATA FUNCTIONS ***/

// Valid pins: In, InA

float3 <pin>_GetPosition(uint DataIndex, uint ElementIndex);
float4 <pin>_GetRotation(uint DataIndex, uint ElementIndex);
float3 <pin>_GetScale(uint DataIndex, uint ElementIndex);
float3 <pin>_GetBoundsMin(uint DataIndex, uint ElementIndex);
float3 <pin>_GetBoundsMax(uint DataIndex, uint ElementIndex);
float4 <pin>_GetColor(uint DataIndex, uint ElementIndex);
float <pin>_GetDensity(uint DataIndex, uint ElementIndex);
int <pin>_GetSeed(uint DataIndex, uint ElementIndex);
float <pin>_GetSteepness(uint DataIndex, uint ElementIndex);
float4x4 <pin>_GetPointTransform(uint DataIndex, uint ElementIndex);
bool <pin>_IsPointRemoved(uint DataIndex, uint ElementIndex);

/*** INPUT TEXTURE DATA FUNCTIONS ***/

float2 InTex_GetTexCoords(float2 WorldPos, float2 Min, float2 Max);
float4 InTex_Sample(float2 TexCoords);

/*** OUTPUT DATA FUNCTIONS ***/

// Valid types: bool, int, float, float2, float3, float4, Rotator (float3), Quat (float4), Transform (float4x4), StringKey (int), Name (uint2)

void Out_Set<type>(uint DataIndex, uint ElementIndex, int AttributeId, <type> Value);
void Out_Set<type>(uint DataIndex, uint ElementIndex, 'AttributeName', <type> Value);

/*** OUTPUT POINT DATA FUNCTIONS ***/

void Out_InitializePoint(uint DataIndex, uint ElementIndex);
void Out_CopyElementFrom_<input pin>(uint TargetDataIndex, uint TargetElementIndex, uint SourceDataIndex, uint SourceElementIndex);
bool Out_RemovePoint(uint DataIndex, uint ElementIndex);

void Out_SetPosition(uint DataIndex, uint ElementIndex, float3 Position);
void Out_SetRotation(uint DataIndex, uint ElementIndex, float4 Rotation);
void Out_SetScale(uint DataIndex, uint ElementIndex, float3 Scale);
void Out_SetBoundsMin(uint DataIndex, uint ElementIndex, float3 BoundsMin);
void Out_SetBoundsMax(uint DataIndex, uint ElementIndex, float3 BoundsMax);
void Out_SetColor(uint DataIndex, uint ElementIndex, float4 Color);
void Out_SetDensity(uint DataIndex, uint ElementIndex, float Density);
void Out_SetSeed(uint DataIndex, uint ElementIndex, int Seed);
void Out_SetSteepness(uint DataIndex, uint ElementIndex, float Steepness);
void Out_SetPointTransform(uint DataIndex, uint ElementIndex, float4x4 Transform);

/*** HELPER FUNCTIONS ***/

int3 GetNumThreads();
uint GetThreadCountMultiplier();

// Returns false if thread has no data to operate on.
// Valid pins: In, InA, InTex, Out
bool <pin>_GetThreadData(uint ThreadIndex, out uint OutDataIndex, out uint OutElementIndex);

float3 GetComponentBoundsMin(); // World-space
float3 GetComponentBoundsMax();
uint GetSeed();

float FRand(inout uint Seed); // Returns random float between 0 and 1.
uint ComputeSeed(uint A, uint B);
uint ComputeSeed(uint A, uint B, uint C);
uint ComputeSeedFromPosition(float3 Position);

// Returns the position of the Nth point in a 2D or 3D grid with the given constraints.
float3 CreateGrid2D(int ElementIndex, int NumPoints, float3 Min, float3 Max);
float3 CreateGrid2D(int ElementIndex, int NumPoints, int NumRows, float3 Min, float3 Max);
float3 CreateGrid3D(int ElementIndex, int NumPoints, float3 Min, float3 Max);
float3 CreateGrid3D(int ElementIndex, int NumPoints, int NumRows, int NumCols, float3 Min, float3 Max);
```
