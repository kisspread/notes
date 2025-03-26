/*** INPUT CONSTANTS ***/

const uint NumPoints = 256;

/*** INPUT PER-THREAD CONSTANTS ***/

const uint ThreadIndex;
const uint Out_DataIndex;
const uint ElementIndex;

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
bool Out_GetThreadData(uint ThreadIndex, out uint OutDataIndex, out uint OutElementIndex);

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