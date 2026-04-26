private String NTFN_STAT_AND_STAT_CMNTS =     "SELECT " +

                                                                                                                                                                                                "MNS.NTFN_ID, MNS.SEQ_ID, MNS.NTFN_HIST_STAT_IND, MNS.NTFN_STAT_CODE, MNS.CMNT_TEXT, MNS.CRTN_TMST, MNS.CRTN_USER_ID, " +

                                                                                                                                                                                                "MNS.LAST_UPTD_TMST, MNS.LAST_UPTD_USER_ID, MNS.CRTN_USER_TRCK_ID, MNS.LAST_UPTD_USER_TRCK_ID, " +

                                                                                                                                                                                                "MNSC.NTFN_STAT_CMNT_ID, MNSC.NTFN_HIST_STAT_IND MNSC_NTFN_HIST_STAT_IND, MNSC.CMNT_TEXT MNSC_CMNT_TEXT, MNSC.CRTN_TMST MNSC_CRTN_TMST, " +

                                                                                                                                                                                                "MNSC.CRTN_USER_ID MNSC_CRTN_USER_ID, MNSC.LAST_UPTD_TMST MNSC_LAST_UPTD_TMST, MNSC.LAST_UPTD_USER_ID MNSC_LAST_UPTD_USER_ID, " +

                                                                                                                                                                                                "MNSC.CRTN_USER_TRCK_ID MNSC_CRTN_USER_TRCK_ID, MNSC.LAST_UPTD_USER_TRCK_ID MNSC_LAST_UPTD_USER_TRCK_ID " +

                                                                                                                                                                                                "FROM MCS_NTFN_STAT MNS " +

                                                                                                                                                                                                "LEFT OUTER JOIN MCS_NTFN_STAT_CMNT MNSC " +

                                                                                                                                                                                                "ON MNS.NTFN_ID = MNSC.NTFN_ID " +

                                                                                                                                                                                                "AND MNS.SEQ_ID = MNSC.NTFN_STAT_SEQ_ID " +

                                                                                                                                                                                                "WHERE MNS.NTFN_ID IN %s ";





                private static final String INSERT_NOTIFICATION_COMMENT = "INSERT INTO MCS_NTFN_STAT_CMNT" +

                                                "                                                (NTFN_STAT_CMNT_ID," +

                                                "                                                                                 NTFN_ID," +

                                                "                                                                                 NTFN_STAT_SEQ_ID," +

                                                "                                                                                 NTFN_HIST_STAT_IND," +

                                                "                                                                                 CMNT_TEXT," +

                                                "                                                                                 CRTN_TMST," +

                                                "                                                                                 CRTN_USER_ID," +

                                                "                                                                                 LAST_UPTD_TMST," +

                                                "                                                                                 LAST_UPTD_USER_ID," +

                                                "                                                                                 CRTN_USER_TRCK_ID," +

                                                "                                                                                 LAST_UPTD_USER_TRCK_ID )" +

                                                "                                                                              VALUES" +

                                                "                                                                                (?,?,?,?,?,?,?,?,?,?,?)";





                private static final String UPDATE_NOTIFICATION_STATUS_COMMENT_DATA = "UPDATE MCS_NTFN_STAT_CMNT" +

                                                "   SET NTFN_HIST_STAT_IND = 'H'," +

                                                "       LAST_UPTD_TMST     = ?," +

                                                "       LAST_UPTD_USER_ID  = ?," +

                                                "              LAST_UPTD_USER_TRCK_ID = ?" +

                                                " WHERE NTFN_ID = ?" +

                                                "   AND NTFN_STAT_CMNT_ID = ?" +

                                                "   AND NTFN_STAT_SEQ_ID = ? AND  NTFN_HIST_STAT_IND='C' ";//added history indicator to avoid updating already h row's last updated user/track id



private static String GET_NOTIFICATION_HISTORY_SELECT_QUERY   = ""

                                                                                + "SELECT "

                                                                                + "                  HISTORYTABLE.Ntfn_Id, "

                                                                                + "                  HISTORYTABLE.seq_id, "

                                                                                + "                  HISTORYTABLE.NTFN_STAT_CODE as STATUSCODE, "

                                                                                + "                 ( select valu_shrt_desc from "

                                                                                + "            MCS.ACA_CD_TBL_HDR H left join MCS.ACA_CD_TBL_VALU V "

                                                                                + "                               on H.CODE_TBL_HDR_ID = V.CODE_TBL_HDR_ID "

                                                                                + "     WHERE H.VALU_LABL_NM = 'ILP NOTIFY STATUS CODES' "

                                                                                + "     and valu_text =  HISTORYTABLE.NTFN_STAT_CODE and rownum = 1) as statusDescription, "

                                                                                + "                 (HISTORYTABLE.CRTN_TMST+(locStn.CST_OSET_VALU/24)) as statusAdjustedTime , "

                                                                                + "                  HISTORYTABLE.CRTN_TMST as statusCreationDate, "

                                                                                + "                  (cmts.crtn_tmst+(locStn.CST_OSET_VALU/24)) as commentAdjustedTime , "

                                                                                + "                  cmts.crtn_tmst as commentCreationDate, "

                                                                                + "                  cmts.cmnt_text as COMMENTS, "

                                                                                + "                  cmts.ntfn_stat_cmnt_id as commentId, "

                                                                                + "                  HISTORYTABLE.CRTN_USER_ID as statusUserId, "

                                                                                + "                  HISTORYTABLE.CRTN_USER_TRCK_ID as statusEmplId, "

                                                                                + "                  case "

                                                                                + "                    when HISTORYTABLE.CRTN_USER_TRCK_ID='AUTOESCL' THEN 'AUTO' "

                                                                                + "                    else (select person.FIR_NAME from mcs_pno_pers_v1 person where person.full_pers_id = HISTORYTABLE.CRTN_USER_TRCK_ID ) end statusCreateFirstName, "

                                                                                + "                  case "

                                                                                + "                    when HISTORYTABLE.CRTN_USER_TRCK_ID='AUTOESCL' THEN 'ESCALATED' "

                                                                                + "                    else (select person.LAST_NAME from mcs_pno_pers_v1 person where person.full_pers_id = HISTORYTABLE.CRTN_USER_TRCK_ID ) end statusCreateLastName, "

                                                                                + "                  cmts.crtn_user_id commentCreatedUserId, "

                                                                                + "                  cmts.crtn_user_trck_id as commentCreatedEmplId, "

                                                                                + "                  case "

                                                                                + "                    when cmts.crtn_user_trck_id='AUTOESCL' THEN 'AUTO' "

                                                                                + "                    else (select person.FIR_NAME from mcs_pno_pers_v1 person where person.full_pers_id =cmts.crtn_user_trck_id ) end commentCreateFirstName, "

                                                                                + "                  case "

                                                                                + "                    when cmts.crtn_user_trck_id='AUTOESCL' THEN 'ESCALATED' "

                                                                                + "                    else (select person.LAST_NAME from mcs_pno_pers_v1 person where person.full_pers_id = cmts.crtn_user_trck_id ) end commentCreateLastName "

                                                                                + "                  FROM MCS_NTFN_STAT HISTORYTABLE "

                                                                                + "                       left join MCS_NTFN NFT on historytable.ntfn_id = nft.ntfn_id "

                                                                                + "                       left join sfm_repr_fac_area RepairArea on RepairArea.Repr_Fac_Area_Id = nft.repr_fac_area_id "

                                                                                + "                       left join mcs_work_repr_fac RepairFac on repairfac.work_unit_id = RepairArea.Work_Unit_Id "

                                                                                + "                       left join mcs_loc_sys_stn_v1 locStn on locStn.STN_CRC7_CODE = RepairFac.Repr_Fac_Crc7 "

                                                                                + "                       left join MCS_NTFN_STAT_CMNT cmts on historytable.ntfn_id = cmts.ntfn_id "

                                                                                + "                                 and historytable.seq_id = cmts.ntfn_stat_seq_id "

                                                                                + "                  WHERE HISTORYTABLE.NTFN_ID = ? "

                                                                                + "                 ORDER BY HISTORYTABLE.SEQ_ID DESC";



                                GET_NOTIFICATION_HISTORY_INSERT_QUERY = new StringBuilder(" INSERT INTO MCS_NTFN_STAT (NTFN_ID, SEQ_ID, NTFN_HIST_STAT_IND, ")

                                                                                                                                                                                                .append(" NTFN_STAT_CODE, CMNT_TEXT, CRTN_TMST, CRTN_USER_ID, LAST_UPTD_TMST, LAST_UPTD_USER_ID, CRTN_USER_TRCK_ID) ")

                                                                                                                                                                                                .append(" VALUES (?,MCS_NTFN_STAT_Q1.NEXTVAL,?,?,?,SYSDATE,?,SYSDATE,?,?) ")

                                                                                                                                                                                                .toString();



                                GET_NOTIFICATION_SELECT_QUERY = new StringBuilder(" SELECT NTFN.NTFN_ID notificationId, NTFN.NTFN_TYPE_CODE typeOfEvent, NTFN.NTFN_RESN_CODE reasonCode, ")

                                                                                                                                                                                                .append(" NTFN.NTFN_SEVR_CODE sevrityCode ")

                                                                                                                                                                                                .append(" , HIST.CMNT_TEXT comments, HIST.CRTN_USER_ID crtnUserId, HIST.Last_Uptd_Tmst lastUpdtDt,")

                                                                                                                                                                                                .append(" DECODE(HIST.NTFN_STAT_CODE,'O','Open','I','In Progress','E','Escalated') STATUS ")

                                                                                                                                                                                                //.append(" NTFN.CRTN_USER_ID FULLNAME ")

                                                                                                                                                                                                .append(" FROM MCS_NTFN NTFN ")

                                                                                                                                                                                                .append(" INNER JOIN MCS_NTFN_STAT HIST ON HIST.NTFN_ID = NTFN.NTFN_ID ")

                                                                                                                                                                                                .append(" WHERE NTFN.PHYS_RESR_ID = ? AND HIST.NTFN_HIST_STAT_IND = 'C' " +

                                                                                                                                                                                                                                " AND HIST.NTFN_STAT_CODE NOT IN ('C','X') " +

                                                                                                                                                                                                                                "ORDER BY sevrityCode DESC,lastUpdtDt DESC ")

                                                                                                                                                                                                .toString();



                                GET_NOTIFICATION_HISTORY_SELECT_QUERY  = new StringBuilder(" SELECT HISTORYTABLE.NTFN_STAT_CODE STATUSCODE,(HISTORYTABLE.CRTN_TMST+locStn.CST_OSET_VALU/24) AdjustedTime , ")

                                                                                                                                                                                                                .append(" HISTORYTABLE.CRTN_TMST      CRTNDATE, HISTORYTABLE.CMNT_TEXT      COMMENTS, ")

                                                                                                                                                                                                                .append(" HISTORYTABLE.CRTN_USER_ID FULLNAME ")

                                                                                                                                                                                                                .append(" FROM MCS_NTFN_STAT HISTORYTABLE ")

                                                                                                                                                                                                                 .append(" , MCS_NTFN NFT  ,MCS_WORK_UNIT WORKUNIT , ")

                                                                                                                                                                                                                .append(" mcs_work_repr_fac RepairFac , sfm_repr_fac_area RepairArea")

                                                                                                                                                                                                                .append(",mcs_loc_sys_stn_v1 locStn")

                                                                                                                                                                                                                 .append(" WHERE HISTORYTABLE.NTFN_ID = ? ")

                                                                                                                                                                                                                 .append("  AND HISTORYTABLE.NTFN_ID = nft.ntfn_id ")

                                                                                                                                                                                                                .append("  and  nft.repr_fac_area_id = RepairArea.Repr_Fac_Area_Id")

                                                                                                                                                                                                                .append(" and RepairArea.Work_Unit_Id = workunit.work_unit_id")

                                                                                                                                                                                                                .append(" and workunit.work_unit_id = RepairFac.Work_Unit_Id")

                                                                                                                                                                                                                .append(" and  locStn.STN_CRC7_CODE =RepairFac.Repr_Fac_Crc7 ")

                                                                                                                                                                                                                 .append("ORDER BY HISTORYTABLE.SEQ_ID DESC ").toString();



                private static final String GET_EQUIPMENT_OPEN_NOTIFICATIONS_COUNT_QUERY="" +

                                                "SELECT MN.ORD_HDR_ID, COUNT(*)  OPEN_NOTIFICATIONS" +

                                                "  FROM MCS_NTFN MN  " +

                                                "  JOIN MCS_NTFN_STAT MNS  " +

                                                "    ON MNS.NTFN_ID = MN.NTFN_ID  " +

                                                "   AND MNS.NTFN_HIST_STAT_IND = 'C'  " +

                                                "  AND MNS.NTFN_STAT_CODE <> 'C'  " +

                                                "  WHERE MN.ORD_HDR_ID IN  %s  " +

                                                "  GROUP BY MN.ORD_HDR_ID  " ;



