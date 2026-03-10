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

)

tablespace MCSTS001

  pctfree 10

  initrans 1

  maxtrans 255

  storage

  (

    initial 1M

    next 1M

    minextents 1

    maxextents unlimited

    pctincrease 0

  );

-- Add comments to the table

comment on table MCS.MCS_NTFN_MSG

  is 'This table contains an audit of the messages sent for the notifications. When originally added by a craft person or when escalated by a supervisor.';

-- Add comments to the columns

comment on column MCS.MCS_NTFN_MSG.ntfn_msg_id

  is 'A generated id, to identify unique notification message rows.';

comment on column MCS.MCS_NTFN_MSG.ntfn_msg_user_id

  is 'Contains the user id of the person who the message was sent to.';

comment on column MCS.MCS_NTFN_MSG.ntfn_msg_type

  is 'The type of the message.

Example of Values:  P = Pop up

C = Cell Phone';

comment on column MCS.MCS_NTFN_MSG.crtn_tmst

  is 'Contains the date and time the record was created.';

comment on column MCS.MCS_NTFN_MSG.crtn_user_id

  is 'Contains the user id of the person who created this row.';

comment on column MCS.MCS_NTFN_MSG.ena_msg_id

  is 'The id of the message sent thru the ENA system.';

comment on column MCS.MCS_NTFN_MSG.last_uptd_tmst

  is 'Contains the date and time the record was last updated.';

comment on column MCS.MCS_NTFN_MSG.last_uptd_user_id

  is 'Contains the user id of the last person to update this row.';

comment on column MCS.MCS_NTFN_MSG.ntfn_id

  is 'The originating notification that the status is for. FK from MCS_NTFN_STAT table.';

comment on column MCS.MCS_NTFN_MSG.ntfn_stat_seq_id

  is 'A generated sequence id, to identify unique status rows for 1 notification. FK from MCS_NTFN_STAT table.';

comment on column MCS.MCS_NTFN_MSG.crtn_user_trck_id

  is 'Contains the user tracking id of the person who created this row.';

comment on column MCS.MCS_NTFN_MSG.last_uptd_user_trck_id

  is 'Contains the employee number of the last person to update this row.';

comment on column MCS.MCS_NTFN_MSG.orgl_msg_fmt_data

  is 'Contains the original message sent to ENA in HTML or whatever format it was sent in.';

comment on column MCS.MCS_NTFN_MSG.msg_dlvy_chnl_type

  is 'Contains the value of the message delivery channel.

Valid value:

P = ENA Pop up';

comment on column MCS.MCS_NTFN_MSG.msg_dlvy_addr

  is 'The final destination delivery address. The data contained varies by the message type sent. For Pop ups, this will be the userid. For SMS it will be the phone number and provider. For emails it will be the email address.';

-- Create/Recreate indexes

create index MCS.MCS_NTFN_MSG_X1 on MCS.MCS_NTFN_MSG (NTFN_ID, NTFN_STAT_SEQ_ID)

  tablespace MCSDFLT001

  pctfree 10

  initrans 2

  maxtrans 255

  storage

  (

    initial 64K

    next 1M

    minextents 1

    maxextents unlimited

  );

-- Create/Recreate primary, unique and foreign key constraints

alter table MCS.MCS_NTFN_MSG

  add constraint MCS_NTFN_MSG_PK primary key (NTFN_MSG_ID)

  using index

  tablespace MCSXS160

  pctfree 1

  initrans 2

  maxtrans 255

  storage

  (

    initial 160K

    next 160K

    minextents 1

    maxextents unlimited

    pctincrease 0

  );

alter table MCS.MCS_NTFN_MSG

  add constraint MCS_NTFN_MSG_F1 foreign key (NTFN_ID, NTFN_STAT_SEQ_ID)

  references MCS.MCS_NTFN_STAT (NTFN_ID, SEQ_ID) on delete cascade;

-- Grant/Revoke object privileges

grant select on MCS.MCS_NTFN_MSG to MCS_READ;



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

)

tablespace MCSTS001

  pctfree 10

  initrans 1

  maxtrans 255

  storage

  (

    initial 1M

    next 1M

    minextents 1

    maxextents unlimited

    pctincrease 0

  );

