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

select * from table(parse_json('{ " a " : 1111 , " b " : 2222 , " c " : { " d " : 4444, " e " : 5555} , " f " : 6666 }')); 

prompt ------------------------------------------------------------------------

set serveroutput on
set linesize 1000
declare
  result pairs;
begin
  result := parse_json('{ " a " : 1111 , " b " : 2222 , " c " : { " d " : 4444, " e " : 5555} , " f " : 6666 }');

  for i in result.FIRST .. result.LAST loop
    dbms_output.put_line(result(i).name || ' :' || chr(9) || result(i).value);
  end loop;
end;
/

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

set linesize 1000
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


declare
  result pairs;
begin 
  result := parse_json
    ( ' /* comment */
       {/*te*/" a " : [0/*st*/
                      ,/*testest*/ { ''test'':/*---*/123.00
                                   , ''yet_another_test'':"test"
                                   , array: [10,20,30]
                                   }
                      , [''yes'',no ]
                      ]
       , " b " : 2222 /*yet another comment...*/
       , " c " : { " d " : 4444
                 , " e " : 5555
                 }
       , " f " : 6666
       }'
    );

  for i in result.FIRST .. result.LAST loop
    dbms_output.put_line('|'||result(i).line(23)||'|');
  end loop;
  dbms_output.put_line(rpad('*',40,'*')); 
  dbms_output.put_line('|'||pairs_to_char(result)||'|');
end;
/
        

declare
  result pairs;
begin
  result := clob_json
    ( '{
           "book": {
               "title": "Hamlet",
               "author": "William Shakespeare",
               "quotes": [
                   "Like Niobe, all tears",
                   "To be, or not to be",
                   "All is not well; I doubt some foul play.",
                   "A countenance more in sorrow than in anger."
               ]
           }
       }'); 

  dbms_output.put_line(rpad('*',40,'*')); 
  dbms_output.put_line(pairs_to_char(result));
end;
/

quit;


