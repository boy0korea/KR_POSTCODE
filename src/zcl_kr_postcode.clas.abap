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

  constants GC_BSP_ID type STRING value 'ZKR_POSTCODE' ##NO_TEXT.
  constants GC_RETURN type STRING value 'RETURN' ##NO_TEXT.
  data MS_ADDR type TS_ADDR .

  events GUI_SELECT
    exporting
      value(IS_ADDR) type ZCL_KR_POSTCODE=>TS_ADDR .

  class-methods FPM_START .
  class-methods FPM_END
    importing
      !IO_EVENT type ref to CL_FPM_EVENT
    returning
      value(RS_ADDR) type TS_ADDR .
  class-methods WD_START .
  class-methods WD_END
    importing
      !IO_WDEVENT type ref to CL_WD_CUSTOM_EVENT
    returning
      value(RS_ADDR) type TS_ADDR .
  class-methods GUI_START
    importing
      !IO_EVENT_HANDLER type ref to ZIF_KR_POSTCODE_EVENT
      !IV_FULL_SCREEN type FLAG optional
    returning
      value(RO_POSTCODE) type ref to ZCL_KR_POSTCODE .
  methods FREE .
  methods RETURN
    importing
      !IS_ADDR type ZCL_KR_POSTCODE=>TS_ADDR optional .
protected section.

  class-methods README .
  class-methods README_SMW0_ZKR_POSTCODE .
  class-methods README_BSP_ZKR_POSTCODE .
private section.

  data MO_GUI_POPUP type ref to CL_GUI_DIALOGBOX_CONTAINER .
  data MO_GUI_FULL_SCREEN type ref to CL_GUI_DOCKING_CONTAINER .
  data MO_GUI_HTML_VIEWER type ref to CL_GUI_HTML_VIEWER .

  class-methods GET_BSP_URL
    returning
      value(RV_URL) type STRING .
  class-methods CONVERT_JSON_TO_ADDR
    importing
      !IV_JSON type CLIKE
    returning
      value(RS_ADDR) type TS_ADDR .
  methods GUI_INIT
    importing
      !IO_EVENT_HANDLER type ref to ZIF_KR_POSTCODE_EVENT
      !IV_FULL_SCREEN type FLAG optional .
  methods GUI_ON_CLOSE_POPUP
    for event CLOSE of CL_GUI_DIALOGBOX_CONTAINER .
  methods GUI_ON_SAPEVENT
    for event SAPEVENT of CL_GUI_HTML_VIEWER
    importing
      !ACTION
      !FRAME
      !GETDATA
      !POSTDATA
      !QUERY_TABLE .
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
*    " /ui2/cl_json 이 있는 경우 사용 가능.
*    /ui2/cl_json=>deserialize(
*      EXPORTING
*        json = iv_json
*      CHANGING
*        data = rs_addr
*    ).
**********************************************************************
*    " /ui2/cl_json 이 없는 경우 대체 코드.
    lv_string = iv_json.
    REPLACE '{"' IN lv_string WITH ''.
    REPLACE '"}' IN lv_string WITH ''.
    SPLIT lv_string AT '","' INTO TABLE lt_string.
    LOOP AT lt_string INTO lv_string.
      SPLIT lv_string AT '":"' INTO lv_json_name lv_json_value.
      CONDENSE: lv_json_name, lv_json_value.
      TRANSLATE lv_json_name TO UPPER CASE.
      ASSIGN COMPONENT lv_json_name OF STRUCTURE rs_addr TO <lv_data>.
      CHECK: sy-subrc EQ 0.
      <lv_data> = lv_json_value.
    ENDLOOP.
