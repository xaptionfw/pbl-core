*&---------------------------------------------------------------------*
*& Report  /GPIOS/PBL_SET_COLOR
*& GPIOS PbL: Farbe setzen
*&---------------------------------------------------------------------*
REPORT /gpios/pbl_set_color.

DATA:
  go_controller TYPE REF TO /gpios/if_pbl_controller,
  gt_io_units   TYPE /gpios/if_pbl_types=>ty_t_io_units,
  go_io_unit    LIKE LINE OF gt_io_units.

PARAMETERS:
  p_ctrl   TYPE /gpios/pbl_ctl-sernr OBLIGATORY MEMORY ID /gpios/pbl_ctl_rmt,
  p_io_uid TYPE /gpios/pbl_ledno,
  p_r      TYPE /gpios/pbl_redon   AS CHECKBOX,
  p_g      TYPE /gpios/pbl_greenon AS CHECKBOX,
  p_b      TYPE /gpios/pbl_blueon  AS CHECKBOX.

START-OF-SELECTION.
  go_controller = /gpios/cl_pbl_controller=>get_instance( iv_sernr = p_ctrl ).
  go_controller->get_io_units( IMPORTING et_io_units = gt_io_units ).
  READ TABLE gt_io_units WITH KEY table_line->gs_data-io_uid = p_io_uid
                         INTO go_io_unit.
  CHECK sy-subrc = 0.
  go_io_unit->set_color( iv_r = p_r
                         iv_g = p_g
                         iv_b = p_b ).
