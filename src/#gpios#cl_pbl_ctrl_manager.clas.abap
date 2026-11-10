class /GPIOS/CL_PBL_CTRL_MANAGER definition
  public
  create protected .

public section.

  interfaces /GPIOS/IF_PBL_CTRL_MANAGER .

  class-data INSTANCE type ref to /GPIOS/IF_PBL_CTRL_MANAGER read-only .
  data GO_CONTAINER type ref to CL_GUI_CUSTOM_CONTAINER read-only .
  data GO_LOCAL_ALV type ref to CL_SALV_TABLE read-only .
  data GO_LOCAL_COLUMNS type ref to CL_SALV_COLUMNS_LIST read-only .
  data GO_LOCAL_EVENTS type ref to CL_SALV_EVENTS_TABLE read-only .
  data GO_LOCAL_FUNCTIONS type ref to CL_SALV_FUNCTIONS_LIST read-only .
  data GO_LOCAL_LAYOUT type ref to CL_SALV_LAYOUT read-only .
  data GO_REMOTE_ALV type ref to CL_SALV_TABLE read-only .
  data GO_REMOTE_COLUMNS type ref to CL_SALV_COLUMNS_LIST read-only .
  data GO_REMOTE_EVENTS type ref to CL_SALV_EVENTS_TABLE read-only .
  data GO_REMOTE_FUNCTIONS type ref to CL_SALV_FUNCTIONS_LIST read-only .
  data GO_REMOTE_HTML type ref to CL_GUI_HTML_VIEWER read-only .
  data GO_REMOTE_LAYOUT type ref to CL_SALV_LAYOUT read-only .
  data GO_REMOTE_SPLITTER type ref to CL_GUI_SPLITTER_CONTAINER read-only .
  data GO_SPLITTER type ref to CL_GUI_SPLITTER_CONTAINER read-only .
  data GS_LOCAL_LAYOUT_KEY type SALV_S_LAYOUT_KEY read-only .
  data GS_REMOTE_LAYOUT_KEY type SALV_S_LAYOUT_KEY read-only .

  class-methods CLASS_CONSTRUCTOR .
  methods LEAVE .
protected section.

  methods CONSTRUCTOR .
  methods INIT_ALV
    raising
      /GPIOS/CX_PBL
      CX_SALV_MSG
      CX_SALV_WRONG_CALL
      CX_SALV_EXISTING .
  methods ON_ADDED_FUNCTION
    for event ADDED_FUNCTION of CL_SALV_EVENTS_TABLE
    importing
      !E_SALV_FUNCTION
      !SENDER .
  methods ON_REALTIME_RECEIVED
    for event RECEIVED of /GPIOS/IF_PBL_REALTIME
    importing
      !ET_RT_DATA .
  methods REGISTER_REALTIME .
private section.
ENDCLASS.



CLASS /GPIOS/CL_PBL_CTRL_MANAGER IMPLEMENTATION.


  METHOD /gpios/if_pbl_ctrl_manager~pai.

    CASE iv_ucomm.
      WHEN 'BACK' OR 'CANC' OR 'EXIT'.
        leave( ).
      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.


  METHOD /gpios/if_pbl_ctrl_manager~pbo.

    DATA: l_value     TYPE dd07v-domvalue_l,
          ls_dd07v_wa TYPE dd07v.

    SET PF-STATUS 'DEFAULT' OF PROGRAM iv_repid.

    l_value = /gpios/if_pbl_ctrl_manager~gv_data_type.

    CALL FUNCTION 'DDUT_DOMVALUE_TEXT_GET'
      EXPORTING
        name          = '/GPIOS/PBL_DATA_TYPE'
        value         = l_value
      IMPORTING
        dd07v_wa      = ls_dd07v_wa
      EXCEPTIONS
        OTHERS        = 0.

    SET TITLEBAR 'DEFAULT' OF PROGRAM iv_repid WITH /gpios/if_pbl_ctrl_manager~gv_data_type ls_dd07v_wa-ddtext.

    CHECK /gpios/if_pbl_ctrl_manager~gv_data_type IN /gpios/if_pbl_ctrl_manager~gt_r_allowed_data_types.

    IF go_container IS INITIAL.

      register_realtime( ).

      CREATE OBJECT go_container
        EXPORTING
          container_name              = iv_container_name
          dynnr                       = iv_dynnr
          repid                       = iv_repid
        EXCEPTIONS
          cntl_error                  = 1
          cntl_system_error           = 2
          create_error                = 3
          lifetime_error              = 4
          lifetime_dynpro_dynpro_link = 5
          OTHERS                      = 6.
      CHECK sy-subrc = 0.

      CREATE OBJECT go_splitter
        EXPORTING
          link_dynnr        = sy-dynnr
          link_repid        = sy-cprog
          rows              = 1
          columns           = 2
          parent            = go_container
        EXCEPTIONS
          cntl_error        = 1
          cntl_system_error = 2
          OTHERS            = 3.
      CHECK sy-subrc = 0.

      IF /gpios/if_pbl_ctrl_manager~gt_r_remote_data_types IS NOT INITIAL AND
         /gpios/if_pbl_ctrl_manager~gv_data_type IN /gpios/if_pbl_ctrl_manager~gt_r_remote_data_types.
        go_splitter->set_column_width(
          EXPORTING  id                = 2
                     width             = 100
          EXCEPTIONS cntl_error        = 1
                     cntl_system_error = 2
                     OTHERS            = 3 ).
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ENDIF.

      init_alv( ).

    ENDIF.

  ENDMETHOD.


  METHOD /gpios/if_pbl_ctrl_manager~receive.

    /gpios/if_pbl_ctrl_manager~go_local_controller->copy_data_from_ref_controller(
      EXPORTING
        iv_save           = abap_true    " Daten auch speichern?
        iv_load_data      = abap_true    " Daten vorab Laden?
        io_ref_controller = /gpios/if_pbl_ctrl_manager~go_remote_controller
        iv_data_type      = /gpios/if_pbl_ctrl_manager~gv_data_type
        iv_my_comm_type   = /gpios/if_pbl_controller=>gc_comm_type_local
        iv_ref_comm_type  = /gpios/if_pbl_controller=>gc_comm_type_remote ).

  ENDMETHOD.


  METHOD /gpios/if_pbl_ctrl_manager~set_controller.

    /gpios/if_pbl_ctrl_manager~go_local_controller = io_local_controller.

    /gpios/if_pbl_ctrl_manager~go_remote_controller = io_remote_controller.

  ENDMETHOD.


  METHOD /gpios/if_pbl_ctrl_manager~set_data_type.

    /gpios/if_pbl_ctrl_manager~gv_data_type = iv_data_type.

  ENDMETHOD.


  METHOD /gpios/if_pbl_ctrl_manager~transfer.

    /gpios/if_pbl_ctrl_manager~go_remote_controller->copy_data_from_ref_controller(
      EXPORTING
        iv_save           = abap_true    " Daten auch speichern?
        iv_load_data      = abap_true    " Daten vorab Laden?
        io_ref_controller = /gpios/if_pbl_ctrl_manager~go_remote_controller
        iv_data_type      = /gpios/if_pbl_ctrl_manager~gv_data_type
        iv_my_comm_type   = /gpios/if_pbl_controller=>gc_comm_type_remote
        iv_ref_comm_type  = /gpios/if_pbl_controller=>gc_comm_type_local ).

  ENDMETHOD.


  METHOD class_constructor.

    IF /gpios/cl_pbl_settings_core=>instance->/gpios/pbl_set-clsname_ctrl_manager IS INITIAL.
      CREATE OBJECT instance TYPE /gpios/cl_pbl_ctrl_manager.
    ELSE.
      CREATE OBJECT instance TYPE (/gpios/cl_pbl_settings_core=>instance->/gpios/pbl_set-clsname_ctrl_manager).
    ENDIF.

  ENDMETHOD.


  METHOD constructor.

    DATA: ls_r_data_type LIKE LINE OF /gpios/if_pbl_ctrl_manager~gt_r_local_data_types.

    set_remote_data_types: /gpios/if_pbl_controller=>gc_data_type_io_units.

  ENDMETHOD.


  METHOD init_alv.

    DATA: lo_local_container  TYPE REF TO cl_gui_container,
          lo_remote_container TYPE REF TO cl_gui_container,
          lr_data             TYPE REF TO data,
          lo_display_settings TYPE REF TO cl_salv_display_settings,
          lo_column        TYPE REF TO cl_salv_column_list,
          l_title             TYPE lvc_title,
          l_ui_url            TYPE url,
          l_icon              TYPE string,
          l_tooltip           TYPE string,
          l_text              TYPE string.
