//========= Copyright  1998-2007, EGOSOFT, All rights reserved. ============
//
// Property of EGOSOFT, dont use or redistribute without premission.
//===========================================================================

#ifndef _EGO_MACRO
#define _EGO_MACRO


//ascii works in MAX
// \11 = Tab
// \40 = space
// \46 = &

// we scale back to get it in the 0.0-20.0 range after texture read!
#define LIGHTINTENSITY_SCALE 20.0f

//dont show any infos in the UI
//since max9 only look for the UIName we must redefine this token
#define _NOUI string UIWidget="None";

//we replace UIName with this placeholder token
#define _N None
#define _Y UIName
//switch from static flow control to none (max shader/fxcomposer vs engine)
#define _IF(x) if(x)
//#define _IF(x) if(true)

//preprocessor fix for fxcomposer #(arg1 ## arg2) was not working
#define TOSTRING(input) #input
#define _1D 1
#define _2D 2
#define _3D 3
#define _CUBE CUBE
//string "none" must be a char not space
#define _EMPTY .
#ifdef _XBOX
	// unused in Xbox case
	#define sRGB ;
	#define LIN ;
#else
	#define sRGB ;SRGBTEXTURE=true;
	#define LIN ;SRGBTEXTURE=false;
#endif

// Define different vFace for Xbox and PC
#ifdef _XBOX
	#define VFACESIGN(face) sign(face)
#else
	#define VFACESIGN(face) sign(-face)
#endif

//maxchannel defines (better readability for the defines)
#define _CH(channel) channel

#define _CULL_NONE 1

#ifdef _3DSMAX_
	#define _DIR_LIGHT "TargetLight"
	#define _POS_LIGHT "PointLight"
	#define _CAMERAPOSITION WORLDCAMERAPOSITION
	#define _DEFAULT_CULLMODE CW
	#define _LIGHTCOLOR LIGHTCOLOR
	//Max Semantic Postfix
	#define _MAP Map
	#define _DIFFUSE DiffuseMap
	// +1 "wrong" offset for Max coord 
	//TODO: get the mirroring correct ? (just needed for clamp/boarder sets)
	#define _TEX2(uv) float2(uv.x, 1.0 + uv.y)
	//paint case tex.xy + z = ID (0...1)
	#define _TEX3(uv) float3(uv.x, 1.0 + uv.y, uv.z)
#else
	#define _DIR_LIGHT "DirectionalLight"
	#define _POS_LIGHT "PointLight"
	#define _CAMERAPOSITION CAMERAPOSITION
	#define _DEFAULT_CULLMODE CW
	#define _LIGHTCOLOR LIGHTCOLOR
	// #define _LIGHTCOLOR DIFFUSE /* We need unique semantic names */
	#define _MAP ""
	#define _DIFFUSE DIFFUSE
	#define _TEX2(uv) (uv)
	#define _TEX3(uv) (uv)
#endif
//Macro to map internal maxcoords to shader texcoord input
//MAX has:
//			VertexColor 		MAP  0
//			VertexLuminosity 	MAP -1
//			VertexAlpha 		MAP -2

//use names insteed of numbers
#define _MAX_VERTEXCOLOR 0
#define _MAX_VERTEXALPHA -2
#define _MAX_VERTEXILLUMINATION -1

//map maxchannel 0 -> VertexColor to TexCoord
#define MAXMAP_TO_TEX(MaxChannel, TexCoord) \
	int texcoord##TexCoord : Texcoord		\
	<										\
		int Texcoord = TexCoord;			\
		int MapChannel = MaxChannel;		\
		string UIWidget = "None";			\
	>;										


// matrix inits

#define IDENTITY_4x4	\
	{1,0,0,0, 			\
	 0,1,0,0, 			\
	 0,0,1,0,			\
	 0,0,0,1}
	 
#define IDENTITY_3x3	\
	{1,0,0, 			\
	 0,1,0, 			\
	 0,0,1}

#define IDENTITY_3x2	\
	{1,0, 				\
	 0,1,				\
	 0,0}
	 

#define ZERO_4x4		\
	{0,0,0,0, 			\
	 0,0,0,0, 			\
	 0,0,0,0,			\
	 0,0,0,0}

#define ZERO_3x3		\
	{0,0,0, 			\
	 0,0,0, 			\
	 0,0,0}

// Macros to define shaderparameters
#define DEF_SWITCH(VarName,Semantic,StartRegister,InitValue,UIDescription) bool VarName : Semantic \
< string UIName = #UIDescription;> = InitValue;

#define DEFD_SWITCH(VarName,StartRegister,InitValue,UIDescription) bool VarName \
< string UIName = #UIDescription;> = InitValue;

//--------------------------------------------------------------------------------------
// variable Parameter creation macros
//--------------------------------------------------------------------------------------
// Merge this together with matrix
#define DEF_AUTO_PARA(VarName,Semantic,Type,InitValue) Type VarName	: Semantic  \
< string UIWidget = "None";> = InitValue;

