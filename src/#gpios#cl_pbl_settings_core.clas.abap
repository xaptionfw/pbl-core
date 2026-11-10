class /GPIOS/CL_PBL_SETTINGS_CORE definition
  public
  inheriting from /GPIOS/CL_PBL_SETTINGS
  create protected

  global friends /GPIOS/CL_PBL_SETTINGS .

*"* public components of class /GPIOS/CL_PBL_SETTINGS_CORE
*"* do not include other source files here!!!
public section.

  interfaces /GPIOS/IF_PBL_SETTINGS_CORE .

  class-data INSTANCE type ref to /GPIOS/IF_PBL_SETTINGS_CORE read-only .

  class-methods CLASS_CONSTRUCTOR .
  class-methods RESET_INSTANCE .
  class-methods SET_INSTANCE
    importing
      !IV_INSTANCE like INSTANCE .
protected section.

*"* protected components of class /GPIOS/CL_PBL_SETTINGS_CORE
*"* do not include other source files here!!!
  class-data INSTANCE_INT type ref to /GPIOS/IF_PBL_SETTINGS_CORE .

*    CONSTANTS /scbag/sks_o_order TYPE string VALUE `EDITORDER OBJTYPE` ##NO_TEXT.
  methods CONSTRUCTOR .
  PRIVATE SECTION.
*"* private components of class /GPIOS/CL_PBL_SETTINGS_CORE
*"* do not include other source files here!!!
ENDCLASS.



CLASS /GPIOS/CL_PBL_SETTINGS_CORE IMPLEMENTATION.


  METHOD class_constructor.

    reset_instance( ).

    instance->/gpios/if_pbl_settings~load( ).

  ENDMETHOD.


  METHOD constructor.

    super->constructor( ).

    gv_main_interface = '/GPIOS/IF_PBL_SETTINGS_CORE'.

  ENDMETHOD.


  METHOD reset_instance.

    IF instance_int IS INITIAL.
      CREATE OBJECT instance_int TYPE /gpios/cl_pbl_settings_core.
    ENDIF.

    set_instance( iv_instance = instance_int ).

  ENDMETHOD.


  METHOD set_instance.

    DATA: lo_old_instance LIKE instance.

    ASSERT iv_instance IS NOT INITIAL.

    IF instance <> iv_instance.
      lo_old_instance = instance.
    ENDIF.

    instance = iv_instance.

    IF lo_old_instance IS NOT INITIAL.
      RAISE EVENT /gpios/if_pbl_settings~instance_changed
        EXPORTING
          eo_old_instance = lo_old_instance
          eo_new_instance = iv_instance.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
