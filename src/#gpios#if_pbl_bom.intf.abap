interface /GPIOS/IF_PBL_BOM
  public .


  interface /GPIOS/IF_PBL_TYPES load .
  data BOM_ITEMS type /GPIOS/IF_PBL_TYPES=>TY_T_BOM_ITEMS read-only .
  data GS_DATA type /GPIOS/PBL_BH read-only .
  data CONTROLLER type ref to /GPIOS/IF_PBL_CONTROLLER read-only .
  constants GV_SHOW_TERMINATOR_TRUE type /GPIOS/PBL_SHOWTERMINATOR value 'true'. "#EC NOTEXT
  constants GV_SHOW_TERMINATOR_FALSE type /GPIOS/PBL_SHOWTERMINATOR value 'false'. "#EC NOTEXT
  constants GV_SHOW_TERMINATOR_DEFAULT type /GPIOS/PBL_SHOWTERMINATOR value 'default'. "#EC NOTEXT

  interface /GPIOS/IF_PBL_BOM load .
  methods START
    importing
      !IV_SHOW_TERMINATOR type /GPIOS/PBL_SHOWTERMINATOR default /GPIOS/IF_PBL_BOM=>GV_SHOW_TERMINATOR_DEFAULT
    raising
      /GPIOS/CX_PBL .
  methods STOP
    raising
      /GPIOS/CX_PBL .
  type-pools ABAP .
  methods GET_BOM_ITEMS
    importing
      !IV_BYPASS_BUFFER type ABAP_BOOL default ABAP_FALSE
      !IV_COMM_TYPE type /GPIOS/PBL_COMMUNICATION_TYPE
      !IV_PING type ABAP_BOOL default ABAP_TRUE
    returning
      value(RT_BOM_ITEMS) like BOM_ITEMS
    raising
      /GPIOS/CX_PBL .
  methods GET_DATA
    importing
      !IV_BYPASS_BUFFER type ABAP_BOOL default ABAP_FALSE
      !IV_COMM_TYPE type /GPIOS/PBL_COMMUNICATION_TYPE
      !IV_PING type ABAP_BOOL default ABAP_TRUE
    returning
      value(RS_DATA) like GS_DATA
    raising
      /GPIOS/CX_PBL .
endinterface.
