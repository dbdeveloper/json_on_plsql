create or replace 
function PAIRS_TO_CHAR
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
-- PARAMETERS:
( I_pairs        IN pairs
, I_sep          IN char := CHR(10)
, I_indent       IN pls_integer := 0
, I_align_names IN boolean := True
)
  return varchar2
is
  L_index     pls_integer;
  L_result    varchar2(32767);
  L_name_size pls_integer := NULL;
  L_sep       varchar2(32767) := concat(I_sep, rpad(' ', I_indent));
begin
  L_index := I_pairs.FIRST;
  if L_index is not NULL then
    if I_align_names then
      L_name_size := 0;
      while L_index is not NULL loop
        L_name_size := greatest( L_name_size, length(I_pairs(L_index).name));
        L_index := I_pairs.NEXT(L_index);
      end loop;
      L_index := I_pairs.FIRST;
    end if;
    
    L_result := concat(rpad(' ', I_indent), I_pairs(L_index).line(L_name_size));
    L_index := I_pairs.NEXT(L_index);
  
    while L_index is not NULL loop
       L_result := L_result || L_sep || I_pairs(L_index).line(L_name_size);
       L_index := I_pairs.NEXT(L_index);
    end loop;
  end if;
  return L_result;
end PAIRS_TO_CHAR;
/
