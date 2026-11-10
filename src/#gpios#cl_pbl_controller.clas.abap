class /GPIOS/CL_PBL_CONTROLLER definition
  public
  create protected

  global friends /GPIOS/IF_PBL_BOM
                 /GPIOS/IF_PBL_BOM_ITEM
                 /GPIOS/IF_PBL_IO_UNIT .

public section.

  interfaces /GPIOS/IF_PBL_CONTROLLER .

  interface /GPIOS/IF_PBL_TYPES load .
  data GT_R_FLAT_CONVERSION type /GPIOS/IF_PBL_TYPES=>TY_R_DATA_TYPES read-only .

  class-methods CLASS_CONSTRUCTOR .
  class-methods GET_INSTANCE
    importing
      !IV_SERNR type /GPIOS/PBL_SERNR
    returning
      value(RO_INSTANCE) type ref to /GPIOS/IF_PBL_CONTROLLER
    raising
      /GPIOS/CX_PBL .
  class-methods GET_INSTANCE_FOR_IP
    importing
      !IV_IP type RFCIPV6ADDR
    returning
      value(RO_INSTANCE) type ref to /GPIOS/IF_PBL_CONTROLLER
    raising
      /GPIOS/CX_PBL .
  class-methods HOST_TO_IP
    importing
      !IV_HOST type CLIKE
    returning
      value(RV_IP) type RFCDISPLAY-RFCHOST .
  methods ABAP2JSON
    importing
      !IV_DATA_TYPE type /GPIOS/PBL_DATA_TYPE optional
      !IV_ACTION_TYPE type /GPIOS/PBL_ACTION_TYPE optional
      !IA_DATA type ANY
    exporting
      !EV_JSON type STRING .
  type-pools ABAP .
  methods GET_HTTP_CLIENT
    importing
      !IV_AUTHENTICATE type ABAP_BOOL default ABAP_TRUE
      !IV_PATH type PFADPRE optional
    returning
      value(RO_CLIENT) type ref to IF_HTTP_CLIENT
    raising
      /GPIOS/CX_PBL .
  methods JSON2ABAP
    importing
      !IV_JSON type STRING
      !IV_DATA_TYPE type /GPIOS/PBL_DATA_TYPE optional
    exporting
      !EA_DATA type ANY .
protected section.

  types:
    BEGIN OF ty_instance_key,
            sernr TYPE /gpios/pbl_sernr,
    END OF   ty_instance_key .
  types:
    BEGIN OF ty_instance.
  INCLUDE TYPE ty_instance_key AS key.
  TYPES: instance TYPE REF TO /gpios/if_pbl_controller,
    END OF   ty_instance .
  types:
    ty_t_instances TYPE HASHED TABLE OF ty_instance WITH UNIQUE KEY key .

  class-data GT_INSTANCES type TY_T_INSTANCES .

  methods CONSTRUCTOR
    importing
      !IV_SERNR type /GPIOS/PBL_SERNR
      !IV_CREATE type ABAP_BOOL default ABAP_FALSE
    raising
      /GPIOS/CX_PBL_CORE .
  methods DELETE_DATA
    importing
      !IV_DATA_TYPE type /GPIOS/PBL_DATA_TYPE
      !IA_DATA type ANY optional
    raising
      /GPIOS/CX_PBL .
  methods INIT .
  methods RECEIVE_DATA
    importing
      !IV_DATA_TYPE type /GPIOS/PBL_DATA_TYPE
    raising
      /GPIOS/CX_PBL .
  methods SET_DELETETION_DELTA
    importing
      !IA_MY_DATA type ANY
      !IA_FOREIGN_DATA type ANY
      !IV_DATA_TYPE type /GPIOS/PBL_DATA_TYPE .
  methods TRANSFER_DATA
    importing
      !IV_DATA_TYPE type /GPIOS/PBL_DATA_TYPE
    raising
      /GPIOS/CX_PBL .
  methods TRIGGER_ACTION
    importing
      !IV_ACTION_TYPE type /GPIOS/PBL_ACTION_TYPE
      !IA_DATA type ANY optional
    exporting
      !EV_RESPONSE type STRING
      !EV_CODE type I
      !EV_REASON type STRING
    raising
      /GPIOS/CX_PBL .
private section.
ENDCLASS.



