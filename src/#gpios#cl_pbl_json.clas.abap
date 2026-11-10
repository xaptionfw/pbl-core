class /GPIOS/CL_PBL_JSON definition
  public
  create public .

public section.
  type-pools ABAP .
  class CX_SY_CONVERSION_ERROR definition load .

  types:
    BEGIN OF ty_name_mapping,
            name_ddic TYPE name_komp,
            name_json TYPE name_komp,
            java_timestamp TYPE abap_bool,
           END OF   ty_name_mapping .
  types:
    ty_t_name_mapping TYPE STANDARD TABLE OF ty_name_mapping WITH NON-UNIQUE KEY name_ddic .
  types PRETTY_NAME_MODE type CHAR1 .

  constants:
    BEGIN OF pretty_mode,
            none          TYPE char1  VALUE '',
            low_case      TYPE char1  VALUE 'L',
            camel_case    TYPE char1  VALUE 'X',
          END OF  pretty_mode .
  class-data SV_WHITE_SPACE type STRING read-only .
  class-data NAME_MAPPING type TY_T_NAME_MAPPING .

  class-methods CLASS_CONSTRUCTOR .
  class-methods XSTRING_TO_STRING
    importing
      !IN type XSTRING
    returning
      value(OUT) type STRING .
  class-methods RESTORE
    importing
      !JSON type STRING
      !PRETTY_NAME type PRETTY_NAME_MODE default PRETTY_MODE-NONE
      !LENGTH type I
    changing
      !DATA type DATA optional
      !OFFSET type I default 0 .
  class-methods CONVERT_JAVA_TIMESTAMP_TO_ABAP
    importing
      !IM_TIMESTAMP type STRING
    exporting
      !EX_DATE type SYDATE
      !EX_TIME type SYUZEIT
      !EX_MSEC type NUM03 .
  class-methods RESTORE_TYPE
    importing
      !JSON type STRING
      !PRETTY_NAME type PRETTY_NAME_MODE default PRETTY_MODE-NONE
      !LENGTH type I
    changing
      !DATA type DATA optional
      !OFFSET type I default 0 .
  class-methods CONVERT_ABAP_TIMESTAMP_TO_JAVA
    importing
      !IM_DATE type SYDATE
      !IM_TIME type SYUZEIT
      !IM_MSEC type NUM03
    exporting
      !EX_TIMESTAMP type STRING .
  class-methods DUMP
    importing
      !DATA type DATA
      !COMPRESS type ABAP_BOOL default ABAP_FALSE
      !TYPE_DESCR type ref to CL_ABAP_TYPEDESCR optional
      !PRETTY_NAME type PRETTY_NAME_MODE default PRETTY_MODE-NONE
    returning
      value(R_JSON) type STRING .
  class-methods DESERIALIZE
    importing
      !JSON type STRING
      !PRETTY_NAME type PRETTY_NAME_MODE default PRETTY_MODE-NONE
    changing
      !DATA type DATA .
  class-methods SERIALIZE
    importing
      !DATA type DATA
      !COMPRESS type ABAP_BOOL default ABAP_FALSE
      !NAME type STRING optional
      !PRETTY_NAME type PRETTY_NAME_MODE default PRETTY_MODE-NONE
      !TYPE_DESCR type ref to CL_ABAP_TYPEDESCR optional
    returning
      value(R_JSON) type STRING .
  class-methods DUMP_TYPE
    importing
      !DATA type DATA
      !TYPE_DESCR type ref to CL_ABAP_ELEMDESCR
    returning
      value(R_JSON) type STRING .
  class-methods DUMP_TYPE_EX
    importing
      !DATA type DATA
    returning
      value(R_JSON) type STRING .
  class-methods PRETTY_NAME
    importing
      !IN type CSEQUENCE
    returning
      value(OUT) type STRING .
  class-methods ESCAPE
    importing
      !IN type ANY
    returning
      value(OUT) type STRING .
  PROTECTED SECTION.
*"* protected components of class ZCL_JSON
*"* do not include other source files here!!!

    CONSTANTS mc_boolean_types TYPE string VALUE `\TYPE-POOL=ABAP\TYPE=ABAP_BOOL#\TYPE=BOOLEAN#\TYPE=BOOLE_D`. "#EC NOTEXT
  PRIVATE SECTION.
