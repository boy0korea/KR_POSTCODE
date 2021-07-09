
var KR_POSTCODE = KR_POSTCODE || {
	callback: null,	// 웹딘 콜백
	element_layer: null,	// <div>

	addCallback: function (callback) {
		// WDDOMODIFYVIEW 에서 FIRST_TIME 에 한번 호출하여 전달.
		// callback 은 웹딘의 이벤트를 호출하기 위해 필요함.
		// 웹딘과 자바스크립트 연결에 대해서는 아래를 참고하세요:
		// https://archive.sap.com/documents/docs/DOC-34098
		this.callback = callback;
	},
	
	init: function (callback) {
		// 화면이 로드되고 처음 실행되는 펑션. 초기화 로직 넣음.
		this.addCallback(callback);

		// 우편번호 찾기 화면을 넣을 element
		this.element_layer = document.getElementById('layer');
		this.initLayerPosition();

		this.sample2_execDaumPostcode();
	},
	
	clickInfo: function (param) {
		KR_POSTCODE.callback.fireEvent('click_corp', param );
	},
	sample2_execDaumPostcode: function () {
        new daum.Postcode({
            oncomplete: function(data) {
                // 검색결과 항목을 클릭했을때 실행할 코드를 작성하는 부분.
                // 웹딘으로 돌아간다.
                KR_POSTCODE.callback.fireEvent('RETURN', JSON.stringify(data) );
            },
            width : '100%',
            height : '100%',
            maxSuggestItems : 5
        }).embed(this.element_layer);


    },
	initLayerPosition: function (){
        this.element_layer.style.position = 'fixed'
        this.element_layer.style.width = '80%'
        this.element_layer.style.height = '80%'
        this.element_layer.style.left = '10%'
        this.element_layer.style.top = '10%'
        this.element_layer.style.border = '5px solid';
		
		this.element_layer.innerHTML = '<img src="//t1.daumcdn.net/postcode/resource/images/close.png" id="btnCloseLayer" style="cursor:pointer;position:fixed;right:10%;top:10%;margin-right:-10px;z-index:1" onclick="KR_POSTCODE.closeDaumPostcode()" alt="닫기 버튼">'
    },
	closeDaumPostcode: function (){
		KR_POSTCODE.callback.fireEvent('RETURN');
	}
};