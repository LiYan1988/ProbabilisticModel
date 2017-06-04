//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: CRead_initialize.cpp
//
// MATLAB Coder version            : 3.3
// C/C++ source code generated on  : 02-Jun-2017 16:29:16
//

// Include Files
#include "rt_nonfinite.h"
#include "CRead.h"
#include "CWrite.h"
#include "CRead_initialize.h"
#include "fileManager.h"

// Function Definitions

//
// Arguments    : void
// Return Type  : void
//
void CRead_initialize()
{
  rt_InitInfAndNaN(8U);
  filedata_init();
}

//
// File trailer for CRead_initialize.cpp
//
// [EOF]
//
