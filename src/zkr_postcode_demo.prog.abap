*&---------------------------------------------------------------------*
*& Report  ZKR_POSTCODE_DEMO
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zkr_postcode_demo.

PARAMETERS: p_pstcd1 TYPE ad_pstcd1 MATCHCODE OBJECT zh_kr_postcode,
            p_gui    TYPE flag RADIOBUTTON GROUP g1,
            p_fpm    TYPE flag RADIOBUTTON GROUP g1,
            p_wd     TYPE flag RADIOBUTTON GROUP g1.


**********************************************************************
START-OF-SELECTION.
**********************************************************************
  CASE abap_true.
    WHEN p_gui.
      SUBMIT zkr_postcode_demo_gui VIA SELECTION-SCREEN AND RETURN.
    WHEN p_fpm.
      CALL FUNCTION 'WDY_EXECUTE_IN_BROWSER'
        EXPORTING
          application = 'ZKR_POSTCODE_DEMO_FPM'.
    WHEN p_wd.
      CALL FUNCTION 'WDY_EXECUTE_IN_BROWSER'
        EXPORTING
          application = 'ZKR_POSTCODE_DEMO_WD'.
  ENDCASE.
