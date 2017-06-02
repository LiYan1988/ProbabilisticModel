/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_CRead_api.h
 *
 * MATLAB Coder version            : 3.3
 * C/C++ source code generated on  : 01-Jun-2017 11:56:19
 */

#ifndef _CODER_CREAD_API_H
#define _CODER_CREAD_API_H

/* Include Files */
#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"
#include <stddef.h>
#include <stdlib.h>
#include "_coder_CRead_api.h"

/* Type Definitions */
#ifndef struct_emxArray_char_T
#define struct_emxArray_char_T

struct emxArray_char_T
{
  char_T *data;
  int32_T *size;
  int32_T allocatedSize;
  int32_T numDimensions;
  boolean_T canFreeData;
};

#endif                                 /*struct_emxArray_char_T*/

#ifndef typedef_emxArray_char_T
#define typedef_emxArray_char_T

typedef struct emxArray_char_T emxArray_char_T;

#endif                                 /*typedef_emxArray_char_T*/

#ifndef struct_emxArray_real_T
#define struct_emxArray_real_T

struct emxArray_real_T
{
  real_T *data;
  int32_T *size;
  int32_T allocatedSize;
  int32_T numDimensions;
  boolean_T canFreeData;
};

#endif                                 /*struct_emxArray_real_T*/

#ifndef typedef_emxArray_real_T
#define typedef_emxArray_real_T

typedef struct emxArray_real_T emxArray_real_T;

#endif                                 /*typedef_emxArray_real_T*/

/* Variable Declarations */
extern emlrtCTX emlrtRootTLSGlobal;
extern emlrtContext emlrtContextGlobal;

/* Function Declarations */
extern void CRead(emxArray_char_T *filename, real_T xsize[2], emxArray_real_T *x);
extern void CRead_api(const mxArray * const prhs[2], const mxArray *plhs[1]);
extern void CRead_atexit(void);
extern void CRead_initialize(void);
extern void CRead_terminate(void);
extern void CRead_xil_terminate(void);
extern void CWrite(emxArray_char_T *filename, emxArray_real_T *x);
extern void CWrite_api(const mxArray *prhs[2], const mxArray *plhs[1]);

#endif

/*
 * File trailer for _coder_CRead_api.h
 *
 * [EOF]
 */
