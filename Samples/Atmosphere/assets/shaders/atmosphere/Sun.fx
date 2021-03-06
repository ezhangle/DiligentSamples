#include "AtmosphereShadersCommon.fxh"

cbuffer cbCameraAttribs
{
    CameraAttribs g_CameraAttribs;
}

cbuffer cbLightParams
{
    LightAttribs g_LightAttribs;
}

#define fSunAngularRadius (32.0/2.0 / 60.0 * ((2.0 * PI)/180.0)) // Sun angular DIAMETER is 32 arc minutes
#define fTanSunAngularRadius tan(fSunAngularRadius)

struct SunVSOutput
{
    float2 f2PosPS : PosPS; // Position in projection space [-1,1]x[-1,1]
};

void SunVS(in uint VertexId : SV_VertexID,
           out SunVSOutput VSOut, 
           // IMPORTANT: non-system generated pixel shader input
           // arguments must have the exact same name as vertex shader 
           // outputs and must go in the same order.
           // Moreover, even if the shader is not using the argument,
           // it still must be declared.

           out float4 f4Pos : SV_Position)
{
    float2 fCotanHalfFOV = float2( MATRIX_ELEMENT(g_CameraAttribs.mProj, 0, 0), MATRIX_ELEMENT(g_CameraAttribs.mProj, 1, 1) );
    float2 f2SunScreenPos = g_LightAttribs.f4LightScreenPos.xy;
    float2 f2SunScreenSize = fTanSunAngularRadius * fCotanHalfFOV;
    float4 MinMaxUV = f2SunScreenPos.xyxy + float4(-1.0, -1.0, 1.0, 1.0) * f2SunScreenSize.xyxy;
 
    float2 Verts[4] = 
    {
        MinMaxUV.xy, 
        MinMaxUV.xw,
        MinMaxUV.zy,
        MinMaxUV.zw
    };

    VSOut.f2PosPS = Verts[VertexId];
    f4Pos = float4(Verts[VertexId], 1.0, 1.0);
}

void SunPS(SunVSOutput VSOut,
           out float4 f4Color : SV_Target)
{
    float2 fCotanHalfFOV = float2( MATRIX_ELEMENT(g_CameraAttribs.mProj, 0, 0), MATRIX_ELEMENT(g_CameraAttribs.mProj, 1, 1) );
    float2 f2SunScreenSize = fTanSunAngularRadius * fCotanHalfFOV;
    float2 f2dXY = (VSOut.f2PosPS - g_LightAttribs.f4LightScreenPos.xy) / f2SunScreenSize;
    f4Color.rgb = sqrt(saturate(1.0 - dot(f2dXY, f2dXY))) * F3ONE;
    f4Color.a = 1.0;
}
