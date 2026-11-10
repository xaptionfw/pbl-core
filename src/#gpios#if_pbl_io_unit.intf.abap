interface /GPIOS/IF_PBL_IO_UNIT
  public .


  data CONTROLLER type ref to /GPIOS/IF_PBL_CONTROLLER read-only .
  data GS_DATA type /GPIOS/PBL_CB_IO read-only .

  methods TOGGLE_COLOR
    importing
      !IV_COLOR type CHAR1
    raising
      /GPIOS/CX_PBL .
  type-pools ABAP .
  methods SET_COLOR
    importing
      !IV_R type ABAP_BOOL
      !IV_G type ABAP_BOOL
      !IV_B type ABAP_BOOL
    raising
      /GPIOS/CX_PBL .
  methods TOGGLE_ALL_COLORS
    raising
      /GPIOS/CX_PBL .
endinterface.