CLASS /GPIOS/CL_PBL_CONTROLLER IMPLEMENTATION.


  METHOD /gpios/if_pbl_controller~check_controller_accessible.
    DATA: l_host TYPE rfchost_ext.

    CHECK /gpios/if_pbl_controller~ping( ) <> 0.
    /gpios/if_pbl_controller~get_connection_info( IMPORTING ev_host = l_host ).

    /gpios/cx_pbl_core=>controller_not_accessible(
        io_controller = me
        iv_host       = l_host ).
  ENDMETHOD.


  METHOD /gpios/if_pbl_controller~copy_data_from_ref_controller.
    DATA: lr_foreign_data TYPE REF TO data,
          lr_my_data      TYPE REF TO data,
          lo_typedescr    TYPE REF TO cl_abap_typedescr.

    FIELD-SYMBOLS: <la_foreign_data> TYPE any,
                   <la_my_data>      TYPE any,
                   <lt_my_data>      TYPE STANDARD TABLE,
                   <l_sernr>         TYPE /gpios/pbl_sernr.

    io_ref_controller->get_data_ref_for_data_type(
      EXPORTING iv_data_type = iv_data_type
                iv_comm_type = iv_ref_comm_type
      IMPORTING er_data      = lr_foreign_data ).

    CHECK lr_foreign_data IS BOUND.

    ASSIGN lr_foreign_data->* TO <la_foreign_data>.

    IF iv_load_data = abap_true.
      io_ref_controller->load(
        EXPORTING iv_comm_type    = iv_ref_comm_type
                  iv_data_type    = iv_data_type ).
    ENDIF.

    me->/gpios/if_pbl_controller~get_data_ref_for_data_type(
                                    EXPORTING iv_data_type = iv_data_type
                                              iv_comm_type = iv_my_comm_type
                                    IMPORTING er_data      = lr_my_data ).
    CHECK lr_my_data IS BOUND.
    ASSIGN lr_my_data->* TO <la_my_data>.

    IF iv_save = abap_true AND iv_delete_before = abap_true.
      set_deletetion_delta( ia_my_data      = <la_my_data>
                            ia_foreign_data = <la_foreign_data>
                            iv_data_type    = iv_data_type ).

    ENDIF.

    <la_my_data> = <la_foreign_data>.

    IF io_ref_controller <> me.
      lo_typedescr = cl_abap_typedescr=>describe_by_data( p_data = <la_my_data> ).
      CASE lo_typedescr->kind.
        WHEN   cl_abap_typedescr=>kind_table.
          ASSIGN <la_my_data> TO <lt_my_data>.
          LOOP AT <lt_my_data> ASSIGNING <la_my_data>.
            ASSIGN COMPONENT 'SERNR' OF STRUCTURE <la_my_data> TO <l_sernr>.
            IF sy-subrc <> 0.
              EXIT. ">>>>>>>
            ENDIF.
            <l_sernr> = /gpios/if_pbl_controller~gs_data-sernr.
          ENDLOOP.
        WHEN cl_abap_typedescr=>kind_struct.
          ASSIGN COMPONENT 'SERNR' OF STRUCTURE <la_my_data> TO <l_sernr>.
          IF sy-subrc = 0.
            <l_sernr> = /gpios/if_pbl_controller~gs_data-sernr.
          ENDIF.
      ENDCASE.
    ENDIF.

    IF iv_save = abap_true.
      IF iv_delete_before = abap_true.
        me->/gpios/if_pbl_controller~delete(
                    EXPORTING iv_all             = abap_false
                              iv_clear_attribute = abap_false
                              iv_comm_type       = iv_my_comm_type
                              iv_data_type       = iv_data_type ).
      ENDIF.

      me->/gpios/if_pbl_controller~save(
                  EXPORTING iv_delete_before = abap_false
                            iv_comm_type     = iv_my_comm_type
                            iv_data_type     = iv_data_type ).
    ENDIF.

  ENDMETHOD.


  METHOD /gpios/if_pbl_controller~delete.
    CASE iv_data_type.
      WHEN /gpios/if_pbl_controller=>gc_data_type_components.
        /gpios/if_pbl_controller~delete_components(
          EXPORTING iv_all             = iv_all
                    iv_clear_attribute = iv_clear_attribute
                    iv_comm_type       = iv_comm_type
                    iv_ping            = iv_ping ).
      WHEN /gpios/if_pbl_controller=>gc_data_type_devices.
        /gpios/if_pbl_controller~delete_device_settings(
          EXPORTING iv_all             = iv_all
                    iv_clear_attribute = iv_clear_attribute
                    iv_comm_type       = iv_comm_type
                    iv_ping            = iv_ping  ).
      WHEN /gpios/if_pbl_controller=>gc_data_type_bomhdr.
        /gpios/if_pbl_controller~delete_bom_headers(
          EXPORTING iv_all             = iv_all
                    iv_clear_attribute = iv_clear_attribute
                    iv_comm_type       = iv_comm_type
                    iv_ping            = iv_ping  ).
      WHEN /gpios/if_pbl_controller=>gc_data_type_bomitm.
        /gpios/if_pbl_controller~delete_bom_items(
          EXPORTING iv_all             = iv_all
                    iv_clear_attribute = iv_clear_attribute
                    iv_comm_type       = iv_comm_type
                    iv_ping            = iv_ping  ).
      WHEN /gpios/if_pbl_controller=>gc_data_type_users.
        /gpios/if_pbl_controller~delete_users(
          EXPORTING iv_all             = iv_all
                    iv_clear_attribute = iv_clear_attribute
                    iv_comm_type       = iv_comm_type
                    iv_ping            = iv_ping  ).
    ENDCASE.


  ENDMETHOD.


  METHOD /gpios/if_pbl_controller~delete_bom_headers.
    DATA: lt_copy_remote    LIKE /gpios/if_pbl_controller~gt_remote_bom_headers,
          ls_bom_header_key LIKE LINE OF /gpios/if_pbl_controller~gt_delete_bom_headers.

    FIELD-SYMBOLS: <ls_bom_headers>       LIKE LINE OF /gpios/if_pbl_controller~gt_remote_bom_headers,
                   <ls_delete_bom_header> LIKE LINE OF /gpios/if_pbl_controller~gt_delete_bom_headers.

    CASE iv_comm_type.
      WHEN /gpios/if_pbl_controller=>gc_comm_type_remote.

        IF iv_all = abap_true.
          CLEAR: /gpios/if_pbl_controller~gt_delete_bom_headers.
          lt_copy_remote  = /gpios/if_pbl_controller~gt_remote_bom_headers.
          /gpios/if_pbl_controller~load_bom_headers( EXPORTING iv_comm_type = iv_comm_type
                                                                 iv_ping      = iv_ping ).
          LOOP AT /gpios/if_pbl_controller~gt_remote_bom_headers ASSIGNING <ls_bom_headers>.
            MOVE-CORRESPONDING <ls_bom_headers> TO ls_bom_header_key.
            APPEND ls_bom_header_key TO /gpios/if_pbl_controller~gt_delete_bom_headers.
          ENDLOOP.
        ENDIF.

        CHECK /gpios/if_pbl_controller~gt_delete_bom_headers IS NOT INITIAL.

        delete_data( EXPORTING iv_data_type = /gpios/if_pbl_controller=>gc_data_type_bomhdr ).

        IF iv_all = abap_true.
          /gpios/if_pbl_controller~gt_remote_bom_headers = lt_copy_remote.
        ENDIF.

        IF iv_clear_attribute = abap_true.
          IF iv_all = abap_true.
            CLEAR: /gpios/if_pbl_controller~gt_remote_bom_headers.
          ELSE.
            LOOP AT /gpios/if_pbl_controller~gt_delete_bom_headers INTO ls_bom_header_key.
              DELETE /gpios/if_pbl_controller~gt_remote_bom_headers WHERE sernr = ls_bom_header_key-sernr
                                                                      AND   baugr = ls_bom_header_key-baugr.
              DELETE /gpios/if_pbl_controller~gt_remote_bom_items WHERE sernr = ls_bom_header_key-sernr
                                                                    AND   baugr = ls_bom_header_key-baugr.

            ENDLOOP.
          ENDIF.
        ENDIF.

      WHEN /gpios/if_pbl_controller=>gc_comm_type_local.
        IF iv_all = abap_true.
          DELETE FROM /gpios/pbl_bh WHERE sernr = /gpios/if_pbl_controller~gs_data-sernr.
          DELETE FROM /gpios/pbl_bi WHERE sernr = /gpios/if_pbl_controller~gs_data-sernr.
        ELSE.
          CHECK /gpios/if_pbl_controller~gt_delete_bom_headers IS NOT INITIAL.
          DELETE /gpios/pbl_bh FROM TABLE /gpios/if_pbl_controller~gt_delete_bom_headers.
          LOOP AT /gpios/if_pbl_controller~gt_delete_bom_headers ASSIGNING <ls_delete_bom_header>.
            DELETE FROM /gpios/pbl_bi WHERE sernr = <ls_delete_bom_header>-sernr
                                        AND   baugr = <ls_delete_bom_header>-baugr.
          ENDLOOP.
        ENDIF.
        IF iv_clear_attribute = abap_true.
          IF iv_all = abap_true.
            CLEAR: /gpios/if_pbl_controller~gt_local_bom_headers,
                   /gpios/if_pbl_controller~gt_local_bom_items.
          ELSE.
            LOOP AT /gpios/if_pbl_controller~gt_delete_bom_headers INTO ls_bom_header_key.
              DELETE /gpios/if_pbl_controller~gt_local_bom_headers WHERE sernr = ls_bom_header_key-sernr
                                                                     AND   baugr = ls_bom_header_key-baugr.
              DELETE /gpios/if_pbl_controller~gt_local_bom_items WHERE sernr = ls_bom_header_key-sernr
                                                                   AND   baugr = ls_bom_header_key-baugr.
            ENDLOOP.
          ENDIF.
        ENDIF.
    ENDCASE.

    CLEAR: /gpios/if_pbl_controller~gt_delete_bom_headers.

  ENDMETHOD.


  METHOD /gpios/if_pbl_controller~delete_bom_items.
    DATA: lt_copy_remote    LIKE /gpios/if_pbl_controller~gt_remote_bom_items,
          ls_bom_item_key LIKE LINE OF /gpios/if_pbl_controller~gt_delete_bom_items.

    FIELD-SYMBOLS: <ls_bom_items> LIKE LINE OF /gpios/if_pbl_controller~gt_remote_bom_items.

    CASE iv_comm_type.
      WHEN /gpios/if_pbl_controller=>gc_comm_type_remote.

        IF iv_all = abap_true.
          CLEAR: /gpios/if_pbl_controller~gt_delete_bom_items.
          lt_copy_remote  = /gpios/if_pbl_controller~gt_remote_bom_items.
          /gpios/if_pbl_controller~load_bom_items( EXPORTING iv_comm_type = iv_comm_type
                                                               iv_ping      = iv_ping ).
          LOOP AT /gpios/if_pbl_controller~gt_remote_bom_items ASSIGNING <ls_bom_items>.
            MOVE-CORRESPONDING <ls_bom_items> TO ls_bom_item_key.
            APPEND ls_bom_item_key TO /gpios/if_pbl_controller~gt_delete_bom_items.
          ENDLOOP.
        ENDIF.

        CHECK /gpios/if_pbl_controller~gt_delete_bom_items IS NOT INITIAL.

        delete_data( EXPORTING iv_data_type = /gpios/if_pbl_controller=>gc_data_type_bomitm ).

        IF iv_all = abap_true.
          /gpios/if_pbl_controller~gt_remote_bom_items = lt_copy_remote.
        ENDIF.

        IF iv_clear_attribute = abap_true.
          IF iv_all = abap_true.
            CLEAR: /gpios/if_pbl_controller~gt_remote_bom_items.
          ELSE.
            LOOP AT /gpios/if_pbl_controller~gt_delete_bom_items INTO ls_bom_item_key.
              DELETE /gpios/if_pbl_controller~gt_remote_bom_items WHERE sernr = ls_bom_item_key-sernr
                                                                    AND   baugr = ls_bom_item_key-baugr
                                                                    AND   idnrk = ls_bom_item_key-idnrk.
            ENDLOOP.
          ENDIF.
        ENDIF.

      WHEN /gpios/if_pbl_controller=>gc_comm_type_local.
        IF iv_all = abap_true.
          DELETE FROM /gpios/pbl_bi WHERE sernr = /gpios/if_pbl_controller~gs_data-sernr.
        ELSE.
          CHECK /gpios/if_pbl_controller~gt_delete_bom_items IS NOT INITIAL.
          DELETE /gpios/pbl_bi FROM TABLE /gpios/if_pbl_controller~gt_delete_bom_items.
        ENDIF.
        IF iv_clear_attribute = abap_true.
          IF iv_all = abap_true.
            CLEAR: /gpios/if_pbl_controller~gt_local_bom_items.
          ELSE.
            LOOP AT /gpios/if_pbl_controller~gt_delete_bom_items INTO ls_bom_item_key.
              DELETE /gpios/if_pbl_controller~gt_local_bom_items WHERE sernr = ls_bom_item_key-sernr
                                                                   AND   baugr = ls_bom_item_key-baugr
                                                                   AND   idnrk = ls_bom_item_key-idnrk.
            ENDLOOP.
          ENDIF.
        ENDIF.
    ENDCASE.

    CLEAR: /gpios/if_pbl_controller~gt_delete_bom_items.

  ENDMETHOD.


  METHOD /gpios/if_pbl_controller~delete_components.
    DATA: lt_copy_remote LIKE /gpios/if_pbl_controller~gt_remote_components,
          ls_cpn_key     LIKE LINE OF /gpios/if_pbl_controller~gt_delete_components.

    FIELD-SYMBOLS: <ls_components>        LIKE LINE OF /gpios/if_pbl_controller~gt_remote_components,
                   <ls_delete_components> LIKE LINE OF /gpios/if_pbl_controller~gt_delete_components.

    CASE iv_comm_type.
      WHEN /gpios/if_pbl_controller=>gc_comm_type_remote.

        IF iv_all = abap_true.
          CLEAR: /gpios/if_pbl_controller~gt_delete_components.
          lt_copy_remote  = /gpios/if_pbl_controller~gt_remote_components.
          /gpios/if_pbl_controller~load_components( EXPORTING iv_comm_type = iv_comm_type
                                                                iv_ping      = iv_ping ).
          LOOP AT /gpios/if_pbl_controller~gt_remote_components ASSIGNING <ls_components>.
            MOVE-CORRESPONDING <ls_components> TO ls_cpn_key.
            APPEND ls_cpn_key TO /gpios/if_pbl_controller~gt_delete_components.
          ENDLOOP.
        ENDIF.

        CHECK /gpios/if_pbl_controller~gt_delete_components IS NOT INITIAL.

        delete_data( EXPORTING iv_data_type = /gpios/if_pbl_controller=>gc_data_type_components ).

        IF iv_all = abap_true.
          /gpios/if_pbl_controller~gt_remote_components = lt_copy_remote.
        ENDIF.

        IF iv_clear_attribute = abap_true.
          IF iv_all = abap_true.
            CLEAR: /gpios/if_pbl_controller~gt_remote_components.
          ELSE.
            LOOP AT /gpios/if_pbl_controller~gt_delete_components INTO ls_cpn_key.
              DELETE /gpios/if_pbl_controller~gt_remote_components WHERE sernr = ls_cpn_key-sernr
                                                                     AND   idnrk = ls_cpn_key-idnrk.
              DELETE /gpios/if_pbl_controller~gt_remote_bom_items WHERE sernr = ls_cpn_key-sernr
                                                                    AND   idnrk = ls_cpn_key-idnrk.
            ENDLOOP.
          ENDIF.
        ENDIF.

      WHEN /gpios/if_pbl_controller=>gc_comm_type_local.
        IF iv_all = abap_true.
          DELETE FROM /gpios/pbl_cpn WHERE sernr = /gpios/if_pbl_controller~gs_data-sernr.
          DELETE FROM /gpios/pbl_bi WHERE sernr = /gpios/if_pbl_controller~gs_data-sernr.
        ELSE.
          CHECK /gpios/if_pbl_controller~gt_delete_components IS NOT INITIAL.
          DELETE /gpios/pbl_cpn FROM TABLE /gpios/if_pbl_controller~gt_delete_components.
          LOOP AT /gpios/if_pbl_controller~gt_delete_components ASSIGNING <ls_delete_components>.
            DELETE FROM /gpios/pbl_bi WHERE sernr = <ls_delete_components>-sernr
                                        AND   idnrk = <ls_delete_components>-idnrk.
          ENDLOOP.
        ENDIF.
        IF iv_clear_attribute = abap_true.
          IF iv_all = abap_true.
            CLEAR: /gpios/if_pbl_controller~gt_local_components.
          ELSE.
            LOOP AT /gpios/if_pbl_controller~gt_delete_components INTO ls_cpn_key.
              DELETE /gpios/if_pbl_controller~gt_local_components WHERE sernr = ls_cpn_key-sernr
                                                                    AND   idnrk = ls_cpn_key-idnrk.
              DELETE /gpios/if_pbl_controller~gt_local_bom_items WHERE sernr = ls_cpn_key-sernr
                                                                   AND   idnrk = ls_cpn_key-idnrk.
            ENDLOOP.
          ENDIF.
        ENDIF.
    ENDCASE.

    CLEAR: /gpios/if_pbl_controller~gt_delete_components.

  ENDMETHOD.


  METHOD /gpios/if_pbl_controller~delete_device_settings.
    CASE iv_comm_type.
      WHEN /gpios/if_pbl_controller=>gc_comm_type_remote.
