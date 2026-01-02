*&---------------------------------------------------------------------*
*&  Include           /PWEAVER/EAV_I01
*&---------------------------------------------------------------------*

*{   INSERT         DEVK900289                                        1

MODULE ZPWADDRESSVAL_8309 INPUT.
 CASE sy-ucomm.
when 'ADDVAL'.
fcode = 'T\13'.

read table xvbpa into zz_ls_xvbpa with key parvw = 'WE' posnr = '000000'.

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
  CALL FUNCTION 'ZPW_ECS_ADDRESS_VALIDATION'
          EXPORTING
            shipto_company      = zz_ls_pw_old_adrc-name1
            shipto_address1     = zz_ls_pw_old_adrc-street
            shipto_address2     = zz_ls_pw_old_adrc-str_suppl1
            shipto_state        = zz_ls_pw_old_adrc-region
            shipto_city         = zz_ls_pw_old_adrc-city1
            shipto_postalcode   = zz_ls_pw_old_adrc-post_code1
            shipto_country      = zz_ls_pw_old_adrc-country
          IMPORTING
            e_shipto_company    = zz_ls_pw_new_adrc-name1
            e_shipto_address1   = zz_ls_pw_new_adrc-street
            e_shipto_address2   = zz_ls_pw_new_adrc-str_suppl1
            e_shipto_state      = zz_ls_pw_new_adrc-region
            e_shipto_city       = zz_ls_pw_new_adrc-city1
            e_shipto_postalcode = zz_ls_pw_new_adrc-post_code1
            e_shipto_country    = zz_ls_pw_new_adrc-country
            e_validation_status = zz_lv_validation_status
            et_change_log       = zz_et_change_log
            e_is_different      = zz_lv_is_different
            e_residential       = zz_e_residential.

  IF  zz_lv_is_different = 'X' AND zz_lv_validation_status = 'CONFIRMED'.
          zz_validation_status = 'UNCONFIRMED'.
  endif.

     LOOP AT zz_et_change_log INTO zz_ls_changelog.
          CASE sy-tabix.
            WHEN 1.
              zz_changelog1 = zz_ls_changelog.
            WHEN 2.
              zz_changelog2 = zz_ls_changelog.
            WHEN 3.
              zz_changelog3 = zz_ls_changelog.
            WHEN 4.
              zz_changelog4 = zz_ls_changelog.
            WHEN 5.
              zz_changelog5 = zz_ls_changelog.
            WHEN OTHERS.
          ENDCASE.
        ENDLOOP.

*call method zz_pw_grid1->refresh_table_display.

when 'USENEW'.
  fcode = 'T\13'.
  data: pw_zz_erow type i.

  CALL METHOD zz_pw_grid1->get_current_cell
    IMPORTING
      e_row     = pw_zz_erow
*      e_value   =
*      e_col     =
*      es_row_id =
*      es_col_id =
*      es_row_no =
      .

 READ TABLE ZZ_it_address into ZZ_wa_address INDEX pw_zz_erow .
IF sy-subrc = 0 .

   fcode = 'T\13'.
data zz_pw_answer type c.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
         EXPORTING
*               DEFAULTOPTION  = 'Y'
      textline1      = 'Do you really want to override the shiptoaddress?'
*      textline2      = 'Yes - CANCEL ALL ; No - CANCEL CURRENT SHIPMENT'
      titel          = 'Change Shipto-Party Address'
      start_column   = 25
      start_row      = 6
*               CANCEL_DISPLAY = 'X'
        IMPORTING
             answer         = zz_pw_answer
              .

  if  zz_pw_answer = 'J'.

clear zz_ls_pw_new_adrc-house_num1.
*zz_ls_pw_new_adrc-street         = ZZ_wa_address-STREET.
*zz_ls_pw_new_adrc-str_suppl1     = ZZ_wa_address-STREET2.
*zz_ls_pw_new_adrc-city1          = ZZ_wa_address-city1  .
*zz_ls_pw_new_adrc-region         = ZZ_wa_address-region .
*zz_ls_pw_new_adrc-post_code1     = ZZ_wa_address-post_code1 .
*zz_ls_pw_new_adrc-country        = ZZ_wa_address-country  .

 read table xvbpa into zz_ls_xvbpa with key posnr = '000000' parvw = 'WE' .
            if sy-subrc = 0 and t180-trtyp = 'H'.
              zz_partner_tabix = sy-tabix.
            clear zz_ls_xvbpa-adrnr.
            modify xvbpa from zz_ls_xvbpa index zz_partner_tabix.
              endif.
move-corresponding zz_ls_pw_new_adrc to zz_fis_address .

          call function 'SD_PARTNER_ADDRESS_SET'
         exporting
              fic_objecttype       = 'BUS2032'
              fic_objectkey        = zz_objectkey
              fif_parvw            = 'WE'
              fif_posnr            = zz_ls_xvbpa-posnr
              fif_parnr            = zz_ls_xvbpa-kunnr
              fis_address_comm_others = vbadr
         changing
              fis_address          = zz_fis_address
*              FIS_ADDRESS_COMM     = lvs_addr1_comm
         exceptions
              parameter_incomplete = 1
              object_not_found     = 2
              partner_not_found    = 3
              change_not_possible  = 4
              address_not_ok       = 5
              others               = 6.

*       get partner tables back from partner object
    call function 'SD_PARTNER_DATA_GET'
         exporting
              fic_objecttype       = 'BUS2032'
              fic_objectkey        = zz_objectkey
              fic_xvbuv_merged    = charx
              fic_hvbuv_merged    = charx
         tables
              fet_xvbpa           = xvbpa
              fet_yvbpa           = yvbpa
              fet_xvbuv           = xvbuv
              fet_hvbuv           = hvbuv
              fet_xvbadr          = xvbadr
              fet_yvbadr          = yvbadr
         exceptions
              no_object_specified = 1
              no_object_found     = 2
              merge_failed        = 3
              others              = 4.
    MOVE-CORRESPONDING zz_ls_pw_new_adrc TO zz_ls_pw_old_adrc.
ENDIF.
* MESSAGE I000(ZPW) WITH zz_pw_status.
*call method zz_PW_GRID1->refresh_table_display.
 ENDIF.

endcase.
 ENDMODULE.

*}   INSERT
