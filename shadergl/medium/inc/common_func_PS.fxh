//========= Copyright  1998-2007, EGOSOFT, All rights reserved. ============
//
// Property of EGOSOFT, dont use or redistribute without premission.
//===========================================================================

#ifndef _EGO_PS
#define _EGO_PS
//NOTE: we need to keep V,N and intermediates in float precission to prevent spec artefacts!

// Light.xy (x = diffuse lambert, y = Phong Specular)
//power.xy (x = SpecPower, y = LabmertScalePower)

half calc_LambertHalf(const float3 N, const float3 L, const half2 Power)
{
	const half NdL = dot(N, L);
	return lambert_half(NdL, Power.y);		// Diffuse (half lambert/scaled up)
}

half2 calc_LambertHalf_Phong(const float3 N, const float3 L, const half3 V, const half2 Power)
{
	half2 Light;

	const float3 R = reflect(-L, N); 	
	const half NdL = dot(N, L);
		
	Light.x = lambert_half(NdL, Power.y);		// Diffuse (half lambert/scaled up)
	Light.y = pow(saturate(dot(R, V)), Power.x);	// Phong (half precission)
	Light.y *= saturate(3.0 * saturate(NdL)); 	// Shadow term
	
   	return Light;
}

half2 calc_Lambert_Phong(const float3 N, const float3 L, const half3 V, const half2 Power)
{
	half2 Light;

	const float3 R = reflect(-L, N); 	
	const half NdL = dot(N, L);
		
	Light.x = saturate(NdL);		// Diffuse
	Light.y = pow(saturate(dot(R, V)), Power.x);	// Phong (half precission)
	Light.y *= saturate(3.0 * Light.x); 	// Shadow term
	
   	return Light;
}

half2 calc_Lambert_Blinn(const float3 N, const float3 L, const half3 V, const half2 Power)
{
	half2 Light;
	
	const float3 H = normalize(V + L); // NOTE: we need float here, but this triggers the flow control bug...???
	const half NdL = dot(N, L);
	
	Light.x = saturate(NdL); 		//Diffuse
	Light.y = pow(saturate(dot(N, H)), Power.x);//Specular
	Light.y *= saturate(3.0 * Light.x); //Shadow term
	
	return Light;
}

half2 calc_LambertHalf_Blinn(const float3 N, const float3 L, const half3 V, const half2 Power)
{
	half2 Light;
	
	const float3 H = normalize(V + L);
	const half NdL = dot(N, L);
	
	Light.x = lambert_half(NdL, Power.y);
	Light.y = pow(saturate(dot(N, H)), Power.x);//Specular
	Light.y *= saturate(3.0 * saturate(NdL)); //Shadow term
	
	return Light;
}

half2x3 Light_Blinn_PS(const float3 VertexToLight, const float3 VertexToEye, const float3 Normal, const half Power, const half3 LightColor)
{
	half2x3 Light = (half2x3)0;
	float2 LightInfluence;
	float3 HalfAngle = normalize(VertexToEye + VertexToLight);
	LightInfluence.x = saturate(dot(Normal, VertexToLight) ); 		//Diffuse
	LightInfluence.y = pow(saturate(dot(Normal, HalfAngle)), Power);//Specular
	LightInfluence.y *= saturate(3.0 * LightInfluence.x); //Shadow term
	
	Light[0].rgb = LightInfluence.x * LightColor.rgb;
	Light[1].rgb = LightInfluence.y * LightColor.rgb;
	return Light;
}

//special Pixel version
//power x,y (x = Spec, y = Diff)
float3 calc_Light_HalfLambert_Point_PS(const float3 PixelPosWorld, const float3 VertexToEye, const float3 Normal, const half LambertPower, const float4 PointLightPos_Att, const half4 PointLightRGB_Ex)
{
	half3 Light;

   	float3 PixelToLight = PointLightPos_Att.xyz - PixelPosWorld.xyz; 	// unnormalized Pixel to Light vector
   	float LightDist = length(PixelToLight);
   	if(LightDist < PointLightPos_Att.a)
   	{
   		PixelToLight = normalize(PixelToLight);	//no more fency math we have special normalize hardware

		half DistanceAtten = 1.0f - smoothstep(0.0f, PointLightPos_Att.a, LightDist );
		half NdL = dot(Normal, PixelToLight);
		
		half LightInfluence = lambert_half(NdL, LambertPower);	//Diffuse (half lambert/scaled up)
		LightInfluence *= DistanceAtten; 					//mod both by Attenuation
		LightInfluence *= PointLightRGB_Ex.a;				//mod both by Intensity
		
		Light = LightInfluence * PointLightRGB_Ex.rgb; //mod by color
	}
	
   	return Light;
}

