interface /GPIOS/IF_PBL_CTRL_MANAGER
  public .


  data GO_LOCAL_CONTROLLER type ref to /GPIOS/IF_PBL_CONTROLLER read-only .
  data GO_REMOTE_CONTROLLER type ref to /GPIOS/IF_PBL_CONTROLLER read-only .
  data GV_DATA_TYPE type /GPIOS/PBL_DATA_TYPE read-only .
  interface /GPIOS/IF_PBL_TYPES load .
  data GT_R_REMOTE_DATA_TYPES type /GPIOS/IF_PBL_TYPES=>TY_R_DATA_TYPES read-only .
  data GT_R_LOCAL_DATA_TYPES type /GPIOS/IF_PBL_TYPES=>TY_R_DATA_TYPES read-only .
  data GT_R_ALLOWED_DATA_TYPES type /GPIOS/IF_PBL_TYPES=>TY_R_DATA_TYPES read-only .
  constants GC_MAINT_MODE_MAINTAIN type /GPIOS/PBL_CTRL_MAINT_MODE value 'MAINTAIN'. "#EC NOTEXT
  constants GC_MAINT_MODE_RECEIVE type /GPIOS/PBL_CTRL_MAINT_MODE value 'RECEIVE'. "#EC NOTEXT
  constants GC_MAINT_MODE_TRANSFER type /GPIOS/PBL_CTRL_MAINT_MODE value 'TRANSFER'. "#EC NOTEXT

  methods PAI
    importing
      !IV_UCOMM type SY-UCOMM default SY-UCOMM
    raising
      /GPIOS/CX_PBL .
  methods PBO
    importing
      !IV_CONTAINER_NAME type CLIKE
      !IV_DYNNR type SY-DYNNR default SY-DYNNR
      !IV_REPID type SY-REPID default SY-CPROG
    raising
      /GPIOS/CX_PBL
      CX_SALV_MSG
      CX_SALV_EXISTING
      CX_SALV_WRONG_CALL .
  methods SET_CONTROLLER
    importing
      !IO_LOCAL_CONTROLLER type ref to /GPIOS/IF_PBL_CONTROLLER
      !IO_REMOTE_CONTROLLER type ref to /GPIOS/IF_PBL_CONTROLLER .
  methods SET_DATA_TYPE
    importing
      !IV_DATA_TYPE type /GPIOS/PBL_DATA_TYPE .
  methods RECEIVE
    raising
      /GPIOS/CX_PBL .
  methods TRANSFER
    raising
      /GPIOS/CX_PBL .
endinterface.
