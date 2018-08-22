/* This file was generated by KreMLin <https://github.com/FStarLang/kremlin>
 * KreMLin invocation: /home/rpk/kremlin/krml -I /home/rpk/kremlin/kremlib/compat -I /mnt/c/hacl-star/code/lib/kremlin -I /home/rpk/kremlin/kremlib/compat -I /mnt/c/hacl-star/specs -I . -ccopt -march=native -verbose -ldopt -flto -tmpdir mpfr-c mpfr-c/out.krml -skip-compilation -minimal -add-include "kremlib.h" -bundle MPFR=* -fparentheses
 * F* version: 3352fef9
 * KreMLin version: c65d4779
 */


#ifndef __MPFR_H
#define __MPFR_H


#include "kremlib.h"

#define MPFR_RoundingMode_MPFR_RNDN 0
#define MPFR_RoundingMode_MPFR_RNDZ 1
#define MPFR_RoundingMode_MPFR_RNDU 2
#define MPFR_RoundingMode_MPFR_RNDD 3
#define MPFR_RoundingMode_MPFR_RNDA 4

typedef uint8_t MPFR_RoundingMode_mpfr_rnd_t;

typedef struct MPFR_Lib_mpfr_struct_s
{
  uint32_t mpfr_prec;
  int32_t mpfr_sign;
  int32_t mpfr_exp;
  uint64_t *mpfr_d;
}
MPFR_Lib_mpfr_struct;

extern int32_t
(*MPFR_mpfr_add1sp1)(
  MPFR_Lib_mpfr_struct *x0,
  MPFR_Lib_mpfr_struct *x1,
  MPFR_Lib_mpfr_struct *x2,
  MPFR_RoundingMode_mpfr_rnd_t x3,
  uint32_t x4
);

extern int32_t
(*MPFR_mpfr_mul_1)(
  MPFR_Lib_mpfr_struct *x0,
  MPFR_Lib_mpfr_struct *x1,
  MPFR_Lib_mpfr_struct *x2,
  MPFR_RoundingMode_mpfr_rnd_t x3,
  uint32_t x4
);

#define __MPFR_H_DEFINED
#endif