*"* private components of class ZCL_JSON
*"* do not include other source files here!!!
ENDCLASS.



CLASS /GPIOS/CL_PBL_JSON IMPLEMENTATION.


  METHOD CLASS_CONSTRUCTOR.
    sv_white_space = cl_abap_char_utilities=>get_simple_spaces_for_cur_cp( ).
  ENDMETHOD.


  METHOD CONVERT_ABAP_TIMESTAMP_TO_JAVA.
    DATA: l_date             TYPE sy-datum.
    DATA: l_days_timestamp   TYPE timestampl.
    DATA: l_secs_timestamp   TYPE timestampl.
    DATA: l_i_days           TYPE i.
    DATA: l_i_sec            TYPE i.
    DATA: l_timestamp        TYPE timestampl.
    DATA: l_dummy            TYPE string.
*-----------------------------------------------------------------------
* milliseconds for the days since January 1, 1970, 00:00:00 GMT
* one day has 86400 seconds
    l_date            = '19700101'.
    l_i_days          = im_date - l_date.
* timestamp for days past in seconds
    l_days_timestamp  = l_i_days * 86400.
    l_i_sec          = im_time.
* timestamp for time at present day
    l_secs_timestamp = l_i_sec.
    l_timestamp = ( l_days_timestamp + l_secs_timestamp ) * 1000.
    ex_timestamp = l_timestamp.
    SPLIT ex_timestamp AT '.' INTO ex_timestamp l_dummy.
    ex_timestamp = ex_timestamp + im_msec.
    SHIFT ex_timestamp RIGHT DELETING TRAILING space.
    SHIFT ex_timestamp LEFT  DELETING LEADING space.
  ENDMETHOD.


  METHOD CONVERT_JAVA_TIMESTAMP_TO_ABAP.
    DATA: l_date        TYPE sy-datum.
    DATA: l_timestamp   TYPE timestampl.
    DATA: l_timsmsec    TYPE timestampl.
    DATA: l_i           TYPE i.
    DATA: l_sec         TYPE i.
    DATA: l_msec        TYPE i.
*-----------------------------------------------------------------------
* im_timestamp stores milliseconds since January 1, 1970, 00:00:00 GMT
    l_timestamp = im_timestamp / 1000.   "timestamp in seconds
* one day has 86400 seconds
    l_i         = l_timestamp DIV 86400. "timestamp in days
    l_date      = '19700101'.
    ex_date     = l_date + l_i.
    l_sec       = l_timestamp MOD 86400. "rest seconds (timestamp - days)
    ex_time     = l_sec.                 "time of date
    l_timsmsec  = l_timestamp MOD 86400. "rest sec and milli seconds
    l_timsmsec  = l_timsmsec - l_sec.
    ex_msec     = l_timsmsec * 1000.
  ENDMETHOD.


  METHOD deserialize.

    DATA: length    TYPE i,
          unescaped LIKE json.

    IF json IS NOT INITIAL.

      unescaped = json.

      " to eliminate numeric replacement calls for every single sting value, we do
      " replacement over all JSON text, while this shall not destroy JSON structure
      REPLACE ALL OCCURRENCES OF `\r\n` IN unescaped WITH cl_abap_char_utilities=>cr_lf.
      REPLACE ALL OCCURRENCES OF `\n`   IN unescaped WITH cl_abap_char_utilities=>newline.
      REPLACE ALL OCCURRENCES OF `\t`   IN unescaped WITH cl_abap_char_utilities=>horizontal_tab.
