// adapt from https://www.shadertoy.com/view/XsBfRW FabriceNeyret2's version 
uniform float4 ViewSize<
	bool automatic = true;
>;
uniform float4x4 ViewProj<
	bool automatic = true;
>;

uniform float4 Time<
	bool automatic = true;
>;

uniform float4x4 Random<
	bool automatic = true;
>;

struct VertFragData {
	float4 pos : POSITION;
	float2 uv  : TEXCOORD0;
};

VertFragData VSDefault(VertFragData vtx) {
	vtx.pos = mul(float4(vtx.pos.xyz, 1.0), ViewProj);
	return vtx;
}

float2 vertexMulMatrix(float2 v, float2x2 m) {
  return float2(
    v.x * m[0][0] + v.y * m[0][1],
    v.x * m[1][0] + v.y * m[1][1]
  );
}


float4 PSDefault(VertFragData vtx) : TARGET {
  float2 Resolution = ViewSize.xy;
  float2 U=vertexMulMatrix(( vtx.pos -.5*Resolution )/Resolution.x,float2x2(1,1,-1,1))*.7 * 10.+5.;
  float2 F = frac(U);
  F = min(F,1.-F);
  float s = length( ceil(U) -5.5 );
  float e = 2.* frac( ( Time.x - s*.5 ) / 4.) - 1.;
  float v = frac ( 4.* min(F.x,F.y) );
  float4 output = lerp( float4(1,1,1,1),
             float4(107.0/255.0, 185.0/255.0, 161.0/255.0,1), 
             smoothstep( -.05, 0., .95*(e < 0. ? v : 1.-v) - e*e)
            + s*.1 );
  return output;
}

technique Draw
{
	pass
	{
		vertex_shader = VSDefault(vtx);
		pixel_shader  = PSDefault(vtx); 
	}
}
