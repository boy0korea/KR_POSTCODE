interface ZIF_KR_POSTCODE_EVENT
  public .


  methods ON_RETURN
    for event GUI_SELECT of ZCL_KR_POSTCODE
    importing
      !IS_ADDR .
endinterface.
