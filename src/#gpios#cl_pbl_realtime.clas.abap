class /GPIOS/CL_PBL_REALTIME definition
  public
  create protected .

public section.

  interfaces /GPIOS/IF_PBL_REALTIME .

  types:
    ty_t_rt_data TYPE /gpios/if_pbl_realtime=>ty_t_rt_data .

  class-data GV_BINARY_MESSAGE type XSTRING .
  class-data GT_RT_DATA type TY_T_RT_DATA read-only .

  class-methods DESERIALIZE
    importing
      !IV_BINARY type XSTRING
    exporting
      !EO_RT_DATA type ref to /GPIOS/CL_PBL_RT_DATA .
  methods SERIALIZE
    importing
      !IO_RT_DATA type ref to /GPIOS/CL_PBL_RT_DATA
    exporting
      !EX_BINARY type XSTRING .
  class-methods GET_INSTANCE
    importing
      !IV_RT_TYPE type /GPIOS/PBL_RT_TYPE
    returning
      value(RO_INSTANCE) type ref to /GPIOS/IF_PBL_REALTIME .
  methods CONSTRUCTOR
    importing
      !IV_RT_TYPE type /GPIOS/PBL_RT_TYPE .
  class-methods PUSH_RT_DATA_STACK
    importing
      !IO_RT_DATA type ref to /GPIOS/CL_PBL_RT_DATA .
  class-methods POP_RT_DATA_STACK .
  class-methods CLEAR_DATA_STACK .
protected section.

  types:
    BEGIN OF TY_INSTANCE_KEY,
          rt_type TYPE /gpios/pbl_rt_type,
    END OF   ty_instance_key .
  types:
    BEGIN OF ty_instance.
            INCLUDE TYPE ty_instance_key as key.
            TYPES: instance TYPE REF TO /gpios/if_pbl_realtime,
    END OF ty_instance .
  types:
    ty_t_instances TYPE HASHED TABLE OF ty_instance WITH UNIQUE KEY key .

  class-data GT_INSTANCES type TY_T_INSTANCES .
private section.
ENDCLASS.



CLASS /GPIOS/CL_PBL_REALTIME IMPLEMENTATION.


  METHOD /gpios/if_pbl_realtime~receive.
  ENDMETHOD.


  METHOD /gpios/if_pbl_realtime~register.
  ENDMETHOD.


  METHOD /gpios/if_pbl_realtime~send.
  ENDMETHOD.


  METHOD /gpios/if_pbl_realtime~unregister.
  ENDMETHOD.


  METHOD clear_data_stack.
    CLEAR: gt_rt_data.
  ENDMETHOD.


  METHOD constructor.
    /gpios/if_pbl_realtime~gv_rt_type = iv_rt_type.
  ENDMETHOD.


  METHOD deserialize.
    DATA: lo_json_writer TYPE REF TO cl_sxml_string_writer.

    CLEAR: eo_rt_data.

    CALL TRANSFORMATION id SOURCE XML    iv_binary
                                  RESULT rt_data = eo_rt_data.

  ENDMETHOD.


  METHOD get_instance.

    DATA: ls_instance LIKE LINE OF gt_instances,
          lo_object   TYPE REF TO object,
          ls_rt       LIKE LINE OF /gpios/cl_pbl_settings_core=>instance->/gpios/pbl_rt .

    ls_instance-key-rt_type = iv_rt_type.

    READ TABLE gt_instances WITH TABLE KEY key = ls_instance-key
                            INTO ls_instance TRANSPORTING instance.
    IF sy-subrc <> 0.
      READ TABLE /gpios/cl_pbl_settings_core=>instance->/gpios/pbl_rt
           WITH TABLE KEY rt_type = iv_rt_type
           INTO ls_rt TRANSPORTING clsname.

      CREATE OBJECT ls_instance-instance
             TYPE (ls_rt-clsname)
             EXPORTING
                iv_rt_type    = iv_rt_type.
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


  METHOD pop_rt_data_stack.

    DELETE gt_rt_data INDEX 1.

  ENDMETHOD.


  METHOD push_rt_data_stack.

    INSERT io_rt_data INTO gt_rt_data INDEX 1.

  ENDMETHOD.


  METHOD serialize.
    DATA: lo_json_writer TYPE REF TO cl_sxml_string_writer.

    CLEAR: ex_binary.

    lo_json_writer = cl_sxml_string_writer=>create( type = if_sxml=>co_xt_json ).
    CALL TRANSFORMATION id SOURCE rt_data = io_rt_data
                           RESULT XML lo_json_writer.

    ex_binary = lo_json_writer->get_output( ).

  ENDMETHOD.
ENDCLASS.
