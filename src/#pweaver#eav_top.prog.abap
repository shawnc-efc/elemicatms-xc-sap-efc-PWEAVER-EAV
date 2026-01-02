*&---------------------------------------------------------------------*
*&  Include           /PWEAVER/EAV_TOP
*&---------------------------------------------------------------------*

*{   INSERT         DEVK900289                                        1


class zz_pw_event_receiver definition deferred.
data: zz_event_receiver type ref to zz_pw_event_receiver .
  data: zz_fes_address_type type  szad_field-addr_type,
      zz_fes_addr1 type  addr1_val,
      zz_fes_addr2 type  addr2_val,
      zz_fes_addr3 type  addr3_val,
      zz_lvs_old_address_format type vbadr.

 data:   zz_lv_validation_status       type string,
             zz_validation_status          type string,
              zz_et_change_log              type table of string,
              zz_ls_changelog              type string,
              zz_lv_is_different            type string,
              zz_e_residential type string.

 data:  ZZ_objecttype type swo_objtyp,
        zz_objectkey type swo_typeid.
  data :  zz_changelog1 type string,
                zz_changelog2 type string,
                zz_changelog3 type string,
                zz_changelog4 type string,
                zz_changelog5 type string.

     data: zz_ls_partner  like vbpa,
          zz_ls_xvbpa like xvbpa,
          zz_ls_yvbpa like yvbpa.

  data: zz_ls_lfa1 type lfa1.
data: zz_ls_pw_old_adrc type adrc,
      zz_ls_pw_new_adrc type adrc.

  data zz_fis_address type addr1_data.
data: zz_partner_tabix type sy-tabix.

DATA BEGIN OF ZZ_wa_address .
        INCLUDE STRUCTURE /PWEAVER/ADDRESS.
DATA sel TYPE c.
DATA END OF ZZ_wa_address.
data : ZZ_it_address like table of ZZ_wa_address with header line.

 DATA zz_pw_ls_fcat type lvc_s_fcat .
   DATA:  zz_PW_g_max type i value 100,
      zz_PW_g_repid like sy-repid,
      zz_pw_gs_layout   type lvc_s_layo,
      zz_pw_address_ctl   type scrfname value 'ADDRESS_CTL',
      zz_pw_grid1  type ref to cl_gui_alv_grid,
      zz_pw_custom_container type ref to cl_gui_custom_container,
      zz_pw_gt_field_catalog TYPE slis_t_fieldcat_alv.
       DATA zz_pw_gt_fieldcat TYPE lvc_t_fcat .

        data:   zz_lv_validation_status       TYPE string,
              zz_validation_status          TYPE string,
              zz_et_change_log              TYPE TABLE OF string,
              zz_ls_changelog              TYPE string,
              zz_lv_is_different            TYPE string,
              zz_residential type string.

  DATA :  zz_changelog1 TYPE string,
                zz_changelog2 TYPE string,
                zz_changelog3 TYPE string,
                zz_changelog4 TYPE string,
                zz_changelog5 TYPE string.
*----------------------------------------------------------------------*
*       CLASS lcl_event_receiver DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
class zz_pw_event_receiver definition.

  public section.
    methods:
*Double-click control
zz_pw_handle_double_click
FOR EVENT double_click OF cl_gui_alv_grid
IMPORTING e_row e_column.

endclass.                    "lcl_event_receiver DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_event_receiver IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
class zz_pw_event_receiver implementation.
  method zz_pw_handle_double_click.
* READ TABLE ZZ_it_address into ZZ_wa_address INDEX e_row .
*IF sy-subrc = 0 .
*
*   fcode = 'T\13'.
*data zz_pw_answer type c.
*  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*         EXPORTING
**               DEFAULTOPTION  = 'Y'
*      textline1      = 'Do you really want to override the shiptoaddress?'
**      textline2      = 'Yes - CANCEL ALL ; No - CANCEL CURRENT SHIPMENT'
*      titel          = 'Change Shipto-Party Address'
*      start_column   = 25
*      start_row      = 6
**               CANCEL_DISPLAY = 'X'
*        IMPORTING
*             answer         = zz_pw_answer
*              .
*
*  if  zz_pw_answer = 'J'.
*IF SY-UNAME = 'DEEPAK'.
*clear zz_ls_pw_new_adrc-house_num1.
*zz_ls_pw_new_adrc-street         = ZZ_wa_address-STREET.
*zz_ls_pw_new_adrc-str_suppl1     = ZZ_wa_address-STREET2.
*zz_ls_pw_new_adrc-city1          = ZZ_wa_address-city1  .
*zz_ls_pw_new_adrc-region         = ZZ_wa_address-region .
*zz_ls_pw_new_adrc-post_code1     = ZZ_wa_address-post_code1 .
*zz_ls_pw_new_adrc-country        = ZZ_wa_address-country  .
*
* read table xvbpa into zz_ls_xvbpa with key posnr = '000000' parvw = 'WE' .
*            if sy-subrc = 0 and t180-trtyp = 'H'.
*              zz_partner_tabix = sy-tabix.
*            clear zz_ls_xvbpa-adrnr.
*            modify xvbpa from zz_ls_xvbpa index zz_partner_tabix.
*              endif.
*move-corresponding zz_ls_pw_new_adrc to zz_fis_address .
*
*          call function 'SD_PARTNER_ADDRESS_SET'
*         exporting
*              fic_objecttype       = 'BUS2032'
*              fic_objectkey        = zz_objectkey
*              fif_parvw            = 'WE'
*              fif_posnr            = zz_ls_xvbpa-posnr
*              fif_parnr            = zz_ls_xvbpa-kunnr
*              fis_address_comm_others = vbadr
*         changing
*              fis_address          = zz_fis_address
**              FIS_ADDRESS_COMM     = lvs_addr1_comm
*         exceptions
*              parameter_incomplete = 1
*              object_not_found     = 2
*              partner_not_found    = 3
*              change_not_possible  = 4
*              address_not_ok       = 5
*              others               = 6.
*
**       get partner tables back from partner object
*    call function 'SD_PARTNER_DATA_GET'
*         exporting
*              fic_objecttype       = 'BUS2032'
*              fic_objectkey        = zz_objectkey
*              fic_xvbuv_merged    = charx
*              fic_hvbuv_merged    = charx
*         tables
*              fet_xvbpa           = xvbpa
*              fet_yvbpa           = yvbpa
*              fet_xvbuv           = xvbuv
*              fet_hvbuv           = hvbuv
*              fet_xvbadr          = xvbadr
*              fet_yvbadr          = yvbadr
*         exceptions
*              no_object_specified = 1
*              no_object_found     = 2
*              merge_failed        = 3
*              others              = 4.
*    MOVE-CORRESPONDING zz_ls_pw_new_adrc TO zz_ls_pw_old_adrc.
*ENDIF.
** MESSAGE I000(ZPW) WITH zz_pw_status.
*call method zz_PW_GRID1->refresh_table_display.
* ENDIF.
*ENDIF.
  endmethod.                    "handle_hotspot_click
  endclass.

*}   INSERT