-- Add comments to the table

comment on table MCS.MCS_NTFN_MSG_STAT

  is 'Description:  This table contains an audit of the status values for the message. When originally added or when updated.';

-- Add comments to the columns

comment on column MCS.MCS_NTFN_MSG_STAT.ntfn_msg_stat_id

  is 'A generated id, to identify unique notification message status rows';

comment on column MCS.MCS_NTFN_MSG_STAT.ntfn_msg_id

  is 'FK to identify unique notification Message rows';

comment on column MCS.MCS_NTFN_MSG_STAT.ntfn_hist_stat_ind

  is 'Designates the ''C'' current row and the ''H'' history rows.';

comment on column MCS.MCS_NTFN_MSG_STAT.ntfn_msg_stat_code

  is 'Designates the status of the message.';

comment on column MCS.MCS_NTFN_MSG_STAT.msg_stat_crtn_tmst

  is 'Contains the date and time the message status was created.';

comment on column MCS.MCS_NTFN_MSG_STAT.crtn_tmst

  is 'Contains the date and time the record was created.';

comment on column MCS.MCS_NTFN_MSG_STAT.crtn_user_id

  is 'Contains the user id of the person who created this row.';

comment on column MCS.MCS_NTFN_MSG_STAT.crtn_user_trck_id

  is 'Contains the user tracking id of the person who created this row.';

comment on column MCS.MCS_NTFN_MSG_STAT.last_uptd_tmst

  is 'Contains the date and time the record was last updated.';

comment on column MCS.MCS_NTFN_MSG_STAT.last_uptd_user_id

  is 'Contains the user id of the last person to update this row.';

comment on column MCS.MCS_NTFN_MSG_STAT.last_uptd_user_trck_id

  is 'Contains the employee number of the last person to update this row.';

-- Create/Recreate indexes

create index MCS.MCS_NTFN_MSG_STAT_X1 on MCS.MCS_NTFN_MSG_STAT (NTFN_MSG_ID)

  tablespace MCSDFLT001

  pctfree 10

  initrans 2

  maxtrans 255

  storage

  (

    initial 64K

    next 1M

    minextents 1

    maxextents unlimited

  );

-- Create/Recreate primary, unique and foreign key constraints

alter table MCS.MCS_NTFN_MSG_STAT

  add constraint MCS_NTFN_MSG_STAT_PK primary key (NTFN_MSG_STAT_ID)

  using index

  tablespace MCSDFLT001

  pctfree 1

  initrans 2

  maxtrans 255

  storage

  (

    initial 64K

    next 1M

    minextents 1

    maxextents unlimited

  );

alter table MCS.MCS_NTFN_MSG_STAT

  add constraint MCS_NTFN_MSG_STAT_F1 foreign key (NTFN_MSG_ID)

  references MCS.MCS_NTFN_MSG (NTFN_MSG_ID) on delete cascade;

-- Grant/Revoke object privileges

grant select on MCS.MCS_NTFN_MSG_STAT to MCS_READ;





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

)

tablespace MCSTS001

  pctfree 10

  initrans 1

  maxtrans 255

  storage

  (

    initial 1M

    next 1M

    minextents 1

    maxextents unlimited

    pctincrease 0

  );

-- Add comments to the table

comment on table MCS.MCS_NTFN_EMAL

  is 'Description:  This table contains an audit of the emails sent for the notifications. When originally added by a craft person or when escalated by a supervisor.

Volumetric: 4,000

Retention period: 12 months.

REPLICATION NEEDED: Yes';

-- Add comments to the columns

comment on column MCS.MCS_NTFN_EMAL.ntfn_id

  is 'The originating notification that the email was sent for.';

comment on column MCS.MCS_NTFN_EMAL.ntfn_emal_id

  is 'A generated id, to identify unique email rows.';

comment on column MCS.MCS_NTFN_EMAL.emal_user_id

  is 'Contains the user id of the person who the email was sent to.';

comment on column MCS.MCS_NTFN_EMAL.ntfn_emal_addr

  is 'The email address the notification was sent to.';

