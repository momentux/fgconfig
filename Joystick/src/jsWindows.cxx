/*
PLIB - A Suite of Portable Game Libraries
Copyright (C) 1998,2002  Steve Baker

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Library General Public
License as published by the Free Software Foundation; either
version 2 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Library General Public License for more details.

You should have received a copy of the GNU Library General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA

For further information visit http://plib.sourceforge.net

$Id: jsWindows.cxx 2114 2006-12-21 20:53:13Z fayjf $
*/
#include "JsAppDlg.h"
#include "StdAfx.h"
#include "js.h"

#define LMFD_ID 45906
#define RMFD_ID 45905
#define HOTAS_ID 1028
#define AUX_THROTTLE_ID 46727
#define STICK_ID 45322

#if defined(UL_WIN32)

#define LMFD_FILENAME "LMFD_CONFIG.txt"
#define RMFD_FILENAME "RMFD_CONFIG.txt"
#define HOTAS_FILENAME "HOTAS_CONFIG.txt"
#define AHCP_FILENAME "AHCP_CONFIG.txt"
#define STICK_FILENAME "STICK_CONFIG.txt"

#define _JS_MAX_AXES_WIN 8 /* X,Y,Z,R,U,V,POV_X,POV_Y */

int cursorX, cursorY;

struct os_specific_s {
  JOYCAPS jsCaps;
  JOYINFOEX js;
  UINT js_id;
  static bool getOEMProductName(jsJoystick *joy, char *buf, int buf_sz);
};

extern CWnd *pCurrentDlg;
extern CString consoleString;
// Inspired by
// http://msdn.microsoft.com/archive/en-us/dnargame/html/msdn_sidewind3d.asp

bool os_specific_s::getOEMProductName(jsJoystick *joy, char *buf, int buf_sz) {
  if (joy->error)
    return false;

  union {
    char key[256];
    char value[256];
  };
  char OEMKey[256];

  HKEY hKey;
  DWORD dwcb;
  LONG lr;

  // Open .. MediaResources\CurrentJoystickSettings
  sprintf(key, "%s\\%s\\%s", REGSTR_PATH_JOYCONFIG, joy->os->jsCaps.szRegKey, REGSTR_KEY_JOYCURR);

  lr = RegOpenKeyEx(HKEY_LOCAL_MACHINE, (LPCWSTR)key, 0, KEY_QUERY_VALUE, &hKey);

  if (lr != ERROR_SUCCESS)
    return false;

  // Get OEM Key name
  dwcb = sizeof(OEMKey);

  // JOYSTICKID1-16 is zero-based; registry entries for VJOYD are 1-based.
  sprintf(value, "Joystick%d%s", joy->os->js_id + 1, REGSTR_VAL_JOYOEMNAME);

  lr = RegQueryValueEx(hKey, (LPCWSTR)value, 0, 0, (LPBYTE)OEMKey, &dwcb);
  RegCloseKey(hKey);

  if (lr != ERROR_SUCCESS)
    return false;

  // Open OEM Key from ...MediaProperties
  sprintf(key, "%s\\%s", REGSTR_PATH_JOYOEM, OEMKey);

  lr = RegOpenKeyEx(HKEY_LOCAL_MACHINE, (LPCWSTR)key, 0, KEY_QUERY_VALUE, &hKey);

  if (lr != ERROR_SUCCESS)
    return false;

  // Get OEM Name
  dwcb = buf_sz;

  lr = RegQueryValueEx(hKey, REGSTR_VAL_JOYOEMNAME, 0, 0, (LPBYTE)buf, &dwcb);
  RegCloseKey(hKey);

  if (lr != ERROR_SUCCESS)
    return false;

  return true;
}

bool jsJoystick::loadButtonTypeFromFile(char fileName[MAX_FILE_NAME_CHAR]) {
  char tmpChar = '0';
  int tmp;
  int buttonID = 0;

  axesNeeded = false;
  povNeeded = false;
  FILE *fp = fopen(fileName, "r");

  if (fp == NULL) {
    consoleString.Format(_T("\nCould not open file: %s\n"), fileName);
    pCurrentDlg->PostMessageW(REFRESH_CONSOLE);
    return (false);
  }

  while (tmpChar != '\n')
    fscanf(fp, "%c", &tmpChar);

  while (!feof(fp)) {
    fscanf(fp, "%d ", &buttonID);

    if (buttonID <= 64) {
      fscanf(fp, "%d %d %d\n", &buttonType[buttonID - 1], &RES_MSGID[buttonID - 1],
             &RES_MSGID_LONG_PRESS[buttonID - 1]);
    } else if (buttonID <= 200) {
      fscanf(fp, "%d %d %d\n", &axesType[buttonID - FIRST_AXES_ID], &RES_MSGID_AXES[buttonID - FIRST_AXES_ID], &tmp);
      if ((axesNeeded == false) && (axesType[buttonID - FIRST_AXES_ID] != NA)) {
        axesNeeded = true;
      }
    } else if (buttonID <= 300) {
      fscanf(fp, "%d %d %d\n", &povType[buttonID - FIRST_POV_ID], &RES_MSGID_POV[buttonID - FIRST_POV_ID], &tmp);
      if ((povNeeded == false) && (povType[buttonID - FIRST_POV_ID] != NA)) {
        povNeeded = true;
      }
    }
  }

  return (true);
}