getInt("select NVL(max(SEQ_ID), 0) from MCS_NTFN_STAT WHERE NTFN_ID ="+ notificationDetails.getNotificationId());



package com.uprr.app.swm.repository.db.impl;



import java.sql.Blob;

import java.sql.PreparedStatement;

import java.sql.ResultSet;

import java.sql.SQLException;

import java.sql.Timestamp;

import java.util.ArrayList;

import java.util.Calendar;

import java.util.Date;

import java.util.List;

import java.util.Set;



import org.apache.commons.collections.CollectionUtils;

import org.apache.commons.lang.StringUtils;

import org.springframework.dao.DataAccessException;

import org.springframework.jdbc.core.PreparedStatementSetter;

import org.springframework.jdbc.core.ResultSetExtractor;

import org.springframework.transaction.TransactionStatus;

import org.springframework.transaction.support.TransactionCallbackWithoutResult;

import org.springframework.transaction.support.TransactionTemplate;



import com.uprr.app.lmpc.business.bom.LocomotiveAttributes;

import com.uprr.app.lmpc.business.bom.equipment.impl.EquipmentDetails;

import com.uprr.app.lmpc.business.bom.equipment.impl.EquipmentDetailsList;

import com.uprr.app.lmpc.business.bom.impl.LocomotiveAttributesList;

import com.uprr.app.lmpc.business.bom.notification.impl.NotificationReportList;

import com.uprr.app.lmpc.business.bom.notification.impl.NotificationReportSearchOptions;

import com.uprr.app.lmpc.common.util.DateUtils;

import com.uprr.app.lmpc.dao.exception.ClientException;

import com.uprr.app.lmpc.dao.exception.ErrorCodes;

import com.uprr.app.lmpc.repository.db.NotificationsRepository;

import com.uprr.app.lmpc.ui.wicket.util.CommonConstants;

import com.uprr.app.lmpc.ui.wicket.util.Constants;

import com.uprr.app.phy.business.bom.lmpc.assignments.impl.UserAssignmentImpl;

import com.uprr.app.phy.business.bom.lmpc.assignments.impl.UserAssignmentList;

import com.uprr.app.phy.business.bom.lmpc.assignments.impl.WorkOrderImpl;

import com.uprr.app.phy.business.bom.lmpc.assignments.impl.WorkOrderList;

import com.uprr.app.phy.business.bom.notifications.NotificationDetails;

import com.uprr.app.phy.business.bom.notifications.NotificationMessageStatusDetails;

import com.uprr.app.phy.business.bom.notifications.NotificationStatusCommentDetails;

import com.uprr.app.phy.business.bom.notifications.NotificationStatusDetails;

import com.uprr.app.phy.business.bom.notifications.NotificationStatusMessageDetails;

import com.uprr.app.phy.business.bom.notifications.impl.NotificationMessageStatusDetailsImpl;

import com.uprr.app.phy.business.bom.notifications.impl.NotificationMessageStatusDetailsList;

import com.uprr.app.phy.business.bom.notifications.impl.NotificationStatusMessageDetailsList;

import com.uprr.app.phy.business.bom.repairfacilityareas.RepairFacilityArea;

import com.uprr.app.phy.business.workorder.boms.OrderItem;

import com.uprr.app.phy.business.workorder.boms.impl.OrderItemImpl;

import com.uprr.app.phy.repository.db.impl.JdbcDaoSupportImpl;

import com.uprr.app.phy.workorder.db.repository.util.DBUtils;





public class NotificationsRepositoryImpl extends JdbcDaoSupportImpl implements NotificationsRepository{





                /**

                *

                 */

                private static final long serialVersionUID = 1L;



                @Override

                public UserAssignmentList getAssignmentsForNotifications(final String loggedInUserTrackId, final long orderHdrId, final Date workDate, final int shift) throws ClientException{

                                try{

                                                logger.debug("getAssignmentsForNotifications : loggedInUserTrackId("+loggedInUserTrackId+")");

                                                logger.debug("getAssignmentsForNotifications : orderHdrId("+ orderHdrId+")");

                                                logger.debug("getAssignmentsForNotifications : workDate("+workDate+")");

                                                logger.debug("getAssignmentsForNotifications : shift("+shift+")");

                                                logger.debug("getAssignmentsForNotifications : GET_ASGNS_4_NOTIFICATIONS("+GET_ASGNS_4_NOTIFICATIONS+")");



                                                final UserAssignmentList retObj = new UserAssignmentList();

                                                super.getJdbcTemplate().query(GET_ASGNS_4_NOTIFICATIONS, new PreparedStatementSetter() {

                                                                @Override

                                                                public void setValues(PreparedStatement ps) throws SQLException {

                                                                                ps.setLong(1, orderHdrId);

                                                                                ps.setDate(2, new java.sql.Date(workDate.getTime()));

                                                                                ps.setInt(3, shift);

                                                                                ps.setString(4, loggedInUserTrackId);

                                                                }

                                                }, new ResultSetExtractor() {

                                                                @Override

                                                                public Object extractData(ResultSet rs) throws SQLException,

                                                                                                DataAccessException {

                                                                                while(rs.next()){

                                                                                                UserAssignmentImpl userAssignment = new UserAssignmentImpl();

                                                                                                userAssignment.setAssignId(rs.getLong("ASGN_ID"));

                                                                                                userAssignment.setAssignToUserId(rs.getString("ASGN_TO_USER_ID"));

                                                                                                userAssignment.setAssignToUserTrackId(rs.getString("ASGN_TO_USER_TRCK_ID"));

                                                                                                userAssignment.setPersonCraftCode(rs.getString("PRSN_CRFT_CODE"));

                                                                                                userAssignment.setEdxForemanCode(rs.getString("EDX_FRMN_CODE"));

                                                                                                userAssignment.setActionDate(rs.getTimestamp("ACTN_DATE"));

                                                                                                userAssignment.setCreatedByMtdTxt(rs.getString("CRTD_BY_MTHD_TEXT"));

                                                                                                userAssignment.setExpirationDate(rs.getTimestamp("EXPN_DATE"));

                                                                                                userAssignment.setItemWorkId(rs.getLong("ITEM_WORK_ID"));

                                                                                                userAssignment.setLabourMinsAssigned(rs.getInt("LABR_MINS_ASGN"));

                                                                                                userAssignment.setOrderHdrId(rs.getLong("ORD_HDR_ID"));

                                                                                                userAssignment.setOrderItemStepNumber(rs.getLong("ORD_ITEM_STEP_NBR"));

                                                                                                userAssignment.setPhysResrId(rs.getLong("PHYS_RESR_ID"));

                                                                                                userAssignment.setRepairFacilityAreaId(rs.getInt("REPR_FAC_AREA_ID"));

                                                                                                userAssignment.setShiftIndicator(rs.getString("SHFT_IND"));

                                                                                                userAssignment.setStatusCode(rs.getString("STAT_CODE"));

                                                                                                userAssignment.setStepCraftSeqNumber(rs.getLong("ORD_ITEM_STEP_CRFT_SEQ_NBR"));

                                                                                                userAssignment.setTotalReportedLabourMins(rs.getInt("TOTL_RPTD_LABR_MINS"));

                                                                                                userAssignment.setWorkDate(rs.getDate("WORK_DATE"));

                                                                                                userAssignment.setCreatedUserId(rs.getString("CRTN_USER_ID"));

                                                                                                userAssignment.setCreatedUserTrackId(rs.getString("CRTN_USER_TRCK_ID"));



                                                                                                userAssignment.setWorkAreaSeqNbr(rs.getLong("DSGN_WORK_AREA_SEQ_NBR"));

                                                                                                retObj.add(userAssignment);



                                                                                                logger.debug("ResultSetExtractor : getAssignId("+userAssignment.getAssignId()+")");

                                                                                                logger.debug("ResultSetExtractor : getCreatedUserId("+userAssignment.getCreatedUserId()+")");

                                                                                                logger.debug("ResultSetExtractor : getCreatedUserTrackId("+userAssignment.getCreatedUserTrackId()+")");

                                                                                }

                                                                                return null;

                                                                }

                                                });

                                                return retObj;

                                }catch(Exception e){

                                                throw new ClientException(e.getMessage(), e);

                                }

                }



