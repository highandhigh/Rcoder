library(devtools)
#install_github('qutke/ruibe')
library(qutke)
library(ruibe)
library(xts)
library(plyr)
key<-'ff5ed58edf645c6581e8148db1130dc310fbab5fdccc4b2a9ea0be30f4128ace'
init(key)

#ǰ��׼��
day0<-Sys.Date()            #���½�����
day1<-as.Date('2014-01-01') 				#��ʼ����
# ��ý������ڣ�ֱ����date���͵�
tdate<-getDate(data='tradingDay',key=key)

#��ȡ�����½������뿪ʼ����֮�����������
dates<-tdate[which(tdate>=day1 & tdate<=day0)]

dl<-list()
for(dat in as.character(dates)){
	dl[[dat]]<-getDailyQuote(data='mktFwdDaily',startdate=dat,enddate=dat,key=key)
}
#do.call�����ִ��һ���������ã���һ�����ƻ�һ���������ݸ����Ĳ����б�������
df0<-do.call(rbind, lapply(dl, data.frame, stringsAsFactors=FALSE))
df0$date<-as.Date(df0$date)
# �ӵ�ǰ�����У���λ����   �������һ��,���һ���
dates2<-dates[which(dates<=tail(df0$date,1))]
dlen<-length(dates2)
dateRange<-data.frame(
  x1=rev(tail(dates2,dlen-10)),
  x2=rev(head(dates2,dlen-10))
)


# �ؼ����裬����ֲ�

#apply	X ���У���������
#MARGIN  1��ʾ�����У�2��ʾ�����У�Ҳ������c(1,2)

result<-apply(dateRange,1,function(row){
  cat(row[1],fill=TRUE)
  d1<-as.Date(row[1])
  d2<-as.Date(row[2])  
  stock<- df0[which(df0$date<=d1 & df0$date>=d2),]
  s1<-ddply(stock,.(qtid),summarise,hi=max(fwdAdjHi[1:10]),lo=min(fwdAdjLo[1:10]),
            inf=(fwdAdjClose[10]-lo)/(hi-lo),vol=volume[10]/mean(volume[1:10]),
            yesRet=ret[10],ret=last(ret))
  #����һ��ʱ�������ǹ�Ʊ֧��
  numa<-nrow(stock[which(stock$ret>0),])
  #����һ��ʱ�����µ���Ʊ֧��
  numb<-nrow(stock[which(stock$ret<0),])
  if (numb<numa)                      #����෽ռ����
  {s2<-s1[which(s1$inf>0.9),]         #׷��         
  s3<-s2[-which(s2$yesRet>=0.095),]   #ȥ����ͣ��Ʊ
  }
  else                                   #����շ�ռ����
  {s2<-s1[which(s1$inf<0.2&s1$vol>1.5),] # ����        
  s3<-s2[-which(s2$yesRet<=-0.095),] }   #ȥ����ͣ��Ʊ
  #  s3$date<-d1 
  return(s3)
})
#���ڴ���

# ����ÿ�յ�ƽ��������
for(i in 1:nrow(dateRange)){
  if(nrow(result[[i]])>0) result[[i]]$date = dateRange$x1[i]
}
df1<-do.call(rbind, lapply(result, data.frame, stringsAsFactors=FALSE))
df2<-ddply(df1,.(date),summarise,ret=mean(ret))

idx300<-getDailyQuote(data='mktDataIndex',qtid='000300.SH',key=key)

x1<-as.xts(df2$ret,order.by=as.Date(df2$date))
x2<-as.xts(idx300$ret,order.by=as.Date(idx300$date))
xd<-merge(x1,x2)
xd$x1[which(is.na(xd$x1))]<-0  #NA����
xd$x2[which(is.na(xd$x2))]<-0  #NA����
df<-as.data.frame(merge(cumprod(xd$x1+1),cumprod(xd$x2+1)))
df<-cbind(date=row.names(df),df)
df$date<-as.qtDate(df$date)


