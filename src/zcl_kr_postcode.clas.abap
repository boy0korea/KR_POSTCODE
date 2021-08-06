class ZCL_KR_POSTCODE definition
  public
  create public .

public section.
  class ZCL_KR_POSTCODE definition load .

  types:
    BEGIN OF ts_addr,
        kr60                    TYPE text60,  " STREET 필드용 길이 60자
        kr40                    TYPE text40,  " CITY 필드용 길이 40자
        en60                    TYPE text60,  " STREET 필드용 길이 60자 (영문)
        en40                    TYPE text40,  " CITY 필드용 길이 40자 (영문)
        kr_old60                TYPE text60,  " STREET 필드용 길이 60자 (구주소)
        kr_old40                TYPE text40,  " CITY 필드용 길이 40자 (구주소)
        zonecode                TYPE string,  " 우편번호
        address                 TYPE string,
        addressenglish          TYPE string,
        addresstype             TYPE string,
        userselectedtype        TYPE string,
        noselected              TYPE string,
        userlanguagetype        TYPE string,
        roadaddress             TYPE string,  " 도로명 주소
        roadaddressenglish      TYPE string,  " 도로명 주소 (영문)
        jibunaddress            TYPE string,
        jibunaddressenglish     TYPE string,
        autoroadaddress         TYPE string,
        autoroadaddressenglish  TYPE string,
        autojibunaddress        TYPE string,
        autojibunaddressenglish TYPE string,
        buildingcode            TYPE string,
        buildingname            TYPE string,
        apartment               TYPE string,
        sido                    TYPE string,
        sidoenglish             TYPE string,
        sigungu                 TYPE string,
        sigunguenglish          TYPE string,
        sigungucode             TYPE string,
        roadnamecode            TYPE string,
        bcode                   TYPE string,
        roadname                TYPE string,
        roadnameenglish         TYPE string,
        bname                   TYPE string,
        bnameenglish            TYPE string,
        bname1                  TYPE string,
        bname1english           TYPE string,
        bname2                  TYPE string,
        bname2english           TYPE string,
        hname                   TYPE string,
        query                   TYPE string,
      END OF ts_addr .

  data MS_ADDR type TS_ADDR .

  events GUI_SELECT
    exporting
      value(IS_ADDR) type ZCL_KR_POSTCODE=>TS_ADDR .

  class-methods GUI_START2
    returning
      value(RS_ADDR) type ZCL_KR_POSTCODE=>TS_ADDR .
  class-methods WD_START2
    importing
      !IV_CALLBACK_ACTION type STRING
      !IO_VIEW type ref to IF_WD_VIEW_CONTROLLER .
  class-methods FPM_START2
    importing
      !IV_CALLBACK_EVENT_ID type FPM_EVENT_ID default 'ZKR_POSTCODE'
      !IO_EVENT type ref to CL_FPM_EVENT .
  class-methods CONVERT_JSON_TO_ADDR
    importing
      !IV_JSON type CLIKE
    returning
      value(RS_ADDR) type TS_ADDR .
  class-methods README .
  class-methods README_SMW0_ZKR_POSTCODE .
protected section.
private section.

  data MO_GUI_POPUP type ref to CL_GUI_DIALOGBOX_CONTAINER .
  data MO_GUI_FULL_SCREEN type ref to CL_GUI_DOCKING_CONTAINER .
  data MO_GUI_HTML_VIEWER type ref to CL_GUI_HTML_VIEWER .
ENDCLASS.



CLASS ZCL_KR_POSTCODE IMPLEMENTATION.


  METHOD convert_json_to_addr.
    DATA: lt_string     TYPE TABLE OF string,
          lv_string     TYPE string,
          lv_json_name  TYPE string,
          lv_json_value TYPE string,
          lv_pivot      TYPE string,
          lv_dummy      TYPE string.
    FIELD-SYMBOLS: <lv_data> TYPE data.

    CHECK: iv_json IS NOT INITIAL.

**********************************************************************
    " /ui2/cl_json 이 있는 경우 사용 가능.
    /ui2/cl_json=>deserialize(
      EXPORTING
        json = iv_json
      CHANGING
        data = rs_addr
    ).
