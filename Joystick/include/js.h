#ifndef __INCLUDED_JS_H__
#define __INCLUDED_JS_H__ 1
#define JS_NEW

#include "ul.h"

#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h> // -dw- for memcpy

#define _JS_MAX_AXES 16
#define _JS_MAX_BUTTONS 32
#define _JS_MAX_HATS 4
#define MAX_BUTTONS 64
#define JS_TRUE 1
#define JS_FALSE 0
#define POLL_DELAY 20

#define LONG_PRESS_DURATION 1500
#define LONG_PRESS_DURATION_TIMEOUT 5000
#define FIRST_AXES_ID 101
#define FIRST_POV_ID 201
#define TOGGLE_ON 1
#define TOGGLE_OFF 2

#define MAX_FILE_NAME_CHAR 1000
enum eButtonType { PRESS_RELEASE_SHORT_LONG = 0, PRESS_RELEASE_SHORT_CONTINUOUS = 1, TOGGLE_SWITCH = 2 };
enum eAxesType { CURSOR_X = 11, CURSOR_Y = 12, NA = 20 };
enum ePOVType { POV1 = 1, POV2 = 2, POV3 = 3, POV4 = 4, POV5 = 5, POV6 = 6, POV7 = 7, POV8 = 8 };

class jsJoystick {
  int id;

public:
  eButtonType buttonType[64];
  eAxesType axesType[10];
  ePOVType povType[10];

  unsigned short RES_MSGID[64];
  unsigned short RES_MSGID_LONG_PRESS[64];
  unsigned short RES_MSGID_AXES[5];
  unsigned short RES_MSGID_POV[8];

  int axesNeeded, povNeeded;

  unsigned short prevButtonStat[MAX_BUTTONS];

  struct os_specific_s *os;
  friend struct os_specific_s;
  int error;
  char name[128];
  int num_axes;
  int num_buttons;

  float dead_band[_JS_MAX_AXES];
  float saturate[_JS_MAX_AXES];
  float center[_JS_MAX_AXES];
  float max[_JS_MAX_AXES];
  float min[_JS_MAX_AXES];

  void open();
  void close();

  float fudge_axis(float value, int axis) const;

public:
  jsJoystick(int ident = 0);
  ~jsJoystick() { close(); }

  const char *getName() const { return name; }
  int getNumAxes() const { return num_axes; }
  int getNumButtons() const { return num_buttons; }
  int notWorking() const { return error; }
  void setError() { error = JS_TRUE; }

  float getDeadBand(int axis) const { return dead_band[axis]; }
  void setDeadBand(int axis, float db) { dead_band[axis] = db; }

  float getSaturation(int axis) const { return saturate[axis]; }
  void setSaturation(int axis, float st) { saturate[axis] = st; }

  void setMinRange(float *axes) { memcpy(min, axes, num_axes * sizeof(float)); }
  void setMaxRange(float *axes) { memcpy(max, axes, num_axes * sizeof(float)); }
  void setCenter(float *axes) { memcpy(center, axes, num_axes * sizeof(float)); }

  void getMinRange(float *axes) const { memcpy(axes, min, num_axes * sizeof(float)); }
  void getMaxRange(float *axes) const { memcpy(axes, max, num_axes * sizeof(float)); }
  void getCenter(float *axes) const { memcpy(axes, center, num_axes * sizeof(float)); }

  void read(int *buttons, float *axes);
  void rawRead(int *buttons, float *axes);

  void getButtonPressOnRelease(int buttons[], bool LongPress[], int &numButtons, int &X_pos, int &Y_pos,
                               unsigned short currToggleStat[MAX_BUTTONS], unsigned short &pov);

  void checkForToggledBit(DWORD currButton, unsigned short buttonList[MAX_BUTTONS], unsigned short *numButtonsPressed,
                          unsigned short currToggleStat[MAX_BUTTONS]);

  bool loadButtonTypeFromFile(char fileName[MAX_FILE_NAME_CHAR]);

  bool checkForReleasedStat(unsigned short buttonID, bool *longPress);
  bool checkForTogggle(unsigned short buttonID);
  void initButtonStat();
  void setButtonStat(DWORD aButton);

  // bool SetForceFeedBack ( int axe, float force );
};

extern void jsInit();

#endif
