FUNCTION /PWEAVER/UPS_VALIDATE_ADDRESS.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PLANT) TYPE  VBAP-WERKS OPTIONAL
*"     VALUE(VSTEL) TYPE  VBAP-VSTEL OPTIONAL
*"     VALUE(COMPANY) OPTIONAL
*"     VALUE(ADDRESS1) OPTIONAL
*"     VALUE(ADDRESS2) OPTIONAL
*"     VALUE(ADDRESS3) OPTIONAL
*"     VALUE(CITY) OPTIONAL
*"     VALUE(STATE) OPTIONAL
*"     VALUE(POSTALCODE) OPTIONAL
*"     VALUE(COUNTRY) OPTIONAL
*"  EXPORTING
*"     VALUE(ERROR)
*"  TABLES
*"      IT_ADDRESS STRUCTURE  /PWEAVER/EAVADDRESS OPTIONAL
*"----------------------------------------------------------------------

DATA : lt_xml TYPE TABLE OF string,
           ls_xml TYPE string.

  DATA : ws_req TYPE string,
         ws_resp TYPE string.

  DATA : temp1 TYPE string,
         temp2 TYPE string.

  DATA :  req_len TYPE i,
          resp_len TYPE i.

  TYPES : BEGIN OF typ_rates_ups,
          service TYPE string,
          freight TYPE string,
          END OF typ_rates_ups.

  DATA : rates_ups TYPE STANDARD TABLE OF typ_rates_ups.
  DATA: LS_RATES_UPS TYPE TYP_RATES_UPS.
  data: ls_carrierconfig type /PWEAVER/CCONFIG.
  DATA: http_client TYPE REF TO if_http_client .

  DATA: l_ixml          TYPE REF TO if_ixml,
        l_streamfactory TYPE REF TO if_ixml_stream_factory,
        l_parser        TYPE REF TO if_ixml_parser,
        l_istream       TYPE REF TO if_ixml_istream,
        l_document      TYPE REF TO if_ixml_document.

  DATA : resp_xstring TYPE xstring.
  data: weight(5) type C,
        ups_total_weight(5) type c.
*data : it_address like standard table of ZPWEXTADDRESS.

  select single * from /PWEAVER/CCONFIG into ls_carrierconfig where carriertype = 'UPS'.
  refresh lt_xml.

 append '<?xml version="1.0"?>' to lt_xml.
append '<AccessRequest xml:lang="en-US">' to lt_xml.
  concatenate '<AccessLicenseNumber>' ls_carrierconfig-cspuserid
   '</AccessLicenseNumber>' into ls_xml.
  append ls_xml to lt_xml.
  concatenate '<UserId>' ls_carrierconfig-userid '</UserId>' into ls_xml.
  append ls_xml to lt_xml.
  concatenate '<Password>' ls_carrierconfig-password '</Password>' into ls_xml.
  append ls_xml to lt_xml.
 append '</AccessRequest>' to lt_xml.
append '<?xml version="1.0"?>' to lt_xml.
append '<AddressValidationRequest xml:lang="en-US">' to lt_xml.
  append '<Request>' to lt_xml.
    append '<TransactionReference>' to lt_xml.
      append '<CustomerContext>Your Test Case Summary Description</CustomerContext>' to lt_xml.
      append '<XpciVersion>1.0</XpciVersion>' to lt_xml.
    append '</TransactionReference>' to lt_xml.
    append '<RequestAction>XAV</RequestAction>' to lt_xml.
    append '<RequestOption>3</RequestOption>' to lt_xml.
  append '</Request>' to lt_xml.

  append '<AddressKeyFormat>' to lt_xml.
  if company is not initial.
     CONCATENATE '<ConsigneeName>' company '</ConsigneeName>' INto lS_xml.
    append ls_xml to lt_xml.
 endif.
 data: address(100) type c.
 concatenate address1 address2 address3 into address separated by ','.
  IF address IS NOT INITIAL.
    CONCATENATE '<AddressLine>' address '</AddressLine>' INto lS_xml.
    append ls_xml to lt_xml.
  endif.
* IF ADDRESS2 IS NOT INITIAL.
*    CONCATENATE '<AddressLine>' ADDRESS2 '</AddressLine>' INto lS_xml.
*    append ls_xml to lt_xml.
*  endif.
* IF ADDRESS3 IS NOT INITIAL.
*    CONCATENATE '<AddressLine>' ADDRESS3 '</AddressLine>' INto lS_xml.
*    append ls_xml to lt_xml.
*  endif.

if city is not initial.
  concatenate '<PoliticalDivision2>' city '</PoliticalDivision2>' into ls_xml.
  append ls_xml to lt_xml.
endif.

if state is not initial.
  concatenate '<PoliticalDivision1>' state '</PoliticalDivision1>' into ls_xml.
  append ls_xml to lt_xml.
 endif.

 if postalcode is not initial.
   concatenate '<PostcodePrimaryLow>' postalcode '</PostcodePrimaryLow>' into ls_xml.
   append ls_xml to lt_xml.
 endif.
    append '<CountryCode>US</CountryCode>' to lt_xml.
  append '</AddressKeyFormat>' to lt_xml.
append '</AddressValidationRequest>' to lt_xml.

  loop at lt_xml into ls_xml.
    CONCATENATE ws_req ls_xml into ws_req.
  endloop.

  data txlen type string  .
  req_len = STRLEN( ws_req ).
  move:  req_len  to txlen .


  CALL METHOD cl_http_client=>create_by_destination
    EXPORTING
      destination              = 'UPS_EAV'
    IMPORTING
      client                   = http_client
    EXCEPTIONS
      argument_not_found       = 1
      destination_not_found    = 2
      destination_no_authority = 3
      plugin_not_active        = 4
      internal_error           = 5
      OTHERS                   = 6.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

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

  IF l_parser->is_dom_generating( ) EQ 'X'.
    PERFORM process_ups_address_validation TABLES IT_ADDRESS USING l_document error .
  ENDIF.

ENDFUNCTION.
