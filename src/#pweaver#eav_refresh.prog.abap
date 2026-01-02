*&---------------------------------------------------------------------*
*&  Include           /PWEAVER/EAV_REFRESH
*&---------------------------------------------------------------------*

*{   INSERT         DEVK900289                                        1
CLEAR: zz_fes_address_type,zz_fes_addr1, zz_fes_addr2 ,zz_fes_addr3,zz_lvs_old_address_format.
CLEAR:zz_lv_validation_status ,zz_validation_status, zz_et_change_log,zz_ls_changelog ,zz_lv_is_different, zz_e_residential.
CLEAR:ZZ_objecttype,ZZ_objecttype,zz_changelog1,zz_changelog2,zz_changelog3,zz_changelog4,zz_changelog5.
CLEAR:zz_ls_partner,zz_ls_xvbpa,zz_ls_yvbpa,zz_ls_lfa1,zz_ls_pw_old_adrc ,zz_ls_pw_new_adrc .
CLEAR:zz_fis_address,zz_partner_tabix ,ZZ_wa_address .
REFRESH: ZZ_it_address.

*}   INSERT
