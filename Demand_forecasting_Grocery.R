library(rnn)
library(RODBC)
library(dplyr)


conn<-odbcConnect("PostgreSQL30")

data<-sqlQuery(conn, paste("select transaction_date,
       sum(case when mcc=6300 then transaction_amount end) Insurance_tran_amount,
               sum(case when mcc=4814 then transaction_amount end) Telecom_tran_amount,
                           sum(case when mcc=4812 then transaction_amount end) Telecom_Equipment_tran_amount,
                           sum(case when mcc=4816 then transaction_amount end) Network_tran_amount,
                           sum(case when mcc=5411 then transaction_amount end) Grocery_tran_amount,
                           sum(case when mcc=4900 then transaction_amount end) Utilities_tran_amount,
                           sum(case when mcc=8211 then transaction_amount end) School_tran_amount,
                           sum(case when mcc=5511 then transaction_amount end) Auto_tran_amount from ", '"westpac_full 2018-11-16 17:04:43".base_transactions', 
               "  where left(customer_sa1,1) = '1' group by 1", sep=''))



