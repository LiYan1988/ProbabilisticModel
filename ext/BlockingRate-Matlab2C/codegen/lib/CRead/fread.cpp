//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: fread.cpp
//
// MATLAB Coder version            : 3.3
// C/C++ source code generated on  : 01-Jun-2017 11:56:19
//

// Include Files
#include "rt_nonfinite.h"
#include "CRead.h"
#include "CWrite.h"
#include "fread.h"
#include "CRead_emxutil.h"
#include "fileManager.h"

// Function Declarations
static int div_s32_sat_ceiling(int numerator, int denominator);

// Function Definitions

//
// Arguments    : int numerator
//                int denominator
// Return Type  : int
//
static int div_s32_sat_ceiling(int numerator, int denominator)
{
  int quotient;
  unsigned int absNumerator;
  unsigned int absDenominator;
  boolean_T quotientNeedsNegation;
  unsigned int tempAbsQuotient;
  if (denominator == 0) {
    if (numerator >= 0) {
      quotient = MAX_int32_T;
    } else {
      quotient = MIN_int32_T;
    }
  } else {
    if (numerator < 0) {
      absNumerator = ~(unsigned int)numerator + 1U;
    } else {
      absNumerator = (unsigned int)numerator;
    }

    if (denominator < 0) {
      absDenominator = ~(unsigned int)denominator + 1U;
    } else {
      absDenominator = (unsigned int)denominator;
    }

    quotientNeedsNegation = ((numerator < 0) != (denominator < 0));
    tempAbsQuotient = absNumerator / absDenominator;
    if ((!quotientNeedsNegation) && (tempAbsQuotient >= 2147483647U)) {
      quotient = MAX_int32_T;
    } else if (quotientNeedsNegation && (tempAbsQuotient > 2147483647U)) {
      quotient = MIN_int32_T;
    } else {
      if (!quotientNeedsNegation) {
        absNumerator %= absDenominator;
        if (absNumerator > 0U) {
          tempAbsQuotient++;
        }
      }

      if (quotientNeedsNegation) {
        quotient = -(int)tempAbsQuotient;
      } else {
        quotient = (int)tempAbsQuotient;
      }
    }
  }

  return quotient;
}

