FUNCTION /gpios/pbl_rt_rec_timer.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  EXPORTING
*"     VALUE(EV_BINARY) TYPE  XSTRING
*"----------------------------------------------------------------------

  DATA: lo_receiver TYPE REF TO /gpios/if_pbl_realtime.

  lo_receiver = /gpios/cl_pbl_realtime=>get_instance( iv_rt_type = /gpios/if_pbl_realtime=>gc_rt_type_timer ).
  TRY.
      lo_receiver->receive( IMPORTING ev_binary = ev_binary ).
    CATCH cx_amc_error.
      RETURN.
  ENDTRY.
ENDFUNCTION.
