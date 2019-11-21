//========= Copyright ? 1998-2007, EGOSOFT, All rights reserved. ============
//
// Property of EGOSOFT, dont use or redistribute without premission.
//===========================================================================

#ifndef _EGO_LIGHTING_MACROS
#define _EGO_LIGHTING_MACROS

#define CALC_GLOBAL_DIRLIGHT_SHADOW(NR, LIGHTFUNCTION_GLOBAL, LIGHT_POWER, IN_OUT_DIFFUSE, IN_OUT_SPECULAR, SHADOW) 	\
	if (DirLight_ColorEx_##NR.a > 0.0)																		\
	{																										\
		half4 DirLightColor_Ex = DirLight_ColorEx_##NR.rgba;												\
    	DirLightColor_Ex.rgb = TO_linearRGB(DirLightColor_Ex.rgb);											\
    	DirLightColor_Ex.rgb *= (DirLightColor_Ex.a * GlobalLightScale);									\
       	half2 DiffSpecTerms = LIGHTFUNCTION_GLOBAL##(Normal, DirLight_Dir_##NR, VertexToEye, LIGHT_POWER); 	\
       	DiffSpecTerms.x *= saturate(SHADOW * 0.9 + 0.1); /* sum to 1.0, 10% light still at shadow) */		\
       	DiffSpecTerms.y *= saturate(SHADOW * SHADOW); /* we dont want specular in shadow areas */			\
		IN_OUT_DIFFUSE##.rgb += DirLightColor_Ex.rgb * DiffSpecTerms.x; 									\
		IN_OUT_SPECULAR##.rgb += DirLightColor_Ex.rgb * DiffSpecTerms.y; 									\
	}

#define CALC_GLOBAL_DIRLIGHT(NR, LIGHTFUNCTION) 														\
	if (DirLight_ColorEx_##NR.a > 0.0)																	\
	{																									\
		half4 DirLightColor_Ex = DirLight_ColorEx_##NR.rgba;											\
    	DirLightColor_Ex.rgb = TO_linearRGB(DirLightColor_Ex.rgb);										\
    	DirLightColor_Ex.rgb *= (DirLightColor_Ex.a * GlobalLightScale);								\
       	half2 DiffSpecTerms = LIGHTFUNCTION##(Normal, DirLight_Dir_##NR, VertexToEye, LightPower.xy); 	\
		DiffuseLight.rgb += DirLightColor_Ex.rgb * DiffSpecTerms.x; 									\
		SpecularLight.rgb += DirLightColor_Ex.rgb * DiffSpecTerms.y;									\
	}

#define CALC_STRAUSS_DIRLIGHT_SHADOW(NR, DIFFUSE, F0, SHADOW, OUT_COLOR)								\
	if (DirLight_ColorEx_##NR.a > 0.0)																	\
	{																									\
		half4 LightColor = DirLight_ColorEx_##NR.rgba;													\
    	LightColor.rgb = TO_linearRGB(LightColor.rgb) * LightColor.a * GlobalLightScale;				\
		const float specstr = SpecStr * (TexSpecularStr.g )* SHADOW * SHADOW*512.0f;								\
		const float diffstr = DiffStr * saturate(SHADOW * 0.9 + 0.1);									\
		OUT_COLOR##.rgb += calc_StraussNew(Normal, DirLight_Dir_##NR, VertexToEye, 						\
										Smoothness, Metallness, diffstr, specstr, 		1.0,				\
										LightColor, DIFFUSE, F0); 								\
	}
#define CALC_STRAUSS_DIRLIGHT_2_SHADOW(NR, DIFFUSE, SPECULAR, F0, SHADOW, OUT_COLOR)								\
	if (DirLight_ColorEx_##NR.a > 0.0)																	\
	{																									\
		half4 LightColor = DirLight_ColorEx_##NR.rgba;													\
    	LightColor.rgb = TO_linearRGB(LightColor.rgb) * LightColor.a * GlobalLightScale;				\
		const float specstr = SpecStr * (TexSpecularStr.g )* SHADOW * SHADOW*512.0f;								\
		const float diffstr = DiffStr * saturate(SHADOW * 0.9 + 0.1);									\
		OUT_COLOR##.rgb += calc_StraussNew2(Normal, DirLight_Dir_##NR, VertexToEye, 						\
										Smoothness, Metallness, diffstr, specstr, 		1.0,				\
										LightColor, DIFFUSE, F0,SPECULAR); 								\
	}
#define CALC_STRAUSS_DIRLIGHT_COCKPIT_SHADOW(NR, DIFFUSE, F0, SHADOW, OUT_COLOR)								\
	if (DirLight_ColorEx_##NR.a > 0.0)																	\
	{																									\
		half4 LightColor = DirLight_ColorEx_##NR.rgba;													\
    	LightColor.rgb = TO_linearRGB(LightColor.rgb) * LightColor.a * GlobalLightScale*0.5;				\
		const float specstr = SpecStr * (TexSpecularStr.g )* SHADOW * SHADOW*256.0f;								\
		const float diffstr = DiffStr * saturate(SHADOW * 0.9 + 0.1);									\
		OUT_COLOR##.rgb += calc_StraussNew(Normal, DirLight_Dir_##NR, VertexToEye, 						\
										Smoothness, Metallness, diffstr, specstr, 		1.0,				\
										LightColor, DIFFUSE, F0); 								\
	}
#define CALC_STRAUSS_DIRLIGHT(NR, DIFFUSE, F0, OUT_COLOR)												\
	if (DirLight_ColorEx_##NR.a > 0.0)																	\
	{																									\
		half4 LightColor = DirLight_ColorEx_##NR.rgba;													\
    	LightColor.rgb = TO_linearRGB(LightColor.rgb) * LightColor.a * GlobalLightScale;				\
		const float specstr = SpecStr * (TexSpecularStr.g)*512.0f;												\
		const float diffstr = DiffStr;																	\
		OUT_COLOR##.rgb += calc_StraussNew(Normal, DirLight_Dir_##NR, VertexToEye, 						\
										Smoothness, Metallness, diffstr, specstr, 	1.0,					\
										LightColor, DIFFUSE, F0);								\
	}
#define CALC_STRAUSS_PLANET_DIRLIGHT(NR, DIFFUSE, F0, OUT_COLOR)												\
	if (DirLight_ColorEx_##NR.a > 0.0)																	\
	{																									\
		half4 LightColor = DirLight_ColorEx_##NR.rgba;													\
    	LightColor.rgb = TO_linearRGB(LightColor.rgb) * LightColor.a * GlobalLightScale;				\
		const float specstr = SpecStr * (TexSpecularStr.g)*12.0f;												\
		const float diffstr = DiffStr;																	\
		OUT_COLOR##.rgb += calc_StraussNew(Normal, DirLight_Dir_##NR, VertexToEye, 						\
										Smoothness2, Metallness2, diffstr, specstr, 0.0	,					\
										LightColor, DIFFUSE, F0);								\
	}
#define CALC_STRAUSS_OLD_DIRLIGHT(NR, DIFFUSE, F0, OUT_COLOR)												\
	if (DirLight_ColorEx_##NR.a > 0.0)																	\
	{																									\
		half4 LightColor = DirLight_ColorEx_##NR.rgba;													\
    	LightColor.rgb = TO_linearRGB(LightColor.rgb) * LightColor.a * GlobalLightScale;				\
		const float specstr = SpecStr * (TexSpecularStr.g);												\
		const float diffstr = DiffStr;																	\
		OUT_COLOR##.rgb += calc_Strauss(Normal, DirLight_Dir_##NR, VertexToEye, 						\
										Smoothness, Metallness, diffstr, specstr, 						\
										LightColor, DIFFUSE, F0);								\
	}
#define CALC_AMBIENT(DIFFUSE, AMBIENT, OUT_COLOR)														\
	OUT_COLOR += AMBIENT * DIFFUSE;																		\
	
#define CALC_GLOBAL_DIRLIGHT_SKIN(NR, LIGHTFUNCTION) 													\
	if (DirLight_ColorEx_##NR.a > 0.0)																	\
	{																									\
		half4 DirLightColor_Ex = DirLight_ColorEx_##NR.rgba;											\
    	DirLightColor_Ex.rgb = TO_linearRGB(DirLightColor_Ex.rgb);										\
    	DirLightColor_Ex.rgb *= (DirLightColor_Ex.a * GlobalLightScale);								\
       	half2 DiffSpecTerms = LIGHTFUNCTION##(Normal, DirLight_Dir_##NR, VertexToEye, LightPower.xy); 	\
		DiffuseLight.rgb += DirLightColor_Ex.rgb * DiffSpecTerms.x; 									\
		SpecularLight.rgb += DirLightColor_Ex.rgb * DiffSpecTerms.y;									\
		if(ColorBaseDiffuseSub.a > 0.1) {																\
			half DiffTermSub = lambert_half(dot(NormalSub, DirLight_Dir_##NR), LambertPowerSub); 		\
			DiffuseLightSub += DirLightColor_Ex.rgb * DiffTermSub;										\
		} 																								\
	}	

#define CALC_GLOBAL_DIRLIGHT_PLANET(NR, LIGHTFUNCTION) \
	if (DirLight_ColorEx_##NR.a > 0.0)									\
	{																	\
		half4 DirLightColor_Ex = DirLight_ColorEx_##NR.rgba;			\
    	DirLightColor_Ex.rgb = TO_linearRGB(DirLightColor_Ex.rgb);		\
    	DirLightColor_Ex.rgb *= (DirLightColor_Ex.a * 0.15); /* HACK layer multiply + HDR = bad idea */					\
       	half2 DiffSpecTerms = LIGHTFUNCTION##(Normal, DirLight_Dir_##NR, VertexToEye, LightPower.xy ); \
		DiffuseLight.rgb += DirLightColor_Ex.rgb * DiffSpecTerms.x; 	\
		SpecularLight.rgb += DirLightColor_Ex.rgb * DiffSpecTerms.y;	\
	}																	
#define ADD_GLOBAL_DIRLIGHT_FRESNEL(RES, NR, VERTEX_TO_EYE, NORMAL, POWER, STR, FALLOFF, OFFSET) \
	if (DirLight_ColorEx_##NR.a > 0.0)	{								\
		half4 DirLightColor_Ex = DirLight_ColorEx_##NR.rgba;			\
    	DirLightColor_Ex.rgb = TO_linearRGB(DirLightColor_Ex.rgb);		\
    	DirLightColor_Ex.rgb *= DirLightColor_Ex.a;						\
		RES += DirLightColor_Ex.rgb * (pow(saturate(-dot(DirLight_Dir_##NR, VERTEX_TO_EYE) + OFFSET), FALLOFF)) * fresnel(VERTEX_TO_EYE, NORMAL, POWER) * STR; \
	}

#endif // EOF