comment on column MCS.MCS_NTFN_EMAL.crtn_tmst

  is 'Contains the date and time the record was created.';

comment on column MCS.MCS_NTFN_EMAL.crtn_user_id

  is 'Contains the user id of the person who created this row.';

-- Create/Recreate indexes

create index MCS.MCS_NTFN_EMAL_X1 on MCS.MCS_NTFN_EMAL (NTFN_ID)

  tablespace MCSDFLT001

  pctfree 10

  initrans 2

  maxtrans 255

  storage

  (

    initial 64K

    next 1M

    minextents 1

    maxextents unlimited

  );

-- Create/Recreate primary, unique and foreign key constraints

alter table MCS.MCS_NTFN_EMAL

  add constraint MCS_NTFN_EMAL_PK primary key (NTFN_ID, NTFN_EMAL_ID)

  using index

  tablespace MCSDFLT001

  pctfree 1

  initrans 2

  maxtrans 255

  storage

  (

    initial 64K

    next 1M

    minextents 1

    maxextents unlimited

  );

alter table MCS.MCS_NTFN_EMAL

  add constraint MCS_NTFN_EMAL_F1 foreign key (NTFN_ID)

  references MCS.MCS_NTFN (NTFN_ID) on delete cascade;

-- Grant/Revoke object privileges

grant select on MCS.MCS_NTFN_EMAL to MCS_READ;



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

)

tablespace MCSTS001

  pctfree 10

  initrans 1

  maxtrans 255

  storage

  (

    initial 1M

    next 1M

    minextents 1

    maxextents unlimited

    pctincrease 0

  );

-- Add comments to the table

comment on table MCS.MCS_NTFN_MSG_STAT

  is 'Description:  This table contains an audit of the status values for the message. When originally added or when updated.';

-- Add comments to the columns

comment on column MCS.MCS_NTFN_MSG_STAT.ntfn_msg_stat_id

  is 'A generated id, to identify unique notification message status rows';

comment on column MCS.MCS_NTFN_MSG_STAT.ntfn_msg_id

  is 'FK to identify unique notification Message rows';

comment on column MCS.MCS_NTFN_MSG_STAT.ntfn_hist_stat_ind

  is 'Designates the ''C'' current row and the ''H'' history rows.';

comment on column MCS.MCS_NTFN_MSG_STAT.ntfn_msg_stat_code

  is 'Designates the status of the message.';

comment on column MCS.MCS_NTFN_MSG_STAT.msg_stat_crtn_tmst

  is 'Contains the date and time the message status was created.';

comment on column MCS.MCS_NTFN_MSG_STAT.crtn_tmst

  is 'Contains the date and time the record was created.';

comment on column MCS.MCS_NTFN_MSG_STAT.crtn_user_id

  is 'Contains the user id of the person who created this row.';

comment on column MCS.MCS_NTFN_MSG_STAT.crtn_user_trck_id

  is 'Contains the user tracking id of the person who created this row.';

comment on column MCS.MCS_NTFN_MSG_STAT.last_uptd_tmst

  is 'Contains the date and time the record was last updated.';

comment on column MCS.MCS_NTFN_MSG_STAT.last_uptd_user_id

  is 'Contains the user id of the last person to update this row.';

comment on column MCS.MCS_NTFN_MSG_STAT.last_uptd_user_trck_id

  is 'Contains the employee number of the last person to update this row.';

-- Create/Recreate indexes

create index MCS.MCS_NTFN_MSG_STAT_X1 on MCS.MCS_NTFN_MSG_STAT (NTFN_MSG_ID)

  tablespace MCSDFLT001

  pctfree 10

  initrans 2

  maxtrans 255

  storage

  (

    initial 64K

    next 1M

    minextents 1

    maxextents unlimited

  );

-- Create/Recreate primary, unique and foreign key constraints

alter table MCS.MCS_NTFN_MSG_STAT

  add constraint MCS_NTFN_MSG_STAT_PK primary key (NTFN_MSG_STAT_ID)

  using index

  tablespace MCSDFLT001

  pctfree 1

  initrans 2

  maxtrans 255

  storage

  (

    initial 64K

    next 1M

    minextents 1

    maxextents unlimited

  );