**********************************************************************
**    " /ui2/cl_json 이 없는 경우 대체 코드.
*    lv_string = iv_json.
*    REPLACE '{"' IN lv_string WITH ''.
*    REPLACE '"}' IN lv_string WITH ''.
*    SPLIT lv_string AT '","' INTO TABLE lt_string.
*    LOOP AT lt_string INTO lv_string.
*      SPLIT lv_string AT '":"' INTO lv_json_name lv_json_value.
*      CONDENSE: lv_json_name, lv_json_value.
*      TRANSLATE lv_json_name TO UPPER CASE.
*      ASSIGN COMPONENT lv_json_name OF STRUCTURE rs_addr TO <lv_data>.
*      CHECK: sy-subrc EQ 0.
*      <lv_data> = lv_json_value.
*    ENDLOOP.
**********************************************************************

    " 추가 필드 = 60 + 40 = street + city
    lv_pivot = rs_addr-sigunguenglish.
    IF lv_pivot IS INITIAL.
      lv_pivot = rs_addr-sidoenglish.
    ENDIF.
    IF lv_pivot CA space.
      " 두 단어이면 앞에꺼. 예: Bundang-gu Seongnam-si
      SPLIT lv_pivot AT space INTO lv_pivot lv_dummy.
    ENDIF.
    lv_pivot = lv_pivot && ','.

    SPLIT rs_addr-roadaddressenglish AT lv_pivot INTO rs_addr-en60 rs_addr-en40.
    CONDENSE: rs_addr-en60, rs_addr-en40.
    IF strlen( rs_addr-en40 ) + strlen( lv_pivot ) + 1 <= 40.
      " 도로명 / 시군구+시도
      CONCATENATE lv_pivot rs_addr-en40 INTO rs_addr-en40 SEPARATED BY space.
    ELSE.
      " 도로명+시군구 / 시도
      CONCATENATE rs_addr-en60 lv_pivot INTO rs_addr-en60 SEPARATED BY space.
    ENDIF.
    CONDENSE: rs_addr-en60, rs_addr-en40.


    " 한글은 = 40 + 60 = city + street
    lv_pivot = rs_addr-sigungu.
    IF lv_pivot IS INITIAL.
      lv_pivot = rs_addr-sido.
    ENDIF.
    IF lv_pivot CA space.
      " 두 단어이면 뒤에꺼. 예: 성남시 분당구
      SPLIT lv_pivot AT space INTO lv_dummy lv_pivot.
    ENDIF.

    SPLIT rs_addr-roadaddress AT lv_pivot INTO rs_addr-kr40 rs_addr-kr60.
    CONDENSE: rs_addr-kr40, rs_addr-kr60.
    IF strlen( rs_addr-kr40 ) + strlen( lv_pivot ) + 1 <= 40.
      " 시도+시군구 / 도로명
      CONCATENATE rs_addr-kr40 lv_pivot INTO rs_addr-kr40 SEPARATED BY space.
    ELSE.
      " 시도 / 시군구+도로명
      CONCATENATE lv_pivot rs_addr-kr60 INTO rs_addr-kr60 SEPARATED BY space.
    ENDIF.
    CONDENSE: rs_addr-kr40, rs_addr-kr40.

    SPLIT rs_addr-jibunaddress AT lv_pivot INTO rs_addr-kr_old40 rs_addr-kr_old60.
    CONDENSE: rs_addr-kr_old40, rs_addr-kr_old60.
    IF strlen( rs_addr-kr_old40 ) + strlen( lv_pivot ) + 1 <= 40.
      " 시도+시군구 / 동 이하
      CONCATENATE rs_addr-kr_old40 lv_pivot INTO rs_addr-kr_old40 SEPARATED BY space.
    ELSE.
      " 시도 / 시군구+동 이하
      CONCATENATE lv_pivot rs_addr-kr_old60 INTO rs_addr-kr_old60 SEPARATED BY space.
    ENDIF.
    CONDENSE: rs_addr-kr_old40, rs_addr-kr_old60.


  ENDMETHOD.                    "convert_json_to_addr


  METHOD fpm_start2.
    zcl_zkr_postcode_v2=>fpm_popup(
      EXPORTING
        iv_callback_event_id = iv_callback_event_id
        io_event             = io_event
    ).
  ENDMETHOD.


  METHOD gui_start2.
    CALL FUNCTION 'ZKR_POSTCODE_OPEN'
      IMPORTING
        es_addr        = rs_addr.
  ENDMETHOD.                    "gui_start


  METHOD readme.
