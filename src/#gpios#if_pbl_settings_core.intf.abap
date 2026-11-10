interface /GPIOS/IF_PBL_SETTINGS_CORE
  public .


  interfaces /GPIOS/IF_PBL_SETTINGS .

  data /GPIOS/PBL_SET type /GPIOS/PBL_SET read-only .
  interface /GPIOS/IF_PBL_TYPES load .
  data /GPIOS/PBL_COM type /GPIOS/IF_PBL_TYPES=>TY_T_PBL_COM read-only .
  data /GPIOS/PBL_ACT type /GPIOS/IF_PBL_TYPES=>TY_T_PBL_ACT read-only .
  data /GPIOS/PBL_RT type /GPIOS/IF_PBL_TYPES=>TY_T_PBL_RT read-only .
  data /GPIOS/PBL_CB type /GPIOS/IF_PBL_TYPES=>TY_T_PBL_CB read-only .
endinterface.
