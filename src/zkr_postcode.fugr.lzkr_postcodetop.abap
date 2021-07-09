FUNCTION-POOL zkr_postcode.                 "MESSAGE-ID ..

CLASS lcl_event_handler DEFINITION DEFERRED.
DATA: gs_addr            TYPE zcl_kr_postcode=>ts_addr,
      gv_full_screen     TYPE flag,
      go_gui_popup       TYPE REF TO cl_gui_dialogbox_container,
      go_gui_full_screen TYPE REF TO cl_gui_docking_container,
      go_gui_html_viewer TYPE REF TO cl_gui_html_viewer,
      go_event_handler   TYPE REF TO lcl_event_handler.

*----------------------------------------------------------------------*
*       CLASS lcl_event_handler DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION.

  PUBLIC SECTION.
    METHODS on_close_popup
        FOR EVENT close OF cl_gui_dialogbox_container .
    METHODS on_sapevent
      FOR EVENT sapevent OF cl_gui_html_viewer
      IMPORTING
        !action
        !frame
        !getdata
        !postdata
        !query_table .

ENDCLASS.                    "lcl_event_handler DEFINITION
*----------------------------------------------------------------------*
*       CLASS lcl_event_handler IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.

  METHOD on_close_popup.
    PERFORM on_close_popup.
  ENDMETHOD.

  METHOD on_sapevent.
    PERFORM on_sapevent USING action postdata.
  ENDMETHOD.

ENDCLASS.                    "lcl_event_handler IMPLEMENTATION
