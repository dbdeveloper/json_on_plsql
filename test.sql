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