                @Override

                public void createNotification(final NotificationDetails notificationDetails)             throws ClientException {

                                try {

                                                getTransactionTemplate().execute(new TransactionCallbackWithoutResult() {

                                                                @Override

                                                                public void doInTransactionWithoutResult(TransactionStatus status) {

                                                                                try{



                                                                                                insertNewNotification(notificationDetails); // insert notification object



                                                                                                for(NotificationStatusDetails notificationStatusDetails: notificationDetails.getNotificationStatusDetails()) // insert notification statues

                                                                                                {

                                                                                                                insertNewNotificationStatus(notificationStatusDetails, notificationDetails.getLoggedInUserId(), notificationDetails.getLoggedInUserTrackId());

                                                                                                                if(CollectionUtils.isNotEmpty(notificationStatusDetails.getNotificationStatusCommentDetails()))

                                                                                                                {

                                                                                                                                for(NotificationStatusCommentDetails notificationStatusCommentDetails : notificationStatusDetails.getNotificationStatusCommentDetails())

                                                                                                                                {

                                                                                                                                                insertNewNotificationComment(notificationStatusCommentDetails, notificationDetails.getLoggedInUserId(), notificationDetails.getLoggedInUserTrackId());

                                                                                                                                }

                                                                                                                }





                                                                                                                if(CollectionUtils.isNotEmpty(notificationStatusDetails.getNotificationStatusMessageDetails()))

                                                                                                                {

                                                                                                                                for(NotificationStatusMessageDetails notificationStatusMessageDetails : notificationStatusDetails.getNotificationStatusMessageDetails())

                                                                                                                                {

                                                                                                                                                insertNewNotificationMessage(notificationStatusMessageDetails, notificationDetails.getLoggedInUserId(), notificationDetails.getLoggedInUserTrackId());



                                                                                                                                                if(CollectionUtils.isNotEmpty(notificationStatusMessageDetails.getNotificationMessageStatusDetails()))

                                                                                                                                                {

                                                                                                                                                                for(NotificationMessageStatusDetails notificationMessageStatusDetails : notificationStatusMessageDetails.getNotificationMessageStatusDetails())

                                                                                                                                                                {

                                                                                                                                                                                insertNewNotificationMessageStatus(notificationMessageStatusDetails, notificationDetails.getLoggedInUserId(), notificationDetails.getLoggedInUserTrackId());

                                                                                                                                                                }

                                                                                                                                                }

                                                                                                                                }

                                                                                                                }



                                                                                                }



                                                                                }catch(Exception e){

                                                                                                logger.error(e.getMessage(),e);

                                                                                                status.setRollbackOnly();

                                                                                                //TODO:NotificationEmail.sendEmail("Error in create user assignment","error"+e  ,null,null);

                                                                                                throw new RuntimeException(e.getMessage(),e);

                                                                                }

                                                                }

                                                });

                                } catch (RuntimeException e) {

                                                throw (ClientException)e.getCause();

                                }



                                logger.info("Finished inserting a notification");

                }



                @Override