half2x3 Light_BlinnHalfLambert_PS(float3 VertexToLight, float3 VertexToEye, float3 Normal, half Power, half3 LightColor, half LambertPower)
{
	half2x3 Light = (half2x3)0;
	float2 LightInfluence;
	float3 HalfAngle = normalize(VertexToEye + VertexToLight);
	float NdL = dot(Normal, VertexToLight);
	LightInfluence.x = lambert_half(NdL, LambertPower); 		//Diffuse
	LightInfluence.y = pow(saturate(dot(Normal, HalfAngle)), Power);//Specular
	LightInfluence.y *= saturate(3.0 * saturate(NdL)); //Shadow term
	
	Light[0].rgb = LightInfluence.x * LightColor.rgb;
	Light[1].rgb = LightInfluence.y * LightColor.rgb;
	return Light;
}

#ifndef _3DSMAX_
//anisotropic lighting
inline half2x3 Light_BlinnAnisoHalfLambert_PS(float3 VertexToLight, float3 VertexToEye, float3 Normal, half SpecPower, half3 LightColor, half LambertPower, sampler2D s_Anisotropic, half2 TexVertexAni)
{
	half2x3 Light = (half2x3)0;
	float2 LightInfluence;
	float NdL = dot(Normal, VertexToLight);
	LightInfluence.x = lambert_half(NdL, LambertPower);
	LightInfluence.y = pow(tex2D(s_Anisotropic, TexVertexAni.xy).g, SpecPower);
	LightInfluence.y *= saturate(3.0 * saturate(NdL) ); //Shadow term
	
	Light[0].rgb = LightInfluence.x * LightColor.rgb;
	Light[1].rgb = LightInfluence.y * LightColor.rgb;
	return Light;
}
#endif

half2x3 Light_Hair_PS(float3 DiffColor, float3 VertexToLight, float3 VertexToEye, float3 Normal, float3 Tangent, half SpecPower, half3 LightColor)
{
	half2x3 Light = (half2x3)0;
	float3 Diff;
	float3 Spec;
	float3 HalfAngle = normalize(VertexToEye + VertexToLight);
	float NdL = dot(Normal, VertexToLight);
	Diff = max(0.0, 0.75 * NdL + 0.25);

	float3 T1 = normalize(Tangent - 0.2 * Normal);
	float3 T2 = normalize(Tangent + 0.1 * Normal);
	
	float3 T1dH = dot(T1, HalfAngle);
	float3 T2dH = dot(T2, HalfAngle);
	
	float3 colorkey = DiffColor / luminance(DiffColor);
	Spec = pow(1 - T1dH * T1dH, 0.5 * SpecPower * 0.2) * (0.5 + 0.5 * colorkey);
	Spec += pow(1 - T2dH * T2dH, 0.5 * SpecPower) * (0.9 + 0.1 * colorkey);
	Spec *= saturate(3.0 * saturate(NdL) ); //Shadow term
	
	Light[0].rgb = Diff * LightColor.rgb;
	Light[1].rgb = Spec * LightColor.rgb;
	return Light;
}

half2x3 Light_Phong_PS(float3 VertexToLight, float3 VertexToEye, float3 Normal, half Power, half3 LightColor)
{
	half2x3 Light = (half2x3)0;
	float2 LightInfluence;
	float3 R = (reflect(-VertexToLight, Normal));
	LightInfluence.x = saturate(dot(Normal, VertexToLight)); 		//Diffuse
	LightInfluence.y = pow(saturate(dot(R, VertexToEye)), Power); 	//Specular
	LightInfluence.y *= saturate(3.0 * LightInfluence.x); //Shadow term
	
	Light[0].rgb = LightInfluence.x * LightColor.rgb;
	Light[1].rgb = LightInfluence.y * LightColor.rgb;
	return Light;
}

//half lambert
half2x3 Light_PhongHalfLambert_PS(float3 L, float3 V, float3 N, half Power, half3 LightColor, half LambertPower, half3 Occlusion)
{
	half2x3 Light = (half2x3)0;
	float3 R = reflect(-L, N);
	float NdL = dot(N, L);
	
	float Phong = pow(saturate(dot(R, V)), Power); 	//Specular
	Phong *= saturate( 3.0 * saturate(NdL) ); //Shadow term
	
	//Light[0].rgb = (lambert_rolloff(NdL, LambertPower) + max(0,NdL)) * LightColor.rgb * Occlusion;
	Light[0].rgb = lambert_half(NdL, LambertPower) * Occlusion * LightColor.rgb;
	
	Light[1].rgb = Phong * Occlusion * LightColor.rgb;
	return Light;
}

