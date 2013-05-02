/*******************************************************************************
 * **SIMPLE JSON PARSER FOR PL/SQL**
 
 * Copyright (c) 2013 Vladyslav Kozlovskyy
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the GNU Lesser Public License
 * which accompanies this distribution, and is available at http://www.gnu.org/licenses/lgpl.html
  
 * **Contributors:**
 *     Vladyslav Kozlovskyy  - dbdeveloper at rambler.ru
 
******************************************************************************/

See sources and `test.sql` file for details.

## INSTALLATION
  execute install.sql using sqlplus:
```shell
  sqlplus  username/userpassword@dbname  @install.sql
```

## REMOVE INSTALLED OBJECTS:
   To remove installed objects execute these commands:
```sql
   DROP FUNCTION PARSE_JSON;
   DROP FUNCTION PAIRS_TO_CHAR;
   DROP TYPE PAIRS FORCE;
   DROP TYPE PAIR FORCE;
```

## USING:
   Using is very simple:

```sql
    select * from table(parse_json('<json_structure>'));
```

or

```sql
set serveroutput on
set linesize 1000
declare
  result pairs;
begin
  result := parse_json('<json_to_parse>');

  for i in result.FIRST .. result.LAST loop
    dbms_output.put_line(result(i).name || ' : ' || result(i).value);
  end loop;
end;
/
```

Result is a pair of key-value, where `Key` is a "path" to get appropriate value.

For example, for such json:

```js
/* comment */
{ " a " : [ 0
          , { 'test': 123.00
            , 'yet_another_test':"test"
            , array: [10, 20, 30]
            }
          , ['yes', 'no']
          ]
, " b " : 2222 /*yet another comment...*/
, " c " : { " d " : 4444
          , " e " : 5555
          }
, " f " : 6666
}
```

the next result set will be get:

```
NAME                      VALUE
------------------------  -------------
 a [0]                  : 0
 a [1].test             : 123.00
 a [1].yet_another_test : test
 a [1].array[0]         : 10
 a [1].array[1]         : 20
 a [1].array[2]         : 30
 a [2][0]               : yes
 a [2][1]               : no
 b                      : 2222
 c . d                  : 4444
 c . e                  : 5555
 f                      : 6666
```

