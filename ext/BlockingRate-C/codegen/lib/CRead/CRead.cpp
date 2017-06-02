//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: CRead.cpp
//
// MATLAB Coder version            : 3.3
// C/C++ source code generated on  : 01-Jun-2017 11:56:19
//

// Include Files
#include "rt_nonfinite.h"
#include "CRead.h"
#include "CWrite.h"
#include "fclose.h"
#include "fread.h"
#include "fopen.h"

// Function Definitions

//
// Arguments    : const emxArray_char_T *filename
//                const double xsize[2]
//                emxArray_real_T *x
// Return Type  : void
//
void CRead(const emxArray_char_T *filename, const double xsize[2],
           emxArray_real_T *x)
{
  double fileID;
  fileID = b_fopen(filename);
  b_fread(fileID, xsize, x);
  b_fclose(fileID);
}

//
// File trailer for CRead.cpp
//
// [EOF]
//
