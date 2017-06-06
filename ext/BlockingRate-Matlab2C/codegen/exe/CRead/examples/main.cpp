//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: main.cpp
//
// MATLAB Coder version            : 3.3
// C/C++ source code generated on  : 02-Jun-2017 16:29:16
//

//***********************************************************************
// This automatically generated example C main file shows how to call
// entry-point functions that MATLAB Coder generated. You must customize
// this file for your application. Do not modify this file directly.
// Instead, make a copy of this file, modify it, and integrate it into
// your development environment.
//
// This file initializes entry-point function arguments to a default
// size and value before calling the entry-point functions. It does
// not store or use any values returned from the entry-point functions.
// If necessary, it does pre-allocate memory for returned values.
// You can use this file as a starting point for a main function that
// you can deploy in your application.
//
// After you copy the file, and before you deploy it, you must make the
// following changes:
// * For variable-size function arguments, change the example sizes to
// the sizes that your application requires.
// * Change the example values of function arguments to the values that
// your application requires.
// * If the entry-point functions return values, store these values or
// otherwise use them as required by your application.
//
//***********************************************************************
// Include Files
#include "rt_nonfinite.h"
#include "CRead.h"
#include "CWrite.h"
#include "main.h"
#include "CRead_terminate.h"
#include "CRead_emxAPI.h"
#include "CRead_initialize.h"

// Function Declarations
static void argInit_1x2_real_T(double result[2]);
static emxArray_char_T *argInit_1xUnbounded_char_T();
static char argInit_char_T();
static double argInit_real_T();
static emxArray_real_T *c_argInit_UnboundedxUnbounded_r();
static void main_CRead();
static void main_CWrite();

// Function Definitions

//
// Arguments    : double result[2]
// Return Type  : void
//
static void argInit_1x2_real_T(double result[2])
{
  int idx1;

  // Loop over the array to initialize each element.
  for (idx1 = 0; idx1 < 2; idx1++) {
    // Set the value of the array element.
    // Change this value to the value that the application requires.
    result[idx1] = argInit_real_T();
  }
}

//
// Arguments    : void
// Return Type  : emxArray_char_T *
//
static emxArray_char_T *argInit_1xUnbounded_char_T()
{
  emxArray_char_T *result;
  static int iv0[2] = { 1, 2 };

  int idx1;

  // Set the size of the array.
  // Change this size to the value that the application requires.
  result = emxCreateND_char_T(2, *(int (*)[2])&iv0[0]);

  // Loop over the array to initialize each element.
  for (idx1 = 0; idx1 < result->size[1U]; idx1++) {
    // Set the value of the array element.
    // Change this value to the value that the application requires.
    result->data[result->size[0] * idx1] = argInit_char_T();
  }

  return result;
}

//
// Arguments    : void
// Return Type  : char
//
static char argInit_char_T()
{
  return '?';
}

//
// Arguments    : void
// Return Type  : double
//
static double argInit_real_T()
{
  return 0.0;
}

//
// Arguments    : void
// Return Type  : emxArray_real_T *
//
static emxArray_real_T *c_argInit_UnboundedxUnbounded_r()
{
  emxArray_real_T *result;
  static int iv1[2] = { 2, 2 };

  int idx0;
  int idx1;

  // Set the size of the array.
  // Change this size to the value that the application requires.
  result = emxCreateND_real_T(2, *(int (*)[2])&iv1[0]);

  // Loop over the array to initialize each element.
  for (idx0 = 0; idx0 < result->size[0U]; idx0++) {
    for (idx1 = 0; idx1 < result->size[1U]; idx1++) {
      // Set the value of the array element.
      // Change this value to the value that the application requires.
      result->data[idx0 + result->size[0] * idx1] = argInit_real_T();
    }
  }

  return result;
}

//
// Arguments    : void
// Return Type  : void
//
static void main_CRead()
{
  emxArray_real_T *x;
  emxArray_char_T *filename;
  double dv0[2];
  emxInitArray_real_T(&x, 2);

  // Initialize function 'CRead' input arguments.
  // Initialize function input argument 'filename'.
  filename = argInit_1xUnbounded_char_T();

  // Initialize function input argument 'xsize'.
  // Call the entry-point 'CRead'.
  argInit_1x2_real_T(dv0);
  CRead(filename, dv0, x);
  emxDestroyArray_real_T(x);
  emxDestroyArray_char_T(filename);
}

//
// Arguments    : void
// Return Type  : void
//
static void main_CWrite()
{
  emxArray_char_T *filename;
  emxArray_real_T *x;

  // Initialize function 'CWrite' input arguments.
  // Initialize function input argument 'filename'.
  filename = argInit_1xUnbounded_char_T();

  // Initialize function input argument 'x'.
  x = c_argInit_UnboundedxUnbounded_r();

  // Call the entry-point 'CWrite'.
  CWrite(filename, x);
  emxDestroyArray_real_T(x);
  emxDestroyArray_char_T(filename);
}

//
// Arguments    : int argc
//                const char * const argv[]
// Return Type  : int
//
int main(int, const char * const [])
{
  // Initialize the application.
  // You do not need to do this more than one time.
  CRead_initialize();

  // Invoke the entry-point functions.
  // You can call entry-point functions multiple times.
  main_CRead();
  main_CWrite();

  // Terminate the application.
  // You do not need to do this more than one time.
  CRead_terminate();
  return 0;
}

//
// File trailer for main.cpp
//
// [EOF]
//
