class /GPIOS/CL_PBL_BOM definition
  public
  create protected .

public section.

  interfaces /GPIOS/IF_PBL_BOM .

  class-methods GET_INSTANCE
    importing
      !IO_CONTROLLER type ref to /GPIOS/IF_PBL_CONTROLLER
      !IV_BAUGR type BAUGR
      !IS_DATA type /GPIOS/PBL_BH optional
    returning
      value(RO_INSTANCE) type ref to /GPIOS/IF_PBL_BOM
    raising
      /GPIOS/CX_PBL .
  class-methods FREE_INSTANCES .
protected section.

  types:
    BEGIN OF TY_INSTANCE_KEY,
          controller TYPE REF TO /gpios/if_pbl_controller,
          baugr TYPE baugr,
    END OF   ty_instance_key .
  types:
    BEGIN OF ty_instance.
            INCLUDE TYPE ty_instance_key as key.
            TYPES: instance TYPE REF TO /gpios/if_pbl_bom,
    END OF ty_instance .
  types:
    ty_t_instances TYPE HASHED TABLE OF ty_instance WITH UNIQUE KEY key .

  class-data GT_INSTANCES type TY_T_INSTANCES .

  methods CONSTRUCTOR
    importing
      !IO_CONTROLLER type ref to /GPIOS/IF_PBL_CONTROLLER
      !IV_BAUGR type BAUGR
      !IS_DATA type /GPIOS/PBL_BH optional .
private section.
ENDCLASS.



CLASS /GPIOS/CL_PBL_BOM IMPLEMENTATION.


  METHOD /gpios/if_pbl_bom~get_bom_items.
    DATA: lo_bom_item  LIKE LINE OF rt_bom_items,
          lt_bom_items TYPE /gpios/if_pbl_types=>ty_t_bi.

    FIELD-SYMBOLS: <ls_bom_item> LIKE LINE OF lt_bom_items.

    IF iv_bypass_buffer = abap_false AND /gpios/if_pbl_bom~bom_items IS NOT INITIAL.
      rt_bom_items = /gpios/if_pbl_bom~bom_items.
      RETURN. ">>>>>>>>>>
    ENDIF.

    CLEAR:/gpios/if_pbl_bom~bom_items.

    /gpios/if_pbl_bom~controller->load_bom_items(
      EXPORTING iv_comm_type = iv_comm_type
                iv_ping      = iv_ping
      IMPORTING et_bom_items = lt_bom_items ).

    LOOP AT lt_bom_items ASSIGNING <ls_bom_item>.
      lo_bom_item = /gpios/cl_pbl_bom_item=>get_instance(
                    io_bom   = me
                    iv_idnrk = <ls_bom_item>-idnrk
                    is_data  = <ls_bom_item> ).
      APPEND lo_bom_item TO /gpios/if_pbl_bom~bom_items.
    ENDLOOP.

    rt_bom_items = /gpios/if_pbl_bom~bom_items.

  ENDMETHOD.


  METHOD /gpios/if_pbl_bom~get_data.

    DATA: lt_bom_headers TYPE /gpios/if_pbl_types=>ty_t_bh.

    FIELD-SYMBOLS: <ls_bom_hdr> LIKE LINE OF lt_bom_headers.

    IF iv_bypass_buffer = abap_false AND /gpios/if_pbl_bom~gs_data IS NOT INITIAL.
      rs_data = /gpios/if_pbl_bom~gs_data.
      RETURN. ">>>>>>>>>>
    ENDIF.

    /gpios/if_pbl_bom~controller->load_bom_headers(
      EXPORTING iv_comm_type   = iv_comm_type
                iv_ping        = iv_ping
      IMPORTING et_bom_headers = lt_bom_headers ).

    READ TABLE lt_bom_headers WITH TABLE KEY baugr = /gpios/if_pbl_bom~gs_data-baugr
                              ASSIGNING <ls_bom_hdr>.
    IF sy-subrc = 0.
      rs_data = /gpios/if_pbl_bom~gs_data = <ls_bom_hdr>.
    ELSE.
      /gpios/cx_pbl_core=>bom_not_exists(
        EXPORTING
          io_controller = /gpios/if_pbl_bom~controller
          iv_baugr      = /gpios/if_pbl_bom~gs_data-baugr
          iv_comm_type  = iv_comm_type ).
    ENDIF.

  ENDMETHOD.


  METHOD /gpios/if_pbl_bom~start.

    TYPES: BEGIN OF ty_bom,
               baugr TYPE baugr,
               show_terminator TYPE /gpios/pbl_showterminator,
           END OF   ty_bom.

    DATA: lo_controller TYPE REF TO /gpios/cl_pbl_controller,
          ls_bom TYPE ty_bom.

    TRY.
        lo_controller ?= /gpios/if_pbl_bom~controller.
      CATCH cx_sy_move_cast_error.
        RETURN. ">>>>>>>
    ENDTRY.

    ls_bom-baugr = /gpios/if_pbl_bom~gs_data-baugr.
    ls_bom-show_terminator = iv_show_terminator.

    lo_controller->trigger_action( iv_action_type = /gpios/if_pbl_controller=>gc_act_type_start_bom
                                   ia_data        = ls_bom ).

  ENDMETHOD.


  METHOD /gpios/if_pbl_bom~stop.

    TYPES: BEGIN OF ty_bom,
               baugr TYPE baugr,
           END OF   ty_bom.

    DATA: lo_controller TYPE REF TO /gpios/cl_pbl_controller,
          ls_bom TYPE ty_bom.

    TRY.
        lo_controller ?= /gpios/if_pbl_bom~controller.
      CATCH cx_sy_move_cast_error.
        RETURN. ">>>>>>>
    ENDTRY.

    ls_bom-baugr = /gpios/if_pbl_bom~gs_data-baugr.

    lo_controller->trigger_action( iv_action_type = /gpios/if_pbl_controller=>gc_act_type_stop_bom
                                   ia_data        = ls_bom ).

  ENDMETHOD.


  METHOD constructor.

    /gpios/if_pbl_bom~controller = io_controller.

    /gpios/if_pbl_bom~gs_data = is_data.

    /gpios/if_pbl_bom~gs_data-baugr = iv_baugr.

  ENDMETHOD.


  METHOD free_instances.
    CLEAR: gt_instances.
    /gpios/cl_pbl_bom_item=>free_instances( ).
  ENDMETHOD.


  METHOD get_instance.

    DATA: ls_instance LIKE LINE OF gt_instances,
          lo_object TYPE REF TO object.

    ls_instance-key-controller = io_controller.
    ls_instance-key-baugr      = iv_baugr.

    READ TABLE gt_instances WITH TABLE KEY key = ls_instance-key
                            INTO ls_instance TRANSPORTING instance.
    IF sy-subrc <> 0.
      IF /gpios/cl_pbl_settings_core=>instance->/gpios/pbl_set-clsname_bom IS INITIAL.
        CREATE OBJECT ls_instance-instance TYPE /gpios/cl_pbl_bom
          EXPORTING
            io_controller = io_controller
            iv_baugr      = iv_baugr
            is_data       = is_data.
      ELSE.
        CREATE OBJECT ls_instance-instance
               TYPE (/gpios/cl_pbl_settings_core=>instance->/gpios/pbl_set-clsname_bom)
               EXPORTING
                  io_controller = io_controller
                  iv_baugr      = iv_baugr
                  is_data       = is_data.
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
ENDCLASS.
