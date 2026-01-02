FUNCTION /PWEAVER/FEDEX_VALIDATE_ADDRES .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(SHIPTO_COMPANY) OPTIONAL
*"     VALUE(SHIPTO_ADDRESS1) OPTIONAL
*"     VALUE(SHIPTO_ADDRESS2) OPTIONAL
*"     VALUE(SHIPTO_STATE) OPTIONAL
*"     VALUE(SHIPTO_CITY) OPTIONAL
*"     VALUE(SHIPTO_POSTALCODE) OPTIONAL
*"     VALUE(SHIPTO_COUNTRY) OPTIONAL
*"  EXPORTING
*"     VALUE(E_SHIPTO_COMPANY)
*"     VALUE(E_SHIPTO_ADDRESS1)
*"     VALUE(E_SHIPTO_ADDRESS2)
*"     VALUE(E_SHIPTO_STATE)
*"     VALUE(E_SHIPTO_CITY)
*"     VALUE(E_SHIPTO_POSTALCODE)
*"     VALUE(E_SHIPTO_COUNTRY)
*"     VALUE(E_VALIDATION_STATUS)
*"     VALUE(E_IS_DIFFERENT)
*"     VALUE(E_RESIDENTIAL)
*"     VALUE(ET_CHANGE_LOG) TYPE  /PWEAVER/TT_STRING
*"----------------------------------------------------------------------


 DATA : lt_xml TYPE TABLE OF string,
          ls_xml TYPE string.

  TYPES : BEGIN OF typ_rates,
           service TYPE string,
           freight TYPE string,
          END OF typ_rates.

  DATA: weight(5) TYPE c,
        total_weight(5) TYPE c,
        v_lines TYPE i,
        lines_v(3),
        count1(3).

  DATA : shipto_address TYPE string.
  DATA: ls_carrierconfig TYPE /pweaver/cconfig.

  DATA: ls_rates TYPE typ_rates.

  DATA :t1(2), t2(2), t3(2).
  DATA : time TYPE sy-timlo,
         shipdate TYPE sy-datlo.

  time = sy-timlo.
  shipdate = sy-datlo.

  t1 = sy-timlo+0(2).
  t2 = sy-timlo+2(2).
  t3 = sy-timlo+4(2).

*  PERFORM move_num_to_char_weight USING packages-brgew CHANGING weight.
  SELECT SINGLE * FROM /pweaver/cconfig INTO ls_carrierconfig WHERE carriertype = 'FEDEX' .

  CLEAR ls_xml.
  REFRESH lt_xml.

***
  IF shipto_address2 IS NOT INITIAL.
    CONCATENATE shipto_address1 shipto_address2 INTO shipto_address SEPARATED BY space.
  ELSE.
    shipto_address = shipto_address1.
  ENDIF.

***********************
  APPEND '<request>' TO lt_xml.

*  IF ls_carrierconfig-url_confirm IS NOT INITIAL.
*    CONCATENATE '<FEDEXWEBURL>' 'https://gatewaybeta.fedex.com:443/web-services'  '</FEDEXWEBURL>' INTO ls_xml.
*    APPEND ls_xml TO lt_xml.
*  ENDIF.
  CONCATENATE '<CspCredentialKey>' 'XxjJ4Q6Oq7LDKAKI' '</CspCredentialKey>' INTO ls_xml.
  APPEND ls_xml TO lt_xml. CLEAR  ls_xml.
  CONCATENATE '<CspCredentialPassword>' 'WxN0qZC4qD5u7RKi8TYyCpxDF' '</CspCredentialPassword>' INTO ls_xml.
  APPEND ls_xml TO lt_xml. CLEAR ls_xml.
  CONCATENATE '<UserCredentialKey>' 'xQb1VSPANIPiepai'  '</UserCredentialKey>' INTO ls_xml.
  APPEND ls_xml TO lt_xml. CLEAR ls_xml.
  CONCATENATE '<UserCredentialPassword>' 'QFIPeWPt9BpnDne29XKECckWt' '</UserCredentialPassword>' INTO ls_xml.
  APPEND ls_xml TO lt_xml. CLEAR ls_xml.
  CONCATENATE '<AccountNumber>' '213942859' '</AccountNumber>' INTO ls_xml.
  APPEND ls_xml TO lt_xml. CLEAR ls_xml.
  CONCATENATE '<MeterNumber>' '102586976' '</MeterNumber>' INTO ls_xml.
  APPEND ls_xml TO lt_xml. CLEAR ls_xml.