//half lambert
half2x3 Light_PhongHalfLambert2_PS(float3 L, float3 V, float3 N, half Power, half3 LightColor, half LambertPower, half3 Occlusion)
{
	half2x3 Light = (half2x3)0;
	float3 R = (reflect(-L, N));
	float NdL = dot(N, L);
	
	float Phong = pow(saturate(dot(R, V)), Power); 	//Specular
	Phong *= saturate( 3.0 * saturate(NdL) ); //Shadow term
	
	Light[0].rgb = (lambert_rolloff(NdL, LambertPower) + max(0,NdL)) * LightColor.rgb * Occlusion;
	//Light[0].rgb = lambert_half(NdL, LambertPower) * LightColor.rgb * Occlusion;
	
	Light[1].rgb = Phong * LightColor.rgb;
	return Light;
}

half spec_func(half s, half NaH, half NaNa) {
    half toksvig = sqrt(NaNa) / (sqrt(NaNa) + s*(1-sqrt(NaNa)));
    return (1.0+toksvig*s) / (1.0+s) * pow(NaH/sqrt(NaNa), toksvig*s);
}

half2 Light_toksvig_PS(float3 VertexToLight, float3 VertexToEye, float3 Normal, half Power)
{
	half2 LightInfluence;
	float3 R = normalize(VertexToLight + VertexToEye);
	//half3 R = reflect(-VertexToLight, Normal);
    //R.N  V.R
    float NaR = dot(R, Normal);
	float NaNa = dot(Normal, Normal);
	LightInfluence.xy = float2( saturate( dot(Normal, VertexToLight) ), spec_func(Power*4.0, NaR , NaNa) );
	LightInfluence.y *= saturate(3.0 * LightInfluence.x); //Shadow term

	return LightInfluence;
}

half2x3 Light_MayaBlinn_PS(float3 VertexToLight, float3 VertexToEye, float3 Normal, half Power, half3 LightColor)
{
	half2x3 Light = (half2x3)0;
	float2 LightInfluence;
	LightInfluence.x = saturate(dot(Normal, VertexToLight)); 		//Diffuse
	LightInfluence.y = MayaBlinnSpecular(-VertexToLight, -VertexToEye, Normal, Power, 1);
	//LightInfluence.y *= saturate(3 * LightInfluence.x); //Shadow term
	
	Light[0].rgb = LightInfluence.x * LightColor.rgb;
	Light[1].rgb = LightInfluence.y * LightColor.rgb;
	return Light;
}

