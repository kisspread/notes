// Define a struct to encapsulate all our functions, keeping the code organized.
// (定义一个结构体来封装我们所有的函数，保持代码整洁。)
struct _fnc {
  float hash(float3 p) {
	float3 p3  = frac(p * .1031);
    p3 += dot(p3, p3.zyx + 31.32);
    return frac((p3.x + p3.y) * p3.z);
  }

  float noise( in float3 x ) {
    float3 i = floor(x);
    float3 f = frac(x);
    f = f*f*(3.0-2.0*f);
	
    return lerp(lerp(lerp( hash(i+float3(0,0,0)), 
                        hash(i+float3(1,0,0)),f.x),
                   lerp( hash(i+float3(0,1,0)), 
                        hash(i+float3(1,1,0)),f.x),f.y),
               lerp(lerp( hash(i+float3(0,0,1)), 
                        hash(i+float3(1,0,1)),f.x),
                   lerp( hash(i+float3(0,1,1)), 
                        hash(i+float3(1,1,1)),f.x),f.y),f.z);
  }

  float mNoise( in float3 pos ) {
    float3 q = pos;
    const float3x3 m = float3x3( 0.20,  0.80,  0.60,
                    -0.80,  0.36, -0.48,
                    -0.60, -0.48,  0.64 );
                    
    float amplitude = .65;
    float f  = amplitude*noise( q );
    q = mul(m, q*2.11);
    float scale = 2.02;
    for (int i = 0; i < 3; ++i)
    {    
    	f += amplitude * noise( q );
        q = mul(m, q*scale);
        amplitude *= 0.5;
        
    }
    return f;
  }

  float2 polarMap(float2 uv, float shift, float inner) {
    float px = 1.0 - frac(atan2(uv.y, uv.x) / 6.28 + 0.25) + shift;
    float py = (sqrt(uv.x * uv.x + uv.y * uv.y) * (1.0 + inner * 2.0) - inner) * 2.0;
    return float2(px, py);
  }

  float3 firePalette(float i) {
    float T = 1400. + 1400.*i; // Temperature range (in Kelvin).
    float3 L = float3(7.4, 5.6, 4.4); // Red, green, blue wavelengths (in hundreds of nanometers).
    L = pow(L,float3(5.0,5.0,5.0)) * (exp(1.43876719683e5/(T*L))-1.0);
    return 1.0-exp(-5e8/L); // Exposure level.
  }

  // The main function now accepts time and other parameters from the material graph.
  // (主函数现在从材质图表中接收时间和其他参数。)
  float4 mainImage( float2 fragCoord, float nonpolar, float iTime, float shift, float inner, float hrepeat ) {
    float2 p = fragCoord.xy;
    float2 uv = p;
    uv.x = abs(uv.x); // mirror
    
    uv = polarMap(uv*1.4,shift,inner);
    uv.x *= hrepeat;

    if (nonpolar == 1.)
      uv = float2(p.x*4.0,p.y+0.9); // use nonpolar uv
    
    float t = iTime * 0.2;
    float fval = uv.y;
    uv = float2(uv.x, uv.y - t) * 2.55;
    fval = fval + 0.67 + (mNoise(float3(uv, t*1.1)) * 0.33);
    float3 color = firePalette(2.4-fval);
    return float4(color.xyz,1.0);
  }
} fnc;

// Call the main function, passing all the necessary inputs from the material graph.
// (调用主函数，并传入所有来自材质图表的必要输入。)
return fnc.mainImage(_uv, npolar, iTime, shift, inner, hrepeat);
