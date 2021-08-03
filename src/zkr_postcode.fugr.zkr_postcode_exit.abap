FUNCTION zkr_postcode_exit.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCT
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     VALUE(SHLP) TYPE  SHLP_DESCR
*"     VALUE(CALLCONTROL) LIKE  DDSHF4CTRL STRUCTURE  DDSHF4CTRL
*"----------------------------------------------------------------------
  TYPES:
    BEGIN OF lty_stru_list,
*   add fields for the selection list here
      zonecode           TYPE ad_pstcd1,
      roadaddress        TYPE text100,
      roadaddressenglish TYPE text100,
      kr60               TYPE ad_street,
      kr40               TYPE ad_city1,
      en60               TYPE ad_street,
      en40               TYPE ad_city1,
    END OF lty_stru_list.
  DATA: lt_select_list TYPE STANDARD TABLE OF lty_stru_list,
        ls_select_list LIKE LINE OF lt_select_list,
        ls_addr        TYPE zcl_kr_postcode=>ts_addr.

  IF wdr_task=>application IS INITIAL.
    " GUI
    CHECK: callcontrol-step EQ 'SELECT'.

    ls_addr = zcl_kr_postcode=>gui_start2( ).

    IF ls_addr IS INITIAL.
      callcontrol-step = 'EXIT'.
      RETURN.
    ENDIF.

    callcontrol-step = 'RETURN'.
    MOVE-CORRESPONDING ls_addr TO ls_select_list.
    APPEND ls_select_list TO lt_select_list.

* map
    CALL FUNCTION 'F4UT_RESULTS_MAP'
      TABLES
        shlp_tab    = shlp_tab
        record_tab  = record_tab
        source_tab  = lt_select_list
      CHANGING
        shlp        = shlp
        callcontrol = callcontrol.
  ELSE.
    " WD
    CASE callcontrol-step.
      WHEN 'SELECT'.
        DATA(lo_d) = wdr_task=>application->get_component_for_name( 'WDR_F4_ELEMENTARY' )->component->get_delegate( ).
        ASSIGN lo_d->('IG_COMPONENTCONTROLLER~SEARCH_HELP') TO FIELD-SYMBOL(<lo_sh>).
        zcl_zkr_postcode_v2=>sh_popup(
            io_search_help = <lo_sh>
        ).
        callcontrol-step = 'EXIT'.
        RETURN.
      WHEN 'RETURN'.
        MOVE-CORRESPONDING gs_addr TO ls_select_list.
        APPEND ls_select_list TO lt_select_list.

* map
        CALL FUNCTION 'F4UT_RESULTS_MAP'
          TABLES
            shlp_tab    = shlp_tab
            record_tab  = record_tab
            source_tab  = lt_select_list
          CHANGING
            shlp        = shlp
            callcontrol = callcontrol.
    ENDCASE.
  ENDIF.

ENDFUNCTION.
