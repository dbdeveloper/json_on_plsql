--------------------------------------------------------------------------------
-- Copyright (c) 2013 Vladyslav Kozlovskyy
-- All rights reserved. This program and the accompanying materials
-- are made available under the terms of the GNU Lesser Public License
-- which accompanies this distribution, and is available at
-- http://www.gnu.org/licenses/lgpl.html
-- 
-- Contributors:
--     Vladyslav Kozlovskyy  - dbdeveloper at rambler.ru
--------------------------------------------------------------------------------
COLUMN NAME FORMAT A25
COLUMN VALUE FORMAT A40

select * from table(parse_json('{
   "firstName": "Иван",
   "lastName": "Иванов",
   "address": {
       "streetAddress": "Московское ш., 101, кв.101",
       "city": "Ленинград",
       "postalCode": 101101
   }  ,
   "phoneNumbers": ["812-123-1234", "916-123-4567"]
  }'));


prompt ------------------------------------------------------------------------

set linesize 250
set serveroutput on
declare
  res pairs;
begin
  res := parse_json('
  /* --------------------------------*\
  |* it is json for testing           *|
  \* --------------------------------*/
  
  {
   "firstName": "Иван", /* it is a comment */
   "lastName": "Иванов",
   "address": {
       "streetAddress": "Московское ш., 101, кв.101",
       "city": "Ленинград",
       "postalCode": 101101
   }  ,
   "phoneNumbers": ["812-123-1234"/*mob*/, "916-123-4567"/*home*/]
  }');

  dbms_output.put_line(pairs_to_char(res));
end;
/

quit;