                public void updateNotification(final NotificationDetails notificationDetails)            throws ClientException {

                                try {

                                                getTransactionTemplate().execute(new TransactionCallbackWithoutResult() {

                                                                @Override

                                                                public void doInTransactionWithoutResult(TransactionStatus status) {

                                                                                try{



                                                                                                String query = " ";



                                                                                                boolean isNotificationDataChanged = false;



                                                                                                if(notificationDetails.isCategoryIndicatorChanged())

                                                                                                {

                                                                                                                isNotificationDataChanged =  true;

                                                                                                                                query =  query + " NTFN_CATG_IND = '"+ notificationDetails.getCategoryIndicator()+"',";



                                                                                                }



                                                                                                if(notificationDetails.isNotificationReasonCodeChanged())

                                                                                                {

                                                                                                                isNotificationDataChanged =  true;

                                                                                                                query =  query + " NTFN_RESN_CODE = '"+ notificationDetails.getNotificationReasonCode()+"',";

                                                                                                }





                                                                                                if(notificationDetails.isNotificationtypeCodeChanged())

                                                                                                {

                                                                                                                isNotificationDataChanged =  true;

                                                                                                                query =  query + " NTFN_TYPE_CODE = '"+ notificationDetails.getNotificationtypeCode()+"',";



                                                                                                }



                                                                                                if(notificationDetails.isProblemCounterMeasureSheetIndChanged())

                                                                                                {

                                                                                                                isNotificationDataChanged =  true;

                                                                                                                query =  query + " PROB_CNTR_MSUR_SHT_IND = '"+ notificationDetails.getProblemCounterMeasureSheetInd() + "',";



                                                                                                }



                                                                                                if(notificationDetails.isTaskChanged())

                                                                                                {





                                                                                                                isNotificationDataChanged =  true;





                                                                                                                if( notificationDetails.getTaskItemWorkId() > 0 ) // we have a task on UI but user removed it hence we need to insert nulls into db

                                                                                                                {

                                                                                                                                query =  query + " ORD_ITEM_ORD_HDR_ID = "+ notificationDetails.getTaskOrderHeaderId() +",";

                                                                                                                                query =  query + " ORD_ITEM_PHYS_RESR_ID = "+ notificationDetails.getTaskPhysicalResourceId()+ ",";

                                                                                                                                query =  query + " ITEM_WORK_ID = "+ notificationDetails.getTaskItemWorkId() + ",";

                                                                                                                }else

                                                                                                                {

                                                                                                                                query =  query + " ORD_ITEM_ORD_HDR_ID = null "   +",";

                                                                                                                                query =  query + " ORD_ITEM_PHYS_RESR_ID = null "  +",";

                                                                                                                                query =  query + " ITEM_WORK_ID = null "  +",";

                                                                                                                }



                                                                                                }





                                                                                                if(isNotificationDataChanged && StringUtils.isNotBlank(query))

                                                                                                {

                                                                                                                //query = StringUtils.removeEnd(query, ",");



                                                                                                                query = " UPDATE MCS_NTFN SET " + query  // + " NTFN_SRC_IND ='"+ notificationDetails.getNotificationSourceIndicator()+"', "

                                                                                                                                                + " LAST_UPTD_TMST= SYSDATE,LAST_UPTD_USER_ID= '"+ notificationDetails.getLoggedInUserId() +"', "

                                                                                                                                                + " LAST_UPTD_USER_TRCK_ID = '"+ notificationDetails.getLoggedInUserTrackId() +"'"

                                                                                                                                                + " WHERE NTFN_ID = "+                notificationDetails.getNotificationId();





                                                                                                                logger.info("Notificatin Update query: "+ query);

                                                                                                                updateNotificationData(notificationDetails, query);

                                                                                                }





                                                                                                //now update all existing notifications with status h if we have a new status

                                                                                                boolean newNotificationStatus =false;

                                                                                                boolean newNotificationComment = false;

                                                                                                boolean deleteNotificationComment = false;



                                                                                                boolean newNotificationMessage = false;

                                                                                                boolean deleteNotificationMessage = false;



                                                                                                for(NotificationStatusDetails notificationStatusDetails: notificationDetails.getNotificationStatusDetails())

                                                                                                {

                                                                                                     if(CommonConstants.NOTIFICATION_ACTION_INSERT.equalsIgnoreCase(notificationStatusDetails.getActionCode()))

                                                                                                                {

                                                                                                                                newNotificationStatus = true;

                                                                                                                                break;

                                                                                                                }

                                                                                                }



                                                                                                for(NotificationStatusDetails notificationStatusDetails: notificationDetails.getNotificationStatusDetails())

                                                                                                {

                                                                                                                for(NotificationStatusCommentDetails notificationStatusCommentDetails : notificationStatusDetails.getNotificationStatusCommentDetails())

                                                                                                                {

                                                                                                                if(CommonConstants.NOTIFICATION_ACTION_INSERT.equalsIgnoreCase(notificationStatusCommentDetails.getActionCode()))

                                                                                                                                {

                                                                                                                                                newNotificationComment = true;

                                                                                                                                                deleteNotificationComment= false;

                                                                                                                                                break;

                                                                                                                                }else if(CommonConstants.NOTIFICATION_ACTION_DELETE.equalsIgnoreCase(notificationStatusCommentDetails.getActionCode()))

                                                                                                                                {

                                                                                                                                                newNotificationComment = false;

                                                                                                                                                deleteNotificationComment= true;

                                                                                                                                                break;

                                                                                                                                }

                                                                                                                }

                                                                                                }



                                                                                                for(NotificationStatusDetails notificationStatusDetails: notificationDetails.getNotificationStatusDetails())

                                                                                                {

                                                                                                                for(NotificationStatusMessageDetails notificationStatusMessageDetails  : notificationStatusDetails.getNotificationStatusMessageDetails())

                                                                                                                {

                                                                                                                if(CommonConstants.NOTIFICATION_ACTION_INSERT.equalsIgnoreCase(notificationStatusMessageDetails.getActionCode()))

                                                                                                                                {

                                                                                                                                                newNotificationMessage = true;



                                                                                                                                }else if(CommonConstants.NOTIFICATION_ACTION_DELETED_AFTER_SENT.equalsIgnoreCase(notificationStatusMessageDetails.getActionCode()))

                                                                                                                                {

                                                                                                                                                deleteNotificationMessage = true;



                                                                                                                                }

                                                                                                                }

                                                                                                }



                                                                                //===============================================================================================



                                                                                                //check if we need to update status of existing tables to H

                                                                                                if(newNotificationStatus)

                                                                                                {

                                                                                                                // check if whether some other code changed the status of this notification

                                                                                                                int maxNotificationStatusSeqId = notificationDetails.getNotificationStatusDetails().getMaxNotificationStatusSeqId();



                                                                                                                int maxNotificationStatusSeqIdInDB = getInt("select NVL(max(SEQ_ID), 0) from MCS_NTFN_STAT WHERE NTFN_ID ="+ notificationDetails.getNotificationId());

                                                                                                                //if some other code changed the notification status

                                                                                                                if(maxNotificationStatusSeqIdInDB > maxNotificationStatusSeqId){



                                                                                                                                throw new ClientException(Constants.NOTIFICATION_UPDATED_MESSAGE);

                                                                                                                }

                                                                                                                // update all notification status as h before inserting a new one

                                                                                                                for(NotificationStatusDetails notificationStatusDetails: notificationDetails.getNotificationStatusDetails())

                                                                                                                {

                                                                                                                    if(!CommonConstants.NOTIFICATION_ACTION_INSERT.equalsIgnoreCase(notificationStatusDetails.getActionCode()))

                                                                                                                                {

                                                                                                                                                updateNotificationStatusData(notificationStatusDetails, notificationDetails.getLoggedInUserId(), notificationDetails.getLoggedInUserTrackId());



                                                                                                                                                /*//update existing notification message status for this notification status to h

                                                                                                                                                for(NotificationStatusMessageDetails notificationStatusMessageDetails  : notificationStatusDetails.getNotificationStatusMessageDetails())

                                                                                                                                                {

                                                                                                                                                                                for(NotificationMessageStatusDetails notificationMessageStatusDetails : notificationStatusMessageDetails.getNotificationMessageStatusDetails())

                                                                                                                                                                                {

                                                                                                                                                                                                updateNotificationMessageStatusData(notificationMessageStatusDetails);

                                                                                                                                                                                }

                                                                                                                                                }





                                                                                                                                                //update existing notification comments and make their history indicator as h

                                                                                                                                                for(NotificationStatusCommentDetails notificationStatusCommentDetails : notificationStatusDetails.getNotificationStatusCommentDetails())

                                                                                                                                                {

                                                                                                                                                                                updateNotificationCommentsData(notificationStatusCommentDetails);



                                                                                                                                                }*/



                                                                                                                                }

                                                                                                                }

                                                                                                }else

                                                                                                {





                                                                                                                if(newNotificationComment || deleteNotificationComment)

                                                                                                                {

                                                                                                                                NotificationStatusDetails notificationStatusDetails = notificationDetails.getNotificationStatusDetails().getCurrentNotificationStatusDetails();



                                                                                                                                if(notificationStatusDetails!= null)

                                                                                                                                {

                                                                                                                                                for(NotificationStatusCommentDetails notificationStatusCommentDetails : notificationStatusDetails.getNotificationStatusCommentDetails())

                                                                                                                                                {

                                                                                                                                                if(!CommonConstants.NOTIFICATION_ACTION_INSERT.equalsIgnoreCase(notificationStatusCommentDetails.getActionCode()))

                                                                                                                                                                {

                                                                                                                                                                                updateNotificationCommentsData(notificationStatusCommentDetails, notificationDetails.getLoggedInUserId(), notificationDetails.getLoggedInUserTrackId());

                                                                                                                                                                }

                                                                                                                                                }

                                                                                                                                }else

                                                                                                                                {

                                                                                                                                                logger.error("Current notificaiton status is null or empty");

                                                                                                                                }

                                                                                                                }





                                                                                                                if(deleteNotificationMessage) //if we have an insert or a delete record then update all old ones with h status

                                                                                                                {

                                                                                                                                NotificationStatusDetails notificationStatusDetails = notificationDetails.getNotificationStatusDetails().getCurrentNotificationStatusDetails();



                                                                                                                                if(notificationStatusDetails!= null)

                                                                                                                                {

                                                                                                                                                for(NotificationStatusMessageDetails notificationStatusMessageDetails  : notificationStatusDetails.getNotificationStatusMessageDetails())

                                                                                                                                                {

                                                                                                                                                if(CommonConstants.NOTIFICATION_ACTION_DELETED_AFTER_SENT.equalsIgnoreCase(notificationStatusMessageDetails.getActionCode()))

                                                                                                                                                                {

                                                                                                                                                                                for(NotificationMessageStatusDetails notificationMessageStatusDetails : notificationStatusMessageDetails.getNotificationMessageStatusDetails())

                                                                                                                                                                                {

                                                                                                                                                                                                updateNotificationMessageStatusData(notificationMessageStatusDetails, notificationDetails.getLoggedInUserId(), notificationDetails.getLoggedInUserTrackId()); // update all existing notification statues as H

                                                                                                                                                                                }





                                                                                                                                                                                //insert new message status with status as x

                                                                                                                                                                                NotificationMessageStatusDetails notificationMessageStatusDetails = new NotificationMessageStatusDetailsImpl();

                                                                                                                                                                                notificationMessageStatusDetails.setMsgHistStatInd(CommonConstants.notificationCurrentRecordValue);

                                                                                                                                                                                notificationMessageStatusDetails.setMsgStatCode(CommonConstants.notificationStatusCancel);

                                                                                                                                                                                notificationMessageStatusDetails.setNotificationStatusMessage(notificationStatusMessageDetails);

                                                                                                                                                                                insertNewNotificationMessageStatus(notificationMessageStatusDetails, notificationDetails.getLoggedInUserId(), notificationDetails.getLoggedInUserTrackId());

                                                                                                                                                                }

                                                                                                                                                }

                                                                                                                                }else

                                                                                                                                {

                                                                                                                                                logger.error("Current notificaiton status is null or empty");

                                                                                                                                }

                                                                                                                }



                                                                                                }



                                                                                //================================================================================================================================



                                                                                                //now insert the respective objects into database

                                                                                                for(NotificationStatusDetails notificationStatusDetails: notificationDetails.getNotificationStatusDetails())

                                                                                                {

                                                                                                     if(CommonConstants.NOTIFICATION_ACTION_INSERT.equalsIgnoreCase(notificationStatusDetails.getActionCode()))

                                                                                                                {

                                                                                                                                insertNewNotificationStatus(notificationStatusDetails, notificationDetails.getLoggedInUserId(), notificationDetails.getLoggedInUserTrackId());

                                                                                                                }



                                                                                                                // now update the notification message comments

                                                                                                                for(NotificationStatusCommentDetails notificationStatusCommentDetails : notificationStatusDetails.getNotificationStatusCommentDetails())

                                                                                                                {

                                                                                                                if(CommonConstants.NOTIFICATION_ACTION_INSERT.equalsIgnoreCase(notificationStatusCommentDetails.getActionCode()))

                                                                                                                                {

                                                                                                                                                insertNewNotificationComment(notificationStatusCommentDetails, notificationDetails.getLoggedInUserId(), notificationDetails.getLoggedInUserTrackId());

                                                                                                                                }

                                                                                                                }



                                                                                                                // now update the nofication message with the status

                                                                                                                for(NotificationStatusMessageDetails notificationStatusMessageDetails  : notificationStatusDetails.getNotificationStatusMessageDetails())

                                                                                                                {



                                                                                                                if(CommonConstants.NOTIFICATION_ACTION_INSERT.equalsIgnoreCase(notificationStatusMessageDetails.getActionCode()))

                                                                                                                                {

                                                                                                                                                insertNewNotificationMessage(notificationStatusMessageDetails, notificationDetails.getLoggedInUserId(), notificationDetails.getLoggedInUserTrackId());

                                                                                                                                                for(NotificationMessageStatusDetails notificationMessageStatusDetails : notificationStatusMessageDetails.getNotificationMessageStatusDetails())

                                                                                                                                                {

                                                                                                                                                                insertNewNotificationMessageStatus(notificationMessageStatusDetails, notificationDetails.getLoggedInUserId(), notificationDetails.getLoggedInUserTrackId());

                                                                                                                                                }

                                                                                                                                }

                                                                                                                }

                                                                                                }



                                                                                }catch(Exception e){

                                                                                                logger.error(e.getMessage(),e);

                                                                                                status.setRollbackOnly();

                                                                                                //TODO:NotificationEmail.sendEmail("Error in create user assignment","error"+e  ,null,null);

                                                                                                throw new RuntimeException(e.getMessage(),e);

                                                                                }

                                                                }

                                                });

                                } catch (RuntimeException e) {

                                                throw (ClientException)e.getCause();

                                }



                                logger.info("Finished updating a notification");

                }



