## The data for the coffee coop is stored in five spreadsheets
## info, which shows how prices of things change over time
## consumption, which tracks who has consumed milk or coffee, and when
## people, with information on every participant of the Coffee Coop 
## payments, which tracks all movements of cash in and out of the Coop
## goods, data on all non-monetary goods the coop produces.



## the formula for a coffee-coop person's balance is calculated as 

## all payments - consumption*cost_when_consumed + all goods - any cash payments to this person.

## load libraries
#library(data.table)
library(xtable)
library(lubridate)
## read data
consumption <- read.csv(file="../coffee_database/consumption.csv",stringsAsFactors=FALSE)
payments <- read.csv(file="../coffee_database/payments.csv",stringsAsFactors=FALSE)
info <- read.csv(file="../coffee_database/info.csv",stringsAsFactors=FALSE)
people  <- read.csv(file="../coffee_database/people.csv",stringsAsFactors=FALSE)
goods <- read.csv(file="../coffee_database/goods.csv",stringsAsFactors=FALSE)
## use Base functions
## convert data columns to same formats
consumption$data_date <- ymd(consumption$data_date)
info$Date <- ymd(info$Date)
## First, We merge on date and calculate cost of coffee and milk
costnumbers <- merge(consumption,info,by.x="data_date",by.y="Date")

costnumbers$owing <- with(costnumbers,CostBlack*Coffee+Milk*CostMilk)

owing_total <- with(costnumbers,tapply(owing,ID,sum))
#library(plyr)
#ddply(.data=costnumbers,.variables="ID",summarize,total=sum(owing))

debts <- data.frame(ID=names(owing_total),owing_total,stringsAsFactors=FALSE)

# drunk_total <- with(costnumbers,tapply(Coffee,ID,sum))
# drunk <- data.frame(ID=names(drunk_total),drunk_total,stringsAsFactors=FALSE)
# drinkers <- merge(drunk,people,all=TRUE)
# drinkers[order(drinkers$drunk_total),]

## now, how much did people pay?
#head(payments)
monies <- tapply(payments$Payment,payments$ID,sum)
monies_paid <- data.frame(ID=names(monies),monies,stringsAsFactors=FALSE)

## combine please
money <- merge(debts,monies_paid,all=TRUE)
#str(money)
## has anyone paid but not used? vice versa?
#colSums(is.na(money))

## in fact, these NAs are 0$
money$monies[is.na(money$monies)] <- 0
#money
#str(money)

people_pay <- merge(money,people,by="ID",all.x=TRUE)

## how much total money has each person **purchased** for us?
value_goods <- aggregate(x=goods["Cost"],by=goods["ID"],FUN=sum)

alldat <- merge(people_pay,value_goods,by="ID",all.x=TRUE,fill=0)
alldat$Cost[is.na(alldat$Cost)] <- 0

inter <- intersect(people$ID,money$ID)
#people[!people$ID%in%inter,] ## these two have never taken anything from coop AND never paid

#money[!money$ID%in%inter,]
#inter[!inter%in%money$ID]
#all(inter%in%money$ID)



accounts <- data.frame(ID=alldat$ID,Name=alldat$Printed.Name,balance=alldat$monies-alldat$owing_total+alldat$Cost)
accounts_pres <- accounts[!alldat$Gone,]
accounts_alphabet <- accounts_pres[order(accounts_pres$Name),]


## Zero balances for Sally
accounts_alphabet[accounts_alphabet$ID==214,"balance"] <- 0

## and for Andrew, Flo and Thor?
accounts_alphabet[accounts_alphabet$ID%in%c(18),"balance"] <- 0


## and here we can stop the filtering and merging.  accounts_alphabet contains all the info now.
##ls()[!ls()%in%"accounts_alphabet"]
## we **COULD** remove all the other files but I don't want to.