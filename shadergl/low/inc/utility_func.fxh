//========= Copyright  1998-2007, EGOSOFT, All rights reserved. ============
//
// Property of EGOSOFT, dont use or redistribute without premission.
//===========================================================================

#ifndef _EGO_UTIL
#define _EGO_UTIL
///	COMMON STUFF	///
#define PI 3.141592654
#define EUL 2.718281828f
#define LUM_ITU601 half3(0.299, 0.587, 0.114)
#define LUM_ITU709 half3(0.2126, 0.7152, 0.0722)
// This is the linear middle grey NOT the sRGB (0.21) or gamma 2.4 (0.18)
#define HDR_DATA_NORMALIZE_SCALE 20.0
// pow(0.0, 2.2) is buggy via preshader it gets converted to log(x).., so we need to add a small value to make it work correctly.
//#define HALF3_SMALL_NUMBER half3(0.001, 0.001, 0.001)	
#define HALF3_SMALL_NUMBER half3(0.00001, 0.00001, 0.00001)	

#define SHADOWMAP_SIZE 4096.0f

///////////////////////////////////////////////////////////////////////////////////////////////////
////								Functions													///
///////////////////////////////////////////////////////////////////////////////////////////////////

// For now we simply normalize by a scale to get the float blending (screen) working, since values > 1.0 will result in undefined behaviour.
half3 EncodeToTextureHDR(const half3 inColorHDR)
{
	return inColorHDR / HDR_DATA_NORMALIZE_SCALE;
}

half3 DecodeTextureHDR(const half3 inColorHDR)
{
	return inColorHDR * HDR_DATA_NORMALIZE_SCALE;
}

half4 EncodeToTextureHDR(const half4 inColorHDR)
{
	return inColorHDR / HDR_DATA_NORMALIZE_SCALE;
}

half4 DecodeTextureHDR(const half4 inColorHDR)
{
	return inColorHDR * HDR_DATA_NORMALIZE_SCALE;
}

// simple sRGB color conversion with 2.2f NOTE: preserve alpha
half3 TO_sRGB(const half3 inColor)
{
	return half3(pow(inColor.rgb + HALF3_SMALL_NUMBER, 1.0/2.2));
}

half4 TO_sRGB(const half4 inColor)
{
	return half4(pow(inColor.rgb + HALF3_SMALL_NUMBER, 1.0/2.2), inColor.a);
}

half TO_linearRGB(const half inColor)
{
	return half3(pow(inColor.x + HALF3_SMALL_NUMBER, 2.2));
}

half3 TO_linearRGB(const half3 inColor)
{
	return half3(pow(inColor.rgb + HALF3_SMALL_NUMBER, 2.2));
}

half4 TO_linearRGB(const half4 inColor)
{
	return half4(pow(inColor.rgb + HALF3_SMALL_NUMBER, 2.2), inColor.a);
}

// Max multiplier aware functions
half3 TO_linearRGB_HDR(const half4 inColor)
{
	//return half3(pow(inColor.rgb + HALF3_SMALL_NUMBER, 2.2) * inColor.a);
	return half3(pow(inColor.rgb + HALF3_SMALL_NUMBER, 2.2));
}

// Max multiplier aware functions
half3 D3DCOLOR_X_TO_linearRGB_HDR(const half4 inColor)
{
	//return half3(pow(inColor.rgb + HALF3_SMALL_NUMBER, 2.2) * inColor.a * LIGHTINTENSITY_SCALE);
	return half3(pow(inColor.rgb + HALF3_SMALL_NUMBER, 2.2) );
}

half3 TO_Hdr(const half4 inColor)
{
	//return (inColor.rgb * inColor.a);
	return (inColor.rgb);
}

// unnormalized PixelToLight Vector, just simple linear att atm
half calc_PointLightAtt(const float3 PixelToLight, const float4 LightAtt_Range)
{
   	float lightDist = length(PixelToLight);
	//const half3 attFactors = half3(1.0f, lightDist, lightDist*lightDist);
	//distanceAtt = 1.0f / dot(LightAtt_Range.xyz, attFactors.xyz);
	half distanceAtt = smoothstep(LightAtt_Range.a, 0.0f, lightDist);

	return distanceAtt;	
}

