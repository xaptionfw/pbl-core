interface /GPIOS/IF_PBL_CONTROLLER
  public .


  data GS_DATA type /GPIOS/PBL_CTL read-only .
  type-pools ABAP .
  data GV_NEW type ABAP_BOOL read-only .
  constants GC_COMM_TYPE_REMOTE type /GPIOS/PBL_COMMUNICATION_TYPE value 'R'. "#EC NOTEXT
  constants GC_COMM_TYPE_LOCAL type /GPIOS/PBL_COMMUNICATION_TYPE value 'L'. "#EC NOTEXT
  constants GC_COMM_ACTION_GET type /GPIOS/PBL_COMMUNICATION_ACT value 'GET'. "#EC NOTEXT
  constants GC_COMM_ACTION_POST type /GPIOS/PBL_COMMUNICATION_ACT value 'POST'. "#EC NOTEXT
  constants GC_COMM_ACTION_DELETE type /GPIOS/PBL_COMMUNICATION_ACT value 'DELETE'. "#EC NOTEXT
  constants GC_DATA_TYPE_DEVICES type /GPIOS/PBL_DATA_TYPE value 'DEVICES'. "#EC NOTEXT
  constants GC_DATA_TYPE_USERS type /GPIOS/PBL_DATA_TYPE value 'USERS'. "#EC NOTEXT
  constants GC_DATA_TYPE_COMPONENTS type /GPIOS/PBL_DATA_TYPE value 'COMPONENTS'. "#EC NOTEXT
  constants GC_DATA_TYPE_BOMHDR type /GPIOS/PBL_DATA_TYPE value 'BOMHDR'. "#EC NOTEXT
  constants GC_DATA_TYPE_BOMITM type /GPIOS/PBL_DATA_TYPE value 'BOMITM'. "#EC NOTEXT
  constants GC_DATA_TYPE_IO_UNITS type /GPIOS/PBL_DATA_TYPE value 'IO_UNITS'. "#EC NOTEXT
  constants GC_ACT_TYPE_SET_COLOR type /GPIOS/PBL_ACTION_TYPE value 'SET_COLOR'. "#EC NOTEXT
  constants GC_ACT_TYPE_GET_RUNNING_BOM type /GPIOS/PBL_ACTION_TYPE value 'GET_RUN_BO'. "#EC NOTEXT
  constants GC_ACT_TYPE_TOGGLE_ALL_COLORS type /GPIOS/PBL_ACTION_TYPE value 'TOG_C_ALL'. "#EC NOTEXT
  constants GC_ACT_TYPE_TOGGLE_COLOR type /GPIOS/PBL_ACTION_TYPE value 'TOG_C'. "#EC NOTEXT
  constants GC_ACT_TYPE_START_BOM type /GPIOS/PBL_ACTION_TYPE value 'START_BOM'. "#EC NOTEXT
  constants GC_ACT_TYPE_STOP_BOM type /GPIOS/PBL_ACTION_TYPE value 'STOP_BOM'. "#EC NOTEXT
  constants GC_ACT_TYPE_TOGGLE_BOM_ITM_IO type /GPIOS/PBL_ACTION_TYPE value 'TOG_BOMI_I'. "#EC NOTEXT
  constants GC_ACT_TYPE_PING type /GPIOS/PBL_ACTION_TYPE value 'PING'. "#EC NOTEXT
  constants GC_HTTP_CODE_OK type I value 200. "#EC NOTEXT
  constants GC_HTTP_CODE_CREATED type I value 201. "#EC NOTEXT
  constants GC_HTTP_CODE_ACCEPTED type I value 202. "#EC NOTEXT
  constants GC_HTTP_CODE_BAD_REQUEST type I value 400. "#EC NOTEXT
  constants GC_HTTP_CODE_UNAUTHORIZED type I value 401. "#EC NOTEXT
  constants GC_HTTP_CODE_FORBIDDEN type I value 403. "#EC NOTEXT
  constants GC_HTTP_CODE_NOT_FOUND type I value 404. "#EC NOTEXT
  constants GC_HTTP_CODE_INTERNAL_SERVER_E type I value 500. "#EC NOTEXT
  constants GC_HTTP_CODE_NOT_IMPLEMENTED type I value 501. "#EC NOTEXT
  data GV_DESCRIPTION type DESCRIPTIO read-only .
  interface /GPIOS/IF_PBL_TYPES load .
  data GT_LOCAL_DEVICES type /GPIOS/IF_PBL_TYPES=>TY_T_DEV .
  data GT_REMOTE_DEVICES type /GPIOS/IF_PBL_TYPES=>TY_T_DEV .
  data GT_LOCAL_USERS type /GPIOS/IF_PBL_TYPES=>TY_T_USR .
  data GT_REMOTE_USERS type /GPIOS/IF_PBL_TYPES=>TY_T_USR .
  data GT_LOCAL_COMPONENTS type /GPIOS/IF_PBL_TYPES=>TY_T_CPN .
  data GT_REMOTE_COMPONENTS type /GPIOS/IF_PBL_TYPES=>TY_T_CPN .
  data GT_DELETE_COMPONENTS type /GPIOS/IF_PBL_TYPES=>TY_T_CPN_KEY .
  data GT_LOCAL_BOM_HEADERS type /GPIOS/IF_PBL_TYPES=>TY_T_BH .
  data GT_REMOTE_BOM_HEADERS type /GPIOS/IF_PBL_TYPES=>TY_T_BH .
  data GT_DELETE_BOM_HEADERS type /GPIOS/IF_PBL_TYPES=>TY_T_BH_KEY .
  data GT_LOCAL_BOM_ITEMS type /GPIOS/IF_PBL_TYPES=>TY_T_BI .
  data GT_REMOTE_BOM_ITEMS type /GPIOS/IF_PBL_TYPES=>TY_T_BI .
  data GT_DELETE_BOM_ITEMS type /GPIOS/IF_PBL_TYPES=>TY_T_BI_KEY .
  data GT_IO_UNITS type /GPIOS/IF_PBL_TYPES=>TY_T_IO_UNITS read-only .
  data GT_IO_UNIT_DATA type /GPIOS/IF_PBL_TYPES=>TY_T_IO_UNIT_DATA .

  methods CHECK_CONTROLLER_ACCESSIBLE
    raising
      /GPIOS/CX_PBL .
  methods COPY_DATA_FROM_REF_CONTROLLER
    importing
      !IV_SAVE type ABAP_BOOL default ABAP_TRUE
      !IV_LOAD_DATA type ABAP_BOOL default ABAP_FALSE
      !IO_REF_CONTROLLER type ref to /GPIOS/IF_PBL_CONTROLLER
      !IV_DATA_TYPE type /GPIOS/PBL_DATA_TYPE
      !IV_MY_COMM_TYPE type /GPIOS/PBL_COMMUNICATION_TYPE
      !IV_REF_COMM_TYPE type /GPIOS/PBL_COMMUNICATION_TYPE
      !IV_DELETE_BEFORE type ABAP_BOOL default ABAP_TRUE
    raising
      /GPIOS/CX_PBL .
  methods DELETE
    importing
      !IV_COMM_TYPE type /GPIOS/PBL_COMMUNICATION_TYPE
      !IV_DATA_TYPE type /GPIOS/PBL_DATA_TYPE
      !IV_ALL type ABAP_BOOL default ABAP_FALSE
      !IV_CLEAR_ATTRIBUTE type ABAP_BOOL default ABAP_TRUE
      !IV_PING type ABAP_BOOL default ABAP_TRUE
    raising
      /GPIOS/CX_PBL .
  methods DELETE_BOM_HEADERS
    importing
      !IV_COMM_TYPE type /GPIOS/PBL_COMMUNICATION_TYPE
      !IV_CLEAR_ATTRIBUTE type ABAP_BOOL default ABAP_TRUE
      !IV_ALL type ABAP_BOOL default ABAP_FALSE
      !IV_PING type ABAP_BOOL default ABAP_TRUE
    raising
      /GPIOS/CX_PBL .
  methods DELETE_BOM_ITEMS
    importing
      !IV_COMM_TYPE type /GPIOS/PBL_COMMUNICATION_TYPE
      !IV_CLEAR_ATTRIBUTE type ABAP_BOOL default ABAP_TRUE
      !IV_ALL type ABAP_BOOL default ABAP_FALSE
      !IV_PING type ABAP_BOOL default ABAP_TRUE
    raising
      /GPIOS/CX_PBL .
  methods DELETE_COMPONENTS
    importing
      !IV_COMM_TYPE type /GPIOS/PBL_COMMUNICATION_TYPE
      !IV_CLEAR_ATTRIBUTE type ABAP_BOOL default ABAP_TRUE
      !IV_ALL type ABAP_BOOL default ABAP_FALSE
      !IV_PING type ABAP_BOOL default ABAP_TRUE
    raising
      /GPIOS/CX_PBL .
  methods DELETE_DEVICE_SETTINGS
    importing
      !IV_COMM_TYPE type /GPIOS/PBL_COMMUNICATION_TYPE
      !IV_CLEAR_ATTRIBUTE type ABAP_BOOL default ABAP_TRUE
      !IV_ALL type ABAP_BOOL default ABAP_FALSE
      !IV_PING type ABAP_BOOL default ABAP_TRUE
    raising
      /GPIOS/CX_PBL .
  methods DELETE_USERS
    importing
      !IV_COMM_TYPE type /GPIOS/PBL_COMMUNICATION_TYPE
      !IV_CLEAR_ATTRIBUTE type ABAP_BOOL default ABAP_TRUE
      !IV_ALL type ABAP_BOOL default ABAP_FALSE
      !IV_PING type ABAP_BOOL default ABAP_TRUE
    raising
      /GPIOS/CX_PBL .
  methods GET_BOM
    importing
      !IV_BAUGR type BAUGR
      !IV_COMM_TYPE type /GPIOS/PBL_COMMUNICATION_TYPE
      !IV_LOAD_DATA type ABAP_BOOL default ABAP_TRUE
      !IV_PING type ABAP_BOOL default ABAP_TRUE
    returning
      value(RO_BOM) type ref to /GPIOS/IF_PBL_BOM
    raising
      /GPIOS/CX_PBL .
  methods GET_CONNECTION_INFO
    exporting
      !EV_HOST type CLIKE
      !EV_PORT type SIMPLE
    raising
      /GPIOS/CX_PBL .
  methods GET_DATA_REF_FOR_DATA_TYPE
    importing
      !IV_DATA_TYPE type /GPIOS/PBL_DATA_TYPE
      !IV_COMM_TYPE type /GPIOS/PBL_COMMUNICATION_TYPE
      !IV_DELETE type ABAP_BOOL default ABAP_FALSE
    exporting
      !ER_DATA type ref to DATA .
  methods GET_IO_UNITS
    importing
      !IV_BYPASS_BUFFER type ABAP_BOOL default ABAP_FALSE
      !IV_PING type ABAP_BOOL default ABAP_TRUE
    exporting
      !ET_IO_UNITS like GT_IO_UNITS
    raising
      /GPIOS/CX_PBL .
  methods GET_IP
    returning
      value(RV_IP) type STRING
    raising
      /GPIOS/CX_PBL .
  methods GET_RUNNING_BOM
    exporting
      !EO_BOM type ref to /GPIOS/IF_PBL_BOM
      !EV_STARTED_AT type TIMESTAMPL
      !ET_REMAINING_BOM_ITEMS type /GPIOS/IF_PBL_TYPES=>TY_T_BOM_ITEMS
    raising
      /GPIOS/CX_PBL .
  methods GET_UI_URL
    importing
      !IV_DATA_TYPE type /GPIOS/PBL_DATA_TYPE optional
    returning
      value(RV_URL) type STRING
    raising
      /GPIOS/CX_PBL .
  methods LOAD
    importing
      !IV_COMM_TYPE type /GPIOS/PBL_COMMUNICATION_TYPE
      !IV_DATA_TYPE type /GPIOS/PBL_DATA_TYPE
      !IV_PING type ABAP_BOOL default ABAP_TRUE
    raising
      /GPIOS/CX_PBL .
  methods LOAD_BOM_HEADERS
    importing
      !IV_COMM_TYPE type /GPIOS/PBL_COMMUNICATION_TYPE
      !IV_PING type ABAP_BOOL default ABAP_TRUE
    exporting
      !ET_BOM_HEADERS like GT_LOCAL_BOM_HEADERS
    raising
      /GPIOS/CX_PBL .
  methods LOAD_BOM_ITEMS
    importing
      !IV_COMM_TYPE type /GPIOS/PBL_COMMUNICATION_TYPE
      !IV_PING type ABAP_BOOL default ABAP_TRUE
    exporting
      !ET_BOM_ITEMS like GT_LOCAL_BOM_ITEMS
    raising
      /GPIOS/CX_PBL .
  methods LOAD_COMPONENTS
    importing
      !IV_COMM_TYPE type /GPIOS/PBL_COMMUNICATION_TYPE
      !IV_PING type ABAP_BOOL default ABAP_TRUE
    exporting
      !ET_COMPONENTS like GT_LOCAL_COMPONENTS
    raising
      /GPIOS/CX_PBL .
  methods LOAD_DEVICE_SETTINGS
    importing
      !IV_COMM_TYPE type /GPIOS/PBL_COMMUNICATION_TYPE
      !IV_PING type ABAP_BOOL default ABAP_TRUE
    exporting
      !ET_DEVICES like GT_LOCAL_DEVICES
    raising
      /GPIOS/CX_PBL .
  methods LOAD_USERS
    importing
      !IV_COMM_TYPE type /GPIOS/PBL_COMMUNICATION_TYPE
      !IV_PING type ABAP_BOOL default ABAP_TRUE
    exporting
      !ET_USERS like GT_LOCAL_USERS
    raising
      /GPIOS/CX_PBL .
  methods PING
    returning
      value(RV_SUBRC) type SYSUBRC
    raising
      /GPIOS/CX_PBL .
  methods SAVE
    importing
      !IV_COMM_TYPE type /GPIOS/PBL_COMMUNICATION_TYPE
      !IV_DATA_TYPE type /GPIOS/PBL_DATA_TYPE
      !IV_DELETE_BEFORE type ABAP_BOOL default ABAP_TRUE
      !IV_PING type ABAP_BOOL default ABAP_TRUE
    raising
      /GPIOS/CX_PBL .
  methods SAVE_BOM_HEADERS
    importing
      !IV_COMM_TYPE type /GPIOS/PBL_COMMUNICATION_TYPE
      !IV_DELETE_BEFORE type ABAP_BOOL default ABAP_TRUE
      !IV_PING type ABAP_BOOL default ABAP_TRUE
    raising
      /GPIOS/CX_PBL .
  methods SAVE_BOM_ITEMS
    importing
      !IV_COMM_TYPE type /GPIOS/PBL_COMMUNICATION_TYPE
      !IV_DELETE_BEFORE type ABAP_BOOL default ABAP_TRUE
      !IV_PING type ABAP_BOOL default ABAP_TRUE
    raising
      /GPIOS/CX_PBL .
  methods SAVE_COMPONENTS
    importing
      !IV_COMM_TYPE type /GPIOS/PBL_COMMUNICATION_TYPE
      !IV_DELETE_BEFORE type ABAP_BOOL default ABAP_TRUE
      !IV_PING type ABAP_BOOL default ABAP_TRUE
    raising
      /GPIOS/CX_PBL .
  methods SAVE_DEVICE_SETTINGS
    importing
      !IV_COMM_TYPE type /GPIOS/PBL_COMMUNICATION_TYPE
      !IV_DELETE_BEFORE type ABAP_BOOL default ABAP_TRUE
      !IV_PING type ABAP_BOOL default ABAP_TRUE
    raising
      /GPIOS/CX_PBL .
  methods SAVE_USERS
    importing
      !IV_COMM_TYPE type /GPIOS/PBL_COMMUNICATION_TYPE
      !IV_DELETE_BEFORE type ABAP_BOOL default ABAP_TRUE
      !IV_PING type ABAP_BOOL default ABAP_TRUE
    raising
      /GPIOS/CX_PBL .
  methods SET_DELETION_ROW
    importing
      !IV_DATA_TYPE type /GPIOS/PBL_DATA_TYPE
      !IA_ROW type ANY .
endinterface.
