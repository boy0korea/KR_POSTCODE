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
    p_adr_kr = is_addr-roadaddress.
    p_adr_en = is_addr-roadaddressenglish.
    p_pstcd1 = is_addr-zonecode.
    p_street = is_addr-kr60.
    p_city1 = is_addr-kr40.
  ENDMETHOD.                    "ZIF_KR_POSTCODE_EVENT~on_return

ENDCLASS.                    "lcl_myevent_handler IMPLEMENTATION

**********************************************************************
AT SELECTION-SCREEN OUTPUT.
**********************************************************************
  LOOP AT SCREEN.
    screen-input = 0. " read only
    MODIFY SCREEN.
  ENDLOOP.

**********************************************************************
* INITIALIZATION.
**********************************************************************
INITIALIZATION.
  DATA: lo_event_handler TYPE REF TO lcl_myevent_handler.
  CREATE OBJECT lo_event_handler.
  zcl_kr_postcode=>gui_start( lo_event_handler ).
