class /GPIOS/CL_PBL_CALLBACK definition
  public
  create protected .

public section.

  interfaces /GPIOS/IF_PBL_CALLBACK .

  class-methods GET_INSTANCE_FOR_HTTP_SERVER
    importing
      !IO_SERVER type ref to IF_HTTP_SERVER
    returning
      value(RO_INSTANCE) type ref to /GPIOS/IF_PBL_CALLBACK .
  class-methods GET_NOTIFICATION_TEXT
    importing
      !IO_CONTROLLER type ref to /GPIOS/IF_PBL_CONTROLLER
      !IV_CB_TYPE type /GPIOS/PBL_CB_TYPE
      !IV_CB_DATA type ANY
    returning
      value(RV_TEXT) type STRING .
  methods EXECUTE_NOTIFICATION_TEST
    importing
      !IV_UNAME type SY-UNAME
      !IV_CB_TYPE type /GPIOS/PBL_CB_TYPE
      !IV_CB_DATA type ANY
      !IO_CONTROLLER type ref to /GPIOS/IF_PBL_CONTROLLER optional .
  methods IS_NOTIFICATION_TEST_ACTIVE
    returning
      value(RV_CREATED_FOR) type BCSD_BREAKLOOP-CREATEDFOR .
  methods SEND_REALTIME
    importing
      !IV_CB_DATA type ANY
      !IV_CB_TYPE type /GPIOS/PBL_CB_TYPE
      !IO_CONTROLLER type ref to /GPIOS/IF_PBL_CONTROLLER
    raising
      CX_AMC_ERROR .
protected section.
private section.
ENDCLASS.



