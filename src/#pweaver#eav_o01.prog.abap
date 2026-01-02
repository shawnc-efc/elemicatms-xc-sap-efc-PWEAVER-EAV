*&---------------------------------------------------------------------*
*&  Include           /PWEAVER/EAV_O01
*&---------------------------------------------------------------------*

*{   INSERT         DEVK900289                                        1
MODULE ZPWADDRESSVAL OUTPUT.

read table xvbpa into zz_ls_xvbpa with key parvw = 'WE' posnr = '000000'.

 zz_objectkey = vbak-vbeln.

CALL FUNCTION 'SD_PARTNER_DATA_PUT'
         EXPORTING
              FIC_OBJECTTYPE              = 'BUS2032'
             fic_objectkey         =  zz_objectkey
         TABLES
              FRT_XVBPA                   = XVBPA
              FRT_YVBPA                   = YVBPA
              FRT_XVBUV                   = XVBUV
              FRT_HVBUV                   = HVBUV
              FRT_XVBADR                  = XVBADR
              FRT_YVBADR                  = YVBADR
         EXCEPTIONS
              NO_OBJECT_SPECIFIED         = 1
              NO_OBJECT_CREATION_POSSIBLE = 2
              OTHERS                      = 3.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

         CALL FUNCTION 'SD_PARTNER_ADDRESS_GET'
          EXPORTING
            fic_objecttype         = 'BUS2032'
             fic_objectkey         =  zz_objectkey
             fif_parvw             = 'WE'
             fif_posnr             = zz_ls_xvbpa-posnr
             fif_parnr             = zz_ls_xvbpa-kunnr
          IMPORTING
            fes_old_address_format =   zz_lvs_old_address_format
            FES_ADDR1 =  zz_FES_ADDR1
            FES_ADDR2 =  zz_FES_ADDR2
            FES_ADDR3 =  zz_FES_ADDR3
          EXCEPTIONS
            parameter_incomplete   = 1
            object_not_found       = 2
            partner_not_found      = 3
            no_address_found       = 4
            format_not_available   = 5
            address_type_unknown   = 6
            OTHERS                 = 7.

move-corresponding  zz_FES_ADDR1 to  zz_ls_pw_old_adrc.

if zz_pw_custom_container is initial.
  create object zz_pw_custom_container
        exporting
            container_name = zz_pw_address_ctl
        exceptions
            cntl_error = 1
            cntl_system_error = 2
            create_error = 3
            lifetime_error = 4
            lifetime_dynpro_dynpro_link = 5.
    if sy-subrc ne 0.
* add your handling, for example
      call function 'POPUP_TO_INFORM'
           exporting
                titel = zz_pw_g_repid
                txt2  = sy-subrc
                txt1  = 'The control could not be created'(510).
    endif.
* create an instance of alv control
    create object zz_pw_grid1
         exporting i_parent = zz_pw_custom_container.


*
refresh zz_pw_gt_fieldcat.
*DATA ls_fcat type lvc_s_fcat .
*zz_pw_ls_fcat-fieldname = 'COMPANY' .
**ls_fcat-inttype = 'C' .
*zz_pw_ls_fcat-outputlen = '25' .
*zz_pw_ls_fcat-coltext = 'Company' .
*zz_pw_ls_fcat-seltext =  'Company' .
*APPEND zz_pw_ls_fcat to zz_pw_gt_fieldcat .
*CLEAR zz_pw_ls_fcat .

zz_pw_ls_fcat-fieldname = 'ADDRESS1' .
*ls_fcat-inttype = 'C' .
zz_pw_ls_fcat-outputlen = '35' .
zz_pw_ls_fcat-coltext = 'Address 1' .
zz_pw_ls_fcat-seltext =  'Address 1' .
APPEND zz_pw_ls_fcat to zz_pw_gt_fieldcat .
CLEAR zz_pw_ls_fcat .

zz_pw_ls_fcat-fieldname = 'ADDRESS2' .
*ls_fcat-inttype = 'C' .
zz_pw_ls_fcat-outputlen = '35' .
zz_pw_ls_fcat-coltext = 'Address 2' .
zz_pw_ls_fcat-seltext =  'Address 2' .
APPEND zz_pw_ls_fcat to zz_pw_gt_fieldcat .
CLEAR zz_pw_ls_fcat .

zz_pw_ls_fcat-fieldname = 'CITY' .
*ls_fcat-inttype = 'C' .
zz_pw_ls_fcat-outputlen = '20' .
zz_pw_ls_fcat-coltext = 'City' .
zz_pw_ls_fcat-seltext = 'City' .
APPEND zz_pw_ls_fcat to zz_pw_gt_fieldcat .
CLEAR zz_pw_ls_fcat .

zz_pw_ls_fcat-fieldname = 'STATE' .
*ls_fcat-inttype = 'C' .
zz_pw_ls_fcat-outputlen = '6' .
zz_pw_ls_fcat-coltext = 'State' .
zz_pw_ls_fcat-seltext = 'State' .
APPEND zz_pw_ls_fcat to zz_pw_gt_fieldcat .
CLEAR zz_pw_ls_fcat .

zz_pw_ls_fcat-fieldname = 'POSTALCODE' .
*ls_fcat-inttype = 'C' .
zz_pw_ls_fcat-outputlen = '10' .
zz_pw_ls_fcat-coltext = 'PostalCode' .
zz_pw_ls_fcat-seltext =  'PostalCode' .
APPEND zz_pw_ls_fcat to zz_pw_gt_fieldcat .
CLEAR zz_pw_ls_fcat .

zz_pw_ls_fcat-fieldname = 'COUNTRY' .
*ls_fcat-inttype = 'C' .
zz_pw_ls_fcat-outputlen = '7' .
zz_pw_ls_fcat-coltext = 'Country' .
zz_pw_ls_fcat-seltext =  'Country' .
APPEND zz_pw_ls_fcat to zz_pw_gt_fieldcat .
CLEAR zz_pw_ls_fcat .


    zz_pw_gs_layout-grid_title = 'EAV - Enterprise Address Validation'.
    zz_pw_gs_layout-info_fname = 'LINE_COLOR'.

    call method zz_pw_grid1->set_table_for_first_display
         exporting
                   is_layout        = zz_pw_gs_layout

         changing  it_outtab        = zz_it_address[]
                   it_fieldcatalog = zz_pw_gt_fieldcat.

 create object zz_event_receiver.
 set handler zz_event_receiver->zz_pw_handle_double_click for zz_pw_grid1.
ELSE.

call method zz_pw_grid1->refresh_table_display.
ENDIF.

  ENDMODULE.

*}   INSERT
