/****************************************
- Init the device
- Activating MultiRT user port
- Create and run MultiRT frame, a phantom frame to get the HW to responde
Note - the Multi RTs will run forever, expecting external real / tester BC to transmit messages.
In order to stop the MultiRT, hit Enter key
****************************************/

#include "stdafx.h"
#include <stdio.h>
#include <conio.h>
#include <stdlib.h>
#include "windows.h"
#include "McxAPI.h"
#include "McxAPIReturnCodes.h"
#include "MultiRTs.h"

INT16 iResult = 0;
UINT16 DeviceId = 0;
char errorCode[1000];
static UINT16 BusList1 = 0;
static UINT16 Element1 = 0;
static UINT16 DB1 = 0;
static UINT16 datablock32[64];

#pragma comment(lib, "McxAPI")

int main()
{
	iResult = InitDevice();
	if (iResult < 0) {
		mcx_GetReturnCodeDescription(iResult, errorCode);
		printf("Error -> %s\n", errorCode);
		return -1;
	}

	iResult = SetCurrentPort();
	if (iResult < 0) {
		mcx_GetReturnCodeDescription(iResult, errorCode);
		printf("Error -> %s\n", errorCode);
		return -1;
	}

	iResult = RunMrt();
	if (iResult < 0) {
		mcx_GetReturnCodeDescription(iResult, errorCode);
		printf("Error -> %s\n", errorCode);
		return -1;
	}
	
	printf("Ok, click Enter to stop Multi RTs...");
	getchar();
	mcx_Free(DeviceId);
	return 0;
}

INT16 InitDevice() {
	return mcx_Initialize(DeviceId, MIL_STD_1553_AND_PP194);
}

INT16 SetCurrentPort() {
	UINT16 userPort = MIL_STD_1553_AND_PP194 | MultiRT;
	return mcx_SetUserPort(DeviceId, userPort);
}

INT16 RunMrt() {
	unsigned short rxStt = 0x800;
	unsigned short txStt = 0;

	iResult += mcx_EnableRts(DeviceId, 0xFFFFFFFF); // Enable all RTs, incremental data is injected
	if (iResult < 0) return iResult;
	iResult = mcx_Create_BusList(DeviceId, BusList1);
	if (iResult < 0) return iResult;
	iResult = mcx_Create_BusList_Element(DeviceId, Element1, 0xF820/*phantom command to get the mRT going*/, 0x80 /*Bus A*/, 0x0000, rxStt, txStt);
	if (iResult < 0) return iResult;
	iResult = mcx_Create_Element_DataBlock(DeviceId, DB1, 0, datablock32, 64);
	if (iResult < 0) return iResult;
	iResult = mcx_Map_DataBlock_To_Element(DeviceId, Element1, DB1);
	if (iResult < 0) return iResult;
	iResult = mcx_Map_Element_To_BusList(DeviceId, BusList1, Element1);
	if (iResult < 0) return iResult;

	iResult = mcx_Start(DeviceId, BusList1, 0);
	if (iResult < 0) return iResult;

	Sleep(0);
	return iResult;
}