**********************************************************************

    " 추가 필드 = 60 + 40 = street + city
    lv_pivot = rs_addr-sigungu.
    IF lv_pivot IS INITIAL.
      lv_pivot = rs_addr-sido.
    ENDIF.
    IF lv_pivot CA space.
      " 두 단어이면 뒤에꺼. 예: 성남시 분당구
      SPLIT lv_pivot AT space INTO lv_dummy lv_pivot.
    ENDIF.

    SPLIT rs_addr-roadaddress AT lv_pivot INTO rs_addr-kr60 rs_addr-kr40.
    CONDENSE: rs_addr-kr60, rs_addr-kr40.
    IF strlen( rs_addr-kr60 ) + strlen( lv_pivot ) + 1 <= 60.
      " 시도+시군구 / 도로명
      CONCATENATE rs_addr-kr60 lv_pivot INTO rs_addr-kr60 SEPARATED BY space.
    ELSE.
      " 시도 / 시군구+도로명
      CONCATENATE lv_pivot rs_addr-kr40 INTO rs_addr-kr40 SEPARATED BY space.
    ENDIF.
    CONDENSE: rs_addr-kr60, rs_addr-kr40.

    SPLIT rs_addr-jibunaddress AT lv_pivot INTO rs_addr-kr_old60 rs_addr-kr_old40.
    CONDENSE: rs_addr-kr_old60, rs_addr-kr_old40.
    IF strlen( rs_addr-kr_old60 ) + strlen( lv_pivot ) + 1 <= 60.
      " 시도+시군구 / 동 이하
      CONCATENATE rs_addr-kr_old60 lv_pivot INTO rs_addr-kr_old60 SEPARATED BY space.
    ELSE.
      " 시도 / 시군구+동 이하
      CONCATENATE lv_pivot rs_addr-kr_old40 INTO rs_addr-kr_old40 SEPARATED BY space.
    ENDIF.
    CONDENSE: rs_addr-kr_old60, rs_addr-kr_old40.


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



  ENDMETHOD.                    "convert_json_to_addr


METHOD fpm_end.
    DATA: lt_param TYPE tihttpnvp,
          ls_param TYPE ihttpnvp,
          lv_json  TYPE string.


    CASE io_event->mv_event_id.
      WHEN 'FPM_RESUME'.
        io_event->mo_event_data->get_value(
          EXPORTING
            iv_key   = 'RESUME_URL_PARAMETERS'
          IMPORTING
            ev_value = lt_param
        ).
        READ TABLE lt_param INTO ls_param WITH KEY name = gc_return.
        lv_json = ls_param-value.

        rs_addr = zcl_kr_postcode=>convert_json_to_addr( lv_json ).
    ENDCASE.

  ENDMETHOD.                    "fpm_end


METHOD fpm_start.
    DATA: ls_url_fields TYPE fpm_s_launch_url.

    ls_url_fields-url = get_bsp_url( ).
    ls_url_fields-use_suspend_resume = abap_true.

    cl_fpm=>get_instance( )->get_navigate_to( )->launch_url(
        is_url_fields            = ls_url_fields
    ).
  ENDMETHOD.                    "fpm_start


METHOD free.
    IF mo_gui_html_viewer IS NOT INITIAL.
      mo_gui_html_viewer->free( ).
    ENDIF.
    IF mo_gui_full_screen IS NOT INITIAL.
      mo_gui_full_screen->free( ).
    ENDIF.
    IF mo_gui_popup IS NOT INITIAL.
      mo_gui_popup->free( ).
    ENDIF.

    FREE: mo_gui_html_viewer, mo_gui_full_screen, mo_gui_popup.

  ENDMETHOD.                    "free


METHOD get_bsp_url.
    DATA: lv_bsp_id TYPE bxmnodes-url,
          lv_url    TYPE bxurlg-gen_url.

    lv_bsp_id = gc_bsp_id && '/default.htm'.

    CALL FUNCTION 'BSP_URL_GENERATION'
      EXPORTING
        node_data     = lv_bsp_id
      IMPORTING
        generated_url = lv_url.

    rv_url = lv_url.

  ENDMETHOD.                    "get_bsp_url


