class ZCL_KR_POSTCODE_DEMO_FPM_FORM definition
  public
  final
  create public .

public section.

  interfaces IF_FPM_GUIBB .
  interfaces IF_FPM_GUIBB_FORM .

  types:
    BEGIN OF ts_address,
        zonecode     TYPE string,
        roadaddress  TYPE string,
        jibunaddress TYPE string,
      END OF ts_address .
protected section.
private section.
ENDCLASS.



CLASS ZCL_KR_POSTCODE_DEMO_FPM_FORM IMPLEMENTATION.


METHOD if_fpm_guibb_form~check_config.
  ENDMETHOD.                    "IF_FPM_GUIBB_FORM~CHECK_CONFIG


METHOD if_fpm_guibb_form~flush.
  ENDMETHOD.                    "IF_FPM_GUIBB_FORM~FLUSH


METHOD if_fpm_guibb_form~get_data.
    DATA: ls_addr TYPE zcl_kr_postcode=>ts_addr.


    CASE io_event->mv_event_id.
      WHEN 'ADDR'.
        zcl_kr_postcode=>fpm_start( ).

      WHEN 'FPM_RESUME'.
        ev_data_changed = abap_true.
        ls_addr = zcl_kr_postcode=>fpm_end( io_event = io_event ).
        CHECK: ls_addr IS NOT INITIAL. " 비어있으면 닫기임.

        MOVE-CORRESPONDING ls_addr TO cs_data.

    ENDCASE.
  ENDMETHOD.                    "IF_FPM_GUIBB_FORM~GET_DATA


METHOD if_fpm_guibb_form~get_default_config.
  ENDMETHOD.                    "IF_FPM_GUIBB_FORM~GET_DEFAULT_CONFIG


METHOD if_fpm_guibb_form~get_definition.
    DATA: ls_address           TYPE ts_address,
          ls_comp              TYPE abap_compdescr,
          ls_field_description TYPE fpmgb_s_formfield_descr,
          ls_action_definition TYPE fpmgb_s_actiondef.

    eo_field_catalog ?= cl_abap_structdescr=>describe_by_data( ls_address ).

    LOOP AT eo_field_catalog->components INTO ls_comp.
      CLEAR: ls_field_description.
      ls_field_description-name = ls_comp-name.
      ls_field_description-label_text = ls_comp-name.
      ls_field_description-read_only = abap_true.

      APPEND ls_field_description TO et_field_description.
    ENDLOOP.


    ls_action_definition-id = 'ADDR'.
    ls_action_definition-text = '우편번호 입력'.
    ls_action_definition-enabled = abap_true.
    APPEND ls_action_definition TO et_action_definition.

  ENDMETHOD.                    "if_fpm_guibb_form~get_definition


METHOD if_fpm_guibb_form~process_event.

  ENDMETHOD.                    "IF_FPM_GUIBB_FORM~PROCESS_EVENT


METHOD if_fpm_guibb~get_parameter_list.
  ENDMETHOD.                    "IF_FPM_GUIBB~GET_PARAMETER_LIST


METHOD if_fpm_guibb~initialize.
  ENDMETHOD.                    "IF_FPM_GUIBB~INITIALIZE
ENDCLASS.