alter table MCS.MCS_NTFN_MSG_STAT

  add constraint MCS_NTFN_MSG_STAT_F1 foreign key (NTFN_MSG_ID)

  references MCS.MCS_NTFN_MSG (NTFN_MSG_ID) on delete cascade;

-- Grant/Revoke object privileges

grant select on MCS.MCS_NTFN_MSG_STAT to MCS_READ;



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

)

tablespace MCSTS001

  pctfree 10

  initrans 1

  maxtrans 255

  storage

  (

    initial 1M

    next 1M

    minextents 1

    maxextents unlimited

    pctincrease 0

  );

-- Add comments to the table

comment on table MCS.MCS_NTFN

  is 'Description:  This table holds any "stop" or "assistance needed" notifications added to a unit. There can be many of these for 1 equipment.

Volumetric: 5,000

Retention period: 12 months.

REPLICATION NEEDED: Yes';

-- Add comments to the columns

comment on column MCS.MCS_NTFN.ntfn_id

  is 'A unique sequential identifier for the row.';

comment on column MCS.MCS_NTFN.ord_hdr_id

  is 'The order header this notification belongs to, if one exists.';

comment on column MCS.MCS_NTFN.ntfn_sevr_code

  is 'The severity level of the notification. This indicates what icon will be displayed on the UI.';

comment on column MCS.MCS_NTFN.ntfn_type_code

  is 'The code indicating the type of notification this is. Values are on a code table.';

comment on column MCS.MCS_NTFN.ntfn_resn_code

  is 'The code indicating the reason for the type of notification this is. Values are on a code table.';

comment on column MCS.MCS_NTFN.phys_resr_id

  is 'The identifier which identifies a unique record for a PHYSICAL RESOURCE.';

comment on column MCS.MCS_NTFN.pr_ty_sup_id

  is 'A system generated identifier which identifies a unique record for a PHYSICAL RESOURCE TYPE SETUP.';

comment on column MCS.MCS_NTFN.crtn_lnr_loca_spot_id

  is 'The identifier which contains the current location of the equipment when the notification was created.';

comment on column MCS.MCS_NTFN.repr_fac_area_id

  is 'The identifier which contains the repair facility area of the equipment when the notification was created.';

comment on column MCS.MCS_NTFN.crtn_tmst

  is 'Contains the date and time the record was created.';

comment on column MCS.MCS_NTFN.crtn_user_id

  is 'Contains the user id of the person who created this row.';

comment on column MCS.MCS_NTFN.last_uptd_tmst

  is 'Contains the date and time the record was last updated.';

comment on column MCS.MCS_NTFN.last_uptd_user_id

  is 'Contains the user id of the last person to update this row.';

comment on column MCS.MCS_NTFN.crtn_user_trck_id

  is 'Contains the user tracking id of the person who created this row.';

comment on column MCS.MCS_NTFN.prob_cntr_msur_sht_ind

  is ' An indicator that this notification will be added to the problem counter measure sheet. This is used to indicate that this problem will be communicated to all shifts.';

comment on column MCS.MCS_NTFN.ord_item_ord_hdr_id

  is 'Part of the foreign key to the order item (task) that this notification belongs to, if one exists.';

comment on column MCS.MCS_NTFN.ord_item_phys_resr_id

  is 'Part of the foreign key to the order item (task) that this notification belongs to, if one exists..';

comment on column MCS.MCS_NTFN.item_work_id

  is 'Part of the foreign key to the order item (task) that this notification belongs to, if one exists.';

comment on column MCS.MCS_NTFN.ntfn_src_ind

  is 'This indicates the source this notification was created from.';

comment on column MCS.MCS_NTFN.last_uptd_user_trck_id

  is 'Contains the employee number of the last person to update this row.';

comment on column MCS.MCS_NTFN.ntfn_catg_ind

  is 'The code indicating the Category of this notification. Values are on a code table.';

-- Create/Recreate indexes

create index MCS.MCS_NTFN_X1 on MCS.MCS_NTFN (ORD_HDR_ID)

  tablespace MCSDFLT001

  pctfree 10

  initrans 2

  maxtrans 255

  storage

  (

    initial 64K

    next 1M

    minextents 1

    maxextents unlimited

  );

