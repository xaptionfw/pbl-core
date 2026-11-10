class /GPIOS/CL_PBL_RT_HTML_SOCKET definition
  public
  inheriting from /GPIOS/CL_PBL_REALTIME
  create protected

  global friends /GPIOS/IF_PBL_REALTIME .

public section.

  data GO_HTML_VIEWER type ref to CL_GUI_HTML_VIEWER read-only .
  data GO_DOCKING_CONTAINER type ref to CL_GUI_DOCKING_CONTAINER read-only .
  constants GC_DOCUMENT_ID type W3OBJID value '/GPIOS/PBL_RT_HTML_SOCKET'. "#EC NOTEXT
  data GV_URL type URL read-only .

  methods /GPIOS/IF_PBL_REALTIME~REGISTER
    redefinition .
  methods /GPIOS/IF_PBL_REALTIME~UNREGISTER
    redefinition .
protected section.

  constants GC_QUERY_DATA_SEPARATOR type CHAR1 value ','. "#EC NOTEXT

  type-pools CNHT .
  methods DESERIALIZE_POSTDATA
    importing
      !IT_POSTDATA type CNHT_POST_DATA_TAB
    returning
      value(RO_RT_DATA) type ref to /GPIOS/CL_PBL_RT_DATA
    raising
      /GPIOS/CX_PBL .
  interface /GPIOS/IF_PBL_TYPES load .
  methods GET_URL_QUERY_STRING
    importing
      !IT_CONTROLLER type /GPIOS/IF_PBL_TYPES=>TY_T_CONTROLLER optional
      !IT_CB_TYPES type /GPIOS/IF_PBL_TYPES=>TY_T_CB_TYPES optional
    returning
      value(RV_QUERY_STRING) type STRING
    raising
      /GPIOS/CX_PBL .
  methods ON_SAPEVENT
    for event SAPEVENT of CL_GUI_HTML_VIEWER
    importing
      !ACTION
      !FRAME
      !GETDATA
      !POSTDATA
      !QUERY_TABLE
      !SENDER .
private section.
ENDCLASS.



