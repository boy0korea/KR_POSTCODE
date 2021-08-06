FUNCTION-POOL zkr_postcode.                 "MESSAGE-ID ..

CLASS lcl_event_handler DEFINITION DEFERRED.
DATA: gs_addr            TYPE zcl_kr_postcode=>ts_addr,
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
  METHOD on_sapevent.
    PERFORM on_sapevent USING action postdata.
  ENDMETHOD.
ENDCLASS.                    "lcl_event_handler IMPLEMENTATION


CLASS lcl_on_close_wdr_f4_elementary DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS on_close
      FOR EVENT on_controller_exit OF cl_wdr_controller
      IMPORTING controller.
ENDCLASS.
CLASS lcl_on_close_wdr_f4_elementary IMPLEMENTATION.
  METHOD on_close.
    DATA: lo_m TYPE REF TO if_wd_message_manager,
          lt_m TYPE if_wd_message_manager=>ty_t_messages,
          ls_m TYPE if_wd_message_manager=>ty_s_message.

    IF controller->component->component_name EQ 'WDR_F4_ELEMENTARY'.
      lo_m = controller->component->if_wd_controller~get_message_manager( ).
      lt_m = lo_m->get_messages( ).
      LOOP AT lt_m INTO ls_m.
        IF ls_m-msg_object IS INSTANCE OF cx_wdr_value_help.
          lo_m->remove_message( ls_m-msg_id ).
        ENDIF.
      ENDLOOP.
      SET HANDLER lcl_on_close_wdr_f4_elementary=>on_close ACTIVATION abap_false.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
