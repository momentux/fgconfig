using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.InteropServices;

namespace McxAPIUser
{
    public class McxA429Wrapper
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
             

        [DllImport("SitalA429.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Channel_GetCount(uint device, ref uint numOfChannels);

        [DllImport("SitalA429.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Channel_Open(uint device, uint channel, ref mcx_A429ChannelInfo channelInfo);

        [DllImport("SitalA429.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_DeviceSetup(int device);

        [DllImport("SitalA429.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Setup(uint device);

        [DllImport("SitalA429.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Channel_GetInformation(uint device, uint channel, ref mcx_A429ChannelInfo channelInfo);

        [DllImport("SitalA429.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Channel_Close(uint device, uint channel);

        [DllImport("SitalA429.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Channel_SetConfigRegister(uint device, uint channel, uint chanFlags);

        [DllImport("SitalA429.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Channel_GetConfigRegister(uint device, uint channel, ref uint chanFlags);

        [DllImport("SitalA429.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Channel_GetStatusRegister(uint device, uint channel, ref uint chanStats);

        [DllImport("SitalA429.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Receive(uint device, uint channel, uint bufferSize, ref uint buffer, ref uint numberOfReceivedWords);

        [DllImport("SitalA429.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Send(uint device, uint channel, uint bufferSize, ref uint buffer, ref uint numberOfWrittenWords);

        [DllImport("SitalA429.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_GetRxWordsPending(uint device, uint channel, ref uint numberOfWords);

        [DllImport("SitalA429.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Card_SetConfiguration(uint device, uint cardFlags);

        [DllImport("SitalA429.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Channel_Reset(uint device, uint channel, uint cardFlags);

        [DllImport("SitalA429.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Pci_Channel_GetCount(uint card, ref uint numOfChannels);

        [DllImport("SitalA429.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Pci_Tx_Rx_Channel_Count(uint card, ref uint numOfTxChannels, ref uint numOfRxChannels);

        [DllImport("SitalA429.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Pci_Channel_Open(uint card, uint channel, ref mcx_A429ChannelInfo channelInfo);

        [DllImport("SitalA429.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Pci_Channel_GetInformation(uint card, uint channel, ref mcx_A429ChannelInfo channelInfo);

        [DllImport("SitalA429.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Pci_Channel_Close(uint card, uint channel);

        [DllImport("SitalA429.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Pci_Channel_SetConfigRegister(uint card, uint channel, uint chanFlags, bool manage = false, UInt32 manFreq = 0);

        [DllImport("SitalA429.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Pci_Channel_GetConfigRegister(uint card, uint channel, ref uint chanFlags);

        [DllImport("SitalA429.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Pci_Channel_GetStatusRegister(uint card, uint channel, ref uint chanStats);

        [DllImport("SitalA429.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Pci_Receive(uint card, uint channel, uint bufferSize, ref uint buffer, ref uint numberOfReceivedWords);

        [DllImport("SitalA429.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Pci_Send(uint card, uint channel, uint bufferSize, ref uint buffer, ref uint numberOfWrittenWords);

        [DllImport("SitalA429.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Pci_GetRxWordsPending(uint card, uint channel, ref uint numberOfWords);

        [DllImport("SitalA429.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Pci_Card_SetConfiguration(uint card, uint cardFlags);

        [DllImport("SitalA429.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Pci_Channel_Reset(uint card, uint channel, uint cardFlags);

        [DllImport("SitalA429.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern short mcx_A429_Pci_LoopBack(uint card, bool flags);
        
    }
}