//--------------------------------------------------------
// Strauss-like light model
//--------------------------------------------------------
half3 calc_Strauss(	const float3 N, 
					const float3 L, 
					const float3 V, 
					const float smooth, 
					const float metal,
					const float diffusestr,
					const float specularstr,
					const half3 lightcolor,
					const half3 diffusecolor,
					const half3 F0)
{
	const float3 R = reflect(-L, N);
	
	const float NdL = dot(N, L);
	const float VdL = dot(V, L);
	const float RdV = dot(R, V);
	
	const half specatten = saturate(3.0 * saturate(NdL));
	const half smoothsquared = smooth * smooth;
	
	const half3 Jd = diffusecolor.rgb; // could be (1.0 - smooth * k) instead of just 1.0
	const half3 Js = smoothsquared / saturate(VdL * 0.9 + 1.0) * F0 * pow(saturate(RdV), 8 * smoothsquared + 10);
	
	return lightcolor.rgb * (lambert_half_power_8(NdL) * diffusestr * Jd + specatten * specularstr * Js);

}
half3 calc_StraussNew(	const float3 N, 
					const float3 L, 
					const float3 V, 
					const float smooth, 
					const float metal,
					const float diffusestr,
					const float specularstr,
					const float SpecFunc,
					const half3 lightcolor,
					const half3 diffusecolor,
					const half3 F0)
{
	  // Make sure the interpolated inputs and
    // constant parameters are normalized
	half3 diffuse;
	
   //  float3 nn = normalize( N );
   //  float3 ln = normalize( L );
   //  float3 vn = normalize( V );
     float3 h = reflect( -L, N );
 
	    
    // Declare any aliases:
    float NdotL   = (dot( N, L ));
	
	float NdotV   = (dot( N, V ));
    float HdotV   = (dot( h, V ));
    float fNdotL  = fresnel_a( NdotL ); //((( 1.0f/(pow(abs(NdotL-1.12f),2)+0.01f)) - 0.797f) / 68.652f);
    float s_cubed = smooth * smooth * smooth;
	//float s_cubed = smooth * smooth ;
		
	float fTransparency = 0.0f;
	
    // Evaluate the diffuse term
    float d  = ( 1.0f - metal * smooth );
	float Rd = ( 1.0f - s_cubed ) * ( 1.0f - fTransparency );
	
	
	diffuse = NdotL * d * Rd * diffusecolor;
   // Compute the inputs into the specular term
    float r = ( 1.0f - fTransparency ) - Rd;
 
	
    float j = fNdotL;// * shadow( NdotL ) * shadow( NdotV );
 


    // 'k' is used to provide small off-specular
    // peak for very rough surfaces. Can be changed
    // to suit desired results...
     float k = 0.1f;//was 0.1
    float reflect = min( 1.0f, r + j * ( r + k ) );
 
    float3 C1 = float3( 1.0f, 1.0f, 1.0f );
    float3 Cs = C1 + metal * (1.0f - fNdotL) * (diffusecolor - C1);
 
 	half specatten = saturate(3.0 * saturate(NdotL));
	//half specatten = saturate(NdotL);

	

    // Evaluate the specular term
    //half3 specular = Cs * reflect*specatten;
	half3 specular = Cs* reflect*specatten;
    specular *= pow( -HdotV, 3.0f / ((1.0f - smooth)) ); //(0.000000134123f + (1.0f - smooth))
	
	
	
    // Composite the final result, ensuring
    // the values are >= 0.0f yields better results. Some
    // combinations of inputs generate negative values which
    // looks wrong when rendered...
    diffuse  = max( 0.0f, diffusestr*diffuse*lightcolor.rgb );
    specular = max( 0.0f, specularstr*specular*lightcolor.rgb );
	//new : additive/multiply mix

	const half3 addSpecular = SpecFunc*specular;
	const half3 mulSpecular = (1.0 - SpecFunc)*specular;
	diffuse = (diffuse + addSpecular) + (diffuse*mulSpecular);

	//old style aditive only
	//diffuse += specular; //diffuse += diffuse*specular;
	
    return diffuse;
}
half3 calc_StraussNew2(	const float3 N, 
					const float3 L, 
					const float3 V, 
					const float smooth, 
					const float metal,
					const float diffusestr,
					const float specularstr,
					const float SpecFunc,
					const half3 lightcolor,
					const half3 diffusecolor,
					const half3 F0,
					const half3 specularcolor)
{
	  // Make sure the interpolated inputs and
    // constant parameters are normalized
	half3 diffuse;
	
   //  float3 nn = normalize( N );
   //  float3 ln = normalize( L );
   //  float3 vn = normalize( V );
     float3 h = reflect( -L, N );
 
	    
    // Declare any aliases:
    float NdotL   = (dot( N, L ));
	
	float NdotV   = (dot( N, V ));
    float HdotV   = (dot( h, V ));
    float fNdotL  = fresnel_a( NdotL ); //((( 1.0f/(pow(abs(NdotL-1.12f),2)+0.01f)) - 0.797f) / 68.652f);
    float s_cubed = smooth * smooth * smooth;
	//float s_cubed = smooth * smooth ;
		
	float fTransparency = 0.0f;
	
    // Evaluate the diffuse term
    float d  = ( 1.0f - metal * smooth );
	float Rd = ( 1.0f - s_cubed ) * ( 1.0f - fTransparency );
	
	
	diffuse = NdotL * d * Rd * diffusecolor;
   // Compute the inputs into the specular term
    float r = ( 1.0f - fTransparency ) - Rd;
 
	
    float j = fNdotL;// * shadow( NdotL ) * shadow( NdotV );
 


    // 'k' is used to provide small off-specular
    // peak for very rough surfaces. Can be changed
    // to suit desired results...
     float k = 0.1f;//was 0.1
    float reflect = min( 1.0f, r + j * ( r + k ) );
 
    float3 C1 = float3( 1.0f, 1.0f, 1.0f );
    float3 Cs = C1 + metal * (1.0f - fNdotL) * (diffusecolor - C1);
 
 	half specatten = saturate(3.0 * saturate(NdotL));
	//half specatten = saturate(NdotL);

	

    // Evaluate the specular term
    //half3 specular = Cs * reflect*specatten;
	half3 specular = Cs* reflect*specatten;
    specular *= pow( -HdotV, 3.0f / ((1.0f - smooth)) ); //(0.000000134123f + (1.0f - smooth))
	
	
	
    // Composite the final result, ensuring
    // the values are >= 0.0f yields better results. Some
    // combinations of inputs generate negative values which
    // looks wrong when rendered...
    diffuse  = max( 0.0f, diffusestr*diffuse*lightcolor.rgb );
    specular = max( 0.0f, specularstr*specular*specularcolor.rgb );
	//new : additive/multiply mix

	const half3 addSpecular = SpecFunc*specular;
	const half3 mulSpecular = (1.0 - SpecFunc)*specular;
	diffuse = (diffuse + addSpecular) + (diffuse*mulSpecular);

	//old style aditive only
	//diffuse += specular; //diffuse += diffuse*specular;
	
    return diffuse;
}
#endif
