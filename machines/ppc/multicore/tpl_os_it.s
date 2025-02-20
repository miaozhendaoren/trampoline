/*
 * @file tpl_dispatch.s
 *
 * @section desc File description
 *
 * Trampoline low level function tu enable and disable interrupts
 *
 * @section copyright Copyright
 *
 * Trampoline OS
 *
 *  Trampoline is copyright (c) IRCCyN 2005-2009
 *  Autosar extension is copyright (c) IRCCyN and ESEO 2007-2009
 *  Trampoline and its Autosar extension are protected by the
 *  French intellectual property law.
 *
 *  This software is distributed under a dual licencing scheme
 *  1 - The Lesser GNU Public Licence v2 (LGPLv2)
 *  2 - The BSD Licence
 *
 * @section infos File informations
 *
 * $Date$
 * $Rev$
 * $Author$
 * $URL$
 */

#include "tpl_os_definitions.h"
#include "tpl_os_application_def.h"
#include "tpl_assembler.h"
#include "tpl_app_define.h"
#include "tpl_os_kernel_stack.h"
#include "tpl_registers.h"


  TPL_EXTERN tpl_counter_it_level_buff
  TPL_EXTERN tpl_counter_it_level
  TPL_EXTERN tpl_os_it_level_buff
  TPL_EXTERN tpl_os_it_level
  TPL_EXTERN tpl_kernel_stack_bottom

  .global tpl_enable_interrupts
  .global tpl_disable_interrupts
  .global tpl_enable_os_interrupts
  .global tpl_disable_os_interrupts
  
  .text

  .section .osCode CODE_ACCESS_RIGHT

/**
 * Enable interrupts. On the PowerPC, the interrupt bit is located
 * in the MSR (Machine state register). But since this function is
 * called from an OS service, whe already are in an interrupt handler.
 * So the interrupt bit is not in the MSR but has been saved in the SRR1
 * register.
 * Since MSR will be restored with the content od the SRR1 register when
 * we will return from interrupt, we change set the interrupt bit in
 * this register.
 */
tpl_enable_interrupts:
/* ------------ VLE ---------------------------------------------------------*/
#if (WITH_VLE == YES)
#if (WITH_SYSTEM_CALL == YES) && (WITH_MEMORY_PROTECTION == YES)
  se_subi   r1,8                    /* make space on stack  */
  se_stw    r5,4(r1)                  /* save r5  */
  se_stw    r6,0(r1)                  /* save r6  */

  e_lis     r11,TPL_HIG(tpl_kernel_stack_bottom)      /* get the kernel   */
  e_or2i    r11,TPL_LOW(tpl_kernel_stack_bottom)      /* stack bottom ptr */

  se_mfar   r5,r11
  se_subi   r5,KS_FOOTPRINT       /* switch r5/r11 to use vle instructions  */
  se_mtar   r11,r5

  e_lwz     r12,KS_SRR1(r11)

  e_or2i    r12,0x8000                  /* set the MSR[EE] bits*/


  e_stw     r12,KS_SRR1(r11)

  se_stw  r6,0(r1)
  se_stw  r5,4(r1)
  se_addi   r1,8
  se_blr
#else 
  mfmsr     r3
  e_or2i    r3,0x8000                  /* set the MSR[EE] bits*/
  mtmsr     r3
  se_blr
#endif
/* ------------ NO VLE ------------------------------------------------------*/
#else
  lis   r11,TPL_HIG(INTC_CPR_PRC0)
  ori   r11,r11,TPL_LOW(INTC_CPR_PRC0)
  li    r12,0
  stw   r12,0(r11)
  blr
#endif
  FUNCTION(tpl_enable_interrupts)
  .type tpl_enable_interrupts,@function
  .size tpl_enable_interrupts,$-tpl_enable_interrupts
  

/**
 * Disable interrupts. On the PowerPC, the interrupt bit is located
 * in the MSR (Machine state register). But since this function is
 * called from an OS service, whe already are in an interrupt handler.
 * So the interrupt bit is not in the MSR but has been saved in the SRR1
 * register.
 * Since MSR will be restored with the content od the SRR1 register when
 * we will return from interrupt, we change set the interrupt bit in
 * this register.
 */
tpl_disable_interrupts:
#if (WITH_VLE == YES)
/* ------------ VLE ---------------------------------------------------------*/
#if (WITH_SYSTEM_CALL == YES) && (WITH_MEMORY_PROTECTION == YES)
  se_subi   r1,8              /* make space on stack  */
  se_stw    r5,4(r1)            /* save r5  */
  se_stw    r6,0(r1)            /* save r6  */

  e_lis     r11,TPL_HIG(tpl_kernel_stack_bottom)      /* get the kernel   */
  e_or2i    r11,TPL_LOW(tpl_kernel_stack_bottom)      /* stack bottom ptr */

  se_mfar   r5,r11
  se_subi   r5,KS_FOOTPRINT  /* switch r5/r11 to use vle instructions  */
  se_mtar   r11,r5

  e_lwz     r12,KS_SRR1(r11)


  e_li      r6,0
  e_or2i    r6,0x8000
  se_not    r6            /* clear the MSR[EE] bits*/
  se_mfar   r5,r12
  se_and    r5,r6
  se_mtar   r12,r5

  e_stw     r12,KS_SRR1(r11)

  se_stw    r6,0(r1)
  se_stw    r5,4(r1)          /* restore context  */
  se_addi   r1,8
  se_blr