* NOT IMPLEMENTED FOR REMOTE!
      WHEN /gpios/if_pbl_controller=>gc_comm_type_local.
        DELETE FROM /gpios/pbl_dev WHERE sernr = /gpios/if_pbl_controller~gs_data-sernr.
        IF iv_clear_attribute = abap_true.
          CLEAR: /gpios/if_pbl_controller~gt_local_devices.
        ENDIF.
    ENDCASE.
  ENDMETHOD.


  METHOD /gpios/if_pbl_controller~delete_users.
    CASE iv_comm_type.
      WHEN /gpios/if_pbl_controller=>gc_comm_type_remote.
* NOT IMPLEMENTED FOR REMTOE!
      WHEN /gpios/if_pbl_controller=>gc_comm_type_local.
        DELETE FROM /gpios/pbl_usr WHERE sernr = /gpios/if_pbl_controller~gs_data-sernr.
        IF iv_clear_attribute = abap_true.
          CLEAR: /gpios/if_pbl_controller~gt_local_users.
        ENDIF.
    ENDCASE.
  ENDMETHOD.


  METHOD /gpios/if_pbl_controller~get_bom.

    FIELD-SYMBOLS: <ls_data> LIKE LINE OF /gpios/if_pbl_controller~gt_local_bom_headers.

    IF iv_load_data = abap_true.
      /gpios/if_pbl_controller~load(
        EXPORTING iv_comm_type = iv_comm_type
                  iv_data_type = /gpios/if_pbl_controller=>gc_data_type_bomhdr
                  iv_ping      = iv_ping ).
    ENDIF.

    CASE iv_comm_type.
      WHEN /gpios/if_pbl_controller=>gc_comm_type_local.
        READ TABLE /gpios/if_pbl_controller~gt_local_bom_headers
             WITH TABLE KEY baugr = iv_baugr ASSIGNING <ls_data>.
      WHEN /gpios/if_pbl_controller=>gc_comm_type_remote.
        READ TABLE /gpios/if_pbl_controller~gt_remote_bom_headers
             WITH TABLE KEY baugr = iv_baugr ASSIGNING <ls_data>.
    ENDCASE.

    IF sy-subrc <> 0.
      /gpios/cx_pbl_core=>bom_not_exists(
        EXPORTING
          io_controller        = me
          iv_baugr             = iv_baugr
          iv_comm_type         = iv_comm_type ).
    ENDIF.

    ro_bom = /gpios/cl_pbl_bom=>get_instance(
      EXPORTING io_controller   = me
                iv_baugr        = iv_baugr
                is_data         = <ls_data> ).

  ENDMETHOD.


  METHOD /gpios/if_pbl_controller~get_connection_info.

    DATA: l_server    TYPE rfcdisplay-rfchost,
          l_servicenr TYPE rfcdisplay-rfcsysid.

    CLEAR: ev_host, ev_port.
    IF /gpios/if_pbl_controller~gs_data-host IS NOT INITIAL AND
       /gpios/if_pbl_controller~gs_data-port IS NOT INITIAL.
      ev_host = /gpios/if_pbl_controller~gs_data-host.
      ev_port = /gpios/if_pbl_controller~gs_data-port.
    ELSEIF  /gpios/if_pbl_controller~gs_data-rfcdest IS NOT INITIAL.
      CLEAR: sy-msgty, sy-msgid.
      CALL FUNCTION 'RFC_READ_HTTP_DESTINATION'
        EXPORTING
          destination             = /gpios/if_pbl_controller~gs_data-rfcdest
        IMPORTING
          servicenr               = l_servicenr
          server                  = l_server
        EXCEPTIONS
          authority_not_available = 1
          destination_not_exist   = 2
          information_failure     = 3
          internal_failure        = 4
          no_http_destination     = 5
          OTHERS                  = 6.
      IF sy-subrc <> 0.
        raise_generic_exception.
      ELSE.
        ev_host = l_server.
        ev_port = l_servicenr.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD /gpios/if_pbl_controller~get_data_ref_for_data_type.

    CLEAR: er_data.

    CASE iv_data_type.
      WHEN /gpios/if_pbl_controller=>gc_data_type_devices.
        CHECK iv_delete = abap_false.
        CASE iv_comm_type.
          WHEN /gpios/if_pbl_controller=>gc_comm_type_local.
            GET REFERENCE OF /gpios/if_pbl_controller~gt_local_devices INTO er_data.
          WHEN /gpios/if_pbl_controller=>gc_comm_type_remote.
            GET REFERENCE OF /gpios/if_pbl_controller~gt_remote_devices INTO er_data.
        ENDCASE.
      WHEN /gpios/if_pbl_controller=>gc_data_type_users.
        CHECK iv_delete = abap_false.
        CASE iv_comm_type.
          WHEN /gpios/if_pbl_controller=>gc_comm_type_local.
            GET REFERENCE OF /gpios/if_pbl_controller~gt_local_users INTO er_data.
          WHEN /gpios/if_pbl_controller=>gc_comm_type_remote.
            GET REFERENCE OF /gpios/if_pbl_controller~gt_remote_users INTO er_data.
        ENDCASE.
      WHEN /gpios/if_pbl_controller=>gc_data_type_components.
        IF iv_delete = abap_true.
          GET REFERENCE OF /gpios/if_pbl_controller~gt_delete_components INTO er_data.
        ELSE.
          CASE iv_comm_type.
            WHEN /gpios/if_pbl_controller=>gc_comm_type_local.
              GET REFERENCE OF /gpios/if_pbl_controller~gt_local_components INTO er_data.
            WHEN /gpios/if_pbl_controller=>gc_comm_type_remote.
              GET REFERENCE OF /gpios/if_pbl_controller~gt_remote_components INTO er_data.
          ENDCASE.
        ENDIF.
      WHEN /gpios/if_pbl_controller=>gc_data_type_bomhdr.
        IF iv_delete = abap_true.
          GET REFERENCE OF /gpios/if_pbl_controller~gt_delete_bom_headers INTO er_data.
        ELSE.
          CASE iv_comm_type.
            WHEN /gpios/if_pbl_controller=>gc_comm_type_local.
              GET REFERENCE OF /gpios/if_pbl_controller~gt_local_bom_headers INTO er_data.
            WHEN /gpios/if_pbl_controller=>gc_comm_type_remote.
              GET REFERENCE OF /gpios/if_pbl_controller~gt_remote_bom_headers INTO er_data.
          ENDCASE.
        ENDIF.
      WHEN /gpios/if_pbl_controller=>gc_data_type_bomitm.
        IF iv_delete = abap_true.
          GET REFERENCE OF /gpios/if_pbl_controller~gt_delete_bom_items INTO er_data.
        ELSE.
          CASE iv_comm_type.
            WHEN /gpios/if_pbl_controller=>gc_comm_type_local.
              GET REFERENCE OF /gpios/if_pbl_controller~gt_local_bom_items INTO er_data.
            WHEN /gpios/if_pbl_controller=>gc_comm_type_remote.
              GET REFERENCE OF /gpios/if_pbl_controller~gt_remote_bom_items INTO er_data.
          ENDCASE.
        ENDIF.
      WHEN /gpios/if_pbl_controller=>gc_data_type_io_units.
        GET REFERENCE OF /gpios/if_pbl_controller~gt_io_unit_data INTO er_data.
      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.


  METHOD /gpios/if_pbl_controller~get_io_units.

    DATA: lo_io_unit TYPE REF TO /gpios/if_pbl_io_unit.

    FIELD-SYMBOLS: <ls_io_unit_data> LIKE LINE OF /gpios/if_pbl_controller~gt_io_unit_data.

    CLEAR: et_io_units.

    IF /gpios/if_pbl_controller~gt_io_units IS NOT INITIAL AND iv_bypass_buffer = abap_false.
      et_io_units = /gpios/if_pbl_controller~gt_io_units.
      RETURN. ">>>>>>>
    ENDIF.

    IF iv_ping = abap_true.
      /gpios/if_pbl_controller~check_controller_accessible( ).
    ENDIF.

    CLEAR: /gpios/if_pbl_controller~gt_io_unit_data.

    receive_data( EXPORTING iv_data_type = /gpios/if_pbl_controller=>gc_data_type_io_units ).

    CLEAR: /gpios/if_pbl_controller~gt_io_units.

    LOOP AT /gpios/if_pbl_controller~gt_io_unit_data ASSIGNING <ls_io_unit_data>.

      lo_io_unit = /gpios/cl_pbl_io_unit=>get_instance(
                io_controller = me
                iv_uid        = <ls_io_unit_data>-io_uid
                is_data       = <ls_io_unit_data> ).
      APPEND lo_io_unit TO /gpios/if_pbl_controller~gt_io_units.
    ENDLOOP.

    et_io_units = /gpios/if_pbl_controller~gt_io_units.

  ENDMETHOD.


  METHOD /gpios/if_pbl_controller~get_ip.

    DATA: l_host TYPE string.

    /gpios/if_pbl_controller~get_connection_info(
      IMPORTING ev_host = l_host ).

    rv_ip = host_to_ip( iv_host = l_host ).

  ENDMETHOD.


  METHOD /gpios/if_pbl_controller~get_running_bom.

    DATA: l_response        TYPE string,
          ls_picking_change TYPE /gpios/pbl_cb_data_pc,
          lo_bom_item       LIKE LINE OF et_remaining_bom_items,
          ls_bom_item_data  TYPE /gpios/pbl_bi,
          ls_bom_data TYPE /gpios/pbl_bh.

    FIELD-SYMBOLS: <ls_remaining> LIKE LINE OF ls_picking_change-remaining.

    CLEAR: eo_bom, ev_started_at, et_remaining_bom_items.

    trigger_action(
      EXPORTING iv_action_type = /gpios/if_pbl_controller~gc_act_type_get_running_bom
      IMPORTING ev_response    = l_response ).

    json2abap( EXPORTING iv_json      = l_response
               IMPORTING ea_data      = ls_picking_change ).

    ev_started_at = ls_picking_change-start.

    CHECK ls_picking_change-baugr IS NOT INITIAL AND ls_picking_change-stopped IS INITIAL.

    IF eo_bom IS REQUESTED OR et_remaining_bom_items IS REQUESTED.
      MOVE-CORRESPONDING me->/gpios/if_pbl_controller~gs_data TO ls_bom_data.
      MOVE-CORRESPONDING ls_picking_change TO ls_bom_data.
      eo_bom = /gpios/cl_pbl_bom=>get_instance(
                io_controller = me
                iv_baugr      = ls_picking_change-baugr
                is_data       = ls_bom_data ).
    ENDIF.

    IF et_remaining_bom_items IS REQUESTED.
      LOOP AT ls_picking_change-remaining ASSIGNING <ls_remaining>.
        MOVE-CORRESPONDING eo_bom->gs_data TO ls_bom_item_data.
        MOVE-CORRESPONDING <ls_remaining> TO ls_bom_item_data.
        CLEAR: ls_bom_item_data-id.
        lo_bom_item = /gpios/cl_pbl_bom_item=>get_instance(
          io_bom      = eo_bom
          iv_idnrk    = <ls_remaining>-idnrk
          is_data     = ls_bom_item_data ).
        CHECK lo_bom_item IS NOT INITIAL.
        APPEND lo_bom_item TO et_remaining_bom_items.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD /gpios/if_pbl_controller~get_ui_url.

    DATA: l_host TYPE rfcdisplay-rfchost,
          l_port TYPE rfcdisplay-rfcsysid,
          l_ip.

    /gpios/if_pbl_controller~get_connection_info(
      IMPORTING ev_host = l_host
                ev_port = l_port ).

    IF l_port IS INITIAL.
      l_port = 80.
    ENDIF.

    IF l_host NP '*.*.*.*'.
      l_host = /gpios/cl_pbl_controller=>host_to_ip(
          iv_host = l_host ).
    ENDIF.

    CONCATENATE 'http://' l_host ':' l_port INTO rv_url.

    CHECK iv_data_type IS NOT INITIAL.

    CASE iv_data_type.
      WHEN /gpios/if_pbl_controller=>gc_data_type_components.
        CONCATENATE rv_url 'components' INTO rv_url SEPARATED BY '/'.
      WHEN /gpios/if_pbl_controller=>gc_data_type_devices.
        CONCATENATE rv_url 'deviceSettings' INTO rv_url SEPARATED BY '/'.
      WHEN /gpios/if_pbl_controller=>gc_data_type_users.
        CONCATENATE rv_url 'userSettings' INTO rv_url SEPARATED BY '/'.
      WHEN /gpios/if_pbl_controller=>gc_data_type_io_units.
        CONCATENATE rv_url 'ioSettings' INTO rv_url SEPARATED BY '/'.
      WHEN /gpios/if_pbl_controller=>gc_data_type_bomhdr OR
           /gpios/if_pbl_controller=>gc_data_type_bomitm.
        CONCATENATE rv_url 'bomHdrs' INTO rv_url SEPARATED BY '/'.
    ENDCASE.

  ENDMETHOD.


  METHOD /gpios/if_pbl_controller~load.

    CASE iv_data_type.
      WHEN /gpios/if_pbl_controller=>gc_data_type_components.
        /gpios/if_pbl_controller~load_components(
          EXPORTING iv_comm_type = iv_comm_type
                    iv_ping      = iv_ping ).
      WHEN /gpios/if_pbl_controller=>gc_data_type_devices.
        /gpios/if_pbl_controller~load_device_settings(
          EXPORTING iv_comm_type = iv_comm_type
                    iv_ping      = iv_ping ).
      WHEN /gpios/if_pbl_controller=>gc_data_type_users.
        /gpios/if_pbl_controller~load_users(
          EXPORTING iv_comm_type = iv_comm_type
                    iv_ping      = iv_ping ).
      WHEN /gpios/if_pbl_controller=>gc_data_type_bomhdr.
        /gpios/if_pbl_controller~load_bom_headers(
          EXPORTING iv_comm_type = iv_comm_type
                    iv_ping      = iv_ping ).
      WHEN /gpios/if_pbl_controller=>gc_data_type_bomitm.
        /gpios/if_pbl_controller~load_bom_items(
          EXPORTING iv_comm_type = iv_comm_type
                    iv_ping      = iv_ping ).
      WHEN /gpios/if_pbl_controller=>gc_data_type_io_units.
        /gpios/if_pbl_controller~get_io_units(
          EXPORTING iv_bypass_buffer = abap_true
                    iv_ping          = iv_ping ).
    ENDCASE.

  ENDMETHOD.


  METHOD /gpios/if_pbl_controller~load_bom_headers.

    CLEAR: et_bom_headers.
    CASE iv_comm_type.
      WHEN /gpios/if_pbl_controller=>gc_comm_type_remote.
        IF iv_ping = abap_true.
          /gpios/if_pbl_controller~check_controller_accessible( ).
        ENDIF.
        receive_data( EXPORTING iv_data_type = /gpios/if_pbl_controller=>gc_data_type_bomhdr ).
        CHECK et_bom_headers IS REQUESTED.
        et_bom_headers = /gpios/if_pbl_controller~gt_remote_bom_headers.
      WHEN /gpios/if_pbl_controller=>gc_comm_type_local.
        SELECT * FROM /gpios/pbl_bh
                 INTO TABLE /gpios/if_pbl_controller~gt_local_bom_headers
                 WHERE sernr = /gpios/if_pbl_controller~gs_data-sernr.
        CHECK et_bom_headers IS REQUESTED.
        et_bom_headers = /gpios/if_pbl_controller~gt_local_bom_headers.
    ENDCASE.

  ENDMETHOD.


  METHOD /gpios/if_pbl_controller~load_bom_items.

    CLEAR: et_bom_items.
    CASE iv_comm_type.
      WHEN /gpios/if_pbl_controller=>gc_comm_type_remote.
        IF iv_ping = abap_true.
          /gpios/if_pbl_controller~check_controller_accessible( ).
        ENDIF.
        receive_data( EXPORTING iv_data_type = /gpios/if_pbl_controller=>gc_data_type_bomitm ).
        CHECK et_bom_items IS REQUESTED.
        et_bom_items = /gpios/if_pbl_controller~gt_remote_bom_items.
      WHEN /gpios/if_pbl_controller=>gc_comm_type_local.
        SELECT * FROM /gpios/pbl_bi
                 INTO TABLE /gpios/if_pbl_controller~gt_local_bom_items
                 WHERE sernr = /gpios/if_pbl_controller~gs_data-sernr.
        CHECK et_bom_items IS REQUESTED.
        et_bom_items = /gpios/if_pbl_controller~gt_local_bom_items.
    ENDCASE.

  ENDMETHOD.


  METHOD /gpios/if_pbl_controller~load_components.

    CLEAR: et_components.
    CASE iv_comm_type.
      WHEN /gpios/if_pbl_controller=>gc_comm_type_remote.
        IF iv_ping = abap_true.
          /gpios/if_pbl_controller~check_controller_accessible( ).
        ENDIF.
        receive_data( EXPORTING iv_data_type = /gpios/if_pbl_controller=>gc_data_type_components ).
        CHECK et_components IS REQUESTED.
        et_components = /gpios/if_pbl_controller~gt_remote_components.
      WHEN /gpios/if_pbl_controller=>gc_comm_type_local.
        SELECT * FROM /gpios/pbl_cpn
                 INTO TABLE /gpios/if_pbl_controller~gt_local_components
                 WHERE sernr = /gpios/if_pbl_controller~gs_data-sernr.
        CHECK et_components IS REQUESTED.
        et_components = /gpios/if_pbl_controller~gt_local_components.
    ENDCASE.

  ENDMETHOD.


  METHOD /gpios/if_pbl_controller~load_device_settings.

    CLEAR: et_devices.
    CASE iv_comm_type.
      WHEN /gpios/if_pbl_controller=>gc_comm_type_remote.
        IF iv_ping = abap_true.
          /gpios/if_pbl_controller~check_controller_accessible( ).
        ENDIF.
        receive_data( EXPORTING iv_data_type = /gpios/if_pbl_controller=>gc_data_type_devices ).
        CHECK et_devices IS REQUESTED.
        et_devices = /gpios/if_pbl_controller~gt_remote_devices.
      WHEN /gpios/if_pbl_controller=>gc_comm_type_local.
        SELECT * FROM /gpios/pbl_dev
                 INTO TABLE /gpios/if_pbl_controller~gt_local_devices
                 WHERE sernr = /gpios/if_pbl_controller~gs_data-sernr.
        CHECK et_devices IS REQUESTED.
        et_devices = /gpios/if_pbl_controller~gt_local_devices.
    ENDCASE.

  ENDMETHOD.


  METHOD /gpios/if_pbl_controller~load_users.

    CLEAR: et_users.
    CASE iv_comm_type.
      WHEN /gpios/if_pbl_controller=>gc_comm_type_remote.
        IF iv_ping = abap_true.
          /gpios/if_pbl_controller~check_controller_accessible( ).
        ENDIF.
        receive_data( EXPORTING iv_data_type = /gpios/if_pbl_controller=>gc_data_type_users ).
        CHECK et_users IS REQUESTED.
        et_users = /gpios/if_pbl_controller~gt_remote_users.
      WHEN /gpios/if_pbl_controller=>gc_comm_type_local.
        SELECT * FROM /gpios/pbl_usr
                 INTO TABLE /gpios/if_pbl_controller~gt_local_users
                 WHERE sernr = /gpios/if_pbl_controller~gs_data-sernr.
        CHECK et_users IS REQUESTED.
        et_users = /gpios/if_pbl_controller~gt_local_users.
    ENDCASE.

  ENDMETHOD.


  METHOD /gpios/if_pbl_controller~ping.

    DATA: l_host TYPE rfchost_ext,
          l_text TYPE string,
          l_code TYPE i.

    /gpios/if_pbl_controller~get_connection_info( IMPORTING ev_host = l_host ).

    trigger_action(
      EXPORTING iv_action_type = /gpios/if_pbl_controller=>gc_act_type_ping
      IMPORTING ev_code        = l_code ).

    IF l_code = /gpios/if_pbl_callback=>gc_http_code_ok.
      rv_subrc = 0.
      MESSAGE s009 WITH l_host.
    ELSE.
      rv_subrc = 4.
    ENDIF.

    RETURN. " >>>>>>

    DATA:
       h7    TYPE i,
       h8(8) TYPE c,
       h9(8) TYPE c,
       BEGIN OF ls_ping,
         A(30) TYPE c,
         B(50) TYPE c,
         C(30) TYPE c,
       END OF ls_ping,
       lt_tabl TYPE STANDARD TABLE OF text132.

    rv_subrc = 4.