*          l_ts                TYPE timestamp,
*          l_n15               TYPE n LENGTH 15,
*          l_ts_s              TYPE string,
*          l_url_s             TYPE string.

    FIELD-SYMBOLS: <lt_data> TYPE STANDARD TABLE.

    CHECK go_splitter IS NOT INITIAL.

    lo_local_container = go_splitter->get_container(
        row       = 1
        column    = 1 ).

    lo_remote_container = go_splitter->get_container(
        row       = 1
        column    = 2 ).

    IF /gpios/if_pbl_ctrl_manager~gt_r_remote_data_types IS INITIAL OR
       /gpios/if_pbl_ctrl_manager~gv_data_type NOT IN /gpios/if_pbl_ctrl_manager~gt_r_remote_data_types.

      /gpios/if_pbl_ctrl_manager~go_local_controller->load(
        EXPORTING iv_comm_type    = /gpios/if_pbl_controller=>gc_comm_type_local
                  iv_data_type    = /gpios/if_pbl_ctrl_manager~gv_data_type ).

      /gpios/if_pbl_ctrl_manager~go_local_controller->get_data_ref_for_data_type(
        EXPORTING iv_data_type = /gpios/if_pbl_ctrl_manager~gv_data_type
                  iv_comm_type = /gpios/if_pbl_controller=>gc_comm_type_local
        IMPORTING er_data      = lr_data ).

      ASSIGN lr_data->* TO <lt_data>.

      cl_salv_table=>factory(
           EXPORTING r_container  = lo_local_container
           IMPORTING r_salv_table = go_local_alv
           CHANGING  t_table      = <lt_data> ).
      lo_display_settings = go_local_alv->get_display_settings( ).
      l_title = 'Daten in SAP (&1 - &2)'(001).
      REPLACE ALL OCCURRENCES OF '&1' IN l_title WITH /gpios/if_pbl_ctrl_manager~go_local_controller->gs_data-sernr.
      REPLACE ALL OCCURRENCES OF '&2' IN l_title WITH /gpios/if_pbl_ctrl_manager~go_local_controller->gv_description.

      lo_display_settings->set_list_header( value = l_title ).

      gs_local_layout_key-report = sy-repid.
      IF /gpios/if_pbl_ctrl_manager~gv_data_type(3) = 'BOM'.
        CONCATENATE 'L' /gpios/if_pbl_ctrl_manager~gv_data_type+3
          INTO gs_local_layout_key-handle.
      ELSE.
        CONCATENATE 'L' /gpios/if_pbl_ctrl_manager~gv_data_type(3)
          INTO gs_local_layout_key-handle.
      ENDIF.

      go_local_layout = go_local_alv->get_layout( ).
      go_local_layout->set_key( gs_local_layout_key ).
