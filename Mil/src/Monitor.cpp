/****************************************
- Init the device
- Set RTs to inject infinite incremental data, NOTE - the RTs are simulated
- Send 3 message BC2RT, RT2BC, RT2RT - run forever
- Monitor bus traffic
****************************************/

#include "stdafx.h"
#include <stdio.h>
#include <conio.h>
#include <stdlib.h>
#include "windows.h"
#include "McxAPI.h"
#include "McxAPIReturnCodes.h"
#include "Monitor.h"

#pragma comment(lib, "McxAPI")

INT16 iResult = 0;
UINT16 DeviceId = 0;
char errorCode[1000];
static UINT16 BusList1 = 0;
static UINT16 Element1 = 0;
static UINT16 Element2 = 1;
static UINT16 Element3 = 2;
static UINT16 DB1 = 0;
static UINT16 DB2 = 1;
static UINT16 datablock32[64];

int main()
{
	iResult = InitDevice();
	if (iResult < 0) {
		mcx_GetReturnCodeDescription(iResult, errorCode);
		printf("Error -> %s\n", errorCode);
		return -1;
	}

	bool simulateRts = true;
	iResult = CreateFrame(simulateRts);
	if (iResult < 0) {
		mcx_GetReturnCodeDescription(iResult, errorCode);
		printf("Error -> %s\n", errorCode);
		return -1;
	}

	RunMonitor();

	mcx_Free(DeviceId);
	printf("\n\n");
	printf("\n\n");
	printf("Ok, we are done, click Enter...");
	getchar();
	getchar();
	return 0;
}

INT16 InitDevice() {
	return mcx_Initialize(DeviceId, MIL_STD_1553_AND_PP194);
}

INT16 CreateFrame(bool simulateRts) {
	UINT16 messageOptions = 0;
	UINT16 cmd1 = 0x3020; // BC2RT6 32WC
	UINT16 cmd2 = 0xA420; // RT202BC 32WC;
	UINT16 cmd3_0 = 0xF020; // RT11toRT30 32WC
	UINT16 cmd3_1 = 0x5C20; // RT11toRT30 32WC
	unsigned short rxStt = 0x800;
	unsigned short txStt = 0;

	if (simulateRts) {
		iResult += mcx_EnableRts(DeviceId, 0xFFFFFFFF /*Inject data*/);
		if (iResult < 0) return iResult;
	}
	else {
		iResult += mcx_EnableRts(DeviceId, 0);
		if (iResult < 0) return iResult;
	}

	if (iResult < 0) return iResult;
	iResult = mcx_Create_BusList(DeviceId, BusList1);
	if (iResult < 0) return iResult;
	iResult = mcx_Create_BusList_Element(DeviceId, Element1, cmd1, 0x80 /*Bus A*/ | messageOptions, 0x0000, rxStt, txStt);
	if (iResult < 0) return iResult;
	iResult = mcx_Create_BusList_Element(DeviceId, Element2, cmd2, 0 /*Bus B*/ | messageOptions, 0x0000, rxStt, txStt);
	if (iResult < 0) return iResult;
	messageOptions = RT2RT_FORMAT;
	iResult = mcx_Create_BusList_Element(DeviceId, Element3, cmd3_0, 0x80 /*Bus B*/ | messageOptions, cmd3_1, rxStt, txStt);
	if (iResult < 0) return iResult;
	iResult = mcx_Create_Element_DataBlock(DeviceId, DB1, 0, datablock32, 64);
	if (iResult < 0) return iResult;
	iResult = mcx_Map_DataBlock_To_Element(DeviceId, Element1, DB1);
	if (iResult < 0) return iResult;
	iResult = mcx_Map_DataBlock_To_Element(DeviceId, Element2, DB1);
	if (iResult < 0) return iResult;
	iResult = mcx_Map_DataBlock_To_Element(DeviceId, Element3, DB1);
	if (iResult < 0) return iResult;
	iResult = mcx_Map_Element_To_BusList(DeviceId, BusList1, Element1);
	if (iResult < 0) return iResult;
	iResult = mcx_Map_Element_To_BusList(DeviceId, BusList1, Element2);
	if (iResult < 0) return iResult;
	iResult = mcx_Map_Element_To_BusList(DeviceId, BusList1, Element3);
	if (iResult < 0) return iResult;

	iResult = mcx_Start(DeviceId, BusList1, 0/*Run forever..*/);
	return iResult;
}

void RunMonitor() {
	UINT32 BSW = 0;
	INT16 msgType;
	unsigned long long ttag = 0;
	WORD data[32];
	UINT32 swPointer = 0;
	WORD rxCommand = 0xAAAA;
	WORD txCommand = 0xAAAA;
	WORD rxStat;
	WORD txStat;
	WORD bufferSize = 0;

	while (!_kbhit()) {
		printf("Hit any key to exit...\n\n");
		// for readability...
		Sleep(500);
		system("cls");
		iResult += mcx_wm_GetNextMsg_1553_194(0, &msgType, &swPointer, &rxCommand, &txCommand, data, &bufferSize, &rxStat, &txStat, &BSW, &ttag);
		if (iResult < 0) {
			mcx_GetReturnCodeDescription(iResult, errorCode);
			printf("Error -> %s\n", errorCode);
			continue;
		}
		printf("rxCmd: %04X|txCmd %04X|msgType %i|rxStt %04X|txStt %04X|BSW %04X|swPtr %04X ", rxCommand, txCommand, msgType, rxStat, txStat, BSW, swPointer);
		for (int i = 0; i < 32; i++) {
			printf("%4X ", data[i]);
		}
		printf("\n\n");
	}
}


