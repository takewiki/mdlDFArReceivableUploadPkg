#' 清空临时表
#'
#' @param dms_token 第二个参数
#'
#' @return 两个数的和
#' @export
#'
#' @examples
#' arReceivable_delete
arReceivable_delete <- function(dms_token) {

  sql = paste0(" truncate table rds_erp_byd_src_t_ar_receivable_list_input ")


  res = tsda::mysql_delete2(token = dms_token,sql_str = sql)

  return(res)

}


#' 更新list表和表头表体数据
#'
#' @param dms_token 第二个参数
#'
#' @return 两个数的和
#' @export
#'
#' @examples
#' arReceivable_insert
arReceivable_insert <- function(dms_token) {
  sql1 = paste0(" INSERT OVERWRITE table rds_erp_byd_src_t_ar_receivable_list_input
SELECT a.*
FROM rds_erp_byd_src_t_ar_receivable_list_input a
LEFT JOIN rds_erp_byd_src_t_ar_receivable_list b
  ON a.FInvoiceNo = b.FInvoiceNo
WHERE b.FInvoiceNo IS NULL; ")

  tsda::mysql_update2(token = dms_token,sql_str =sql1 )

  sql2 = paste0("INSERT INTO rds_erp_byd_src_t_ar_receivable_list
        SELECT
            ROW_NUMBER() OVER (ORDER BY FInvoiceNo, FSaleOrderNo, FSaleOrderSeq)
            + IFNULL((SELECT MAX(fid) FROM rds_erp_byd_src_t_ar_receivable_list), 0) AS FID,
            FInvoiceNo, FExternalRefeNumber, FInvoiceDate, FSellerNumber, FSellerName,
            FCustomerNumber, FCustomerName, FSaleOrgNumber, FSaleOrgName,
            FMaterialNumber, FMaterialName, FSaleOrderNo, FSettleType, FInvoiceType,
            FLogisticsMethod, FSaleOrderSeq, FHSName, FSalDescription,
            FSalExternalRefeNumber, FPlatBillNo, FTrackBillNo, FTaxRate,
            FInvoiceQty, FInvoiceTotalAmount, FInvoiceNetValue, FTaxAmt
        FROM rds_erp_byd_src_t_ar_receivable_list_input;")
  tsda::mysql_update2(token = dms_token,sql_str =sql2)


  sql3 = paste0("    INSERT INTO rds_erp_byd_src_t_ar_receivable (FID, FBillNo, FInvoiceNo, FExternalRefeNumber,
            FInvoiceDate, FSellerNumber, FSellerName, FCustomerNumber, FCustomerName,
            FSaleOrgNumber, FSaleOrgName, FIsDo, FLogMessage, FUpdateTime, FNeedUpdate)
SELECT
    ROW_NUMBER() OVER (ORDER BY FInvoiceNo, FSaleOrgNumber)
    + IFNULL((SELECT MAX(fid) FROM rds_erp_byd_src_t_ar_receivable), 0) AS FID,
    '' AS FBillNo,
    FInvoiceNo, FExternalRefeNumber, FInvoiceDate, FSellerNumber, FSellerName,
    FCustomerNumber, FCustomerName, FSaleOrgNumber, FSaleOrgName,
    0 AS FIsDo, '' AS FLogMessage, NOW() AS FUpdateTime, 0 AS FNeedUpdate
FROM rds_erp_byd_src_t_ar_receivable_list_input
GROUP BY
    FInvoiceNo, FExternalRefeNumber, FInvoiceDate, FSellerNumber, FSellerName,
    FCustomerNumber, FCustomerName, FSaleOrgNumber, FSaleOrgName;")
  tsda::mysql_update2(token = dms_token,sql_str =sql3)

  sql4 = paste0("       INSERT INTO rds_erp_byd_src_t_ar_receivableentry
SELECT
    ROW_NUMBER() OVER (ORDER BY FInvoiceNo, FSaleOrderNo, FSaleOrderSeq)
    + IFNULL((SELECT MAX(fentryid) FROM rds_erp_byd_src_t_ar_receivableentry), 0) AS fentryid,
    '' AS fbillno,
    0 AS Fseq,
    FInvoiceNo,
    FSaleOrgNumber,
    FMaterialNumber,
    FMaterialName,
    FSaleOrderNo,
    FSettleType,
    FInvoiceType,
    FLogisticsMethod,
    REPLACE(FSaleOrderSeq, '#', '0') AS FSaleOrderSeq,
    FHSName,
    FSalDescription,
    FSalExternalRefeNumber,
    FPlatBillNo,
    FTrackBillNo,
    REPLACE(REPLACE(SUBSTRING_INDEX(FTaxRate, ' ', 1), '#', '0'), ',', '') AS FTaxRate,
    NULLIF(REPLACE(REPLACE(SUBSTRING_INDEX(FInvoiceQty, ' ', 1), '#', '0'), ',', ''), '') AS FInvoiceQty,
    NULLIF(REPLACE(REPLACE(SUBSTRING_INDEX(FInvoiceTotalAmount, ' ', 1), '#', ''), ',', ''), '') AS FInvoiceTotalAmount,
    NULLIF(REPLACE(REPLACE(SUBSTRING_INDEX(FInvoiceNetValue, ' ', 1), '#', ''), ',', ''), '') AS FInvoiceNetValue,
    REPLACE(REPLACE(SUBSTRING_INDEX(FTaxAmt, ' ', 1), '#', '3'), ',', '') AS FTaxAmt,
    SUBSTRING_INDEX(FInvoiceQty, ' ', -1) AS Funit,
    SUBSTRING_INDEX(FInvoiceTotalAmount, ' ', -1) AS FCURRENCY,
    '' AS FSrcBillName,
    '' AS FSrcBillNo,
    0 AS FSrcSeq,
    0 AS FIsDo,
    '' AS FLogMessage,
    NOW() AS FUpdateTime,
    0 AS FNeedUpdate
FROM rds_erp_byd_src_t_ar_receivable_list_input;")
  tsda::mysql_update2(token = dms_token,sql_str =sql4)

  sql5 = paste0("TRUNCATE TABLE rds_erp_byd_src_t_ar_receivable_list_input;")


  res = tsda::mysql_update2(token = dms_token,sql_str =sql5 )
  return(res)

}



#' 查询list表
#'
#' @param dms_token 第二个参数
#' @param FStartDate
#' @param FEndDate
#'
#' @return 两个数的和
#' @export
#'
#' @examples
#' arReceivable_select
arReceivable_select <- function(dms_token,FStartDate,FEndDate) {
  sql = paste0("
select
FInvoiceNo	发票号	,
FExternalRefeNumber	外部参考号	,
FInvoiceDate	发票日期	,
FSellerNumber	卖方编码	,
FSellerName	卖方名称	,
FCustomerNumber	客户编码	,
FCustomerName	客户名称	,
FSaleOrgNumber	销售组织编码	,
FSaleOrgName	销售组织名称	,
FMaterialNumber	物料编码	,
FMaterialName	物料名称	,
FSaleOrderNo	销售订单编码	,
FSettleType	结算方式	,
FInvoiceType	发票类型	,
FLogisticsMethod	物流方式	,
FSaleOrderSeq	销售订单行号	,
FHSName	存货名称	,
FSalDescription	销售订单描述	,
FSalExternalRefeNumber	销售订单外部参考号	,
FPlatBillNo	平台订单号	,
FTrackBillNo	运单号	,
FTaxRate	税率	,
FInvoiceQty	发票数量	,
FInvoiceTotalAmount	发票总价值	,
FInvoiceNetValue	发票净值	,
FTaxAmt	税额
from rds_erp_byd_src_t_ar_receivable_list
WHERE cast(FInvoiceDate as date) >= '",FStartDate,"' AND cast(FInvoiceDate as date)  <= '",FEndDate,"';


               ")


  res = tsda::mysql_select2(token = dms_token,sql =sql )
  return(res)

}