void jsJoystick::open() {
  name[0] = '\0';

  os->js.dwFlags = JOY_RETURNALL;
  os->js.dwSize = sizeof(os->js);

  memset(&(os->jsCaps), 0, sizeof(os->jsCaps));

  error = joyGetDevCaps(os->js_id, &(os->jsCaps), sizeof(os->jsCaps));

  num_axes = 0;
  num_buttons = 0;

  if (error == JOYERR_NOERROR) {
    num_buttons = os->jsCaps.wNumButtons;
    num_axes = os->jsCaps.wNumAxes;

    switch (os->jsCaps.wPid) {
    case LMFD_ID:
      sprintf(name, "LMFD");
      loadButtonTypeFromFile(LMFD_FILENAME);
      break;

    case RMFD_ID:
      sprintf(name, "RMFD");
      loadButtonTypeFromFile(RMFD_FILENAME);
      break;

    case HOTAS_ID:
      sprintf(name, "HOTAS");
      loadButtonTypeFromFile(HOTAS_FILENAME);
      break;

    case AUX_THROTTLE_ID:
      sprintf(name, "AHCP");
      loadButtonTypeFromFile(AHCP_FILENAME);
      break;

    case STICK_ID:
      sprintf(name, "STICK");
      loadButtonTypeFromFile(STICK_FILENAME);
      break;

    default:
      break;
    }

    consoleString = CString(name) + _T(" Connected\n");
    pCurrentDlg->PostMessageW(REFRESH_CONSOLE);
  }
#if 0
	// Windows joystick drivers may provide any combination of
	// X,Y,Z,R,U,V,POV - not necessarily the first n of these.
	if ( os->jsCaps.wCaps & JOYCAPS_HASPOV )
	{
		num_axes = _JS_MAX_AXES_WIN ;
		min [ 7 ] = -1.0 ; max [ 7 ] = 1.0 ;  // POV Y
		min [ 6 ] = -1.0 ; max [ 6 ] = 1.0 ;  // POV X
	}
	else
		num_axes = 6 ;

	min [ 5 ] = (float) os->jsCaps.wVmin ; max [ 5 ] = (float) os->jsCaps.wVmax ;
	min [ 4 ] = (float) os->jsCaps.wUmin ; max [ 4 ] = (float) os->jsCaps.wUmax ;
	min [ 3 ] = (float) os->jsCaps.wRmin ; max [ 3 ] = (float) os->jsCaps.wRmax ;
	min [ 2 ] = (float) os->jsCaps.wZmin ; max [ 2 ] = (float) os->jsCaps.wZmax ;
	min [ 1 ] = (float) os->jsCaps.wYmin ; max [ 1 ] = (float) os->jsCaps.wYmax ;
	min [ 0 ] = (float) os->jsCaps.wXmin ; max [ 0 ] = (float) os->jsCaps.wXmax ;


	for ( int i = 0 ; i < num_axes ; i++ )
	{
		center    [ i ] = ( max[i] + min[i] ) / 2.0f ;
		dead_band [ i ] = 0.0f ;
		saturate  [ i ] = 1.0f ;
	}
#endif
}

void jsJoystick::close() { delete os; }

jsJoystick::jsJoystick(int ident) {
  id = ident;

  os = new struct os_specific_s;

  if (ident >= 0 && ident < (int)joyGetNumDevs()) {
    os->js_id = JOYSTICKID1 + ident;
    open();
  } else {
    num_axes = 0;
    setError();
  }
}