float fresnel(const float3 V, const float3 N, const half Power, const half Str, const half minRange)
{
    float fresnel = pow(1-abs(dot(V, N)), Power) * Str;    // note: abs() makes 2-sided materials work
    float result = minRange + (1-minRange) * fresnel;
    return result;
}

float fresnel(const float3 V, const float3 N, const half Power)
{
    return (pow(1-abs(dot(V, N)), Power));    // note: abs() makes 2-sided materials work
}

inline float fresnel_a(float x)
{
	return ((( 1.0f/(pow(abs(x-1.12f),2))) - (1.0f/pow(1.12f,2))) / 68.652f);// (( 1/pow(1.0f-1.12f,2)) - (1/pow(1.12f,2)));
}
inline float shadow(float x)
{
	return ((10000.0f - (1.0f/(pow(abs(x-1.01f),2)))) / 9999.2f);//(( 1/pow(1.0f-1.01f,2)) - (1/pow(1.01f,2)));
}

float3 wrap_RGB(const float NdL, const half3 wrapRGB )
{
    half3 result;
    result.x = max( 0, ( NdL + wrapRGB.x ) / ( 1 + wrapRGB.x ) );
    result.y = max( 0, ( NdL + wrapRGB.y ) / ( 1 + wrapRGB.y ) );
    result.z = max( 0, ( NdL + wrapRGB.z ) / ( 1 + wrapRGB.z ) );
    return result;
}

//rescaled lambert
inline float lambert_half(const float NdL, const half LambertPower)
{
	return (pow( (NdL * 0.5) + 0.5, LambertPower));
}

// wrap around lambert using the 8th power
inline half lambert_half_power_8(const half NdL)
{
	half res = NdL * 0.5 + 0.5;
	res *= res;
	res *= res;
	res *= res;
	return res;
}

//lambert rolloff
float lambert_rolloff(const float NdL, const half rolloff)
{
	float subLamb = smoothstep(-rolloff,1.0,NdL) - smoothstep(0.0,1.0,NdL);
    return (max(0.0, subLamb));
}

// The actual specular lighting model the Blinn shader node in Maya computes
//  (based on cook-torrance)
// Careful with the direction of V and L.  
float MayaBlinnSpecular( float3 L, float3 V, float3 N, half eccentricity, half rollOff )
{
    float result = 0;
    
    float cosne = dot( -V, N );
	float cosln = dot( -L, N );
    
	if( cosln > 0.0f )
	{
		float3 H = normalize( -L + -V );
		
		float3 h = -L + -V; // un normalized half-way vector

		float coseh = dot( H, -V );
		float cosnh = dot( H, N );
		
		float computedEcc = eccentricity * eccentricity - 1.0;
		float m = eccentricity;
		
		float alpha = acos( cosnh );
		float ta = tan( alpha );
		
		float pH = 1.0 / ( m * m * pow( cosnh, 4.0 ) ) * exp( -( ta * ta ) / ( m * m ) );		
		
		float Dd = ( computedEcc + 1.0f ) / ( 1.0 + computedEcc * cosnh * cosnh );
		Dd = Dd * Dd;
		cosnh = 2 * cosnh;

		float Gg;
		if ( cosne < cosln ) 
			Gg = ( cosne*cosnh < coseh ) ? cosnh / coseh : 1.0f / cosne;
		else 
			Gg = ( cosln*cosnh < coseh ) ? cosln * cosnh / ( coseh * cosne ) : 1.0f / cosne;
				
		// Fresnel calculation.
		coseh = 1.0f - coseh;
		coseh = pow( coseh, 5.0 );
		float Ff = coseh + ( 1.0f - coseh ) * rollOff;

		// Make sure that the specularCoefficient doesn't become negative.
		float specularCoefficient = saturate( cosln ) * max( pH * Ff / dot( h, h ), 0 );
		//float specularCoefficient = max( Gg * Ff * Dd, 0 );
		result = specularCoefficient;
	}
    
    return result;
}

