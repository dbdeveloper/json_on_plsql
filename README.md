/*******************************************************************************
 * **SIMPLE JSON PARSER FOR PL/SQL**
 
 * Copyright (c) 2013 Vladyslav Kozlovskyy
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the GNU Lesser Public License
 * which accompanies this distribution, and is available at http://www.gnu.org/licenses/lgpl.html
  
 * **Contributors:**
 *     Vladyslav Kozlovskyy  - dbdeveloper@rambler.ru
 
******************************************************************************/

See soures and `test.sql` file for detail.

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
