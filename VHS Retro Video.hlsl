//------------------------------------------------------------------------------
// Defines
//------------------------------------------------------------------------------
// Variations of PI/TAU
#define PI   3.141592653
#define TAU  6.283185307
#define PIm2 6.283185307
#define PIb2 1.570796326
#define PIb4 0.785398163

// Phi/Φ = Golden Ratio
#define PHI 1.61803398874989484820459

// e (Eulers Constant)
#define EULERS_CONSTANT 2,7182818284590452353602874713527

// Degrees <-> Radians Conversion
#define TO_RAD(x) (x *  0.017453292)
#define TO_DEG(x) (x * 57.295779513)

//------------------------------------------------------------------------------
// Uniforms
//------------------------------------------------------------------------------
uniform float4x4 ViewProj<
	bool automatic = true;
>;

uniform float4 Time<
	bool automatic = true;
>;


// Filter Support
#ifdef IS_FILTER
uniform texture2d InputA<
	bool automatic = true;
>;
#endif

// Transition Support
#ifdef IS_TRANSITION
uniform texture2d InputA<
	bool automatic = true;
>;

uniform texture2d InputB<
	bool automatic = true;
>;

uniform float TransitionTime<
	bool automatic = true;
>;
#endif

uniform int RandomSeed<
	bool automatic = true;
>;

uniform float4x4 Random<
	bool automatic = true;
>;

//------------------------------------------------------------------------------
// Structures
//------------------------------------------------------------------------------
struct VertexInformation {
	float4 position : POSITION;
	float4 texcoord0 : TEXCOORD0;
};

//------------------------------------------------------------------------------
// Samplers
//------------------------------------------------------------------------------
sampler_state PointRepeatSampler {
	Filter    = Point;
	AddressU  = Repeat;
	AddressV  = Repeat;
};
sampler_state LinearRepeatSampler {
	Filter    = Linear;
	AddressU  = Repeat;
	AddressV  = Repeat;
};

sampler_state PointClampSampler {
	Filter    = Point;
	AddressU  = Clamp;
	AddressV  = Clamp;
};
sampler_state LinearClampSampler {
	Filter    = Linear;
	AddressU  = Clamp;
	AddressV  = Clamp;
};

//------------------------------------------------------------------------------
// Functions
//------------------------------------------------------------------------------
VertexInformation DefaultVertexShader(VertexInformation vtx) {
	vtx.position = mul(float4(vtx.position.xyz, 1.0), ViewProj);
	return vtx;
};

bool is_float_equal(float a, float b) {
	return (abs(a - b) <= .00001);
}

// Always provided by OBS
uniform float4x4 ViewProj<
	bool automatic = true;
>;

// Provided by Stream Effects

uniform float4 ViewSize<
	bool automatic = true;
>;
uniform texture2d InputA<
	bool automatic = true;
>;


// ---------- Shader Code


struct VertFragData {
	float4 pos : POSITION;
	float2 uv  : TEXCOORD0;
};

sampler_state MeshTextureSampler
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Wrap;
    AddressV = Wrap;
};

VertFragData VSDefault(VertFragData vtx) {
	vtx.pos = mul(float4(vtx.pos.xyz, 1.0), ViewProj);
	return vtx;
}

float4 PSDefault(VertFragData vtx) : TARGET {
	float xyratio = ViewSize.x / ViewSize.y;
	vtx.uv *= float2(ViewSize.x/2., ViewSize.y/2.);
	vtx.uv = floor(vtx.uv);
	vtx.uv /= float2(ViewSize.x/2., ViewSize.y/2.);
	vtx.uv.x -= (step(frac(Time.x * .4), vtx.uv.y) * .005);
	float4 colorR = InputA.Sample(MeshTextureSampler, vtx.uv);
	float4 colorG = InputA.Sample(MeshTextureSampler, vtx.uv + float2(0., 0.005));
	float4 colorB = InputA.Sample(MeshTextureSampler, vtx.uv - float2(0.005/xyratio, 0.));
	colorR.r = 1. - cos(.5 * PI * colorR.r);
	colorG.g = 1. - cos(.5 * PI * colorG.g);
	colorB.b = 1. - cos(.5 * PI * colorB.b);
	return float4(colorR.r, colorG.g, colorB.b, 1.);
}

technique Draw
{
	pass
	{
		vertex_shader = VSDefault(vtx);
		pixel_shader  = PSDefault(vtx); 
	}
}