*      gs_local_layout = go_local_layout->get_default_layout( ).
      go_local_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).
      go_local_layout->set_default( abap_true ).

      go_local_columns = go_local_alv->get_columns( ).
      TRY.
          lo_column ?= go_local_columns->get_column( 'MANDT' ).
          lo_column->set_technical( ).
        CATCH cx_salv_not_found.                        "#EC NO_HANDLER
      ENDTRY.

      go_local_events = go_local_alv->get_event( ).
      SET HANDLER on_added_function FOR go_local_events.

      go_local_functions = go_local_alv->get_functions( ).
      go_local_functions->set_all( ).

      l_icon = icon_refresh.
      l_tooltip = 'Anzeige aktualisieren'(002).
      go_local_functions->add_function(
        EXPORTING
          name               = 'REFRESH'
          icon               = l_icon
          tooltip            = l_tooltip
          position           = if_salv_c_function_position=>left_of_salv_functions ).

      l_icon = icon_delete.
      l_tooltip = 'Alles löschen'(003).
      go_local_functions->add_function(
        EXPORTING
          name               = 'DELETE_ALL'
          icon               = l_icon
          tooltip            = l_tooltip
          position           = if_salv_c_function_position=>left_of_salv_functions ).

      l_icon = icon_delete_row.
      l_tooltip = 'Zeile löschen'(004).
      go_local_functions->add_function(
        EXPORTING
          name               = 'DELETE_ROW'
          icon               = l_icon
          tooltip            = l_tooltip
          position           = if_salv_c_function_position=>left_of_salv_functions ).

    ELSE.
      lo_local_container->set_visible(
        EXPORTING  visible           = abap_false
        EXCEPTIONS cntl_error        = 1
                   cntl_system_error = 2
                   OTHERS            = 3 ).
      CHECK sy-subrc = 0.
    ENDIF.

**********************************************************************
* REMOTE PART --->
**********************************************************************

    IF /gpios/if_pbl_ctrl_manager~gt_r_local_data_types IS INITIAL OR
       /gpios/if_pbl_ctrl_manager~gv_data_type NOT IN /gpios/if_pbl_ctrl_manager~gt_r_local_data_types.

      CREATE OBJECT go_remote_splitter
        EXPORTING
          parent            = lo_remote_container
          rows              = 2
          columns           = 1
        EXCEPTIONS
          cntl_error        = 1
          cntl_system_error = 2
          OTHERS            = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      lo_remote_container = go_remote_splitter->get_container(
               row       = 2
               column    = 1 ).

      CREATE OBJECT go_remote_html
        EXPORTING
          parent             = lo_remote_container
        EXCEPTIONS
          cntl_error         = 1
          cntl_install_error = 2
          dp_install_error   = 3
          dp_error           = 4
          OTHERS             = 5.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      lo_remote_container = go_remote_splitter->get_container(
         row       = 1
         column    = 1 ).

      /gpios/if_pbl_ctrl_manager~go_remote_controller->load(
        EXPORTING iv_comm_type    = /gpios/if_pbl_controller=>gc_comm_type_remote
                  iv_data_type    = /gpios/if_pbl_ctrl_manager~gv_data_type ).

      /gpios/if_pbl_ctrl_manager~go_remote_controller->get_data_ref_for_data_type(
        EXPORTING iv_data_type = /gpios/if_pbl_ctrl_manager~gv_data_type
                  iv_comm_type = /gpios/if_pbl_controller=>gc_comm_type_remote
        IMPORTING er_data      = lr_data ).

      ASSIGN lr_data->* TO <lt_data>.


      cl_salv_table=>factory(
           EXPORTING r_container  = lo_remote_container
           IMPORTING r_salv_table = go_remote_alv
           CHANGING  t_table      = <lt_data> ).

      lo_display_settings = go_remote_alv->get_display_settings( ).
      l_title = 'Gerätedaten (&1 - &2)'(005).
      REPLACE ALL OCCURRENCES OF '&1' IN l_title WITH /gpios/if_pbl_ctrl_manager~go_remote_controller->gs_data-sernr.
      REPLACE ALL OCCURRENCES OF '&2' IN l_title WITH /gpios/if_pbl_ctrl_manager~go_remote_controller->gv_description.
      lo_display_settings->set_list_header( value = l_title ).

      gs_remote_layout_key-report = sy-repid.
      IF /gpios/if_pbl_ctrl_manager~gv_data_type(3) = 'BOM'.
        CONCATENATE 'R' /gpios/if_pbl_ctrl_manager~gv_data_type+3
          INTO gs_remote_layout_key-handle.
      ELSE.
        CONCATENATE 'R' /gpios/if_pbl_ctrl_manager~gv_data_type(3)
          INTO gs_remote_layout_key-handle.
      ENDIF.

      go_remote_layout = go_remote_alv->get_layout( ).
      go_remote_layout->set_key( gs_remote_layout_key ).
