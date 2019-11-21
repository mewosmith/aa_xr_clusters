//========= Copyright  1998-2007, EGOSOFT, All rights reserved. ============
//
// Property of EGOSOFT, dont use or redistribute without premission.
//===========================================================================

#ifndef _EGO_INCLUDES
#define _EGO_INCLUDES

#ifdef _3DSMAX_
	// Max2010 include error
	#include ".\inc\macros.fxh"
	#include "..\inc\macro_states.fxh"
	#include "..\inc\lighting_macros.fxh"
	#include "..\inc\utility_func.fxh"
	#include "..\inc\common_func_PS.fxh"
#else 
	//standard includes for all shaders 
	#include "inc\macros.fxh"
	#include "inc\macro_states.fxh"
	#include "inc\lighting_macros.fxh"
	// add includes
	#include "inc\utility_func.fxh"
	#include "inc\common_func_PS.fxh"
#endif

#endif // _EGO_INCLUDES