half luminance(const half3 c)
{
	return dot( c, LUM_ITU601 );
}

half luminanceHDTV(const half3 c)
{
	return dot( c, LUM_ITU709 );
}

float4x4 scaleMat(const float s)
{
	return float4x4(
		s, 0, 0, 0,
		0, s, 0, 0,
		0, 0, s, 0,
		0, 0, 0, 1);
}

float4x4 translateMat(const float3 t)
{
	return float4x4(
		1, 0, 0, 0,
		0, 1, 0, 0,
		0, 0, 1, 0,
		t, 1);
}

float4x4 saturationMat(const float s)
{ 
    const float rwgt = 0.3086;
    const float gwgt = 0.6094;
    const float bwgt = 0.0820;

	return float4x4(
		(1.0-s)*rwgt + s,	(1.0-s)*rwgt,  		(1.0-s)*rwgt,		0,
		(1.0-s)*gwgt, 		(1.0-s)*gwgt + s, 	(1.0-s)*gwgt,		0,
		(1.0-s)*bwgt,    	(1.0-s)*bwgt, 		(1.0-s)*bwgt + s,	0,
		0.0, 0.0, 0.0, 1.0);
}

float4x4 rotateMat(float3 d, const float ang)
{
	float s = sin(ang);
	float c = cos(ang);
	d = normalize(d);
	return float4x4(
		d.x*d.x*(1 - c) + c,		d.x*d.y*(1 - c) - d.z*s,	d.x*d.z*(1 - c) + d.y*s,	0,
		d.x*d.y*(1 - c) + d.z*s,	d.y*d.y*(1 - c) + c,		d.y*d.z*(1 - c) - d.x*s,	0, 
		d.x*d.z*(1 - c) - d.y*s,	d.y*d.z*(1 - c) + d.x*s,	d.z*d.z*(1 - c) + c,		0, 
		0, 0, 0, 1 );
}

//Angle in radians !
//build the first row of the HUE matrix
//d = (1,1,1)
float3 calcHueShiftVec(const float ang)
{
	float s = sin(ang);
	float c = cos(ang);
	float A = 0.333*(1 - c) - 0.57735*s;
	float B = 0.333*(1 - c) + 0.57735*s;
	float C = 0.333*(1 - c) + c;
	
	return float3(C, A, B);
}

//takes the precalced hue vector in form of first matrix row (1,A,B) (A,B are the cos/sin rotations)
//the second and third row are builded dynamicly using swizzles (those should be very fast op's)
//matrix:
//			1 A B
//			B 1 A
//			A B 1
float3 HueShift(const float3 RGB, const float3 vHue )
{
	//maybe remove the "1" ? will this be slower cause of the register copy?
	return float3(dot(RGB, vHue), dot(RGB, vHue.zxy), dot(RGB, vHue.yzx));
}

//version which takes the angle as input (in radians)
//d = (1,1,1)
float3 HueShift(const float3 RGB, const float ang )
{
	float s = sin(radians(ang));
	float c = cos(radians(ang));
	float A = 0.333*(1 - c) - 0.57735*s;
	float B = 0.333*(1 - c) + 0.57735*s;
	float C = 0.333*(1 - c) + c;
	
	float3 vHue = float3(C, A, B);
	//maybe remove the "1" ? will this be slower cause of the register copy?
	return float3(dot(RGB, vHue), dot(RGB, vHue.zxy), dot(RGB, vHue.yzx));
}