*    CONCATENATE '<UserCredentialKey>' 'R7iEGJlHgfWPDGjK'  '</UserCredentialKey>' INTO ls_xml.
*  APPEND ls_xml TO lt_xml. CLEAR ls_xml.
*  CONCATENATE '<UserCredentialPassword>' 'bzHVcz48ErlM8N4Lni8TxFk8H' '</UserCredentialPassword>' INTO ls_xml.
*  APPEND ls_xml TO lt_xml. CLEAR ls_xml.
*  CONCATENATE '<AccountNumber>' '510159020' '</AccountNumber>' INTO ls_xml.
*  APPEND ls_xml TO lt_xml. CLEAR ls_xml.
*  CONCATENATE '<MeterNumber>' '1244649' '</MeterNumber>' INTO ls_xml.
*  APPEND ls_xml TO lt_xml. CLEAR ls_xml.

  APPEND
  '<Options><MaximumNumberOfMatches>5</MaximumNumberOfMatches></Options>' TO lt_xml.

  APPEND
  '<AddressesToValidate><AddressId>WTC</AddressId>' TO lt_xml.

  CONCATENATE '<CompanyName>' shipto_company '</CompanyName>' INTO ls_xml.
  APPEND ls_xml TO lt_xml. CLEAR ls_xml.

  APPEND '<Address>' TO lt_xml.
  CONCATENATE '<StreetLine1>' shipto_address '</StreetLine1>' INTO ls_xml.
  APPEND ls_xml TO lt_xml. CLEAR ls_xml.


  CONCATENATE '<City>' shipto_city '</City>' INTO ls_xml.
  APPEND ls_xml TO lt_xml. CLEAR ls_xml.
  CONCATENATE '<StateOrProvinceCode>' shipto_state '</StateOrProvinceCode>' INTO ls_xml.
  APPEND ls_xml TO lt_xml. CLEAR ls_xml.
  IF STRLEN( shipto_postalcode ) GE 5.
    CONCATENATE '<PostalCode>' shipto_postalcode(5) '</PostalCode>' INTO ls_xml.
  ELSE.
    CONCATENATE '<PostalCode>' shipto_postalcode '</PostalCode>' INTO ls_xml.
  ENDIF.
  APPEND ls_xml TO lt_xml. CLEAR ls_xml.

  CONCATENATE '<CountryCode>' shipto_country '</CountryCode>' INTO ls_xml.
  APPEND ls_xml TO lt_xml. CLEAR ls_xml.
  APPEND '</Address>' TO lt_xml.

  APPEND '</AddressesToValidate></request>' TO lt_xml.


************************

  DATA filename(80) TYPE c.
  DATA : filename_xml TYPE string.
  CLEAR filename.
  CONCATENATE 'ADDRESSVALIDATE_WFEDEX' '_' sy-datum '_' sy-uzeit '.xml' INTO  filename.

  CONCATENATE  'C:\Shipping\ECS\Request\' filename INTO filename_xml.

  CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
*     BIN_FILESIZE              =
      filename                  =  filename_xml
      filetype                  = 'ASC'
