CLASS zcl_kr_postcode_demo_fpm_form DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_fpm_guibb .
    INTERFACES if_fpm_guibb_form .

    TYPES:
      BEGIN OF ts_address,
        zonecode     TYPE string,
        roadaddress  TYPE string,
        jibunaddress TYPE string,
        ad_pstcd1    TYPE ad_pstcd1,
      END OF ts_address .
  PROTECTED SECTION.
  PRIVATE SECTION.
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
        CHECK: iv_raised_by_own_ui EQ abap_true.
        " input address
        zcl_kr_postcode=>fpm_start2(
          EXPORTING
            iv_callback_event_id = 'ADDR_RETURN'
            io_event             = io_event
        ).

      WHEN 'ADDR_RETURN'.
        CHECK: iv_raised_by_own_ui EQ abap_true.
        " return address
        ev_data_changed = abap_true.
        io_event->mo_event_data->get_value(
          EXPORTING
            iv_key   = 'IS_ADDR'
          IMPORTING
            ev_value = ls_addr
        ).
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

      CASE ls_field_description-name.
        WHEN 'AD_PSTCD1'.
          ls_field_description-read_only = abap_false.
          ls_field_description-ddic_shlp_name = 'ZH_KR_POSTCODE'.
      ENDCASE.

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