#define DEF_PARA_UI(VarName,Semantic,Type,InitValue,LookupName,UIDescription,UI_WidgetType,UI_Min,UI_Max,UI_Step) \
	Type VarName : Semantic  							\
	< 	string UIName = UIDescription;						\
		string UIWidget = #UI_WidgetType;					\
		float UIMin = UI_Min;								\
		float UIMax = UI_Max;								\
		float UIStep = UI_Step;								\
		string ExportName = #LookupName;					\
		bool Export = true;									\
	> = InitValue;

#define DEFD_PARA_UI(VarName,Semantic,Type,InitValue,UIDescription,UI_WidgetType,UI_Min,UI_Max,UI_Step) \
	Type VarName : Semantic  							\
< 	string UIName = #UIDescription;						\
	string UIWidget = #UI_WidgetType;					\
	float UIMin = UI_Min;								\
	float UIMax = UI_Max;								\
	float UIStep = UI_Step;								\
> = InitValue;

#define DEF_HUE_UI(Exportable,Variation,VarName,LookupName,iBrigh,iCon,iSat,iHue,_Animation,UIDescription) \
	float VarName##Brightness : HUE					\
< 	string UIName = TOSTRING(UIDescription Brightness);	\
	string UIWidget = "SLIDER";							\
	float UIMin = 0.0;									\
	float UIMax = 10.0;									\
	float UIStep = 0.01;								\
	string ExportName = TOSTRING(LookupName##_brightness_shift);	\
	bool Export = Exportable;							\
	bool AutoVariation = Variation;						\
	string Animation = _Animation;						\
> = iBrigh;											\
	float VarName##Contrast : HUE						\
< 	string UIName = TOSTRING(UIDescription Contrast);	\
	string UIWidget = "SLIDER";							\
	float UIMin = 0.0;									\
	float UIMax = 10.0;									\
	float UIStep = 0.01;								\
	string ExportName = TOSTRING(LookupName##_contrast_shift);	\
	bool Export = Exportable;							\
	bool AutoVariation = Variation;						\
	string Animation = _Animation;						\
> = iCon;											\
	float VarName##Saturation : HUE						\
< 	string UIName = TOSTRING(UIDescription Saturation);	\
	string UIWidget = "SLIDER";							\
	float UIMin = 0.0;									\
	float UIMax = 10.0;									\
	float UIStep = 0.01;								\
	string ExportName = TOSTRING(LookupName##_saturation_shift);	\
	bool Export = Exportable;							\
	bool AutoVariation = Variation;						\
	string Animation = _Animation;						\
> = iSat;											\
	float VarName##Hue : HUE							\
< 	string UIName = TOSTRING(UIDescription Hue);		\
	string UIWidget = "SLIDER";							\
	float UIMin = 0.0;									\
	float UIMax = 360.0;								\
	float UIStep = 1.0;									\
	string ExportName = TOSTRING(LookupName##_hue_shift);	\
	bool Export = Exportable;							\
	bool AutoVariation = Variation;						\
	string Animation = _Animation;						\
> = iHue;

//dynamic MAX dir light
// IMPORTAND: Max premultiplies the color with the multi value, this means todo correct sRGB lighting we first have to undo this step do srgb->lin and apply the multiply again.
// NOTE: Only for transparent light calculation in linear space this is not needed.
#define DEF_LIGHT_DIRECTIONAL(VarName,LookupName,StartRegister,InitValueDir,InitValueColor,InitMulti,UIDescription,_NR,_REFID) \
	float3 VarName##_Dir_##_NR : DIRECTION	 					\
	<	string UIName = TOSTRING(Dir UIDescription _NR);		\
 		string ExportName = TOSTRING(LookupName##_NR##_direction);	\
		string Object = _DIR_LIGHT;								\
		string Space = "World";									\
		int RefID = _REFID;										\
	> = InitValueDir;											\
	float3 VarName##_Color_##_NR : _LIGHTCOLOR					\
	<															\
		string UIWidget = "None";								\
		string ExportName = TOSTRING(LookupName##_NR##_color);	\
		int LightRef = _REFID;									\
	> = InitValueColor;											\
	/* HDR Exponent/Multiplyer */								\
	float VarName##_Ex_##_NR									\
	<															\
		string UIName = TOSTRING(Multiply UIDescription _NR);	\
		string ExportName = TOSTRING(LookupName##_NR##_ex);		\
	> = InitMulti;


// simple point light
#define DEF_LIGHT_POSITIONAL(VarName,LookupName,StartRegister,InitValuePos,InitValueColor,InitMulti,InitValueAtten,UIDescription,_NR,_REFID) \
	float3 VarName##_Pos_##_NR : POSITION						\
	<															\
		string UIName = TOSTRING(Pos UIDescription _NR);		\
		string ExportName = TOSTRING(LookupName##_REFID##_position); \
		string Object = _POS_LIGHT;								\
		string Space = "World";									\
		int refID = _REFID;										\
	> = InitValuePos;											\
	/* use alpha as HDR scale */								\
	float3 VarName##_Color_##_NR : _LIGHTCOLOR					\
	<															\
		string UIWidget = "None";								\
		string ExportName = TOSTRING(LookupName##_NR##_color);	\
		int LightRef = _REFID;									\
	> = InitValueColor;											\
	/* attenuation quadratic */									\
	float VarName##_Att_##_NR	 								\
	<															\
		string UIName = TOSTRING(Att UIDescription _NR);		\
		string ExportName = TOSTRING(LookupName##_NR##_att);	\
		int LightRef = _REFID;									\
	> = InitValueAtten;											\
	/* HDR Exponent/Multiplyer */								\
	float VarName##_Ex_##_NR	 								\
	<															\
		string UIName = TOSTRING(Multiply UIDescription _NR);\
		string ExportName = TOSTRING(LookupName##_NR##_ex);	\
	> = InitMulti;

#ifdef _3DSMAX_
	// max compatible light definition of a linear calced light (no sRGB correction)
	#define DEF_LIGHT_DIR(_NR)										\
		float3 DirLight_Dir_##_NR : DIRECTION	 					\
		<	string UIName = TOSTRING(DirLight _NR);					\
			string Object = _DIR_LIGHT;								\
			string Space = "World";									\
			int RefID = _NR - 1;									\
		>;															\
		float4 DirLight_ColorEx_##_NR  : _LIGHTCOLOR				\
		<															\
			string UIWidget = "None";								\
			int LightRef = _NR - 1;									\
		>;
#else
	#define DEF_LIGHT_DIR(_NR) \
		float4 DirLight_Dir_##_NR : DIRECTION##_NR					\
		<															\
			string UIWidget = "None";								\
			string Object = _DIR_LIGHT;								\
			string Space = "World";									\
		>;															\
		/* use alpha as HDR scale */								\
		float4 DirLight_ColorEx_##_NR : LIGHTCOLOR##_NR				\
		<															\
			string UIWidget = "None";								\
		>;
#endif
	
#define DEF_LIGHT_AMBIENT(_NR)	\
	float4 AmbientLight_ColorEx_##_NR : AMBIENT##_NR \
	<											\
		string UIName = "AmbientColor";			\
		string UIWidget = "COLORSWATCH";		\
	>;

//--------------------------------------------------------------------------------------
// variable Texture/Sampler creation macros
//--------------------------------------------------------------------------------------

//IMPORTAND NOTE:
// we "staticly" setup texture filtering per layer, based on test (quality/perf)
// the user dont know what anisotrop filtering is exactly and how it influence performance/quality
// we have 2007 so even having a option to switch texture filtering back to "linear" makes no sence
// it also makes never sence to set the anisotrop level > 8 (quality wise)
// better spend performance for other features!

// Bottomline we dont have a setable texture filtering mode! (saves set calls and more robust)
// d3d will fallback to linear filtering anyway if anisotrop is not supported (very unlikly (S3 cards?))

//default 2D Texture + Sampler decl, this version is automatically set by teh engine via semantic.
#define DEF_AUTO_TEXTURE(TexName,Semantic,TexType,FilterTypeMin,FilterTypeMag,FilterTypeMip,SRGBDEF) \
	texture##TexType##D t_##TexName : Semantic	\
	<											\
		string UIWidget = "None";				\
		string ResourceType = TOSTRING(TexType);\
	>;											\
	sampler##TexType##D s_##TexName : _xbox360Semantic_##Semantic <_NOUI> = sampler_state	\
	{											\
	    Texture = < t_##TexName > ;				\
	    MinFilter = FilterTypeMin;				\
	    MagFilter = FilterTypeMag;				\
	    MipFilter = FilterTypeMip;				\
		AddressU = Wrap; /* this is again crappy, since we have to reset it for every layer just because we have a few clamp cases! */	\
	    AddressV = Wrap;						\
	    AddressW = Clamp;						\
	    MAXANISOTROPY = 2						\
	   	SRGBDEF									\
	};

#define DEF_AUTO_TEXTURE_CUBE(TexName,Semantic,FilterTypeMin,FilterTypeMag,FilterTypeMip,SRGBDEF) \
	textureCUBE t_##TexName : Semantic	\
	<											\
		string UIWidget = "None";				\
		string ResourceType = "CUBE";\
	>;											\
	samplerCUBE s_##TexName : _xbox360Semantic_##Semantic <_NOUI> = sampler_state	\
	{											\
	    Texture = < t_##TexName > ;				\
	    MinFilter = FilterTypeMin;				\
	    MagFilter = FilterTypeMag;				\
	    MipFilter = FilterTypeMip;				\
		AddressU = Wrap; /* this is again crappy, since we have to reset it for every layer just because we have a few clamp cases! */	\
	    AddressV = Wrap;						\
	    MAXANISOTROPY = 2						\
	   	SRGBDEF									\
	};
	
#define DEF_AUTO_TEXTURE_ADV(TexName,Semantic,TexType,FilterTypeMin,FilterTypeMag,FilterTypeMip,SRGBDEF,AdressMode_U,AdressMode_V) \
	texture##TexType##D t_##TexName : Semantic	\
	<											\
		string UIWidget = "None";				\
		string ResourceType = TOSTRING(TexType);\
	>;											\
	sampler##TexType##D s_##TexName : _xbox360Semantic_##Semantic <_NOUI> = sampler_state	\
	{											\
	    Texture = < t_##TexName > ;				\
	    MinFilter = FilterTypeMin;				\
	    MagFilter = FilterTypeMag;				\
	    MipFilter = FilterTypeMip;				\
		AddressU = AdressMode_U; 				\
	    AddressV = AdressMode_V;				\
	    AddressW = Clamp;						\
	    MAXANISOTROPY = 2						\
	   	SRGBDEF									\
	};
	
//default 2D Texture + Sampler decl (extra info)
#define DEF_TEXTURE_ADV(TexName,Semantic,TexType,FilterTypeMin,FilterTypeMag,FilterTypeMip,SRGBDEF,AdressMode_U,AdressMode_V,LookupName,UIDescription,DefaultTexture) \
	texture##TexType##D t_##TexName : Semantic		\
	<												\
		string UIName = UIDescription ;				\
		string ExportName = #LookupName;			\
		string ResourceType = TOSTRING(TexType);	\
		string name = DefaultTexture;				\
		string resourcename = DefaultTexture;		\
		bool Export = true;							\
	>;												\
	sampler##TexType##D s_##TexName : _xbox360Semantic_##Semantic##__##LookupName <_NOUI> = sampler_state	\
	{												\
	    Texture = < t_##TexName > ;					\
	    MinFilter = FilterTypeMin;					\
	    MagFilter = FilterTypeMag;					\
	    MipFilter = FilterTypeMip;					\
	    AddressU = AdressMode_U;					/* this is a problem, since we dont reset those back to default wrap everytime! */ \
	    AddressV = AdressMode_V;				 	/* so make sure everytime we use this specialcase reset it back to wrap via a reset pass */ \
	   	MAXANISOTROPY = 2							\
	   	SRGBDEF										\
	};
	
//NOTE: we use Max9 Texture Semantics for Texture identifications! (for fxcomposer it dont realy matter)
//Example "Diffuse" = DiffuseMap
//NOTE: max hides parameters only if there is no UIName annotation, UIWidget = "none" wont work!
// We also give every "layer" parameter the same lookupname, so we can identify which parameter belong to which layer. 

//defines a standard layer (a texture + sampler, a bool, a Str value, a default color value) all based on layer name!	 DEFAULT
#define DEF_LAYER_S(bUI,tUI,cUI,fUI,tileUI,TexExport,StrExport,TileExport,TexType,vShaderParaName,Semantic,StrDefaultValue,DefaultColor,DefaultTiling,MaxMapChannel,FilterTypeMin,SRGBDEF,LayerLookupName,UILayerName,DefaultTexture) \
	bool b##vShaderParaName : Semantic						\
	< 														\
		string bUI = TOSTRING(UseMap_in_Channel:##\MaxMapChannel);	\
	> = false;												\
	texture##TexType##D t_##vShaderParaName : Semantic		\
	<														\
		string tUI = #UILayerName;							\
		string name = DefaultTexture;						\
		string resourcename = DefaultTexture;				\
		string ExportName = TOSTRING(LayerLookupName##_map);\
		string ResourceType = TOSTRING(TexType##d);			\
		bool Export = TexExport;							\
	>;														\
	sampler##TexType##D s_##vShaderParaName : _xbox360Semantic_##Semantic##__##LayerLookupName##_map <_NOUI> = sampler_state	\
	{											\
	    Texture = < t_##vShaderParaName > ;		\
	    MinFilter = FilterTypeMin;				\
	    MagFilter = LINEAR;						\
	    MipFilter = LINEAR;						\
		MipMapLodBias = 0.025;					\
		AddressU = Wrap; /* this is again crappy, since we have to reset it for every layer just because we have a few clamp cases! */	\
	    AddressV = Wrap;						\
		MAXANISOTROPY = 2						\
	   	SRGBDEF									\
	};											\
	float4 vShaderParaName##Color : Semantic##_color \
	<											\
	     string cUI = TOSTRING(UILayerName##\Color);\
	     string UIWidget = "COLORSWATCH";		\
    >  = DefaultColor;							\
	float vShaderParaName##Tiling : Semantic##_u /* keep old shadername for compatibility */ \
	<											\
		string tileUI = TOSTRING(UILayerName##\Tiling_u);	\
		string ExportName = TOSTRING(LayerLookupName##_tiling); /* keep old exportname for compatibility! */ \
		float UIMin = 1;							\
		float UIMax = 500;							\
		float UIStep = 1;							\
		bool Export = TileExport;					\
	> = DefaultTiling;								\
	float vShaderParaName##Tiling_v : Semantic##_v	\
	<												\
		string tileUI = TOSTRING(UILayerName##\Tiling_v);	\
		string ExportName = TOSTRING(LayerLookupName##_tiling_v);\
		float UIMin = 1;							\
		float UIMax = 500;							\
		float UIStep = 1;							\
		bool Export = TileExport;					\
	> = DefaultTiling;								\
	float vShaderParaName##Str : Semantic			\
	< 												\
		string fUI = TOSTRING(UILayerName##\Str);	\
		string ExportName = TOSTRING(LayerLookupName##Str);	\
	    string UIWidget = "SLIDER";					\
		float UIMin = 0;							\
		float UIMax = 100;							\
		float UIStep = 0.01;						\
		bool Export = StrExport;					\
	> = StrDefaultValue;

	
//defines a standard layer (a texture + sampler, a bool, a Str value, a default color value) all based on layer name!	 DEFAULT
#define DEF_LAYER_S_CHAR(bUI,tUI,cUI,fUI,tileUI,TexExport,StrExport,TileExport,TexType,vShaderParaName,Semantic,StrDefaultValue,DefaultColor,DefaultTiling,MaxMapChannel,FilterTypeMin,SRGBDEF,LayerLookupName,UILayerName,DefaultTexture) \
	bool b##vShaderParaName : Semantic						\
	< 														\
		string bUI = TOSTRING(UseMap_in_Channel:##\MaxMapChannel);	\
	> = false;												\
	texture##TexType##D t_##vShaderParaName : Semantic		\
	<														\
		string tUI = #UILayerName;							\
		string name = DefaultTexture;						\
		string resourcename = DefaultTexture;				\
		string ExportName = TOSTRING(LayerLookupName##_map);\
		string ResourceType = TOSTRING(TexType##d);			\
		bool Export = TexExport;							\
	>;														\
	sampler##TexType##D s_##vShaderParaName : _xbox360Semantic_##Semantic##__##LayerLookupName##_map <_NOUI> = sampler_state	\
	{											\
	    Texture = < t_##vShaderParaName > ;		\
	    MinFilter = FilterTypeMin;				\
	    MagFilter = LINEAR;						\
	    MipFilter = LINEAR;						\
		MipMapLodBias = 0.0;					\
		AddressU = Wrap; /* this is again crappy, since we have to reset it for every layer just because we have a few clamp cases! */	\
	    AddressV = Wrap;						\
		MAXANISOTROPY = 2						\
	   	SRGBDEF									\
	};											\
	float4 vShaderParaName##Color : Semantic##_color \
	<											\
	     string cUI = TOSTRING(UILayerName##\Color);\
	     string UIWidget = "COLORSWATCH";		\
    >  = DefaultColor;							\
	float vShaderParaName##Tiling : Semantic##_u /* keep old shadername for compatibility */ \
	<											\
		string tileUI = TOSTRING(UILayerName##\Tiling_u);	\
		string ExportName = TOSTRING(LayerLookupName##_tiling); /* keep old exportname for compatibility! */ \
		float UIMin = 1;							\
		float UIMax = 500;							\
		float UIStep = 1;							\
		bool Export = TileExport;					\
	> = DefaultTiling;								\
	float vShaderParaName##Tiling_v : Semantic##_v	\
	<												\
		string tileUI = TOSTRING(UILayerName##\Tiling_v);	\
		string ExportName = TOSTRING(LayerLookupName##_tiling_v);\
		float UIMin = 1;							\
		float UIMax = 500;							\
		float UIStep = 1;							\
		bool Export = TileExport;					\
	> = DefaultTiling;								\
	float vShaderParaName##Str : Semantic			\
	< 												\
		string fUI = TOSTRING(UILayerName##\Str);	\
		string ExportName = TOSTRING(LayerLookupName##Str);	\
	    string UIWidget = "SLIDER";					\
		float UIMin = 0;							\
		float UIMax = 100;							\
		float UIStep = 0.01;						\
		bool Export = StrExport;					\
	> = StrDefaultValue;



//defines a standard layer (a texture + sampler, a bool, a Str value, a default color value) all based on layer name!	 DEFAULT + CLAMP!
#define DEF_LAYER_SCLAMP(bUI,tUI,cUI,fUI,tileUI,TexExport,StrExport,TileExport,TexType,vShaderParaName,Semantic,StrDefaultValue,DefaultColor,DefaultTiling,MaxMapChannel,FilterTypeMin,SRGBDEF,LayerLookupName,UILayerName,DefaultTexture) \
	bool b##vShaderParaName : Semantic						\
	< 														\
		string bUI = TOSTRING(UseMap_in_Channel:##\MaxMapChannel);	\
	> = false;												\
	texture##TexType##D t_##vShaderParaName : Semantic		\
	<														\
		string tUI = #UILayerName;							\
		string name = DefaultTexture;						\
		string resourcename = DefaultTexture;				\
		string ExportName = TOSTRING(LayerLookupName##_map);\
		string ResourceType = TOSTRING(TexType##d);			\
		bool Export = TexExport;							\
	>;														\
	sampler##TexType##D s_##vShaderParaName : _xbox360Semantic_##Semantic##__##LayerLookupName##_map <_NOUI> = sampler_state	\
	{											\
	    Texture = < t_##vShaderParaName > ;		\
	    MinFilter = FilterTypeMin;				\
	    MagFilter = LINEAR;						\
	    MipFilter = LINEAR;						\
		MipMapLodBias = 0.0;					\
		AddressU = Clamp; /* this is again crappy, since we have to reset it for every layer just because we have a few clamp cases! */	\
	    AddressV = Clamp;						\
		MAXANISOTROPY = 2						\
	   	SRGBDEF									\
	};											\
	float4 vShaderParaName##Color : Semantic##_color \
	<											\
	     string cUI = TOSTRING(UILayerName##\Color);\
	     string UIWidget = "COLORSWATCH";		\
    >  = DefaultColor;							\
	float vShaderParaName##Tiling : Semantic##_u /* keep old shadername for compatibility */ \
	<											\
		string tileUI = TOSTRING(UILayerName##\Tiling_u);	\
		string ExportName = TOSTRING(LayerLookupName##_tiling); /* keep old exportname for compatibility! */ \
		float UIMin = 1;							\
		float UIMax = 500;							\
		float UIStep = 1;							\
		bool Export = TileExport;					\
	> = DefaultTiling;								\
	float vShaderParaName##Tiling_v : Semantic##_v	\
	<												\
		string tileUI = TOSTRING(UILayerName##\Tiling_v);	\
		string ExportName = TOSTRING(LayerLookupName##_tiling_v);\
		float UIMin = 1;							\
		float UIMax = 500;							\
		float UIStep = 1;							\
		bool Export = TileExport;					\
	> = DefaultTiling;								\
	float vShaderParaName##Str : Semantic			\
	< 												\
		string fUI = TOSTRING(UILayerName##\Str);	\
		string ExportName = TOSTRING(LayerLookupName##Str);	\
	    string UIWidget = "SLIDER";					\
		float UIMin = 0;							\
		float UIMax = 100;							\
		float UIStep = 0.01;						\
		bool Export = StrExport;					\
	> = StrDefaultValue;
		
//defines a UI layer (implying point texture filtering) (a texture + sampler, a bool, a Str value, a default color value) all based on layer name!	 DEFAULT
#define DEF_LAYER_UI_UNFILTERED(bUI,tUI,cUI,fUI,tileUI,TexExport,StrExport,TileExport,TexType,vShaderParaName,Semantic,StrDefaultValue,DefaultColor,DefaultTiling,MaxMapChannel,SRGBDEF,LayerLookupName,UILayerName,DefaultTexture) \
	bool b##vShaderParaName : Semantic						\
	< 														\
		string bUI = TOSTRING(UseMap_in_Channel:##\MaxMapChannel);	\
	> = false;												\
	texture##TexType##D t_##vShaderParaName : Semantic		\
	<														\
		string tUI = #UILayerName;							\
		string name = DefaultTexture;						\
		string resourcename = DefaultTexture;				\
		string ExportName = TOSTRING(LayerLookupName##_map);\
		string ResourceType = TOSTRING(TexType##d);			\
		bool Export = TexExport;							\
	>;														\
	sampler##TexType##D s_##vShaderParaName : _xbox360Semantic_##Semantic##__##LayerLookupName##_map <_NOUI> = sampler_state	\
	{											\
	    Texture = < t_##vShaderParaName > ;		\
	    MinFilter = NONE;				\
	    MagFilter = NONE;						\
	    MipFilter = NONE;						\
		MipMapLodBias = 0.025;					\
		AddressU = Wrap; /* this is again crappy, since we have to reset it for every layer just because we have a few clamp cases! */	\
	    AddressV = Wrap;						\
		MAXANISOTROPY = 2						\
	   	SRGBDEF									\
	};											\
	float4 vShaderParaName##Color : Semantic##_color \
	<											\
	     string cUI = TOSTRING(UILayerName##\Color);\
	     string UIWidget = "COLORSWATCH";		\
    >  = DefaultColor;							\
	float vShaderParaName##Tiling : Semantic##_u /* keep old shadername for compatibility */ \
	<											\
		string tileUI = TOSTRING(UILayerName##\Tiling_u);	\
		string ExportName = TOSTRING(LayerLookupName##_tiling); /* keep old exportname for compatibility! */ \
		float UIMin = 1;							\
		float UIMax = 500;							\
		float UIStep = 1;							\
		bool Export = TileExport;					\
	> = DefaultTiling;								\
	float vShaderParaName##Tiling_v : Semantic##_v	\
	<												\
		string tileUI = TOSTRING(UILayerName##\Tiling_v);	\
		string ExportName = TOSTRING(LayerLookupName##_tiling_v);\
		float UIMin = 1;							\
		float UIMax = 500;							\
		float UIStep = 1;							\
		bool Export = TileExport;					\
	> = DefaultTiling;								\
	float vShaderParaName##Str : Semantic			\
	< 												\
		string fUI = TOSTRING(UILayerName##\Str);	\
		string ExportName = TOSTRING(LayerLookupName##Str);	\
	    string UIWidget = "SLIDER";					\
		float UIMin = 0;							\
		float UIMax = 100;							\
		float UIStep = 0.01;						\
		bool Export = StrExport;					\
	> = StrDefaultValue;

//defines a standard layer (a texture + sampler, a bool, a Str value, a default color value) all based on layer name!	BUMP
#define DEF_LAYER_B(bUI,tUI,cUI,fUI,tileUI,TexExport,StrExport,TileExport,TexType,vShaderParaName,Semantic,StrDefaultValue,DefaultColor,DefaultTiling,MaxMapChannel,FilterTypeMin,SRGBDEF,LayerLookupName,UILayerName,DefaultTexture) \
	bool b##vShaderParaName : Semantic						\
	< 														\
		string bUI = TOSTRING(UseMap_in_Channel:##\MaxMapChannel);	\
	> = false;												\
	texture##TexType##D t_##vShaderParaName : Semantic		\
	<														\
		string tUI = #UILayerName;							\
		string name = DefaultTexture;						\
		string resourcename = DefaultTexture;				\
		string ExportName = TOSTRING(LayerLookupName##_map);\
		string ResourceType = TOSTRING(TexType##d);			\
		bool Export = TexExport;							\
	>;														\
	sampler##TexType##D s_##vShaderParaName : _xbox360Semantic_##Semantic##__##LayerLookupName##_map <_NOUI> = sampler_state	\
	{											\
	    Texture = < t_##vShaderParaName > ;		\
	    MinFilter = LINEAR;				\
	    MagFilter = LINEAR;				\
	    MipFilter = LINEAR;				\
		MipMapLodBias = 0.15;					\
		AddressU = Wrap; /* this is again crappy, since we have to reset it for every layer just because we have a few clamp cases! */	\
	    AddressV = Wrap;						\
		MAXANISOTROPY = 2						\
	   	SRGBDEF									\
	};											\
	float4 vShaderParaName##Color : Semantic##_color \
	<											\
	     string cUI = TOSTRING(UILayerName##\Color);\
	     string UIWidget = "COLORSWATCH";		\
    >  = DefaultColor;							\
	float vShaderParaName##Tiling : Semantic##_u /* keep old shadername for compatibility */ \
	<											\
		string tileUI = TOSTRING(UILayerName##\Tiling_u);	\
		string ExportName = TOSTRING(LayerLookupName##_tiling); /* keep old exportname for compatibility! */ \
		float UIMin = 1;							\
		float UIMax = 500;							\
		float UIStep = 1;							\
		bool Export = TileExport;					\
	> = DefaultTiling;								\
	float vShaderParaName##Tiling_v : Semantic##_v	\
	<												\
		string tileUI = TOSTRING(UILayerName##\Tiling_v);	\
		string ExportName = TOSTRING(LayerLookupName##_tiling_v);\
		float UIMin = 1;							\
		float UIMax = 500;							\
		float UIStep = 1;							\
		bool Export = TileExport;					\
	> = DefaultTiling;								\
	float vShaderParaName##Str : Semantic			\
	< 												\
		string fUI = TOSTRING(UILayerName##\Str);	\
		string ExportName = TOSTRING(LayerLookupName##Str);	\
	    string UIWidget = "SLIDER";					\
		float UIMin = 0;							\
		float UIMax = 100;							\
		float UIStep = 0.15;						\
		bool Export = StrExport;					\
	> = StrDefaultValue;


//defines a standard layer (a texture + sampler, a bool, a Str value, a default color value) all based on layer name!	SPECULAR
#define DEF_LAYER_SP(bUI,tUI,cUI,fUI,tileUI,TexExport,StrExport,TileExport,TexType,vShaderParaName,Semantic,StrDefaultValue,DefaultColor,DefaultTiling,MaxMapChannel,FilterTypeMin,SRGBDEF,LayerLookupName,UILayerName,DefaultTexture) \
	bool b##vShaderParaName : Semantic						\
	< 														\
		string bUI = TOSTRING(UseMap_in_Channel:##\MaxMapChannel);	\
	> = false;												\
	texture##TexType##D t_##vShaderParaName : Semantic		\
	<														\
		string tUI = #UILayerName;							\
		string name = DefaultTexture;						\
		string resourcename = DefaultTexture;				\
		string ExportName = TOSTRING(LayerLookupName##_map);\
		string ResourceType = TOSTRING(TexType##d);			\
		bool Export = TexExport;							\
	>;														\
	sampler##TexType##D s_##vShaderParaName : _xbox360Semantic_##Semantic##__##LayerLookupName##_map <_NOUI> = sampler_state	\
	{											\
	    Texture = < t_##vShaderParaName > ;		\
	    MinFilter = ANISOTROPIC;				\
	    MagFilter = LINEAR;				\
	    MipFilter = LINEAR;				\
		MipMapLodBias = 0.01;					\
		AddressU = Wrap; /* this is again crappy, since we have to reset it for every layer just because we have a few clamp cases! */	\
	    AddressV = Wrap;						\
		MAXANISOTROPY = 2						\
	   	SRGBDEF									\
	};											\
	float4 vShaderParaName##Color : Semantic##_color \
	<											\
	     string cUI = TOSTRING(UILayerName##\Color);\
	     string UIWidget = "COLORSWATCH";		\
    >  = DefaultColor;							\
	float vShaderParaName##Tiling : Semantic##_u /* keep old shadername for compatibility */ \
	<											\
		string tileUI = TOSTRING(UILayerName##\Tiling_u);	\
		string ExportName = TOSTRING(LayerLookupName##_tiling); /* keep old exportname for compatibility! */ \
		float UIMin = 1;							\
		float UIMax = 500;							\
		float UIStep = 1;							\
		bool Export = TileExport;					\
	> = DefaultTiling;								\
	float vShaderParaName##Tiling_v : Semantic##_v	\
	<												\
		string tileUI = TOSTRING(UILayerName##\Tiling_v);	\
		string ExportName = TOSTRING(LayerLookupName##_tiling_v);\
		float UIMin = 1;							\
		float UIMax = 500;							\
		float UIStep = 1;							\
		bool Export = TileExport;					\
	> = DefaultTiling;								\
	float vShaderParaName##Str : Semantic			\
	< 												\
		string fUI = TOSTRING(UILayerName##\Str);	\
		string ExportName = TOSTRING(LayerLookupName##Str);	\
	    string UIWidget = "SLIDER";					\
		float UIMin = 0;							\
		float UIMax = 100;							\
		float UIStep = 0.05;						\
		bool Export = StrExport;					\
	> = StrDefaultValue;




//cubemap version (Problem: token (Number + String) not possible = 1D,2D wont work ENVIRONMENT
#define DEF_LAYER_C(bUI,tUI,cUI,fUI,tileUI,TexExport,StrExport,TileExport,TexType,vShaderParaName,Semantic,StrDefaultValue,DefaultColor,DefaultTiling,MaxMapChannel,FilterTypeMin,SRGBDEF,LayerLookupName,UILayerName,DefaultTexture) \
	bool b##vShaderParaName	: Semantic						\
	< 														\
		string bUI = TOSTRING(UseMap_in_Channel:##\MaxMapChannel);	\
	> = false;												\
	texture##TexType t_##vShaderParaName : Semantic			\
	<														\
		string tUI = #UILayerName;							\
		string name = DefaultTexture;						\
		string resourcename = DefaultTexture;				\
		string ExportName = TOSTRING(LayerLookupName##_map);\
		string ResourceType = TOSTRING(TexType);			\
		bool Export = TexExport;							\
	>;														\
	sampler##TexType s_##vShaderParaName : _xbox360Semantic_##Semantic##__##LayerLookupName##_map <_NOUI> = sampler_state	\
	{											\
	    Texture = < t_##vShaderParaName > ;		\
	    MinFilter = FilterTypeMin;				\
	    MagFilter = LINEAR;						\
	    MipFilter = LINEAR;						\
		AddressU = Wrap; /* this is again crappy, since we have to reset it for every layer just because we have a few clamp cases! */	\
	    AddressV = Wrap;						\
	    MAXANISOTROPY = 1						\
	   	SRGBDEF									\
	};											\
	float4 vShaderParaName##Color : Semantic##_color	\
	<											\
	     string cUI = TOSTRING(UILayerName##\Color);\
	     string UIWidget = "COLORSWATCH";		\
    >   = DefaultColor;							\
	float vShaderParaName##Tiling : Semantic##_u /* keep old shadername for compatibility */ \
	<											\
		string tileUI = TOSTRING(UILayerName##\Tiling_u);	\
		string ExportName = TOSTRING(LayerLookupName##_tiling); /* keep old exportname for compatibility! */ \
		float UIMin = 1;							\
		float UIMax = 500;							\
		float UIStep = 1;							\
		bool Export = TileExport;					\
	> = DefaultTiling;								\
	float vShaderParaName##Tiling_v : Semantic##_v	\
	<												\
		string tileUI = TOSTRING(UILayerName##\Tiling_v);	\
		string ExportName = TOSTRING(LayerLookupName##_tiling_v);\
		float UIMin = 1;							\
		float UIMax = 500;							\
		float UIStep = 1;							\
		bool Export = TileExport;					\
	> = DefaultTiling;								\
	float vShaderParaName##Str : Semantic			\
	< 												\
		string fUI = TOSTRING(UILayerName##\Str);	\
		string ExportName = TOSTRING(LayerLookupName##Str);	\
		string UIWidget = "SLIDER";					\
		float UIMin = 0;							\
		float UIMax = 10;							\
		float UIStep = 0.05;						\
		bool Export = StrExport;					\
	> = StrDefaultValue;


// technique macros

#if defined(_3DSMAX_) || defined(fxcomposer)
	#define DEF_TECHNIQUE(name,vertexinputname,vs_func,ps_func,blendmode,renderstates) \
		technique name <		string Script = "Pass=p0;"; 					\
								string VertexInput = #vertexinputname ; >		\
		{																		\
    		pass p0 < string Script = "Draw=geometry;" ;> {						\
        		VertexShader = compile vs_3_0 vs_func##();						\
        		PixelShader  = compile ps_3_0 ps_func##();						\
       			renderstates													\
       			blendmode														\
   			}																	\
		}
		
#else
	#define DEF_TECHNIQUE(name, vs_func, ps_func) 								\
		technique name 															\
		{																		\
    		pass p0 {															\
        		VertexShader = compile vs_3_0 vs_func##();						\
        		PixelShader  = compile ps_3_0 ps_func##();						\
   			}																	\
		}
	
#endif


#endif //EOF