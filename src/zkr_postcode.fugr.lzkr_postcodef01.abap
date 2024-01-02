*----------------------------------------------------------------------*
***INCLUDE LZKR_POSTCODEF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form do_init
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM do_init .

  DATA: lo_parent TYPE REF TO cl_gui_container,
        lt_event  TYPE cntl_simple_events,
        ls_event  TYPE cntl_simple_event,
        lv_url    TYPE bxurlg-gen_url.

  CREATE OBJECT go_event_handler.

  " full screen
  CREATE OBJECT go_gui_full_screen
    EXPORTING
      side      = cl_gui_docking_container=>dock_at_bottom
      extension = cl_gui_docking_container=>ws_maximizebox
      caption   = 'Address'.
  lo_parent = go_gui_full_screen.

  " html viewer
  CREATE OBJECT go_gui_html_viewer
    EXPORTING
      parent               = lo_parent
      query_table_disabled = abap_true.
  ls_event-eventid = cl_gui_html_viewer=>m_id_sapevent.
  ls_event-appl_event = abap_true.
  APPEND ls_event TO lt_event.
  go_gui_html_viewer->set_registered_events( lt_event ).
  SET HANDLER go_event_handler->on_sapevent FOR go_gui_html_viewer.


  " SMW0 Web Repository Object 사용.
  go_gui_html_viewer->load_html_document(
    EXPORTING
      document_id            = 'ZKR_POSTCODE'
    IMPORTING
      assigned_url           = lv_url
    EXCEPTIONS
      document_not_found     = 1
      dp_error_general       = 2
      dp_invalid_parameter   = 3
      html_syntax_notcorrect = 4
      OTHERS                 = 5
  ).
  IF sy-subrc EQ 1.
    zcl_kr_postcode=>readme_smw0_zkr_postcode( ).
  ENDIF.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  go_gui_html_viewer->show_url( lv_url ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form do_free_and_back
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM do_free_and_back .
  IF go_gui_html_viewer IS NOT INITIAL.
    go_gui_html_viewer->free( ).
  ENDIF.
  IF go_gui_full_screen IS NOT INITIAL.
    go_gui_full_screen->free( ).
  ENDIF.

  FREE: go_gui_html_viewer, go_gui_full_screen, go_event_handler.

  LEAVE TO SCREEN 0.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form on_sapevent
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ACTION
*&      --> POSTDATA
*&---------------------------------------------------------------------*
FORM on_sapevent  USING    iv_action
                           it_postdata TYPE cnht_post_data_tab.

  DATA: lv_json TYPE string.

  CASE iv_action.
    WHEN 'RETURN'.
      CONCATENATE LINES OF it_postdata INTO lv_json.
      REPLACE 'return=' IN lv_json WITH ''.
      " 특수문자 3개 처리 &=?
      " CL_GUI_HTML_VIEWER->TRANSLATE_QUERY_STRING
      REPLACE ALL OCCURRENCES OF '%26' IN lv_json WITH '&'.
      REPLACE ALL OCCURRENCES OF '%3D' IN lv_json WITH '='.
      REPLACE ALL OCCURRENCES OF '%3F' IN lv_json WITH '?'.
      gs_addr = zcl_kr_postcode=>convert_json_to_addr( lv_json ).
      PERFORM do_free_and_back.

    WHEN OTHERS.
  ENDCASE.

ENDFORM.
