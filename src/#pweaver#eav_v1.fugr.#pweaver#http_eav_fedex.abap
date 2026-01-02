FUNCTION /PWEAVER/HTTP_EAV_FEDEX.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(SHIPTO_COMPANY)
*"     REFERENCE(SHIPTO_ADDRESS1)
*"     REFERENCE(SHIPTO_ADDRESS2)
*"     REFERENCE(SHIPTO_STATE)
*"     REFERENCE(SHIPTO_CITY)
*"     REFERENCE(SHIPTO_POSTALCODE)
*"     REFERENCE(SHIPTO_COUNTRY)
*"  EXPORTING
*"     REFERENCE(E_SHIPTO_COMPANY)
*"     REFERENCE(E_SHIPTO_ADDRESS1)
*"     REFERENCE(E_SHIPTO_ADDRESS2)
*"     REFERENCE(E_SHIPTO_STATE)
*"     REFERENCE(E_SHIPTO_CITY)
*"     REFERENCE(E_SHIPTO_POSTALCODE)
*"     REFERENCE(E_SHIPTO_COUNTRY)
*"     REFERENCE(E_VALIDATION_STATUS)
*"     REFERENCE(ET_CHANGE_LOG) TYPE  /PWEAVER/TT_STRING
*"     REFERENCE(E_IS_DIFFERENT)
*"     REFERENCE(E_RESIDENTIAL)
*"--------------------------------------------------------------------

data : lt_xml type table of string,
          ls_xml type string.

  types : begin of typ_rates,
           service type string,
           freight type string,
          end of typ_rates.

  data: weight(5) type c,
        total_weight(5) type c,
        v_lines type i,
        lines_v(3),
        count1(3).

  data : shipto_address type string.
*  data : shipto_address2 type string.
  data: ls_carrierconfig type /pweaver/cconfig.

  data: ls_rates type typ_rates.

  DATA : ws_req TYPE string,
         ws_resp TYPE string.

  DATA: rlength TYPE i,
      txlen TYPE string  .

  DATA :  req_len TYPE i,
          resp_len TYPE i.

  DATA: http_client TYPE REF TO if_http_client .

  DATA: l_ixml          TYPE REF TO if_ixml,
        l_streamfactory TYPE REF TO if_ixml_stream_factory,
        l_parser        TYPE REF TO if_ixml_parser,
        l_istream       TYPE REF TO if_ixml_istream,
        l_document      TYPE REF TO if_ixml_document.

  DATA : resp_xstring TYPE xstring.

  data :t1(2), t2(2), t3(2).
  data : time type sy-timlo,
         shipdate type sy-datlo.

  time = sy-timlo.
  shipdate = sy-datlo.

  t1 = sy-timlo+0(2).
  t2 = sy-timlo+2(2).
  t3 = sy-timlo+4(2).

*  PERFORM move_num_to_char_weight USING packages-brgew CHANGING weight.
  select single * from /pweaver/cconfig into ls_carrierconfig where carriertype = 'FEDEX' .

  clear ls_xml.
  refresh lt_xml.
***
  if shipto_address2 is not initial.
    concatenate shipto_address1 shipto_address2 into shipto_address separated by space.
  else.
    shipto_address = shipto_address1.
  endif.