CLASS /GPIOS/CL_PBL_CALLBACK IMPLEMENTATION.


  METHOD /gpios/if_pbl_callback~get_callback_type_for_server.

    DATA: l_method TYPE /gpios/pbl_cb-method,
          l_path TYPE /gpios/pbl_cb-path.

    l_method = io_server->request->get_method( ).

    l_path = io_server->request->get_header_field( '~path_translated' ).

    CHECK NOT ( l_path IS INITIAL OR l_method IS INITIAL ).

    SELECT SINGLE cb_type                               "#EC CI_NOFIELD
           FROM /gpios/pbl_cb
           INTO rv_cb_type
           WHERE method = l_method
           AND   path   = l_path.

  ENDMETHOD.


  METHOD /gpios/if_pbl_callback~get_controller_for_server.

    ro_controller = /gpios/cl_pbl_controller=>get_instance_for_ip( iv_ip = cl_http_server=>c_caller_ip ).

  ENDMETHOD.


  METHOD /gpios/if_pbl_callback~handle_callback.

    DATA: lo_callback        TYPE REF TO /gpios/if_pbl_callback,
          l_method           TYPE seocpdname,
          l_notify_test_user TYPE sy-uname.

    CLEAR: ev_http_reason, ev_http_payload.

    CONCATENATE 'HANDLE_CALLBACK' iv_cb_type INTO l_method SEPARATED BY '_'.

    lo_callback = me.

    ev_http_code = /gpios/if_pbl_callback=>gc_http_code_ok.

    l_notify_test_user = is_notification_test_active( ).
    IF l_notify_test_user IS NOT INITIAL.
      execute_notification_test( iv_cb_data    = iv_cb_data
                                 io_controller = io_controller
                                 iv_cb_type    = iv_cb_type
                                 iv_uname      = l_notify_test_user ).
    ENDIF.

    TRY.
        CALL METHOD lo_callback->(l_method)
          EXPORTING
            iv_cb_data      = iv_cb_data
            io_controller   = io_controller
          IMPORTING
            ev_http_code    = ev_http_code
            ev_http_reason  = ev_http_reason
            ev_http_payload = ev_http_payload.
      CATCH cx_sy_dyn_call_error.
        ev_http_code = /gpios/if_pbl_callback=>gc_http_code_not_implemented.
    ENDTRY.

    IF ev_http_code = /gpios/if_pbl_callback=>gc_http_code_not_implemented.
      ev_http_reason = 'The Callback Method is not implemented on this SAP System. Please contact a SAP Developer.'.
    ENDIF.

  ENDMETHOD.


  METHOD /gpios/if_pbl_callback~handle_callback_iac.

    ev_http_code = /gpios/if_pbl_callback=>gc_http_code_not_implemented.
    TRY.
        send_realtime( iv_cb_data    = iv_cb_data
                       iv_cb_type    = /gpios/if_pbl_callback=>gc_cb_type_io_assign_change
                       io_controller = io_controller ).
      CATCH cx_amc_error.
        RETURN.
    ENDTRY.

  ENDMETHOD.


  METHOD /gpios/if_pbl_callback~handle_callback_ic.

    ev_http_code = /gpios/if_pbl_callback=>gc_http_code_not_implemented.
    TRY.
        send_realtime( iv_cb_data    = iv_cb_data
                       iv_cb_type    = /gpios/if_pbl_callback=>gc_cb_type_io_change
                       io_controller = io_controller ).
      CATCH cx_amc_error.
        RETURN.
    ENDTRY.

  ENDMETHOD.


  METHOD /gpios/if_pbl_callback~handle_callback_irc.

    ev_http_code = /gpios/if_pbl_callback=>gc_http_code_not_implemented.
    TRY.
        send_realtime( iv_cb_data    = iv_cb_data
                       iv_cb_type    = /gpios/if_pbl_callback=>gc_cb_type_ir_change
                       io_controller = io_controller ).
      CATCH cx_amc_error.
        RETURN.
    ENDTRY.

  ENDMETHOD.


  METHOD /gpios/if_pbl_callback~handle_callback_it.

    ev_http_code = /gpios/if_pbl_callback=>gc_http_code_not_implemented.
    TRY.
        send_realtime( iv_cb_data    = iv_cb_data
                       iv_cb_type    = /gpios/if_pbl_callback=>gc_cb_type_io_touch
                       io_controller = io_controller ).
      CATCH cx_amc_error.
        RETURN.
    ENDTRY.

  ENDMETHOD.


  METHOD /gpios/if_pbl_callback~handle_callback_pc.

    ev_http_code = /gpios/if_pbl_callback=>gc_http_code_not_implemented.
    TRY.
        send_realtime( iv_cb_data    = iv_cb_data
                       iv_cb_type    = /gpios/if_pbl_callback=>gc_cb_type_picking_change
                       io_controller = io_controller ).
      CATCH cx_amc_error.
        RETURN.
    ENDTRY.

  ENDMETHOD.


  METHOD execute_notification_test.

    DATA: l_msg          TYPE sm04dic-popupmsg,
          l_cb_data_json TYPE string.

    CHECK iv_uname IS NOT INITIAL.

    l_msg = get_notification_text( io_controller = io_controller
                                   iv_cb_type    = iv_cb_type
                                   iv_cb_data    = iv_cb_data ).

    CALL FUNCTION 'TH_POPUP'
      EXPORTING
        client         = sy-mandt
        user           = iv_uname
        message        = l_msg
      EXCEPTIONS
        user_not_found = 1
        OTHERS         = 2.

    CHECK sy-subrc = 0.

  ENDMETHOD.


  METHOD get_instance_for_http_server.

    CHECK ro_instance IS INITIAL.

    IF /gpios/cl_pbl_settings_core=>instance->/gpios/pbl_set-clsname_callback IS NOT INITIAL.
      CREATE OBJECT ro_instance TYPE (/gpios/cl_pbl_settings_core=>instance->/gpios/pbl_set-clsname_callback).
    ELSE.
      CREATE OBJECT ro_instance TYPE /gpios/cl_pbl_callback.
    ENDIF.

  ENDMETHOD.


  METHOD get_notification_text.

    DATA:
          l_dummy         TYPE string,
          l_sernr         TYPE /gpios/pbl_sernr,
          l_io_unit       TYPE /gpios/pbl_ledno.

    FIELD-SYMBOLS: <ls_pc>  TYPE /gpios/pbl_cb_data_pc,
                   <ls_iac> TYPE /gpios/pbl_cb_data_iac,
                   <ls_ic>  TYPE /gpios/pbl_cb_data_ic,
                   <ls_irc> TYPE /gpios/pbl_cb_data_irc,
                   <ls_it>  TYPE /gpios/pbl_cb_data_it.

    IF io_controller IS NOT INITIAL.
      l_sernr = io_controller->gs_data-sernr.
      CONCATENATE l_sernr io_controller->gv_description INTO l_sernr SEPARATED BY ` - `.
    ENDIF.
