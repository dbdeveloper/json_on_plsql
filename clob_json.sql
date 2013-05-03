create or replace 
function clob_json
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
( I_json_clob IN clob )
return pairs
is

 res     pairs := pairs();
 res_idx pls_integer := 0;
 err_msg varchar2(200);
 i       pls_integer := 1;

--------------------------------------------------------------------------------
function fmt_err( err_id pls_integer
                , p1 varchar2 := NULL
                , p2 varchar2 := NULL
                )
  return varchar2
is
  owner    varchar2(30);
  name     varchar2(30);
  lineno   pls_integer;
  caller_t varchar2(30);
  who_called_me varchar2(100);
begin
  OWA_UTIL.WHO_CALLED_ME(owner, name, lineno, caller_t);
  who_called_me := ' (' || owner || '.' || name || ':' || lineno || ')';

  case err_id
    when 1 then
        return ''''||p1||''' character is detected when one of '
               ||p2||' characters is expected.' || who_called_me;
    when 2 then
        return ''''||p1||''' character is detected when '''
               ||p2||''' is expected.' || who_called_me;
    when 3 then
        return p1||' is not terminated! '||p2||
               ' is expected but END OF TEXT is detected!' || who_called_me;
    else
      return 'unknown error ' || err_id || who_called_me;
  end case;
end fmt_err;
--------------------------------------------------------------------------------
function parse_string( I_text    IN     clob
                     , I_pos     IN OUT pls_integer
                     , I_term    IN     varchar2
                     , I_err_msg IN OUT varchar2
                     )
  return varchar2
is
 str varchar2(4000);
 len pls_integer := length(I_text);
 c   varchar2(4);
