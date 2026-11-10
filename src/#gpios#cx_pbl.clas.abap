class /GPIOS/CX_PBL definition
  public
  inheriting from CX_STATIC_CHECK
  create public .

public section.

  interfaces IF_T100_MESSAGE .

  data SERNR type /GPIOS/PBL_SERNR read-only .
  data MSGTY type MSGTY read-only .
  data MSGV1 type SYMSGV read-only .
  data MSGV2 type SYMSGV read-only .
  data MSGV3 type SYMSGV read-only .
  data MSGV4 type SYMSGV read-only .
  class-data MSG_TEXT type STRING .
  data CONTROLLER type ref to /GPIOS/IF_PBL_CONTROLLER read-only .

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
  class-methods MESSAGE_EXCEPTION
    importing
      !PREVIOUS type ref to CX_ROOT optional
      !MSGTY type SYMSGTY default SY-MSGTY
      !MSGID type SYMSGID default SY-MSGID
      !MSGNO type SYMSGNO default SY-MSGNO
      !MSGV1 type SYMSGV default SY-MSGV1
      !MSGV2 type SYMSGV default SY-MSGV2
      !MSGV3 type SYMSGV default SY-MSGV3
      !MSGV4 type SYMSGV default SY-MSGV4
      !SERNR type /GPIOS/PBL_SERNR optional
      !CONTROLLER type ref to /GPIOS/IF_PBL_CONTROLLER optional
    raising
      /GPIOS/CX_PBL .
protected section.

  type-pools ABAP .
  class-methods RAISE_MESSAGE_EXCEPTION
    importing
      !PREVIOUS type ref to CX_ROOT optional
      !MSGTY type SYMSGTY default SY-MSGTY
      !MSGID type SYMSGID default SY-MSGID
      !MSGNO type SYMSGNO default SY-MSGNO
      !MSGV1 type SYMSGV default SY-MSGV1
      !MSGV2 type SYMSGV default SY-MSGV2
      !MSGV3 type SYMSGV default SY-MSGV3
      !MSGV4 type SYMSGV default SY-MSGV4
      value(EXCEPTION_CLASS) type SEOCLSNAME optional
      !DETERMINE_CLASS type ABAP_BOOL default ABAP_TRUE
      !SERNR type /GPIOS/PBL_SERNR optional
      !CONTROLLER type ref to /GPIOS/IF_PBL_CONTROLLER optional
    raising
      /GPIOS/CX_PBL .
private section.
ENDCLASS.



CLASS /GPIOS/CX_PBL IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->SERNR = SERNR .
me->MSGTY = MSGTY .
me->MSGV1 = MSGV1 .
me->MSGV2 = MSGV2 .
me->MSGV3 = MSGV3 .
me->MSGV4 = MSGV4 .
me->MSG_TEXT = MSG_TEXT .
me->CONTROLLER = CONTROLLER .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.


  METHOD MESSAGE_EXCEPTION.
    CALL METHOD /gpios/cx_pbl=>raise_message_exception
      EXPORTING
        previous   = previous
        msgty      = msgty
        msgid      = msgid
        msgno      = msgno
        msgv1      = msgv1
        msgv2      = msgv2
        msgv3      = msgv3
        msgv4      = msgv4
        sernr      = sernr
        controller = controller.
  ENDMETHOD.


  METHOD RAISE_MESSAGE_EXCEPTION.

    DATA:
      textid       TYPE scx_t100key,
      lt_callstack TYPE abap_callstack,
      ls_callstack LIKE LINE OF lt_callstack,
      lx_pbl       TYPE REF TO /gpios/cx_pbl.

    CHECK msgid IS NOT INITIAL.
    textid-msgid = msgid.
    textid-msgno = msgno.
    textid-attr1 = 'MSGV1'.
    textid-attr2 = 'MSGV2'.
    textid-attr3 = 'MSGV3'.
    textid-attr4 = 'MSGV4'.

    IF exception_class IS INITIAL AND determine_class = abap_true.
      CALL FUNCTION 'SYSTEM_CALLSTACK'
        EXPORTING
          max_level = 2
        IMPORTING
          callstack = lt_callstack.
      READ TABLE lt_callstack INDEX 2 INTO ls_callstack TRANSPORTING mainprogram.
      exception_class = cl_oo_classname_service=>get_clsname_by_include( incname = ls_callstack-mainprogram ).
    ENDIF.

    CREATE OBJECT lx_pbl TYPE (exception_class)
      EXPORTING
        textid   = textid
        previous = previous
        controller = controller
        sernr    = sernr
        msgty    = msgty
        msgv1    = msgv1
        msgv2    = msgv2
        msgv3    = msgv3
        msgv4    = msgv4.

    RAISE EXCEPTION lx_pbl.

  ENDMETHOD.
ENDCLASS.