************************************************************************
*** GET_OPSYS_STRING                                                 ***
*** ---------------------------------------------------------------- ***
*** Assemble ping string for nr_bl blocks with bl_gr bytes           ***
************************************************************************
    h9 = 4.
    CONDENSE h9.
    h8 = 64.
    CONDENSE h8.

    CASE sy-opsys.
      WHEN 'OS400' OR 'OS/400'.          "****** AS/400 ******
*     ping 155.155.194.23 PKTLEN(500) NBRPKT(10)
        ls_ping-a = 'ping '.                                "#EC NOTEXT
        ls_ping-c = 'PKTLEN('.                              "#EC NOTEXT
        h7 = strlen( ls_ping-c ).
        ls_ping-c+h7 = h8.
        h7 = strlen( ls_ping-c ).
        ls_ping-c+h7 = ')'.
        "condense ls_ping-c no-gaps.
        h7 = strlen( ls_ping-c ).
        h7 = h7 + 1.
        ls_ping-c+h7 = 'NBRPKT('.                           "#EC NOTEXT
        h7 = strlen( ls_ping-c ).
        ls_ping-c+h7 = h9.
        h7 = strlen( ls_ping-c ).
        ls_ping-c+h7 = ')'.

      WHEN 'HP-UX'.                           "****** HP     *******
