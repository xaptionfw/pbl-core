*&---------------------------------------------------------------------*
*& Report  /GPIOS/PBL_GET_EVENT
*& GPIOS PbL: auf Touch Ereignis im Dialog reagieren
*&---------------------------------------------------------------------*
REPORT /gpios/pbl_get_event.

DATA:
  go_controller  TYPE REF TO /gpios/if_pbl_controller,
  go_realtime    TYPE REF TO /gpios/if_pbl_realtime,
  gv_last_ctrl   TYPE /gpios/pbl_ctl-sernr,
  gv_last_cbtype TYPE /gpios/pbl_cb_type.

*&---------------------------------------------------------------------*
*&      Class LCL_REALTIME
*&---------------------------------------------------------------------*
CLASS lcl_realtime DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      on_received FOR EVENT received OF /gpios/if_pbl_realtime
        IMPORTING
          sender
          et_rt_data.
ENDCLASS.

PARAMETERS:
  p_ctrl   TYPE /gpios/pbl_ctl-sernr OBLIGATORY MEMORY ID /gpios/pbl_ctl_rmt,
  p_cbtype TYPE /gpios/pbl_cb_type   AS LISTBOX VISIBLE LENGTH 20 OBLIGATORY DEFAULT 'IT' USER-COMMAND switch.
SELECTION-SCREEN:
  SKIP,
  COMMENT /1(50) g_com1 MODIF ID not,
  COMMENT /1(50) g_com2 MODIF ID reg.

INITIALIZATION.
  g_com1 = 'Bitte Eingabetaste für Registrierung drücken'(001).
  g_com2 = 'Registrierung ist erfolgt'(002).
  IF go_realtime IS INITIAL.
    go_realtime = /gpios/cl_pbl_realtime=>get_instance( iv_rt_type = /gpios/if_pbl_realtime=>gc_rt_type_html_socket ).
    SET HANDLER lcl_realtime=>on_received FOR go_realtime.
  ENDIF.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF ( screen-group1 = 'NOT' AND NOT go_realtime->gv_registered IS INITIAL ) OR
       ( screen-group1 = 'REG' AND go_realtime->gv_registered IS INITIAL ).
      screen-active = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.


AT SELECTION-SCREEN.
  CHECK NOT go_realtime IS INITIAL.
  IF gv_last_ctrl <> p_ctrl.
    go_realtime->unregister( ).
    go_controller = /gpios/cl_pbl_controller=>get_instance( iv_sernr = p_ctrl ).
  ENDIF.
  CHECK NOT go_controller IS INITIAL AND
        NOT go_realtime IS INITIAL.
  IF gv_last_ctrl <> p_ctrl OR
     gv_last_cbtype <> p_cbtype.
    go_realtime->unregister( ).
  ENDIF.
  IF go_realtime->gv_registered IS INITIAL.
    PERFORM register_realtime.
  ENDIF.
  gv_last_ctrl = p_ctrl.
  gv_last_cbtype = p_cbtype.

*&---------------------------------------------------------------------*
*&      Form  REGISTER_REALTIME
*&---------------------------------------------------------------------*
FORM register_realtime.
  DATA:
    lt_controller TYPE /gpios/if_pbl_types=>ty_t_controller,
    lt_cb_types   TYPE /gpios/if_pbl_types=>ty_t_cb_types.
  FIELD-SYMBOLS:
    <ls_cb> LIKE LINE OF /gpios/cl_pbl_settings_core=>instance->/gpios/pbl_cb.

  APPEND go_controller TO lt_controller.
  LOOP AT /gpios/cl_pbl_settings_core=>instance->/gpios/pbl_cb ASSIGNING <ls_cb>
    WHERE cb_type = p_cbtype.
    APPEND <ls_cb>-cb_type TO lt_cb_types.
  ENDLOOP.
  TRY.
      go_realtime->register( it_controller = lt_controller
                             it_cb_types   = lt_cb_types ).
    CATCH /gpios/cx_pbl.
      RETURN.
  ENDTRY.
ENDFORM.                    " REGISTER_REALTIME

*&---------------------------------------------------------------------*
*&      Class LCL_REALTIME
*&---------------------------------------------------------------------*
CLASS lcl_realtime IMPLEMENTATION.
  METHOD on_received.
    DATA:
      lo_rt_data TYPE REF TO /gpios/cl_pbl_rt_data.
    FIELD-SYMBOLS:
      <la_any> TYPE any.

    LOOP AT et_rt_data INTO lo_rt_data.
      ASSIGN lo_rt_data->gv_cb_data->* TO <la_any>.
*     cl_demo_output=>display( <la_any> ).
      CALL FUNCTION 'RS_COMPLEX_OBJECT_EDIT'
        EXPORTING
          object_name          = 'Callback Data' "#EC NOTEXT
*         popup                = abap_false
        CHANGING
          object               = <la_any>
        EXCEPTIONS
          object_not_supported = 1
          OTHERS               = 2.
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
