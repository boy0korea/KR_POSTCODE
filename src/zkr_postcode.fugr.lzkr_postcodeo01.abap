*----------------------------------------------------------------------*
***INCLUDE LZKR_POSTCODEO01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  PBO_1000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_1000 OUTPUT.
  DATA: lo_event_handler TYPE REF TO lcl_myevent_handler.

  SET PF-STATUS 'TESTHTM1' OF PROGRAM 'SAPHTML_EVENTS_DEMO'.
  SET TITLEBAR '1000'.

  IF go_postcode IS INITIAL.

    CREATE OBJECT lo_event_handler.
    zcl_kr_postcode=>gui_start(
      EXPORTING
        io_event_handler = lo_event_handler
        iv_full_screen   = abap_true
      RECEIVING
        ro_postcode = go_postcode
    ).
  ENDIF.
ENDMODULE.                 " PBO_1000  OUTPUT
