using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.InteropServices;

namespace McxAPIUser
{
    public class McxAPIWrapper
    {
        public struct mcx_A429ChannelInfo
        {
            public System.UInt32 dwStructureSize;
            public System.UInt32 dwUserTag;
            // bitmask, see below
            public System.UInt32 dwFlags;
            public System.UInt32 dwTransferSize;
            public System.UInt32 dwCardNumber;

            public System.UInt32 dwReserved1;
            // Flags decode
            public bool channelIsAvailable
            {
                get { return ((dwFlags & 0x1) != 0); }
            }
            public bool channelRunning
            {
                get { return ((dwFlags & 0x2) != 0); }
            }
            public bool channelFailure
            {
                get { return ((dwFlags & 0x4) != 0); }
            }
            public bool channelIsTX
            {
                get { return ((dwFlags & 0x8) != 0); }
            }
            public bool channelIsHighSpeed
            {
                get { return ((dwFlags & 0x10) != 0); }
            }
            public bool channelSupportsTX
            {
                get { return ((dwFlags & 0x20) != 0); }
            }
            public bool channelSupportsRX
            {
                get { return ((dwFlags & 0x40) != 0); }
            }
            public bool channelSupportsHighSpeed
            {
                get { return ((dwFlags & 0x80) != 0); }
            }
            public bool channelSupportsLowSpeed
            {
                get { return ((dwFlags & 0x100) != 0); }
            }
        }
        public  struct mcx_MsgStruct
        {
            UInt16   cmd;        // command to be send or recieve
            UInt16[] data;       // data of the command
            UInt16   dataSize;   // data size
            UInt16[] BSW;        // bit status word
            UInt16[] rtStatus;   // command status
            bool     emulateRt;  // emulate rt flag
        }
        public  struct mcx_MsgFrameStruct
        {
            UInt16 deviceId;    // device id
            UInt16 FrameShots;  // how many times to send/recieve the frame (0 for endless loop)
            bool   FrameType;   // frame limit in micro seconds or times per second in Hz
            UInt16 FrameSpeed;  // frame limit value according to Frame type
            UInt16 BC_RT_Type;  // BC+RT or Multi RT
            bool   FrameNode;   // Gap mode or Rate mode
        }        

        // Following bits are same for TX and RX modes:
        public const System.UInt32 MCX_A429_CFG_HIGH_RATE   = 0x0001;  //< Data rate: 100 KHz
        public const System.UInt32 MCX_A429_CFG_LOW_RATE    = 0x0000;  //< Data rate: 12.5 KHz
        public const System.UInt32 MCX_A429_CFG_MASK_RATE   = 0x0001;
        public const System.UInt32 MCX_A429_CFG_PARITY_NONE = 0x0000;  //< Data parity: none. MSB can be used as data.
        public const System.UInt32 MCX_A429_CFG_PARITY_EVEN = 0x0002;  //< Data parity: even
        public const System.UInt32 MCX_A429_CFG_PARITY_ODD  = 0x0006;  //< Data parity: odd
        public const System.UInt32 MCX_A429_CFG_MASK_PARITY = 0x0006;  //   Mask for parity bits

        public const System.UInt32 MCX_A429_NUMBER_OF_WORDS_MASK = 0x00FF0000;  //   Number of words in FIFO mask - Bits 16-23
        public const System.UInt32 MCX_A429_FIFO_FULL = 0x01000000;  //   FIFO full
        public const System.UInt32 MCX_A429_FIFO_EMPTY = 0x02000000;  //   FIFO empty
        public const System.UInt32 MCX_A429_RX_LABEL_TABLE_READY = 0x04000000;  //   Labels table ready
        
        // Following bits apply only for RX mode:
        public const System.UInt32 MCX_A429_CFG_RX_LABEL_MATCH    = 0x0008;  //< enable label matching
        public const System.UInt32 MCX_A429_CFG_MASK_RX_LABELS    = 0x0008;
        public const System.UInt32 MCX_A429_CFG_RX_DECODER_ENABLE = 0x0010;
        public const System.UInt32 MCX_A429_CFG_RX_DECODER_DISABLE = 0x0000;
        public const System.UInt32 MCX_A429_CFG_MASK_RX_DECODER = 0x0070;

