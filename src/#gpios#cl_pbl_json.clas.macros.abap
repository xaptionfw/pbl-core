*"* use this source file for any macro definitions you need
*"* in the implementation part of the class
DEFINE escape_json_inplace.
  replace all occurrences of `\`                                    in &1 with `\\`.
  replace all occurrences of `"`                                    in &1 with `\"`.
END-OF-DEFINITION.

DEFINE escape_json.
  move &1 to &2.
  escape_json_inplace &2.
END-OF-DEFINITION.

DEFINE dump_type.

  case &2->type_kind.
    when cl_abap_typedescr=>typekind_float or cl_abap_typedescr=>typekind_int or cl_abap_typedescr=>typekind_int1 or
         cl_abap_typedescr=>typekind_int2 or cl_abap_typedescr=>typekind_packed.
      if &1 is initial.
        &3 = `0`.
      else.
        move &1 to &3.
        if &1 lt 0.
          shift &3 right circular.
        else.
          condense &3.
        endif.
      endif.
    when cl_abap_typedescr=>typekind_num.
      if &1 is initial.
        &3 = `0`.
      else.
        move &1 to &3.
        shift &3 left deleting leading ` 0`.
      endif.
    when cl_abap_typedescr=>typekind_string or cl_abap_typedescr=>typekind_csequence or cl_abap_typedescr=>typekind_clike.
      if &1 is initial.
        &3 = `""`.
      else.
        escape_json &1 &3.
        concatenate `"` &3 `"` into &3.
      endif.
    when cl_abap_typedescr=>typekind_xstring.
      if &1 is initial.
        &3 = `""`.
      else.
        &3 = xstring_to_string( &1 ).
        escape_json_inplace &3.
        concatenate `"` &3 `"` into &3.
      endif.
    when cl_abap_typedescr=>typekind_char or cl_abap_typedescr=>typekind_hex.
      if &2->output_length eq 1 and mc_boolean_types cs &2->absolute_name.
        if &1 eq abap_true.
          &3 = `true`.
        else.
          &3 = `false`.
        endif.
      else.
        escape_json &1 &3.
        concatenate `"` &3 `"` into &3.
      endif.
    when cl_abap_typedescr=>typekind_date or cl_abap_typedescr=>typekind_time.
      move &1 to &3.
    when others.
      if &1 is initial.
        &3 = `null`.
      else.
        move &1 to &3.
      endif.
  endcase.

END-OF-DEFINITION.

DEFINE format_name.
  READ TABLE name_mapping
       with TABLE KEY name_ddic = &1
       INTO &4 TRANSPORTING name_json.
  IF sy-subrc <> 0.
    &4-name_json = &1.
  ENDIF.
  case &2.
    when pretty_mode-camel_case.
      &3 = pretty_name( &4-name_json ).
    when pretty_mode-low_case.
      &3 = &4-name_json.
      translate &3 to lower case.                         "#EC SYNTCHAR
    when others.
      &3 = &4-name_json.
  endcase.
END-OF-DEFINITION.

DEFINE throw_error.
  create object excp.
  raise exception excp.
END-OF-DEFINITION.

DEFINE eat_white.
  while offset < length and sv_white_space cs json+offset(1).
    offset = offset + 1.
  endwhile.
END-OF-DEFINITION.

DEFINE eat_string.
  if json+offset(1) eq `"`.
    mark   = offset + 1.
    offset = mark.
    while offset < length and json+offset(1) ne `"`.
      if json+offset(1) eq `\`.
        offset = offset + 1.
      endif.
      offset = offset + 1.
    endwhile.
    match = offset - mark.
    &1 = json+mark(match).
    offset = offset + 1.
  else.
    throw_error.
  endif.
END-OF-DEFINITION.

DEFINE eat_number.
  mark   = offset.
  while offset < length and `0123456789-eE.` cs json+offset(1).
    offset = offset + 1.
  endwhile.
  match = offset - mark.
  &1 = json+mark(match).
END-OF-DEFINITION.

DEFINE eat_bool.
  mark   = offset.
  while offset < length and `aeflnrstu` cs json+offset(1).
    offset = offset + 1.
  endwhile.
  match = offset - mark.
  if json+mark(match) eq `true`.
    &1 = abap_true.
  elseif json+mark(match) eq `false`.
    &1 = abap_false.
  endif.
END-OF-DEFINITION.

DEFINE eat_char.
  if offset < length and json+offset(1) eq &1.
    offset = offset + 1.
  else.
    throw_error.
  endif.
END-OF-DEFINITION.
