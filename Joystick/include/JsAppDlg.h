#pragma once

#include "DeviceInterface.h"
#include "js.h"
#include "resource.h"

#define MAX_HMI_DEVICE 10
#define REFRESH_CONSOLE WM_USER + 1
#define REFRESH_CURSOR_POS WM_USER + 2

// CJsAppDlg dialog
class CJsAppDlg : public CDialogEx {
  // Construction
public:
  CJsAppDlg(CWnd *pParent = NULL); // standard constructor

  // Dialog Data
  enum { IDD = IDD_JSAPP_DIALOG };

protected:
  virtual void DoDataExchange(CDataExchange *pDX); // DDX/DDV support
  CWinThread *readThreadID;

  // Implementation
protected:
  HICON m_hIcon;

  // Generated message map functions
  virtual BOOL OnInitDialog();
  afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
  afx_msg void OnPaint();
  afx_msg HCURSOR OnQueryDragIcon();
  DECLARE_MESSAGE_MAP()
  LRESULT updateConsole(WPARAM, LPARAM);
  LRESULT updateCursorPos(WPARAM, LPARAM);
  HANDLE openSerialPort(const std::string &portName, DWORD baudRate);
  void closeSerialPort(HANDLE hSerial);

public:
  CString m_Text;
  afx_msg void OnEnChangeMfceditbrowseHotas();
  afx_msg void OnBnClickedButton1();
  afx_msg void OnBnClickedButton2();
  afx_msg void OnBnClickedButton3();
  afx_msg void OnBnClickedButton4();
  CString m_CursorX;
  CString m_CursorY;
};