**********************************************************************
* 설명서
**********************************************************************
* 배포처: https://github.com/boy0korea/KR_POSTCODE
* 버전: 2.0 (2021.07.09)
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
    DATA: io_event TYPE REF TO cl_fpm_event.
    " 시작:
    zcl_kr_postcode=>fpm_start2(
        iv_callback_event_id = 'ZKR_POSTCODE'
        io_event             = io_event
    ).
    " 종료: iv_callback_event_id 에서 입력한 이벤트 일때 구현하세요.
    io_event->mo_event_data->get_value(
      EXPORTING
        iv_key   = 'IS_ADDR'
      IMPORTING
        ev_value = ls_addr
    ).
    " 데모: ZKR_POSTCODE_DEMO_FPM
    DATA: lo_fpm_feeder TYPE REF TO zcl_kr_postcode_demo_fpm_form.


    " for WD
    " 시작:
    zcl_kr_postcode=>wd_start2(
      EXPORTING
        iv_callback_action = 'ZKR_POSTCODE'
        io_view            = wdr_task=>application->focused_view_element->get_view( ) " wd_ths->wd_get_api( )
    ).
    " 종료: iv_callback_action 에서 입력한 ACTION에 구현하세요.
    DATA: wdevent TYPE REF TO cl_wd_custom_event.
    wdevent->get_data(
      EXPORTING
        name  = 'IS_ADDR'
      IMPORTING
        value = ls_addr
    ).
    " 데모: ZKR_POSTCODE_DEMO_WD


    " for SAP GUI
    " 시작:
    ls_addr = zcl_kr_postcode=>gui_start2( ).
    " 데모: ZKR_POSTCODE_DEMO_GUI
    SUBMIT zkr_postcode_demo_gui.


    " search help: ZH_KR_POSTCODE
    DEFINE sh.
      PARAMETERS: p_x TYPE ad_pstcd1 MATCHCODE OBJECT zh_kr_postcode.
    END-OF-DEFINITION.


**********************************************************************
* 기타 설명
**********************************************************************
    " Web Object 업로드 필요함. --> abapGit 사용으로 자동 추가 됨.
    readme_smw0_zkr_postcode( ).


**********************************************************************
* 버전별 변경 기록
**********************************************************************
* 1.0 (2021.03.30) 최초 공개
* 1.1 (2021.03.31) BSP page에서 상단에 back 버튼 추가
* 1.2 (2021.04.01) 지번주소 60자,40자 필드 추가
* 2.0 (2021.07.09) 스탠다드 주소 입력 부분 enhancement 추가
*                  WD 와 FPM 내부팝업 형태로 변경한 version 2 추가

  ENDMETHOD.                    "readme


  METHOD readme_smw0_zkr_postcode.
    ASSERT 1 = 0.
* 티코드 SMW0 에서 object = ZKR_POSTCODE 를 만들어서 첨부 파일 업로드해야 함.

*<!DOCTYPE html>
*<html>
*<head>
*  <title>우편번호 입력</title>
*</head>
*<body>
*<div id="wrap" style="display:none;border:1px solid;width:100%;height:100%;margin:5px 0;position:relative">
*<img src="http://t1.daumcdn.net/postcode/resource/images/close.png" id="btnFoldWrap" style="cursor:pointer;position:absolute;right:0px;top:-1px;z-index:1" onclick="foldDaumPostcode()" alt="접기 버튼">
*</div>
*<form id="post" method="post" action="SAPEVENT:RETURN"><input id="return" type="hidden" name="return" value=""></form>
*<script src="http://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
*<script>
*    // 우편번호 찾기 찾기 화면을 넣을 element
*    var element_wrap = document.getElementById('wrap');
*    var element_post = document.getElementById('post');
*    var element_return = document.getElementById('return');
*    function foldDaumPostcode() {
*        element_post.submit();
*    }
*    function sample3_execDaumPostcode() {
*        new daum.Postcode({
*            oncomplete: function(data) {
*                // 검색결과 항목을 클릭했을때 실행할 코드를 작성하는 부분.
*                element_return.value = JSON.stringify(data);
*                element_post.submit();
*            },
*            // 우편번호 찾기 화면 크기가 조정되었을때 실행할 코드를 작성하는 부분. iframe을 넣은 element의 높이값을 조정한다.
*            onresize : function(size) {
*                element_wrap.style.height = size.height+'px';
*            },
*            width : '100%',
*            height : '100%'
*        }).embed(element_wrap);
*        // iframe을 넣은 element를 보이게 한다.
*        element_wrap.style.display = 'block';
*    }
*    sample3_execDaumPostcode();
*</script>
*</body>
*</html>
  ENDMETHOD.                    "README_SMW0_ZKR_POSTCODE


  METHOD WD_START2.
    zcl_zkr_postcode_v2=>wd_popup(
      EXPORTING
        iv_callback_action = iv_callback_action
        io_view            = io_view
    ).
  ENDMETHOD.                    "wd_start
ENDCLASS.
