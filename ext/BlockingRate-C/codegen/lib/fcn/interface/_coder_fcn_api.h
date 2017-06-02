/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_fcn_api.h
 *
 * MATLAB Coder version            : 3.3
 * C/C++ source code generated on  : 01-Jun-2017 22:16:22
 */

#ifndef _CODER_FCN_API_H
#define _CODER_FCN_API_H

/* Include Files */
#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"
#include <stddef.h>
#include <stdlib.h>
#include "_coder_fcn_api.h"

/* Variable Declarations */
extern emlrtCTX emlrtRootTLSGlobal;
extern emlrtContext emlrtContextGlobal;

/* Function Declarations */
extern real_T fcn(real_T x);
extern void fcn_api(const mxArray * const prhs[1], const mxArray *plhs[1]);
extern void fcn_atexit(void);
extern void fcn_initialize(void);
extern void fcn_terminate(void);
extern void fcn_xil_terminate(void);

#endif

/*
 * File trailer for _coder_fcn_api.h
 *
 * [EOF]
 */
