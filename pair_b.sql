create or replace 
type body PAIR
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
as
  constructor function PAIR( SELF  IN OUT NOCOPY PAIR ) return SELF as RESULT
  as
  begin
    return;
  end pair;
  ------------------------------------------------------------------------------
  constructor function PAIR( SELF  IN OUT NOCOPY PAIR
                           , name  IN varchar2
                           , value IN varchar2
                           )
    return SELF as RESULT
  as
  begin
    SELF.name  := name;
    SELF.value := nvl(value, '<NULL>');
    return;
  end pair;
  ------------------------------------------------------------------------------
  constructor function PAIR( SELF  IN OUT NOCOPY PAIR
                           , name  IN varchar2
                           , value IN boolean
                           )
    return SELF as RESULT
  as
  begin
    SELF.name  := name;
    SELF.value := case when value is NULL then '<NULL>'
                       when value         then 'TRUE'
                                          else 'FALSE'
                  end;
    return;
  end pair;
  ------------------------------------------------------------------------------
  member function line(I_name_size IN pls_integer := NULL) return varchar2
  is
  begin
    return rpad(name, nvl(I_name_size, length(name))) || ' : ' || value;
  end line;
end;
/
