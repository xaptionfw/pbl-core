class /GPIOS/CL_PBL_SETTINGS definition
  public
  abstract
  create public .

*"* public components of class /GPIOS/CL_PBL_SETTINGS
*"* do not include other source files here!!!
public section.

  interfaces /GPIOS/IF_PBL_SETTINGS .

  aliases CLEAR
    for /GPIOS/IF_PBL_SETTINGS~CLEAR .
  aliases LOAD
    for /GPIOS/IF_PBL_SETTINGS~LOAD .
  aliases REFRESH
    for /GPIOS/IF_PBL_SETTINGS~REFRESH .

  class-methods CLASS_CONSTRUCTOR .
  PROTECTED SECTION.
*"* protected components of class /GPIOS/CL_PBL_SETTINGS
*"* do not include other source files here!!!

    DATA gv_main_interface TYPE seoclsname .

    METHODS load_interface_attributes
      IMPORTING
        !iv_interface_name TYPE seoclsname .
    METHODS clear_interface_attributes
      IMPORTING
        !iv_interface_name TYPE seoclsname .
    METHODS copy_interface_attributes
      IMPORTING
        !iv_interface_name TYPE seoclsname
        !io_source_class TYPE REF TO object .
private section.
*"* private components of class /GPIOS/CL_PBL_SETTINGS
*"* do not include other source files here!!!
ENDCLASS.



CLASS /GPIOS/CL_PBL_SETTINGS IMPLEMENTATION.


  METHOD /gpios/if_pbl_settings~clear.
    CHECK gv_main_interface IS NOT INITIAL.

    clear_interface_attributes( gv_main_interface ).
  ENDMETHOD.


  METHOD /gpios/if_pbl_settings~load.
    CHECK gv_main_interface IS NOT INITIAL.

    load_interface_attributes( gv_main_interface ).
  ENDMETHOD.


  METHOD /gpios/if_pbl_settings~refresh.
    clear( ).
    load( ).

    RAISE EVENT /gpios/if_pbl_settings~settings_refreshed.
  ENDMETHOD.


  METHOD CLASS_CONSTRUCTOR.
  ENDMETHOD.


  METHOD clear_interface_attributes.

    DATA: lo_intfdescr TYPE REF TO cl_abap_intfdescr,
          l_assign     TYPE string.

    FIELD-SYMBOLS: <ls_attributes> LIKE LINE OF lo_intfdescr->attributes,
                   <l_any>         TYPE any.

    lo_intfdescr ?= cl_abap_intfdescr=>describe_by_name( iv_interface_name ).

    CHECK lo_intfdescr IS NOT INITIAL.

    LOOP AT lo_intfdescr->attributes ASSIGNING <ls_attributes>.
      CONCATENATE iv_interface_name <ls_attributes>-name INTO l_assign SEPARATED BY '~'.
      ASSIGN (l_assign) TO <l_any>.
      CHECK sy-subrc IS INITIAL.
      CLEAR: <l_any>.
    ENDLOOP.

  ENDMETHOD.


  METHOD copy_interface_attributes.

    DATA: lo_intfdescr TYPE REF TO cl_abap_intfdescr,
          l_assign     TYPE string,
          l_attr_name  TYPE abap_attrname.

    FIELD-SYMBOLS: <ls_attributes> LIKE LINE OF lo_intfdescr->attributes,
                   <l_target>      TYPE any,
                   <l_source>      TYPE any.

    lo_intfdescr ?= cl_abap_intfdescr=>describe_by_name( iv_interface_name ).

    CHECK lo_intfdescr IS NOT INITIAL.

    LOOP AT lo_intfdescr->attributes ASSIGNING <ls_attributes>.
      CONCATENATE iv_interface_name <ls_attributes>-name INTO l_assign SEPARATED BY '~'.
      ASSIGN me->(l_assign) TO <l_target>.
      CHECK sy-subrc IS INITIAL.
      ASSIGN io_source_class->(l_assign) TO <l_source>.
      CHECK sy-subrc IS INITIAL.
      TRY.
* Maybe there is a special handling how to fill this attribute
          CALL METHOD (<ls_attributes>-name)
            CHANGING
              ch_attr = <l_target>.
        CATCH cx_sy_dyn_call_error.
* No special handling for this attribute its a simple db select
          TRY.
              MOVE <l_source> TO <l_target>.
            CATCH cx_root.
          ENDTRY.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.


  METHOD load_interface_attributes.

    DATA: lo_intfdescr   TYPE REF TO cl_abap_intfdescr,
          lo_typedescr   TYPE REF TO cl_abap_typedescr,
          l_assign       TYPE string,
          l_db_name      TYPE tabname16,
          l_attr_name    TYPE abap_attrname,
          l_assign_order TYPE string.

    FIELD-SYMBOLS: <ls_attributes>  LIKE LINE OF lo_intfdescr->attributes,
                   <l_any>          TYPE any,
                   <l_assign_order> TYPE any,
                   <l_any_table>    TYPE ANY TABLE.

    lo_intfdescr ?= cl_abap_intfdescr=>describe_by_name( iv_interface_name ).

    CHECK lo_intfdescr IS NOT INITIAL.

    LOOP AT lo_intfdescr->attributes ASSIGNING <ls_attributes>.
      CONCATENATE iv_interface_name <ls_attributes>-name INTO l_assign SEPARATED BY '~'.
      ASSIGN (l_assign) TO <l_any>.
      CHECK sy-subrc IS INITIAL.

      UNASSIGN <l_assign_order>.
      CONCATENATE <ls_attributes>-name `ORDER` INTO l_assign_order SEPARATED BY '_'.
      ASSIGN (l_assign_order) TO <l_assign_order>.

      TRY.
* Maybe there is a special handling how to fill this attribute
          CALL METHOD (<ls_attributes>-name)
            CHANGING
              ch_attr = <l_any>.
        CATCH cx_sy_dyn_call_error.
* No special handling for this attribute its a simple db select
          l_attr_name = <ls_attributes>-name.
          REPLACE FIRST OCCURRENCE OF REGEX: '\<CA_' IN l_attr_name WITH space.
          IF sy-subrc = 4.
            REPLACE FIRST OCCURRENCE OF REGEX: '\<CAS_'  IN l_attr_name WITH space.
          ENDIF.
          IF sy-subrc = 4.
            REPLACE FIRST OCCURRENCE OF REGEX: '\<CAT_'  IN l_attr_name WITH space.
          ENDIF.
          l_db_name = l_attr_name.
          lo_typedescr ?= cl_abap_typedescr=>describe_by_data( <l_any> ).
          CASE lo_typedescr->kind.
            WHEN cl_abap_typedescr=>kind_struct.
* Structure: Select single
              SELECT SINGLE * FROM (l_db_name)
                     INTO CORRESPONDING FIELDS OF <l_any>.
            WHEN cl_abap_typedescr=>kind_table.
* Table select all
              ASSIGN <l_any> TO <l_any_table>.
              IF  <l_assign_order> IS ASSIGNED.
                SELECT * FROM (l_db_name)
                       INTO CORRESPONDING FIELDS OF TABLE <l_any_table>
                       ORDER BY (<l_assign_order>).
              ELSE.
                SELECT * FROM (l_db_name)
                       INTO CORRESPONDING FIELDS OF TABLE <l_any_table>.
              ENDIF.

            WHEN OTHERS.
* Not supported
              CONTINUE. " >>>>>>
          ENDCASE.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
