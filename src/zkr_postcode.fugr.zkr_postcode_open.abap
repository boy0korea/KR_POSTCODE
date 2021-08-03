FUNCTION zkr_postcode_open.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     REFERENCE(ES_ADDR) TYPE  ZCL_KR_POSTCODE=>TS_ADDR
*"----------------------------------------------------------------------

  CLEAR: gs_addr.

  CALL SCREEN 1000.

  es_addr = gs_addr.

ENDFUNCTION.