*     /etc/ping 155.155.194.23 500 10 .             max 65500
        ls_ping-a = '/etc/ping '.                           "#EC NOTEXT
        ls_ping-c = h8.
        h7 = strlen( ls_ping-c ).  h7 = h7 + 1.
        ls_ping-c+h7 = h9.

      WHEN 'OSF1'.                            "****** OSF1   *******
*     /sbin/ping -c 10 -s 500 155.155.194.23.
        ls_ping-a = '/sbin/ping -c '.                       "#EC NOTEXT
        h7 = strlen( ls_ping-a ). h7 = h7 + 1.
        ls_ping-a+h7 = h9.
        h7 = strlen( ls_ping-a ).
        ls_ping-a+h7 = ' -s' .
        h7 = strlen( ls_ping-a ). h7 = h7 + 1.
        ls_ping-a+h7 = h8.

      WHEN 'SunOS'.                           "****** Sun    *******
*     /usr/sbin/ping -s 155.155.194.23 500 10
        ls_ping-a = '/usr/sbin/ping -s'.                    "#EC NOTEXT
        ls_ping-c = ' '.
        ls_ping-c+1 = h8.
        h7 = strlen( ls_ping-c ). h7 = h7 + 1.
        ls_ping-c+h7 = h9.

      WHEN 'VMS'.                             "****** VMS    *******
*     mcr ucx$ping 155.155.194.23 500 10
        ls_ping-a = 'mcr ucx$ping '.                        "#EC NOTEXT
        ls_ping-c = ' '.
        ls_ping-c+1 = h8.
        h7 = strlen( ls_ping-c ). h7 = h7 + 1.
        ls_ping-c+h7 = h9.

      WHEN 'AIX'.                             "****** IBM    *******
*     /etc/ping 155.155.194.23 500 10
        ls_ping-a = '/etc/ping '.                           "#EC NOTEXT
        ls_ping-c = ' '.
        ls_ping-c+1 = h8.
        h7 = strlen( ls_ping-c ). h7 = h7 + 1.
        ls_ping-c+h7 = h9.

      WHEN 'MPE/iX'.                          "****** MPE/iX *******
*     /etc/ping 155.155.194.23 500 10
        ls_ping-a = '/etc/ping '.                           "#EC NOTEXT
        ls_ping-c = ' '.
        ls_ping-c+1 = h8.
        h7 = strlen( ls_ping-c ). h7 = h7 + 1.
        ls_ping-c+h7 = h9.

      WHEN 'Windows NT'.                      "***** Windows NT *****
*     ping -a 155.155.194.23 -n 10 -l 500            max 65500
        ls_ping-a = 'ping -a '.                             "#EC NOTEXT
        ls_ping-c = ' -n '.
        h7 = strlen( ls_ping-c ). h7 = h7 + 1.
        ls_ping-c+h7 = h9.
        h7 = strlen( ls_ping-c ).
        ls_ping-c+h7 = ' -l '.  h7 = h7 + 4.
        ls_ping-c+h7 = h8.

      WHEN 'SINIX' OR 'SINIX-P' OR 'SINIX-N'. "****** SINIX    *******
*     ping -s 155.155.194.23 500 10        " 5.41 and 5.42 sec
        ls_ping-a = 'ping -s '.                     "#EC NOTEXT " RM600
        ls_ping-c = ' '.                     " SINIX-N  RM4000
        ls_ping-c+1 = h8.
        h7 = strlen( ls_ping-c ). h7 = h7 + 1.
        ls_ping-c+h7 = h9.

      WHEN 'Relia' OR 'ReliantUNI'.            "****** Relia *******
*     ping -s 155.155.194.23 500 10        " like SINIX  max 4096
        ls_ping-a = 'ping -s '.                           "#EC NOTEXT "
        ls_ping-c = ' '.                     "
        ls_ping-c+1 = h8.
        h7 = strlen( ls_ping-c ). h7 = h7 + 1.
        ls_ping-c+h7 = h9.

      WHEN 'SINIX-Y' OR 'SMO_DC.OSx'.       "***** SINIX-Y or old SNI ****
*     ping -s 155.155.194.23 500 10
        ls_ping-a = 'ping -s '. "#EC NOTEXT " experimental Multiprocess
        ls_ping-c = ' '.
        ls_ping-c+1 = h8.
        h7 = strlen( ls_ping-c ).   h7 = h7 + 1.
        ls_ping-c+h7 = h9.

      WHEN 'Linux'.                           "****** Linux *******
*     ping 155.155.194.23 -c10 -s500 .
        ls_ping-a = 'ping '.                                "#EC NOTEXT
        ls_ping-c = ' -c '.
        h7 = strlen( ls_ping-c ). h7 = h7 + 1.
        ls_ping-c+h7 = h9.
        h7 = strlen( ls_ping-c ).
        ls_ping-c+h7 = ' -s '.  h7 = h7 + 4.
        ls_ping-c+h7 = h8.

      WHEN 'OS/390'.                           "****** OS/390 *******
*     ping -l500 -c10 155.155.194.23       " only IP for pres
        ls_ping-a = 'ping -l'.            "#EC NOTEXT  " app IP or name
        h7 = strlen( ls_ping-a ). h7 = h7 + 1.
        ls_ping-a+h7 = h8.
        h7 = strlen( ls_ping-a ).
        ls_ping-a+h7 = ' -c' .
        h7 = strlen( ls_ping-a ). h7 = h7 + 1.
        ls_ping-a+h7 = h9.

      WHEN OTHERS.                         "not yet supported
        MESSAGE s344(s1).
        RETURN.
    ENDCASE.