                public void updateNotificationMessagesWithENAId(NotificationStatusMessageDetailsList notificationStatusMessageDetailsList, final String loggedInUserId, final String loggedInUserTrackId) throws ClientException {

                                if(CollectionUtils.isNotEmpty(notificationStatusMessageDetailsList)){

                                                for(NotificationStatusMessageDetails notificationStatusMessageDetails:notificationStatusMessageDetailsList){

                                                                updateNotificationForEnaMsgId(notificationStatusMessageDetails,loggedInUserId,loggedInUserTrackId);



                                                                NotificationMessageStatusDetailsList notificationMessageStatusDetailsList = notificationStatusMessageDetails.getNotificationMessageStatusDetails();



                                                                if(CollectionUtils.isNotEmpty(notificationMessageStatusDetailsList)){

                                                                                for(NotificationMessageStatusDetails notificationMessageStatusDetails:notificationMessageStatusDetailsList){



                                                                                                if("C".equalsIgnoreCase(notificationMessageStatusDetails.getMsgHistStatInd())){

                                                                                                              updateNotificationMessageStatusData(notificationMessageStatusDetails,loggedInUserId,loggedInUserTrackId);

                                                                                                                insertNewNotificationMessageStatus(notificationMessageStatusDetails,loggedInUserId,loggedInUserTrackId);

                                                                                                }

                                                                                }

                                                                }

                                                }

                                }

                }



                private void insertNewNotification(final NotificationDetails notificationDetails) throws ClientException {

                                try {



                                                super.getJdbcTemplate().update( INSERT_NOTIFICATION,             new PreparedStatementSetter() {



                                                                @Override

                                                                public void setValues(PreparedStatement ps)     throws SQLException {



                                                                                final int notificationId = queryForNextSequence("MCS_NTFN_Q1");

                                                                                notificationDetails.setNotificationId(notificationId);



                                                                                ps.setInt(1, notificationId);



                                                                                if(notificationDetails.getOrderHeaderId()>0)

                                                                                                ps.setLong(2, notificationDetails.getOrderHeaderId());

                                                                                else

                                                                                                ps.setString(2,null);



                                                                 ps.setString(3, notificationDetails.getNotificationSeverityCode());

                                                                 ps.setString(4,notificationDetails.getNotificationtypeCode());

                                                                 ps.setString(5,notificationDetails.getNotificationReasonCode());



                                                                 if(notificationDetails.getPhysicalResourceId()>0){



                                                                                 ps.setLong(6,notificationDetails.getPhysicalResourceId());

                                                                                 ps.setLong(7,1);//PR_TY_SUP_ID =1

                                                                 }

                                                                 else{



                                                                                 ps.setString(6,null);

                                                                                 ps.setString(7,null);//PR_TY_SUP_ID =null as notification created on track/spot but not on equipment

                                                                 }





                                                                                 ps.setLong(8,notificationDetails.getRepairFacilityAreaId()); // REPR_FAC_AREA_ID repair facility area id

                                                                 ps.setString(9,notificationDetails.getLoggedInUserId());

                                                                 ps.setString(10,notificationDetails.getLoggedInUserId());

                                                                 ps.setString(11,notificationDetails.getLoggedInUserTrackId()); //CRTN_USER_TRCK_ID



                                                                 if(notificationDetails.getCreatedLinearLocationSpotId()>0)

                                                                                 ps.setLong(12,notificationDetails.getCreatedLinearLocationSpotId());

                                                                                                else

                                                                                                                ps.setString(12,null);





                                                                                 ps.setString(13,notificationDetails.getNotificationSourceIndicator()); //CRTN_USER_TRCK_ID

                                                                                ps.setString(14,notificationDetails.getLoggedInUserTrackId()); //LAST_UPTD_USER_TRCK_ID



                                                                                 ps.setString(15,notificationDetails.getProblemCounterMeasureSheetInd()); //PROB_CNTR_MSUR_SHT_IND,



                                                                                 if(notificationDetails.getTaskOrderHeaderId() >0)

                                                                                                ps.setLong(16,notificationDetails.getTaskOrderHeaderId()); //ORD_ITEM_ORD_HDR_ID

                                                                                else

                                                                                                ps.setString(16,null);



                                                                                 if(notificationDetails.getTaskPhysicalResourceId() >0)

                                                                                                ps.setLong(17,notificationDetails.getTaskPhysicalResourceId()); //ORD_ITEM_PHYS_RESR_ID

                                                                                else

                                                                                                ps.setString(17,null);



                                                                                 if(notificationDetails.getTaskItemWorkId() >0)

                                                                                                ps.setLong(18,notificationDetails.getTaskItemWorkId()); // ITEM_WORK_ID

                                                                                else

                                                                                                ps.setString(18, null);





                                                                                 ps.setString(19, notificationDetails.getCategoryIndicator());//NTFN_CATG_IND







                                                                }

                                                });

                                } catch (DataAccessException exception) {

                                                logger.error("Error while inserting notification   : ",           exception);

                                                throw new ClientException(ErrorCodes.SQL_DATAACCESS_ERROR,           "SQL DATA ACCESS ERROR WHILE INSERTING NOTIFICAITON");

                                } catch (Exception exception) {

                                                logger.error("Error while inserting notification : ", exception);

                                                throw new ClientException(ErrorCodes.GENERIC_REPOSITORY_ERROR,                exception.getMessage());

                                }

                }







                private void insertNewNotificationStatus(final NotificationStatusDetails notificationStatusDetails, final String loggedInUserId, final String loggedInUserTrackId) throws ClientException {

                                try {



                                                super.getJdbcTemplate().update( INSERT_NOTIFICATION_STATUS,           new PreparedStatementSetter() {



                                                                @Override

                                                                public void setValues(PreparedStatement ps)     throws SQLException {









                                                                                /*final int notificationStatusSeqId = queryForNextSequence("MCS_NTFN_STAT_Q1");*/



                                                                                int notificationStatusSeqId = 0;



                                                                                try {

                                                                                                notificationStatusSeqId = getInt("select NVL(max(SEQ_ID)+ 1, 1) from MCS_NTFN_STAT WHERE NTFN_ID ="+ notificationStatusDetails.getNotification().getNotificationId());

                                                                                } catch (Exception e) {

                                                                                                try {

                                                                                                                throw new ClientException(ErrorCodes.GENERIC_REPOSITORY_ERROR,         "Exception while pulling new notification status id");

                                                                                                } catch (ClientException e1) {



                                                                                                }

                                                                                }



                                                                                notificationStatusDetails.setStatusSequenceId(notificationStatusSeqId);



                                                                                String logMsg = "INSERT_NOTIFICATION_STATUS: ";

                                                                                logMsg = logMsg + "Notification Id: "+notificationStatusDetails.getNotification().getNotificationId()

                                                                                                                + " Notification Status Id: "+ notificationStatusDetails.getStatusSequenceId();

                                                                                logger.info(logMsg);



                                                                                ps.setLong(1,notificationStatusDetails.getNotification().getNotificationId());

                                                                                ps.setLong(2,notificationStatusSeqId);

                                                                                ps.setString(3,notificationStatusDetails.getStatusHistoryStatCode());

                                                                                ps.setString(4,notificationStatusDetails.getStatCode());

                                                                                //ps.setString(5,notificationStatusDetails.getCommentText());

                                                                                ps.setString(5,loggedInUserId);//CRTN_USER_ID

                                                                                ps.setString(6,loggedInUserId); //LAST_UPTD_USER_ID

                                                                                ps.setString(7,loggedInUserTrackId); //CRTN_USER_TRCK_ID

                                                                                ps.setString(8,loggedInUserTrackId); //LAST_UPTD_USER_TRCK_ID

                                                                }

                                                });

                                } catch (DataAccessException exception) {

                                                logger.error("Error while inserting notification status  : ",               exception);

                                                throw new ClientException(ErrorCodes.SQL_DATAACCESS_ERROR,           "SQL DATA ACCESS ERROR");

                                } catch (Exception exception) {

                                                logger.error("Error while inserting notification status : ", exception);

                                                throw new ClientException(ErrorCodes.GENERIC_REPOSITORY_ERROR,                exception.getMessage());

                                }

                }



