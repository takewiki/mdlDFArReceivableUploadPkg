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

  sql = paste0(" truncate table rds_erp_byd_src_t_ar_Receivable_list_input ")


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
  sql = paste0(" CALL rds_erp_byd_src_proc_ar_Receivable_insert();  ")


  res = tsda::mysql_update2(token = dms_token,sql_str =sql )
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
from rds_erp_byd_src_t_ar_Receivable_list
WHERE cast(FInvoiceDate as date) >= '",FStartDate,"' AND cast(FInvoiceDate as date)  <= '",FEndDate,"';


               ")


  res = tsda::mysql_select2(token = dms_token,sql =sql )
  return(res)

}