***********************
*  APPEND '<?xml version="1.0" encoding="utf-8"?>' to lt_xml.
  APPEND '<soapenv:Envelope xmlns="http://fedex.com/ws/addressvalidation/v2" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">'
      to lt_xml.
  APPEND '<soapenv:Body>' to lt_xml.
  APPEND '<AddressValidationRequest xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' to lt_xml.
  APPEND '<WebAuthenticationDetail>' to lt_xml.
  APPEND '<CspCredential>' to lt_xml.
  concatenate '<Key>' ls_carrierconfig-cspuserid '</Key>' into ls_xml.
  append ls_xml to lt_xml. clear  ls_xml.
  concatenate '<Password>' ls_carrierconfig-csppassword '</Password>' into ls_xml.
  append ls_xml to lt_xml. clear ls_xml.
  APPEND '</CspCredential>' to lt_xml.
  APPEND '<UserCredential>' to lt_xml.
  concatenate '<Key>' ls_carrierconfig-userid  '</Key>' into ls_xml.
  append ls_xml to lt_xml. clear ls_xml.
  concatenate '<Password>' ls_carrierconfig-password '</Password>' into ls_xml.
  append ls_xml to lt_xml. clear ls_xml.
  APPEND '</UserCredential>' to lt_xml.
  APPEND '</WebAuthenticationDetail>' to lt_xml.
  APPEND '<ClientDetail>' to lt_xml.
  concatenate '<AccountNumber>' ls_carrierconfig-accountnumber '</AccountNumber>' into ls_xml.
  append ls_xml to lt_xml. clear ls_xml.
  concatenate '<MeterNumber>' ls_carrierconfig-metnumber '</MeterNumber>' into ls_xml.
  append ls_xml to lt_xml. clear ls_xml.
  APPEND '</ClientDetail>' to lt_xml.
  APPEND '<TransactionDetail>' to lt_xml.

  CONCATENATE '<CustomerTransactionId>' ls_carrierconfig-accountnumber   '</CustomerTransactionId>' INTO ls_xml.
  APPEND ls_xml TO lt_xml. CLEAR ls_xml.
  APPEND '</TransactionDetail>' to lt_xml.

  APPEND '<Version>' to lt_xml.
  concatenate '<ServiceId>' 'aval' '</ServiceId>' into ls_xml.
  append ls_xml to lt_xml. clear ls_xml.
  concatenate '<Major>' '2' '</Major>' into ls_xml.
  append ls_xml to lt_xml. clear ls_xml.
  concatenate '<Intermediate>' '0' '</Intermediate>' into ls_xml.
  append ls_xml to lt_xml. clear ls_xml.
  concatenate '<Minor>' '0' '</Minor>' into ls_xml.
  append ls_xml to lt_xml. clear ls_xml.
  APPEND '</Version>' to lt_xml.

  concatenate '<RequestTimestamp>' shipdate+0(4) '-' shipdate+4(2) '-'  shipdate+6(2)  'T' t1 ':' t2 ':' t3  '</RequestTimestamp>' into ls_xml.
  append ls_xml to lt_xml. clear ls_xml.

  append '<Options>' to lt_xml.
  CONCATENATE '<VerifyAddresses>' 'true' '</VerifyAddresses>' into ls_xml.
  append ls_xml to lt_xml. clear ls_xml.
  CONCATENATE '<CheckResidentialStatus>' 'true' '</CheckResidentialStatus>' into ls_xml.
  append ls_xml to lt_xml. clear ls_xml.
  CONCATENATE '<MaximumNumberOfMatches>' '5' '</MaximumNumberOfMatches>' into ls_xml.
  append ls_xml to lt_xml. clear ls_xml.
  CONCATENATE '<StreetAccuracy>' 'TIGHT' '</StreetAccuracy>' into ls_xml.
  append ls_xml to lt_xml. clear ls_xml.
  CONCATENATE '<DirectionalAccuracy>' 'LOOSE' '</DirectionalAccuracy>' into ls_xml.
  append ls_xml to lt_xml. clear ls_xml.
  CONCATENATE '<CompanyNameAccuracy>' 'LOOSE' '</CompanyNameAccuracy>' into ls_xml.
  append ls_xml to lt_xml. clear ls_xml.
  append '</Options>' to lt_xml.

  append
  '<AddressesToValidate>' to lt_xml.
  append '<AddressId>WTC</AddressId>' to lt_xml.

  concatenate '<CompanyName>' shipto_company '</CompanyName>' into ls_xml.
  append ls_xml to lt_xml. clear ls_xml.

  append '<Address>' to lt_xml.
  concatenate '<StreetLines>' shipto_address '</StreetLines>' into ls_xml.
  append ls_xml to lt_xml. clear ls_xml.

*  concatenate '<City>' shipto_city '</City>' into ls_xml.
*  append ls_xml to lt_xml. clear ls_xml.
*  concatenate '<StateOrProvinceCode>' shipto_state '</StateOrProvinceCode>' into ls_xml.
*  append ls_xml to lt_xml. clear ls_xml.
  if strlen( shipto_postalcode ) ge 5.
    concatenate '<PostalCode>' shipto_postalcode(5) '</PostalCode>' into ls_xml.
  else.
    concatenate '<PostalCode>' shipto_postalcode '</PostalCode>' into ls_xml.
  endif.
  append ls_xml to lt_xml. clear ls_xml.

