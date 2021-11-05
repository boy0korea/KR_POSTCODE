"Name: \PR:SAPLSZA7\FO:D0400_OUTPUT\SE:END\EI
ENHANCEMENT 0 ZE_KR_POSTCODE_SZA7.
* KR_POSTCODE
  IF addr2_data-country EQ 'KR' AND
     g_dialog_mode <> display.
    LOOP AT SCREEN.
      IF screen-name = 'ADDR2_DATA-POST_CODE1' OR
         screen-name = 'ADDR2_DATA-STREET' OR
         screen-name = 'ADDR2_DATA-CITY1'.
        screen-value_help = 2.
        IF screen-name = 'ADDR2_DATA-POST_CODE1'.
          screen-length = 8.
        ENDIF.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDENHANCEMENT.