*     APPEND                    = SPACE
*     WRITE_FIELD_SEPARATOR     = SPACE
*     HEADER                    = '00'
*     TRUNC_TRAILING_BLANKS     = SPACE
*     WRITE_LF                  = 'X'
*     COL_SELECT                = SPACE
*     COL_SELECT_MASK           = SPACE
*     DAT_MODE                  = SPACE
*     CONFIRM_OVERWRITE         = SPACE
*     NO_AUTH_CHECK             = SPACE
*     CODEPAGE                  = SPACE
*     IGNORE_CERR               = ABAP_TRUE
*     REPLACEMENT               = '#'
*     WRITE_BOM                 = SPACE
*     TRUNC_TRAILING_BLANKS_EOL = 'X'
*     WK1_N_FORMAT              = SPACE
*     WK1_N_SIZE                = SPACE
*     WK1_T_FORMAT              = SPACE
*     WK1_T_SIZE                = SPACE
*   IMPORTING
*     FILELENGTH                =
    CHANGING
      data_tab                  = lt_xml
    EXCEPTIONS
      file_write_error          = 1
      no_batch                  = 2
      gui_refuse_filetransfer   = 3
      invalid_type              = 4
      no_authority              = 5
      unknown_error             = 6
      header_not_allowed        = 7
      separator_not_allowed     = 8
      filesize_not_allowed      = 9
      header_too_long           = 10
      dp_error_create           = 11
      dp_error_send             = 12
      dp_error_write            = 13
      unknown_dp_error          = 14
      access_denied             = 15
      dp_out_of_memory          = 16
      disk_full                 = 17
      dp_timeout                = 18
      file_not_found            = 19
      dataprovider_exception    = 20
      control_flush_error       = 21
      not_supported_by_gui      = 22
      error_no_gui              = 23
      OTHERS                    = 24
          .
  IF sy-subrc <> 0.
*  MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


  DATA filename2 TYPE string.

  filename2 = 'C:\Shipping\ECS\Response\'.

  CONCATENATE filename2 filename  INTO filename2.

  REFRESH: lt_xml.
  DATA : str1 TYPE c,
         str2 TYPE string.
  DATA : amount TYPE p DECIMALS 3.
  DATA : str_start TYPE i, str_end TYPE i.
  DATA : resp_xstring TYPE xstring.

  DO 1000 TIMES.

    CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
       filename                      = filename2
       filetype                      = 'ASC'
*      HAS_FIELD_SEPARATOR     = SPACE
*      HEADER_LENGTH           = 0
*      READ_BY_LINE            = 'X'
*      DAT_MODE                = SPACE
*      CODEPAGE                = SPACE
*      IGNORE_CERR             = ABAP_TRUE
*      REPLACEMENT             = '#'
*      VIRUS_SCAN_PROFILE      =
*    IMPORTING
*      FILELENGTH              =
*      HEADER                  =
    CHANGING
      data_tab                = lt_xml
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      not_supported_by_gui    = 17
      error_no_gui            = 18
      OTHERS                  = 19
.
    IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      WAIT UP TO 1 SECONDS.
    ELSE.
      EXIT.

    ENDIF.

  ENDDO.
