interface /GPIOS/IF_PBL_CALLBACK
  public .


  constants GC_CB_TYPE_PICKING_CHANGE type /GPIOS/PBL_CB_TYPE value 'PC'. "#EC NOTEXT
  constants GC_CB_TYPE_IO_CHANGE type /GPIOS/PBL_CB_TYPE value 'IC'. "#EC NOTEXT
  constants GC_CB_TYPE_IO_ASSIGN_CHANGE type /GPIOS/PBL_CB_TYPE value 'IAC'. "#EC NOTEXT
  constants GC_CB_TYPE_IO_TOUCH type /GPIOS/PBL_CB_TYPE value 'IT'. "#EC NOTEXT
  constants GC_CB_TYPE_IR_CHANGE type /GPIOS/PBL_CB_TYPE value 'IRC'. "#EC NOTEXT
  constants GC_HTTP_CODE_OK type I value 200. "#EC NOTEXT
  constants GC_HTTP_CODE_CREATED type I value 201. "#EC NOTEXT
  constants GC_HTTP_CODE_ACCEPTED type I value 202. "#EC NOTEXT
  constants GC_HTTP_CODE_BAD_REQUEST type I value 400. "#EC NOTEXT
  constants GC_HTTP_CODE_UNAUTHORIZED type I value 401. "#EC NOTEXT
  constants GC_HTTP_CODE_FORBIDDEN type I value 403. "#EC NOTEXT
  constants GC_HTTP_CODE_NOT_FOUND type I value 404. "#EC NOTEXT
  constants GC_HTTP_CODE_INTERNAL_SERVER_E type I value 500. "#EC NOTEXT
  constants GC_HTTP_CODE_NOT_IMPLEMENTED type I value 501. "#EC NOTEXT
  constants GC_BCS_DEBUG type BCS_BLMODULE value '/GPIOS/PBL_CALLBACK_DEBUG'. "#EC NOTEXT
  constants GC_BCS_NOTIFICATION_TEST type BCS_BLMODULE value '/GPIOS/PBL_CALLBACK_NOTIFICATION_TEST'. "#EC NOTEXT

  methods GET_CALLBACK_TYPE_FOR_SERVER
    importing
      !IO_SERVER type ref to IF_HTTP_SERVER
    returning
      value(RV_CB_TYPE) type /GPIOS/PBL_CB_TYPE .
  methods HANDLE_CALLBACK
    importing
      !IV_CB_TYPE type /GPIOS/PBL_CB_TYPE
      !IV_CB_DATA type ANY
      !IO_CONTROLLER type ref to /GPIOS/IF_PBL_CONTROLLER optional
    exporting
      !EV_HTTP_CODE type I
      !EV_HTTP_REASON type STRING
      !EV_HTTP_PAYLOAD type STRING .
  methods HANDLE_CALLBACK_PC
    importing
      !IV_CB_DATA type /GPIOS/PBL_CB_DATA_PC
      !IO_CONTROLLER type ref to /GPIOS/IF_PBL_CONTROLLER optional
    exporting
      !EV_HTTP_CODE type I
      !EV_HTTP_REASON type STRING
      !EV_HTTP_PAYLOAD type STRING .
  methods HANDLE_CALLBACK_IT
    importing
      !IV_CB_DATA type /GPIOS/PBL_CB_DATA_IT
      !IO_CONTROLLER type ref to /GPIOS/IF_PBL_CONTROLLER optional
    exporting
      !EV_HTTP_CODE type I
      !EV_HTTP_REASON type STRING
      !EV_HTTP_PAYLOAD type STRING .
  methods HANDLE_CALLBACK_IC
    importing
      !IV_CB_DATA type /GPIOS/PBL_CB_DATA_IC
      !IO_CONTROLLER type ref to /GPIOS/IF_PBL_CONTROLLER optional
    exporting
      !EV_HTTP_CODE type I
      !EV_HTTP_REASON type STRING
      !EV_HTTP_PAYLOAD type STRING .
  methods HANDLE_CALLBACK_IAC
    importing
      !IV_CB_DATA type /GPIOS/PBL_CB_DATA_IAC
      !IO_CONTROLLER type ref to /GPIOS/IF_PBL_CONTROLLER optional
    exporting
      !EV_HTTP_CODE type I
      !EV_HTTP_REASON type STRING
      !EV_HTTP_PAYLOAD type STRING .
  methods HANDLE_CALLBACK_IRC
    importing
      !IV_CB_DATA type /GPIOS/PBL_CB_DATA_IRC
      !IO_CONTROLLER type ref to /GPIOS/IF_PBL_CONTROLLER optional
    exporting
      !EV_HTTP_CODE type I
      !EV_HTTP_REASON type STRING
      !EV_HTTP_PAYLOAD type STRING .
  methods GET_CONTROLLER_FOR_SERVER
    importing
      !IO_SERVER type ref to IF_HTTP_SERVER
    returning
      value(RO_CONTROLLER) type ref to /GPIOS/IF_PBL_CONTROLLER
    raising
      /GPIOS/CX_PBL .
endinterface.
