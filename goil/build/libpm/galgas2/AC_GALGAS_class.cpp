//---------------------------------------------------------------------------------------------------------------------*
//                                                                                                                     *
//  acPtr_class : Base class for GALGAS class                                                                          *
//                                                                                                                     *
//  This file is part of libpm library                                                                                 *
//                                                                                                                     *
//  Copyright (C) 2008, ..., 2010 Pierre Molinaro.                                                                     *
//                                                                                                                     *
//  e-mail : pierre.molinaro@irccyn.ec-nantes.fr                                                                       *
//                                                                                                                     *
//  IRCCyN, Institut de Recherche en Communications et Cybernétique de Nantes, ECN, École Centrale de Nantes (France)  *
//                                                                                                                     *
//  This library is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General  *
//  Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option)  *
//  any later version.                                                                                                 *
//                                                                                                                     *
//  This program is distributed in the hope it will be useful, but WITHOUT ANY WARRANTY; without even the implied      *
//  warranty of MERCHANDIBILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for            *
//  more details.                                                                                                      *
//                                                                                                                     *
//---------------------------------------------------------------------------------------------------------------------*

#include "galgas2/AC_GALGAS_class.h"
#include "galgas2/acPtr_class.h"
#include "galgas2/C_galgas_type_descriptor.h"
#include "strings/C_String.h"

//---------------------------------------------------------------------------------------------------------------------*

const C_galgas_type_descriptor * AC_GALGAS_class::dynamicTypeDescriptor (void) const {
  const C_galgas_type_descriptor * result = NULL ;
  if (NULL != mObjectPtr) {
    result = mObjectPtr->classDescriptor () ;
  }
  return result ;
}

//---------------------------------------------------------------------------------------------------------------------*

AC_GALGAS_class::AC_GALGAS_class (void) :
AC_GALGAS_root (),
mObjectPtr (NULL) {
}

//---------------------------------------------------------------------------------------------------------------------*

AC_GALGAS_class::AC_GALGAS_class (const acPtr_class * inPointer) :
AC_GALGAS_root (),
mObjectPtr (NULL) {
  macroAssignSharedObject (mObjectPtr, (acPtr_class *) inPointer) ;
}

//---------------------------------------------------------------------------------------------------------------------*

AC_GALGAS_class::~AC_GALGAS_class (void) {
  macroDetachSharedObject (mObjectPtr) ;
}

//---------------------------------------------------------------------------------------------------------------------*

void AC_GALGAS_class::drop (void) {
  macroDetachSharedObject (mObjectPtr) ;
}

//---------------------------------------------------------------------------------------------------------------------*

AC_GALGAS_class::AC_GALGAS_class (const AC_GALGAS_class & inSource) :
AC_GALGAS_root (),
mObjectPtr (NULL) {
  macroAssignSharedObject (mObjectPtr, inSource.mObjectPtr) ;
}

//---------------------------------------------------------------------------------------------------------------------*

AC_GALGAS_class & AC_GALGAS_class::operator = (const AC_GALGAS_class & inSource) {
  macroAssignSharedObject (mObjectPtr, inSource.mObjectPtr) ;
  return * this ;
}

//---------------------------------------------------------------------------------------------------------------------*

void AC_GALGAS_class::description (C_String & ioString,
                                   const int32_t inIndentation) const {
  ioString << "<@"
           << staticTypeDescriptor ()->mGalgasTypeName
           << ":" ;
  if (isValid ()) {
    mObjectPtr->description (ioString, inIndentation) ;
  }else{
    ioString << "not built" ;
  }
  ioString << ">" ;
}

//---------------------------------------------------------------------------------------------------------------------*

void AC_GALGAS_class::insulate (LOCATION_ARGS) {
  if (isValid () && (mObjectPtr->retainCount () > 1)) {
    acPtr_class * ptr = mObjectPtr->duplicate (THERE) ;
    macroAssignSharedObject (mObjectPtr, ptr) ;
    macroDetachSharedObject (ptr) ;
  }
}

//---------------------------------------------------------------------------------------------------------------------*