*  concatenate '<CountryCode>' shipto_country '</CountryCode>' into ls_xml.
*  append ls_xml to lt_xml. clear ls_xml.
  append '</Address>' to lt_xml.

  append '</AddressesToValidate>' to lt_xml.
  append '</AddressValidationRequest>' to lt_xml.
  append '</soapenv:Body>' to lt_xml.
  append '</soapenv:Envelope>' to lt_xml.

  LOOP AT lt_xml INTO ls_xml.
    REPLACE ALL OCCURRENCES OF '&' IN ls_xml WITH '&amp;'.
    REPLACE ALL OCCURRENCES OF '''' IN ls_xml WITH '&apos;'.
    MODIFY lt_xml FROM ls_xml INDEX sy-tabix.
  ENDLOOP.

  LOOP AT lt_xml INTO ls_xml.
    CONCATENATE ws_req ls_xml INTO ws_req.
  ENDLOOP.

  req_len = STRLEN( ws_req ).
  MOVE:  req_len  TO txlen .

  CALL METHOD cl_http_client=>create
    EXPORTING
      host    = 'gateway.fedex.com'
      service = '443'
      scheme  = '2'
    IMPORTING
      client  = http_client.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  http_client->propertytype_logon_popup = http_client->co_disabled.

  CALL METHOD http_client->request->set_header_field
    EXPORTING
      name  = '~request_method'
      value = 'POST'.

  CALL METHOD http_client->request->set_header_field
    EXPORTING
      name  = '~server_protocol'
      value = 'HTTP/1.1'.

  CALL METHOD http_client->request->set_header_field
    EXPORTING
      name  = '~request_uri'
      value = '/web-services'.

  CALL METHOD http_client->request->set_header_field
    EXPORTING
      name  = 'Content-Type'
      value = 'application/x-www-form-urlencoded; charset=utf-8'.

  CALL METHOD http_client->request->set_header_field
    EXPORTING
      name  = 'Content-Length'
      value = txlen.

  CALL METHOD http_client->request->set_cdata
    EXPORTING
      data   = ws_req
      offset = 0
      length = req_len.

  CALL METHOD http_client->send
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2.

  CALL METHOD http_client->receive
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2
      http_processing_failed     = 3.

  CLEAR ws_resp.

  ws_resp = http_client->response->get_cdata( ).
  resp_len = STRLEN( ws_resp ).

  cl_trex_char_utility=>convert_to_utf8( EXPORTING im_char_string = ws_resp
                                         IMPORTING ex_utf8_string = resp_xstring ).

* Creating the main iXML factory
  CALL METHOD cl_ixml=>create
*  EXPORTING
*    TYPE   = 0
    RECEIVING
      rval   = l_ixml.

* Creating a stream factory
  CALL METHOD l_ixml->create_stream_factory
    RECEIVING
      rval = l_streamfactory.

* Create a stream
  CALL METHOD l_streamfactory->create_istream_xstring
    EXPORTING
      string = resp_xstring
    RECEIVING
      rval   = l_istream.

* Creating a document
  CALL METHOD l_ixml->create_document
    RECEIVING
      rval = l_document.

* Create a Parser
  CALL METHOD l_ixml->create_parser
    EXPORTING
      document       = l_document
      istream        = l_istream
      stream_factory = l_streamfactory
    RECEIVING
      rval           = l_parser.

* If Parsing Failes
  IF l_parser->parse( ) NE 0.
    IF l_parser->num_errors( ) NE 0.
      DATA: parseerror TYPE REF TO if_ixml_parse_error,
      str TYPE string,
      i TYPE i,
      count TYPE i,
      index TYPE i.

      count = l_parser->num_errors( ).
*      WRITE: count, ' parse errors have occured:'.
      index = 0.
      WHILE index < count.
        parseerror = l_parser->get_error( index = index ).
        i = parseerror->get_line( ).
*        WRITE: 'line: ', i.
        i = parseerror->get_column( ).
*        WRITE: 'column: ', i.
        str = parseerror->get_reason( ).
*        WRITE: str.
        index = index + 1.
      ENDWHILE.
    ENDIF.
  ENDIF.

  TYPES :BEGIN OF TY_ADDRESS,
         Changes TYPE STRING,
         DeliveryPointValidation TYPE STRING,
         ResidentialStatus TYPE STRING,
         CompanyName TYPE STRING,
         StreetLines TYPE STRING,
         StreetLines1 TYPE STRING,
         City TYPE STRING,
         StateOrProvinceCode TYPE STRING,
         PostalCode TYPE STRING,
         CountryCode TYPE STRING,
         END OF TY_ADDRESS.

  DATA : IT_ADD TYPE TABLE OF TY_ADDRESS,
         WA_ADD TYPE TY_ADDRESS,
          error type string.
  IF l_parser->is_dom_generating( ) EQ 'X'.
    PERFORM process_fdx_adrs_validation TABLES IT_ADD USING l_document error .
  ENDIF.

  If IT_ADD[] IS  NOT INITIAL.
    read table it_add into wa_add index 1.
    append  wa_add-Changes to ET_CHANGE_LOG.
    e_validation_status = wa_add-DeliveryPointValidation.
    e_residential = wa_add-ResidentialStatus.
    e_shipto_company = wa_add-CompanyName.
    e_shipto_country = wa_add-CountryCode.
    e_shipto_postalcode = wa_add-PostalCode.
    e_shipto_state = wa_add-StateOrProvinceCode.
    e_shipto_city = wa_add-City.
    e_shipto_address1 = wa_add-StreetLines.
    e_shipto_address2 = shipto_address2.
  ENDIF.

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
    e_shipto_postalcode
    e_shipto_country INTO out_adr_string.
  ENDIF.

  TRANSLATE out_adr_string TO UPPER CASE.
  CONDENSE out_adr_string NO-GAPS.
  IF in_adr_string NE out_adr_string.
    e_is_different = 'X'.
  ENDIF.
  REFRESH IT_ADD.
  CLEAR : IT_ADD,WA_ADD.


ENDFUNCTION.