*012  Stückliste &1 auf Controller &2 gestartet
*013  Stückliste &2 auf Controller &2 gestoppt
*014  Komponente &1 von Stückliste &2 auf Controller &3 rückgemeldet mit &4.
*015  Farbe von IO-Einheit &1 an Controller &2 geändert: &4
*016  Sensor von IO-Einheit &1 an Controller &2 geändert: &4
*Zuordnung von Komponente &1 an IO-Einheit &2 auf Controller &3 geändert
    CASE iv_cb_type.
      WHEN /gpios/if_pbl_callback=>gc_cb_type_picking_change.
        ASSIGN iv_cb_data TO <ls_pc>.
        IF <ls_pc>-stopped = abap_true.
          MESSAGE s013 WITH <ls_pc>-baugr l_sernr INTO rv_text.
        ELSE.
          MESSAGE s012 WITH <ls_pc>-baugr l_sernr INTO rv_text.
        ENDIF.
      WHEN /gpios/if_pbl_callback=>gc_cb_type_io_assign_change.
        ASSIGN iv_cb_data TO <ls_iac>.
        MESSAGE s017 WITH <ls_iac>-idnrk <ls_iac>-id l_sernr INTO rv_text.
      WHEN /gpios/if_pbl_callback=>gc_cb_type_io_change.
        ASSIGN iv_cb_data TO <ls_ic>.
        IF <ls_ic>-redon IS INITIAL.
          l_dummy = `R: `.
        ELSE.
          l_dummy = `R:X`.
        ENDIF.
        IF <ls_ic>-greenon IS INITIAL.
          CONCATENATE l_dummy `G: ` INTO l_dummy SEPARATED BY ` | `.
        ELSE.
          CONCATENATE l_dummy `G:X` INTO l_dummy SEPARATED BY ` | `.
        ENDIF.
        IF <ls_ic>-blueon IS INITIAL.
          CONCATENATE l_dummy `B: ` INTO l_dummy SEPARATED BY ` | `.
        ELSE.
          CONCATENATE l_dummy `B:X` INTO l_dummy SEPARATED BY ` | `.
        ENDIF.
        MESSAGE s015 WITH <ls_ic>-io_uid l_sernr l_dummy  INTO rv_text.
      WHEN /gpios/if_pbl_callback=>gc_cb_type_io_touch.
        ASSIGN iv_cb_data TO <ls_it>.
        MESSAGE s014 WITH <ls_it>-touched_io-io_uid <ls_it>-baugr l_sernr <ls_it>-touched_id INTO rv_text.
      WHEN /gpios/if_pbl_callback=>gc_cb_type_ir_change.
        ASSIGN iv_cb_data TO <ls_irc>.
        MESSAGE s016 WITH <ls_irc>-iounit-io_uid <ls_irc>-touched_id l_sernr INTO rv_text.
    ENDCASE.

  ENDMETHOD.


  METHOD is_notification_test_active.

* Notification Test switch is realized via BCS_BREAKLOOP Functionality. See:
* cl_bcs_breakloop=>get_loop( iv_module =  ).
* For more details

    DATA lv_timestamp TYPE timestamp.

    GET TIME STAMP FIELD lv_timestamp.

    SELECT SINGLE createdfor
           FROM bcsd_breakloop INTO rv_created_for WHERE    "#EC WARNOK
                    bl_module   = /gpios/if_pbl_callback=>gc_bcs_notification_test     AND
*                  ( createdfor  = sy-uname OR
                    createdfor  <> '*'          AND
                    createdfor  <> space        AND
                    status      = sx_true       AND
                    deleted     = sx_false      AND
                    exptime    >= lv_timestamp.

  ENDMETHOD.


  METHOD send_realtime.

    DATA: lo_realtime TYPE REF TO /gpios/if_pbl_realtime.

    lo_realtime = /gpios/cl_pbl_realtime=>get_instance( iv_rt_type = /gpios/if_pbl_realtime=>gc_rt_type_html_socket ).

    lo_realtime->send( EXPORTING iv_cb_type    = iv_cb_type
                                 iv_cb_data    = iv_cb_data
                                 io_controller = io_controller ).
  ENDMETHOD.
ENDCLASS.