*   REPLACE ALL OCCURRENCES OF `\f`   IN r_json WITH cl_abap_char_utilities=>form_feed.
*   REPLACE ALL OCCURRENCES OF `\b`   IN r_json WITH cl_abap_char_utilities=>backspace.

      length = numofchar( unescaped ).
      restore_type( EXPORTING json = unescaped pretty_name = pretty_name length = length CHANGING data = data ).

    ENDIF.

  ENDMETHOD.


  METHOD DUMP.

    "Get attributes of class
    DATA: l_typedesc         TYPE REF TO cl_abap_typedescr,
          l_elem_descr       TYPE REF TO cl_abap_elemdescr,
          properties         TYPE STANDARD TABLE OF string,
          fields             TYPE STANDARD TABLE OF string,
          symbol_table       TYPE cl_abap_structdescr=>symbol_table,
          lv_prop_name       TYPE string,
          lv_itemval         TYPE string,
          l_timestamp_numc   TYPE n LENGTH 40,
          l_timestamp        TYPE string,
          l_date             TYPE sydate,
          l_time             TYPE syuzeit,
          l_msec             TYPE num03.

    DATA: ls_name_mapping LIKE LINE OF name_mapping.

    FIELD-SYMBOLS: <attr>             LIKE LINE OF cl_abap_objectdescr=>attributes,
                   <line>             TYPE any,
                   <value>            TYPE any,
                   <symbol_table>     LIKE LINE OF symbol_table,
                   <table>            TYPE ANY TABLE.

    " we need here macro instead of method calls because of the performance reasons.
    " Based on SAT measurments.

    "Loop attributes of class
    CASE type_descr->kind.
      WHEN cl_abap_typedescr=>kind_ref." OBJECT

        DATA: l_classdesc TYPE REF TO cl_abap_classdescr,
               obj_ref    TYPE REF TO object.

        IF data IS INITIAL.
          r_json = `null`.
        ELSE.
          obj_ref ?= data.
          l_classdesc ?= cl_abap_typedescr=>describe_by_object_ref( obj_ref ).

          LOOP AT l_classdesc->attributes ASSIGNING <attr> WHERE is_constant EQ abap_false AND alias_for IS INITIAL AND
            ( is_interface EQ abap_false OR type_kind NE cl_abap_typedescr=>typekind_oref ).
            ASSIGN obj_ref->(<attr>-name) TO <value>.
            READ TABLE name_mapping WITH KEY name_ddic = <attr>-name INTO ls_name_mapping TRANSPORTING name_json java_timestamp.
            IF compress EQ abap_false OR <value> IS NOT INITIAL.
              IF ls_name_mapping-java_timestamp IS NOT INITIAL AND <value> IS NOT INITIAL.
                CONVERT TIME STAMP <value> TIME ZONE space INTO DATE l_date TIME l_time.
                l_msec = <value> * 1000.
                CALL METHOD convert_abap_timestamp_to_java
                  EXPORTING
                    im_date      = l_date
                    im_time      = l_time
                    im_msec      = l_msec
                  IMPORTING
                    ex_timestamp = l_timestamp.
                l_timestamp_numc = l_timestamp.
                ASSIGN l_timestamp_numc TO <value>.
              ENDIF.
              l_typedesc = cl_abap_typedescr=>describe_by_data( <value> ).
              lv_itemval = dump( data = <value> compress = compress pretty_name = pretty_name type_descr = l_typedesc ).
              format_name <attr>-name pretty_name lv_prop_name ls_name_mapping.
              CONCATENATE `"` lv_prop_name  `":` lv_itemval INTO lv_itemval.
              APPEND lv_itemval TO properties.
            ENDIF.
          ENDLOOP.

          CONCATENATE LINES OF properties INTO r_json SEPARATED BY `,`.
          CONCATENATE `{` r_json `}` INTO r_json.
        ENDIF.

      WHEN cl_abap_typedescr=>kind_elem. "if it is elementary type_descr add it to json
        l_elem_descr ?= type_descr.
        "r_json = dump_type( data = data type_descr = l_elem_descr ).
        dump_type data l_elem_descr r_json.

      WHEN cl_abap_typedescr=>kind_struct."if it`s structure loop throught the components of structure

        DATA: l_structdesc TYPE REF TO cl_abap_structdescr.

        l_structdesc ?= type_descr.
        symbol_table = l_structdesc->get_symbols( ).

        LOOP AT symbol_table ASSIGNING <symbol_table>.
          ASSIGN COMPONENT <symbol_table>-name OF STRUCTURE data TO <value>.
          READ TABLE name_mapping WITH KEY name_ddic = <symbol_table>-name INTO ls_name_mapping TRANSPORTING name_json java_timestamp.
          IF compress EQ abap_false OR <value> IS NOT INITIAL.
            IF ls_name_mapping-java_timestamp IS NOT INITIAL AND <value> IS NOT INITIAL.
              CONVERT TIME STAMP <value> TIME ZONE space INTO DATE l_date TIME l_time.
              l_msec = <value> * 1000.
              CALL METHOD convert_abap_timestamp_to_java
                EXPORTING
                  im_date      = l_date
                  im_time      = l_time
                  im_msec      = l_msec
                IMPORTING
                  ex_timestamp = l_timestamp.
              l_timestamp_numc = l_timestamp.
              ASSIGN l_timestamp_numc TO <value>.
            ENDIF.
            lv_itemval = dump( data = <value> compress = compress pretty_name = pretty_name type_descr = <symbol_table>-type ).
            format_name <symbol_table>-name pretty_name lv_prop_name ls_name_mapping.
            CONCATENATE `"` lv_prop_name  `":` lv_itemval INTO lv_itemval.
            APPEND lv_itemval TO properties.
          ENDIF.
        ENDLOOP.

        CONCATENATE LINES OF properties INTO r_json SEPARATED BY `,`.
        CONCATENATE `{` r_json `}` INTO r_json.

      WHEN cl_abap_typedescr=>kind_table.

        DATA: l_tabledescr TYPE REF TO cl_abap_tabledescr.

        l_tabledescr ?= type_descr.
        l_typedesc = l_tabledescr->get_table_line_type( ).

        ASSIGN data TO <table>.

        " optimization for structured tables
        IF l_typedesc->kind EQ cl_abap_typedescr=>kind_struct.

          TYPES: BEGIN OF t_s_column,
                  header TYPE string,
                  name   TYPE string,
                  type   TYPE REF TO cl_abap_datadescr,
                 END OF t_s_column.

          DATA: columns TYPE STANDARD TABLE OF t_s_column.
          FIELD-SYMBOLS: <column> LIKE LINE OF columns.

          l_structdesc ?= l_typedesc.
          symbol_table = l_structdesc->get_symbols( ).
          LOOP AT symbol_table ASSIGNING <symbol_table>.
            APPEND INITIAL LINE TO columns ASSIGNING <column>.
            MOVE-CORRESPONDING <symbol_table> TO <column>.
            format_name <symbol_table>-name pretty_name <column>-header ls_name_mapping.
            CONCATENATE `"` <column>-header  `":` INTO <column>-header.
          ENDLOOP.
          LOOP AT <table> ASSIGNING <line>.
            CLEAR fields.
            LOOP AT columns ASSIGNING <column>.
              ASSIGN COMPONENT <column>-name OF STRUCTURE <line> TO <value>.
              READ TABLE name_mapping WITH KEY name_ddic = <column>-name INTO ls_name_mapping TRANSPORTING name_json java_timestamp.
              IF compress EQ abap_false OR <value> IS NOT INITIAL.
                IF <column>-type->kind EQ cl_abap_typedescr=>kind_elem.
                  IF ls_name_mapping-java_timestamp IS NOT INITIAL AND <value> IS NOT INITIAL.
                    CONVERT TIME STAMP <value> TIME ZONE space INTO DATE l_date TIME l_time.
                    l_msec = <value> * 1000.
                    CALL METHOD convert_abap_timestamp_to_java
                      EXPORTING
                        im_date      = l_date
                        im_time      = l_time
                        im_msec      = l_msec
                      IMPORTING
                        ex_timestamp = l_timestamp.
                    l_timestamp_numc = l_timestamp.
                    ASSIGN l_timestamp_numc TO <value>.
                  ENDIF.
                  l_elem_descr ?= <column>-type.
                  "lv_itemval = dump_type( data = <value> type_descr = l_elem_descr ).
                  dump_type <value> l_elem_descr lv_itemval.
                ELSE.
                  lv_itemval = dump( data = <value> compress = compress pretty_name = pretty_name type_descr = <column>-type ).
                ENDIF.
                CONCATENATE <column>-header lv_itemval INTO lv_itemval.
                APPEND lv_itemval TO fields.
              ENDIF.
            ENDLOOP.
            CONCATENATE LINES OF fields INTO lv_itemval SEPARATED BY `,`.
            CONCATENATE `{` lv_itemval `}` INTO lv_itemval.
            APPEND lv_itemval TO properties.
          ENDLOOP.
        ELSE.
          LOOP AT <table> ASSIGNING <value>.
            lv_itemval = dump( data = <value> compress = compress pretty_name = pretty_name type_descr = l_typedesc ).
            APPEND lv_itemval TO properties.
          ENDLOOP.
        ENDIF.

        CONCATENATE LINES OF properties INTO r_json SEPARATED BY `,`.
        CONCATENATE `[` r_json `]` INTO r_json.

    ENDCASE.

  ENDMETHOD.


  METHOD DUMP_TYPE.

    CASE type_descr->type_kind.
      WHEN cl_abap_typedescr=>typekind_float OR cl_abap_typedescr=>typekind_int OR cl_abap_typedescr=>typekind_int1 OR
           cl_abap_typedescr=>typekind_int2 OR cl_abap_typedescr=>typekind_packed.
        IF data IS INITIAL.
          r_json = `0`.
        ELSE.
          MOVE data TO r_json.
          IF data LT 0.
            SHIFT r_json RIGHT CIRCULAR.
          ELSE.
            CONDENSE r_json.
          ENDIF.
        ENDIF.
      WHEN cl_abap_typedescr=>typekind_num.
        IF data IS INITIAL.
          r_json = `0`.
        ELSE.
          MOVE data TO r_json.
          SHIFT r_json LEFT DELETING LEADING ` 0`.
        ENDIF.
      WHEN cl_abap_typedescr=>typekind_string OR cl_abap_typedescr=>typekind_csequence OR cl_abap_typedescr=>typekind_clike.
        IF data IS INITIAL.
          r_json = `""`.
        ELSE.
          r_json = escape( data ).
          CONCATENATE `"` r_json `"` INTO r_json.
        ENDIF.
      WHEN cl_abap_typedescr=>typekind_xstring.
        IF data IS INITIAL.
          r_json = `""`.
        ELSE.
          r_json = xstring_to_string( data ).
          r_json = escape( r_json ).
          CONCATENATE `"` r_json `"` INTO r_json.
        ENDIF.
      WHEN cl_abap_typedescr=>typekind_char OR cl_abap_typedescr=>typekind_hex.
        IF type_descr->output_length EQ 1 AND mc_boolean_types CS type_descr->absolute_name.
          IF data EQ abap_true.
            r_json = `true`.
          ELSE.
            r_json = `false`.
          ENDIF.
        ELSE.
          r_json = escape( data ).
          CONCATENATE `"` r_json `"` INTO r_json.
        ENDIF.
      WHEN cl_abap_typedescr=>typekind_date OR cl_abap_typedescr=>typekind_time.
        MOVE data TO r_json.
      WHEN OTHERS.
        IF data IS INITIAL.
          r_json = `null`.
        ELSE.
          MOVE data TO r_json.
        ENDIF.
    ENDCASE.

  ENDMETHOD.


  METHOD DUMP_TYPE_EX.

    DATA: lrf_descr TYPE REF TO cl_abap_elemdescr.
    lrf_descr ?= cl_abap_typedescr=>describe_by_data( data ).
    r_json = dump_type( data = data type_descr = lrf_descr ).

  ENDMETHOD.


  METHOD ESCAPE.

    MOVE in TO out.

    REPLACE ALL OCCURRENCES OF `\` IN out WITH `\\`.
    REPLACE ALL OCCURRENCES OF `"` IN out WITH `\"`.

  ENDMETHOD.


  METHOD PRETTY_NAME.

    DATA: tokens TYPE TABLE OF char128.
    FIELD-SYMBOLS: <token> LIKE LINE OF tokens.

    out = in.

    TRANSLATE out TO LOWER CASE.
    TRANSLATE out USING `/_:_~_`.
    SPLIT out AT `_` INTO TABLE tokens.
    DELETE tokens WHERE table_line IS INITIAL.
    LOOP AT tokens ASSIGNING <token> FROM 2.
      TRANSLATE <token>(1) TO UPPER CASE.
    ENDLOOP.

    CONCATENATE LINES OF tokens INTO out.

  ENDMETHOD.


  METHOD restore.

    DATA: mark        LIKE offset,
          match       LIKE offset,
          excp        TYPE REF TO cx_sy_move_cast_error,
          name_json   TYPE string,
          name_abap   TYPE string,
          l_timestamp TYPE string,
          l_date      TYPE sydate,
          l_time      TYPE syuzeit,
          l_msec      TYPE num03.

    DATA: ls_name_mapping LIKE LINE OF name_mapping.

    FIELD-SYMBOLS: <value> TYPE any.

    eat_white.
    eat_char `{`.

    WHILE offset < length AND json+offset(1) NE `}`.

      eat_white.
      eat_string name_json.
      eat_white.
      eat_char `:`.
      eat_white.
      UNASSIGN <value>.

      CLEAR: ls_name_mapping.

      READ TABLE name_mapping
           WITH KEY name_json = name_json
           INTO ls_name_mapping TRANSPORTING name_ddic java_timestamp.
      IF sy-subrc <> 0.
        ls_name_mapping-name_ddic = name_json.
      ENDIF.
      TRANSLATE ls_name_mapping-name_ddic TO UPPER CASE.
      ASSIGN COMPONENT ls_name_mapping-name_ddic OF STRUCTURE data TO <value>.

      IF <value> IS NOT ASSIGNED AND pretty_name EQ abap_true.
        name_abap = name_json.
        REPLACE ALL OCCURRENCES OF REGEX `([a-z])([A-Z])` IN name_abap WITH `$1_$2`. "#EC NOTEXT
        TRANSLATE name_abap TO UPPER CASE.
        ASSIGN COMPONENT name_abap OF STRUCTURE data TO <value>.
      ENDIF.

      IF <value> IS ASSIGNED.
        IF ls_name_mapping-java_timestamp IS NOT INITIAL.
          CLEAR: l_timestamp.
          restore_type( EXPORTING json = json length = length pretty_name = pretty_name CHANGING data = l_timestamp offset = offset ).
          CALL METHOD convert_java_timestamp_to_abap
            EXPORTING
              im_timestamp = l_timestamp
            IMPORTING
              ex_date      = l_date
              ex_time      = l_time
              ex_msec      = l_msec.

          CONVERT DATE l_date TIME l_time INTO TIME STAMP <value> TIME ZONE space.

          <value> = <value> + ( l_msec / 1000 ).

        ELSE.
          restore_type( EXPORTING json = json length = length pretty_name = pretty_name CHANGING data = <value> offset = offset ).
        ENDIF.
      ELSE.
        restore_type( EXPORTING json = json length = length pretty_name = pretty_name CHANGING offset = offset ).
      ENDIF.

      eat_white.

      IF offset < length AND json+offset(1) NE `}`.
        eat_char `,`.
      ELSE.
        EXIT.
      ENDIF.

    ENDWHILE.

    eat_char `}`.

  ENDMETHOD.


  METHOD restore_type.

    DATA: mark        LIKE offset,
          match       LIKE offset,
          sdummy      TYPE string,                          "#EC NEEDED
          idummy      TYPE i,                               "#EC NEEDED
          line        TYPE REF TO data,
          type_descr  TYPE REF TO cl_abap_typedescr,
          table_descr TYPE REF TO cl_abap_tabledescr,
          excp        TYPE REF TO cx_sy_move_cast_error.

    FIELD-SYMBOLS: <line>           TYPE any,
                   <table>          TYPE ANY TABLE,
                   <table_sorted>   TYPE SORTED TABLE,
                   <table_hashed>   TYPE HASHED TABLE,
                   <table_standard> TYPE STANDARD TABLE.

    eat_white.

    CASE json+offset(1).
      WHEN `{`. " object
        IF data IS SUPPLIED.
          restore( EXPORTING json = json pretty_name = pretty_name length = length
                   CHANGING data = data offset = offset ).
        ELSE.
          restore( EXPORTING json = json pretty_name = pretty_name length = length
                   CHANGING  offset = offset ).
        ENDIF.
      WHEN `[`. " array
        eat_char `[`.
        eat_white.
        IF json+offset(1) NE `]`.
          type_descr = cl_abap_typedescr=>describe_by_data( data ).
          IF type_descr->type_kind EQ cl_abap_typedescr=>typekind_table.
            table_descr ?= type_descr.
            ASSIGN data TO <table>.
            CREATE DATA line LIKE LINE OF <table>.
            ASSIGN line->* TO <line>.
            WHILE offset < length AND json+offset(1) NE `]`.
              CLEAR <line>.
              restore_type( EXPORTING json = json length = length pretty_name = pretty_name CHANGING data = <line> offset = offset ).
              CASE table_descr->table_kind.
                WHEN cl_abap_tabledescr=>tablekind_sorted.
                  ASSIGN data TO <table_sorted>.
                  INSERT <line> INTO TABLE <table_sorted>.
                WHEN cl_abap_tabledescr=>tablekind_hashed.
                  ASSIGN data TO <table_hashed>.
                  INSERT <line> INTO TABLE <table_hashed>.
                WHEN OTHERS.
                  ASSIGN data TO <table_standard>.
                  APPEND <line> TO <table_standard>.
              ENDCASE.
              eat_white.
              IF offset < length AND json+offset(1) NE `]`.
                eat_char `,`.
              ELSE.
                EXIT.
              ENDIF.
            ENDWHILE.
          ELSE.
            WHILE offset < length AND json+offset(1) NE `}`.
              eat_white.
              restore_type( EXPORTING json = json length = length pretty_name = pretty_name CHANGING offset = offset ).
              IF offset < length AND json+offset(1) NE `]`.
                eat_char `,`.
              ELSE.
                EXIT.
              ENDIF.
            ENDWHILE.
          ENDIF.
        ENDIF.
        eat_char `]`.
      WHEN `"`. " string
        IF data IS SUPPLIED.
          eat_string data.
          " unescape string
          REPLACE ALL OCCURRENCES OF `\"` IN data WITH `"`.
          REPLACE ALL OCCURRENCES OF `\\` IN data WITH `\`.
        ELSE.
          eat_string sdummy.
        ENDIF.
      WHEN `-`. " number
        IF data IS SUPPLIED.
          eat_number data.
        ELSE.
          eat_number idummy.
        ENDIF.
      WHEN OTHERS.
        IF '0123456789' CS json+offset(1). " number
          IF data IS SUPPLIED.
            eat_number data.
          ELSE.
            eat_number idummy.
          ENDIF.
        ELSE. " true/false/null
          IF data IS SUPPLIED.
            eat_bool data.
          ELSE.
            eat_bool sdummy.
          ENDIF.
        ENDIF.
    ENDCASE.
  ENDMETHOD.


  METHOD serialize.

    DATA: lrf_descr TYPE REF TO cl_abap_typedescr.

    IF type_descr IS INITIAL.
      lrf_descr = cl_abap_typedescr=>describe_by_data( data ).
    ELSE.
      lrf_descr = type_descr.
    ENDIF.

    r_json = dump( data = data compress = compress pretty_name = pretty_name type_descr = lrf_descr ).

    " we do not do escaping of every single string value for white space characters,
    " but we do it on top, to replace multiple calls by 3 only, while we do not serialize
    " outlined/formatted JSON this shall not produce any harm
    REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf          IN r_json WITH `\r\n`.
    REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>newline        IN r_json WITH `\n`.
    REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>horizontal_tab IN r_json WITH `\t`.
* REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>form_feed      IN r_json WITH `\f`.
* REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>backspace      IN r_json WITH `\b`.

    IF name IS NOT INITIAL AND ( compress EQ abap_false OR r_json IS NOT INITIAL ).
      CONCATENATE `"` name `":` r_json INTO r_json.
    ENDIF.

  ENDMETHOD.


  METHOD XSTRING_TO_STRING.

    DATA: lv_output_length   TYPE i,
          lt_binary_tab      TYPE STANDARD TABLE OF sdokcntbin.

    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        buffer        = in
      IMPORTING
        output_length = lv_output_length
      TABLES
        binary_tab    = lt_binary_tab.

    CALL FUNCTION 'SCMS_BINARY_TO_STRING'
      EXPORTING
        input_length  = lv_output_length
      IMPORTING
        text_buffer   = out
        output_length = lv_output_length
      TABLES
        binary_tab    = lt_binary_tab.

  ENDMETHOD.
ENDCLASS.
