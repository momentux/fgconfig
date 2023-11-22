/****************************************
- Init the device
- Set RTs to simulate response
- Create buslist with 1 message BC2RT
- Start buslist, run once
- Update message's data
- Restart the same bus list
****************************************/


#include "stdafx.h"
#include <stdio.h>
#include <stdlib.h>
#include "windows.h"
#include "McxAPI.h"
#include "McxAPIReturnCodes.h"

INT16 iResult = 0;
UINT16 DeviceId = 0;
char errorCode[1000];
static UINT16 BusList1 = 0;
static UINT16 Element1 = 0;
static UINT16 DB1 = 0;

#pragma comment(lib, "McxAPI")

int main()
{
	UINT16 datablock32[64];
	iResult = mcx_Initialize(DeviceId, MIL_STD_1553_AND_PP194);
	if (iResult < 0) {
		mcx_GetReturnCodeDescription(iResult, errorCode);
		printf("Error -> %s\n", errorCode);
		return -1;
	}

	UINT16 messageOptions = 0;
	UINT16 cmd1 = 0x3020; // BC2RT6 32WC

	iResult = mcx_EnableRts(DeviceId, 0x7FFFFFFF); // Enable all RTs
	if (iResult < 0) {
		mcx_GetReturnCodeDescription(iResult, errorCode);
		printf("Error -> %s\n", errorCode);
		return -1;
	}

	for (UINT16 i = 0x0000; i < 32; i++)
	{
		datablock32[i] = i;
	}

	iResult = mcx_Create_BusList(DeviceId, BusList1);
	if (iResult < 0) {
		mcx_GetReturnCodeDescription(iResult, errorCode);
		printf("Error -> %s\n", errorCode);
		return -1;
	}
	iResult = mcx_Create_BusList_Element(DeviceId, Element1, cmd1, 0x80 /*Bus A*/ | messageOptions, 0x0000, 0, 0);
	if (iResult < 0) {
		mcx_GetReturnCodeDescription(iResult, errorCode);
		printf("Error -> %s\n", errorCode);
		return -1;
	}
	iResult = mcx_Create_Element_DataBlock(DeviceId, DB1, 0, datablock32, 64);
	if (iResult < 0) {
		mcx_GetReturnCodeDescription(iResult, errorCode);
		printf("Error -> %s\n", errorCode);
		return -1;
	}
	iResult = mcx_Map_DataBlock_To_Element(DeviceId, Element1, DB1);
	if (iResult < 0) {
		mcx_GetReturnCodeDescription(iResult, errorCode);
		printf("Error -> %s\n", errorCode);
		return -1;
	}
	iResult = mcx_Map_Element_To_BusList(DeviceId, BusList1, Element1);
	if (iResult < 0) {
		mcx_GetReturnCodeDescription(iResult, errorCode);
		printf("Error -> %s\n", errorCode);
		return -1;
	}
	iResult = mcx_Start(DeviceId, BusList1, 1);
	if (iResult < 0) {
		mcx_GetReturnCodeDescription(iResult, errorCode);
		printf("Error -> %s\n", errorCode);
		return -1;
	}

	// Updating data
	for (UINT16 i = 0x0000; i < 32; i++)
	{
		datablock32[i] = i + 32;
	}

	iResult = mcx_Restart(DeviceId, BusList1);
	if (iResult < 0) {
		mcx_GetReturnCodeDescription(iResult, errorCode);
		printf("Error -> %s\n", errorCode);
		return -1;
	}

	printf("Ok, we are done, click Enter...");
	getchar();

	return 0;
}

