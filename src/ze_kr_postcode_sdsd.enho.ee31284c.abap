"Name: \PR:SAPLSDSD\FO:DETERMINE_SHLP_OF_FIELD\SE:BEGIN\EI
ENHANCEMENT 0 ZE_KR_POSTCODE_SDSD.
*  * KR_POSTCODE
  IF help_infos-dynpprog EQ 'SAPLSZA1' AND
*     help_infos-dynpro EQ '0301' AND
     help_infos-tabname EQ 'ADDR1_DATA' AND
     ( help_infos-fieldname EQ 'POST_CODE1' OR help_infos-fieldname EQ 'STREET' OR help_infos-fieldname EQ 'CITY1' ).

    DATA ZDYNPFIELDS LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.
    DATA zinterface_wa LIKE ddshiface.

    perform dynp_values_read
            tables zdynpfields
            using help_infos.

    READ TABLE zdynpfields WITH KEY fieldname = 'ADDR1_DATA-COUNTRY'.
    IF zdynpfields-fieldvalue EQ 'KR'.    " 국가가 KR 인 경우에만 변경함.
      shlp_top-shlpname = 'ZH_KR_POSTCODE'.
      shlp_top-shlptype = 'SH'.

      zinterface_wa-shlpfield = 'ZONECODE'.
      zinterface_wa-valtabname = 'ADDR1_DATA'.
      zinterface_wa-valfield = 'POST_CODE1'.
      APPEND zinterface_wa to shlp_top-interface.

      IF help_infos-dynpro+2 EQ '04'. " international
        zinterface_wa-shlpfield = 'EN60'.
      ELSE.
        zinterface_wa-shlpfield = 'KR60'.
      ENDIF.
      zinterface_wa-valtabname = 'ADDR1_DATA'.
      zinterface_wa-valfield = 'STREET'.
      APPEND zinterface_wa to shlp_top-interface.

      IF help_infos-dynpro+2 EQ '04'. " international
        zinterface_wa-shlpfield = 'EN40'.
      ELSE.
        zinterface_wa-shlpfield = 'KR40'.
      ENDIF.
      zinterface_wa-valtabname = 'ADDR1_DATA'.
      zinterface_wa-valfield = 'CITY1'.
      APPEND zinterface_wa to shlp_top-interface.
    ENDIF.

  ENDIF.

ENDENHANCEMENT.