*      gs_remote_layout = go_remote_layout->get_default_layout( ).
      go_remote_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).
      go_remote_layout->set_default( abap_true ).

      go_remote_columns = go_remote_alv->get_columns( ).
      TRY.
          lo_column ?= go_remote_columns->get_column( 'MANDT' ).
          lo_column->set_technical( ).
        CATCH cx_salv_not_found.                        "#EC NO_HANDLER
      ENDTRY.

      go_remote_functions = go_remote_alv->get_functions( ).
      go_remote_functions->set_all( ).

      go_remote_events = go_remote_alv->get_event( ).
      SET HANDLER on_added_function FOR go_remote_events.

      IF go_local_alv IS NOT INITIAL AND
         /gpios/if_pbl_ctrl_manager~gv_data_type <> /gpios/if_pbl_controller=>gc_data_type_io_units.
        l_icon = icon_arrow_left.
        l_tooltip = 'Daten von Steuergerät laden'(007).
        l_text = 'Herunterladen'(006).
        go_remote_functions->add_function(
          EXPORTING
            name               = 'RECEIVE_FROM_REMOTE'
            icon               = l_icon
            text               = l_text
            tooltip            = l_tooltip
            position           = if_salv_c_function_position=>left_of_salv_functions ).
      ENDIF.

      l_icon = icon_refresh.
      l_tooltip = 'Anzeige aktualisieren'(002).
      go_remote_functions->add_function(
        EXPORTING
          name               = 'REFRESH'
          icon               = l_icon
          tooltip            = l_tooltip
          position           = if_salv_c_function_position=>left_of_salv_functions ).

      CASE /gpios/if_pbl_ctrl_manager~gv_data_type.
        WHEN /gpios/if_pbl_controller=>gc_data_type_io_units.
          l_icon = icon_led_red.
          l_tooltip = 'Rot anschalten/ausschalten'(008).
          go_remote_functions->add_function(
            EXPORTING
              name               = 'TOGGLE_RED'
              icon               = l_icon
              tooltip            = l_tooltip
              position           = if_salv_c_function_position=>right_of_salv_functions ).

          l_icon = icon_led_green.
          l_tooltip = 'Grün anschalten/ausschalten'(009).
          go_remote_functions->add_function(
             EXPORTING
               name               = 'TOGGLE_GREEN'
               icon               = l_icon
               tooltip            = l_tooltip
               position           = if_salv_c_function_position=>right_of_salv_functions ).

          l_icon = icon_businav_szenario.
          l_tooltip = 'Blau anschalten/ausschalten'(010).
          go_remote_functions->add_function(
            EXPORTING
              name               = 'TOGGLE_BLUE'
              icon               = l_icon
              tooltip            = l_tooltip
              position           = if_salv_c_function_position=>right_of_salv_functions ).

        WHEN /gpios/if_pbl_controller=>gc_data_type_components.
          l_icon = icon_failure.
          l_tooltip = 'Alle LED anschalten/ausschalten'(011).
          go_remote_functions->add_function(
            EXPORTING
              name               = 'TOGGLE_ALL'
              icon               = l_icon
              tooltip            = l_tooltip
              position           = if_salv_c_function_position=>right_of_salv_functions ).

        WHEN /gpios/if_pbl_controller=>gc_data_type_bomitm.

          l_icon = icon_failure.
          l_tooltip = 'Stücklistenkomponente anschalten/ausschalten'(012).
          go_remote_functions->add_function(
            EXPORTING
              name               = 'TOGGLE_BOM_ITEM_IO'
              icon               = l_icon
              tooltip            = l_tooltip
              position           = if_salv_c_function_position=>right_of_salv_functions ).

      ENDCASE.

      IF /gpios/if_pbl_ctrl_manager~gv_data_type <> /gpios/if_pbl_controller=>gc_data_type_io_units.
        l_icon = icon_delete.
        l_tooltip = 'Alles löschen'(003).
        go_remote_functions->add_function(
          EXPORTING
            name               = 'DELETE_ALL'
            icon               = l_icon
            tooltip            = l_tooltip
            position           = if_salv_c_function_position=>left_of_salv_functions ).

        l_icon = icon_delete_row.
        l_tooltip = 'Zeile löschen'(004).
        go_remote_functions->add_function(
          EXPORTING
            name               = 'DELETE_ROW'
            icon               = l_icon
            tooltip            = l_tooltip
            position           = if_salv_c_function_position=>left_of_salv_functions ).
      ENDIF.

      IF /gpios/if_pbl_ctrl_manager~gv_data_type = /gpios/if_pbl_controller=>gc_data_type_bomhdr.
        l_icon = icon_system_play.
        l_tooltip = 'Stückliste starten'(013).
        go_remote_functions->add_function(
          EXPORTING
            name               = 'START_BOM'
            icon               = l_icon
            tooltip            = l_tooltip
            position           = if_salv_c_function_position=>right_of_salv_functions ).

        l_icon = icon_breakpoint.
        l_tooltip = 'Stückliste stoppen'(014).
        go_remote_functions->add_function(
          EXPORTING
            name               = 'STOP_BOM'
            icon               = l_icon
            tooltip            = l_tooltip
            position           = if_salv_c_function_position=>right_of_salv_functions ).

        l_icon = icon_bom.
        l_tooltip = 'Laufende Stückliste ermitteln'(015).
        go_remote_functions->add_function(
          EXPORTING
            name               = 'GET_RUNNING_BOM'
            icon               = l_icon
            tooltip            = l_tooltip
            position           = if_salv_c_function_position=>right_of_salv_functions ).

      ENDIF.

    ELSE.
      lo_remote_container->set_visible(
        EXPORTING  visible           = abap_false
        EXCEPTIONS cntl_error        = 1
                   cntl_system_error = 2
                   OTHERS            = 3 ).
      CHECK sy-subrc = 0.
    ENDIF.

    IF go_local_alv IS NOT INITIAL.

      IF go_remote_alv IS NOT INITIAL.
*        lo_functions = go_local_alv->get_functions( ).

        l_icon = icon_arrow_right.
        l_tooltip = 'Daten auf Steuergerät laden'(017).
        l_text = 'Hochladen'(016).
        go_local_functions->add_function(
          EXPORTING
            name               = 'TRANSFER_TO_REMOTE'
            icon               = l_icon
            text               = l_text
            tooltip            = l_tooltip
            position           = if_salv_c_function_position=>right_of_salv_functions ).
      ENDIF.

      go_local_alv->display( ).
    ENDIF.

    IF go_remote_alv IS NOT INITIAL.
      go_remote_alv->display( ).
    ENDIF.


    IF go_remote_html IS NOT INITIAL.
      l_ui_url = /gpios/if_pbl_ctrl_manager~go_remote_controller->get_ui_url(
          iv_data_type = /gpios/if_pbl_ctrl_manager~gv_data_type ).