* OS/400 requires single quotes around the IP address
    IF sy-opsys = 'OS400' OR sy-opsys = 'OS/400'.
      CONCATENATE '''' l_host '''' INTO ls_ping-b.
    ELSE.
      ls_ping-b = l_host.
    ENDIF.

    l_text = 'Ping an &1...'(001).
    REPLACE ALL OCCURRENCES OF '&1' IN   l_text WITH ls_ping-b.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = 30
        text       = l_text.

    CALL 'SYSTEM' ID 'COMMAND' FIELD ls_ping
                  ID 'TAB'     FIELD lt_tabl.             "#EC CI_CCALL
    FIND FIRST OCCURRENCE OF REGEX ' 4 (packets )?received ' IN TABLE lt_tabl.
    rv_subrc = sy-subrc.
    IF rv_subrc = 0.
      MESSAGE s009 WITH ls_ping-b.
    ENDIF.

  ENDMETHOD.


  METHOD /gpios/if_pbl_controller~save.

    CASE iv_data_type.
      WHEN /gpios/if_pbl_controller=>gc_data_type_components.
        /gpios/if_pbl_controller~save_components(
          EXPORTING iv_delete_before = iv_delete_before
                    iv_comm_type     = iv_comm_type
                    iv_ping          = iv_ping ).
      WHEN /gpios/if_pbl_controller=>gc_data_type_devices.
        /gpios/if_pbl_controller~save_device_settings(
          EXPORTING iv_delete_before = iv_delete_before
                    iv_comm_type     = iv_comm_type
                    iv_ping          = iv_ping ).
      WHEN /gpios/if_pbl_controller=>gc_data_type_bomhdr.
        /gpios/if_pbl_controller~save_bom_headers(
          EXPORTING iv_delete_before = iv_delete_before
                    iv_comm_type     = iv_comm_type
                    iv_ping          = iv_ping ).
      WHEN /gpios/if_pbl_controller=>gc_data_type_bomitm.
        /gpios/if_pbl_controller~save_bom_items(
          EXPORTING iv_delete_before = iv_delete_before
                    iv_comm_type     = iv_comm_type
                    iv_ping          = iv_ping ).
      WHEN /gpios/if_pbl_controller=>gc_data_type_users.
        /gpios/if_pbl_controller~save_users(
          EXPORTING iv_delete_before = iv_delete_before
                    iv_comm_type     = iv_comm_type
                    iv_ping          = iv_ping ).
    ENDCASE.

  ENDMETHOD.


  METHOD /gpios/if_pbl_controller~save_bom_headers.

    IF iv_delete_before = abap_true.
      /gpios/if_pbl_controller~delete_bom_headers( iv_comm_type       = iv_comm_type
                                                   iv_clear_attribute = abap_false
                                                   iv_all             = abap_true
                                                   iv_ping            = iv_ping ).
    ENDIF.

    CASE iv_comm_type.
      WHEN /gpios/if_pbl_controller=>gc_comm_type_remote.
        CHECK /gpios/if_pbl_controller~gt_remote_bom_headers IS NOT INITIAL.
        IF iv_ping = abap_true.
          /gpios/if_pbl_controller~check_controller_accessible( ).
        ENDIF.
        transfer_data( EXPORTING iv_data_type = /gpios/if_pbl_controller=>gc_data_type_bomhdr ).
      WHEN /gpios/if_pbl_controller=>gc_comm_type_local.
        CHECK /gpios/if_pbl_controller~gt_local_bom_headers IS NOT INITIAL.
        MODIFY /gpios/pbl_bh FROM TABLE /gpios/if_pbl_controller~gt_local_bom_headers.
    ENDCASE.

  ENDMETHOD.


  METHOD /gpios/if_pbl_controller~save_bom_items.

    IF iv_delete_before = abap_true.
      /gpios/if_pbl_controller~delete_bom_items( iv_comm_type       = iv_comm_type
                                                 iv_clear_attribute = abap_false
                                                 iv_all             = abap_true
                                                 iv_ping            = iv_ping ).
    ENDIF.

    CASE iv_comm_type.
      WHEN /gpios/if_pbl_controller=>gc_comm_type_remote.
        CHECK /gpios/if_pbl_controller~gt_remote_bom_items IS NOT INITIAL.
        IF iv_ping = abap_true.
          /gpios/if_pbl_controller~check_controller_accessible( ).
        ENDIF.
        transfer_data( EXPORTING iv_data_type = /gpios/if_pbl_controller=>gc_data_type_bomitm ).
      WHEN /gpios/if_pbl_controller=>gc_comm_type_local.
        CHECK /gpios/if_pbl_controller~gt_local_bom_items IS NOT INITIAL.
        MODIFY /gpios/pbl_bi FROM TABLE /gpios/if_pbl_controller~gt_local_bom_items.
    ENDCASE.

  ENDMETHOD.


  METHOD /gpios/if_pbl_controller~save_components.

    IF iv_delete_before = abap_true.
      /gpios/if_pbl_controller~delete_components( iv_comm_type       = iv_comm_type
                                                  iv_clear_attribute = abap_false
                                                  iv_all             = abap_true
                                                  iv_ping            = iv_ping ).
    ENDIF.

    CASE iv_comm_type.
      WHEN /gpios/if_pbl_controller=>gc_comm_type_remote.
        CHECK /gpios/if_pbl_controller~gt_remote_components IS NOT INITIAL.
        IF iv_ping = abap_true.
          /gpios/if_pbl_controller~check_controller_accessible( ).
        ENDIF.
        transfer_data( EXPORTING iv_data_type = /gpios/if_pbl_controller=>gc_data_type_components ).
      WHEN /gpios/if_pbl_controller=>gc_comm_type_local.
        CHECK /gpios/if_pbl_controller~gt_local_components IS NOT INITIAL.
        MODIFY /gpios/pbl_cpn FROM TABLE /gpios/if_pbl_controller~gt_local_components.
    ENDCASE.

  ENDMETHOD.


  METHOD /gpios/if_pbl_controller~save_device_settings.

    IF iv_delete_before = abap_true.
      /gpios/if_pbl_controller~delete_device_settings( iv_comm_type       = iv_comm_type
                                                       iv_clear_attribute = abap_false
                                                       iv_all             = abap_true
                                                       iv_ping            = iv_ping ).
    ENDIF.

    CASE iv_comm_type.
      WHEN /gpios/if_pbl_controller=>gc_comm_type_remote.
        CHECK /gpios/if_pbl_controller~gt_remote_devices IS NOT INITIAL.
        IF iv_ping = abap_true.
          /gpios/if_pbl_controller~check_controller_accessible( ).
        ENDIF.
        transfer_data( EXPORTING iv_data_type = /gpios/if_pbl_controller=>gc_data_type_devices ).
      WHEN /gpios/if_pbl_controller=>gc_comm_type_local.
        CHECK /gpios/if_pbl_controller~gt_local_devices IS NOT INITIAL.
        MODIFY /gpios/pbl_dev FROM TABLE /gpios/if_pbl_controller~gt_local_devices.
    ENDCASE.

  ENDMETHOD.


  METHOD /gpios/if_pbl_controller~save_users.

    IF iv_delete_before = abap_true.
      /gpios/if_pbl_controller~delete_users( iv_comm_type       = iv_comm_type
                                             iv_clear_attribute = abap_false
                                             iv_all             = abap_true
                                             iv_ping            = iv_ping ).
    ENDIF.

    CASE iv_comm_type.
      WHEN /gpios/if_pbl_controller=>gc_comm_type_remote.
        CHECK /gpios/if_pbl_controller~gt_remote_users IS NOT INITIAL.
        IF iv_ping = abap_true.
          /gpios/if_pbl_controller~check_controller_accessible( ).
        ENDIF.
        transfer_data( EXPORTING iv_data_type = /gpios/if_pbl_controller=>gc_data_type_users ).
      WHEN /gpios/if_pbl_controller=>gc_comm_type_local.
        CHECK /gpios/if_pbl_controller~gt_local_users IS NOT INITIAL.
        MODIFY /gpios/pbl_usr FROM TABLE /gpios/if_pbl_controller~gt_local_users.
    ENDCASE.

  ENDMETHOD.


  METHOD /gpios/if_pbl_controller~set_deletion_row.

    DATA: lr_delete     TYPE REF TO data,
          lr_delete_wa  TYPE REF TO data.

    FIELD-SYMBOLS: <lt_delete>       TYPE STANDARD TABLE,
                   <ls_delete>       TYPE any.


    /gpios/if_pbl_controller~get_data_ref_for_data_type(
      EXPORTING iv_data_type = iv_data_type
                iv_comm_type = /gpios/if_pbl_controller=>gc_comm_type_remote
                iv_delete    = abap_true
      IMPORTING er_data      = lr_delete ).

    CHECK lr_delete IS BOUND.

    ASSIGN lr_delete->* TO <lt_delete>.

    CREATE DATA lr_delete_wa LIKE LINE OF <lt_delete>.

    ASSIGN lr_delete_wa->* TO <ls_delete>.

    MOVE-CORRESPONDING ia_row TO <ls_delete>.

    APPEND <ls_delete> TO <lt_delete>.

  ENDMETHOD.


  METHOD abap2json.

    DATA: l_pretty_mode TYPE /gpios/cl_pbl_json=>pretty_name_mode.

    l_pretty_mode = /gpios/cl_pbl_json=>pretty_mode-none.

    CASE iv_action_type.
      WHEN /gpios/if_pbl_controller=>gc_act_type_set_color OR
           /gpios/if_pbl_controller=>gc_act_type_toggle_all_colors OR
           /gpios/if_pbl_controller=>gc_act_type_toggle_color OR
           /gpios/if_pbl_controller=>gc_act_type_toggle_bom_itm_io OR
           /gpios/if_pbl_controller=>gc_act_type_stop_bom.
        l_pretty_mode = /gpios/cl_pbl_json=>pretty_mode-low_case.
      WHEN            /gpios/if_pbl_controller=>gc_act_type_start_bom.
        l_pretty_mode = /gpios/cl_pbl_json=>pretty_mode-camel_case.
      WHEN OTHERS.
    ENDCASE.

    ev_json = /gpios/cl_pbl_json=>serialize( pretty_name = l_pretty_mode
                                             data        = ia_data ).
    CASE iv_action_type.
      WHEN /gpios/if_pbl_controller=>gc_act_type_set_color.
        REPLACE FIRST OCCURRENCE OF `"r":` IN  ev_json WITH `"R":`.
        REPLACE FIRST OCCURRENCE OF `"g":` IN  ev_json WITH `"G":`.
        REPLACE FIRST OCCURRENCE OF `"b":` IN  ev_json WITH `"B":`.
    ENDCASE.

  ENDMETHOD.


  METHOD class_constructor.

    DATA: ls_name_mapping LIKE LINE OF /gpios/cl_pbl_json=>name_mapping.

    CLEAR: /gpios/cl_pbl_json=>name_mapping.

    ls_name_mapping-name_ddic = 'OPMODE'.
    ls_name_mapping-name_json = 'MODE'.
    APPEND ls_name_mapping TO /gpios/cl_pbl_json=>name_mapping.

    ls_name_mapping-name_ddic = 'IO_UID'.
    ls_name_mapping-name_json = 'uid'.
    APPEND ls_name_mapping TO /gpios/cl_pbl_json=>name_mapping.

    ls_name_mapping-java_timestamp = abap_true.
    ls_name_mapping-name_json = ls_name_mapping-name_ddic = 'START'.
    APPEND ls_name_mapping TO /gpios/cl_pbl_json=>name_mapping.

    ls_name_mapping-name_json = ls_name_mapping-name_json = 'STOP'.
    APPEND ls_name_mapping TO /gpios/cl_pbl_json=>name_mapping.

  ENDMETHOD.


  METHOD constructor.

    DATA: ls_r_flat_conversion LIKE LINE OF gt_r_flat_conversion VALUE 'IEQ'.

    IF iv_create = abap_false.
      SELECT SINGLE *
             FROM  /gpios/pbl_ctl
             INTO  /gpios/if_pbl_controller~gs_data
             WHERE sernr = iv_sernr
             AND   cccategory = (
                      SELECT cccategory FROM t000 WHERE mandt = sy-mandt "#EC CI_BUFFSUBQ
                                 ).
      IF sy-subrc <> 0.
        /gpios/cx_pbl_core=>controller_not_exists( iv_sernr = iv_sernr ).
      ENDIF.

      SELECT SINGLE descript
             FROM /gpios/pbl_ctt
             INTO /gpios/if_pbl_controller~gv_description
             WHERE sernr = iv_sernr
*             AND   cccategory = (
*                      SELECT cccategory FROM t000 WHERE mandt = sy-mandt
*                                 )
             AND   spras = sy-langu.
      IF sy-subrc <> 0.
        SELECT SINGLE descript
               FROM /gpios/pbl_ctt
               INTO /gpios/if_pbl_controller~gv_description
               WHERE sernr = iv_sernr
*               AND   cccategory = (
*                        SELECT cccategory FROM t000 WHERE mandt = sy-mandt
*                                   ).
          .
      ENDIF.

    ELSE.
      /gpios/if_pbl_controller~gv_new = abap_true.
      /gpios/if_pbl_controller~gs_data-sernr = iv_sernr.
    ENDIF.

    DEFINE add_flat_conversion.
      ls_r_flat_conversion-low = &1.
      append ls_r_flat_conversion to gt_r_flat_conversion.
    END-OF-DEFINITION.

    add_flat_conversion: /gpios/if_pbl_controller=>gc_data_type_users,
                         /gpios/if_pbl_controller=>gc_data_type_devices.

  ENDMETHOD.


  METHOD delete_data.

    DATA: lr_data    TYPE REF TO data,
          lo_client  TYPE REF TO if_http_client,
          l_json     TYPE string,
          l_msg      TYPE string,
          l_response TYPE string,
          l_code     TYPE i,
          l_reason   TYPE string.

    FIELD-SYMBOLS: <ls_pbl_com> LIKE LINE OF /gpios/cl_pbl_settings_core=>instance->/gpios/pbl_com,
                   <la_data>    TYPE any.

    IF ia_data IS NOT SUPPLIED.
      /gpios/if_pbl_controller~get_data_ref_for_data_type(
                                  EXPORTING iv_data_type = iv_data_type
                                            iv_comm_type = /gpios/if_pbl_controller=>gc_comm_type_remote
                                            iv_delete    = abap_true
                                  IMPORTING er_data      = lr_data ).
    ELSE.
      ASSIGN ia_data TO <la_data>.
    ENDIF.

    IF lr_data IS BOUND.
      ASSIGN lr_data->* TO <la_data>.
    ENDIF.

    READ TABLE /gpios/cl_pbl_settings_core=>instance->/gpios/pbl_com
         WITH TABLE KEY data_type   = iv_data_type
                        comm_action = /gpios/if_pbl_controller=>gc_comm_action_delete
         ASSIGNING <ls_pbl_com>.

    lo_client = get_http_client( iv_path = <ls_pbl_com>-pfadpre ).
    CHECK NOT lo_client IS INITIAL.
    lo_client->request->set_method( 'DELETE' ).
    lo_client->request->if_http_entity~set_content_type( `application/json;charset=UTF-8` ). "#EC NOTEXT

    IF <la_data> IS ASSIGNED.
      abap2json( EXPORTING iv_data_type = iv_data_type
                           ia_data      = <la_data>
                 IMPORTING ev_json      = l_json ).

    ENDIF.

    lo_client->request->set_cdata( l_json ).


    lo_client->send( EXCEPTIONS http_communication_failure = 1
                                http_invalid_state         = 2
                                http_processing_failed     = 3
                                http_invalid_timeout       = 4
                                OTHERS                     = 5 ).
    IF sy-subrc <> 0.
      lo_client->get_last_error( IMPORTING message = l_msg ).
      cl_message_helper=>set_msg_vars_for_clike( text = l_msg ).
      raise_generic_exception.
    ENDIF.

    lo_client->receive( EXCEPTIONS http_communication_failure = 1
                                   http_invalid_state         = 2
                                   http_processing_failed     = 3
                                   OTHERS                     = 4 ).
    IF sy-subrc <> 0.
      lo_client->get_last_error( IMPORTING message = l_msg ).
      cl_message_helper=>set_msg_vars_for_clike( text = l_msg ).
      raise_generic_exception.
    ENDIF.

    l_response = lo_client->response->get_cdata( ).

    lo_client->response->get_status( IMPORTING code   = l_code
                                               reason = l_reason ).
    IF l_code <> /gpios/if_pbl_controller=>gc_http_code_ok.
      /gpios/cx_pbl_core=>data_transfer_failed( io_controller = me
                                                  iv_code       = l_code
                                                  iv_reason     = l_reason ).
    ENDIF.

    lo_client->close( ).

  ENDMETHOD.


  METHOD get_http_client.
    DATA: l_host     TYPE string,
          l_port     TYPE string,
          l_username TYPE string,
          l_password TYPE string,
          l_url      TYPE string.

