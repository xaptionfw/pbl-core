class /GPIOS/CL_PBL_RT_TIMER definition
  public
  inheriting from /GPIOS/CL_PBL_REALTIME
  create protected

  global friends /GPIOS/IF_PBL_REALTIME .

public section.

  interfaces IF_AMC_MESSAGE_RECEIVER .
  interfaces IF_AMC_MESSAGE_RECEIVER_BINARY .

  constants GC_AMC_APPLICATION_ID type AMC_APPLICATION_ID value '/XAPTION/PBL_REALTIME'. "#EC NOTEXT
  constants GC_AMC_CHANNEL_CALLBACK type AMC_CHANNEL_ID value '/callback'. "#EC NOTEXT
  data GO_TIMER type ref to CL_GUI_TIMER .

  class-methods TIMER_CALLBACK
    importing
      !P_TASK type CLIKE .

  methods /GPIOS/IF_PBL_REALTIME~RECEIVE
    redefinition .
  methods /GPIOS/IF_PBL_REALTIME~REGISTER
    redefinition .
  methods /GPIOS/IF_PBL_REALTIME~SEND
    redefinition .
protected section.

  type-pools ABAP .
  methods ENQUEUE_LOOP
    returning
      value(RV_ACTIVE) type ABAP_BOOL .
  methods ON_TIMER_FINISHED
    for event FINISHED of CL_GUI_TIMER
    importing
      !SENDER .
  methods SEND_ENQUEUE_LOOP
    returning
      value(RV_ACTIVE) type ABAP_BOOL .
private section.
ENDCLASS.



CLASS /GPIOS/CL_PBL_RT_TIMER IMPLEMENTATION.


  METHOD /gpios/if_pbl_realtime~receive.

    DATA: lo_binary_message TYPE REF TO if_amc_message_consumer.

    CLEAR: ev_binary.

    lo_binary_message = cl_amc_channel_manager=>create_message_consumer(
         i_application_id = /gpios/cl_pbl_rt_timer=>gc_amc_application_id
         i_channel_id     = /gpios/cl_pbl_rt_timer=>gc_amc_channel_callback ).

    lo_binary_message->start_message_delivery( i_receiver =  me ).

    WAIT FOR MESSAGING CHANNELS
     UNTIL me->gv_binary_message IS NOT INITIAL.

    ev_binary = me->gv_binary_message.

  ENDMETHOD.


  METHOD /gpios/if_pbl_realtime~register.

*    CHECK /gpios/if_pbl_realtime~gv_registered = abap_false.
    IF go_timer IS INITIAL.
      CREATE OBJECT go_timer
        EXCEPTIONS
          error  = 1
          OTHERS = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        RETURN. ">>>>>
      ENDIF.

      go_timer->interval = 2.

      SET HANDLER on_timer_finished FOR go_timer.

      go_timer->run( ).
    ENDIF.

    CALL FUNCTION '/GPIOS/PBL_RT_REC_TIMER'
      STARTING NEW TASK 'TIMER'
      CALLING timer_callback ON END OF TASK.

    CALL FUNCTION 'DEQUEUE_/GPIOS/E_PBL_RTT'.

    /gpios/if_pbl_realtime~gv_registered = abap_true.

  ENDMETHOD.


  METHOD /gpios/if_pbl_realtime~send.

    DATA: lo_rt_data     TYPE REF TO /gpios/cl_pbl_rt_data,
    lv_binary      TYPE xstring,
    l_enqueued     TYPE abap_bool.

    FIELD-SYMBOLS: <la_cb_data> TYPE any.

    CREATE OBJECT lo_rt_data.

    CREATE DATA lo_rt_data->gv_cb_data LIKE iv_cb_data.

    ASSIGN lo_rt_data->gv_cb_data->* TO <la_cb_data>.

    <la_cb_data> = iv_cb_data.

    lo_rt_data->gv_cb_type = iv_cb_type.
    lo_rt_data->gs_controller_data = io_controller->gs_data.

    serialize( EXPORTING io_rt_data = lo_rt_data
               IMPORTING ex_binary  = lv_binary ).

    DATA: lo_binary_message TYPE REF TO if_amc_message_producer_binary.

    lo_binary_message ?= cl_amc_channel_manager=>create_message_producer(
                      i_application_id = gc_amc_application_id
                      i_channel_id     = gc_amc_channel_callback ).

    WHILE enqueue_loop( ) = abap_true.
      IF l_enqueued  = abap_false.
        l_enqueued  = abap_true.
      ENDIF.
      WAIT UP TO 1 SECONDS.
    ENDWHILE.

    lo_binary_message->send( i_message = lv_binary ).

  ENDMETHOD.


  METHOD enqueue_loop.

    DATA: lt_enq TYPE STANDARD TABLE OF seqg3.

    rv_active = abap_true.

    CALL FUNCTION 'ENQUEUE_READ'
      EXPORTING
        gname                 = '/GPIOS/E_PBL_RT'
        guname                = space
      TABLES
        enq                   = lt_enq
      EXCEPTIONS
        communication_failure = 1
        system_failure        = 2
        OTHERS                = 3.

    CHECK sy-subrc = 0 AND lt_enq IS INITIAL.

    CLEAR: rv_active.

  ENDMETHOD.


  METHOD if_amc_message_receiver_binary~receive.
    gv_binary_message = i_message.
  ENDMETHOD.


  METHOD on_timer_finished.

    DATA: lt_rt_data LIKE /gpios/cl_pbl_rt_timer=>gt_rt_data.

    IF /gpios/cl_pbl_rt_timer=>gt_rt_data IS NOT INITIAL.
      TRY.
          /gpios/if_pbl_realtime~register( ).
        CATCH /gpios/cx_pbl.
          RETURN.
      ENDTRY.
      lt_rt_data = /gpios/cl_pbl_rt_timer=>gt_rt_data.
      clear_data_stack( ).
      RAISE EVENT /gpios/if_pbl_realtime~received
        EXPORTING et_rt_data = lt_rt_data.
    ENDIF.

    go_timer->run( EXCEPTIONS error  = 1
                              OTHERS = 2 ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDMETHOD.


  METHOD send_enqueue_loop.

    DATA: lt_enq TYPE STANDARD TABLE OF seqg3.

    rv_active = abap_true.

    CALL FUNCTION 'ENQUEUE_READ'
      EXPORTING
        gname                 = '/GPIOS/E_PBL_RT'
        guname                = space
      TABLES
        enq                   = lt_enq
      EXCEPTIONS
        communication_failure = 1
        system_failure        = 2
        OTHERS                = 3.

    CHECK sy-subrc = 0 AND lt_enq IS INITIAL.

    CLEAR: rv_active.


  ENDMETHOD.


  METHOD timer_callback.

    DATA: lv_binary   TYPE xstring,
          lo_rt_data  TYPE REF TO /gpios/cl_pbl_rt_data,
          lo_realtime TYPE REF TO /gpios/if_pbl_realtime.

    CHECK p_task = 'TIMER'.

    CALL FUNCTION 'ENQUEUE_/GPIOS/E_PBL_RTT'
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.

    CHECK sy-subrc = 0.

    RECEIVE RESULTS FROM FUNCTION '/GPIOS/PBL_RT_REC_TIMER'
            IMPORTING ev_binary = lv_binary.

    deserialize( EXPORTING iv_binary  = lv_binary
                 IMPORTING eo_rt_data = lo_rt_data ).



    push_rt_data_stack( EXPORTING io_rt_data = lo_rt_data ).

  ENDMETHOD.
ENDCLASS.