void jsJoystick::rawRead(int *buttons, float *axes) {
  if (error) {
    if (buttons)
      *buttons = 0;

    if (axes)
      for (int i = 0; i < num_axes; i++)
        axes[i] = 1500.0f;

    return;
  }

  MMRESULT status = joyGetPosEx(os->js_id, &(os->js));

  if (status != JOYERR_NOERROR) {
    setError();
    return;
  }

  if (buttons != NULL)
    *buttons = (int)os->js.dwButtons;

  if (axes != NULL) {
    /* WARNING - Fall through case clauses!! */

    switch (num_axes) {
    case 8:
      // Generate two POV axes from the POV hat angle.
      // Low 16 bits of js.dwPOV gives heading (clockwise from ahead) in
      //   hundredths of a degree, or 0xFFFF when idle.

      if ((os->js.dwPOV & 0xFFFF) == 0xFFFF) {
        axes[6] = 0.0;
        axes[7] = 0.0;
      } else {
        // This is the contentious bit: how to convert angle to X/Y.
        //    wk: I know of no define for PI that we could use here:
        //    SG_PI would pull in sg, M_PI is undefined for MSVC
        // But the accuracy of the value of PI is very unimportant at
        // this point.

        float s = (float)sin((os->js.dwPOV & 0xFFFF) * (0.01 * 3.1415926535f / 180));
        float c = (float)cos((os->js.dwPOV & 0xFFFF) * (0.01 * 3.1415926535f / 180));

        // Convert to coordinates on a square so that North-East
        // is (1,1) not (.7,.7), etc.
        // s and c cannot both be zero so we won't divide by zero.
        if (fabs(s) < fabs(c)) {
          axes[6] = (c < 0.0) ? -s / c : s / c;
          axes[7] = (c < 0.0) ? -1.0f : 1.0f;
        } else {
          axes[6] = (s < 0.0) ? -1.0f : 1.0f;
          axes[7] = (s < 0.0) ? -c / s : c / s;
        }
      }

    case 6:
      axes[5] = (float)os->js.dwVpos;
    case 5:
      axes[4] = (float)os->js.dwUpos;
    case 4:
      axes[3] = (float)os->js.dwRpos;
    case 3:
      axes[2] = (float)os->js.dwZpos;
    case 2:
      axes[1] = (float)os->js.dwYpos;
    case 1:
      axes[0] = (float)os->js.dwXpos;
      break;

      // default:
      //  ulSetError ( UL_WARNING, "PLIB_JS: Wrong num_axes. Joystick input is now invalid" ) ;
    }
  }
}

bool jsJoystick::checkForReleasedStat(unsigned short buttonID, bool *LongPress) {
  int longTimeOut = 0;
  DWORD tmpButton;
  while (1) {
    if ((longTimeOut > (LONG_PRESS_DURATION_TIMEOUT / POLL_DELAY))) {
      *LongPress = true;
      return (TRUE);
    } else if (longTimeOut > (LONG_PRESS_DURATION / POLL_DELAY)) {
      *LongPress = true;
      longTimeOut++;
    } else {
      *LongPress = false;
      longTimeOut++;
    }
    Sleep(POLL_DELAY);

    MMRESULT status = joyGetPosEx(os->js_id, &(os->js));
    if (status != JOYERR_NOERROR) {
      setError();
      *LongPress = FALSE;
      return (FALSE);
    }

    tmpButton = os->js.dwButtons;
    tmpButton = tmpButton >> buttonID;
    if ((tmpButton & 0x1) == 0) {
      return (TRUE);
    }
  }
}

bool jsJoystick::checkForTogggle(unsigned short buttonID) {
  DWORD tmpButton;
  DWORD prevButton;

  MMRESULT status = joyGetPosEx(os->js_id, &(os->js));
  if (status != JOYERR_NOERROR) {
    setError();
    return (FALSE);
  }

  prevButton = prevButtonStat[buttonID];

  tmpButton = os->js.dwButtons;
  tmpButton = tmpButton >> buttonID;

  if ((tmpButton & 0x1) != (prevButton & 0x1)) {
    return (TRUE);
  }
}

void jsJoystick::initButtonStat() {
  DWORD tmpButton;
  MMRESULT status = joyGetPosEx(os->js_id, &(os->js));

  tmpButton = os->js.dwButtons;

  for (unsigned short i = 0; i < num_buttons; i++) {
    prevButtonStat[i] = (tmpButton >> i) & 0x1;
  }
}

void jsJoystick::setButtonStat(DWORD aButton) {
  for (unsigned short i = 0; i < num_buttons; i++) {
    prevButtonStat[i] = (aButton >> i) & 0x1;
  }
}