*l_host = /gpios/if_pbl_controller~get_ip( ).

    IF /gpios/if_pbl_controller~gs_data-rfcdest IS INITIAL.

      /gpios/if_pbl_controller~get_connection_info(
              IMPORTING ev_host = l_host
                        ev_port = l_port ).

      CHECK NOT l_host IS INITIAL.

      CLEAR :sy-msgty, sy-msgid.
      cl_http_client=>create(
        EXPORTING
          host               = l_host
          service            = l_port
        IMPORTING
          client             = ro_client
        EXCEPTIONS
          argument_not_found = 1
          plugin_not_active  = 2
          internal_error     = 3
          OTHERS             = 4 ).
      IF sy-subrc <> 0 OR ro_client IS INITIAL.
        raise_generic_exception.
      ENDIF.
    ELSE.
      CLEAR :sy-msgty, sy-msgid.
      cl_http_client=>create_by_destination(
        EXPORTING
          destination              = /gpios/if_pbl_controller~gs_data-rfcdest
        IMPORTING
          client                   = ro_client
        EXCEPTIONS
          argument_not_found       = 1
          destination_not_found    = 2
          destination_no_authority = 3
          plugin_not_active        = 4
          internal_error           = 5
          OTHERS                   = 6 ).
      IF sy-subrc <> 0.
        raise_generic_exception.
      ENDIF.
    ENDIF.

    IF iv_path IS SUPPLIED.
      l_url = iv_path.
      ro_client->request->set_header_field(
           name  = '~request_uri'
           value = l_url ).
    ENDIF.

    IF iv_authenticate = abap_true AND  NOT /gpios/if_pbl_controller~gs_data-apius IS INITIAL.
      l_username = /gpios/if_pbl_controller~gs_data-apius.
      l_password = /gpios/if_pbl_controller~gs_data-apipw.
      ro_client->authenticate(
        EXPORTING username = l_username
                  password = l_password ).
    ENDIF.

  ENDMETHOD.


  METHOD get_instance.
    DATA: ls_instance LIKE LINE OF gt_instances,
          lo_object   TYPE REF TO object.

    ls_instance-key-sernr = iv_sernr.

    READ TABLE gt_instances
         WITH TABLE KEY key = ls_instance-key
         INTO ls_instance TRANSPORTING instance.
    IF sy-subrc <> 0.
      IF /gpios/cl_pbl_settings_core=>instance->/gpios/pbl_set-clsname_controller IS INITIAL.
        CREATE OBJECT ls_instance-instance TYPE
          /gpios/cl_pbl_controller
          EXPORTING
            iv_sernr = iv_sernr.
      ELSE.
        CREATE OBJECT ls_instance-instance TYPE
              (/gpios/cl_pbl_settings_core=>instance->/gpios/pbl_set-clsname_controller)
              EXPORTING iv_sernr = iv_sernr.
      ENDIF.
      INSERT ls_instance INTO TABLE gt_instances.

      lo_object = ls_instance-instance.

      TRY.
          CALL METHOD lo_object->('INIT').
        CATCH cx_sy_dyn_call_error.
      ENDTRY.
    ENDIF.

    ASSERT ls_instance-instance IS BOUND.

    ro_instance = ls_instance-instance.

  ENDMETHOD.


  METHOD get_instance_for_ip.

    DATA: lt_ctl TYPE STANDARD TABLE OF /gpios/pbl_ctl,
          l_server TYPE rfcdisplay-rfchost.

    FIELD-SYMBOLS: <ls_ctl> LIKE LINE OF lt_ctl.

    CHECK iv_ip IS NOT INITIAL.

    SELECT * FROM /gpios/pbl_ctl                        "#EC CI_NOFIELD
             INTO TABLE lt_ctl
             WHERE cccategory = (
                      SELECT cccategory FROM t000 WHERE mandt = sy-mandt "#EC CI_BUFFSUBQ
                                 ).

    LOOP AT lt_ctl ASSIGNING <ls_ctl>.
      IF <ls_ctl>-host IS NOT INITIAL.
        IF <ls_ctl>-host = iv_ip.
          ro_instance = /gpios/cl_pbl_controller=>get_instance( iv_sernr = <ls_ctl>-sernr ).
          RETURN. " >>>>>>>>>
        ENDIF.
        IF host_to_ip( iv_host = <ls_ctl>-host ) = iv_ip.
          ro_instance = /gpios/cl_pbl_controller=>get_instance( iv_sernr = <ls_ctl>-sernr ).
          RETURN. " >>>>>>>>>
        ENDIF.
      ENDIF.

      IF <ls_ctl>-rfcdest IS NOT INITIAL.
        CLEAR: sy-msgty, sy-msgid.
        CALL FUNCTION 'RFC_READ_HTTP_DESTINATION'
          EXPORTING
            destination             = <ls_ctl>-rfcdest
          IMPORTING
            server                  = l_server
          EXCEPTIONS
            authority_not_available = 1
            destination_not_exist   = 2
            information_failure     = 3
            internal_failure        = 4
            no_http_destination     = 5
            OTHERS                  = 6.
        IF sy-subrc = 0.
          IF l_server = iv_ip.
            ro_instance = /gpios/cl_pbl_controller=>get_instance( iv_sernr = <ls_ctl>-sernr ).
            RETURN. " >>>>>>>>>
          ENDIF.
          IF host_to_ip( iv_host = l_server ) = iv_ip.
            ro_instance = /gpios/cl_pbl_controller=>get_instance( iv_sernr = <ls_ctl>-sernr ).
            RETURN. " >>>>>>>>>
          ENDIF.
        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD host_to_ip.
    DATA: l_rfchost TYPE rfcdisplay-rfchost.

    l_rfchost = iv_host.

    CALL FUNCTION 'RFC_HOST_TO_IP'
      EXPORTING
        rfchost                     = l_rfchost
      IMPORTING
        rfcip                       = rv_ip
      EXCEPTIONS
        host_to_ip_conversion_error = 1
        OTHERS                      = 2.

  ENDMETHOD.


  METHOD init.
  ENDMETHOD.


  METHOD json2abap.

    DATA: lo_typedescr TYPE REF TO cl_abap_typedescr,
          l_do         TYPE i.

    FIELD-SYMBOLS: <lt_data> TYPE table,
                   <ls_data> TYPE any,
                   <l_sernr> TYPE /gpios/pbl_sernr,
                   <l_mandt> TYPE mandt.

    /gpios/cl_pbl_json=>deserialize(
      EXPORTING json = iv_json
      CHANGING  data = ea_data ).

    lo_typedescr = cl_abap_typedescr=>describe_by_data( p_data = ea_data ).

    CASE lo_typedescr->kind.
      WHEN lo_typedescr->kind_table.
        ASSIGN ea_data TO <lt_data>.
        l_do = lines( <lt_data> ).
      WHEN lo_typedescr->kind_struct.
        ASSIGN ea_data TO <ls_data>.
        l_do = 1.
      WHEN OTHERS.
        l_do = 0.
    ENDCASE.

    DO l_do TIMES.
      IF <lt_data> IS ASSIGNED.
        READ TABLE <lt_data> INDEX sy-index ASSIGNING <ls_data>.
      ENDIF.
      ASSIGN COMPONENT 'SERNR' OF STRUCTURE <ls_data> TO <l_sernr>.
      IF sy-subrc = 0.
        <l_sernr> = /gpios/if_pbl_controller~gs_data-sernr.
      ENDIF.
      ASSIGN COMPONENT 'MANDT' OF STRUCTURE <ls_data> TO <l_mandt>.
      IF sy-subrc = 0.
        <l_mandt> = sy-mandt.
      ENDIF.
    ENDDO.

  ENDMETHOD.


  METHOD receive_data.
    DATA:
        lo_client  TYPE REF TO if_http_client,
        l_msg      TYPE string,
        l_json     TYPE string,
        lr_data    TYPE REF TO data,
        lr_data_wa TYPE REF TO data.

    FIELD-SYMBOLS: <ls_pbl_com> LIKE LINE OF /gpios/cl_pbl_settings_core=>instance->/gpios/pbl_com,
                   <la_data>    TYPE any,
                   <la_table>   TYPE STANDARD TABLE,
                   <la_data_wa> TYPE any.

    READ TABLE /gpios/cl_pbl_settings_core=>instance->/gpios/pbl_com
         WITH TABLE KEY data_type = iv_data_type
                        comm_action = /gpios/if_pbl_controller=>gc_comm_action_get
         ASSIGNING <ls_pbl_com>.

    lo_client = get_http_client( iv_path = <ls_pbl_com>-pfadpre ).
    CHECK NOT lo_client IS INITIAL.
    lo_client->request->set_method( if_http_request=>co_request_method_get ).

    CLEAR: sy-msgty, sy-msgid.
    lo_client->send( EXCEPTIONS http_communication_failure = 1
                                http_invalid_state         = 2
                                http_processing_failed     = 3
                                http_invalid_timeout       = 4
                                OTHERS                     = 5 ).
    IF sy-subrc <> 0.
      lo_client->get_last_error( IMPORTING message = l_msg ).
      cl_message_helper=>set_msg_vars_for_clike( text = l_msg ).
      raise_generic_exception.
    ENDIF.

    CLEAR: sy-msgty, sy-msgid.
    lo_client->receive( EXCEPTIONS http_communication_failure = 1
                                   http_invalid_state         = 2
                                   http_processing_failed     = 3
                                   OTHERS                     = 4 ).
    IF sy-subrc <> 0.
      lo_client->get_last_error( IMPORTING message = l_msg ).
      cl_message_helper=>set_msg_vars_for_clike( text = l_msg ).
      raise_generic_exception.
    ENDIF.

    l_json = lo_client->response->get_cdata( ).

    lo_client->close( ).

    /gpios/if_pbl_controller~get_data_ref_for_data_type(
                                EXPORTING iv_data_type = iv_data_type
                                          iv_comm_type = /gpios/if_pbl_controller=>gc_comm_type_remote
                                IMPORTING er_data      = lr_data ).

    ASSIGN lr_data->* TO <la_data>.
    CLEAR: <la_data>.

    IF iv_data_type IN gt_r_flat_conversion AND gt_r_flat_conversion IS NOT INITIAL.
      ASSIGN <la_data> TO <la_table>.
      CREATE DATA lr_data_wa LIKE LINE OF <la_table>.
      ASSIGN lr_data_wa->* TO <la_data_wa>.
      json2abap( EXPORTING iv_json      = l_json
                           iv_data_type = iv_data_type
                 IMPORTING ea_data      = <la_data_wa> ).
      APPEND <la_data_wa> TO <la_table>.
    ELSE.
      json2abap( EXPORTING iv_json      = l_json
                           iv_data_type = iv_data_type
                 IMPORTING ea_data      = <la_data> ).

    ENDIF.


  ENDMETHOD.


  METHOD set_deletetion_delta.

    DATA: lr_delete     TYPE REF TO data,
          lr_delete_wa  TYPE REF TO data,
          lo_tabledescr TYPE REF TO cl_abap_tabledescr,
          lt_keys       TYPE abap_table_keydescr_tab,
          l_where       TYPE string.

    FIELD-SYMBOLS: <lt_foreign_data> TYPE STANDARD TABLE,
                   <lt_my_data>      TYPE STANDARD TABLE,
                   <ls_my_data>      TYPE any,
                   <lt_delete>       TYPE STANDARD TABLE,
                   <ls_delete>       TYPE any,
                   <ls_key>          LIKE LINE OF lt_keys,
                   <ls_component>    LIKE LINE OF <ls_key>-components.

    ASSIGN ia_my_data      TO <lt_my_data>.
    ASSIGN ia_foreign_data TO <lt_foreign_data>.

    /gpios/if_pbl_controller~get_data_ref_for_data_type(
      EXPORTING iv_data_type = iv_data_type
                iv_comm_type = /gpios/if_pbl_controller=>gc_comm_type_remote
                iv_delete    = abap_true
      IMPORTING er_data      = lr_delete ).

    CHECK lr_delete IS BOUND.

    ASSIGN lr_delete->* TO <lt_delete>.

    CLEAR: <lt_delete>.

    lo_tabledescr ?= cl_abap_tabledescr=>describe_by_data( p_data = <lt_my_data> ).

    lt_keys = lo_tabledescr->get_keys( ).

    READ TABLE lt_keys WITH KEY is_primary = abap_true ASSIGNING <ls_key>.
    CHECK sy-subrc = 0.

    LOOP AT <ls_key>-components ASSIGNING <ls_component>.
      IF l_where IS INITIAL.
        CONCATENATE <ls_component>-name ` = <LS_MY_DATA>-` <ls_component>-name INTO l_where.
      ELSE.
        CONCATENATE l_where ` AND ` <ls_component>-name ` = <LS_MY_DATA>-` <ls_component>-name  INTO l_where.
      ENDIF.
    ENDLOOP.

    CREATE DATA lr_delete_wa LIKE LINE OF <lt_delete>.
    ASSIGN lr_delete_wa->* TO <ls_delete>.

    LOOP AT <lt_my_data> ASSIGNING <ls_my_data>.
      LOOP AT <lt_foreign_data> TRANSPORTING NO FIELDS WHERE (l_where).
        EXIT. ">>>>>>>>>
      ENDLOOP.
      CHECK sy-subrc <> 0.
      MOVE-CORRESPONDING <ls_my_data> TO <ls_delete>.
      APPEND <ls_delete> TO <lt_delete>.
    ENDLOOP.

  ENDMETHOD.


  METHOD transfer_data.

    DATA: lr_data    TYPE REF TO data,
          lo_client  TYPE REF TO if_http_client,
          l_json     TYPE string,
          l_msg      TYPE string,
          l_response TYPE string,
          l_code     TYPE i,
          l_reason   TYPE string.

    FIELD-SYMBOLS: <ls_pbl_com> LIKE LINE OF /gpios/cl_pbl_settings_core=>instance->/gpios/pbl_com,
                   <la_data>    TYPE any,
                   <la_table>   TYPE STANDARD TABLE.

    /gpios/if_pbl_controller~get_data_ref_for_data_type(
                                EXPORTING iv_data_type = iv_data_type
                                          iv_comm_type = /gpios/if_pbl_controller=>gc_comm_type_remote
                                IMPORTING er_data      = lr_data ).

    IF lr_data IS BOUND.
      ASSIGN lr_data->* TO <la_data>.

      IF iv_data_type IN gt_r_flat_conversion AND gt_r_flat_conversion IS NOT INITIAL.
        ASSIGN <la_data> TO <la_table>.
        READ TABLE <la_table> INDEX 1 ASSIGNING <la_data>.
      ENDIF.

    ENDIF.

    READ TABLE /gpios/cl_pbl_settings_core=>instance->/gpios/pbl_com
         WITH TABLE KEY data_type = iv_data_type
                        comm_action = /gpios/if_pbl_controller=>gc_comm_action_post
         ASSIGNING <ls_pbl_com>.

    lo_client = get_http_client( iv_path = <ls_pbl_com>-pfadpre ).
    CHECK NOT lo_client IS INITIAL.
    lo_client->request->set_method( if_http_request=>co_request_method_post ).
    lo_client->request->if_http_entity~set_content_type( `application/json;charset=UTF-8` ). "#EC NOTEXT

    IF <la_data> IS ASSIGNED.
      abap2json( EXPORTING iv_data_type = iv_data_type
                           ia_data      = <la_data>
                 IMPORTING ev_json      = l_json ).

    ENDIF.

    lo_client->request->set_cdata( l_json ).


    lo_client->send( EXCEPTIONS http_communication_failure = 1
                                http_invalid_state         = 2
                                http_processing_failed     = 3
                                http_invalid_timeout       = 4
                                OTHERS                     = 5 ).
    IF sy-subrc <> 0.
      lo_client->get_last_error( IMPORTING message = l_msg ).
      cl_message_helper=>set_msg_vars_for_clike( text = l_msg ).
      raise_generic_exception.
    ENDIF.

    lo_client->receive( EXCEPTIONS http_communication_failure = 1
                                   http_invalid_state         = 2
                                   http_processing_failed     = 3
                                   OTHERS                     = 4 ).
    IF sy-subrc <> 0.
      lo_client->get_last_error( IMPORTING message = l_msg ).
      cl_message_helper=>set_msg_vars_for_clike( text = l_msg ).
      raise_generic_exception.
    ENDIF.

    l_response = lo_client->response->get_cdata( ).

    lo_client->response->get_status( IMPORTING code   = l_code
                                               reason = l_reason ).
    IF l_code <> /gpios/if_pbl_controller=>gc_http_code_ok.
      /gpios/cx_pbl_core=>data_transfer_failed( io_controller = me
                                                iv_code       = l_code
                                                iv_reason     = l_reason ).
    ENDIF.

    lo_client->close( ).

  ENDMETHOD.


  METHOD trigger_action.

    DATA: lr_data    TYPE REF TO data,
          lo_client  TYPE REF TO if_http_client,
          l_method   TYPE string,
          l_json     TYPE string,
          l_msg      TYPE string.

    FIELD-SYMBOLS: <ls_pbl_act> LIKE LINE OF /gpios/cl_pbl_settings_core=>instance->/gpios/pbl_act,
                   <la_table>   TYPE STANDARD TABLE.

    CLEAR: ev_response, ev_code, ev_reason.

    READ TABLE /gpios/cl_pbl_settings_core=>instance->/gpios/pbl_act
         WITH TABLE KEY action_type = iv_action_type
         ASSIGNING <ls_pbl_act>.

    CHECK sy-subrc = 0.

    lo_client = get_http_client( iv_path = <ls_pbl_act>-pfadpre ).
    CHECK NOT lo_client IS INITIAL.
    l_method = <ls_pbl_act>-comm_action.
    lo_client->request->set_method( l_method ).
    lo_client->request->if_http_entity~set_content_type( `application/json;charset=UTF-8` ). "#EC NOTEXT

    IF ia_data IS SUPPLIED.
      abap2json( EXPORTING iv_action_type = iv_action_type
                           ia_data        = ia_data
                 IMPORTING ev_json        = l_json ).

    ENDIF.

    lo_client->request->set_cdata( l_json ).


    lo_client->send( EXCEPTIONS http_communication_failure = 1
                                http_invalid_state         = 2
                                http_processing_failed     = 3
                                http_invalid_timeout       = 4
                                OTHERS                     = 5 ).
    IF sy-subrc <> 0.
      lo_client->get_last_error( IMPORTING message = l_msg ).
      cl_message_helper=>set_msg_vars_for_clike( text = l_msg ).
      raise_generic_exception.
    ENDIF.

    lo_client->receive( EXCEPTIONS http_communication_failure = 1
                                   http_invalid_state         = 2
                                   http_processing_failed     = 3
                                   OTHERS                     = 4 ).
    IF sy-subrc <> 0.
      lo_client->get_last_error( IMPORTING message = l_msg ).
      cl_message_helper=>set_msg_vars_for_clike( text = l_msg ).
      raise_generic_exception.
    ENDIF.

    ev_response = lo_client->response->get_cdata( ).

    lo_client->response->get_status( IMPORTING code   = ev_code
                                               reason = ev_reason ).
    IF ev_code <> /gpios/if_pbl_controller=>gc_http_code_ok.
      /gpios/cx_pbl_core=>data_transfer_failed( io_controller = me
                                                  iv_code       = ev_code
                                                  iv_reason     = ev_reason ).
    ENDIF.

    lo_client->close( ).

  ENDMETHOD.
ENDCLASS.
