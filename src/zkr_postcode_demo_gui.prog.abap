*&---------------------------------------------------------------------*
*& Report  ZKR_POSTCODE_DEMO_GUI
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zkr_postcode_demo_gui.

PARAMETERS: p_adr_kr TYPE string,
            p_adr_en TYPE string,
            p_pstcd1 TYPE ad_pstcd1,
            p_street TYPE ad_street,
            p_city1  TYPE ad_city1.

**********************************************************************
INITIALIZATION.
**********************************************************************
  DATA: ls_addr TYPE zcl_kr_postcode=>ts_addr.

  ls_addr = zcl_kr_postcode=>gui_start2( ).

  IF ls_addr IS NOT INITIAL.
    p_adr_kr = ls_addr-roadaddress.
    p_adr_en = ls_addr-roadaddressenglish.
    p_pstcd1 = ls_addr-zonecode.
    p_street = ls_addr-kr60.
    p_city1 = ls_addr-kr40.
  ENDIF.