inline float4x3 make_ColorMatrix(const float inBrightness,const float inContrast,const float inSaturation,const float inHue)
{
    // construct color matrix
     
    // brightness - scale around (0.0, 0.0, 0.0)
    float4x4 brightnessMatrix = scaleMat(inBrightness);
	
    // contrast - scale around (0.5, 0.5, 0.5)
    float4x4 contrastMatrix = translateMat(-0.5);
    contrastMatrix = mul(contrastMatrix, scaleMat(inContrast) );
    contrastMatrix = mul(contrastMatrix, translateMat(0.5) );
	
    // saturation
    float4x4 saturationMatrix = saturationMat(inSaturation);

    // hue - rotate around (1, 1, 1)
    float4x4 hueMatrix = rotateMat(float3(1, 1, 1), radians(inHue));

	// composite together matrices
	float4x4 m;
	m = brightnessMatrix;
	m = mul(m, contrastMatrix);
	m = mul(m, saturationMatrix);
	m = mul(m, hueMatrix);


	return m;
}

inline float4x4 make_bias_mat(float BiasVal)
{
	float fTexWidth = 2048;
	float fTexHeight = 2048;
	float fZScale = 1.0; //dx9
	float fOffsetX = 0.5f + (0.5f / fTexWidth);
	float fOffsetY = 0.5f + (0.5f / fTexHeight);
	float4x4 result = float4x4(0.5f,     0.0f,     0.0f,      0.0f,
					0.0f,    -0.5f,     0.0f,      0.0f,
					0.0f,     0.0f,     fZScale,   0.0f,
					fOffsetX, fOffsetY, -BiasVal,     1.0f );
	return result;
}


float fresnelVec_2(float in_abs_VdotN, half inKrMin, half inKrMax, half inFresnelExpon)
{
    float fresnel = inKrMin + (inKrMax - inKrMin) * pow(in_abs_VdotN, inFresnelExpon);
    
    return fresnel;
}

float fresnelVec(float3 inVertexToEye, float3 inNormal, half inKrMin, half inKrMax, half inFresnelExpon)
{
    float VdotN = 1-abs(dot(inVertexToEye, inNormal));
    float fresnel = inKrMin + (inKrMax - inKrMin) * pow(VdotN, inFresnelExpon);
    
    return fresnel;
}

float fresnel2(float3 eyeVec, float3 normal, half R0)
{
    float kOneMinusEdotN  = 1-abs(dot(eyeVec, normal));    // note: abs() makes 2-sided materials work

    // raise to 5th power
    float result = kOneMinusEdotN * kOneMinusEdotN;
    result = result * result;
    result = result * kOneMinusEdotN;
    result = R0 + (1-R0) * result;

    return 1-result;
}

float fresnel3(float3 eyeVec, float3 normal, half R0)
{
    float kOneMinusEdotN  = 1-abs(dot(eyeVec, normal));    // note: abs() makes 2-sided materials work

    // raise to 5th power
    float result = kOneMinusEdotN * kOneMinusEdotN;
    result = result * result;
    result = result * kOneMinusEdotN;
    result = R0 + (1-R0) * result;

    return 1-result;
}

half highlights(const half3 inColor, const half HighlightThreshold, const half MaxLuminance)
{
	const half pixel_lumi = luminance(inColor.rgb);
	half normalized_clamped_lumi = smoothstep(HighlightThreshold, MaxLuminance, pixel_lumi);
	return normalized_clamped_lumi;
	//return lerp(0, lumi_clamped, pow(lumi_clamped, 5));
	//return lerp(0, 1, lumi_clamped); //little lumi boost
}

float3 UNSIGNED(const float3 V)
{
	return (V.xyz * 0.5) + 0.5;
}

float3 SIGNED(const float3 V)
{
	return (V.xyz * 2.0) - 1.0;
}

float4 UNSIGNED(const float4 V)
{
	return (V.xyzw * 0.5) + 0.5;
}

float4 SIGNED(const float4 V)
{
	return (V.xyzw * 2.0) - 1.0;
}

float2 UNSIGNED(const float2 V)
{
	return (V.xy * 0.5) + 0.5;
}

float2 SIGNED(const float2 V)
{
	return (V.xy * 2.0) - 1.0;
}

float2 MAKESIGNED(const float2 V)
{
	return (V.xy * 2.0) - 1.0;
}

float UNSIGNED(const float V)
{
	return (V * 0.5) + 0.5;
}

float SIGNED(const float V)
{
	return (V * 2.0) - 1.0;
}

// half overload versions

