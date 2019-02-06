library(rnn)
library(RODBC)
library(dplyr)
library(plm)


conn<-odbcConnect("PostgreSQL30")

data<-sqlQuery(conn, paste("select cast(cast(customer_sa1 as bigint)/100 as int) sa2, transaction_date,
        count(case when mcc=6300 then transaction_amount end) Insurance_tran_demand,
       sum(case when mcc=6300 then transaction_amount end) / count(case when mcc=6300 then transaction_amount end) Insurance_avg_price,
               sum(case when mcc=4814 then transaction_amount end) Telecom_tran_amount,
                           sum(case when mcc=4812 then transaction_amount end) Telecom_Equipment_tran_amount,
                           sum(case when mcc=4816 then transaction_amount end) Network_tran_amount,
                           sum(case when mcc=5411 then transaction_amount end) Grocery_tran_amount,
                           sum(case when mcc=4900 then transaction_amount end) Utilities_tran_amount,
                           sum(case when mcc=8211 then transaction_amount end) School_tran_amount,
                           sum(case when mcc=5511 then transaction_amount end) Auto_tran_amount from ", '"westpac_full 2018-11-16 17:04:43".base_transactions', 
               "  where left(customer_sa1,1) = '1' group by 1,2", sep=''))

data[is.na(data)]<-0

data$sa2<-as.factor(data$sa2)

formula<-as.formula(paste("insurance_tran_demand", paste(paste(names(data)[-c(1,2,3)], collapse = " + "), "insurance_avg_price * sa2", sep=" + "), sep = " ~ "))

fixed<-plm(formula, data=data, index=c("sa2", "transaction_date"), model="within")

fix_coeff<-summary(fixed)$coefficients

fixed_effects<-data.frame(effects=fixef(fixed))

random<-plm(formula, data=data, index=c("sa2", "transaction_date"), model="random")

random_summary<-summary(random)

random_coeff<-random_summary$coefficients

phtest(fixed, random)

