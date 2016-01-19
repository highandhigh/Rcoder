install.packages('lubridate')
library('lubridate')

library(qutke)
key<-"faca4c8ff4dc1502d87944ea9cfd74f19918f0aef37fde6746b61d4d339bfcf3"
init(key)

date <- Sys.Date()-2
date


#����ɸѡ,�ж���SW1
#ʹ��ѭ����������qtid���м���
#industry <- getIndustry(data='industryType',date=date,SW1='��ҵó��',key=key)

#shiyong list() junshi 
#qtid <- industry$qtid

#YalesonChan test shiyong c()
qtid <- list('000001.SZ','000002.SZ')
close <- list()
volume <- list()
prevClose <- list()
quoteChangeDaily <- list()
quoteChangeWeek <- list()
quoteChangeMonth <- list()
quoteChangeYear <- list()
quoteChangeFYear <- list()

#��ȡ��������
lastYearDate <- as.Date(paste(year(date)-1,month(date),day(date),sep='-'))
tradingDay <- getDate(data='tradingDay',startdate=lastYearDate,enddate=date,key=key)
length <- length(tradingDay)
FirstDay <- as.Date(paste(year(date)-1,'1','13',sep='-'))

for(x in qtid){
  
  count <- 1
  x <- '000001.SZ'
  
  mktDaily <- getDailyQuote(data='mktDaily',qtid = x,startdate=date,enddate=date,key=key)
  
  #�������̼�
  close[count]<- mktDaily$close
  #���ս�����
  volume[count] <- mktDaily$volume
  #��һ�����յ����̼�
  prevClose[count] <- mktDaily$prevClose
  #�����ǵ���
  quoteChangeDaily[count] <- (close[[count]]-prevClose[[count]])/prevClose[[count]]
  
  #������򵥵����ڼ��㷽��
  mktWeek <- getDailyQuote(data='mktDaily',qtid = x,startdate=tradingDay[length-5],enddate=tradingDay[length-5],key=key)
  mktMonth <- getDailyQuote(data='mktDaily',qtid = x,startdate=tradingDay[length-20],enddate=tradingDay[length-20],key=key)
  mktYear <- getDailyQuote(data='mktDaily',qtid = x,startdate=tradingDay[1],enddate=tradingDay[1],key=key)
  
  mktFYear <- getDailyQuote(data='mktDaily',qtid = x,startdate=FirstDay,enddate=FirstDay,key=key)
  
  #��һ�ܵ��ǵ��������ڵ�5�������գ�
  quoteChangeWeek[count] <- (close[[count]]-mktWeek$close)/mktWeek$close
  quoteChangeMonth[count] <- (close[[count]]-mktMonth$close)/mktMonth$close
  quoteChangeYear[count] <- (close[[count]]-mktYear$close)/mktYear$close
  quoteChangeFYear[count] <- (close[[count]]-mktFYear$close)/mktFYear$close
  
  count <- count+1
  
}

#'����'=industry$qtid,'����'=industry$ChiName,'����'=industry$date,
stock1 <- data.frame('�������̼�'=close,
                        '�����ǵ���'=quoteChangeDaily,'���ճɽ���'=volume,'��һ���ǵ���'=quoteChangeWeek,
                        '��һ���ǵ���'=quoteChangeMonth,'��һ���ǵ���'=quoteChangeYear,
                        '���������ǵ���'=quoteChangeFYear)

#stock1$date<-as.qtDate(stock1$'����')
#postData(stock1,name='stock1',key=key)