                private void insertNewNotificationComment(final NotificationStatusCommentDetails notificationStatusCommentDetails, final String loggedInUserId, final String loggedInUserTrackId) throws ClientException {

                                try {



                                                super.getJdbcTemplate().update( INSERT_NOTIFICATION_COMMENT,    new PreparedStatementSetter() {



                                                                @Override

                                                                public void setValues(PreparedStatement ps)     throws SQLException {



                                                                                final int notificationStatusCommentId = queryForNextSequence("MCS_NTFN_STAT_CMNT_Q1");

                                                                                Calendar cal =Calendar.getInstance();





                                                                                String logMsg = "INSERT_NOTIFICATION_COMMENT: ";

                                                                                logMsg = logMsg + "Notification Id: "+notificationStatusCommentDetails.getNotificationStatus().getNotification().getNotificationId()

                                                                                                                + " Notification StatusId: "+ notificationStatusCommentDetails.getNotificationStatus().getStatusSequenceId()

                                                                                                                +"Notification Comment id: "+ notificationStatusCommentId;

                                                                                logger.info(logMsg);





                                                                                ps.setLong(1,notificationStatusCommentId); //NTFN_STAT_CMNT_ID

                                                                                ps.setLong(2,notificationStatusCommentDetails.getNotificationStatus().getNotification().getNotificationId()); //NTFN_ID

                                                                                ps.setLong(3,notificationStatusCommentDetails.getNotificationStatus().getStatusSequenceId()); //NTFN_STAT_SEQ_ID

                                                                                ps.setString(4,notificationStatusCommentDetails.getCommentHistoryIndicator());//NTFN_HIST_STAT_IND

                                                                                ps.setString(5,notificationStatusCommentDetails.getCommentText());//CMNT_TEXT

                                                                                ps.setTimestamp(6,new Timestamp(cal.getTime().getTime()));//CRTN_TMST

                                                                                ps.setString(7,loggedInUserId);//CRTN_USER_ID

                                                                                ps.setTimestamp(8,new Timestamp(cal.getTime().getTime()));//LAST_UPTD_TMST

                                                                                ps.setString(9,loggedInUserId);//LAST_UPTD_USER_ID



                                                                                ps.setString(10,loggedInUserTrackId); //CRTN_USER_TRCK_ID

                                                                                ps.setString(11,loggedInUserTrackId); //LAST_UPTD_USER_TRCK_ID









                                                                                /*ps.setLong(1,notificationDetails.getNotificationId());

                                                                                ps.setString(2,notificationStatusDetails.getStatusHistoryStatCode());*/



                                                                }

                                                });

                                } catch (DataAccessException exception) {

                                                logger.error("Error while inserting notification comment  : ",        exception);

                                                throw new ClientException(ErrorCodes.SQL_DATAACCESS_ERROR,           "SQL DATA ACCESS ERROR");

                                } catch (Exception exception) {

                                                logger.error("Error while inserting notification comment : ", exception);

                                                throw new ClientException(ErrorCodes.GENERIC_REPOSITORY_ERROR,                exception.getMessage());

                                }

                }



                private void insertNewNotificationMessage(final NotificationStatusMessageDetails notificationStatusMessageDetails, final String loggedInUserId, final String loggedInUserTrackId) throws ClientException {

                                try {



                                                super.getJdbcTemplate().update( INSERT_NOTIFICATION_MESSAGE,       new PreparedStatementSetter() {



                                                                @Override

                                                                public void setValues(PreparedStatement ps)     throws SQLException {



                                                                                final int notificationMessageId = queryForNextSequence("MCS_NTFN_MSG_Q1");

                                                                                Calendar cal =Calendar.getInstance();

                                                                                notificationStatusMessageDetails.setStatusMessageId(notificationMessageId);





                                                                                String logMsg = "INSERT_NOTIFICATION_MESSAGE: ";

                                                                                logMsg = logMsg + "Notification Id: "+notificationStatusMessageDetails.getNotificationStatus().getNotification().getNotificationId()

                                                                                                                + " Notification Status Id: "+ notificationStatusMessageDetails.getNotificationStatus().getStatusSequenceId()

                                                                                                                +"Notification Message id: "+ notificationMessageId;

                                                                                logger.info(logMsg);



                                                                                ps.setLong(1,notificationMessageId); //NTFN_MSG_ID

                                                                                ps.setString(2,notificationStatusMessageDetails.getMsgSentToUserId());//NTFN_MSG_USER_ID

                                                                                ps.setString(3,notificationStatusMessageDetails.getMessageType());//NTFN_MSG_TYPE

                                                                                ps.setTimestamp(4,new Timestamp(cal.getTime().getTime()));//CRTN_TMST

                                                                                ps.setString(5,loggedInUserId);//CRTN_USER_ID

                                                                                ps.setString(6,notificationStatusMessageDetails.getEnaMessageId()+"");//ENA_MSG_ID

                                                                                ps.setTimestamp(7,new Timestamp(cal.getTime().getTime()));//LAST_UPTD_TMST

                                                                                ps.setString(8,loggedInUserId);//LAST_UPTD_USER_ID

                                                                                ps.setLong(9,notificationStatusMessageDetails.getNotificationStatus().getNotification().getNotificationId()); //NTFN_ID

                                                                                ps.setLong(10,notificationStatusMessageDetails.getNotificationStatus().getStatusSequenceId()); //NTFN_STAT_SEQ_ID

                                                                                ps.setString(11,loggedInUserTrackId); //CRTN_USER_TRCK_ID

                                                                                ps.setString(12,loggedInUserTrackId); //LAST_UPTD_USER_TRCK_ID

                                                                                ps.setString(13,notificationStatusMessageDetails.getOriginalMessageDataFormat()); //ORGL_MSG_FMT_DATA

                                                                                ps.setString(14,notificationStatusMessageDetails.getMessageDelvryChanType()); //MSG_DLVY_CHNL_TYPE

                                                                                ps.setString(15,notificationStatusMessageDetails.getMessageSentToUserDeliveryAddress()); //MSG_DLVY_ADDR



                                                                }

                                                });

                                } catch (DataAccessException exception) {

                                                logger.error("Error while inserting notification message  : ",          exception);

                                                throw new ClientException(ErrorCodes.SQL_DATAACCESS_ERROR,           "SQL DATA ACCESS ERROR");

                                } catch (Exception exception) {

                                                logger.error("Error while inserting notification message : ", exception);

                                                throw new ClientException(ErrorCodes.GENERIC_REPOSITORY_ERROR,                exception.getMessage());

                                }

                }





                public void insertNewNotificationMessageStatus(final NotificationMessageStatusDetails notificationMessageStatusDetails, final String loggedInUserId, final String loggedInUserTrackId) throws ClientException {

                                try {



                                                super.getJdbcTemplate().update( INSERT_NOTIFICATION_MESSAGE_STATUS,      new PreparedStatementSetter() {



                                                                @Override

                                                                public void setValues(PreparedStatement ps)     throws SQLException {



                                                                                final int notificationMessageId = queryForNextSequence("MCS_NTFN_MSG_STAT_Q1");

                                                                                Calendar cal =Calendar.getInstance();

                                                                                notificationMessageStatusDetails.setMessageStatusId(notificationMessageId);



                                                                                String logMsg = "INSERT_NOTIFICATION_MESSAGE_STATUS: ";

                                                                                logMsg = logMsg + "Notification Message Id: "+notificationMessageStatusDetails.getNotificationStatusMessage().getStatusMessageId()

                                                                                                                +"Notification Message Status id: "+ notificationMessageId;

                                                                                logger.info(logMsg);





                                                                                ps.setLong(1,notificationMessageId); //NTFN_MSG_STAT_ID

                                                                                ps.setLong(2,notificationMessageStatusDetails.getNotificationStatusMessage().getStatusMessageId()); //NTFN_MSG_ID

                                                                                ps.setString(3,notificationMessageStatusDetails.getMsgHistStatInd()); //NTFN_HIST_STAT_IND

                                                                                ps.setString(4,notificationMessageStatusDetails.getMsgStatCode()); //NTFN_MSG_STAT_CODE

                                                                                ps.setTimestamp(5,new Timestamp(cal.getTime().getTime()));//MSG_STAT_CRTN_TMST

                                                                                ps.setTimestamp(6,new Timestamp(cal.getTime().getTime()));//CRTN_TMST

                                                                                ps.setString(7,loggedInUserId);//CRTN_USER_ID

                                                                                ps.setString(8,loggedInUserTrackId); //CRTN_USER_TRCK_ID

                                                                                ps.setTimestamp(9,new Timestamp(cal.getTime().getTime()));//LAST_UPTD_TMST

                                                                                ps.setString(10,loggedInUserId);//LAST_UPTD_USER_ID

                                                                                ps.setString(11,loggedInUserTrackId); //LAST_UPTD_USER_TRCK_ID



                                                                }

                                                });

                                } catch (DataAccessException exception) {

                                                logger.error("Error while inserting notification message status  : ",             exception);

                                                throw new ClientException(ErrorCodes.SQL_DATAACCESS_ERROR,           "SQL DATA ACCESS ERROR");

                                } catch (Exception exception) {

                                                logger.error("Error while inserting notification message : ", exception);

                                                throw new ClientException(ErrorCodes.GENERIC_REPOSITORY_ERROR,                exception.getMessage());

                                }

                }





                private void updateNotificationData(final NotificationDetails notificationDetails,String query) throws ClientException {

                                try {



                                                super.getJdbcTemplate().update( query,               new PreparedStatementSetter() {



                                                                @Override

                                                                public void setValues(PreparedStatement ps)     throws SQLException {









                                                                }

                                                });

                                } catch (DataAccessException exception) {

                                                logger.error("Error while updating notification   : ",           exception);

                                                throw new ClientException(ErrorCodes.SQL_DATAACCESS_ERROR,           "SQL DATA ACCESS ERROR WHILE UPDATING NOTIFICAITON");

                                } catch (Exception exception) {

                                                logger.error("Error while updating notification : ", exception);

                                                throw new ClientException(ErrorCodes.GENERIC_REPOSITORY_ERROR,                exception.getMessage());

                                }

                }





                //Update notification status as H for old ones before inserting

