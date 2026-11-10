class /GPIOS/CL_PBL_IO_UNIT definition
  public
  create protected .

public section.

  interfaces /GPIOS/IF_PBL_IO_UNIT .

  class-methods GET_INSTANCE
    importing
      !IO_CONTROLLER type ref to /GPIOS/IF_PBL_CONTROLLER
      !IV_UID type /GPIOS/PBL_LEDNO
      !IS_DATA type /GPIOS/PBL_CB_IO optional
    returning
      value(RO_INSTANCE) type ref to /GPIOS/IF_PBL_IO_UNIT
    raising
      /GPIOS/CX_PBL .
protected section.

  types:
    BEGIN OF TY_INSTANCE_KEY,
          controller TYPE REF TO /gpios/if_pbl_controller,
          uid TYPE /GPIOS/PBL_LEDNO,
         END OF   ty_instance_key .
  types:
    BEGIN OF ty_instance.
            INCLUDE TYPE ty_instance_key as key.
            TYPES: instance TYPE REF TO /gpios/if_pbl_io_unit,
            END OF ty_instance .
  types:
    ty_t_instances TYPE HASHED TABLE OF ty_instance WITH UNIQUE KEY key .

  class-data GT_INSTANCES type TY_T_INSTANCES .

  methods CONSTRUCTOR
    importing
      !IO_CONTROLLER type ref to /GPIOS/IF_PBL_CONTROLLER
      !IV_UID type /GPIOS/PBL_LEDNO
      !IS_DATA type /GPIOS/PBL_CB_IO optional .
private section.
ENDCLASS.



CLASS /GPIOS/CL_PBL_IO_UNIT IMPLEMENTATION.


  METHOD /gpios/if_pbl_io_unit~set_color.

    TYPES: BEGIN OF ty_color,
             uid TYPE /gpios/pbl_ledno,
             r TYPE i,
             g TYPE i,
             b TYPE i,
           END OF   ty_color.

    DATA: lo_controller TYPE REF TO /gpios/cl_pbl_controller,
          ls_color TYPE ty_color.

    TRY.
        lo_controller ?= /gpios/if_pbl_io_unit~controller.
      CATCH cx_sy_move_cast_error.
        RETURN. ">>>>>>>
    ENDTRY.

    IF iv_r = abap_true.
      ls_color-r = 1.
    ENDIF.

    IF iv_g = abap_true.
      ls_color-g = 1.
    ENDIF.

    IF iv_b = abap_true.
      ls_color-b = 1.
    ENDIF.

    ls_color-uid = /gpios/if_pbl_io_unit~gs_data-io_uid.

    lo_controller->trigger_action( iv_action_type = /gpios/if_pbl_controller=>gc_act_type_set_color
                                   ia_data        = ls_color ).

  ENDMETHOD.


  METHOD /gpios/if_pbl_io_unit~toggle_all_colors.

    TYPES: BEGIN OF ty_color,
             uid TYPE /gpios/pbl_ledno,
           END OF   ty_color.

    DATA: lo_controller TYPE REF TO /gpios/cl_pbl_controller,
          ls_color TYPE ty_color.

    TRY.
        lo_controller ?= /gpios/if_pbl_io_unit~controller.
      CATCH cx_sy_move_cast_error.
        RETURN. ">>>>>>>
    ENDTRY.

    ls_color-uid = /gpios/if_pbl_io_unit~gs_data-io_uid.

    lo_controller->trigger_action( iv_action_type = /gpios/if_pbl_controller=>gc_act_type_toggle_all_colors
                                   ia_data        = ls_color ).

  ENDMETHOD.


  METHOD /gpios/if_pbl_io_unit~toggle_color.

    TYPES: BEGIN OF ty_color,
             uid TYPE /gpios/pbl_ledno,
             color TYPE char1,
           END OF   ty_color.

    DATA: lo_controller TYPE REF TO /gpios/cl_pbl_controller,
          ls_color TYPE ty_color.

    TRY.
        lo_controller ?= /gpios/if_pbl_io_unit~controller.
      CATCH cx_sy_move_cast_error.
        RETURN. ">>>>>>>
    ENDTRY.

    ls_color-color = iv_color.

    ls_color-uid = /gpios/if_pbl_io_unit~gs_data-io_uid.

    lo_controller->trigger_action( iv_action_type = /gpios/if_pbl_controller=>gc_act_type_toggle_color
                                   ia_data        = ls_color ).

  ENDMETHOD.


  METHOD constructor.

    /gpios/if_pbl_io_unit~controller = io_controller.

    /gpios/if_pbl_io_unit~gs_data = is_data.

    /gpios/if_pbl_io_unit~gs_data-io_uid = iv_uid.

  ENDMETHOD.


  METHOD get_instance.

    DATA: ls_instance LIKE LINE OF gt_instances,
          lo_object TYPE REF TO object.

    ls_instance-key-controller = io_controller.
    ls_instance-key-uid = iv_uid.

    READ TABLE gt_instances WITH TABLE KEY key = ls_instance-key
                            INTO ls_instance TRANSPORTING instance.
    IF sy-subrc <> 0.
      IF /gpios/cl_pbl_settings_core=>instance->/gpios/pbl_set-clsname_io_unit IS INITIAL.
        CREATE OBJECT ls_instance-instance TYPE /gpios/cl_pbl_io_unit
          EXPORTING
            io_controller = io_controller
            iv_uid        = iv_uid
            is_data       = is_data.
      ELSE.
        CREATE OBJECT ls_instance-instance
               TYPE (/gpios/cl_pbl_settings_core=>instance->/gpios/pbl_set-clsname_io_unit)
               EXPORTING
                  io_controller = io_controller
                  iv_uid        = iv_uid
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
