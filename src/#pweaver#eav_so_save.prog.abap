*&---------------------------------------------------------------------*
*&  Include           /PWEAVER/EAV_SO_SAVE
*&---------------------------------------------------------------------*

*{   INSERT         DEVK900289                                        1


DATA: FES_ADDRESS_TYPE TYPE  SZAD_FIELD-ADDR_TYPE,
      FES_ADDR1 TYPE  ADDR1_VAL,
      FES_ADDR2 TYPE  ADDR2_VAL,
      FES_ADDR3 TYPE  ADDR3_VAL.

ZZ_objectkey = vbak-vbeln.

         call function 'SD_PARTNER_ADDRESS_GET'
          exporting
            fic_objecttype         = 'BUS2032'
             fic_objectkey         = zz_objectkey
             fif_parvw             = 'WE'
             fif_posnr             = zz_ls_xvbpa-posnr
             fif_parnr             = zz_ls_xvbpa-kunnr
          importing
            fes_old_address_format =  zz_lvs_old_address_format
            fes_addr1 = zz_fes_addr1
            fes_addr2 = zz_fes_addr2
            fes_addr3 = zz_fes_addr3
          exceptions
            parameter_incomplete   = 1
            object_not_found       = 2
            partner_not_found      = 3
            no_address_found       = 4
            format_not_available   = 5
            address_type_unknown   = 6
            others                 = 7.
*
move-corresponding zz_fes_addr1 to zz_ls_pw_old_adrc.
zz_ls_pw_new_adrc = zz_ls_pw_old_adrc.
refresh  zz_it_address.
   CALL FUNCTION 'ZPW_BAPI_ADDRESS_VALIDATE_UPS'
          EXPORTING
*           PLANT      =
*           VSTEL      =
            COMPANY    = zz_ls_pw_old_adrc-name1
            ADDRESS1   = zz_ls_pw_old_adrc-street
            ADDRESS2   = zz_ls_pw_old_adrc-str_suppl1
*           ADDRESS3   = address3
            CITY       = zz_ls_pw_old_adrc-city1
            STATE      = zz_ls_pw_old_adrc-region
            POSTALCODE = zz_ls_pw_old_adrc-post_code1
            COUNTRY    = zz_ls_pw_old_adrc-country
*          IMPORTING
*            ERROR      = ERROR_MESSAGE
          TABLES
*           ALL_RATES  =
*           PACKAGES   =
            IT_ADDRESS = zz_it_address.

   DATA:pw_add_lines type i.
   describe table zz_it_address lines pw_add_lines.
    if zz_it_address[] IS INITIAL.
    message i000(ZPW) WITH 'Please check the shipto address'.
    elseif pw_add_lines > 1.
     message i000(ZPW) WITH 'Multiple addresses found , Please check'.
    ENDIF.

*}   INSERT
