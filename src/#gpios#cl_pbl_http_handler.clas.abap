class /GPIOS/CL_PBL_HTTP_HANDLER definition
  public
  create public .

public section.

  interfaces IF_HTTP_EXTENSION .

  methods CONVERT_CALLBACK_DATA
    importing
      !IO_SERVER type ref to IF_HTTP_SERVER optional
      !IV_CB_TYPE type /GPIOS/PBL_CB_TYPE
    exporting
      !ER_CB_DATA type ref to DATA .
  methods GET_CALLBACK_STRUCTURE_REF
    importing
      !IV_CB_TYPE type /GPIOS/PBL_CB_TYPE
    exporting
      !ER_STRUCTURE_REF type ref to DATA .
  methods JSON2ABAP
    importing
      !I_JSON type STRING
    exporting
      !E_DATA type ANY
      !E_ERROR type STRING .
  methods DESERIALIZE_CALLBACK_DATA
    importing
      !IV_JSON type STRING
      !IV_CB_TYPE type /GPIOS/PBL_CB_TYPE
    exporting
      !ER_CB_DATA type ref to DATA .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /GPIOS/CL_PBL_HTTP_HANDLER IMPLEMENTATION.


  METHOD convert_callback_data.

    DATA: l_method TYPE seocpdname,
          l_json   TYPE string.

    CLEAR: er_cb_data.

    CONCATENATE `CONVERT` iv_cb_type INTO l_method SEPARATED BY '_'.

    TRY.
*    pc  picking change
*    it  io touch
*    ic  io change
*    iac  io assignment change
*    irc  ir change
        CALL METHOD me->(l_method)
          EXPORTING
            io_server  = io_server
          IMPORTING
            er_cb_data = er_cb_data.
      CATCH cx_sy_dyn_call_error.
    ENDTRY.

    CHECK er_cb_data IS NOT BOUND.


    l_json = io_server->request->get_cdata( ).

    deserialize_callback_data( EXPORTING iv_json    = l_json
                                         iv_cb_type = iv_cb_type
                               IMPORTING er_cb_data = er_cb_data ).


  ENDMETHOD.


  METHOD deserialize_callback_data.

    DATA: l_method TYPE seocpdname,
          l_error TYPE string.

    FIELD-SYMBOLS: <ls_cb_data> TYPE any.

    CLEAR: er_cb_data.

    CALL METHOD get_callback_structure_ref
      EXPORTING
        iv_cb_type       = iv_cb_type
      IMPORTING
        er_structure_ref = er_cb_data.

    CHECK er_cb_data IS BOUND.

    ASSIGN er_cb_data->* TO <ls_cb_data>.

    CALL METHOD json2abap
      EXPORTING
        i_json  = iv_json
      IMPORTING
        e_data  = <ls_cb_data>
        e_error = l_error.

  ENDMETHOD.


  METHOD get_callback_structure_ref.

    DATA: l_name TYPE strukname.

    CLEAR: er_structure_ref.

    DATA: lo_structdescr TYPE REF TO cl_abap_structdescr.

    CONCATENATE '/GPIOS/PBL_CB_DATA' iv_cb_type INTO l_name SEPARATED BY '_'.

    TRY.
        lo_structdescr  ?= cl_abap_structdescr=>describe_by_name( p_name = l_name ).
        CREATE DATA er_structure_ref TYPE HANDLE lo_structdescr.
      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.


  METHOD if_http_extension~handle_request.

    DATA: lo_callback    TYPE REF TO /gpios/if_pbl_callback,
          l_cb_type      TYPE /gpios/pbl_cb_type,
          lr_cb_data     TYPE REF TO data,
          l_http_code    TYPE i,
          l_http_reason  TYPE string,
          l_http_payload TYPE string,
          lo_controller  TYPE REF TO /gpios/if_pbl_controller.

    FIELD-SYMBOLS: <la_cb_data> TYPE any.

    cl_bcs_breakloop=>execute_loop( iv_module = '/GPIOS/PBL_CALLBACK_DEBUG' ).

    lo_callback = /gpios/cl_pbl_callback=>get_instance_for_http_server( io_server = server ).

    CHECK lo_callback IS NOT INITIAL.
    TRY.
        lo_controller = lo_callback->get_controller_for_server( io_server = server ).
      CATCH /gpios/cx_pbl.
        RETURN.
    ENDTRY.
    l_cb_type = lo_callback->get_callback_type_for_server( io_server = server ).

    CHECK l_cb_type IS NOT INITIAL.

    me->convert_callback_data( EXPORTING io_server  = server
                                         iv_cb_type = l_cb_type
                               IMPORTING er_cb_data = lr_cb_data ).

    CHECK lr_cb_data IS BOUND.

    ASSIGN lr_cb_data->* TO <la_cb_data>.

    lo_callback->handle_callback( EXPORTING iv_cb_type      = l_cb_type
                                            iv_cb_data      = <la_cb_data>
                                            io_controller   = lo_controller
                                  IMPORTING ev_http_code    = l_http_code
                                            ev_http_reason  = l_http_reason
                                            ev_http_payload = l_http_payload ).

    IF l_http_code IS INITIAL.
      l_http_code = /gpios/if_pbl_callback=>gc_http_code_ok.
    ENDIF.

    server->response->set_status(
      EXPORTING
        code   = l_http_code
        reason = l_http_reason ).

    IF l_http_payload IS NOT INITIAL.
      server->response->set_cdata(
        EXPORTING data   = l_http_payload ).
    ENDIF.

  ENDMETHOD.


  METHOD json2abap.
    DATA:
      l_json   TYPE string,
      lo_error TYPE REF TO cx_root.

*    TRY.
*        CALL METHOD /ui2/cl_json=>('DESERIALIZE')
*          EXPORTING
*            json        = i_json
*            pretty_name = ' '
*          CHANGING
*            data        = e_data.
*      CATCH cx_sy_create_data_error INTO lo_error.
*        e_error = lo_error->get_text( ).
*        RETURN.
*      CATCH cx_sy_dyn_call_illegal_method.
    TRY.
        /gpios/cl_pbl_json=>deserialize(
          EXPORTING
            json        =  i_json
          CHANGING
            data        = e_data ).
      CATCH cx_root.
        CONCATENATE '{"DATA":' i_json '}' INTO l_json.
        TRY.
            CALL TRANSFORMATION id "OPTIONS clear = 'all'
              SOURCE XML l_json
              RESULT data = e_data.
          CATCH cx_transformation_error INTO lo_error.
            e_error = lo_error->get_text( ).
        ENDTRY.
    ENDTRY.
*    ENDTRY.
  ENDMETHOD.
ENDCLASS.
