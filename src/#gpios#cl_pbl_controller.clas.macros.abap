*"* use this source file for any macro definitions you need
*"* in the implementation part of the class
DEFINE raise_generic_exception.
  IF sy-msgty IS NOT INITIAL AND sy-msgid IS NOT INITIAL.
    MESSAGE ID     sy-msgid
            TYPE   sy-msgty
            NUMBER sy-msgno
            WITH   sy-msgv1
                   sy-msgv2
                   sy-msgv3
                   sy-msgv4 INTO /gpios/cx_pbl=>msg_text.
    /gpios/cx_pbl=>message_exception(
      EXPORTING
         sernr          = /gpios/if_pbl_controller~gs_data-sernr
        controller      = me ).
  ENDIF.
END-OF-DEFINITION.
