*&---------------------------------------------------------------------*
*&  Include           /PWEAVER/LEAV_V1F01
*&---------------------------------------------------------------------*

*{   INSERT         DEVK900289                                        1

*&---------------------------------------------------------------------*
*&      Form  PROCESS_UPS_VALIDATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_ADDRESS  text
*      -->P_L_DOCUMENT  text
*----------------------------------------------------------------------*
FORM PROCESS_UPS_ADDRESS_VALIDATION  TABLES  it_address type table
                 USING document TYPE REF TO if_ixml_document error .


  DATA: node TYPE REF TO if_ixml_node,
  iterator TYPE REF TO if_ixml_node_iterator,
  nodemap TYPE REF TO if_ixml_named_node_map,
  attr TYPE REF TO if_ixml_node,
  name TYPE string,
  prefix TYPE string,
  value TYPE string,
  indent TYPE i,
  count TYPE i,
  index TYPE i.

  data : wa_address type /pweaver/eavADDRESS.

  node ?= document.

  CHECK NOT node IS INITIAL.

  IF node IS INITIAL. EXIT. ENDIF.

* create a node iterator
  iterator = node->create_iterator( ).

* get current node
  node = iterator->get_next( ).

* loop over all nodes

  WHILE NOT node IS INITIAL.

    name = node->get_name( ).
    CASE name.

     WHEN 'NoCandidatesIndicator'.

          node = iterator->get_next( ).
            value = node->get_value( ).
            error = 'UPS did not find a valid matching address.'. "value.
            exit.

      WHEN 'AddressKeyFormat'.
        DO.
          IF node IS INITIAL. EXIT. ENDIF.
          node = iterator->get_next( ).
          name = node->get_name( ).

          IF name = 'AddressLine'.
            node = iterator->get_next( ).
            value = node->get_value( ).
            wa_address-address1 = value.
*            exit.
          endif.
          if name = 'PoliticalDivision2'.
            node = iterator->get_next( ).
            value = node->get_value( ).
            wa_address-city = value.
*            exit.
          endif.
          if name = 'PoliticalDivision1'.
            node = iterator->get_next( ).
            value = node->get_value( ).
            wa_address-state = value.
*            exit.
          endif.
          if name = 'PostcodePrimaryLow'.
            node = iterator->get_next( ).
            value = node->get_value( ).
            wa_address-postalcode = value.
*            exit.
          endif.
          if name = 'CountryCode'.
            node = iterator->get_next( ).
            value = node->get_value( ).
            wa_address-country = value.
            exit.
          endif.
        clear  value.
        ENDDO.


      when  'Error'.
            DO.
              node = iterator->get_next( ).
              IF node IS INITIAL. EXIT. ENDIF.
              name = node->get_name( ).
              IF name = 'ErrorDescription'.
                node = iterator->get_next( ).
                value = node->get_value( ).
                error = value.
                EXIT.
              ENDIF.
            ENDDO.

    ENDCASE.

    IF NOT wa_address IS INITIAL.
      APPEND wa_address TO it_address.
      CLEAR wa_address.
    ENDIF.
    node = iterator->get_next( ).

  ENDWHILE.

ENDFORM.                    " PROCESS_UPS_ADDRESS_VALIDATION

*&---------------------------------------------------------------------*
*&      Form  process_fdx_adrs_validation
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_ADD  text
*      -->P_L_DOCUMENT  text
*      -->P_ERROR  text
*----------------------------------------------------------------------*
form process_fdx_adrs_validation  tables   it_address type table
                        USING    DOCUMENT type ref to if_ixml_document error.


DATA: node TYPE REF TO if_ixml_node,
  iterator TYPE REF TO if_ixml_node_iterator,
  nodemap TYPE REF TO if_ixml_named_node_map,
  attr TYPE REF TO if_ixml_node,
  name TYPE string,
  prefix TYPE string,
  value TYPE string,
  indent TYPE i,
  count TYPE i,
  index TYPE i.

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

  DATA :wa_address TYPE TY_ADDRESS.

  node ?= document.

  CHECK NOT node IS INITIAL.

  IF node IS INITIAL. EXIT. ENDIF.

* create a node iterator
  iterator = node->create_iterator( ).

* get current node
  node = iterator->get_next( ).

* loop over all nodes

  WHILE NOT node IS INITIAL.

    name = node->get_name( ).

    CASE name.


      WHEN 'ProposedAddressDetails'.
        DO.
          IF node IS INITIAL. EXIT. ENDIF.
          node = iterator->get_next( ).
          name = node->get_name( ).

          IF name = 'Changes'.
            node = iterator->get_next( ).
            value = node->get_value( ).
            wa_address-Changes = value.
          endif.

          IF name = 'DeliveryPointValidation'.
            node = iterator->get_next( ).
            value = node->get_value( ).
            wa_address-DeliveryPointValidation = value.
          endif.

          IF name = 'ResidentialStatus'.
            node = iterator->get_next( ).
            value = node->get_value( ).
            wa_address-ResidentialStatus = value.
          endif.


          IF name = 'CompanyName'.
            node = iterator->get_next( ).
            value = node->get_value( ).
            wa_address-CompanyName = value.
*            exit.
          endif.
          if name = 'StreetLines'.
            node = iterator->get_next( ).
            value = node->get_value( ).
            wa_address-StreetLines = value.
*            exit.
          endif.
          if name = 'City'.
            node = iterator->get_next( ).
            value = node->get_value( ).
            wa_address-city = value.
*            exit.
          endif.
          if name = 'StateOrProvinceCode'.
            node = iterator->get_next( ).
            value = node->get_value( ).
            wa_address-StateOrProvinceCode = value.
*            exit.
          endif.

          if name = 'PostalCode'.
            node = iterator->get_next( ).
            value = node->get_value( ).
            wa_address-PostalCode = value.
*            exit.
          endif.

          if name = 'CountryCode'.
            node = iterator->get_next( ).
            value = node->get_value( ).
            wa_address-CountryCode = value.
            exit.
          endif.
          clear  value.
        ENDDO.

      when  'Error'.
        DO.
          node = iterator->get_next( ).
          IF node IS INITIAL. EXIT. ENDIF.
          name = node->get_name( ).
          IF name = 'ErrorDescription'.
            node = iterator->get_next( ).
            value = node->get_value( ).
            error = value.
            EXIT.
          ENDIF.
        ENDDO.

    ENDCASE.

    IF NOT wa_address IS INITIAL.
      APPEND wa_address TO it_address.
      CLEAR wa_address.
    ENDIF.
    node = iterator->get_next( ).

  ENDWHILE.





endform.                    " process_fdx_adrs_validation
*}   INSERT
