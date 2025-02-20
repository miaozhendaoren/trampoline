/*
 * @file tpl_assembler.h
 *
 * @section desc File description
 *
 * Cooking to have a portable assembly source
 *
 * @section copyright Copyright
 *
 * Trampoline OS
 *
 * Trampoline is copyright (c) IRCCyN 2005-2007
 * Autosar extension is copyright (c) IRCCyN and ESEO 2007
 * libpcl port is copyright (c) Jean-Francois Deverge 2006
 * ARM7 port is copyright (c) ESEO 2007
 * hcs12 port is copyright (c) Geensys 2007
 * Trampoline and its Autosar extension are protected by the
 * French intellectual property law.
 *
 * This software is distributed under the Lesser GNU Public Licence
 *
 * @section infos File informations
 *
 */

#ifndef TPL_ASSEMBLER_H
#define TPL_ASSEMBLER_H

//This file is called by files generated by goil.
//However, the AVR port supports only GCC.
//
#ifdef __GNUC__
  #define TPL_HIG(sym)  sym@h
  #define TPL_LOW(sym)  sym@l
  #define TPL_EXTERN    .extern
  #define CODE_ACCESS_RIGHT ,"ax"
  #define VAR_ACCESS_RIGHT ,"aw"
#else
  #error "Unknown compiler"
#endif


#endif /*  TPL_ASSEMBLER_H  */

/* End of file tpl_assembler.h */