* We got the response.
  CHECK lt_xml IS NOT INITIAL.

  DATA : l_document TYPE REF TO if_ixml_document.

  CALL FUNCTION 'ZPW_ECS_GET_XML_DOCUMENT'
    IMPORTING
      eo_document = l_document
    TABLES
      data_tab    = lt_xml.

  DATA : lt_values      TYPE STANDARD TABLE OF string,
         lt_streetlines TYPE STANDARD TABLE OF string,
         lv_streetline_count TYPE i.

  CALL FUNCTION 'ZPW_ECS_GET_VALUES_BY_TAG'
    EXPORTING
      io_document = l_document
      tag_name    = 'Changes'
    IMPORTING
      values_tab  = lt_values.

  CHECK lt_values IS NOT INITIAL.
  APPEND LINES OF lt_values TO et_change_log.
  REPLACE ALL OCCURRENCES OF '_' IN TABLE et_change_log WITH ` `.

  REFRESH lt_values.

  CALL FUNCTION 'ZPW_ECS_GET_VALUES_BY_TAG'
    EXPORTING
      io_document = l_document
      tag_name    = 'DeliveryPointValidation'
    IMPORTING
      values_tab  = lt_values.

  IF lt_values IS NOT INITIAL.
    READ TABLE lt_values INTO e_validation_status INDEX 1.
  ENDIF.
  REFRESH lt_values.
  CALL FUNCTION 'ZPW_ECS_GET_VALUES_BY_TAG'
    EXPORTING
      io_document = l_document
      tag_name    = 'CompanyName'
    IMPORTING
      values_tab  = lt_values.

  IF lt_values IS NOT INITIAL.
    READ TABLE lt_values INTO e_shipto_company INDEX 1.
  ENDIF.
  REFRESH lt_values.

  CALL FUNCTION 'ZPW_ECS_GET_VALUES_BY_TAG'
    EXPORTING
      io_document = l_document
      tag_name    = 'StreetLines'
    IMPORTING
      values_tab  = lt_values.

  lv_streetline_count = LINES( lt_values ).

  IF lt_values IS NOT INITIAL AND lv_streetline_count GT 1.
    READ TABLE lt_values INTO e_shipto_address1 INDEX 1.
    READ TABLE lt_values INTO e_shipto_address2 INDEX 2.
  ELSEIF lt_values IS NOT INITIAL.
    READ TABLE lt_values INTO e_shipto_address1 INDEX 1.
  ENDIF.

  REFRESH lt_values.

  CALL FUNCTION 'ZPW_ECS_GET_VALUES_BY_TAG'
    EXPORTING
      io_document = l_document
      tag_name    = 'City'
    IMPORTING
      values_tab  = lt_values.

  IF lt_values IS NOT INITIAL.
    READ TABLE lt_values INTO e_shipto_city INDEX 1.
  ENDIF.
  REFRESH lt_values.

  CALL FUNCTION 'ZPW_ECS_GET_VALUES_BY_TAG'
    EXPORTING
      io_document = l_document
      tag_name    = 'StateOrProvinceCode'
    IMPORTING
      values_tab  = lt_values.

  IF lt_values IS NOT INITIAL.
    READ TABLE lt_values INTO e_shipto_state INDEX 1.
  ENDIF.
  REFRESH lt_values.

  CALL FUNCTION 'ZPW_ECS_GET_VALUES_BY_TAG'
    EXPORTING
      io_document = l_document
      tag_name    = 'PostalCode'
    IMPORTING
      values_tab  = lt_values.

  IF lt_values IS NOT INITIAL.
    READ TABLE lt_values INTO e_shipto_postalcode INDEX 1.
  ENDIF.
  REFRESH lt_values.


  CALL FUNCTION 'ZPW_ECS_GET_VALUES_BY_TAG'
    EXPORTING
      io_document = l_document
      tag_name    = 'CountryCode'
    IMPORTING
      values_tab  = lt_values.

  IF lt_values IS NOT INITIAL.
    READ TABLE lt_values INTO e_shipto_country INDEX 1.
  ENDIF.
  REFRESH lt_values.

    CALL FUNCTION 'ZPW_ECS_GET_VALUES_BY_TAG'
    EXPORTING
      io_document = l_document
      tag_name    = 'ResidentialStatus'
    IMPORTING
      values_tab  = lt_values.

  IF lt_values IS NOT INITIAL.
    READ TABLE lt_values INTO e_residential INDEX 1.
  ENDIF.
  REFRESH lt_values.

  DATA : in_adr_string TYPE string,
         out_adr_string TYPE string.

  IF STRLEN( shipto_postalcode ) GE 5.
    CONCATENATE shipto_company
    shipto_address1
    shipto_address2
    shipto_state
    shipto_city
    shipto_postalcode(5)
    shipto_country INTO in_adr_string.
  ELSE.
    CONCATENATE shipto_company
    shipto_address1
    shipto_address2
    shipto_state
    shipto_city
    shipto_postalcode
    shipto_country INTO in_adr_string.
  ENDIF.

  TRANSLATE in_adr_string TO UPPER CASE.
  CONDENSE in_adr_string NO-GAPS.
  IF STRLEN( e_shipto_postalcode ) GE 5.
    CONCATENATE e_shipto_company
    e_shipto_address1
    e_shipto_address2
    e_shipto_state
    e_shipto_city
    e_shipto_postalcode(5)
    e_shipto_country INTO out_adr_string.
  ELSE.
    CONCATENATE e_shipto_company
    e_shipto_address1
    e_shipto_address2
    e_shipto_state
    e_shipto_city
    e_shipto_postalcode(5)
    e_shipto_country INTO out_adr_string.
  ENDIF.

  TRANSLATE out_adr_string TO UPPER CASE.
  CONDENSE out_adr_string NO-GAPS.
  IF in_adr_string NE out_adr_string.
    e_is_different = 'X'.
  ENDIF.



ENDFUNCTION.
