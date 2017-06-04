//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: CWrite.cpp
//
// MATLAB Coder version            : 3.3
// C/C++ source code generated on  : 02-Jun-2017 16:29:16
//

// Include Files
#include "rt_nonfinite.h"
#include "CRead.h"
#include "CWrite.h"
#include "fclose.h"
#include "fileManager.h"
#include "fopen.h"

// Function Definitions

//
// Arguments    : const emxArray_char_T *filename
//                const emxArray_real_T *x
// Return Type  : void
//
void CWrite(const emxArray_char_T *filename, const emxArray_real_T *x)
{
  double fileID;
  FILE * filestar;
  boolean_T autoflush;
  size_t bytesOutSizet;
  fileID = c_fopen(filename);
  f_fileManager(fileID, &filestar, &autoflush);
  if (!(fileID != 0.0)) {
    filestar = NULL;
  }

  if ((filestar == NULL) || ((x->size[0] == 0) || (x->size[1] == 0))) {
  } else {
    bytesOutSizet = fwrite(&x->data[0], (size_t)sizeof(double), (size_t)(x->
      size[0] * x->size[1]), filestar);
    if (((double)bytesOutSizet > 0.0) && autoflush) {
      fflush(filestar);
    }
  }

  b_fclose(fileID);
}

//
// File trailer for CWrite.cpp
//
// [EOF]
//