half3 UNSIGNED_pp(const half3 V)
{
	return (V.xyz * 0.5) + 0.5;
}

half3 SIGNED_pp(const half3 V)
{
	return (V.xyz * 2.0) - 1.0;
}

half2 UNSIGNED_pp(const half2 V)
{
	return (V.xy * 0.5) + 0.5;
}

half2 SIGNED_pp(const half2 V)
{
	return (V.xy * 2.0) - 1.0;
}

half UNSIGNED_pp(const half V)
{
	return (V * 0.5) + 0.5;
}

half SIGNED_pp(const half V)
{
	return (V * 2.0) - 1.0;
}

// calc z based on x,y (base vector needed to be normalized)
// only works in tangentspace with positive normals !
float3 Derive_Z_RGB(const float2 Normal_XY)
{
	float3 Normal;
	Normal.xy = SIGNED(Normal_XY.xy);
	Normal.z = sqrt(1.0-saturate(dot(Normal.xy, Normal.xy)));  // Derive Z
	
	return Normal;
}	

//calc z based on x,y (base vector needed to be normalized)
// only works in tangentspace with positive normals !
float3 Derive_Z(const float2 Normal_XY)
{
	return float3(Normal_XY.xy, sqrt(1.0-saturate(dot(Normal_XY.xy, Normal_XY.xy))));  // Derive Z
}

float Reconstruct_Z(const float2 Normal_XY)
{
	return sqrt(1.0-saturate(dot(Normal_XY.xy, Normal_XY.xy)));
}	

// only works in tangentspace with positive normals !
void Derive_Z_RGB(out float3 Normal)
{
	Normal.xy = SIGNED(Normal).xy;
	Normal.z = sqrt(1.0-saturate(dot(Normal.xy, Normal.xy)));  // Derive Z
}

void ReconstructTangentFrameFromColorSign(inout float4 Normal_XYZW, inout float3 Tangent_XYZ, inout float3 Binormal_XYZ)
{
		Normal_XYZW.xyzw 	= SIGNED(Normal_XYZW.xyzw);
		Tangent_XYZ.xyz		= SIGNED(Tangent_XYZ.xyz);
		// only works if 1.0 is encoded as "no change", 0.0 will screw things up!
		Binormal_XYZ.xyz	= cross(Normal_XYZW.xyz, Tangent_XYZ.xyz) * sign(Normal_XYZW.w);
}

//-------------------------------------------------------------------------------
// We use X3 normalmap layout for better reuse of old textures.
//-------------------------------------------------------------------------------
//just Half inputs, force _pp calc's
half3 calcWorldNormal_pp(const half3 TexNormal, const half3 Norm, const half3 Tang, const half3 BiNo)
{
	// do we need to renormalize?, Op "should" be free right?
	#ifdef _3DSMAX_
		return (TexNormal.x * normalize(BiNo) + TexNormal.y * normalize(-Tang) + TexNormal.z * normalize(Norm)); //MAX 2008 Coords
	#else
		return (TexNormal.x * normalize(-Tang) + TexNormal.y * normalize(-BiNo) + TexNormal.z * normalize(Norm)); // game coords (why the 2 negs?)
	#endif
}

// float version
float3 calcWorldNormal(const half3 TexNormal, const float3 Norm, const float3 Tang, const float3 BiNo)
{
	// do we need to renormalize?, Op "should" be free right?
	#ifdef _3DSMAX_
		return (TexNormal.x * normalize(BiNo) + TexNormal.y * normalize(-Tang) + TexNormal.z * normalize(Norm)); //MAX 2008 Coords
	#else
		//return (TexNormal.x * normalize(-Tang) + TexNormal.y * normalize(-BiNo) + TexNormal.z * normalize(Norm)); // game coords (why the 2 negs?)
		return (TexNormal.x * (-Tang) + TexNormal.y * (-BiNo) + TexNormal.z * (Norm)); // game coords (why the 2 negs?) TEST remove normalize - those should come in normalized anyways
	#endif
}

