
// JsAppDlg.cpp : implementation file
//

#include "JsAppDlg.h"
#include "DeviceInterface.h"
#include "JsApp.h"
#include "afxdialogex.h"
#include "stdafx.h"
#include "ul.h"
#include <iostream>
#include <string>
#include <thread>
#include <windows.h>

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

#define OAC_SIM_SEND_PORT 2500
#define OAC_IP "134.32.40.112"
#define CONVERT_ENDIAN
// CAboutDlg dialog used for App About

void readJoystickThread(LPVOID Lparam);
jsJoystick *js[MAX_HMI_DEVICE];
CWnd *pCurrentDlg;
CString consoleString;

extern int cursorX, cursorY;

CString HotasFileName, LMFD_filename, RMFD_filename, Stick_fileName;

class CAboutDlg : public CDialogEx {
public:
  CAboutDlg();

  // Dialog Data
  enum { IDD = IDD_ABOUTBOX };

protected:
  virtual void DoDataExchange(CDataExchange *pDX); // DDX/DDV support

  // Implementation
protected:
  DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialogEx(CAboutDlg::IDD) {}

void CAboutDlg::DoDataExchange(CDataExchange *pDX) { CDialogEx::DoDataExchange(pDX); }

BEGIN_MESSAGE_MAP(CAboutDlg, CDialogEx)
END_MESSAGE_MAP()

// CJsAppDlg dialog

LRESULT CJsAppDlg::updateConsole(WPARAM, LPARAM) {
  m_Text = consoleString + CString("\r\n") + m_Text;
  UpdateData(false);
  consoleString = _T("");
  return 1;
}

LRESULT CJsAppDlg::updateCursorPos(WPARAM, LPARAM) {
  m_CursorX.Format(_T("%d"), cursorX);
  m_CursorY.Format(_T("%d"), cursorY);
  UpdateData(false);
  return 1;
}

CJsAppDlg::CJsAppDlg(CWnd *pParent /*=NULL*/) : CDialogEx(CJsAppDlg::IDD, pParent) {
  m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
  m_Text = _T("");
  m_CursorX = _T("");
  m_CursorY = _T("");
}

void CJsAppDlg::DoDataExchange(CDataExchange *pDX) {
  CDialogEx::DoDataExchange(pDX);
  DDX_Text(pDX, IDC_EDIT_Console, m_Text);
  DDV_MaxChars(pDX, m_Text, 1000000);
  DDX_Text(pDX, IDC_EDIT_CURSOR_X, m_CursorX);
  DDV_MaxChars(pDX, m_CursorX, 20);
  DDX_Text(pDX, IDC_EDIT_CURSOR_Y, m_CursorY);
  DDV_MaxChars(pDX, m_CursorY, 20);
}

BEGIN_MESSAGE_MAP(CJsAppDlg, CDialogEx)
ON_MESSAGE(REFRESH_CONSOLE, updateConsole)
ON_MESSAGE(REFRESH_CURSOR_POS, updateCursorPos)
ON_WM_SYSCOMMAND()
ON_WM_PAINT()
ON_WM_QUERYDRAGICON()
ON_EN_CHANGE(IDC_MFCEDITBROWSE_HOTAS, &CJsAppDlg::OnEnChangeMfceditbrowseHotas)
ON_BN_CLICKED(IDC_BUTTON1, &CJsAppDlg::OnBnClickedButton1)
ON_BN_CLICKED(IDC_BUTTON2, &CJsAppDlg::OnBnClickedButton2)
ON_BN_CLICKED(IDC_BUTTON3, &CJsAppDlg::OnBnClickedButton3)
ON_BN_CLICKED(IDC_BUTTON4, &CJsAppDlg::OnBnClickedButton4)
END_MESSAGE_MAP()

// CJsAppDlg message handlers

BOOL CJsAppDlg::OnInitDialog() {
  CDialogEx::OnInitDialog();

  // Add "About..." menu item to system menu.

  // IDM_ABOUTBOX must be in the system command range.
  ASSERT((IDM_ABOUTBOX & 0xFFF0) == IDM_ABOUTBOX);
  ASSERT(IDM_ABOUTBOX < 0xF000);

  CMenu *pSysMenu = GetSystemMenu(FALSE);
  if (pSysMenu != NULL) {
    BOOL bNameValid;
    CString strAboutMenu;
    bNameValid = strAboutMenu.LoadString(IDS_ABOUTBOX);
    ASSERT(bNameValid);
    if (!strAboutMenu.IsEmpty()) {
      pSysMenu->AppendMenu(MF_SEPARATOR);
      pSysMenu->AppendMenu(MF_STRING, IDM_ABOUTBOX, strAboutMenu);
    }
  }

  // Set the icon for this dialog.  The framework does this automatically
  //  when the application's main window is not a dialog
  SetIcon(m_hIcon, TRUE);  // Set big icon
  SetIcon(m_hIcon, FALSE); // Set small icon

  // TODO: Add extra initialization here
  readThreadID = AfxBeginThread((AFX_THREADPROC)readJoystickThread, this, THREAD_PRIORITY_NORMAL, 0, 0);

  HANDLE hSerial = openSerialPort("COM3", CBR_9600);
  if (hSerial != INVALID_HANDLE_VALUE) {
    std::thread serialThread(readSerialData, hSerial);
    serialThread.join(); // Or detach, depending on your application's needs
    closeSerialPort(hSerial);
  }

  return TRUE; // return TRUE  unless you set the focus to a control
}

void CJsAppDlg::OnSysCommand(UINT nID, LPARAM lParam) {
  if ((nID & 0xFFF0) == IDM_ABOUTBOX) {
    CAboutDlg dlgAbout;
    dlgAbout.DoModal();
  } else {
    CDialogEx::OnSysCommand(nID, lParam);
  }
}

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void CJsAppDlg::OnPaint() {
  if (IsIconic()) {
    CPaintDC dc(this); // device context for painting

    SendMessage(WM_ICONERASEBKGND, reinterpret_cast<WPARAM>(dc.GetSafeHdc()), 0);

    // Center icon in client rectangle
    int cxIcon = GetSystemMetrics(SM_CXICON);
    int cyIcon = GetSystemMetrics(SM_CYICON);
    CRect rect;
    GetClientRect(&rect);
    int x = (rect.Width() - cxIcon + 1) / 2;
    int y = (rect.Height() - cyIcon + 1) / 2;

    // Draw the icon
    dc.DrawIcon(x, y, m_hIcon);
  } else {
    CDialogEx::OnPaint();
  }
}

// The system calls this function to obtain the cursor to display while the user drags
//  the minimized window.
HCURSOR CJsAppDlg::OnQueryDragIcon() { return static_cast<HCURSOR>(m_hIcon); }

void readJoystickThread(LPVOID Lparam) {
  int i;
  int buttons[64];
  bool chkLong[64];
  int numButtonsPressed;
  int X_pos, Y_pos;
  unsigned short currToggleStat[MAX_BUTTONS];
  unsigned long buttonCnt = 0;
  unsigned short povID;

  sButtonPressInfo bpInfo;
  sCursorDataPviToOac crsrRates;

  pCurrentDlg = AfxGetApp()->m_pMainWnd;

  for (i = 0; i < MAX_HMI_DEVICE; i++)
    js[i] = new jsJoystick(i);

  int useful[MAX_HMI_DEVICE], hmiConnected = 0;

  for (i = 0; i < MAX_HMI_DEVICE; i++) {
    if (!(js[i]->notWorking())) {
      useful[hmiConnected] = i;
      js[i]->initButtonStat();
      hmiConnected++;
    }
  }

  UDPLanInterface oacSocket(OAC_SIM_SEND_PORT, 0, OAC_IP, TX_MODE);

  if (hmiConnected > 0) {

    while (1) {
      // js[iCurrJoyStkIdx]->getButtonPressOnRelease(buttons);

      for (i = 0; i < hmiConnected; i++) {
        X_pos = 0;
        Y_pos = 0;

        js[useful[i]]->getButtonPressOnRelease(buttons, chkLong, numButtonsPressed, X_pos, Y_pos, currToggleStat,
                                               povID);
        if (numButtonsPressed > 0) {
          for (int j = 0; j < numButtonsPressed; j++) {
            buttonCnt = buttonCnt + 1;
            if (chkLong[j] == true || currToggleStat[j] == TOGGLE_OFF) {
              switch (js[useful[i]]->buttonType[buttons[j]]) {
              case TOGGLE_SWITCH: {
                consoleString.Format(_T("%d. Toggle Button-%d OFF "), buttonCnt, buttons[j]);
                consoleString = consoleString + CString(js[useful[i]]->name);
                pCurrentDlg->PostMessageW(REFRESH_CONSOLE);
                break;
              }

              case PRESS_RELEASE_SHORT_LONG: {
                consoleString.Format(_T("%d. Button-%d Long Press in "), buttonCnt, buttons[j]);
                consoleString = consoleString + CString(js[useful[i]]->name);
                pCurrentDlg->PostMessageW(REFRESH_CONSOLE);
                break;
              }
              }
              bpInfo.iKeyPress = js[useful[i]]->RES_MSGID_LONG_PRESS[buttons[j]];
              bpInfo.tHdr.uiMsgId = PVI_TO_OAC_BTN_PRESS_MSG_ID;

              if (bpInfo.iKeyPress > 0) {
                Reverse4Byte(&bpInfo.iKeyPress, 1);
                Reverse4Byte(&bpInfo.tHdr.uiMsgId, 1);
                oacSocket.SendPack((Byte *)&bpInfo, sizeof(sButtonPressInfo));
              }
            } else {
              switch (js[useful[i]]->buttonType[buttons[j]]) {
              case TOGGLE_SWITCH: {
                consoleString.Format(_T("%d. Toggle Button-%d ON "), buttonCnt, buttons[j]);
                consoleString = consoleString + CString(js[useful[i]]->name);
                pCurrentDlg->PostMessageW(REFRESH_CONSOLE);
                break;
              }

              case PRESS_RELEASE_SHORT_LONG: {
                consoleString.Format(_T("%d. Button-%d Short Press in "), buttonCnt, buttons[j]);
                consoleString = consoleString + CString(js[useful[i]]->name);
                pCurrentDlg->PostMessageW(REFRESH_CONSOLE);
                break;
              }

              case PRESS_RELEASE_SHORT_CONTINUOUS: {
                consoleString.Format(_T("%d. Button-%d Continuous Press in "), buttonCnt, buttons[j]);
                consoleString = consoleString + CString(js[useful[i]]->name);
                pCurrentDlg->PostMessageW(REFRESH_CONSOLE);
                break;
              }
              }

              bpInfo.iKeyPress = js[useful[i]]->RES_MSGID[buttons[j]];
              bpInfo.tHdr.uiMsgId = PVI_TO_OAC_BTN_PRESS_MSG_ID;

              if (bpInfo.iKeyPress > 0) {
                Reverse4Byte(&bpInfo.iKeyPress, 1);
                Reverse4Byte(&bpInfo.tHdr.uiMsgId, 1);
                oacSocket.SendPack((Byte *)&bpInfo, sizeof(sButtonPressInfo));
              }
            }
          }
        }

        if (abs(X_pos) > 0 || abs(Y_pos) > 0) {
          cursorX = X_pos;
          cursorY = Y_pos;
          pCurrentDlg->PostMessageW(REFRESH_CURSOR_POS);
          crsrRates.tHdr.uiMsgId = PVI_TO_OAC_T4_CRSR_RATES_MSG_ID;
          crsrRates.siCrsrLeftRightRt = X_pos;
          crsrRates.siCrsrUpDownRt = Y_pos;
          Reverse4Byte(&crsrRates.tHdr.uiMsgId, 1);
          Reverse2Byte((uInt16 *)&crsrRates.siCrsrLeftRightRt, 1);
          Reverse2Byte((uInt16 *)&crsrRates.siCrsrUpDownRt, 1);
          oacSocket.SendPack((Byte *)&crsrRates, sizeof(sCursorDataPviToOac));
        }

        if (povID != 0) {
          buttonCnt = buttonCnt + 1;

          consoleString.Format(_T("%d. POV-%d Continuous Press in "), buttonCnt, povID);
          consoleString = consoleString + CString(js[useful[i]]->name);
          pCurrentDlg->PostMessageW(REFRESH_CONSOLE);

          bpInfo.iKeyPress = js[useful[i]]->RES_MSGID_POV[povID - 1];
          bpInfo.tHdr.uiMsgId = PVI_TO_OAC_BTN_PRESS_MSG_ID;
          if (bpInfo.iKeyPress > 0) {
            Reverse4Byte(&bpInfo.iKeyPress, 1);
            Reverse4Byte(&bpInfo.tHdr.uiMsgId, 1);
            oacSocket.SendPack((Byte *)&bpInfo, sizeof(sButtonPressInfo));
          }
        }
      }
      Sleep(POLL_DELAY);
    }
  } else {
    printf("\nNo Joystick detected...Press enter, connect joystick and re-run");
    getchar();
  }
}

void CJsAppDlg::OnEnChangeMfceditbrowseHotas() {
  // TODO:  If this is a RICHEDIT control, the control will not
  // send this notification unless you override the CDialogEx::OnInitDialog()
  // function and call CRichEditCtrl().SetEventMask()
  // with the ENM_CHANGE flag ORed into the mask.

  // TODO:  Add your control notification handler code here
}

void CJsAppDlg::OnBnClickedButton1() {
  // TODO: Add your control notification handler code here
  bool stat = false;

  this->GetDlgItem(IDC_MFCEDITBROWSE_HOTAS)->GetWindowTextW(HotasFileName);
  if (HotasFileName.IsEmpty() == true) {
    consoleString = _T("No file selected for HOTAS Config Reload");
    updateConsole(0, 0);
  } else {
    for (unsigned short i = 0; i < MAX_HMI_DEVICE; i++) {
      if (strcmp(js[i]->name, "HOTAS") == 0) {
        stat = js[i]->loadButtonTypeFromFile(CT2A(HotasFileName));
        if (stat == true) {
          consoleString = _T("HOTAS Config reloaded - ") + HotasFileName;
          updateConsole(0, 0);
        } else {
          consoleString = _T("Unable to load HOTAS Config");
          updateConsole(0, 0);
        }
      }
    }
  }
}

void CJsAppDlg::OnBnClickedButton2() {
  // TODO: Add your control notification handler code here
  bool stat = false;
  this->GetDlgItem(IDC_MFCEDITBROWSE_HOTAS)->GetWindowTextW(LMFD_filename);
  if (LMFD_filename.IsEmpty() == true) {
    consoleString = _T("No file selected for LMFD Config Reload");
    updateConsole(0, 0);
  } else {
    for (unsigned short i = 0; i < MAX_HMI_DEVICE; i++) {
      if (strcmp(js[i]->name, "LMFD") == 0) {
        stat = js[i]->loadButtonTypeFromFile(CT2A(LMFD_filename));
        if (stat == true) {
          consoleString = _T("LMFD Config reloaded - ") + LMFD_filename;
          updateConsole(0, 0);
        } else {
          consoleString = _T("Unable to load LMFD Config");
          updateConsole(0, 0);
        }
      }
    }
  }
}

void CJsAppDlg::OnBnClickedButton3() {
  // TODO: Add your control notification handler code here
  bool stat = false;
  this->GetDlgItem(IDC_MFCEDITBROWSE_HOTAS)->GetWindowTextW(RMFD_filename);
  if (RMFD_filename.IsEmpty() == true) {
    consoleString = _T("No file selected for LMFD Config Reload");
    updateConsole(0, 0);
  } else {
    for (unsigned short i = 0; i < MAX_HMI_DEVICE; i++) {
      if (strcmp(js[i]->name, "RMFD") == 0) {
        stat = js[i]->loadButtonTypeFromFile(CT2A(RMFD_filename));
        if (stat == true) {
          consoleString = _T("RMFD Config reloaded - ") + RMFD_filename;
          updateConsole(0, 0);
        } else {
          consoleString = _T("Unable to load RMFD Config");
          updateConsole(0, 0);
        }
      }
    }
  }
}

void CJsAppDlg::OnBnClickedButton4() {
  // TODO: Add your control notification handler code here
  this->GetDlgItem(IDC_MFCEDITBROWSE_HOTAS)->GetWindowTextW(Stick_fileName);
}

HANDLE openSerialPort(const std::string &portName, DWORD baudRate) {
  HANDLE hSerial = CreateFile(portName.c_str(), GENERIC_READ, 0, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  if (hSerial == INVALID_HANDLE_VALUE) {
    std::cerr << "Error opening serial port" << std::endl;
    return INVALID_HANDLE_VALUE;
  }

  DCB dcbSerialParams = {0};
  dcbSerialParams.DCBlength = sizeof(dcbSerialParams);
  if (!GetCommState(hSerial, &dcbSerialParams)) {
    std::cerr << "Error getting device state" << std::endl;
    CloseHandle(hSerial);
    return INVALID_HANDLE_VALUE;
  }

  dcbSerialParams.BaudRate = baudRate;
  dcbSerialParams.ByteSize = 8;
  dcbSerialParams.StopBits = ONESTOPBIT;
  dcbSerialParams.Parity = NOPARITY;
  if (!SetCommState(hSerial, &dcbSerialParams)) {
    std::cerr << "Error setting device parameters" << std::endl;
    CloseHandle(hSerial);
    return INVALID_HANDLE_VALUE;
  }

  COMMTIMEOUTS timeouts = {0};
  timeouts.ReadIntervalTimeout = 50;
  timeouts.ReadTotalTimeoutConstant = 50;
  timeouts.ReadTotalTimeoutMultiplier = 10;
  if (!SetCommTimeouts(hSerial, &timeouts)) {
    std::cerr << "Error setting timeouts" << std::endl;
    CloseHandle(hSerial);
    return INVALID_HANDLE_VALUE;
  }

  return hSerial;
}

// Function to close the serial port
void closeSerialPort(HANDLE hSerial) { CloseHandle(hSerial); }

// Function to read from the serial port
std::string readSerialPort(HANDLE hSerial, DWORD &bytesRead) {
  char buffer[1024];
  if (!ReadFile(hSerial, buffer, sizeof(buffer) - 1, &bytesRead, NULL)) {
    std::cerr << "Error reading from serial port" << std::endl;
    return "";
  }

  buffer[bytesRead] = '\0'; // Null-terminate the string
  return std::string(buffer);
}

void readSerialData(HANDLE hSerial) {
    DWORD bytesRead;
    while (true) {
        std::string data = readSerialPort(hSerial, bytesRead);
        if (bytesRead > 0) {
            std::cout << "Read " << bytesRead << " bytes: " << data << std::endl;

            // Send the data over UDP
            oacSocket.SendPack((Byte *)data.c_str(), bytesRead);
        }

        // Add a condition to break the loop if needed
        if (data == "exit_command") break; // Example condition to exit

        std::this_thread::sleep_for(std::chrono::milliseconds(100)); // To prevent high CPU usage
    }
}