CLASS /GPIOS/CL_PBL_RT_HTML_SOCKET IMPLEMENTATION.


  METHOD /gpios/if_pbl_realtime~register.

    DATA: lt_events   TYPE cntl_simple_events,
          ls_event    TYPE cntl_simple_event,
          l_url_query TYPE string.

    CHECK /gpios/if_pbl_realtime~gv_registered = abap_false.

    IF go_docking_container IS INITIAL.
      CREATE OBJECT go_docking_container
        EXPORTING
          side      = cl_gui_docking_container=>dock_at_right
          extension = 0.
      CREATE OBJECT go_html_viewer
        EXPORTING
          parent             = go_docking_container
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

      ls_event-eventid    = go_html_viewer->m_id_sapevent.
      ls_event-appl_event = abap_true.
      APPEND ls_event TO lt_events.

      go_html_viewer->set_registered_events(
        EXPORTING events = lt_events ).

      SET HANDLER on_sapevent FOR go_html_viewer.

      l_url_query = get_url_query_string(
                            it_controller = it_controller
                            it_cb_types   = it_cb_types ).

      IF l_url_query IS NOT INITIAL .
        CONCATENATE 'pbl_rt_html_socket.htm' l_url_query INTO gv_url.
      ENDIF.

      go_html_viewer->load_html_document(
        EXPORTING
          document_id            = /gpios/cl_pbl_rt_html_socket=>gc_document_id
          document_url           = gv_url
        IMPORTING
          assigned_url           = gv_url
        EXCEPTIONS
          document_not_found     = 1
          dp_error_general       = 2
          dp_invalid_parameter   = 3
          html_syntax_notcorrect = 4
          OTHERS                 = 5 ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      go_html_viewer->show_url(
        EXPORTING
          url                    = gv_url
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
      go_docking_container->set_visible(
        EXPORTING
          visible           = abap_false
        EXCEPTIONS
          cntl_error        = 1
          cntl_system_error = 2
          OTHERS            = 3 ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.

    /gpios/if_pbl_realtime~gv_registered = abap_true.

  ENDMETHOD.


  METHOD /gpios/if_pbl_realtime~unregister.
    CHECK NOT /gpios/if_pbl_realtime~gv_registered IS INITIAL.
    IF go_html_viewer IS BOUND.
      go_html_viewer->close_document( ).
      FREE go_html_viewer.
    ENDIF.
    IF go_docking_container IS BOUND.
      go_docking_container->free( ).
      FREE go_docking_container.
    ENDIF.
    CLEAR: /gpios/if_pbl_realtime~gv_registered.
  ENDMETHOD.


  METHOD deserialize_postdata.

    DATA: l_offset        TYPE i,
          l_length        TYPE i,
          l_part          TYPE string,
          l_controller    TYPE string,
          l_ip            TYPE rfcipv6addr,
          l_cb_string     TYPE string,
          l_cb_data       TYPE string,
          lo_controller   TYPE REF TO /gpios/if_pbl_controller,
          ls_cb           LIKE LINE OF /gpios/cl_pbl_settings_core=>instance->/gpios/pbl_cb,
          lo_http_handler TYPE REF TO /gpios/cl_pbl_http_handler.

    FIELD-SYMBOLS: <l_postdata> LIKE LINE OF it_postdata.

    CHECK it_postdata IS NOT INITIAL.

    CREATE OBJECT ro_rt_data.

    READ TABLE it_postdata INDEX 1 ASSIGNING <l_postdata>.

    FIND FIRST OCCURRENCE OF '&CB_DATA1=' IN <l_postdata>
         MATCH OFFSET l_offset
         MATCH LENGTH l_length.

    l_part = <l_postdata>(l_offset).

    FIND FIRST OCCURRENCE OF REGEX 'CONTROLLER=(.*)&CB_TYPE=(.*)'
               IN l_part
               SUBMATCHES l_controller
                          l_cb_string.

    READ TABLE /gpios/cl_pbl_settings_core=>instance->/gpios/pbl_cb
         WITH KEY identificator = l_cb_string
         INTO ls_cb TRANSPORTING cb_type.

    ASSERT sy-subrc = 0.

    ro_rt_data->gv_cb_type = ls_cb-cb_type.

    CONCATENATE LINES OF it_postdata INTO l_cb_data.

    l_cb_data = l_cb_data+l_offset.

    REPLACE ALL OCCURRENCES OF REGEX '&CB_DATA\d{1,3}='
                               IN l_cb_data
                               WITH space.

    l_ip = l_controller.

    lo_controller = /gpios/cl_pbl_controller=>get_instance_for_ip( iv_ip = l_ip ).
    ro_rt_data->gs_controller_data = lo_controller->gs_data.

    CREATE OBJECT lo_http_handler.
    lo_http_handler->deserialize_callback_data(
                               EXPORTING  iv_json    = l_cb_data
                                          iv_cb_type = ro_rt_data->gv_cb_type
                               IMPORTING  er_cb_data = ro_rt_data->gv_cb_data ).

  ENDMETHOD.


  METHOD get_url_query_string.

    DATA: lo_controller       LIKE LINE OF it_controller,
          l_ip                TYPE string,
          l_cb_type           LIKE LINE OF it_cb_types,
          l_controller_string TYPE string,
          l_cb_string         TYPE string,
          ls_cb               LIKE LINE OF /gpios/cl_pbl_settings_core=>instance->/gpios/pbl_cb.

    LOOP AT it_controller INTO lo_controller.
      l_ip = lo_controller->get_ip( ).
      IF l_controller_string IS INITIAL.
        l_controller_string = l_ip.
      ELSE.
        CONCATENATE l_controller_string l_ip
                INTO l_controller_string
                SEPARATED BY gc_query_data_separator.
      ENDIF.
    ENDLOOP.

    IF l_controller_string IS NOT INITIAL.
      CONCATENATE 'controller=' l_controller_string INTO rv_query_string.
    ENDIF.

    LOOP AT it_cb_types INTO l_cb_type.
      READ TABLE /gpios/cl_pbl_settings_core=>instance->/gpios/pbl_cb
           WITH TABLE KEY cb_type = l_cb_type
           INTO ls_cb TRANSPORTING identificator.

      IF l_cb_string IS INITIAL.
        l_cb_string = ls_cb-identificator.
      ELSE.
        CONCATENATE l_cb_string ls_cb-identificator INTO l_cb_string SEPARATED BY gc_query_data_separator.
      ENDIF.
    ENDLOOP.

    IF l_cb_string IS NOT INITIAL.
      CONCATENATE 'handler=' l_cb_string INTO l_cb_string.
    ENDIF.

    IF l_cb_string IS NOT INITIAL AND rv_query_string IS NOT INITIAL.
      CONCATENATE rv_query_string '&' INTO rv_query_string.
    ENDIF.

    CONCATENATE rv_query_string l_cb_string INTO rv_query_string.

    IF rv_query_string IS NOT INITIAL.
      CONCATENATE '?' rv_query_string INTO rv_query_string.
    ENDIF.

  ENDMETHOD.


  METHOD on_sapevent.

    DATA: lt_rt_data  TYPE /gpios/if_pbl_realtime=>ty_t_rt_data,
          lo_realtime LIKE LINE OF lt_rt_data.

    TRY.
        lo_realtime = deserialize_postdata( EXPORTING it_postdata = postdata ).
      CATCH /gpios/cx_pbl.
        RETURN.
    ENDTRY.
    CHECK lo_realtime IS NOT INITIAL.

    APPEND lo_realtime TO lt_rt_data.

    RAISE EVENT /gpios/if_pbl_realtime~received
      EXPORTING
        et_rt_data = lt_rt_data.

  ENDMETHOD.
ENDCLASS.