void jsJoystick::getButtonPressOnRelease(int buttons[], bool LongPress[], int &numButtons, int &X_pos, int &Y_pos,
                                         unsigned short currToggleStat[MAX_BUTTONS], unsigned short &pov) {
  unsigned short buttonList[MAX_BUTTONS];
  unsigned short numButtonsPressed = 0;
  bool releasedStat = false;
  bool toggleStat = false;

  unsigned short povTimeout = 0;

  pov = 0;
  numButtons = 0;

  int buttonId = 0;
  if (error) {
    buttons[0] = 0;
    numButtons = 0;
    return;
  }

  MMRESULT status = joyGetPosEx(os->js_id, &(os->js));

  // if(os->js.dwButtons>0)
  {
    checkForToggledBit(os->js.dwButtons, buttonList, &numButtonsPressed, currToggleStat);

    for (unsigned short i = 0; i < numButtonsPressed; i++) {
      switch (buttonType[buttonList[i]]) {
      case PRESS_RELEASE_SHORT_LONG:
        releasedStat = checkForReleasedStat(buttonList[i], &(LongPress[i]));
        if (releasedStat == TRUE) {
          buttons[i] = buttonList[i];
          break;
        } else {
          if (*LongPress == TRUE) {
            buttons[i] = buttonList[i];

            consoleString.Format(_T("\n Button ID: %d depressed for more than 5sec\n"), buttons[0]);
            pCurrentDlg->PostMessageW(REFRESH_CONSOLE);
            break;
          } else {
            buttons[i] = 0;
            LongPress[i] = 0;
            consoleString.Format(_T("\n Error set in joystick: %s\n"), name);
            pCurrentDlg->PostMessageW(REFRESH_CONSOLE);
            break;
          }
        }
        break;

      case PRESS_RELEASE_SHORT_CONTINUOUS:
        LongPress[i] == FALSE;
        buttons[i] = buttonList[i];
        break;

      case TOGGLE_SWITCH:
        LongPress[i] == FALSE;
        buttons[i] = buttonList[i];
        break;

      default:
        buttons[i] = 0;
        consoleString.Format(_T("\nInvalid Button type: %d\n"), buttonType[buttonList[i]]);
        pCurrentDlg->PostMessageW(REFRESH_CONSOLE);
        continue;
      }
    }

    numButtons = numButtonsPressed;
    setButtonStat(os->js.dwButtons);
  }

  if (axesNeeded == 1) {
    if (os->js.dwXpos != 32767 || os->js.dwYpos != 32767) {
      X_pos = (long)os->js.dwXpos - 32767;
      Y_pos = (long)os->js.dwYpos - 32767;
    }
  }

  if (povNeeded == 1) {
    if (os->js.dwPOV != 65535) {
      switch (os->js.dwPOV) {
      case 0:
        pov = POV1;
        break;

      case 4500:
        pov = POV2;
        break;

      case 9000:
        pov = POV3;
        break;

      case 13500:
        pov = POV4;
        break;

      case 18000:
        pov = POV5;
        break;

      case 22500:
        pov = POV6;
        break;

      case 27000:
        pov = POV7;
        break;

      case 31500:
        pov = POV8;
        break;
      }

      while (1) {
        povTimeout = povTimeout + 50;
        if (povTimeout > 2000)
          break;

        MMRESULT status = joyGetPosEx(os->js_id, &(os->js));

        if (os->js.dwPOV == 65535)
          break;

        Sleep(50);
      }
    }
  }
}

void jsJoystick::checkForToggledBit(DWORD currButton, unsigned short buttonList[MAX_BUTTONS],
                                    unsigned short *numButtonsPressed, unsigned short currToggleStat[MAX_BUTTONS]) {
  unsigned short cnt = 0;
  DWORD tmpCurrWord;

  tmpCurrWord = currButton;

  for (int i = 0; i < num_buttons; i++) {
    if ((buttonType[i] == TOGGLE_SWITCH) || (buttonType[i] == PRESS_RELEASE_SHORT_LONG)) {
      if ((tmpCurrWord & 0x1) == 1 && prevButtonStat[i] == 0) {
        buttonList[cnt] = i;
        currToggleStat[cnt] = TOGGLE_ON;
        cnt = cnt + 1;
      } else if ((tmpCurrWord & 0x1) == 0 && prevButtonStat[i] == 1) {
        if (buttonType[i] == TOGGLE_SWITCH) {
          currToggleStat[cnt] = TOGGLE_OFF;
          buttonList[cnt] = i;
          cnt = cnt + 1;
        }
      }
    } else if (buttonType[i] == PRESS_RELEASE_SHORT_CONTINUOUS) {
      if ((tmpCurrWord & 0x1) == 1) {
        buttonList[cnt] = i;
        currToggleStat[cnt] = TOGGLE_ON;
        cnt = cnt + 1;
      }
    }

    tmpCurrWord = tmpCurrWord >> 1;
  }

  *numButtonsPressed = cnt;
}

void jsInit() {}

#endif
