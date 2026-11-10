class /GPIOS/CL_PBL_BOM_ITEM definition
  public
  create protected .

public section.

  interfaces /GPIOS/IF_PBL_BOM_ITEM .

  class-methods GET_INSTANCE
    importing
      !IO_BOM type ref to /GPIOS/IF_PBL_BOM
      !IV_IDNRK type IDNRK
      !IS_DATA type /GPIOS/PBL_BI optional
    returning
      value(RO_INSTANCE) type ref to /GPIOS/IF_PBL_BOM_ITEM
    raising
      /GPIOS/CX_PBL .
  class-methods FREE_INSTANCES .
protected section.

  types:
    BEGIN OF ty_instance_key,
          bom    TYPE REF TO /gpios/if_pbl_bom,
          idnrk  TYPE idnrk,
    END OF   ty_instance_key .
  types:
    BEGIN OF ty_instance.
  INCLUDE TYPE ty_instance_key AS key.
  TYPES: instance TYPE REF TO /gpios/if_pbl_bom_item,
  END OF ty_instance .
  types:
    ty_t_instances TYPE HASHED TABLE OF ty_instance WITH UNIQUE KEY key .

  class-data GT_INSTANCES type TY_T_INSTANCES .

  methods CONSTRUCTOR
    importing
      !IO_BOM type ref to /GPIOS/IF_PBL_BOM
      !IV_IDNRK type IDNRK
      !IS_DATA type /GPIOS/PBL_BI optional .
private section.
ENDCLASS.



CLASS /GPIOS/CL_PBL_BOM_ITEM IMPLEMENTATION.


  METHOD /gpios/if_pbl_bom_item~get_data.

    DATA: lt_bom_items TYPE /gpios/if_pbl_types=>ty_t_bi.

    FIELD-SYMBOLS: <ls_bom_itm> LIKE LINE OF lt_bom_items.

    IF iv_bypass_buffer = abap_false AND /gpios/if_pbl_bom_item~gs_data IS NOT INITIAL.
      rs_data = /gpios/if_pbl_bom_item~gs_data.
      RETURN. ">>>>>>>>>>
    ENDIF.

    /gpios/if_pbl_bom_item~bom->controller->load_bom_items(
      EXPORTING iv_comm_type = iv_comm_type
                iv_ping      = iv_ping
      IMPORTING et_bom_items = lt_bom_items ).

    READ TABLE lt_bom_items WITH TABLE KEY baugr = /gpios/if_pbl_bom_item~bom->gs_data-baugr
                                           idnrk = /gpios/if_pbl_bom_item~gs_data-idnrk
                              ASSIGNING <ls_bom_itm>.
    IF sy-subrc = 0.
      rs_data = /gpios/if_pbl_bom_item~gs_data = <ls_bom_itm>.
    ELSE.
      /gpios/cx_pbl_core=>bom_itm_not_exists(
        EXPORTING
          io_controller = /gpios/if_pbl_bom_item~bom->controller
          iv_baugr      = /gpios/if_pbl_bom_item~bom->gs_data-baugr
          iv_idnrk      = /gpios/if_pbl_bom_item~gs_data-idnrk
          iv_comm_type  = iv_comm_type ).
    ENDIF.

  ENDMETHOD.


  METHOD /gpios/if_pbl_bom_item~get_io_unit.

    IF iv_bypass_buffer = abap_false AND /gpios/if_pbl_bom_item~io_unit IS NOT INITIAL.
      ro_io_unit = /gpios/if_pbl_bom_item~io_unit.
      RETURN. ">>>>>>>>>>
    ENDIF.

    IF iv_bypass_buffer = abap_false AND /gpios/if_pbl_bom_item~gs_data-id IS NOT INITIAL.
      /gpios/if_pbl_bom_item~io_unit = /gpios/cl_pbl_io_unit=>get_instance(
          io_controller = /gpios/if_pbl_bom_item~bom->controller
          iv_uid        = /gpios/if_pbl_bom_item~gs_data-id ).
      ro_io_unit = /gpios/if_pbl_bom_item~io_unit.
      RETURN. ">>>>>>>>>>
    ENDIF.

    /gpios/if_pbl_bom_item~get_data(
        iv_bypass_buffer = abap_true
        iv_comm_type     = /gpios/if_pbl_controller=>gc_comm_type_remote
        iv_ping          = abap_false ).

    /gpios/if_pbl_bom_item~io_unit = /gpios/cl_pbl_io_unit=>get_instance(
        io_controller = /gpios/if_pbl_bom_item~bom->controller
        iv_uid        = /gpios/if_pbl_bom_item~gs_data-id ).

    ro_io_unit = /gpios/if_pbl_bom_item~io_unit.

  ENDMETHOD.


  METHOD /gpios/if_pbl_bom_item~toggle_bom_itm.

    TYPES: BEGIN OF ty_bomitm,
              baugr TYPE matnr,
              idnrk TYPE idnrk,
           END OF   ty_bomitm.

    DATA: lo_controller TYPE REF TO /gpios/cl_pbl_controller,
          ls_bomitm TYPE ty_bomitm.

    TRY.
        lo_controller ?= /gpios/if_pbl_bom_item~bom->controller.
      CATCH cx_sy_move_cast_error.
        RETURN. ">>>>>>>
    ENDTRY.

    ls_bomitm-baugr = /gpios/if_pbl_bom_item~gs_data-baugr.
    ls_bomitm-idnrk = /gpios/if_pbl_bom_item~gs_data-idnrk.

    lo_controller->trigger_action( iv_action_type = /gpios/if_pbl_controller=>gc_act_type_toggle_bom_itm_io
                                   ia_data        = ls_bomitm ).

  ENDMETHOD.


  METHOD constructor.

    /gpios/if_pbl_bom_item~bom = io_bom.

    /gpios/if_pbl_bom_item~gs_data = is_data.

    /gpios/if_pbl_bom_item~gs_data-baugr = io_bom->gs_data-baugr.
    /gpios/if_pbl_bom_item~gs_data-idnrk = iv_idnrk.

  ENDMETHOD.


  METHOD free_instances.
    CLEAR: gt_instances.
  ENDMETHOD.


  METHOD get_instance.

    DATA: ls_instance LIKE LINE OF gt_instances,
          lo_object TYPE REF TO object.

    ls_instance-key-bom = io_bom.
    ls_instance-key-idnrk = iv_idnrk.

    READ TABLE gt_instances WITH TABLE KEY key = ls_instance-key
                            INTO ls_instance TRANSPORTING instance.
    IF sy-subrc <> 0.
      IF /gpios/cl_pbl_settings_core=>instance->/gpios/pbl_set-clsname_bom_item IS INITIAL.
        CREATE OBJECT ls_instance-instance TYPE /gpios/cl_pbl_bom_item
          EXPORTING
            io_bom   = io_bom
            iv_idnrk = iv_idnrk
            is_data  = is_data.
      ELSE.
        CREATE OBJECT ls_instance-instance
               TYPE (/gpios/cl_pbl_settings_core=>instance->/gpios/pbl_set-clsname_bom_item)
               EXPORTING
                  io_bom   = io_bom
                  iv_idnrk = iv_idnrk
                  is_data  = is_data.
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
