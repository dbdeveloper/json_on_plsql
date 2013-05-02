create or replace 
type PAIR
/*******************************************************************************
 * Copyright (c) 2013 Vladyslav Kozlovskyy
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the GNU Lesser Public License
 * which accompanies this distribution, and is available at
 * http://www.gnu.org/licenses/lgpl.html
 * 
 * Contributors:
 *     Vladyslav Kozlovskyy  - dbdeveloper at rambler.ru
 ******************************************************************************/
as object
( name  varchar2(256)
, value varchar2(32767)
, constructor function PAIR( SELF  IN OUT NOCOPY PAIR ) return SELF as RESULT
, constructor function PAIR( SELF  IN OUT NOCOPY PAIR
                           , name  IN varchar2
                           , value IN varchar2
                           ) return SELF as RESULT
  ------------------------------------------------------------------------------                           
, constructor function PAIR( SELF  IN OUT NOCOPY PAIR
                           , name  IN varchar2
                           , value IN boolean
                           ) return SELF as RESULT
  ------------------------------------------------------------------------------                           
, member function line(I_name_size IN pls_integer := NULL) return varchar2
) not final;
/
