-- Create table

create table MCS.MCS_NTFN_MSG

(

  ntfn_msg_id            NUMBER(9) not null,

  ntfn_msg_user_id       VARCHAR2(8),

  ntfn_msg_type          VARCHAR2(1),

  crtn_tmst              DATE,

  crtn_user_id           VARCHAR2(8),

  ena_msg_id             NUMBER(11),

  last_uptd_tmst         DATE,

  last_uptd_user_id      VARCHAR2(8),

  ntfn_id                NUMBER(9) not null,

  ntfn_stat_seq_id       NUMBER(4) not null,

  crtn_user_trck_id      VARCHAR2(8),

  last_uptd_user_trck_id VARCHAR2(8),

  orgl_msg_fmt_data      BLOB,

  msg_dlvy_chnl_type     VARCHAR2(1),

  ods_load_tmst          DATE default SYSDATE,

  msg_dlvy_addr          VARCHAR2(150)

);

-- Create table

create table MCS.MCS_NTFN_MSG_STAT

(

  ntfn_msg_stat_id       NUMBER(9) not null,

  ntfn_msg_id            NUMBER(9) not null,

  ntfn_hist_stat_ind     VARCHAR2(1),

  ntfn_msg_stat_code     VARCHAR2(1),

  msg_stat_crtn_tmst     DATE,

  crtn_tmst              DATE,

  crtn_user_id           VARCHAR2(8),

  crtn_user_trck_id      VARCHAR2(8),

  last_uptd_tmst         DATE,

  last_uptd_user_id      VARCHAR2(8),

  last_uptd_user_trck_id VARCHAR2(8),

  ods_load_tmst          DATE default SYSDATE

);

-- Create table

create table MCS.MCS_NTFN_EMAL

(

  ntfn_id        NUMBER(9) not null,

  ntfn_emal_id   NUMBER(9) not null,

  emal_user_id   VARCHAR2(8),

  ntfn_emal_addr VARCHAR2(100),

  crtn_tmst      DATE default SYSDATE,

  crtn_user_id   VARCHAR2(8),

  ods_load_tmst  DATE default SYSDATE

);

-- Create table

create table MCS.MCS_NTFN_MSG_STAT

(

  ntfn_msg_stat_id       NUMBER(9) not null,

  ntfn_msg_id            NUMBER(9) not null,

  ntfn_hist_stat_ind     VARCHAR2(1),

  ntfn_msg_stat_code     VARCHAR2(1),

  msg_stat_crtn_tmst     DATE,

  crtn_tmst              DATE,

  crtn_user_id           VARCHAR2(8),

  crtn_user_trck_id      VARCHAR2(8),

  last_uptd_tmst         DATE,

  last_uptd_user_id      VARCHAR2(8),

  last_uptd_user_trck_id VARCHAR2(8),

  ods_load_tmst          DATE default SYSDATE

);

-- Create table

create table MCS.MCS_NTFN

(

  ntfn_id                NUMBER(9) not null,

  ord_hdr_id             NUMBER(9),

  ntfn_sevr_code         VARCHAR2(3),

  ntfn_type_code         VARCHAR2(3),

  ntfn_resn_code         VARCHAR2(3),

  phys_resr_id           NUMBER(9),

  pr_ty_sup_id           NUMBER(9),

  crtn_lnr_loca_spot_id  NUMBER(6),

  repr_fac_area_id       NUMBER(4),

  crtn_tmst              DATE default SYSDATE,

  crtn_user_id           VARCHAR2(8),

  last_uptd_tmst         DATE,

  last_uptd_user_id      VARCHAR2(8),

  ods_load_tmst          DATE default SYSDATE,

  crtn_user_trck_id      VARCHAR2(8),

  prob_cntr_msur_sht_ind VARCHAR2(1),

  ord_item_ord_hdr_id    NUMBER(9),

  ord_item_phys_resr_id  NUMBER(9),

  item_work_id           NUMBER(6),

  ntfn_src_ind           VARCHAR2(3),

  last_uptd_user_trck_id VARCHAR2(8),

  ntfn_catg_ind          VARCHAR2(1)

);

-- Create table

create table MCS.MCS_NTFN_STAT

(

  ntfn_id                NUMBER(9) not null,

  seq_id                 NUMBER(4) not null,

  ntfn_hist_stat_ind     VARCHAR2(1),

  ntfn_stat_code         VARCHAR2(1),

  cmnt_text              VARCHAR2(500),

  crtn_tmst              DATE default SYSDATE,

  crtn_user_id           VARCHAR2(8),

  last_uptd_tmst         DATE,

  last_uptd_user_id      VARCHAR2(8),

  ods_load_tmst          DATE default SYSDATE,

  crtn_user_trck_id      VARCHAR2(8),

  last_uptd_user_trck_id VARCHAR2(8)

);

-- Create table

create table MCS.MCS_NTFN_STAT_CMNT

(

  ntfn_stat_cmnt_id      NUMBER(9) not null,

  ntfn_id                NUMBER(9) not null,

  ntfn_stat_seq_id       NUMBER(4) not null,

  ntfn_hist_stat_ind     VARCHAR2(1),

  cmnt_text              VARCHAR2(500),

  crtn_tmst              DATE,

  crtn_user_id           VARCHAR2(8),

  last_uptd_tmst         DATE,

  last_uptd_user_id      VARCHAR2(8),

  crtn_user_trck_id      VARCHAR2(8),

  last_uptd_user_trck_id VARCHAR2(8),

  ods_load_tmst          DATE default SYSDATE,

  dev_id                 VARCHAR2(30)

);