METHOD gui_init.
    DATA: lo_parent   TYPE REF TO cl_gui_container,
          lt_event    TYPE cntl_simple_events,
          ls_event    TYPE cntl_simple_event,
          lv_hostname TYPE string,
          lv_bsp_id   TYPE bxmnodes-url,
          lv_url      TYPE bxurlg-gen_url.


    IF io_event_handler IS NOT INITIAL.
      SET HANDLER io_event_handler->on_return FOR me.
    ENDIF.

    IF iv_full_screen EQ abap_false.
      " popup
      CREATE OBJECT mo_gui_popup
        EXPORTING
          width   = 600    " Width of This Container
          height  = 300    " Height of This Container
          top     = 100    " Top Position of Dialog Box
          left    = 100    " Left Position of Dialog Box
          caption = 'Address'.
      SET HANDLER me->gui_on_close_popup FOR mo_gui_popup.
      lo_parent = mo_gui_popup.
    ELSE.
      " full screen
      CREATE OBJECT mo_gui_full_screen
        EXPORTING
          side      = cl_gui_docking_container=>dock_at_bottom
          extension = cl_gui_docking_container=>ws_maximizebox
          caption   = 'Address'.
      lo_parent = mo_gui_full_screen.
    ENDIF.


    CREATE OBJECT mo_gui_html_viewer
      EXPORTING
        parent               = lo_parent
        query_table_disabled = abap_true.
    ls_event-eventid = cl_gui_html_viewer=>m_id_sapevent.
    ls_event-appl_event = abap_true.
    APPEND ls_event TO lt_event.
    mo_gui_html_viewer->set_registered_events( lt_event ).
    SET HANDLER me->gui_on_sapevent FOR mo_gui_html_viewer.


**********************************************************************
    " 이 부분을 주석처리하면 GUI에서는 BSP 사용안함.						
    CALL FUNCTION 'TH_GET_VIRT_HOST_DATA'
      EXPORTING
        protocol = 0
        virt_idx = 0
      IMPORTING
        hostname = lv_hostname
      EXCEPTIONS
        OTHERS   = 3.
