"Name: \PR:SAPLSZA1\FO:D0100_OUTPUT\SE:END\EI
ENHANCEMENT 0 ZE_KR_POSTCODE_SZA1.
* KR_POSTCODE
  IF addr1_data-country EQ 'KR' AND
     g_dialog_mode <> display.
    LOOP AT SCREEN.
      IF screen-name = 'ADDR1_DATA-POST_CODE1' OR
         screen-name = 'ADDR1_DATA-STREET' OR
         screen-name = 'ADDR1_DATA-CITY1'.
        screen-value_help = 2.
        IF screen-name = 'ADDR1_DATA-POST_CODE1'.
          screen-length = 8.
        ENDIF.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDENHANCEMENT.