create index MCS.MCS_NTFN_X2 on MCS.MCS_NTFN (ORD_ITEM_ORD_HDR_ID, ORD_ITEM_PHYS_RESR_ID, ITEM_WORK_ID)

  tablespace MCSDFLT001

  pctfree 10

  initrans 2

  maxtrans 255

  storage

  (

    initial 64K

    next 1M

    minextents 1

    maxextents unlimited

  );

-- Create/Recreate primary, unique and foreign key constraints

alter table MCS.MCS_NTFN

  add constraint MCS_NTFN_PK primary key (NTFN_ID)

  using index

  tablespace MCSDFLT001

  pctfree 1

  initrans 2

  maxtrans 255

  storage

  (

    initial 64K

    next 1M

    minextents 1

    maxextents unlimited

  );

alter table MCS.MCS_NTFN

  add constraint MCS_NTFN_F1 foreign key (ORD_HDR_ID)

  references MCS.MCS_ORD_HDR (ORD_HDR_ID) on delete cascade;

alter table MCS.MCS_NTFN

  add constraint MCS_NTFN_F2 foreign key (ORD_ITEM_ORD_HDR_ID, ORD_ITEM_PHYS_RESR_ID, ITEM_WORK_ID)

  references MCS.MCS_ORD_ITEM (ORD_HDR_ID, PHYS_RESR_ID, ITEM_WORK_ID) on delete set null;

-- Grant/Revoke object privileges

grant select on MCS.MCS_NTFN to MCS_READ;



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

)

tablespace MCSTS001

  pctfree 10

  initrans 1

  maxtrans 255

  storage

  (

    initial 1M

    next 1M

    minextents 1

    maxextents unlimited

    pctincrease 0

  );

-- Add comments to the table

comment on table MCS.MCS_NTFN_STAT

  is 'Description:  This table contains the status of any "stop" or "assistance needed" notifications for a unit. There can be many of status codes for 1 notification.

Volumetric: 10,000

Retention period: 12 months.

REPLICATION NEEDED: Yes';

-- Add comments to the columns

comment on column MCS.MCS_NTFN_STAT.ntfn_id

  is 'The originating notification that the status is for.';

comment on column MCS.MCS_NTFN_STAT.seq_id

  is 'A generated sequence id, to identify unique status rows for 1 notification.';

comment on column MCS.MCS_NTFN_STAT.ntfn_hist_stat_ind

  is 'This reflects whether this row is "C"urrent or "H"istorical.';

comment on column MCS.MCS_NTFN_STAT.ntfn_stat_code

  is 'The code indicating the status of the notification.';

comment on column MCS.MCS_NTFN_STAT.cmnt_text

  is 'The comments added for the status row.';

comment on column MCS.MCS_NTFN_STAT.crtn_tmst

  is 'Contains the date and time the record was created.';

comment on column MCS.MCS_NTFN_STAT.crtn_user_id

  is 'Contains the user id of the person who created this row.';

comment on column MCS.MCS_NTFN_STAT.last_uptd_tmst

  is 'Contains the date and time the record was last updated.';

comment on column MCS.MCS_NTFN_STAT.last_uptd_user_id

  is 'Contains the user id of the last person to update this row.';

comment on column MCS.MCS_NTFN_STAT.crtn_user_trck_id

  is 'Contains the user tracking id of the person who created this row.';

comment on column MCS.MCS_NTFN_STAT.last_uptd_user_trck_id

  is 'Contains the employee number of the last person to update this row.';

-- Create/Recreate indexes

create index MCS.MCS_NTFN_STAT_X1 on MCS.MCS_NTFN_STAT (NTFN_ID)

  tablespace MCSDFLT001

  pctfree 10

  initrans 2

  maxtrans 255

  storage

  (

    initial 64K

    next 1M

    minextents 1

    maxextents unlimited

  );

-- Create/Recreate primary, unique and foreign key constraints

