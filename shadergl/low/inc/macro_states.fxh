//========= Copyright ? 1998-2007, EGOSOFT, All rights reserved. ============
//
// Property of EGOSOFT, dont use or redistribute without premission.
//===========================================================================

#ifndef _EGO_MACRO_STATES
#define _EGO_MACRO_STATES

// helper file for large crappy static state + shader defines
#define _DEFAULT_STATES_BASE \
	    COLORWRITEENABLE = RED|GREEN|BLUE; 	\
		CullMode = _DEFAULT_CULLMODE;		\
		ALPHAFUNC = GREATEREQUAL;			\
		ALPHAREF = 2;						\

//use default states
#define _DEFAULT_STATES_BASE_SOLID \
	    COLORWRITEENABLE = RED|GREEN|BLUE; 	\
		ZEnable = true;						\
		ZWriteEnable = true;				\
		CullMode = _DEFAULT_CULLMODE;		\
		AlphaBlendEnable = false;			\
		ALPHATESTENABLE = false;			\
		ALPHAFUNC = GREATEREQUAL;			\
		ALPHAREF = 2;						\

//use default states
// we need to clamp beetwen 170-0 for TAA MS Mode 
// note we subtract 32 from any alpha
#define _DEFAULT_STATES_BASE_SOLID_ALPHA1BIT \
	    COLORWRITEENABLE = RED|GREEN|BLUE; 	\
		ZEnable = true;						\
		ZWriteEnable = true;				\
		CullMode = none;					\
		AlphaBlendEnable = false;			\
		ALPHATESTENABLE = true;				\
		ALPHAFUNC = GREATEREQUAL;			\
		ALPHAREF = 2;						\

		
//use default states
#define _DEFAULT_STATES_BASE_SOLID_NOCULL	\
	    COLORWRITEENABLE = RED|GREEN|BLUE; 	\
		ZEnable = true;						\
		ZWriteEnable = true;				\
		CullMode = none;					\
		AlphaBlendEnable = false;			\
		ALPHATESTENABLE = false;			\
		ALPHAFUNC = GREATEREQUAL;			\
		ALPHAREF = 2;						\

//use default states
#define _DEFAULT_STATES_BASE_ALPHA8	\
	    COLORWRITEENABLE = RED|GREEN|BLUE; 	\
		ZEnable = true;						\
		ZWriteEnable = false;				\
		CullMode = _DEFAULT_CULLMODE;		\
		AlphaBlendEnable = true;			\
		ALPHATESTENABLE = false;			\
		ALPHAFUNC = GREATEREQUAL;			\
		SrcBlend =srcalpha;			 		\
		DestBlend =invsrcalpha;				\
		ALPHAREF = 2;

#define _DEFAULT_STATES_BASE_ALPHA8_NOCULL \
	    COLORWRITEENABLE = RED|GREEN|BLUE; 	\
		ZEnable = true;						\
		ZWriteEnable = false;				\
		CullMode = _CULL_NONE;				\
		AlphaBlendEnable = true;			\
		ALPHATESTENABLE = true;				\
		ALPHAFUNC = GREATEREQUAL;			\
		SrcBlend =srcalpha;			 		\
		DestBlend =invsrcalpha;				\
		ALPHAREF = 2;

#define _DEFAULT_STATES_BASE_ALPHA8_NOCULL_SOLID \
		COLORWRITEENABLE = RED|GREEN|BLUE; 	\
		ZEnable = true;						\
		ZWriteEnable = true;				\
		CullMode = _CULL_NONE;				\
		AlphaBlendEnable = true;			\
		ALPHATESTENABLE = true;				\
		ALPHAFUNC = GREATEREQUAL;			\
		SrcBlend =srcalpha;			 		\
		DestBlend =invsrcalpha;				\
		ALPHAREF = 2;


// new split states, we keep old for compatibility

#define _STATEBLOCK_SOLID \
		ZEnable = true;						\
		ZWriteEnable = true;				\
		AlphaBlendEnable = false;			\
		AlphaTestEnable = false;			\
		COLORWRITEENABLE = RED|GREEN|BLUE; 	\
		SRGBWRITEENABLE = true;				\
		CullMode = _DEFAULT_CULLMODE;
		
#define _STATEBLOCK_SOLID_TWOSIDED \
		ZEnable = true;						\
		ZWriteEnable = true;				\
		AlphaBlendEnable = false;			\
		AlphaTestEnable = false;			\
		COLORWRITEENABLE = RED|GREEN|BLUE; 	\
		SRGBWRITEENABLE = true;				\
		CullMode = _CULL_NONE;

#define _STATEBLOCK_SOLID_ALPHATEST \
		ZEnable = true;						\
		ZWriteEnable = true;				\
		AlphaBlendEnable = true;			\
		AlphaTestEnable = true;				\
		ALPHAREF = 2;						\
		COLORWRITEENABLE = RED|GREEN|BLUE; 	\
		SRGBWRITEENABLE = true;				\
		CullMode = _CULL_NONE;

