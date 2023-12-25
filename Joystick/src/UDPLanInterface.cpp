#include "DeviceInterface.h"
#include "JsAppDlg.h"
#include "StdAfx.h"

extern CString consoleString;
extern CWnd *pCurrentDlg;

UDPLanInterface::UDPLanInterface() {}

UDPLanInterface::UDPLanInterface(Int32 aSendPort, Int32 aRecvPort, Byte *IP, Byte aMode) {
  Byte Ip_Addr[20];
  Int32 sendSockSize = 1000000;
  Int32 recevSockSize = 1000000;

  WSADATA wsa;
  if (WSAStartup(MAKEWORD(2, 2), &wsa) < 0)
    return;

  if (aMode == TX_MODE || aMode == RX_TX_MODE) {
    /*************Tx Variables Init **********/
    strcpy(Ip_Addr, IP);

    TxSockAddr.sin_family = AF_INET;
    TxSockAddr.sin_port = htons(aSendPort);
    TxSockAddr.sin_addr.s_addr = inet_addr(Ip_Addr);

    TxSockAddrLen = sizeof(TxSockAddr);

    if ((TxSockfd = socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
      consoleString.Format(_T("Cannot Create Socket"));
      pCurrentDlg->PostMessageW(REFRESH_CONSOLE);
    } else {
      consoleString.Format(_T("Socket Created for send port no.: %d for IP:"), aSendPort);
      consoleString = consoleString + CString(IP);
      pCurrentDlg->PostMessageW(REFRESH_CONSOLE);
      Sleep(1);
      consoleString = _T("");
    }

    setsockopt(TxSockfd, SOL_SOCKET, SO_SNDBUF, (char *)(&sendSockSize), sizeof(sendSockSize));
  }

  if (aMode == RX_MODE || aMode == RX_TX_MODE) {
    /*************Rx Variables Init **********/
    RxSockAddr.sin_family = AF_INET;
    RxSockAddr.sin_port = htons(aRecvPort);
    RxSockAddr.sin_addr.s_addr = INADDR_ANY;
    RxSockAddrLen = sizeof(RxSockAddr);

    if ((RxSockfd = socket(AF_INET, SOCK_DGRAM, 0)) == ERROR) {
      consoleString.Format(_T("Cannot Create Socket"));
      pCurrentDlg->PostMessageW(REFRESH_CONSOLE);
    }

    setsockopt(RxSockfd, SOL_SOCKET, SO_RCVBUF, (char *)(&recevSockSize), sizeof(recevSockSize));

    if ((bind(RxSockfd, (struct sockaddr *)&RxSockAddr, RxSockAddrLen) == ERROR)) {
      consoleString.Format(_T("Error in bind"));
      pCurrentDlg->PostMessageW(REFRESH_CONSOLE);
    } else {
      consoleString.Format(_T("Socket bound for Rx port no.: %d"), aRecvPort);
      consoleString = consoleString + CString(IP);
      pCurrentDlg->PostMessageW(REFRESH_CONSOLE);
    }
  }
}

UDPLanInterface::~UDPLanInterface() {
#if VXWORKS7_BUILD
  close(TxSockfd);
  close(RxSockfd);
#else
  closesocket(TxSockfd);
  closesocket(RxSockfd);
#endif
}

void inline UDPLanInterface::SendPack(Byte *buffer, Int32 size) {
  Int32 count;

  if ((count = sendto(TxSockfd, buffer, size, 0, (struct sockaddr *)&TxSockAddr, TxSockAddrLen)) == ERROR) {
    perror("Error in Sending Data");
    // printf("%s\n ",inet_ntoa(TxSockAddr.sin_addr));
  }
}

Int32 inline UDPLanInterface::RecvPack(Byte *buffer, Int32 *size) {
  Int32 count;

  if ((count = recvfrom(RxSockfd, buffer, MAX_MSG_SIZE, 0, (struct sockaddr *)&RxSockAddr, &RxSockAddrLen)) == ERROR) {
    perror("Lanif: Err Data Recp");
    return ERROR;
  }
  *size = count;
  return count;
}