                private void updateNotificationStatusData(final NotificationStatusDetails notificationStatusDetails, final String loggedInUserId, final String loggedInUserTrackId) throws ClientException {

                                try {



                                                super.getJdbcTemplate().update( UPDATE_NOTIFICATION_STATUS_DATA,            new PreparedStatementSetter() {



                                                                @Override

                                                                public void setValues(PreparedStatement ps)     throws SQLException {



                                                                                String logMsg = "UPDATE_NOTIFICATION_STATUS_DATA: ";

                                                                                logMsg = logMsg + "Notification Id: "+notificationStatusDetails.getNotification().getNotificationId()

                                                                                                                +"Notification Status id: "+ notificationStatusDetails.getStatusSequenceId();

                                                                                logger.info(logMsg);



                                                                                Calendar cal =Calendar.getInstance();



                                                                                ps.setTimestamp(1,new Timestamp(cal.getTime().getTime()));//LAST_UPTD_TMST

                                                                                ps.setString(2, loggedInUserId);

                                                                                ps.setString(3, loggedInUserTrackId);

                                                                                ps.setLong(4,notificationStatusDetails.getNotification().getNotificationId());

                                                                                ps.setLong(5,notificationStatusDetails.getStatusSequenceId());



                                                                }

                                                });

                                } catch (DataAccessException exception) {

                                                logger.error("Error while updating notification status  : "+ notificationStatusDetails.getStatusSequenceId(),               exception);

                                                throw new ClientException(ErrorCodes.SQL_DATAACCESS_ERROR,           "SQL DATA ACCESS ERROR WHILE UPDATING NOTIFICAITON STATUS");

                                } catch (Exception exception) {

                                                logger.error("Error while updating notification status : ", exception);

                                                throw new ClientException(ErrorCodes.GENERIC_REPOSITORY_ERROR,                exception.getMessage());

                                }

                }



                //Update notification Message Id

                private void updateNotificationForEnaMsgId(final NotificationStatusMessageDetails notificationStatusMessageDetails, final String loggedInUserId, final String loggedInUserTrackId) throws ClientException {

                                try {



                                                super.getJdbcTemplate().update( UPDATE_NOTIFICATION_MESSAGE_FOR_MSG_ID,        new PreparedStatementSetter() {



                                                                @Override

                                                                public void setValues(PreparedStatement ps)     throws SQLException {



                                                                                String logMsg = "UPDATE_MCS_NTFN_MSG_DATA: ";

                                                                                logMsg = logMsg + "Notification Ena Id: "+notificationStatusMessageDetails.getEnaMessageId();



                                                                                logger.info(logMsg);



                                                                                Calendar cal =Calendar.getInstance();

                                                                                if(notificationStatusMessageDetails.getEnaMessageId() != 0)

                                                                                                ps.setLong(1, notificationStatusMessageDetails.getEnaMessageId());

                                                                                else{

                                                                                                ps.setLong(1,0);

                                                                                }

                                                                                //ps.setString(2,notificationStatusMessageDetails.getOriginalMessageDataFormat());



                                                                                String strContent = notificationStatusMessageDetails.getOriginalMessageDataFormat();

                                                                                byte[] byteContent = strContent.getBytes();

                                                                                Blob blob = ps.getConnection().createBlob();//Where connection is the connection to db object.

//                                                                            String string = Arrays.toString(byteContent);

//                                                                            byte[] decodedPicData = Base64.decodeBase64(string);



                                                                                blob.setBytes(1, byteContent);



                                                                                ps.setBlob(2, blob);



                                                                                ps.setTimestamp(3,new Timestamp(cal.getTime().getTime()));//LAST_UPTD_TMST

                                                                                ps.setString(4, loggedInUserId);

                                                                                ps.setString(5, loggedInUserTrackId);

                                                                                ps.setLong(6,notificationStatusMessageDetails.getStatusMessageId());





                                                                }

                                                });

                                } catch (DataAccessException exception) {

                                                logger.error("Error while updating ENA Message Id  : "+ notificationStatusMessageDetails.getEnaMessageId(),    exception);

                                                throw new ClientException(ErrorCodes.SQL_DATAACCESS_ERROR,           "SQL DATA ACCESS ERROR WHILE UPDATING ENA MESSAGE ID ");

                                } catch (Exception exception) {

                                                logger.error("Error while updating ENA Message Id  : ", exception);

                                                throw new ClientException(ErrorCodes.GENERIC_REPOSITORY_ERROR,                exception.getMessage());

                                }

                }







                //Update notification comments as H for old ones before inserting a new one

                                private void updateNotificationCommentsData(final NotificationStatusCommentDetails notificationStatusCommentDetails, final String loggedInUserId, final String loggedInUserTrackId) throws ClientException {

                                                try {



                                                                super.getJdbcTemplate().update( UPDATE_NOTIFICATION_STATUS_COMMENT_DATA,                new PreparedStatementSetter() {



                                                                                @Override

                                                                                public void setValues(PreparedStatement ps)     throws SQLException {





                                                                                                String logMsg = "UPDATE_NOTIFICATION_STATUS_COMMENT_DATA: ";

                                                                                                logMsg = logMsg + "Notification Id: "+notificationStatusCommentDetails.getNotificationStatus().getNotification().getNotificationId()

                                                                                                                                +"Notification Status id: "+ notificationStatusCommentDetails.getNotificationStatus().getStatusSequenceId()

                                                                                                                                +"Notification status comment id: "+notificationStatusCommentDetails.getStatusCommentId();

                                                                                                logger.info(logMsg);





                                                                                                Calendar cal =Calendar.getInstance();



                                                                                                ps.setTimestamp(1,new Timestamp(cal.getTime().getTime()));//LAST_UPTD_TMST

                                                                                                ps.setString(2, loggedInUserId);

                                                                                                ps.setString(3, loggedInUserTrackId);

                                                                                                ps.setLong(4,notificationStatusCommentDetails.getNotificationStatus().getNotification().getNotificationId());

                                                                                                ps.setLong(5,notificationStatusCommentDetails.getStatusCommentId());

                                                                                                ps.setLong(6,notificationStatusCommentDetails.getNotificationStatus().getStatusSequenceId());



                                                                                }

                                                                });

                                                } catch (DataAccessException exception) {

                                                                logger.error("Error while updating notification comment status    : "+ notificationStatusCommentDetails.getNotificationStatus().getNotification().getNotificationId() ,  exception);

                                                                throw new ClientException(ErrorCodes.SQL_DATAACCESS_ERROR,           "SQL DATA ACCESS ERROR WHILE INSERTING NOTIFICAITON");

                                                } catch (Exception exception) {

                                                                logger.error("Error while updating notification comment status : ", exception);

                                                                throw new ClientException(ErrorCodes.GENERIC_REPOSITORY_ERROR,                exception.getMessage());

                                                }

                                }







                                //Update notification message as H for old ones before inserting a new one

                                                                public void updateNotificationMessageStatusData(final NotificationMessageStatusDetails notificationMessageStatusDetails, final String loggedInUserId, final String loggedInUserTrackId) throws ClientException {

                                                                                try {



                                                                                                super.getJdbcTemplate().update( UPDATE_NOTIFICATION_MESSAGE_STATUS_DATA,         new PreparedStatementSetter() {



                                                                                                                @Override

                                                                                                                public void setValues(PreparedStatement ps)     throws SQLException {





                                                                                                                                String logMsg = "UPDATE_NOTIFICATION_MESSAGE_STATUS_DATA: ";

                                                                                                                                logMsg = logMsg

                                                                                                                                                                +"Notification message id: "+ notificationMessageStatusDetails.getMessageStatusId()

                                                                                                                                                                +"Notification message status id: "+notificationMessageStatusDetails.getNotificationStatusMessage().getStatusMessageId();

                                                                                                                                logger.info(logMsg);



                                                                                                                                Calendar cal =Calendar.getInstance();



                                                                                                                                ps.setTimestamp(1,new Timestamp(cal.getTime().getTime()));//LAST_UPTD_TMST

                                                                                                                                ps.setString(2,loggedInUserId);//LAST_UPTD_USER_ID

                                                                                                                                ps.setString(3,loggedInUserTrackId); //LAST_UPTD_USER_TRCK_ID

                                                                                                                                ps.setLong(4,notificationMessageStatusDetails.getMessageStatusId()); //NTFN_MSG_STAT_ID

                                                                                                                                ps.setLong(5,notificationMessageStatusDetails.getNotificationStatusMessage().getStatusMessageId()); //NTFN_MSG_ID



                                                                                                                }

                                                                                                });

                                                                                } catch (DataAccessException exception) {

                                                                                                logger.error("Error while updating notification message status    : " ,                exception);

                                                                                                throw new ClientException(ErrorCodes.SQL_DATAACCESS_ERROR,                "SQL DATA ACCESS ERROR WHILE UPDATING NOTIFICAITON MESSAGE STATUS");

                                                                                } catch (Exception exception) {

                                                                                                logger.error("Error while updating notification message status : ", exception);

                                                                                                throw new ClientException(ErrorCodes.GENERIC_REPOSITORY_ERROR,         exception.getMessage());

                                                                                }

                                                                }





                                @Override

                                public void getAssignmentsForSupervisors(NotificationReportSearchOptions searchOptions,NotificationReportList notificationReportList) throws ClientException {



                                                try {

                                                                long startTime = System.currentTimeMillis();



                                                                String query =  GET_ASSIGNMENT_DETAILS;

                                                                Object[] inputObjects = new Object[]{DateUtils.getDateAsString(searchOptions.getWorkDate(), DateUtils.MM_DD_YYYY_FORMAT),searchOptions.getRepairFacilityAreaid(), searchOptions.getShift(),searchOptions.getEmployeeId()};



                                                                logger.info("Query to get assignments for supervisors"+query);

                                                                logger.info("[[----------------Inputs for the query");

                                                                for(Object inputObject : inputObjects)

                                                                                logger.info("inputObject :- "+inputObject);

                                                                logger.info("Inputs for the query ----------------]]");



                                                                queryForList(query.toString(),inputObjects, getAssignmentListExtractor(notificationReportList));



                                                                //LMPCUtils.writeMetricsLog("NotificationsRepositoryImpl getAssignmentsForSupervisors pulling GET_ASSIGNMENT_DETAILS took : " + (System.currentTimeMillis() - startTime));



                                                }              catch (DataAccessException exception) {

                                                                logger.error("Error while getting assignment details for supvervisor: ",exception);

                                                                throw new ClientException(ErrorCodes.SQL_DATAACCESS_ERROR, "SQL DATA ACCESS ERROR");

                                                }

                                                catch (Exception exception) {

                                                                logger.error("Error while getting assignment details for supvervisor: ",exception);

                                                                throw new ClientException(ErrorCodes.GENERIC_REPOSITORY_ERROR, exception.getMessage());

                                                }

                   }



