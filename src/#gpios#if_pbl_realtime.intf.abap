interface /GPIOS/IF_PBL_REALTIME
  public .


  data GV_RT_TYPE type /GPIOS/PBL_RT_TYPE read-only .
  constants GC_RT_TYPE_TIMER type /GPIOS/PBL_RT_TYPE value 'TIMER'. "#EC NOTEXT
  constants GC_RT_TYPE_HTML_SOCKET type /GPIOS/PBL_RT_TYPE value 'HTML_SOCK'. "#EC NOTEXT
  type-pools ABAP .
  data GV_REGISTERED type ABAP_BOOL read-only .

  class /GPIOS/CL_PBL_REALTIME definition load .
  events RECEIVED
    exporting
      value(ET_RT_DATA) type /GPIOS/CL_PBL_REALTIME=>TY_T_RT_DATA .

  methods SEND
    importing
      !IV_CB_TYPE type /GPIOS/PBL_CB_TYPE
      !IV_CB_DATA type ANY
      !IO_CONTROLLER type ref to /GPIOS/IF_PBL_CONTROLLER
    raising
      CX_AMC_ERROR .
  interface /GPIOS/IF_PBL_TYPES load .
  methods REGISTER
    importing
      !IT_CONTROLLER type /GPIOS/IF_PBL_TYPES=>TY_T_CONTROLLER optional
      !IT_CB_TYPES type /GPIOS/IF_PBL_TYPES=>TY_T_CB_TYPES optional
    raising
      /GPIOS/CX_PBL .
  methods RECEIVE
    exporting
      !EV_BINARY type XSTRING
    raising
      CX_AMC_ERROR .
  methods UNREGISTER .
endinterface.