alter table MCS.MCS_NTFN_STAT

  add constraint MCS_NTFN_STAT_PK primary key (NTFN_ID, SEQ_ID)

  using index

  tablespace MCSDFLT001

  pctfree 1

  initrans 2

  maxtrans 255

  storage

  (

    initial 64K

    next 1M

    minextents 1

    maxextents unlimited

  );

alter table MCS.MCS_NTFN_STAT

  add constraint MCS_NTFM_STAT_F1 foreign key (NTFN_ID)

  references MCS.MCS_NTFN (NTFN_ID) on delete cascade;

-- Grant/Revoke object privileges

grant select on MCS.MCS_NTFN_STAT to MCS_READ;



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

)

tablespace MCSTS001

  pctfree 10

  initrans 1

  maxtrans 255

  storage

  (

    initial 1M

    next 1M

    minextents 1

    maxextents unlimited

    pctincrease 0

  );

-- Add comments to the table

comment on table MCS.MCS_NTFN_STAT_CMNT

  is 'Description:  This table contains an audit of the comments entered for the notification status. When originally added or when updated.';

-- Add comments to the columns

comment on column MCS.MCS_NTFN_STAT_CMNT.ntfn_stat_cmnt_id

  is 'A generated id, to identify unique notification status comment rows';

comment on column MCS.MCS_NTFN_STAT_CMNT.ntfn_id

  is 'The originating notification that the status is for. FK to the MCS_NTFN_STAT table.';

comment on column MCS.MCS_NTFN_STAT_CMNT.ntfn_stat_seq_id

  is 'A generated sequence id, to identify unique status rows for 1 notification. FK to the MCS_NTFN_STAT table.';

comment on column MCS.MCS_NTFN_STAT_CMNT.ntfn_hist_stat_ind

  is 'Designates the "C''"current row and the "H" history rows.';

comment on column MCS.MCS_NTFN_STAT_CMNT.cmnt_text

  is 'The Comments for the status that were added.';

comment on column MCS.MCS_NTFN_STAT_CMNT.crtn_tmst

  is 'Contains the date and time the record was created.';

comment on column MCS.MCS_NTFN_STAT_CMNT.crtn_user_id

  is 'Contains the user id of the person who created this row.';

comment on column MCS.MCS_NTFN_STAT_CMNT.last_uptd_tmst

  is 'Contains the date and time the record was last updated.';

comment on column MCS.MCS_NTFN_STAT_CMNT.last_uptd_user_id

  is 'Contains the user id of the last person to update this row.';

comment on column MCS.MCS_NTFN_STAT_CMNT.crtn_user_trck_id

  is 'Contains the user tracking id of the person who created this row.';

comment on column MCS.MCS_NTFN_STAT_CMNT.last_uptd_user_trck_id

  is 'Contains the employee number of the last person to update this row.';

comment on column MCS.MCS_NTFN_STAT_CMNT.dev_id

  is 'Device ID of the device that was used to complete this notification comment.  The value will be ''Browser'' or null if using responsive version on a desktop';

-- Create/Recreate indexes

create index MCS.MCS_NTFN_STAT_CMNT_X1 on MCS.MCS_NTFN_STAT_CMNT (NTFN_ID, NTFN_STAT_SEQ_ID)

  tablespace MCSDFLT001

  pctfree 10

  initrans 2

  maxtrans 255

  storage

  (

    initial 64K

    next 1M

    minextents 1

    maxextents unlimited

  );

-- Create/Recreate primary, unique and foreign key constraints

alter table MCS.MCS_NTFN_STAT_CMNT

  add constraint MCS_NTFN_STAT_CMNT_PK primary key (NTFN_STAT_CMNT_ID)

  using index

  tablespace MCSDFLT001

  pctfree 1

  initrans 2

  maxtrans 255

  storage

  (

    initial 64K

    next 1M

    minextents 1

    maxextents unlimited

  );

alter table MCS.MCS_NTFN_STAT_CMNT

  add constraint MCS_NTFN_STAT_CMNT_F1 foreign key (NTFN_ID, NTFN_STAT_SEQ_ID)

  references MCS.MCS_NTFN_STAT (NTFN_ID, SEQ_ID) on delete cascade;

-- Grant/Revoke object privileges

grant select on MCS.MCS_NTFN_STAT_CMNT to MCS_READ;