//
// Arguments    : double fileID
//                const double sizeA[2]
//                emxArray_real_T *A
// Return Type  : void
//
void b_fread(double fileID, const double sizeA[2], emxArray_real_T *A)
{
  boolean_T doEOF;
  int numRead;
  int c;
  size_t nBytes;
  FILE * filestar;
  boolean_T p;
  emxArray_real_T *At;
  emxArray_real_T *b_A;
  emxArray_real_T *c_A;
  int i1;
  int bytesOut;
  size_t numReadSizeT;
  int loop_ub;
  double tbuf[1024];
  double x;
  if (rtIsInf(sizeA[1])) {
    numRead = (int)sizeA[0];
    c = 1024;
    doEOF = true;
  } else {
    doEOF = false;
    numRead = (int)sizeA[0];
    c = (int)sizeA[1];
  }

  nBytes = sizeof(double);
  filestar = b_fileManager(fileID);
  if ((fileID != 0.0) && (fileID != 1.0) && (fileID != 2.0)) {
    p = true;
  } else {
    p = false;
  }

  if (!p) {
    filestar = NULL;
  }

  emxInit_real_T(&At, 1);
  emxInit_real_T1(&b_A, 2);
  emxInit_real_T(&c_A, 1);
  if (!doEOF) {
    if (filestar == NULL) {
      i1 = A->size[0] * A->size[1];
      A->size[0] = (int)sizeA[0];
      A->size[1] = 0;
      emxEnsureCapacity((emxArray__common *)A, i1, sizeof(double));
    } else {
      c *= numRead;
      i1 = b_A->size[0] * b_A->size[1];
      b_A->size[0] = (int)sizeA[0];
      b_A->size[1] = (int)sizeA[1];
      emxEnsureCapacity((emxArray__common *)b_A, i1, sizeof(double));
      bytesOut = 0;
      numRead = 1;
      while ((bytesOut < c) && (numRead > 0)) {
        numReadSizeT = fread(&b_A->data[bytesOut], nBytes, c - bytesOut,
                             filestar);
        numRead = (int)numReadSizeT;
        bytesOut += (int)numReadSizeT;
      }

      i1 = b_A->size[0] * b_A->size[1];
      for (numRead = bytesOut; numRead + 1 <= i1; numRead++) {
        b_A->data[numRead] = 0.0;
      }

      i1 = A->size[0] * A->size[1];
      A->size[0] = b_A->size[0];
      A->size[1] = b_A->size[1];
      emxEnsureCapacity((emxArray__common *)A, i1, sizeof(double));
      loop_ub = b_A->size[0] * b_A->size[1];
      for (i1 = 0; i1 < loop_ub; i1++) {
        A->data[i1] = b_A->data[i1];
      }

      if (bytesOut < sizeA[0] * sizeA[1]) {
        if (bytesOut >= sizeA[0]) {
          x = std::ceil((double)bytesOut / sizeA[0]);
          if (1 > (int)x) {
            loop_ub = 0;
          } else {
            loop_ub = (int)x;
          }

          c = b_A->size[0];
          i1 = A->size[0] * A->size[1];
          A->size[0] = c;
          A->size[1] = loop_ub;
          emxEnsureCapacity((emxArray__common *)A, i1, sizeof(double));
          for (i1 = 0; i1 < loop_ub; i1++) {
            for (numRead = 0; numRead < c; numRead++) {
              A->data[numRead + A->size[0] * i1] = b_A->data[numRead + b_A->
                size[0] * i1];
            }
          }
        } else {
          if (1 > bytesOut) {
            loop_ub = 0;
          } else {
            loop_ub = bytesOut;
          }

          i1 = c_A->size[0];
          c_A->size[0] = loop_ub;
          emxEnsureCapacity((emxArray__common *)c_A, i1, sizeof(double));
          for (i1 = 0; i1 < loop_ub; i1++) {
            c_A->data[i1] = b_A->data[i1];
          }

          i1 = A->size[0] * A->size[1];
          A->size[0] = loop_ub;
          A->size[1] = 1;
          emxEnsureCapacity((emxArray__common *)A, i1, sizeof(double));
          for (i1 = 0; i1 < 1; i1++) {
            for (numRead = 0; numRead < loop_ub; numRead++) {
              A->data[numRead] = c_A->data[numRead];
            }
          }
        }
      }
    }
  } else {
    i1 = At->size[0];
    At->size[0] = 0;
    emxEnsureCapacity((emxArray__common *)At, i1, sizeof(double));
    if (filestar == NULL) {
      bytesOut = 0;
    } else {
      c = 1;
      bytesOut = 0;
      while (c > 0) {
        c = 0;
        numRead = 1;
        while ((c < 1024) && (numRead > 0)) {
          numReadSizeT = fread(&tbuf[c], nBytes, 1024 - c, filestar);
          numRead = (int)numReadSizeT;
          c += (int)numReadSizeT;
        }

        if (1 > c) {
          loop_ub = -1;
        } else {
          loop_ub = c - 1;
        }

        numRead = At->size[0];
        i1 = At->size[0];
        At->size[0] = (numRead + loop_ub) + 1;
        emxEnsureCapacity((emxArray__common *)At, i1, sizeof(double));
        for (i1 = 0; i1 <= loop_ub; i1++) {
          At->data[numRead + i1] = tbuf[i1];
        }

        bytesOut += c;
      }
    }

    if (At->size[0] >= sizeA[0]) {
      i1 = A->size[0] * A->size[1];
      A->size[0] = (int)sizeA[0];
      A->size[1] = div_s32_sat_ceiling(bytesOut, (int)sizeA[0]);
      emxEnsureCapacity((emxArray__common *)A, i1, sizeof(double));
      for (numRead = 0; numRead + 1 <= bytesOut; numRead++) {
        A->data[numRead] = At->data[numRead];
      }

      i1 = A->size[0] * A->size[1];
      while (bytesOut + 1 <= i1) {
        A->data[bytesOut] = 0.0;
        bytesOut++;
      }
    } else {
      i1 = A->size[0] * A->size[1];
      A->size[0] = At->size[0];
      A->size[1] = 1;
      emxEnsureCapacity((emxArray__common *)A, i1, sizeof(double));
      loop_ub = At->size[0];
      for (i1 = 0; i1 < loop_ub; i1++) {
        A->data[i1] = At->data[i1];
      }
    }
  }

  emxFree_real_T(&c_A);
  emxFree_real_T(&b_A);
  emxFree_real_T(&At);
}

//
// File trailer for fread.cpp
//
// [EOF]
//