#else
  e_li      r4,0
  e_or2i    r4,0x8000
  se_not    r4            /* clear the MSR[EE] bits*/  
  mfmsr     r3
  se_and    r3,r4
  mtmsr     r3
  se_blr
#endif
/* ------------ NO VLE ------------------------------------------------------*/
#else
  lis   r11,TPL_HIG(INTC_CPR_PRC0)           /* load INTC_CPR_PRC0 ptr     */
  ori   r11,r11,TPL_LOW(INTC_CPR_PRC0)
  lis   r11,TPL_HIG(tpl_counter_it_level)    /* get priority value to load */
  ori   r11,r11,TPL_LOW(tpl_counter_it_level)
  lwz   r12,0(r12)
  stw   r12,0(r11)                           /* set new priority value     */
  blr
#endif
  FUNCTION(tpl_disable_interrupts)
  .type tpl_disable_interrupts,@function
  .size tpl_disable_interrupts,$-tpl_disable_interrupts
  

/**
 *
 */
tpl_enable_os_interrupts:
/* ------------ VLE ---------------------------------------------------------*/
#if (WITH_VLE == YES)
#if (WITH_SYSTEM_CALL == YES) && (WITH_MEMORY_PROTECTION == YES)
  se_subi   r1,8                    /* make space on stack  */
  se_stw    r5,4(r1)                  /* save r5  */
  se_stw    r6,0(r1)                  /* save r6  */

  e_lis     r11,TPL_HIG(tpl_kernel_stack_bottom)      /* get the kernel   */
  e_or2i    r11,TPL_LOW(tpl_kernel_stack_bottom)      /* stack bottom ptr */

  se_mfar   r5,r11
  se_subi   r5,KS_FOOTPRINT       /* switch r5/r11 to use vle instructions  */
  se_mtar   r11,r5

  e_lwz     r12,KS_SRR1(r11)

  e_or2i    r12,0x8000                  /* set the MSR[EE] bits*/


  e_stw     r12,KS_SRR1(r11)

  se_stw  r6,0(r1)
  se_stw  r5,4(r1)
  se_addi   r1,8
  se_blr
#else 
  mfmsr     r3
  e_or2i    r3,0x8000                  /* set the MSR[EE] bits*/
  mtmsr     r3
  se_blr
#endif
/* ------------ NO VLE ------------------------------------------------------*/
#else
  lis   r11,TPL_HIG(INTC_CPR_PRC0)
  ori   r11,r11,TPL_LOW(INTC_CPR_PRC0)
  li    r12,0
  stw   r12,0(r11)
  blr
#endif
  FUNCTION(tpl_enable_os_interrupts)
  .type tpl_enable_os_interrupts,@function
  .size tpl_enable_os_interrupts,$-tpl_enable_os_interrupts
  

/**
 *
 */
tpl_disable_os_interrupts:
#if (WITH_VLE == YES)
/* ------------ VLE ---------------------------------------------------------*/
#if (WITH_SYSTEM_CALL == YES) && (WITH_MEMORY_PROTECTION == YES)
  se_subi   r1,8              /* make space on stack  */
  se_stw    r5,4(r1)            /* save r5  */
  se_stw    r6,0(r1)            /* save r6  */

  e_lis     r11,TPL_HIG(tpl_kernel_stack_bottom)      /* get the kernel   */
  e_or2i    r11,TPL_LOW(tpl_kernel_stack_bottom)      /* stack bottom ptr */

  se_mfar   r5,r11
  se_subi   r5,KS_FOOTPRINT  /* switch r5/r11 to use vle instructions  */
  se_mtar   r11,r5

  e_lwz     r12,KS_SRR1(r11)


  e_li      r6,0
  e_or2i    r6,0x8000
  se_not    r6            /* clear the MSR[EE] bits*/
  se_mfar   r5,r12
  se_and    r5,r6
  se_mtar   r12,r5

  e_stw     r12,KS_SRR1(r11)

  se_stw    r6,0(r1)
  se_stw    r5,4(r1)          /* restore context  */
  se_addi   r1,8
  se_blr
#else
  e_li      r4,0
  e_or2i    r4,0x8000
  se_not    r4            /* clear the MSR[EE] bits*/  
  mfmsr     r3
  se_and    r3,r4
  mtmsr     r3
  se_blr
#endif
/* ------------ NO VLE ------------------------------------------------------*/
#else
  lis   r11,TPL_HIG(INTC_CPR_PRC0)           /* load INTC_CPR_PRC0 ptr     */
  ori   r11,r11,TPL_LOW(INTC_CPR_PRC0)
  lis   r11,TPL_HIG(tpl_counter_it_level)    /* get priority value to load */
  ori   r11,r11,TPL_LOW(tpl_counter_it_level)
  lwz   r12,0(r12)
  stw   r12,0(r11)                           /* set new priority value     */
  blr
#endif
  FUNCTION(tpl_disable_os_interrupts)
  .type tpl_disable_os_interrupts,@function
  .size tpl_disable_os_interrupts,$-tpl_disable_os_interrupts

