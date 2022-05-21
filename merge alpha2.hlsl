//             The Star And Thank Author License (SATA)
//                     Version 2.0, April 2021

// Copyright © <2022> <shugen002>(shader.github@shugen.space)

// Project Url: https://github.com/shugen002/shader/blob/master/merge%20alpha2.hlsl

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// And wait, the most important, you should star/+1/like the project(s) in project url
// section above first, and then thank the author(s) in Copyright section.

// Here are some suggested ways:

//  - Email the authors a thank-you letter, and make friends with him/her/them.
//  - Report bugs or issues.
//  - Tell friends what a wonderful project this is.
//  - And, sure, you can just express thanks in your mind without telling the world.

// Contributors of this project by forking have the option to add his/her name and
// forked project url at copyright and project url sections, but shall not delete
// or modify anything else in these two sections.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

uniform float4x4 ViewProj<
	bool automatic = true;
	string name = "View Projection Matrix";
>;
uniform texture2d InputA<
	bool automatic = true;
>;

sampler_state textureSampler {
	Filter   = Linear;
	AddressU = Clamp;
	AddressV = Clamp;
};

struct VertData {
	float4 pos : POSITION;
	float2 uv : TEXCOORD0;
};

VertData VSDefault(VertData vtx)
{
  vtx.pos = mul(float4(vtx.pos.xyz, 1.0), ViewProj);
	return vtx;
}

float4 PSAlphaFilter(VertData vtx) : TARGET
{
  float2 uv = vtx.uv;
  float3 pixel = InputA.Sample(textureSampler, float2(vtx.uv.x, vtx.uv.y)).rgb;
  float alpha = InputA.Sample(textureSampler, float2(vtx.uv.x + 0.5, vtx.uv.y)).g;
  return float4(clamp(pixel.rgb / alpha, 0.0, 1.0), alpha);
}

technique Draw
{
	pass
	{
		vertex_shader = VSDefault(vtx);
		pixel_shader = PSAlphaFilter(vtx);
	}
}