//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: fopen.cpp
//
// MATLAB Coder version            : 3.3
// C/C++ source code generated on  : 02-Jun-2017 16:29:16
//

// Include Files
#include "rt_nonfinite.h"
#include "CRead.h"
#include "CWrite.h"
#include "fopen.h"
#include "fileManager.h"

// Function Definitions

//
// Arguments    : const emxArray_char_T *filename
// Return Type  : double
//
double b_fopen(const emxArray_char_T *filename)
{
  double fileID;
  boolean_T b_bool;
  int kstr;
  int exitg1;
  static const char cv0[3] = { 'a', 'l', 'l' };

  b_bool = false;
  if (filename->size[1] == 3) {
    kstr = 0;
    do {
      exitg1 = 0;
      if (kstr + 1 < 4) {
        if (filename->data[kstr] != cv0[kstr]) {
          exitg1 = 1;
        } else {
          kstr++;
        }
      } else {
        b_bool = true;
        exitg1 = 1;
      }
    } while (exitg1 == 0);
  }

  if (b_bool) {
    fileID = 0.0;
  } else {
    fileID = fileManager(filename);
  }

  return fileID;
}

//
// Arguments    : const emxArray_char_T *filename
// Return Type  : double
//
double c_fopen(const emxArray_char_T *filename)
{
  return e_fileManager(filename);
}

//
// File trailer for fopen.cpp
//
// [EOF]
//
