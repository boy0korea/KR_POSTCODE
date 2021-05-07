FUNCTION-POOL zkr_postcode.                 "MESSAGE-ID ..

DATA: gs_addr TYPE zcl_kr_postcode=>ts_addr,
      go_postcode TYPE REF TO zcl_kr_postcode.

*----------------------------------------------------------------------*
*       CLASS lcl_myevent_handler DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_myevent_handler DEFINITION.

  PUBLIC SECTION.
    INTERFACES zif_kr_postcode_event.

ENDCLASS.                    "lcl_myevent_handler DEFINITION
*----------------------------------------------------------------------*
*       CLASS lcl_myevent_handler IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_myevent_handler IMPLEMENTATION.

  METHOD zif_kr_postcode_event~on_return.
    gs_addr = is_addr.
    go_postcode->free( ).
    FREE: go_postcode.
    LEAVE TO SCREEN 0.
  ENDMETHOD.                    "ZIF_KR_POSTCODE_EVENT~on_return

ENDCLASS.                    "lcl_myevent_handler IMPLEMENTATION
