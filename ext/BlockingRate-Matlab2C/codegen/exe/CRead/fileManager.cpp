//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: fileManager.cpp
//
// MATLAB Coder version            : 3.3
// C/C++ source code generated on  : 02-Jun-2017 16:29:16
//

// Include Files
#include "rt_nonfinite.h"
#include "CRead.h"
#include "CWrite.h"
#include "fileManager.h"
#include "CRead_emxutil.h"

// Variable Definitions
static FILE * eml_openfiles[20];
static boolean_T eml_autoflush[20];

// Function Declarations
static FILE * d_fileManager(signed char varargin_1);
static signed char filedata();
static void getfilestar(double fid, FILE * *filestar, boolean_T *autoflush);
static double rt_roundd_snf(double u);

// Function Definitions

//
// Arguments    : signed char varargin_1
// Return Type  : FILE *
//
static FILE * d_fileManager(signed char varargin_1)
{
  FILE * f;
  signed char fileid;
  fileid = varargin_1;
  if (varargin_1 < 0) {
    fileid = -1;
  }

  if (fileid >= 3) {
    f = eml_openfiles[fileid - 3];
  } else if (fileid == 0) {
    f = stdin;
  } else if (fileid == 1) {
    f = stdout;
  } else if (fileid == 2) {
    f = stderr;
  } else {
    f = NULL;
  }

  return f;
}

//
// Arguments    : void
// Return Type  : signed char
//
static signed char filedata()
{
  signed char f;
  signed char k;
  boolean_T exitg1;
  f = 0;
  k = 1;
  exitg1 = false;
  while ((!exitg1) && (k < 21)) {
    if (eml_openfiles[k - 1] == NULL) {
      f = k;
      exitg1 = true;
    } else {
      k++;
    }
  }

  return f;
}

//
// Arguments    : double fid
//                FILE * *filestar
//                boolean_T *autoflush
// Return Type  : void
//
static void getfilestar(double fid, FILE * *filestar, boolean_T *autoflush)
{
  signed char fileid;
  fileid = (signed char)rt_roundd_snf(fid);
  if ((fileid < 0) || (fid != fileid)) {
    fileid = -1;
  }

  if (fileid >= 3) {
    *filestar = eml_openfiles[fileid - 3];
    *autoflush = eml_autoflush[fileid - 3];
  } else if (fileid == 0) {
    *filestar = stdin;
    *autoflush = true;
  } else if (fileid == 1) {
    *filestar = stdout;
    *autoflush = true;
  } else if (fileid == 2) {
    *filestar = stderr;
    *autoflush = true;
  } else {
    *filestar = NULL;
    *autoflush = true;
  }
}

//
// Arguments    : double u
// Return Type  : double
//
static double rt_roundd_snf(double u)
{
  double y;
  if (std::abs(u) < 4.503599627370496E+15) {
    if (u >= 0.5) {
      y = std::floor(u + 0.5);
    } else if (u > -0.5) {
      y = u * 0.0;
    } else {
      y = std::ceil(u - 0.5);
    }
  } else {
    y = u;
  }

  return y;
}

//
// Arguments    : double varargin_1
// Return Type  : FILE *
//
FILE * b_fileManager(double varargin_1)
{
  FILE * f;
  boolean_T a;
  getfilestar(varargin_1, &f, &a);
  return f;
}

//
// Arguments    : double varargin_1
// Return Type  : int
//
int c_fileManager(double varargin_1)
{
  int f;
  signed char fileid;
  FILE * filestar;
  int cst;
  f = -1;
  fileid = (signed char)rt_roundd_snf(varargin_1);
  if ((fileid < 0) || (varargin_1 != fileid)) {
    fileid = -1;
  }

  filestar = d_fileManager(fileid);
  if ((filestar == NULL) || (fileid < 3)) {
  } else {
    cst = fclose(filestar);
    if (cst == 0) {
      f = 0;
      eml_openfiles[fileid - 3] = NULL;
      eml_autoflush[fileid - 3] = true;
    }
  }

  return f;
}

//
// Arguments    : const emxArray_char_T *varargin_1
// Return Type  : double
//
double e_fileManager(const emxArray_char_T *varargin_1)
{
  signed char fileid;
  signed char j;
  emxArray_char_T *r1;
  int i2;
  int loop_ub;
  FILE * filestar;
  char cv3[3];
  static const char cv4[3] = { 'w', 'b', '\x00' };

  fileid = -1;
  j = filedata();
  if (!(j < 1)) {
    emxInit_char_T(&r1, 2);
    i2 = r1->size[0] * r1->size[1];
    r1->size[0] = 1;
    r1->size[1] = varargin_1->size[1] + 1;
    emxEnsureCapacity((emxArray__common *)r1, i2, sizeof(char));
    loop_ub = varargin_1->size[1];
    for (i2 = 0; i2 < loop_ub; i2++) {
      r1->data[r1->size[0] * i2] = varargin_1->data[varargin_1->size[0] * i2];
    }

    r1->data[r1->size[0] * varargin_1->size[1]] = '\x00';
    for (i2 = 0; i2 < 3; i2++) {
      cv3[i2] = cv4[i2];
    }

    filestar = fopen(&r1->data[0], cv3);
    emxFree_char_T(&r1);
    if (filestar != NULL) {
      eml_openfiles[j - 1] = filestar;
      eml_autoflush[j - 1] = true;
      i2 = j + 2;
      if (i2 > 127) {
        i2 = 127;
      }

      fileid = (signed char)i2;
    }
  }

  return fileid;
}

//
// Arguments    : double varargin_1
//                FILE * *f
//                boolean_T *a
// Return Type  : void
//
void f_fileManager(double varargin_1, FILE * *f, boolean_T *a)
{
  getfilestar(varargin_1, f, a);
}

//
// Arguments    : const emxArray_char_T *varargin_1
// Return Type  : double
//
double fileManager(const emxArray_char_T *varargin_1)
{
  signed char fileid;
  signed char j;
  emxArray_char_T *r0;
  int i0;
  int loop_ub;
  FILE * filestar;
  char cv1[3];
  static const char cv2[3] = { 'r', 'b', '\x00' };

  fileid = -1;
  j = filedata();
  if (!(j < 1)) {
    emxInit_char_T(&r0, 2);
    i0 = r0->size[0] * r0->size[1];
    r0->size[0] = 1;
    r0->size[1] = varargin_1->size[1] + 1;
    emxEnsureCapacity((emxArray__common *)r0, i0, sizeof(char));
    loop_ub = varargin_1->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      r0->data[r0->size[0] * i0] = varargin_1->data[varargin_1->size[0] * i0];
    }

    r0->data[r0->size[0] * varargin_1->size[1]] = '\x00';
    for (i0 = 0; i0 < 3; i0++) {
      cv1[i0] = cv2[i0];
    }

    filestar = fopen(&r0->data[0], cv1);
    emxFree_char_T(&r0);
    if (filestar != NULL) {
      eml_openfiles[j - 1] = filestar;
      eml_autoflush[j - 1] = true;
      i0 = j + 2;
      if (i0 > 127) {
        i0 = 127;
      }

      fileid = (signed char)i0;
    }
  }

  return fileid;
}

//
// Arguments    : void
// Return Type  : void
//
void filedata_init()
{
  FILE * a;
  int i;
  a = NULL;
  for (i = 0; i < 20; i++) {
    eml_autoflush[i] = false;
    eml_openfiles[i] = a;
  }
}

//
// File trailer for fileManager.cpp
//
// [EOF]
//