*      GET TIME STAMP FIELD l_ts.
*      l_ts_s = l_n15 = l_ts.
*      l_url_s = l_ui_url.
*      cl_http_server=>if_http_server~append_field_url(
*        EXPORTING
*          name  = 'DUMMY'
*          value = l_ts_s
*        CHANGING
*          url   = l_url_s ).
*      l_ui_url = l_url_s.
      go_remote_html->show_url(
        EXPORTING
          url                    = l_ui_url
        EXCEPTIONS
          cntl_error             = 1
          cnht_error_not_allowed = 2
          cnht_error_parameter   = 3
          dp_error_general       = 4
          OTHERS                 = 5 ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD leave.

    IF go_local_alv IS NOT INITIAL.
      go_local_alv->close_screen( ).
    ENDIF.

    IF go_remote_alv IS NOT INITIAL.
      go_remote_alv->close_screen( ).
    ENDIF.

    IF go_remote_html IS NOT INITIAL.
*      go_remote_html->do_refresh( ).
      go_remote_html->close_document( ).
      go_remote_html->free( EXCEPTIONS cntl_error        = 1
                                               cntl_system_error = 2
                                               OTHERS            = 3 ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.

    go_remote_splitter->free( EXCEPTIONS cntl_error        = 1
                                         cntl_system_error = 2
                                         OTHERS            = 3 ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    go_splitter->free( EXCEPTIONS cntl_error        = 1
                                  cntl_system_error = 2
                                  OTHERS            = 3 ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    go_container->free( EXCEPTIONS cntl_error        = 1
                                   cntl_system_error = 2
                                   OTHERS            = 3 ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CLEAR: go_local_alv, go_remote_alv, go_splitter, go_container.

    LEAVE TO SCREEN 0.

  ENDMETHOD.


  METHOD on_added_function.

    DATA: lo_selections       TYPE REF TO cl_salv_selections,
          lt_selected_rows    TYPE salv_t_row,
          l_selected_row      LIKE LINE OF lt_selected_rows,
          lt_io_units         LIKE /gpios/if_pbl_ctrl_manager~go_remote_controller->gt_io_units,
          lt_final_io_units   LIKE lt_io_units,
          l_color             TYPE char1,
          lo_io_unit          LIKE LINE OF lt_io_units,
          ls_stable           TYPE lvc_s_stbl VALUE 'XX',
          lr_remote_data      TYPE REF TO data,
          lo_bom              TYPE REF TO /gpios/if_pbl_bom,
          lr_local_data       TYPE REF TO data,
          lt_final_bom_itms   LIKE /gpios/if_pbl_ctrl_manager~go_remote_controller->gt_remote_bom_items,
          lt_bom_items        LIKE lo_bom->bom_items,
          lo_bom_item         LIKE LINE OF lt_bom_items,
          l_controller_info   TYPE string,
          lx_root             TYPE REF TO cx_root,
          l_started           TYPE timestampl,
          lo_alv              TYPE REF TO cl_salv_table,
          lo_functions        TYPE REF TO cl_salv_functions_list,
          lo_display_settings TYPE REF TO cl_salv_display_settings,
          lt_bom_item_data    LIKE STANDARD TABLE OF lo_bom_item->gs_data.

    FIELD-SYMBOLS: <ls_io_unit_data> LIKE LINE OF /gpios/if_pbl_ctrl_manager~go_remote_controller->gt_io_unit_data,
                   <ls_component>    LIKE LINE OF /gpios/if_pbl_ctrl_manager~go_remote_controller->gt_remote_components,
                   <ls_bom_hdr>      LIKE LINE OF /gpios/if_pbl_ctrl_manager~go_remote_controller->gt_remote_bom_headers,
                   <ls_bom_itm>      LIKE LINE OF /gpios/if_pbl_ctrl_manager~go_remote_controller->gt_remote_bom_items,
                   <la_local_data>   TYPE any,
                   <la_remote_data>  TYPE any,
                   <lt_remote_data>  TYPE STANDARD TABLE,
                   <lt_local_data>  TYPE STANDARD TABLE.


    TRY.
        CASE sender.

          WHEN go_remote_events.

            lo_selections = go_remote_alv->get_selections( ).
            lt_selected_rows = lo_selections->get_selected_rows( ).

            CASE e_salv_function.
              WHEN 'TOGGLE_RED' OR 'TOGGLE_GREEN' OR 'TOGGLE_BLUE' OR 'TOGGLE_ALL' OR 'TOGGLE_BOM_ITEM_IO'.
                /gpios/if_pbl_ctrl_manager~go_remote_controller->get_io_units( IMPORTING et_io_units = lt_io_units ).

                CASE /gpios/if_pbl_ctrl_manager~gv_data_type.
                  WHEN /gpios/if_pbl_controller=>gc_data_type_io_units.
                    LOOP AT lt_selected_rows INTO l_selected_row.
                      READ TABLE /gpios/if_pbl_ctrl_manager~go_remote_controller->gt_io_unit_data
                           INDEX l_selected_row
                           ASSIGNING <ls_io_unit_data>.
                      CHECK sy-subrc = 0.
                      READ TABLE lt_io_units WITH KEY table_line->gs_data-io_uid = <ls_io_unit_data>-io_uid
                                             INTO lo_io_unit.
                      CHECK sy-subrc = 0.
                      APPEND lo_io_unit TO lt_final_io_units.
                    ENDLOOP.

                    CASE e_salv_function.
                      WHEN 'TOGGLE_RED'.
                        l_color = 'R'.
                      WHEN 'TOGGLE_GREEN'.
                        l_color = 'G'.
                      WHEN 'TOGGLE_BLUE'.
                        l_color = 'B'.
                    ENDCASE.

                    LOOP AT lt_final_io_units INTO lo_io_unit.
                      lo_io_unit->toggle_color( iv_color = l_color ).
                    ENDLOOP.

                  WHEN  /gpios/if_pbl_controller=>gc_data_type_components.

                    LOOP AT lt_selected_rows INTO l_selected_row.
                      READ TABLE /gpios/if_pbl_ctrl_manager~go_remote_controller->gt_remote_components
                           INDEX l_selected_row
                           ASSIGNING <ls_component>.
                      CHECK sy-subrc = 0.
                      READ TABLE lt_io_units WITH KEY table_line->gs_data-io_uid = <ls_component>-id
                                             INTO lo_io_unit.
                      IF sy-subrc = 0.
                        APPEND lo_io_unit TO lt_final_io_units.
                      ELSE.
                        /gpios/cx_pbl_core=>io_unit_not_exist(
                          EXPORTING
                            iv_sernr = /gpios/if_pbl_ctrl_manager~go_remote_controller->gs_data-sernr
                            iv_uid   = <ls_component>-id ).
                      ENDIF.
                    ENDLOOP.

                    LOOP AT lt_final_io_units INTO lo_io_unit.
                      lo_io_unit->toggle_all_colors( ).
                    ENDLOOP.

                  WHEN /gpios/if_pbl_controller=>gc_data_type_bomitm.

                    LOOP AT lt_selected_rows INTO l_selected_row.
                      READ TABLE /gpios/if_pbl_ctrl_manager~go_remote_controller->gt_remote_bom_items
                           INDEX l_selected_row
                           ASSIGNING <ls_bom_itm>.
                      CHECK sy-subrc = 0.
                      APPEND <ls_bom_itm> TO lt_final_bom_itms.
                    ENDLOOP.

                    SORT lt_final_bom_itms BY baugr ord ASCENDING.
                    TRY.

                        LOOP AT lt_final_bom_itms ASSIGNING <ls_bom_itm>.
                          AT NEW baugr.
                            lo_bom = /gpios/if_pbl_ctrl_manager~go_remote_controller->get_bom(
                                         iv_baugr             = <ls_bom_itm>-baugr
                                         iv_comm_type         = /gpios/if_pbl_controller=>gc_comm_type_remote
                                         iv_load_data         = abap_true
                                         iv_ping              = abap_false ).
                            lt_bom_items = lo_bom->get_bom_items(
                                       EXPORTING iv_comm_type     = /gpios/if_pbl_controller=>gc_comm_type_remote
                                                 iv_ping          = abap_false ).
                          ENDAT.

                          READ TABLE lt_bom_items WITH KEY table_line->gs_data-baugr = <ls_bom_itm>-baugr
                                                           table_line->gs_data-idnrk = <ls_bom_itm>-idnrk
                                                  INTO lo_bom_item.
                          CHECK lo_bom_item IS NOT INITIAL.
                          lo_bom_item->toggle_bom_itm( ).

                        ENDLOOP.
                      CATCH cx_root INTO lx_root.        "#EC CATCH_ALL
                        MESSAGE lx_root TYPE 'I' DISPLAY LIKE 'E'.
                    ENDTRY.
                ENDCASE.

              WHEN 'REFRESH'.
                /gpios/if_pbl_ctrl_manager~go_remote_controller->load(
                   EXPORTING iv_comm_type    = /gpios/if_pbl_controller=>gc_comm_type_remote
                             iv_data_type    = /gpios/if_pbl_ctrl_manager~gv_data_type ).
                go_remote_alv->refresh( EXPORTING s_stable = ls_stable ).
                MESSAGE s008 WITH /gpios/if_pbl_ctrl_manager~go_remote_controller->gs_data-sernr.
                IF go_remote_html IS NOT INITIAL.
                  go_remote_html->do_refresh(
                    EXCEPTIONS cntl_error = 1
                               OTHERS     = 2 ).
                  IF sy-subrc <> 0.
                    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                  ENDIF.
                ENDIF.

              WHEN 'RECEIVE_FROM_REMOTE'.
                /gpios/if_pbl_ctrl_manager~go_local_controller->copy_data_from_ref_controller(
                  EXPORTING iv_save           = abap_true    " Daten auch speichern?
                            iv_load_data      = abap_false    " Daten vorab Laden?
                            io_ref_controller = /gpios/if_pbl_ctrl_manager~go_remote_controller
                            iv_data_type      = /gpios/if_pbl_ctrl_manager~gv_data_type
                            iv_my_comm_type   = /gpios/if_pbl_controller=>gc_comm_type_local
                            iv_ref_comm_type  = /gpios/if_pbl_controller=>gc_comm_type_remote ).
                go_local_alv->refresh( EXPORTING s_stable = ls_stable ).
                MESSAGE s005 WITH /gpios/if_pbl_ctrl_manager~go_remote_controller->gs_data-sernr
                                  /gpios/if_pbl_ctrl_manager~go_local_controller->gs_data-sernr.

              WHEN 'DELETE_ALL'.
                /gpios/if_pbl_ctrl_manager~go_remote_controller->delete(
                  EXPORTING
                    iv_comm_type = /gpios/if_pbl_controller=>gc_comm_type_remote
                    iv_data_type = /gpios/if_pbl_ctrl_manager~gv_data_type
                    iv_all       = abap_true ).
                go_remote_alv->refresh( EXPORTING s_stable = ls_stable ).
                IF go_remote_html IS NOT INITIAL.
                  go_remote_html->do_refresh(
                    EXCEPTIONS cntl_error = 1
                               OTHERS     = 2 ).
                  IF sy-subrc <> 0.
                    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                  ENDIF.
                ENDIF.

              WHEN 'DELETE_ROW'.

                CHECK lt_selected_rows IS NOT INITIAL.

                /gpios/if_pbl_ctrl_manager~go_remote_controller->get_data_ref_for_data_type(
                  EXPORTING iv_data_type = /gpios/if_pbl_ctrl_manager~gv_data_type
                            iv_comm_type = /gpios/if_pbl_controller=>gc_comm_type_remote
                  IMPORTING er_data      = lr_remote_data ).
                ASSIGN lr_remote_data->* TO <lt_remote_data>.

                LOOP AT lt_selected_rows INTO l_selected_row.
                  READ TABLE <lt_remote_data> INDEX l_selected_row ASSIGNING <la_remote_data>.
                  /gpios/if_pbl_ctrl_manager~go_remote_controller->set_deletion_row(
                      ia_row       = <la_remote_data>
                      iv_data_type = /gpios/if_pbl_ctrl_manager~gv_data_type ).
                ENDLOOP.

                /gpios/if_pbl_ctrl_manager~go_remote_controller->delete(
                  EXPORTING
                    iv_all       = abap_false
                    iv_comm_type = /gpios/if_pbl_controller=>gc_comm_type_remote
                    iv_data_type = /gpios/if_pbl_ctrl_manager~gv_data_type ).


                go_remote_alv->refresh( EXPORTING s_stable = ls_stable ).
                IF go_remote_html IS NOT INITIAL.
                  go_remote_html->do_refresh(
                    EXCEPTIONS cntl_error = 1
                               OTHERS     = 2 ).
                  IF sy-subrc <> 0.
                    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                  ENDIF.
                ENDIF.

              WHEN 'START_BOM' OR 'STOP_BOM'.
                CHECK lt_selected_rows IS NOT INITIAL.
                READ TABLE lt_selected_rows INDEX 1 INTO l_selected_row.

                READ TABLE /gpios/if_pbl_ctrl_manager~go_remote_controller->gt_remote_bom_headers
                     INDEX l_selected_row ASSIGNING <ls_bom_hdr>.
                CHECK sy-subrc = 0.
                lo_bom = /gpios/if_pbl_ctrl_manager~go_remote_controller->get_bom(
                                  EXPORTING
                                    iv_baugr             = <ls_bom_hdr>-baugr
                                    iv_comm_type         = /gpios/if_pbl_controller=>gc_comm_type_remote
                                    iv_load_data         = abap_false ).
                CASE e_salv_function.
                  WHEN 'START_BOM'.
                    lo_bom->start( ).
                  WHEN 'STOP_BOM'.
                    lo_bom->stop( ).
                  WHEN OTHERS.
                ENDCASE.
              WHEN 'GET_RUNNING_BOM'.
                /gpios/if_pbl_ctrl_manager~go_remote_controller->get_running_bom( IMPORTING eo_bom                 = lo_bom
                                                                                              et_remaining_bom_items = lt_bom_items
                                                                                              ev_started_at          = l_started ).
                IF lo_bom IS NOT INITIAL.
                  l_controller_info = lines( lt_bom_items ).
                  MESSAGE s021 WITH lo_bom->gs_data-baugr
                                    l_started
                                    l_controller_info DISPLAY LIKE 'S'.
                  LOOP AT lt_bom_items INTO lo_bom_item.
                    APPEND lo_bom_item->gs_data TO lt_bom_item_data.
                  ENDLOOP.
                  IF lt_bom_item_data IS NOT INITIAL.
                    TRY.
                        cl_salv_table=>factory(
                          IMPORTING r_salv_table = lo_alv
                          CHANGING  t_table      = lt_bom_item_data ).
                        lo_display_settings = lo_alv->get_display_settings( ).
                        lo_display_settings->set_list_header( value = 'Liste der zu bearbeitenden Komponenten'(018) ).
                        lo_functions = lo_alv->get_functions( ).
                        lo_functions->set_all( 'X' ).

                        lo_alv->set_screen_popup(
                          start_column = 5
                          end_column   = 170
                          start_line   = 1
                          end_line     = 30 ).

                        lo_alv->display( ).

                      CATCH cx_salv_msg.                "#EC NO_HANDLER
                    ENDTRY.

                  ENDIF.
                ELSE.
                  CONCATENATE /gpios/if_pbl_ctrl_manager~go_remote_controller->gs_data-sernr
                              /gpios/if_pbl_ctrl_manager~go_remote_controller->gv_description
                            INTO l_controller_info SEPARATED BY space.
                  MESSAGE s020 WITH l_controller_info DISPLAY LIKE 'W'.
                ENDIF.

            ENDCASE.

          WHEN go_local_events.

            lo_selections = go_local_alv->get_selections( ).
            lt_selected_rows = lo_selections->get_selected_rows( ).

            CASE e_salv_function.
              WHEN 'TRANSFER_TO_REMOTE'.
                /gpios/if_pbl_ctrl_manager~go_remote_controller->copy_data_from_ref_controller(
                  EXPORTING iv_save           = abap_true    " Daten auch speichern?
                            iv_load_data      = abap_false    " Daten vorab Laden?
                            io_ref_controller = /gpios/if_pbl_ctrl_manager~go_local_controller
                            iv_data_type      = /gpios/if_pbl_ctrl_manager~gv_data_type
                            iv_my_comm_type   = /gpios/if_pbl_controller=>gc_comm_type_remote
                            iv_ref_comm_type  = /gpios/if_pbl_controller=>gc_comm_type_local ).
                go_remote_alv->refresh( EXPORTING s_stable = ls_stable ).
                MESSAGE s006 WITH /gpios/if_pbl_ctrl_manager~go_local_controller->gs_data-sernr
                                  /gpios/if_pbl_ctrl_manager~go_remote_controller->gs_data-sernr.
                IF go_remote_html IS NOT INITIAL.
                  go_remote_html->do_refresh(
                    EXCEPTIONS cntl_error = 1
                               OTHERS     = 2 ).
                  IF sy-subrc <> 0.
                    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                  ENDIF.
                ENDIF.
              WHEN 'REFRESH'.
                /gpios/if_pbl_ctrl_manager~go_local_controller->load(
                    EXPORTING iv_comm_type    = /gpios/if_pbl_controller=>gc_comm_type_local
                              iv_data_type    = /gpios/if_pbl_ctrl_manager~gv_data_type ).
                go_local_alv->refresh( EXPORTING s_stable = ls_stable ).
                MESSAGE s007 WITH /gpios/if_pbl_ctrl_manager~go_local_controller->gs_data-sernr.

              WHEN 'DELETE_ALL'.
                /gpios/if_pbl_ctrl_manager~go_local_controller->delete(
                  EXPORTING
                    iv_comm_type = /gpios/if_pbl_controller=>gc_comm_type_local
                    iv_data_type = /gpios/if_pbl_ctrl_manager~gv_data_type
                    iv_all       = abap_true ).
                go_local_alv->refresh( EXPORTING s_stable = ls_stable ).

              WHEN 'DELETE_ROW'.

                CHECK lt_selected_rows IS NOT INITIAL.

                /gpios/if_pbl_ctrl_manager~go_remote_controller->get_data_ref_for_data_type(
                  EXPORTING iv_data_type = /gpios/if_pbl_ctrl_manager~gv_data_type
                            iv_comm_type = /gpios/if_pbl_controller=>gc_comm_type_local
                  IMPORTING er_data      = lr_local_data ).
                ASSIGN lr_local_data->* TO <lt_local_data>.

                LOOP AT lt_selected_rows INTO l_selected_row.
                  READ TABLE <lt_local_data> INDEX l_selected_row ASSIGNING <la_local_data>.
                  /gpios/if_pbl_ctrl_manager~go_local_controller->set_deletion_row(
                      ia_row       = <la_local_data>
                      iv_data_type = /gpios/if_pbl_ctrl_manager~gv_data_type ).
                ENDLOOP.

                /gpios/if_pbl_ctrl_manager~go_local_controller->delete(
                  EXPORTING
                    iv_all       = abap_false
                    iv_comm_type = /gpios/if_pbl_controller=>gc_comm_type_local
                    iv_data_type = /gpios/if_pbl_ctrl_manager~gv_data_type ).

                go_local_alv->refresh( EXPORTING s_stable = ls_stable ).

            ENDCASE.

        ENDCASE.

      CATCH cx_root INTO lx_root.                        "#EC CATCH_ALL
        MESSAGE lx_root TYPE 'S' DISPLAY LIKE 'E'.
    ENDTRY.

  ENDMETHOD.


  METHOD on_realtime_received.

    DATA: lo_rt_data LIKE LINE OF et_rt_data.

    FIELD-SYMBOLS: <la_cb_data> TYPE any,
                   <lv_uid>     TYPE /gpios/pbl_ledno,
                   <ls_unit>    LIKE LINE OF /gpios/if_pbl_ctrl_manager~go_remote_controller->gt_io_unit_data.

    LOOP AT et_rt_data INTO lo_rt_data.
      ASSIGN lo_rt_data->gv_cb_data->* TO <la_cb_data>.

      IF lo_rt_data->gs_controller_data-sernr = /gpios/if_pbl_ctrl_manager~go_remote_controller->gs_data-sernr AND
         lo_rt_data->gv_cb_type = /gpios/if_pbl_callback=>gc_cb_type_io_change.
        ASSIGN COMPONENT 'IO_UID' OF STRUCTURE <la_cb_data> TO <lv_uid>.
        READ TABLE /gpios/if_pbl_ctrl_manager~go_remote_controller->gt_io_unit_data ASSIGNING <ls_unit>
          WITH KEY io_uid = <lv_uid>.
        IF sy-subrc = 0.
          MOVE-CORRESPONDING <la_cb_data> TO <ls_unit>.
        ENDIF.
      ENDIF.

      /gpios/cl_pbl_callback=>get_notification_text(
          io_controller = me->/gpios/if_pbl_ctrl_manager~go_remote_controller
          iv_cb_type    = lo_rt_data->gv_cb_type
          iv_cb_data    = <la_cb_data> ).
      MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDLOOP.

    IF go_remote_alv IS BOUND.
      go_remote_alv->refresh( ).
    ENDIF.

    IF go_remote_html IS BOUND.
      go_remote_html->do_refresh(
        EXCEPTIONS cntl_error = 1
                   OTHERS     = 2 ).
    ENDIF.
  ENDMETHOD.


  METHOD register_realtime.
    DATA: lo_realtime   TYPE REF TO /gpios/if_pbl_realtime,
          lt_controller TYPE /gpios/if_pbl_types=>ty_t_controller,
          lt_cb_types   TYPE /gpios/if_pbl_types=>ty_t_cb_types.

    lo_realtime = /gpios/cl_pbl_realtime=>get_instance( iv_rt_type = /gpios/if_pbl_realtime=>gc_rt_type_html_socket ).

    SET HANDLER on_realtime_received FOR lo_realtime.

    APPEND /gpios/if_pbl_ctrl_manager~go_remote_controller TO lt_controller.

    CASE /gpios/if_pbl_ctrl_manager~gv_data_type.
      WHEN /gpios/if_pbl_controller=>gc_data_type_io_units.
        APPEND /gpios/if_pbl_callback=>gc_cb_type_io_change TO lt_cb_types.
        APPEND /gpios/if_pbl_callback=>gc_cb_type_ir_change TO lt_cb_types.
      WHEN /gpios/if_pbl_controller=>gc_data_type_components.
        APPEND /gpios/if_pbl_callback=>gc_cb_type_io_assign_change TO lt_cb_types.
      WHEN OTHERS.
        APPEND /gpios/if_pbl_callback=>gc_cb_type_io_touch TO lt_cb_types.
        APPEND /gpios/if_pbl_callback=>gc_cb_type_picking_change TO lt_cb_types.
    ENDCASE.
    TRY.
        lo_realtime->register( it_controller = lt_controller
                               it_cb_types   = lt_cb_types ).
      CATCH /gpios/cx_pbl.
        RETURN.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