//max only test
//we try to see if a diffuse texture is set for this sampler
/*bool Test_forTexture(sampler2D inSampler)
{
	float4 ColorRGBA = tex2D(inSampler, float2(0.5f, 0.5f)).rgba;
	//if all 4 values are zero we assume no texture is assigned to this sampler
	//if a texture is assigned without alpha than alpha whill be 1
	//the case that a texture is assigned with color and alpha == 0.0 is very small!
	return dot(ColorRGBA, ColorRGBA); // false == 0.0
} */

// simple camera distance based fading
half CalcCameraDistanceFading(const float inWorldViewZ, const half FadeRange, const half FadeSpeed)
{
//	return pow(saturate((inWorldViewZ / FadeRange) - 0.05), FadeSpeed);
	return saturate(1.0 + (inWorldViewZ / (FadeRange + 0.00001) - 1.0) * FadeSpeed);
}

half CalcViewAngleFading(const float3 normalWV, const float3 posWV, const half AnglePower, const half AngleOffset)
{
	return lerp(0.0, 1.0, saturate(pow(abs(dot(normalWV, normalize(posWV))), AnglePower) - AngleOffset));
}
///////////////////////////////////////////////////////////////////////////////////////////////////
////								Blend Ops													///
///////////////////////////////////////////////////////////////////////////////////////////////////
inline half3 blendScreen(const half3 A, const half3 B)
{
 	return (1 - (1 - A) * (1 - B));
}

inline half3 blendAvg(const half3 A, const half3 B)
{
 	return ((A + B) / 2);
}

inline half3 blendAdd(const half3 A, const half3 B)
{
 	return (A + B);
}

inline half3 blendMultiply(const half3 A, const half3 B)
{
 	return (A * B);
}

inline half3 blendOverlay(const half3 A, const half3 B)
{
    //half3 lumCoeff = half3(0.25,0.65,0.1);
    //half L = min(1,max(0,10*(dot(lumCoeff,A)- 0.45)));
    half L = min(1.0,max(0,10 *( luminance(A) - 0.45)));
    half3 result1 = 2.0 * A * B;
    half3 result2 = 1.0 - 2.0*(1.0-B)*(1.0-A);
    return (lerp(result1,result2,L)); 
}

inline half3 blendOverlayHDR(const half3 A, const half3 B)
{
    //half3 lumCoeff = half3(0.25,0.65,0.1);
    //half L = min(1,max(0,10*(dot(lumCoeff,A)- 0.45)));

    half L = min(1.0,max(0,10 *( luminance(A) - 0.45)));
    half3 result1 = 4.0 * A * B;
    half3 result2 = 4.0 - 8.0*(4.0-B)*(4.0-A);
    return (lerp(result1,result2,L)); 
}
inline half3 blendOverlayHDR2(const half3 A, const half3 B, const half strength)
{

//float3 multiplyResults = base * blend;  
//float3 screenResults = 1 - (1 - base) * (1 - blend);  
//float3 t = max(0, sign(base - 0.5));  
//float3 finalColor = 2 * lerp(multiplyResults, screenResults, t); 

	half3 multiplyResults = A*B;//	base * blend;  
	half3 screenResults = 4 - (4 - A) * (1 - B);  
	half3 t = max(0, sign(A - 10));  
	//return (A+B+ 8*lerp(multiplyResults, screenResults, t)); 
	//return (A+strength*screenResults+ strength*20 * multiplyResults ); //the one
	return (A+strength*B+ strength*20 * multiplyResults ); 
	//return screenResults; 

	

}

inline half3 blendOverlay(const half3 A, const half3 B, const half temp)
{
    //half3 lumCoeff = half3(0.25,0.65,0.1);
    //half L = min(1,max(0,10*(dot(lumCoeff,A)- 0.45)));
    half L = min(1.0,max(0,10 *( luminance(A) - 0.45)));
    half3 result1 = 2.0 * A * B;
    half3 result2 = 1.0 - 2.0*(1.0-B)*(1.0-A);
    return (lerp(result1,result2,L)); 
}

