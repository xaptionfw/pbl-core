class /GPIOS/CL_PBL_DOCU definition
  public
  abstract
  create public .

public section.

  constants CO_OBJID type W3OBJID value '/GPIOS/PBL_DOCU'. "#EC NOTEXT

  class-methods SHOW_DOCU .
protected section.
private section.
ENDCLASS.



CLASS /GPIOS/CL_PBL_DOCU IMPLEMENTATION.


  METHOD show_docu.
    DATA:
      ls_key TYPE wwwdatatab,
      l_objid TYPE string,
      l_dir TYPE string,
      l_temp_file TYPE c LENGTH 255,
      l_file TYPE string.

    SELECT SINGLE relid objid
      INTO (ls_key-relid, ls_key-objid)
      FROM wwwdata
      WHERE relid = 'MI'
      AND   objid = co_objid
      AND   srtf2 = 0.
    IF sy-subrc <> 0.
      MESSAGE 'Keine Dokumentation gefunden'(001) TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.
    cl_gui_frontend_services=>get_temp_directory( CHANGING temp_dir = l_dir ).
    l_objid = co_objid.
    TRANSLATE l_objid USING '/.'.
    SHIFT l_objid LEFT DELETING LEADING '.'.
    CONCATENATE l_dir l_objid INTO l_temp_file.
    CALL FUNCTION 'DOWNLOAD_WEB_OBJECT'
      EXPORTING
        key  = ls_key
      CHANGING
        temp = l_temp_file.
    l_file = l_temp_file.
    cl_gui_frontend_services=>execute(
      EXPORTING
        document               = l_file
      EXCEPTIONS
        cntl_error             = 1
        error_no_gui           = 2
        bad_parameter          = 3
        file_not_found         = 4
        path_not_found         = 5
        file_extension_unknown = 6
        error_execute_failed   = 7
        synchronous_failed     = 8
        not_supported_by_gui   = 9
        OTHERS                 = 10 ).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
