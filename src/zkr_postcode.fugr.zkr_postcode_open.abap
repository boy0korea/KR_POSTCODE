FUNCTION zkr_postcode_open.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_FULL_SCREEN) TYPE  FLAG OPTIONAL
*"  EXPORTING
*"     REFERENCE(ES_ADDR) TYPE  ZCL_KR_POSTCODE=>TS_ADDR
*"----------------------------------------------------------------------

  CLEAR: gs_addr.
  gv_full_screen = iv_full_screen.

  IF iv_full_screen EQ abap_true.
    CALL SCREEN 1000.
  ELSE.
    CALL SCREEN 1000 STARTING AT 1 100 ENDING AT 1 100.
  ENDIF.

  es_addr = gs_addr.

ENDFUNCTION.
