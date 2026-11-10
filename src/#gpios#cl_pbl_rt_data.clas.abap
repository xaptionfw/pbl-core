class /GPIOS/CL_PBL_RT_DATA definition
  public
  create public .

public section.

  interfaces IF_SERIALIZABLE_OBJECT .

  data GV_CB_TYPE type /GPIOS/PBL_CB_TYPE .
  data GV_CB_DATA type ref to DATA .
  data GS_CONTROLLER_DATA type /GPIOS/PBL_CTL .
protected section.
private section.
ENDCLASS.



CLASS /GPIOS/CL_PBL_RT_DATA IMPLEMENTATION.
ENDCLASS.
