// Copyright 2022 Shugen002

// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files 
// (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, 
// publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, 
// subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO 
// THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
// CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
// DEALINGS IN THE SOFTWARE.

// Version: 0.2

// Usage: Load this file as shader in shader filter of Xaymar's OBS StreamFX Plugin.
// (https://obsproject.com/forum/resources/streamfx-for-obs%C2%AE-studio.578/)
// Suggest to apply this shader as a scene filter.

// version history:
// 0.1: initial release
// 0.2: fix for premuliply alpha

// Always provided by OBS
uniform float4x4 ViewProj<
	bool automatic = true;
	string name = "View Projection Matrix";
>;

uniform texture2d InputA<
	bool automatic = true;
>;


// ---------- Shader Code
sampler_state def_sampler {
	AddressU  = Clamp;
	AddressV  = Clamp;
	Filter    = Linear;
};

struct VertData {
	float4 pos : POSITION;
	float2 uv  : TEXCOORD0;
};

VertData VSDefault(VertData vtx) {
	vtx.pos = mul(float4(vtx.pos.xyz, 1.0), ViewProj);
	return vtx;
}

float4 PSTemplate(VertData vtx) : TARGET {	
  float2 uv = vtx.uv;
  if(uv.x <= 0.75){
    float4 rgb= InputA.Sample(def_sampler, uv);
		rgb.r /= rgb.a;
    rgb.g /= rgb.a;
    rgb.b /= rgb.a;
    rgb.a = 1.0;
    return rgb;
  }
  else{
    uv.x = uv.x - 0.75;
		float4 rgb1= InputA.Sample(def_sampler, uv);
    uv.x = uv.x + 0.25;
		float4 rgb2= InputA.Sample(def_sampler, uv);
    uv.x = uv.x + 0.25;
    float4 rgb3= InputA.Sample(def_sampler, uv);
    return float4(rgb1.a, rgb2.a, rgb3.a, 1.0);
  }
}

technique Draw
{
	pass
	{
		vertex_shader = VSDefault(vtx);
		pixel_shader  = PSTemplate(vtx); 
	}
}