**********************************************************************

    IF lv_hostname CA '.'.
      " BSP 사용.
      lv_url = get_bsp_url( ).
      mo_gui_html_viewer->enable_sapsso( abap_true ).
      mo_gui_html_viewer->show_url( lv_url ).
    ELSE.
      " BSP 불가하므로. SAP Web Repository Object 사용.
      mo_gui_html_viewer->load_html_document(
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
        readme_smw0_zkr_postcode( ).
      ENDIF.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
      mo_gui_html_viewer->show_url( lv_url ).
    ENDIF.


  ENDMETHOD.                    "gui_init


METHOD gui_on_close_popup.
    return( ).
  ENDMETHOD.                    "gui_on_close_popup


METHOD gui_on_sapevent.
    DATA: lv_json TYPE string,
          ls_addr TYPE ts_addr.


    CASE action.
      WHEN 'RETURN'.
        CONCATENATE LINES OF postdata INTO lv_json.
        REPLACE 'return=' IN lv_json WITH ''.
        ls_addr = convert_json_to_addr( lv_json ).
        return( ls_addr ).

      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.                    "gui_on_sapevent


METHOD gui_start.
    CREATE OBJECT ro_postcode.

    ro_postcode->gui_init(
      EXPORTING
        io_event_handler = io_event_handler
        iv_full_screen   = iv_full_screen
    ).
  ENDMETHOD.                    "gui_start


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


METHOD readme_bsp_zkr_postcode.
    ASSERT 1 = 0.
* BSP: ZKR_POSTCODE , Page: default.htm 을 만들어 주세요.

*<!DOCTYPE html>
*<html>
*<head>
*  <title>우편번호 입력</title>
*</head>
*<body>
*<button onclick="foldDaumPostcode()"><img src="<%= CL_BSP_MIMES=>SAP_ICON( id = 'ICON_SYSTEM_BACK' )%>" /> back</button>
*<div id="wrap" style="display:none;border:1px solid;width:100%;height:100%;margin:5px 0;position:relative">
*<img src="//t1.daumcdn.net/postcode/resource/images/close.png" id="btnFoldWrap" style="cursor:pointer;position:absolute;right:0px;top:-1px;z-index:1" onclick="foldDaumPostcode()" alt="접기 버튼">
*</div>
*<form id="post" method="post" action=""><input id="return" type="hidden" name="return" value=""></form>
*<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
*<script>
*    // 우편번호 찾기 찾기 화면을 넣을 element
*    var element_wrap = document.getElementById('wrap');
*    var element_post = document.getElementById('post');
*    var element_return = document.getElementById('return');
*    // 웹딘 resumeUrl
*    var resumeUrl = "<%= request->get_form_field( 'sap-wd-resumeurl' )%>";
*    resumeUrl = decodeURIComponent(resumeUrl);
*    if (resumeUrl != "") {
*      element_post.action = resumeUrl;
*    } else {
*      element_post.action = "SAPEVENT:RETURN";
*    }
*    function foldDaumPostcode() {
*        // 웹딘으로 돌아간다.
*        element_post.submit();
*    }
*    function sample3_execDaumPostcode() {
*        new daum.Postcode({
*            oncomplete: function(data) {
*                // 검색결과 항목을 클릭했을때 실행할 코드를 작성하는 부분.
*                // 웹딘으로 돌아간다.
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
*

  ENDMETHOD.                    "README_SMW0_ZKR_POSTCODE


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
*<form id="post" method="post" action=""><input id="return" type="hidden" name="return" value=""></form>
*<script src="http://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
*<script>
*    // 우편번호 찾기 찾기 화면을 넣을 element
*    var element_wrap = document.getElementById('wrap');
*    var element_post = document.getElementById('post');
*    var element_return = document.getElementById('return');
*    // 웹딘 resumeUrl
*    //var resumeUrl = '<%= request->get_form_field( `sap-wd-resumeurl` )%>';
*    //resumeUrl = decodeURIComponent(resumeUrl);
*    //if (resumeUrl != "") {
*    //  element_post.action = resumeUrl;
*    //} else {
*      element_post.action = 'SAPEVENT:RETURN';
*    //}
*    function foldDaumPostcode() {
*        // 웹딘으로 돌아간다.
*        element_post.submit();
*    }
*    function sample3_execDaumPostcode() {
*        new daum.Postcode({
*            oncomplete: function(data) {
*                // 검색결과 항목을 클릭했을때 실행할 코드를 작성하는 부분.
*                // 웹딘으로 돌아간다.
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


METHOD return.
    ms_addr = is_addr.
    RAISE EVENT gui_select
      EXPORTING
        is_addr = is_addr.
    free( ).
  ENDMETHOD.                    "return


METHOD wd_end.
    DATA: lv_json TYPE string.

    lv_json = io_wdevent->get_string( gc_return ).
    rs_addr = zcl_kr_postcode=>convert_json_to_addr( lv_json ).

  ENDMETHOD.                    "wd_end


METHOD wd_start.
    DATA: ls_plug    TYPE wdy_rr_iobound_plug,
          ls_viewman TYPE wdr_viewman_line,
          lo_viewman TYPE REF TO cl_wdr_view_manager,
          lt_param   TYPE wdr_event_parameter_list,
          ls_param   TYPE wdr_event_parameter.
    FIELD-SYMBOLS: <lv_data> TYPE data.

*  wd_this->get_w_main_ctr( )->fire_suspend_plg(
*    url = lv_url
*  ).

    READ TABLE wdr_task=>application->component->component_info->repository->meta_data-outbound_plugs INTO ls_plug WITH KEY plug_type = 2.
    READ TABLE wdr_task=>application->view_managers_for_window INTO ls_viewman WITH KEY name = ls_plug-view_name.
    lo_viewman = ls_viewman-view_manager.
    ls_param-name = 'URL'.
    CREATE DATA ls_param-value TYPE string.
    ASSIGN ls_param-value->* TO <lv_data>.
    <lv_data> = get_bsp_url( ).
    INSERT ls_param INTO TABLE lt_param.

    lo_viewman->if_wdr_view_manager~navigate(
      EXPORTING
        source        = lo_viewman->interface_view
        outbound_plug = ls_plug-plug_name
        parameters    = lt_param
    ).

  ENDMETHOD.                    "wd_start
ENDCLASS.