        public const System.UInt32 MCX_A429_CARD_DISABLE_INTERNAL_LOOPBACK = 0x00000000; // sets the card to disable internal loopback, external Arinc429 Tx Rx data is accepted
        public const System.UInt32 MCX_A429_CARD_ENABLE_INTERNAL_LOOPBACK = 0x00000001; // sets the card to enable internal loopback, external Arinc429 Tx Rx data is not accepted

        // Protocols for init / reload functions

        public const System.UInt32 MIL_STD_1553_AND_PP194 = 0x0000;
        public const System.UInt32 H009 = 0x0001;
        public const System.UInt32 MultiRT = 0x0002;
        public const System.UInt32 MIL_STD_1553 = 0x0004;
        public const System.UInt32 EBR_1553 = 0x0008;
        public const System.UInt32 DIGIBUS_F16 = 0x0016;

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_MapDevices(ref ushort numberOfDevices);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Initialize(uint deviceId, uint protocol);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_ReloadHW(uint deviceId, uint protocol);

        [DllImport("McxAPI.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_SetFpgaFileDirectory(uint deviceId, string fpgaFileDir);

        [DllImport("McxAPI.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_GetDescriptors(uint deviceId, StringBuilder deviceName, StringBuilder deviceManufacturer, StringBuilder deviceFirmware, StringBuilder deviceSerial);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Read(uint deviceId, uint address, ushort size, ref ushort buffer);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Write(uint deviceId, uint address, ushort size, ref ushort buffer);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Create_BusList(uint deviceId, uint busList);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Create_BusList_Element(uint deviceId, uint element, uint command, uint options, uint command2, uint StatusWord1, uint StatusWord2);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Create_BusList_Element1(uint deviceId, uint element, uint command, uint options);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Create_Element_DataBlock(uint deviceId, uint dataBlock, uint dataBlockMode, ref ushort buffer, ushort bufferSize);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Map_DataBlock_To_Element(uint deviceId, uint element, uint dataBlock);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Map_Element_To_BusList(uint deviceId, uint busList, uint element);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Start(uint deviceId, uint busList, uint numberOfIterations);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Get_Element_Results(uint deviceId, uint busList, uint elementIndex, ref uint blockStatusWord, ref ushort buffer, ushort bufferSize, ref ushort status1, ref ushort status2, ref ushort tag);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_DevicePassiveTimeStarted(uint deviceId, ref uint isFirstPassive);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_SetFrameTime(uint deviceId, uint microSeconds);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_EnableRts(uint deviceId, uint rtsVector);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_EnableRius(uint deviceId, ushort riusVector);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Free(uint deviceId);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_FreeBusList(uint deviceId, uint busList);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Close(uint deviceId);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Stop(uint deviceId);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Stop2(uint deviceId);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Element_DataBlock_Write(uint deviceId, uint element, uint wDataBlock, ref ushort buffer, uint bufferSize);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Element_DataBlock_Read(uint deviceId, uint element, uint wDataBlock, ref ushort buffer, ushort bufferSize);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Delete_BusList(uint deviceId, uint busList);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Delete_BusList_Element(uint deviceId, uint element);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Delete_Element_DataBlock(uint deviceId, uint dataBlock);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_UnMap_DataBlock_From_Element(uint deviceId, uint element, uint dataBlock);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_UnMap_Element_From_BusList(uint deviceId, uint busList, uint element);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Get_DataBlock_NumberOfWordsToRead(uint deviceId, uint element, uint dataBlock, ref ushort numWordsToRead);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Get_DataBlock_NumberOfWordsToWrite(uint deviceId, uint element, uint dataBlock, ref ushort numWordsToWrite);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Get_Version(uint deviceId, ref ushort version);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Get_EnabledRts(uint deviceId, ref uint rtsVector);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_SetIntEnable(uint deviceId, uint interrupsEnabled);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_GetIntVector(uint deviceId, ref ushort interruptsStatuses);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_SetTime(uint deviceId, ulong time, ushort reg14 = 0, ushort reg15 = 0, ushort reg16 = 0,ushort REG17 = 0);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_GetTime(uint deviceId, ref ulong time);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_SetTimeResolution(uint deviceId, uint timeResolution);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_GetTimeResolution(uint deviceId, ref ushort timeResolution);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Set_Error(uint deviceId, uint errorType, uint messageNumber, uint wordNumber, int injectionParameters, int zXDistortion);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Element_EnableIrq(uint deviceId, uint busList, uint element);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Element_ElementGetIrq(uint deviceId, uint busList, uint element, ref ushort interruptStatusRegisterValue);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Get_Element_Results_PP194(uint deviceId, uint busList, uint elementIndex, ref uint blockStatusWord, ref ushort buffer, ushort bufferSize, ref ushort status1, ref ushort status2, ref ushort tag);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_SetUserPort(uint deviceId, uint userPort);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_GetUserPort(uint deviceId, ref uint userPort);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_GetCurrentFrameNumber(uint deviceId, ref uint currFrameNumber);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_wm_GetNextMsg_H009(uint deviceId, ref uint swPointer, ref ushort command, ref ushort isCommandValid, ref ushort data, ref ushort bufferSize, ref uint BSW, ref ulong tTag);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_wm_GetNextMsg_1553_194(uint deviceId, ref uint msgType, ref uint swPointer, ref ushort rxCommand, ref ushort txCommand, ref ushort data, ref ushort bufferSize, ref ushort rxStatus, ref ushort txStatus, ref uint BSW, ref ulong tTag);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_wm_collectMonitor(uint deviceId);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_wm_Stop_H009(uint deviceId);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_wm_Initialize(uint deviceId);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Grip2_GetTemperature(uint deviceId, ref int temperature);

        [DllImport("McxAPI.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_GetReturnCodeDescription(int errorCode, StringBuilder errorCodeDescription);
        
        [DllImport("McxAPI.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_GetLicenseDescription(uint deviceId, StringBuilder description);
        
        [DllImport("McxAPI.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_GetMonitorErrorsDescription(uint bsw, StringBuilder errorsDescription);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Element_SetGap(uint deviceId, uint elementId, uint gap);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_pTDR_GetRawData(uint deviceId, ref ushort buffer, ushort bufferSize);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Restart(uint deviceId, uint busList);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_BusList_UpdateData(uint deviceId, uint busList, ref int updatedFrame);
        
        [DllImport("McxAPI.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_GetSimulatorErrorsDescription(uint bsw, StringBuilder errorsDescription, ushort protocol);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_pTDR_Enable(uint deviceId, ushort enable, ushort options);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Transmit_1553_Message(uint deviceId, uint command, ref uint blockStatusWord, ref ushort buffer, ref ushort actualWordCount, ref ushort status, ref ushort tTag, ref ushort options);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Transmit_1553_Messages(uint deviceId, uint command, ref uint blockStatusWord, ref ushort buffer, ushort numberOfShots, ref ushort status, ref ushort options);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Send_Data_To_RT(uint deviceId, uint rt, uint subAddress, uint wordCount, ref ushort buffer, ref uint blockStatusWord, ref ushort status, ref ushort tTag, ref ushort options);
                                                    
        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Get_Data_From_RT(uint deviceId, uint rt, uint subAddress, uint wordCount, ref ushort buffer, ref uint blockStatusWord, ref ushort status, ref ushort tTag, ref ushort options);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_SetConfigurationRegisters(uint deviceId, uint configRegisters, uint configRegisters2);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_GetConfigurationRegisters(uint deviceId, ref uint configRegisters, ref uint configRegisters2);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_SetupRS422(uint deviceId, uint line, uint bitsCount, uint parity, uint stopBits, uint rateDivider);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_SendRS422(uint deviceId, uint line, uint length, ref ushort buffer);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_RS485_Setup(uint moduleId, uint line, uint bitsCount, uint parity, uint stopBits, uint rateDivider, uint rxTxMode, ref uint offset);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_RS485_Put(uint moduleId, uint line, uint length, ref ushort buffer);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_RS485_Get(uint moduleId, uint line, ref uint offset, uint length, ref ushort buffer);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_RS485_GetNumberOfReceivedWords(uint moduleId, uint line, uint offset, ref uint length);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_RS485_GetStatus(uint moduleId, ref uint line0, ref uint line1);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Channel_GetCount(ref uint numOfChannels);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Channel_Open(uint channel, ref mcx_A429ChannelInfo channelInfo);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Setup(uint device);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Channel_GetInformation(uint channel, ref mcx_A429ChannelInfo channelInfo);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Channel_Close(uint channel);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Channel_SetConfigRegister(uint channel, uint chanFlags);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Channel_GetConfigRegister(uint channel, ref uint chanFlags);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Channel_GetStatusRegister(uint channel, ref uint chanStats);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Receive(uint channel, uint bufferSize, ref uint buffer, ref uint numberOfReceivedWords);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Send(uint channel, uint bufferSize, ref uint buffer, ref uint numberOfWrittenWords);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_GetRxWordsPending(uint channel, ref uint numberOfWords);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Card_SetConfiguration(uint cardFlags);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Channel_Reset(uint channel, uint cardFlags);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Pci_Channel_GetCount(uint card, ref uint numOfChannels);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Pci_Tx_Rx_Channel_Count(uint card, ref uint numOfTxChannels, ref uint numOfRxChannels);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Pci_Channel_Open(uint card, uint channel, ref mcx_A429ChannelInfo channelInfo);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Pci_Channel_GetInformation(uint card, uint channel, ref mcx_A429ChannelInfo channelInfo);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Pci_Channel_Close(uint card, uint channel);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Pci_Channel_SetConfigRegister(uint card, uint channel, uint chanFlags, bool manage = false, UInt32 manFreq = 0);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Pci_Channel_GetConfigRegister(uint card, uint channel, ref uint chanFlags);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Pci_Channel_GetStatusRegister(uint card, uint channel, ref uint chanStats);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Pci_Receive(uint card, uint channel, uint bufferSize, ref uint buffer, ref uint numberOfReceivedWords);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Pci_Send(uint card, uint channel, uint bufferSize, ref uint buffer, ref uint numberOfWrittenWords);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Pci_GetRxWordsPending(uint card, uint channel, ref uint numberOfWords);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Pci_Card_SetConfiguration(uint card, uint cardFlags);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Pci_Channel_Reset(uint card, uint channel, uint cardFlags);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Read_Debug(uint deviceId, uint address, ushort size, ref ushort buffer);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Write_Debug(uint deviceId, uint address, ushort size, ref ushort buffer);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_SetCyberAttack(uint deviceId, uint cyberAttackType, uint triggerCommand);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_TestExternalLoopback_DevicetoDevice(uint device0, uint device1, ref ushort resultD0A, ref ushort resultD0B, ref ushort resultD1A, ref ushort resultD1B, ref bool badDataFound);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Eth_SetupIpType(uint requestType);

        [DllImport("McxAPI.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Eth_SetServerIPsList(uint serversNumber, string ips);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Send_AsynchMsg1(uint deviceId, uint command, uint options, uint statusWord, ref ushort buffer, ushort bufferSize);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Send_AsynchMsg2(uint deviceId, uint command, uint options, uint statusWord, ref ushort buffer, ushort bufferSize);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Get_Asynch1_Results(uint deviceId, ref uint blockStatusWord, ref ushort buffer, ushort bufferSize, ref ushort status, ref ushort tag);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Get_Asynch2_Results(uint deviceId, ref uint blockStatusWord, ref ushort buffer, ushort bufferSize, ref ushort status, ref ushort tag);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_SetRTsResponseDelay(uint deviceId, ushort rtResponseHalfUs, ushort respondAnyway);

        [DllImport("McxAPI.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_wm_DumpMonitor_RawData(uint deviceId, string fullName, uint lengthToDump, ushort options);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_wm_DumpMonitor_Cancel(uint deviceId);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Element_SetRate(uint deviceId, uint elementId, uint rate, uint skew, uint elementSpacing);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Start_RateMode(uint deviceId, uint busList, uint numberOfIterations);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Element_UpdateData(uint deviceId, uint busList, uint element);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Element_UpdateStatuses(uint deviceId, uint element, uint rxStatus, uint txStatus);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Get_Buslist_TransmittedElements(uint deviceId, uint busList, ref char elementsTransmitted);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_Read_17(uint deviceId, uint address, ushort size, ref ushort buffer);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_GetApiDebugData(uint deviceId, ref uint wordsPending, ref uint maxWordsPending);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_GetTemperature(uint deviceId, ref int temperature);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_GetPciProductIds(ref uint pIds, ref int numberOfCardsFound);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_GetPciMake(uint card, ref int make);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_GetPciMakeByDevice(uint swDevice, ref int make);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_TransmitSingleMessageOnce(UInt16 deviceId, UInt16 cmd, ref UInt16 buffer, UInt16 size, ref UInt16 BSW, ref UInt16 rtStatus);

        [DllImport("McxAPI.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_TransmitFrame(UInt16 deviceId, UInt16 cmd, bool emulateRt, ref UInt16 buffer, UInt16 size, ref UInt16 BSW, ref UInt16 rtStatus);
    }
}
