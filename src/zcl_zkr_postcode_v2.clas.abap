class ZCL_ZKR_POSTCODE_V2 definition
  public
  inheriting from CL_WD_COMPONENT_ASSISTANCE
  create public .

public section.

  data MO_EVENT_DATA type ref to IF_FPM_PARAMETER .
  data MO_COMP_USAGE type ref to IF_WD_COMPONENT_USAGE .
  class-data GV_WD_COMP_ID type STRING read-only .
  class-data GO_WD_COMP type ref to ZIWCI_KR_POSTCODE_V2 read-only .

  class-methods CLASS_CONSTRUCTOR .
  class-methods OPEN_POPUP
    importing
      !IO_EVENT_DATA type ref to IF_FPM_PARAMETER .
  methods ON_OK
    importing
      !IS_ADDR type ZCL_KR_POSTCODE=>TS_ADDR .
  methods ON_CLOSE
    for event WINDOW_CLOSED of IF_WD_WINDOW .
  class-methods FPM_POPUP
    importing
      !IV_CALLBACK_EVENT_ID type FPM_EVENT_ID default 'ZKR_POSTCODE'
      !IO_EVENT type ref to CL_FPM_EVENT .
  class-methods WD_POPUP
    importing
      !IV_CALLBACK_ACTION type STRING
      !IO_VIEW type ref to IF_WD_VIEW_CONTROLLER .
  class-methods SH_POPUP .
  PROTECTED SECTION.

    METHODS do_callback .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ZKR_POSTCODE_V2 IMPLEMENTATION.


  METHOD class_constructor.
    gv_wd_comp_id = CAST cl_abap_refdescr( cl_abap_typedescr=>describe_by_data( go_wd_comp ) )->get_referenced_type( )->get_relative_name( ).
    REPLACE 'IWCI_' IN gv_wd_comp_id WITH ''.
  ENDMETHOD.


  METHOD do_callback.
    DATA: lv_event_id    TYPE fpm_event_id,
          lo_fpm         TYPE REF TO if_fpm,
          lo_event       TYPE REF TO cl_fpm_event,
          lo_event_start TYPE REF TO cl_fpm_event,
          lt_key         TYPE TABLE OF string,
          lv_key         TYPE string,
          lr_value       TYPE REF TO data,
          lv_action      TYPE string,
          lo_view        TYPE REF TO cl_wdr_view,
          lo_action      TYPE REF TO if_wdr_action,
          lt_param       TYPE wdr_name_value_list,
          ls_param       TYPE wdr_name_value,
          lo_search_help TYPE REF TO cl_wdr_elementary_search_help.


**********************************************************************
* FPM
**********************************************************************
    mo_event_data->get_value(
      EXPORTING
        iv_key   = 'IV_CALLBACK_EVENT_ID'
      IMPORTING
        ev_value = lv_event_id
    ).
    IF lv_event_id IS NOT INITIAL.

      lo_fpm = cl_fpm=>get_instance( ).
      CHECK: lo_fpm IS NOT INITIAL.

      CREATE OBJECT lo_event
        EXPORTING
          iv_event_id   = lv_event_id
          io_event_data = mo_event_data.

      mo_event_data->get_value(
        EXPORTING
          iv_key   = 'IO_EVENT'
        IMPORTING
          ev_value = lo_event_start
      ).
      lo_event->ms_source_uibb = lo_event_start->ms_source_uibb.

      lo_fpm->raise_event( lo_event ).

    ENDIF.

**********************************************************************
* WD
**********************************************************************
    mo_event_data->get_value(
      EXPORTING
        iv_key   = 'IV_CALLBACK_ACTION'
      IMPORTING
        ev_value = lv_action
    ).
    IF lv_action IS NOT INITIAL.

      mo_event_data->get_value(
        EXPORTING
          iv_key   = 'IO_VIEW'
        IMPORTING
          ev_value = lo_view
      ).
      CHECK: lo_view IS NOT INITIAL.

      TRY.
          lo_action = lo_view->get_action_internal( lv_action ).
        CATCH cx_wdr_runtime INTO DATA(lx_wdr_runtime).
          wdr_task=>application->component->if_wd_controller~get_message_manager( )->report_error_message( lx_wdr_runtime->get_text( ) ).
      ENDTRY.
      CHECK: lo_action IS NOT INITIAL.

      CLEAR: ls_param.
      ls_param-name = 'MO_EVENT_DATA'.
      ls_param-object = mo_event_data.
      ls_param-type = cl_abap_typedescr=>typekind_oref.
      APPEND ls_param TO lt_param.

      lt_key = mo_event_data->get_keys( ).
      LOOP AT lt_key INTO lv_key.
        mo_event_data->get_value(
          EXPORTING
            iv_key   = lv_key
          IMPORTING
            er_value = lr_value
        ).
        CLEAR: ls_param.
        ls_param-name = lv_key.
        ls_param-dref = lr_value.
        ls_param-type = cl_abap_typedescr=>typekind_dref.
        APPEND ls_param TO lt_param.
      ENDLOOP.

      lo_action->set_parameters( lt_param ).
      lo_action->fire( ).

    ENDIF.


