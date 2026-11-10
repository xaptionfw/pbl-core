class /GPIOS/CX_PBL_CORE definition
  public
  inheriting from /GPIOS/CX_PBL
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !SERNR type /GPIOS/PBL_SERNR optional
      !MSGTY type MSGTY optional
      !MSGV1 type SYMSGV optional
      !MSGV2 type SYMSGV optional
      !MSGV3 type SYMSGV optional
      !MSGV4 type SYMSGV optional
      !MSG_TEXT type STRING optional
      !CONTROLLER type ref to /GPIOS/IF_PBL_CONTROLLER optional .
  class-methods CONTROLLER_NOT_EXISTS
    importing
      !IV_SERNR type /GPIOS/PBL_SERNR
    raising
      /GPIOS/CX_PBL_CORE .
  class-methods CONTROLLER_NOT_ACCESSIBLE
    importing
      !IO_CONTROLLER type ref to /GPIOS/IF_PBL_CONTROLLER
      !IV_HOST type CLIKE
    raising
      /GPIOS/CX_PBL_CORE .
  class-methods DATA_TRANSFER_FAILED
    importing
      !IO_CONTROLLER type ref to /GPIOS/IF_PBL_CONTROLLER
      !IV_CODE type I
      !IV_REASON type CLIKE
    raising
      /GPIOS/CX_PBL .
  class-methods IO_UNIT_NOT_EXIST
    importing
      !IV_SERNR type /GPIOS/PBL_SERNR
      !IV_UID type /GPIOS/PBL_LEDNO
    raising
      /GPIOS/CX_PBL_CORE .
  class-methods BOM_ITM_NOT_EXISTS
    importing
      !IO_CONTROLLER type ref to /GPIOS/IF_PBL_CONTROLLER
      !IV_BAUGR type BAUGR
      !IV_COMM_TYPE type /GPIOS/PBL_COMMUNICATION_TYPE
      !IV_IDNRK type IDNRK
    raising
      /GPIOS/CX_PBL_CORE .
  class-methods BOM_NOT_EXISTS
    importing
      !IO_CONTROLLER type ref to /GPIOS/IF_PBL_CONTROLLER
      !IV_BAUGR type BAUGR
      !IV_COMM_TYPE type /GPIOS/PBL_COMMUNICATION_TYPE
    raising
      /GPIOS/CX_PBL_CORE .
protected section.
private section.
ENDCLASS.



CLASS /GPIOS/CX_PBL_CORE IMPLEMENTATION.


  METHOD bom_itm_not_exists.
    CASE iv_comm_type.
      WHEN /gpios/if_pbl_controller=>gc_comm_type_local.
        MESSAGE e018 WITH iv_baugr iv_idnrk INTO msg_text.
      WHEN /gpios/if_pbl_controller=>gc_comm_type_remote.
        MESSAGE e019 WITH iv_baugr iv_idnrk io_controller->gs_data-sernr INTO msg_text.
    ENDCASE.
    TRY.
        /gpios/cx_pbl_core=>raise_message_exception(
            sernr = io_controller->gs_data-sernr ).
      CATCH /gpios/cx_pbl.
        RETURN.
    ENDTRY.
  ENDMETHOD.


  METHOD bom_not_exists.
    CASE iv_comm_type.
      WHEN /gpios/if_pbl_controller=>gc_comm_type_local.
        MESSAGE e010 WITH iv_baugr io_controller->gs_data-sernr INTO msg_text.
      WHEN /gpios/if_pbl_controller=>gc_comm_type_remote.
        MESSAGE e011 WITH iv_baugr io_controller->gs_data-sernr INTO msg_text.
    ENDCASE.
    TRY.
        /gpios/cx_pbl_core=>raise_message_exception(
            sernr = io_controller->gs_data-sernr ).
      CATCH /gpios/cx_pbl.
        RETURN.
    ENDTRY.
  ENDMETHOD.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
SERNR = SERNR
MSGTY = MSGTY
MSGV1 = MSGV1
MSGV2 = MSGV2
MSGV3 = MSGV3
MSGV4 = MSGV4
MSG_TEXT = MSG_TEXT
CONTROLLER = CONTROLLER
.
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.


  METHOD controller_not_accessible.

    MESSAGE e002 WITH io_controller->gs_data-sernr iv_host  INTO msg_text.
    TRY.
        /gpios/cx_pbl_core=>raise_message_exception(
            sernr      = io_controller->gs_data-sernr
            controller = io_controller ).
      CATCH /gpios/cx_pbl.
        RETURN.
    ENDTRY.
  ENDMETHOD.


  METHOD controller_not_exists.

    MESSAGE e001 WITH iv_sernr INTO msg_text.

    TRY.
        /gpios/cx_pbl_core=>raise_message_exception(
            sernr = iv_sernr ).
      CATCH /gpios/cx_pbl.
        RETURN.
    ENDTRY.
  ENDMETHOD.


  METHOD data_transfer_failed.

*Datenübertragung an Controller &1 fehlgeschlagen (Status: &2, Code: &3)

    MESSAGE e003 WITH io_controller->gs_data-sernr iv_reason iv_code INTO msg_text.

    CALL METHOD /gpios/cx_pbl_core=>raise_message_exception
      EXPORTING
        sernr      = io_controller->gs_data-sernr
        controller = io_controller.

  ENDMETHOD.


  METHOD io_unit_not_exist.

    MESSAGE e004 WITH iv_uid iv_sernr INTO msg_text.
    TRY.
        /gpios/cx_pbl_core=>raise_message_exception(
            sernr = iv_sernr ).
      CATCH /gpios/cx_pbl.
        RETURN.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