#define _STATEBLOCK_TRANSPARENT \
		ZEnable = true;						\
		ZWriteEnable = false;				\
		AlphaBlendEnable = true;			\
		AlphaTestEnable = false;			\
		COLORWRITEENABLE = RED|GREEN|BLUE; 	\
		SRGBWRITEENABLE = true;		

#define _BLENDMODE_DEFAULT \
		BlendOp =add; 			\
		SrcBlend =one;			\
		DestBlend =one;
		
#define _BLENDMODE_ALPHA1 \
		BlendOp =add; 			\
		SrcBlend =srcalpha;		\
		DestBlend =invsrcalpha;

#define _BLENDMODE_ALPHA8 \
		BlendOp =add; 			\
		SrcBlend =srcalpha;		\
		DestBlend =invsrcalpha;	\
		CullMode = _CULL_NONE;		

#define _BLENDMODE_ALPHA8_SINGLE \
		BlendOp =add; 			\
		SrcBlend =srcalpha;		\
		DestBlend =invsrcalpha;	\
		CullMode = _DEFAULT_CULLMODE;
		
#define _BLENDMODE_SCREEN \
		BlendOp =add; 			\
		SrcBlend =one;			\
		DestBlend =invsrcColor;	\
		CullMode = _CULL_NONE;
		
#define _BLENDMODE_ADDITIVE \
		BlendOp =add; 			\
		SrcBlend =one;			\
		DestBlend =one;			\
		CullMode = _CULL_NONE;

#define _BLENDMODE_ADDITIVE_SINGLE \
		BlendOp =add; 			\
		SrcBlend =one;			\
		DestBlend =one;			\
		CullMode = _DEFAULT_CULLMODE;
		
#define _BLENDMODE_MULTIPLY \
		BlendOp =add; 			\
		SrcBlend =destcolor;	\
		DestBlend =zero;		\
		CullMode = _CULL_NONE;
		
#define _BLENDMODE_SUBTRACTIVE \
		BlendOp =subtract; 		\
		SrcBlend =one;			\
		DestBlend =one;			\
		CullMode = _CULL_NONE;
		
#define _BLENDMODE_SCRCOLOR \
		BlendOp =add; 			\
		SrcBlend =srccolor;		\
		DestBlend =invsrcColor;	\
		CullMode = _CULL_NONE;
		
#define _BLENDMODE_HAZEBLEND \
		BlendOp =add; 			\
		SrcBlend =srccolor;		\
		DestBlend =one;			\
		CullMode = _CULL_NONE;

#define _BLENDMODE_HAZEBLENDOLD \
		BlendOp =add; 			\
		SrcBlend =srccolor;		\
		DestBlend =one;			\
		CullMode = _CULL_NONE;
		
#define _BLENDMODE_ALPHA8ADD \
		BlendOp =add;		\
		SrcBlend =one;		\
		DestBlend =invsrcalpha;\
		CullMode = _CULL_NONE;

//-------------------------------------------------------------------------------
// Lighting
//-------------------------------------------------------------------------------
#ifdef _3DSMAX_
	#define USE_TEXTURE_LIGHTING \
		DEF_AUTO_PARA(LocalLightScale, LOCALLIGHTSCALE	, float, (1.0)) \
		DEF_PARA_UI(GlobalLightScale, GLOBALLIGHTSCALE, float, {1.0}, none, "Light strength", SLIDER, 0.0, 20.0, 0.1)
#else 
	#define USE_TEXTURE_LIGHTING \
		DEF_AUTO_TEXTURE_ADV(LightIndexTexture		, LBUFFERRESOLVE		,_2D, LINEAR,LINEAR,LINEAR, LIN, clamp,clamp) \
		DEF_AUTO_PARA(LocalLightScale, LOCALLIGHTSCALE	, float, (1.0)) \
		DEF_AUTO_PARA(GlobalLightScale, GLOBALLIGHTSCALE, float, (1.0))
#endif



//-------------------------------------------------------------------------------
// Shadows
//-------------------------------------------------------------------------------
#define USE_SHADOW_MAP \
	texture2D t_ShadowMap : SHADOW				\
	<											\
		string UIWidget = "None";				\
		string ResourceType = "2D";				\
	>;											\
	sampler2D s_ShadowMap : _xbox360Semantic_SHADOW <_NOUI> = sampler_state	\
	{												\
	    Texture = < t_ShadowMap > ;					\
		BorderColor = float4(1.0, 1.0, 1.0, 1.0);	\
	    MinFilter = LINEAR;							\
	    MagFilter = LINEAR;							\
	    MipFilter = LINEAR;							\
		AddressU = border; 							\
	    AddressV = border;							\
		SRGBTEXTURE = false;						\
	};

//-------------------------------------------------------------------------------
// dynamic damage
//-------------------------------------------------------------------------------
#define USE_ATTRIBUTES_MAP \
	DEF_AUTO_TEXTURE_ADV(AttributeBuffer, ATTRIBUTES, _2D, POINT,POINT,POINT,LIN,clamp,clamp)
	
#endif //EOF