**********************************************************************
* search help
**********************************************************************
    mo_event_data->get_value(
      EXPORTING
        iv_key   = 'IO_SEARCH_HELP'
      IMPORTING
        ev_value = lo_search_help
    ).
    IF lo_search_help IS NOT INITIAL.

      ASSIGN ('(SAPLZKR_POSTCODE)GS_ADDR') TO FIELD-SYMBOL(<ls_addr>).
      mo_event_data->get_value(
        EXPORTING
          iv_key   = 'IS_ADDR'
        IMPORTING
          ev_value = <ls_addr>
      ).

      lo_search_help->do_return( 'GENERAL' ).

    ENDIF.

  ENDMETHOD.


  METHOD fpm_popup.
    DATA: lo_event_data TYPE REF TO if_fpm_parameter.

    CREATE OBJECT lo_event_data TYPE cl_fpm_parameter.

    lo_event_data->set_value(
      EXPORTING
        iv_key   = 'IV_CALLBACK_EVENT_ID'
        iv_value = iv_callback_event_id
    ).

    lo_event_data->set_value(
      EXPORTING
        iv_key   = 'IO_EVENT'
        iv_value = io_event
    ).

    open_popup( lo_event_data ).
  ENDMETHOD.


  METHOD on_ok.
    DATA: lt_callstack   TYPE abap_callstack,
          ls_callstack   TYPE abap_callstack_line,
          lo_class_desc  TYPE REF TO cl_abap_classdescr,
          ls_method_desc TYPE abap_methdescr,
          ls_param_desc  TYPE abap_parmdescr.
    FIELD-SYMBOLS: <lv_value> TYPE any.

    CALL FUNCTION 'SYSTEM_CALLSTACK'
      EXPORTING
        max_level = 1
      IMPORTING
        callstack = lt_callstack.
    READ TABLE lt_callstack INTO ls_callstack INDEX 1.
    lo_class_desc ?= cl_abap_classdescr=>describe_by_name( cl_oo_classname_service=>get_clsname_by_include( ls_callstack-include ) ).
    READ TABLE lo_class_desc->methods INTO ls_method_desc WITH KEY name = ls_callstack-blockname.
    LOOP AT ls_method_desc-parameters INTO ls_param_desc WHERE parm_kind = cl_abap_classdescr=>importing.
      ASSIGN (ls_param_desc-name) TO <lv_value>.
      mo_event_data->set_value(
        EXPORTING
          iv_key   = CONV #( ls_param_desc-name )
          iv_value = <lv_value>
      ).
    ENDLOOP.

    do_callback( ).

  ENDMETHOD.


  METHOD open_popup.
    DATA: lo_comp_usage TYPE REF TO if_wd_component_usage.

    cl_wdr_runtime_services=>get_component_usage(
      EXPORTING
        component            = wdr_task=>application->component
        used_component_name  = gv_wd_comp_id
        component_usage_name = gv_wd_comp_id
        create_component     = abap_true
        do_create            = abap_true
      RECEIVING
        component_usage      = lo_comp_usage
    ).

    go_wd_comp ?= lo_comp_usage->get_interface_controller( ).

    go_wd_comp->open_popup(
        io_event_data = io_event_data
        io_comp_usage = lo_comp_usage
    ).
  ENDMETHOD.


  METHOD wd_popup.
    DATA: lo_event_data TYPE REF TO if_fpm_parameter.

    CREATE OBJECT lo_event_data TYPE cl_fpm_parameter.

    lo_event_data->set_value(
      EXPORTING
        iv_key   = 'IV_CALLBACK_ACTION'
        iv_value = iv_callback_action
    ).

    lo_event_data->set_value(
      EXPORTING
        iv_key   = 'IO_VIEW'
        iv_value = CAST cl_wdr_view( io_view )
    ).

    open_popup( lo_event_data ).
  ENDMETHOD.


  METHOD sh_popup.
    DATA: lo_event_data  TYPE REF TO if_fpm_parameter,
          lo_component_d TYPE REF TO object.
    FIELD-SYMBOLS: <lo_search_help> TYPE REF TO cl_wdr_elementary_search_help.

    lo_component_d = wdr_task=>application->get_component_for_name( 'WDR_F4_ELEMENTARY' )->component->get_delegate( ).
    ASSIGN lo_component_d->('IG_COMPONENTCONTROLLER~SEARCH_HELP') TO <lo_search_help>.

    CREATE OBJECT lo_event_data TYPE cl_fpm_parameter.

    lo_event_data->set_value(
      EXPORTING
        iv_key   = 'IO_SEARCH_HELP'
        iv_value = <lo_search_help>
    ).

    open_popup( lo_event_data ).
  ENDMETHOD.


  METHOD on_close.
    mo_comp_usage->delete_component( ).
  ENDMETHOD.
ENDCLASS.
