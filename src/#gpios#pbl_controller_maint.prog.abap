*&---------------------------------------------------------------------*
*& Report  /gpios/PBL_CONTROLLER_MAINT
*& PbL: Steuergeräteverwaltung
*&---------------------------------------------------------------------*
*& (C) GPIO Solutions GmbH
*&---------------------------------------------------------------------*
REPORT /gpios/pbl_controller_maint.

TABLES:
  sscrfields.

DATA:
  gs_ft                TYPE smp_dyntxt,
  go_local_controller  TYPE REF TO /gpios/if_pbl_controller,
  go_remote_controller TYPE REF TO /gpios/if_pbl_controller,
  gx_root              TYPE REF TO cx_root.

SELECTION-SCREEN:
  FUNCTION KEY 1,
  FUNCTION KEY 2,
  BEGIN OF BLOCK sel WITH FRAME TITLE text-002 NO INTERVALS.
PARAMETERS:
  p_lclctr TYPE /gpios/pbl_ctl-sernr OBLIGATORY MEMORY ID /gpios/pbl_ctl_loc,
  p_remctr TYPE /gpios/pbl_ctl-sernr OBLIGATORY MEMORY ID /gpios/pbl_ctl_rmt,
  p_dataty TYPE /gpios/pbl_data_type AS LISTBOX OBLIGATORY VISIBLE LENGTH 20 DEFAULT 'IO_UNITS'.
SELECTION-SCREEN:
  END OF BLOCK sel,
  BEGIN OF BLOCK b1 WITH FRAME TITLE text-001 NO INTERVALS.
PARAMETERS:
  p_mode TYPE /gpios/pbl_ctrl_maint_mode AS LISTBOX OBLIGATORY VISIBLE LENGTH 20
         DEFAULT /gpios/if_pbl_ctrl_manager=>gc_maint_mode_maintain.
SELECTION-SCREEN:
  END OF BLOCK b1.

INITIALIZATION.
  gs_ft-icon_id = icon_tools.
  gs_ft-quickinfo = gs_ft-icon_text = 'Einstellungen'(003).
  sscrfields-functxt_01 = gs_ft.
  gs_ft-icon_id = icon_pdf.
  gs_ft-quickinfo = gs_ft-icon_text = 'Dokumentation'(004).
  sscrfields-functxt_02 = gs_ft.

AT SELECTION-SCREEN.
  CASE sy-ucomm.
    WHEN 'FC01'.
      CALL FUNCTION 'BMENU_START_BROWSER'
        EXPORTING
          tree_id = '/GPIOS/PBL_SETTINGS'
        EXCEPTIONS
          OTHERS  = 0.
      MESSAGE 'Transaktion wurde neu gestartet'(010) TYPE 'S'.
      LEAVE TO TRANSACTION sy-tcode.
    WHEN 'FC02'.
      CALL TRANSACTION '/GPIOS/PBL_DOCU'.
  ENDCASE.

START-OF-SELECTION.
  go_local_controller = /gpios/cl_pbl_controller=>get_instance( iv_sernr = p_lclctr ).
  go_remote_controller = /gpios/cl_pbl_controller=>get_instance( iv_sernr = p_remctr ).
  /gpios/cl_pbl_ctrl_manager=>instance->set_controller( io_local_controller  = go_local_controller
                                                        io_remote_controller = go_remote_controller ).
  /gpios/cl_pbl_ctrl_manager=>instance->set_data_type( iv_data_type = p_dataty ).
  CASE p_mode.
    WHEN /gpios/if_pbl_ctrl_manager=>gc_maint_mode_maintain.
      CALL SCREEN 100.
    WHEN /gpios/if_pbl_ctrl_manager=>gc_maint_mode_receive.
      /gpios/cl_pbl_ctrl_manager=>instance->receive( ).
    WHEN /gpios/if_pbl_ctrl_manager=>gc_maint_mode_transfer.
      /gpios/cl_pbl_ctrl_manager=>instance->transfer( ).
  ENDCASE.

*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
MODULE status OUTPUT.
  TRY.
      /gpios/cl_pbl_ctrl_manager=>instance->pbo( iv_dynnr          = sy-dynnr
                                                 iv_repid          = sy-repid
                                                 iv_container_name = 'CONTAINER' ).
    CATCH cx_root INTO gx_root.
      MESSAGE gx_root TYPE 'E'.
  ENDTRY.
ENDMODULE.                 " STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE user_command INPUT.
  TRY.
      /gpios/cl_pbl_ctrl_manager=>instance->pai( iv_ucomm = sy-ucomm ).
    CATCH cx_root INTO gx_root.
      MESSAGE gx_root TYPE 'E'.
  ENDTRY.
ENDMODULE.                 " USER_COMMAND  INPUT
