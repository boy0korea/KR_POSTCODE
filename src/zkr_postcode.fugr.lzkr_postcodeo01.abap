*----------------------------------------------------------------------*
***INCLUDE LZKR_POSTCODEO01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  PBO_1000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_1000 OUTPUT.
  SET TITLEBAR '1000'.

  IF gv_full_screen EQ abap_true.
    SET PF-STATUS 'TESTHTM1' OF PROGRAM 'SAPHTML_EVENTS_DEMO'.
  ELSE.
    SET PF-STATUS 'INIT' OF PROGRAM 'SAPMSHLP'.
  ENDIF.

  IF go_gui_html_viewer IS INITIAL.
    PERFORM do_init.
  ENDIF.

ENDMODULE.                 " PBO_1000  OUTPUT
