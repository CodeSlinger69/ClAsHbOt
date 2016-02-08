// dllmain.cpp : Defines the entry point for the DLL application.
#include "stdafx.h"
#include "CGdiPlus.h"

BOOL APIENTRY DllMain( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
					 )
{
	switch (ul_reason_for_call)
	{
	case DLL_PROCESS_ATTACH:
		//MessageBox(NULL, L"DLL load", L"", MB_OK);
		break;
	case DLL_THREAD_ATTACH:
		break;
	case DLL_THREAD_DETACH:
		break;
	case DLL_PROCESS_DETACH:
		//MessageBox(NULL, L"DLL Unload", L"", MB_OK);
		CGdiPlus::Shutdown();
		break;
	}
	return TRUE;
}