                                @Override

                                public void updateEquipmentDetails(NotificationReportList notificationReportList)throws ClientException {



                                                try {

                                                                logger.info("Start of getEquipmentDetails : physResrIDs("+notificationReportList.getPhysResrIdList().size()+")");



                                                                if(CollectionUtils.isNotEmpty(notificationReportList.getPhysResrIdList()))

                                                                {



                                                                                String query = GET_EQUIPMENT_DETAILS;

                                                                                String preparedQuery = DBUtils.getPreparedInClause(notificationReportList.getPhysResrIdList().size(),"ORDHDR.PHYS_RESR_ID");

                                                                                query = String.format(query, preparedQuery);

                                                                                logger.info("updateOpenWorkOrderDetails final Query: "+ query);



                                                                                EquipmentDetailsList equipmentDetailsList = (EquipmentDetailsList) queryForList(query, notificationReportList.getPhysResrIdList().toArray(), EquipmentDetailsExtractor());



                                                                                notificationReportList.updateEquipmentDetails(equipmentDetailsList);

                                                                }

                                                }

                                                catch (DataAccessException exception) {

                                                                logger.error("Error while getting Equipment Details for phyResIds "+notificationReportList.getPhysResrIdList().size()+": ",exception);

                                                                throw new ClientException(ErrorCodes.SQL_DATAACCESS_ERROR, "SQL DATA ACCESS ERROR: "+exception.getCause());

                                                }

                                                catch (Exception exception) {

                                                                logger.error("Error while getting Equipment Details for phyResIds "+notificationReportList.getPhysResrIdList().size()+": ",exception);

                                                                throw new ClientException(ErrorCodes.GENERIC_REPOSITORY_ERROR, exception.getMessage());

                                                }



                                }





                                private ResultSetExtractor EquipmentDetailsExtractor() {



                                                return new ResultSetExtractor(){



                                                                @Override

                                                                public EquipmentDetailsList extractData(ResultSet resultSet)

                                                                                                throws SQLException, DataAccessException {



                                                                                EquipmentDetailsList equipmentsList = new EquipmentDetailsList();



                                                                                while (resultSet.next()) {



                                                                                                EquipmentDetails equipment = new EquipmentDetails();



                                                                                                String eqmtInit = resultSet.getString("EQMT_INIT");

                                                                                                String eqmtNbr = resultSet.getString("EQMT_NBR");

                                                                                                String physResrId = resultSet.getString("PHYS_RESR_ID");



                                                                                                equipment.setEqmtInit(eqmtInit);

                                                                                                equipment.setEqmtNbr(eqmtNbr);

                                                                                                equipment.setPhysResrId(physResrId);



                                                                                                equipmentsList.add(equipment);

                                                                                }



                                                                                return equipmentsList;

                                                                }



                                                };

                                }



                private ResultSetExtractor  getAssignmentListExtractor(final NotificationReportList notificationReportList) {



                                return new ResultSetExtractor() {

                                                @Override

                                                public NotificationReportList extractData(ResultSet resultSet)

                                                                                throws SQLException, DataAccessException {



                                                                while (resultSet.next()) {



                                                                                String orderHeaderId = resultSet.getString("ORD_HDR_ID");

                                                                                String physResrId = resultSet.getString("PHYS_RESR_ID");

                                                                                String assignToUserTrackId = resultSet.getString("ASGN_TO_USER_TRCK_ID");

                                                                                String assignmentCreationTrackId = resultSet.getString("CRTN_USER_TRCK_ID");



                                                                                notificationReportList.updateAssignmentInfo(assignmentCreationTrackId, assignToUserTrackId, physResrId);



                                                                }



                                                return notificationReportList;

                                  }

                   };

                }



                public TransactionTemplate getTransactionTemplate() {

                                return transactionTemplate;

                }



                public void setTransactionTemplate(TransactionTemplate transactionTemplate) {

                                this.transactionTemplate = transactionTemplate;

                }






                private static final String GET_EQUIPMENT_DETAILS =

                                " SELECT  ACA.EQMT_INIT,    "+

        " ACA.EQMT_NBR,              "+

        " ACA.PHYS_RESR_ID          "+

        " FROM ACA_MAJ_EQMT ACA     "+

        " WHERE ACA.PHYS_RESR_ID  IN %s ";



                private static final String GET_ASSIGNMENT_DETAILS =

                                "  SELECT A.ASGN_TO_USER_TRCK_ID ,A.CRTN_USER_TRCK_ID   , A.ORD_HDR_ID, A.PHYS_RESR_ID   " +

                                " FROM MCS_ORD_ITEM_STEP_USER_ASGN A, MCS_ORD_HDR HDR  "+

                                " WHERE A.WORK_DATE = to_date(?, 'mm/dd/yyyy')                                 "+

                                "   AND A.STAT_CODE IN ('A', 'C')                                              "+

                                "   AND A.REPR_FAC_AREA_ID = ?                                                "+

                                "   AND A.ORD_HDR_ID = HDR.ORD_HDR_ID                                          "+

                                "              AND A.SHFT_IND=?      AND HDR.STAT_CODE = 'O'                               "+

                                "   AND A.CRTN_USER_TRCK_ID=? ";



                                //" GROUP BY A.ASGN_TO_USER_TRCK_ID                                              ";







                private static final String INSERT_NOTIFICATION = new StringBuilder(" INSERT INTO MCS_NTFN")

                .append(" (NTFN_ID, " +

                                                "ORD_HDR_ID, " +

                                                "NTFN_SEVR_CODE, " +

                                                "NTFN_TYPE_CODE, " +

                                                "NTFN_RESN_CODE, " +

                                                "PHYS_RESR_ID, " +

                                                "PR_TY_SUP_ID, ")

                                                .append("  REPR_FAC_AREA_ID, " +

                                                                                "CRTN_TMST, " +

                                                                                "CRTN_USER_ID, " +

                                                                                "LAST_UPTD_TMST, " +

                                                                                "LAST_UPTD_USER_ID, " +

                                                                                "CRTN_USER_TRCK_ID," +

                                                                                " CRTN_LNR_LOCA_SPOT_ID , NTFN_SRC_IND, LAST_UPTD_USER_TRCK_ID, PROB_CNTR_MSUR_SHT_IND, ORD_ITEM_ORD_HDR_ID, ORD_ITEM_PHYS_RESR_ID, ITEM_WORK_ID, NTFN_CATG_IND) ")

                                                                                .append(" VALUES (?,?,?,?,?,?,?,?,SYSDATE,?,SYSDATE,?,?,?,?,?,?,?,?,?,?) ")

                                                                                .toString();





                private static final String INSERT_NOTIFICATION_STATUS = new StringBuilder(" INSERT INTO MCS_NTFN_STAT (NTFN_ID, SEQ_ID, NTFN_HIST_STAT_IND, ")

                .append(" NTFN_STAT_CODE, CRTN_TMST, CRTN_USER_ID, LAST_UPTD_TMST, LAST_UPTD_USER_ID, CRTN_USER_TRCK_ID, LAST_UPTD_USER_TRCK_ID) ")

                .append(" VALUES (?,?,?,?,SYSDATE,?,SYSDATE,?,?,?) ")

                .toString();



                private static final String NTFN_COUNTS_QUERY = "SELECT NS.NTFN_STAT_CODE, COUNT(*) COUNT " +

                                                                                                                                                                                                                "FROM MCS_NTFN N " +

                                                                                                                                                                                                                "JOIN MCS_NTFN_STAT NS " +

                                                                                                                                                                                                                "ON NS.NTFN_ID = N.NTFN_ID " +

                                                                                                                                                                                                                "AND NS.NTFN_HIST_STAT_IND = 'C' " +

                                                                                                                                                                                                                "WHERE ((NS.NTFN_STAT_CODE = 'C' AND NS.CRTN_TMST >= SYSDATE - 1) " +

                                                                                                                                                                                                                " OR (NS.NTFN_STAT_CODE <> 'C')) " +

                                                                                                                                                                                                                "AND N.REPR_FAC_AREA_ID = ? " +

                                                                                                                                                                                                                "GROUP BY NS.NTFN_STAT_CODE";





                                GET_NOTIFICATION_FOR_LOCOMOTIVES = new StringBuilder(" SELECT NTFN.PHYS_RESR_ID physicalResourceId, NTFN.NTFN_SEVR_CODE sevrityCode")

                                                                                                                                                                   .append(" FROM MCS_NTFN NTFN " +

                                                                                                                                                                                                   " INNER JOIN MCS_NTFN_STAT HIST ON HIST.NTFN_ID = NTFN.NTFN_ID "+

                                                                                                                                                                                                   " WHERE HIST.NTFN_HIST_STAT_IND = 'C' AND HIST.NTFN_STAT_CODE NOT IN ('C','X') AND " +

                                                                                                                                                                                                   " NTFN.PHYS_RESR_ID IN :phyResIds ")

                                                                                                                                                                   .toString();