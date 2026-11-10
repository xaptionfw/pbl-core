interface /GPIOS/IF_PBL_BOM_ITEM
  public .


  data BOM type ref to /GPIOS/IF_PBL_BOM read-only .
  data GS_DATA type /GPIOS/PBL_BI read-only .
  data IO_UNIT type ref to /GPIOS/IF_PBL_IO_UNIT read-only .

  methods TOGGLE_BOM_ITM
    raising
      /GPIOS/CX_PBL .
  type-pools ABAP .
  methods GET_DATA
    importing
      !IV_BYPASS_BUFFER type ABAP_BOOL default ABAP_FALSE
      !IV_COMM_TYPE type /GPIOS/PBL_COMMUNICATION_TYPE
      !IV_PING type ABAP_BOOL default ABAP_TRUE
    returning
      value(RS_DATA) like GS_DATA
    raising
      /GPIOS/CX_PBL .
  methods GET_IO_UNIT
    importing
      !IV_BYPASS_BUFFER type ABAP_BOOL default ABAP_FALSE
    returning
      value(RO_IO_UNIT) type ref to /GPIOS/IF_PBL_IO_UNIT
    raising
      /GPIOS/CX_PBL .
endinterface.