inline half3 blendOverlayDark(const half3 A, const half3 B)
{
    //half L = min(1,max(0,10*(dot(lumCoeff,A)- 0.45)));
    half L = luminance(A);
    L *= 0.5; //reduce bright spots, so B can get "through" better
    half3 result1 = 2 * A * B;
    half3 result2 = 1 - 2*(1-B)*(1-A);
    return (lerp(result1,result2,L)); 
}

inline half3 blendOverlayDark(const half3 A, const half3 B, const half temp)
{
    //half L = min(1,max(0,10*(dot(lumCoeff,A)- 0.45)));
    half L = luminance(A);
    L *= 0.5; //reduce bright spots, so B can get "through" better
    half3 result1 = 2 * A * B;
    half3 result2 = 1 - 2*(1-B)*(1-A);
    return (lerp(result1,result2,L)); 
}

inline half3 blendClimate(const half3 A, const half3 B)
{
	if (A.r>0.99 && A.g>0.99 && A.b>0.99)
	{
		return half3(1.0,1.0,1.0);
	}else
	return ((A + B)/2.0 );
}


inline half3 blendAlpha(const half3 A, const half3 B, const half alpha)
{
 	//return ( (A * alpha) +  (B * (1 - alpha)) );
 	return lerp(A, B, saturate(alpha));
}

inline half3 blendInv(const half3 A, const half3 B)
{
 	return abs(A - B);
}

// input values over 1.0 may result in bad artefacts!
inline half3 blendColorDodge(const half3 A, const half3 B)
{
 	return (A / (1 - B));
}
///////////////////////////////////////////////////////////////////////////////////////////////////
////								HDR/ColorSpace conversion Ops								///
///////////////////////////////////////////////////////////////////////////////////////////////////

half3 ToneMap_Reinhard(const half3 in_color, const float exposure, const float LumAvg, const float LumWhite, const float LumBlack)
{
	const half LumPixel = luminanceHDTV(in_color) - LumBlack; 
	
	// Apply the modified operator (Eq. 4)
	const float LumScaled = (LumPixel * exposure) / LumAvg;    
	const float LumCompressed = (LumScaled * (1.0 + (LumScaled / (LumWhite * LumWhite)))) / (1.0 + LumScaled);
	
	return LumCompressed * in_color;
} 

float GetShadow(sampler2D shadowmap, float4 coords)
{
	const int OFFSET_COUNT = 4;
	const float RECIPROCAL_OFFSET_COUNT = 1.0 / OFFSET_COUNT;
	float2 offsets[] = { float2(-0.5, -0.5), float2(0.5, -0.5), float2(-0.5, 0.5), float2(0.5, 0.5) };
	float4 results;
	
	float shadow = 1.0;
	
	coords.xyz /= coords.w;

//	return tex2D(shadowmap, coords.xy).x < coords.z ? 0.0 : 1.0;
	
	float2 coordfloor = floor(coords.xy * SHADOWMAP_SIZE) / SHADOWMAP_SIZE;
	results.x = tex2D(shadowmap, coordfloor.xy).x < coords.z ? 0.0 : 1.0;
	results.y = tex2D(shadowmap, coordfloor.xy + float2(1.0, 0.0) / SHADOWMAP_SIZE).x < coords.z ? 0.0 : 1.0;
	results.z = tex2D(shadowmap, coordfloor.xy + float2(0.0, 1.0) / SHADOWMAP_SIZE).x < coords.z ? 0.0 : 1.0;
	results.w = tex2D(shadowmap, coordfloor.xy + float2(1.0, 1.0) / SHADOWMAP_SIZE).x < coords.z ? 0.0 : 1.0;

	float2 f = frac(coords.xy * SHADOWMAP_SIZE);
	float2 yinter = lerp(results.xz, results.yw, f.x);
	return lerp(yinter.x, yinter.y, f.y);
}

float SoftParticleAttenuation(float softmin, float softmax, float z)
{
	float delta = z - softmin;
	float range = softmax - softmin;
	return saturate(delta / (range + 0.00001)); // prevent division by zero
}

#endif