begin
  -- string
  I_pos := I_pos +1;
  while I_pos<=len loop
    c := substr(I_text,I_pos,1);
    if c = '\' then -- to use \x -> x transformation
       I_pos := I_pos + 1;
       c := substr(I_text,I_pos,1);
    else
      if c = I_term then
        return str;
      end if;
    end if;
    str := concat(str, c);
    I_pos := I_pos + 1;
  end loop;
  I_err_msg := fmt_err(3, 'String', '''' || I_term || ''' character');
  return NULL;
end parse_string;
--------------------------------------------------------------------------------
procedure parse_comment( I_text    IN     clob
                       , I_pos     IN OUT pls_integer
                       , I_err_msg IN OUT varchar2
                       )
is
  len pls_integer := length(I_text);
  c varchar2(4);
begin
  I_pos := I_pos + 1;
  while I_pos<=len loop
    if substr(I_text,I_pos,2) = '*/' then
      I_pos := I_pos + 1;
      return;
    end if;
    I_pos := I_pos + 1;
  end loop;
  I_err_msg := fmt_err(3, 'Comment', '''*/'' pair');
end parse_comment;
--------------------------------------------------------------------------------
procedure parse_obj( I_text    in            clob
                   , I_pos     in out        pls_integer
                   , I_res     in out nocopy pairs
                   , I_res_idx in out        pls_integer
                   , I_err_msg in out nocopy varchar2
                   , I_prefix  in            varchar2 := NULL
                   );
--------------------------------------------------------------------------------
procedure parse_array( I_text    in            clob
                     , I_pos     in out        pls_integer
                     , I_res     in out nocopy pairs
                     , I_res_idx in out        pls_integer
                     , I_err_msg in out nocopy varchar2
                     , I_prefix  in            varchar2 := NULL
                     )
is
  res_rec pair := pair;
  len     pls_integer := length(I_text);
  c       varchar2(4);
  str     varchar2(2000);

  L_array boolean := false;
  L_idx   pls_integer := 0;
begin
  while I_pos<=len loop
    c := substr(I_text, I_pos,1);
    case c
      when '['     then
        if L_array then
          if res_rec.value is NULL then
            -- subarray
            parse_array(I_text, I_pos, I_res, I_res_idx, I_err_msg, res_rec.name);
            if I_err_msg is not NULL then
              exit;
            end if;
            res_rec.value := NULL;
          else
            I_err_msg := fmt_err(1, '[', ''',''|'']''');
            exit;
          end if;
        else
          L_array := true;
          res_rec.name := I_prefix || '[' || L_idx || ']';
        end if;
      when ']'     then
        if not L_array then
          I_err_msg := fmt_err(2, ']', '[');
          exit;
        end if;
        L_array := false;
        if res_rec.value is not NULL then
          I_res_idx := I_res_idx + 1;
          I_res.EXTEND(1);
          I_res(I_res_idx) := res_rec;
        end if;
        exit;
      when ','     then
        if not L_array then
          I_err_msg := fmt_err(2, ',', '[');
          exit;
        end if;
        
        if res_rec.value is not NULL then
          I_res_idx := I_res_idx + 1;
          I_res.EXTEND(1);
          I_res(I_res_idx) := res_rec;
        end if;

        L_idx := L_idx + 1;
        res_rec.name  := I_prefix || '[' || L_idx || ']';
        res_rec.value := NULL;

      when '"'     then
        if not L_array then
          I_err_msg := fmt_err(2, '"', '[');
          exit;
        end if;
        if res_rec.value is not NULL then
          I_err_msg := fmt_err(1, '"', ''',''|'']''');
          exit;
        end if;
        res_rec.value := parse_string(I_text, I_pos, '"', I_err_msg);
      when ''''    then
        if not L_array then
          I_err_msg := fmt_err(2, '''', '[');
          exit;
        end if;
        if res_rec.value is not NULL then
          I_err_msg := fmt_err(1, '''', ''',''|'']''');
          exit;
        end if;
        res_rec.value := parse_string(I_text, I_pos, '''', I_err_msg);
      when '/' then
          -- ? comment /* ... */ ?
          if substr(I_text, I_pos+1, 1) = '*' then
             parse_comment(I_text, I_pos, I_err_msg);
          end if;
      when '{'     then
        if not L_array then
          I_err_msg := fmt_err(2, '{', '[');
          exit;
        end if;
        if res_rec.value is not NULL then
          I_err_msg := fmt_err(1, '{', ''',''|'']''');
          exit;
        end if;
        parse_obj(I_text, I_pos, I_res, I_res_idx, I_err_msg, res_rec.name);
        if I_err_msg is not NULL then
          exit;
        end if;
        res_rec.value := NULL;
      when ' '     then NULL;
      when chr(9)  then NULL;
      when chr(10) then NULL;
      else
        if not L_array then
          I_err_msg := fmt_err(2, c, '[');
          exit;
        end if;
        if res_rec.value is not NULL then
           I_err_msg := fmt_err(1, c, ''',''|'']''');
           exit;
        end if;
        -- string
        str := NULL;
        while I_pos<=len loop
          c := substr(I_text,I_pos,1);
          exit when c in (',',']','/',' ',chr(9),chr(10));
          str := concat(str, c);
          I_pos := I_pos + 1;
        end loop;
        res_rec.value := str;
        continue;
    end case;
    I_pos := I_pos + 1;
  end loop;
  
  if I_err_msg is NULL and L_array then
    I_err_msg := fmt_err(3, 'Array', ''']'' character');
  end if;
end parse_array;
--------------------------------------------------------------------------------
procedure parse_obj( I_text    in            clob
                   , I_pos     in out        pls_integer
                   , I_res     in out nocopy pairs
                   , I_res_idx in out        pls_integer
                   , I_err_msg in out nocopy varchar2
                   , I_prefix  in            varchar2 := NULL
                   )
is
 LEFT_PART  constant pls_integer := 0;
 RIGHT_PART constant pls_integer := 1;

 res_rec pair := pair;
 res_start_idx pls_integer := I_res_idx;

 len     pls_integer := length(I_text);
 c       varchar2(4);

 L_collection boolean := False;
 L_part       pls_integer;  -- 0 - left part (name), 1 - right part (value)

 str     varchar2(2000);
begin
  while I_pos<=len loop
    c := substr(I_text, I_pos,1);
    case c
      when '{' then
          if L_collection then
             if L_part = LEFT_PART then
               -- ERROR!
               I_err_msg := fmt_err(1, '{', '''"''|alpha_numeric_characters|''}''');
               exit;
             else -- RIGHT_PART then
               -- recursive call of this program
               parse_obj(I_text, I_pos, I_res, I_res_idx, I_err_msg,
                         concat( case when I_prefix is not NULL
                                      then concat(I_prefix, '.')
                                      else NULL
                                 end
                              , res_rec.name
                              )
                        );
               if I_err_msg is not NULL then
                 exit;
               end if;
             end if;
          else
             L_collection := true;
             L_part := LEFT_PART;
          end if;
          res_rec.name  := NULL;
          res_rec.value := NULL;
      when '[' then
          if not L_collection then
            I_err_msg := fmt_err(2, '[', '{');
            exit;
          end if;

          if L_part = RIGHT_PART then
            if res_rec.value is NULL then
              if res_rec.name is not NULL then
                -- array
                parse_array(I_text, I_pos, I_res, I_res_idx, I_err_msg,
                            concat( case when I_prefix is not NULL
                                         then concat(I_prefix, '.')
                                         else NULL
                                    end
                                  , res_rec.name
                                  )
                           );
                if I_err_msg is not NULL then
                  exit;
                end if;
                res_rec.name  := NULL;
                res_rec.value := NULL;
              else
                I_err_msg := fmt_err(1, '[', ''',''|''}''');
                exit;
              end if;
            else
              I_err_msg := fmt_err(1, '[', ''',''|''}''');
              exit;
            end if;
          else -- LEFT_PART
            if res_rec.name is not NULL then
              I_err_msg := fmt_err(2, '[', ':');
              exit;
            else
              I_err_msg := fmt_err(1, '[', 'name of a parameter or ''}''');
              exit;
            end if;
          end if;
      when '"' then
          if not L_collection then
            I_err_msg := fmt_err(2, '"', '{');
            exit;
          end if;

          if L_part = LEFT_PART then
            if res_rec.name is not NULL then
              I_err_msg := fmt_err(2, '"', ':');
              exit;
            end if;
          else
            if res_rec.value is not NULL then
              I_err_msg := fmt_err(1, '"', ''',''|''}''');
              exit;
            end if;
          end if;
          str := parse_string(I_text, I_pos, '"', I_err_msg);
          if L_part = LEFT_PART then
            res_rec.name := str;
          else -- RIGHT_PART
            res_rec.value := str;
          end if;
      when '/' then
          -- ? comment /* ... */ ?
          if substr(I_text, I_pos+1, 1) = '*' then
             parse_comment(I_text, I_pos, I_err_msg);
          end if;
      when '''' then
          if not L_collection then
            I_err_msg := fmt_err(2, '''', '{');
            exit;
          end if;

          if L_part = LEFT_PART then
            if res_rec.name is not NULL then
              I_err_msg := fmt_err(2, '''', ':');
              exit;
            end if;
          else
            if res_rec.value is not NULL then
              I_err_msg := fmt_err(1, '''', ''',''|''}''');
              exit;
            end if;
          end if;
          str := parse_string(I_text, I_pos, '''', I_err_msg);
          if L_part = LEFT_PART then
            res_rec.name := str;
          else -- RIGHT_PART
            res_rec.value := str;
          end if;
      when ':' then
          if not L_collection then
            I_err_msg := fmt_err(2, ':', '{');
            exit;
          end if;

          if L_part = LEFT_PART then
            if res_rec.name is not NULL then
              L_part := RIGHT_PART;
            else
              -- ERROR!
              I_err_msg := fmt_err(1, ':', 'name of a parameter or ''}''');
              exit;
            end if;
          else -- RIGHT_PART;
            -- ERROR!
            if res_rec.value is not NULL then
              I_err_msg := fmt_err(1, ':', ''',''|''}''');
            else
              I_err_msg := fmt_err(1, ':', 'value string or ''}''');
            end if;
            exit;
          end if;
      when ',' then
          if not L_collection then
            I_err_msg := fmt_err(2, ',', '{');
            exit;
          end if;

          if L_part = RIGHT_PART then
            if res_rec.value is not NULL then
              if I_prefix is not null then
                res_rec.name := I_prefix || '.' || res_rec.name;
              end if;
              -- save pair in result table:
              I_res_idx := I_res_idx + 1;
              I_res.EXTEND(1);
              I_res(I_res_idx) := res_rec;
              L_part := LEFT_PART;
              res_rec.name := NULL;
              res_rec.value := NULL;
            else
              if res_rec.name is NULL then
                 -- special case: return from recurse (subcollections were
                 -- already inserted into I_res)
                 L_part := LEFT_PART;
              else
                I_err_msg := fmt_err(1, ',', 'value string or ''{''');
                exit;
              end if;
            end if;
          else -- LEFT_PART
            if res_rec.name is NULL then
              I_err_msg := fmt_err(1, ',', 'name of a parameter or ''}''');
            else
              I_err_msg := fmt_err(2, ',', ':');
            end if;
            exit;
          end if;
      when '}' then
          if not L_collection then
            I_err_msg := fmt_err(2, '}', '{');
            exit;
          end if;

          if L_part = RIGHT_PART then
            if res_rec.value is not NULL then
              if I_prefix is not null then
                res_rec.name := I_prefix || '.' || res_rec.name;
              end if;
              -- save pair in result table:
              I_res_idx := I_res_idx + 1;
              I_res.EXTEND(1);
              I_res(I_res_idx) := res_rec;
              L_collection := false;
              exit;
            else
              if res_rec.name is NULL then
                 -- special case: return from recurse (subcollections were
                 -- already inserted into I_res)
                 L_collection := false;
                 exit;
              else
                I_err_msg := fmt_err(1, '}', 'value string');
                exit;
              end if;
            end if;
          else
            if res_rec.name is NULL then
              if res_start_idx = I_res_idx then
                -- empty collection
                L_collection := false;
                exit;
              else
                I_err_msg := fmt_err(1, '}', 'name of a parameter');
                exit;
              end if;
            else
              I_err_msg := fmt_err(2, '}', ':');
              exit;
            end if;
          end if;
      when ' '     then NULL;
      when chr(9)  then NULL;
      when chr(10) then NULL;

      else -- any other characters
        if not L_collection then
          I_err_msg := fmt_err(2, c, '{');
          exit;
        end if;

        if L_part = LEFT_PART then
          if res_rec.name is not NULL then
            I_err_msg := fmt_err(2, c, ':');
            exit;
          end if;
        else -- RIGHT_PART
          if res_rec.value is not NULL then
            I_err_msg := fmt_err(1, c, ''',''|''}''');
            exit;
          end if;
        end if;
        -- string
        str := NULL;
        while I_pos<=len loop
          c := substr(I_text,I_pos,1);
          if L_part = LEFT_PART then
            exit when c in (':','/',' ',chr(9),chr(10));
          else -- RIGHT_PART
            exit when c in (',','/','}',' ',chr(9),chr(10));
          end if;
          str := concat( str, c);
          I_pos := I_pos + 1;
        end loop;
        if L_part = LEFT_PART then
          res_rec.name := str;
        else -- RIGHT_PART
          res_rec.value := str;
        end if;
        continue;
    end case;
    I_pos := I_pos + 1;
  end loop;
  if I_err_msg is NULL and L_collection then
    I_err_msg := fmt_err(3, 'Object', '''}'' character');
  end if;
 end parse_obj;

begin
  parse_obj(I_json_clob, i, res, res_idx, err_msg);

  if err_msg is not NULL then
    raise_application_error(-20000, 'ERROR: '||err_msg||' POSITION: '||i);
  end if;
  return res;
end clob_json;
/
