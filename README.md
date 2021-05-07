METHOD readme.
**********************************************************************
* 설명서
**********************************************************************
* 배포처: https://boy0.tistory.com/164
* 버전: 1.2 (2021.04.01)
* 참고: 다음 우편번호 API - Daum
*       https://postcode.map.daum.net/guide


**********************************************************************
* 데모: ZKR_POSTCODE_DEMO
**********************************************************************
    SUBMIT zkr_postcode_demo.


**********************************************************************
* 리턴값 설명
**********************************************************************
    DATA: ls_addr TYPE zcl_kr_postcode=>ts_addr.

    ls_addr-kr60 = 'STREET 필드용 길이 60자'.
    ls_addr-kr40 = 'CITY 필드용 길이 40자'.
    ls_addr-en60 = 'STREET 필드용 길이 60자'.
    ls_addr-en40 = 'CITY 필드용 길이 40자'.
    ls_addr-zonecode = '우편번호'.
    ls_addr-roadaddress = '도로명 주소 한글'.
    ls_addr-roadaddressenglish = '도로명 주소 영문'.
    ls_addr-jibunaddress = '(구)지번 주소 한글'.
    ls_addr-jibunaddressenglish = '(구)지번 주소 영문'.
    " 기타 리턴값은 위 guide 홈페이지에서 확인하세요.
    " 60/40 으로 나누는 기준은 CONVERT_JSON_TO_ADDR 메소드에 있는 로직을 참고하세요.
    convert_json_to_addr( space ).


**********************************************************************
* 메소드 설명
**********************************************************************
    " for FPM
    " 시작:
    zcl_kr_postcode=>fpm_start( ).
    " 종료: FPM_RESUME 이벤트 일때 호출하세요.
    DATA: lo_fpm_event TYPE REF TO cl_fpm_event.
    ls_addr = zcl_kr_postcode=>fpm_end( io_event = lo_fpm_event ).
    " 데모: ZKR_POSTCODE_DEMO_FPM
    CALL TRANSACTION 'WDYID'.
    DATA: lo_fpm_feeder TYPE REF TO zcl_kr_postcode_demo_fpm_form.


    " for WD
    " 시작:
    zcl_kr_postcode=>wd_start( ).
    " 종료: inbound PLUG RESUME 에서 호출하세요.
    DATA: lo_wdevent TYPE REF TO cl_wd_custom_event.
    ls_addr = zcl_kr_postcode=>wd_end( io_wdevent = lo_wdevent ).
    " 데모: ZKR_POSTCODE_DEMO_WD
    CALL TRANSACTION 'WDYID'.


    " for SAP GUI
    " 시작:
    DATA: lo_event_handler TYPE REF TO zif_kr_postcode_event.
    zcl_kr_postcode=>gui_start(
      EXPORTING
        io_event_handler = lo_event_handler
*        iv_full_screen   = iv_full_screen
*      RECEIVING
*        ro_postcode      = ro_postcode
    ).
    " 종료: 이벤트 핸들러의 ON_RETURN 메소드를 구현하세요.
    lo_event_handler->on_return( is_addr = ls_addr ).
    " 데모: ZKR_POSTCODE_DEMO_GUI
    SUBMIT zkr_postcode_demo_gui.


    " search help: ZH_KR_POSTCODE
    DEFINE sh.
      parameters: p_x type ad_pstcd1 matchcode object zh_kr_postcode.
    END-OF-DEFINITION.


**********************************************************************
* 기타 설명
**********************************************************************
    " BSP 필요함.
    readme_bsp_zkr_postcode( ).
    " Web Object 업로드 필요함.
    readme_smw0_zkr_postcode( ).


**********************************************************************
* 버전별 변경 기록
**********************************************************************
* 1.0 (2021.03.30) 최초 공개
* 1.1 (2021.03.31) /ui2/cl_json=>deserialize( ) 부분 주석처리
*                  BSP page에서 상단에 back 버튼 추가
* 1.2 (2021.04.01) 지번주소 60자,40자 필드 추가

  ENDMETHOD.                    "readme
