*&---------------------------------------------------------------------*
*&  Include           /GPIOS/LPBL_MNTF01
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE /XAPTION/LPBL_MAIF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  /gpios/resize_table
*&---------------------------------------------------------------------*
FORM /gpios/resize_table USING im_prog
                               im_dynnr
                               im_width
                               im_table.

  CHECK im_width <= 255.

  DATA:
    BEGIN OF ls_dynpro_descr,
      prog   TYPE progname,
      dynpro TYPE char4,
    END OF ls_dynpro_descr.

  DATA:
    l_fnam          TYPE d021s-fnam,
    l_crmt_ei_kb_id TYPE crmt_ei_kb_id,
    h               TYPE d020s,
    ls_f            TYPE d021s,
    f               TYPE STANDARD TABLE OF d021s,
    e               TYPE STANDARD TABLE OF d022s,
    m               TYPE STANDARD TABLE OF d023s,
    m1              TYPE string,
    l1              TYPE string,
    w1              TYPE string.

  CHECK im_width <= 255.

  ls_dynpro_descr-prog   = im_prog.
  ls_dynpro_descr-dynpro = im_dynnr.

  CONCATENATE 'TCTRL_' im_table INTO l_fnam.

  IMPORT DYNPRO h f e m ID ls_dynpro_descr.
  CHECK sy-subrc = 0.

  READ TABLE f INTO ls_f WITH KEY fnam = l_fnam.
  CHECK sy-subrc = 0 AND h-noco <> im_width.

  h-noco = im_width.

* convert to hex
  l_crmt_ei_kb_id = im_width - 2.
  CALL FUNCTION 'CRM_EI_KB_CONV_DEC_TO_HEX'
    EXPORTING
      iv_decimal = l_crmt_ei_kb_id
    IMPORTING
      ev_hex     = l_crmt_ei_kb_id.

  CHECK NOT l_crmt_ei_kb_id+30(2) IS INITIAL.

  ls_f-leng = l_crmt_ei_kb_id+30(2). " '9B'. " 155 em hexa

  MODIFY f FROM ls_f INDEX sy-tabix TRANSPORTING leng.
  CHECK sy-subrc = 0.

  EXPORT DYNPRO h f e m ID ls_dynpro_descr.

  GENERATE DYNPRO h f e m ID ls_dynpro_descr MESSAGE m1 LINE l1 WORD w1.
  CHECK sy-subrc = 0.
ENDFORM.                    " /gios/resize_table

*&---------------------------------------------------------------------*
*&      Form  /gpios/resize_this_table
*&---------------------------------------------------------------------*
FORM /gpios/resize_this_table.
  FIELD-SYMBOLS:
    <ls_col> LIKE LINE OF <vim_tctrl>-cols.

  PERFORM /gpios/resize_table USING
                 sy-repid       "im_prog
                 x_header-liste "im_dynnr
                 255            "im_width
                 view_name      ."im_table.
  LOOP AT <vim_tctrl>-cols ASSIGNING <ls_col>
    WHERE screen-name = '/GPIOS/PBL_VCT-APIPW'.
    <ls_col>-screen-invisible = '1'.
  ENDLOOP.
ENDFORM.                    " /gpios/resize_this_table

FORM /gpios/fill_cccategory.
  SELECT SINGLE cccategory
         FROM t000
         CLIENT SPECIFIED
         INTO /gpios/pbl_vct-cccategory
         WHERE mandt = sy-mandt.
ENDFORM.                    " /gpios/fill_cccategorye
