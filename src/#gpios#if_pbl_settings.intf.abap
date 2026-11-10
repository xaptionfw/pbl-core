interface /GPIOS/IF_PBL_SETTINGS
  public .


  class-events INSTANCE_CHANGED
    exporting
      value(EO_OLD_INSTANCE) type ref to /GPIOS/IF_PBL_SETTINGS
      value(EO_NEW_INSTANCE) type ref to /GPIOS/IF_PBL_SETTINGS .
  events SETTINGS_REFRESHED .

  methods LOAD .
  methods CLEAR .
  methods REFRESH .
endinterface.
