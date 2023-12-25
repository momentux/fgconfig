
#include "JsApp.h"
#include "JsAppDlg.h"
#include "stdafx.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

BEGIN_MESSAGE_MAP(CJsAppApp, CWinApp)
ON_COMMAND(ID_HELP, &CWinApp::OnHelp)
END_MESSAGE_MAP()

CJsAppApp::CJsAppApp() {
  // support Restart Manager
  m_dwRestartManagerSupportFlags = AFX_RESTART_MANAGER_SUPPORT_RESTART;
}

CJsAppApp theApp;

BOOL CJsAppApp::InitInstance() {
  // InitCommonControlsEx() is required on Windows XP if an application
  // manifest specifies use of ComCtl32.dll version 6 or later to enable
  // visual styles.  Otherwise, any window creation will fail.
  INITCOMMONCONTROLSEX InitCtrls;
  InitCtrls.dwSize = sizeof(InitCtrls);
  InitCtrls.dwICC = ICC_WIN95_CLASSES;
  InitCommonControlsEx(&InitCtrls);

  CWinApp::InitInstance();

  AfxEnableControlContainer();

  CShellManager *pShellManager = new CShellManager;

  SetRegistryKey(_T("Local AppWizard-Generated Applications"));

  CJsAppDlg dlg;
  m_pMainWnd = &dlg;
  INT_PTR nResponse = dlg.DoModal();
  if (nResponse == IDOK) {
    // TODO: Place code here to handle when the dialog is
    //  dismissed with OK
  } else if (nResponse == IDCANCEL) {
    // TODO: Place code here to handle when the dialog is
    //  dismissed with Cancel
  }

  if (pShellManager != NULL) {
    delete pShellManager;
  }

  // Since the dialog has been closed, return FALSE so that we exit the
  //  application, rather than start the application's message pump.
  return FALSE;
}
