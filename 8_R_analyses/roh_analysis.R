##################
## Read in Data ##
##################

setwd('8_R_analyses')

#source('script_mass_latitude.R') #Add latlong and bodymass to raw data
source('gen_filepath.R')

roh20 <- read.csv(datapath('roh20X_full_02272018.csv'),header=T)[1:78,] #drop whale
roh20$mean.ROH.length..Kbp.[roh20$mean.ROH.length..Kbp.=='#DIV/0!'] <- NA

#Figure showing distributions of raw response vars

library(TeachingDemos)

tiff(filename=outpath("fig_summary.tiff"),width=90,height=90,units="mm",res=1000, pointsize=6,
     compression = "lzw",type='cairo')

par(mar = c(4.5,3.5,1.5,1) + 0.1, oma=c(0,0,0,0),mgp=c(2.5,1,0))
par(mfrow=c(2,2))

hist(roh20$hetero,xlab="",col='gray',main="Heterozygosity")

hist(roh20$ROHnumber,xlab="",col='gray',main="Number of ROHs")
subplot( 
  hist(roh20$ROHnumber[roh20$ROHnumber<10000], col='gray',xlab='', ylab='',main=""), 
  x=grconvertX(c(0.35,0.85), from='npc'),
  y=grconvertY(c(0.35,0.85), from='npc'),
  type='plt', 
  #pars=list( mar=c(1.5,1.5,0,0)+0.1))
)

rohl <- as.numeric(as.character(roh20$mean.ROH.length..Kbp.))
hist(rohl,xlab="",col='gray',main="Mean ROH Length")
subplot( 
  hist(rohl[rohl<300], col='gray',xlab='', ylab='',main=""), 
  x=grconvertX(c(0.35,0.85), from='npc'),
  y=grconvertY(c(0.35,0.85), from='npc'),
  type='plt', pars=list( mar=c(1.5,1.5,0,0)+0.1)
)

rohf <- roh20$Froh
hist(rohf,xlab="",col='gray',main="Proportion of genome in ROHs")
#subplot( 
#  hist(rohf[rohf<0.0005], col='gray',xlab='', ylab='',main=""), 
#  x=grconvertX(c(0.4,0.9), from='npc'),
#  y=grconvertY(c(0.4,0.9), from='npc'),
#  type='plt', pars=list( mar=c(1.5,1.5,0,0)+0.1)
#)

dev.off()

#Generate response variables (log-transform)
het <- log(roh20$hetero)

numrohs <- log(roh20$ROHnumber+1)
#numrohs[which(is.infinite(numrohs))] <- NA

lenrohs <- log(as.numeric(as.character(roh20$mean.ROH.length..Kbp.))+1)
#lenrohs[which(is.infinite(lenrohs))] <- NA

#proprohs <- log((roh20$SNVROHnumber+1)/(roh20$sites+1))
#proprohs[which(is.infinite(proprohs))] <- NA
frohs <- log(roh20$Froh+1) 

#Test normality
shapiro.test(het)
shapiro.test(numrohs) #Fails
shapiro.test(lenrohs)
#shapiro.test(proprohs) #Fails
shapiro.test(frohs) #Fails

#Clean up covariates
redlist <- relevel(roh20$Red_list_groups,ref='N')
diet <- relevel(roh20$Class.of.Consumption,ref='O')
diet[diet=='H'] <- 'O'
diet <- factor(diet)
lat <- scale(abs(roh20$lat))
mass <- scale(log(roh20$mass))

#Build complete dataset
data <- data.frame(het=het,numrohs=numrohs,lenrohs=lenrohs,frohs=frohs,
                   redlist=redlist,diet=diet,lat=lat,mass=mass)

#Correlations among covariates
head(data)

cor.test(data$lat,data$mass) #No significant correlation

tbl <- table(data[data$redlist!='D',c(5:6)])[c(1,3),]
chisq.test(tbl) #No significant correlation

summary(aov(data$lat~data$redlist)) #No relationship

summary(aov(data$lat~data$diet)) #relationship
summary(lm(data$lat~data$diet)) #Latitude significantly higher for carnivores (but R2 ~0.09)

summary(aov(data$mass~data$diet)) #no relationship

summary(aov(mass~redlist,data=data[data$redlist!='D',])) #relationship
summary(lm(mass~redlist,data=data[data$redlist!='D',])) #Mass significantly higher for threatened species (but R2~0.19)

#N50 explorations

hist(log(roh20$N50))

##

tiff(filename=outpath("fig_N50.tiff"),width=90,height=90,units="mm",res=1000, pointsize=6,
     compression = "lzw",type='cairo')

het.test <- cor.test(log(roh20$N50),het)

par(mar = c(4.5,3.5,1.5,1) + 0.1, oma=c(0,0,0,0),mgp=c(2.5,1,0))
par(mfrow=c(2,2))

##

plot(log(roh20$N50),numrohs, xlab="log(N50)",ylab=bquote('log('*italic(N)[ROH]*')'),pch=19)
nroh.test <- cor.test(log(roh20$N50),numrohs,method='spearman')

r <- round(nroh.test$estimate,2)
text(11,4,bquote(italic('r = ')*.(r)))

pval <- round(nroh.test$p.value,3)
text(11,3,bquote(italic('p = ')*.(pval)))

##

plot(log(roh20$N50),lenrohs, xlab="log(N50)",ylab=bquote('log('*italic(L)[ROH]*')'),pch=19)
nroh.test <- cor.test(log(roh20$N50),lenrohs,method='spearman')

r <- round(nroh.test$estimate,2)
text(11,6,bquote(r == .(r)))

pval <- round(nroh.test$p.value,3)
text(11,5.5,bquote(italic('p = ')*.(pval)))

##

plot(log(roh20$N50),frohs, xlab="log(N50)",ylab=bquote('log('*italic(F)[ROH]*')'),pch=19)
nroh.test <- cor.test(log(roh20$N50),frohs,method='spearman')

r <- round(nroh.test$estimate,2)
text(11,0.4,bquote(r == .(r)))

pval <- round(nroh.test$p.value,3)
text(11,0.37,bquote(italic('p = ')*.(pval)))

dev.off()

#Covariate effects on N50

N50 <- roh20$N50[data$redlist!='D']

data.sub <- data[data$redlist!='D',] #Remove species w/out data
data.sub$redlist <- factor(data.sub$redlist)

n50.test <- lm(log(N50)~redlist+diet+lat+mass, data=data.sub)
summary(n50.test) #N50 significantly lower for carnivores; but no other effects

# Correlations between theta and ROH variables

round(cor(data[,1:4]),2)

cor.test(data$het,data$lenrohs,method='pearson')
cor.test(data$het,data$numrohs,method='spearman')
#cor.test(data$het,data$proprohs,method='spearman')
cor.test(data$het,data$frohs,method='spearman')

cor.test(data$numrohs,data$frohs,method='spearman')
#cor.test(data$numrohs,data$proprohs,method='spearman')
cor.test(data$lenrohs,data$frohs,method='spearman')
#cor.test(data$lenrohs,data$proprohs,method='spearman')
cor.test(data$lenrohs,data$numrohs,method='spearman')


cordata <- cbind(data[,1:4],log(roh20$N50))
library(Hmisc)
rcorr(as.matrix(cordata),type='spearman')
#############################################################

#Heterozygosity Analysis

tiff(filename=outpath("fig_heterozygosity.tiff"),width=90,height=90,units="mm",res=1000, pointsize=6,
     compression = "lzw",type='cairo')

data.sub <- data[data$redlist!='D',] #Remove species w/out data
data.sub$redlist <- factor(data.sub$redlist)

test = lm(het~lat+mass+diet*redlist,data=data.sub)
summary(test)

iso <- t.test(het~redlist,data=data.sub)

#Threatened/diet
HN <- predict(test,newdata=data.frame(lat=mean(data.sub$lat,na.rm=T),mass=mean(data.sub$mass,na.rm=T),diet='O',redlist='N'))
CT <- predict(test,newdata=data.frame(lat=mean(data.sub$lat,na.rm=T),mass=mean(data.sub$mass,na.rm=T),diet='C',redlist='T'))
td.eff <- abs(CT-HN)/abs(HN)*100

#Plot interaction between diet and redlist status
mns <- aggregate(x=data.sub$het,by=list(data.sub$diet,data.sub$redlist),FUN=mean)$x
sds <- aggregate(x=data.sub$het,by=list(data.sub$diet,data.sub$redlist),FUN=sd)$x
nsamp <- aggregate(x=data.sub$het,by=list(data.sub$diet,data.sub$redlist),FUN=length)$x
ses <- sds/sqrt(nsamp)

structure <- c(1,2,3.5,4.5)
upper <- mns+ses
lower <- mns-ses

#cols <- c('black','gray','white')
cols <- rev(c('black','gray'))

par(mar = c(4.5,3.5,1.5,1) + 0.1, oma=c(0,0,0,0),mgp=c(2.5,1,0))
par(fig=c(0,1,0.48,1),new=FALSE)

plot(0,xlim=c(0.5,5),ylim=c(min(lower)*1.02,max(upper)*0.94),xaxt='n',ylab=bquote('log('*theta*')'%+-%'SE'),xlab="",
     main=expression(paste(bold('Red List Status'%*%' Diet Category'))))
axis(1,at=c(1.5,4),labels=c('Non-threatened','Threatened'),tick=F)

wd=0.07
segments(structure,lower,structure,upper)
segments(structure-wd,upper,structure+wd,upper)
segments(structure-wd,lower,structure+wd,lower)
points(structure,mns,pch=21,bg=cols,cex=2.5)
abline(v=2.75)

text(0.5,-5.5,'A',cex=2)

legend('topright',pch=21,pt.bg=cols,pt.cex=2.5,legend=c('Non-carnivore','Carnivore'),ncol=1)

# beta <- round(test$coefficients[7],3)
# text(5.5,upper[5]+0.25,bquote(beta == .(beta)))
#
# pval <- round(summary(test)$coefficients[7,4],3)
# text(5.5,upper[5]+0.1,bquote(italic('p = ')*.(pval)))

for (i in 1:4){
  text(structure[i],-7.4,bquote(italic('n=')*.(nsamp[i])))
}

##Body Mass

m1 <- predict(test,newdata=data.frame(lat=mean(data.sub$lat,na.rm=T),mass=0,diet='O',redlist='N'))
m2 <- predict(test,newdata=data.frame(lat=mean(data.sub$lat,na.rm=T),mass=1,diet='O',redlist='N'))
mass.eff <- abs(m1-m2)/abs(m1)*100

par(fig=c(0,0.51,0,0.52),new=TRUE)

plot(data.sub$mass,data.sub$het,pch=19,ylab=bquote('log('*theta*')'),main='Body Mass',
     xlab="Body Mass (z-score)")
abline(test$coefficients[1]+mean(data.sub$lat,na.rm=T)*test$coefficients[2],test$coefficients[3])

text(1.7,-4.5,'B',cex=2)

# beta <- round(test$coefficients[3],3)
# text(0.3,-4.6,bquote(beta == .(beta)),adj=c(0,0))
#
# pval <- round(summary(test)$coefficients[3,4],3)
# text(0.3,-4.9,bquote(italic('p = ')*.(pval)),adj=c(0,0))

##Latitude
par(fig=c(0.49,1,0,0.52),new=TRUE)

plot(data.sub$lat,data.sub$het,pch=19,ylab=bquote('log('*theta*')'),main='Latitude', xlab="Latitude (z-score)")
abline(test$coefficients[1]+mean(data.sub$mass,na.rm=T)*test$coefficients[3],test$coefficients[2])

text(2.6,-4.5,'C',cex=2)

# beta <- round(test$coefficients[2],3)
# text(1.7,-4.8,bquote(beta == .(beta)),adj=c(0,0))
#
# pval <- round(summary(test)$coefficients[2,4],3)
# text(1.7,-5.1,bquote(italic('p = ')*.(pval)),adj=c(0,0))


dev.off()

###################################################################

tiff(filename=outpath("fig_lenrohs.tiff"),width=90,height=90,units="mm",res=1000, pointsize=6,
     compression = "lzw",type='cairo')

#Mean ROH Length Analysis
data.sub <- data[data$redlist!='D',] #Remove species w/out data
data.sub$redlist <- factor(data.sub$redlist)

test = lm(lenrohs~lat+mass+diet*redlist,data=data.sub)


test2 = lm(lenrohs~lat+mass+diet+redlist,data=data.sub)

summary(test2)

test=test2

par(mfrow=c(2,2))
par(mar = c(3.5,3.5,1.5,1) + 0.1, oma=c(0,0,0,0),mgp=c(2.5,1,0))

#Redlist status
data.sub <- data[data$redlist!='D',] #Remove species w/out data
data.sub$redlist <- factor(data.sub$redlist)

mns <- aggregate(x=data.sub$lenrohs,by=list(data.sub$redlist),FUN=mean,na.rm=T)$x
sds <- aggregate(x=data.sub$lenrohs,by=list(data.sub$redlist),FUN=sd,na.rm=T)$x
nsamp <- aggregate(x=data.sub$lenrohs,by=list(data.sub$redlist),FUN=length)$x
ses <- sds/sqrt(nsamp)
upper <- mns+ses
lower <- mns-ses

plot(1:2,mns,pch=19,xlim=c(0.5,2.5),xaxt='n',ylim=c(0.9*min(lower),1.05*max(upper)),
     ylab=bquote('log('*italic(L)[ROH]*')'%+-%'SE'),cex=2.5,xlab="",main='Red List Status')
axis(1,at=c(1:2),labels=c('Non-threatened','Threatened'),tick=F)
segments(1:2,lower,1:2,upper)
wd=0.05
segments(c(1:2)-wd,lower,c(1:2)+wd,lower)
segments(c(1:2)-wd,upper,c(1:2)+wd,upper)

# beta <- round(test$coefficients[6],3)
# text(2,3.3,bquote(beta == .(beta)))
#
# pval <- round(summary(test)$coefficients[6,4],3)
# text(2,3.15,bquote(italic('p = ')*.(pval)),cex=1)

for (i in 1:2){
  text(i,2.8,bquote(italic('n=')*.(nsamp[i])))
}

text(0.6,4.2,'A',cex=2)

## Diet Class
cols <- rev(c('black','black'))

mns <- aggregate(x=data.sub$lenrohs,by=list(data.sub$diet),FUN=mean,na.rm=T)$x
sds <- aggregate(x=data.sub$lenrohs,by=list(data.sub$diet),FUN=sd,na.rm=T)$x
nsamp <- aggregate(x=data.sub$lenrohs,by=list(data.sub$diet),FUN=length)$x
ses <- sds/sqrt(nsamp)
upper <- mns+ses
lower <- mns-ses

plot(1:2,mns,pch=19,xlim=c(0.5,2.5),xaxt='n',ylim=c(0.9*min(lower),1.05*max(upper)),
     ylab=bquote('log('*italic(L)[ROH]*')'%+-%'SE'),cex=2.5,xlab="",main='Diet Category')
axis(1,at=c(1:2),labels=c('Non-carnivore','Carnivore'),tick=F)
segments(1:2,lower,1:2,upper)
wd=0.05
segments(c(1:2)-wd,lower,c(1:2)+wd,lower)
segments(c(1:2)-wd,upper,c(1:2)+wd,upper)
points(1:2,mns,pch=21,bg=cols,cex=2.5)

# beta <- round(test$coefficients[4],3)
# text(2,3.65,bquote(beta == .(beta)))
#
# beta <- round(test$coefficients[5],3)
# text(3,3.35,bquote(beta == .(beta)))
#
#
# pval <- round(summary(test)$coefficients[4,4],3)
# text(2,3.5,bquote(italic('p = ')*.(pval)),cex=1)
#
# pval <- round(summary(test)$coefficients[5,4],3)
# text(3,3.2,bquote(italic('p = ')*.(pval)),cex=1)


for (i in 1:2){
  text(i,2.4,bquote(italic('n=')*.(nsamp[i])))
}

text(0.6,3.9,'B',cex=2)

##Body Mass
m1 <- predict(test2,newdata=data.frame(lat=mean(data.sub$lat,na.rm=T),mass=0,diet='O',redlist='N'))
m2 <- predict(test2,newdata=data.frame(lat=mean(data.sub$lat,na.rm=T),mass=1,diet='O',redlist='N'))
mass.eff <- abs(m1-m2)/abs(m1)*100

plot(data.sub$mass,data.sub$lenrohs,pch=19,ylab=bquote('log('*italic(L)[ROH]*')'),main='Body Mass',
     xlab="Body Mass (z-score)")
abline(test$coefficients[1]+mean(data.sub$lat,na.rm=T)*test$coefficients[2],test$coefficients[3])

text(-1.6,7.2,'C',cex=2)

# beta <- round(test$coefficients[3],3)
# text(-1.5,7.2,bquote(beta == .(beta)),adj=c(0,0))
#
# pval <- round(summary(test)$coefficients[3,4],3)
# text(-1.5,6.65,bquote(italic('p = ')*.(pval)),adj=c(0,0))

##Latitude
l1 <- predict(test2,newdata=data.frame(lat=0,mass=mean(data.sub$mass,na.rm=T),diet='O',redlist='N'))
l2 <- predict(test2,newdata=data.frame(lat=1,mass=mean(data.sub$mass,na.rm=T),diet='O',redlist='N'))
lat.eff <- abs(l1-l2)/abs(l1)*100


plot(data.sub$lat,data.sub$lenrohs,pch=19,ylab=bquote('log('*italic(L)[ROH]*')'),main='Latitude',
     xlab="Latitude (z-score)")
abline(test$coefficients[1]+mean(data.sub$mass)*test$coefficients[3],test$coefficients[2])

text(2.5,7.2,'D',cex=2)

# beta <- round(test$coefficients[2],3)
# text(-0.5,7.2,bquote(beta == .(beta)),adj=c(0,0))
#
# pval <- round(summary(test)$coefficients[2,4],3)
# text(-0.5,6.65,bquote(italic('p = ')*.(pval)),adj=c(0,0))

dev.off()

###################################################################

#Number of ROHS analysis: not normal, so doing non-parametric analysis

tiff(filename=outpath("fig5_num_rohs.tiff"),width=90,height=90,units="mm",res=1000, pointsize=6,
     compression = "lzw",type='cairo')

#Redlist status
data.sub <- data[data$redlist!='D',] #Remove species w/out data
data.sub$redlist <- factor(data.sub$redlist)

nr.redlist <- kruskal.test(data.sub$numrohs,data.sub$redlist)
mns <- aggregate(x=data.sub$numrohs,by=list(data.sub$redlist),FUN=mean)$x
sds <- aggregate(x=data.sub$numrohs,by=list(data.sub$redlist),FUN=sd)$x
nsamp <- aggregate(x=data.sub$numrohs,by=list(data.sub$redlist),FUN=length)$x
ses <- sds/sqrt(nsamp)
upper <- mns+ses
lower <- mns-ses

par(mfrow=c(2,2))
par(mar = c(3.5,3.5,1.5,1) + 0.1, oma=c(0,0,0,0),mgp=c(2.5,1,0))

plot(1:2,mns,pch=19,xlim=c(0.5,2.5),xaxt='n',ylim=c(0.9*min(lower),1.05*max(upper)),
     ylab=bquote('log('*italic(N)[ROH]*')'%+-%'SE'),cex=2.5,xlab="",main='Red List Status')
axis(1,at=c(1:2),labels=c('Non-threatened','Threatened'),tick=F)
segments(1:2,lower,1:2,upper)
wd=0.05
segments(c(1:2)-wd,lower,c(1:2)+wd,lower)
segments(c(1:2)-wd,upper,c(1:2)+wd,upper)
# pval <- round(nr.redlist$p.value,3)
# text(0.75,5.6,bquote(italic('p = ')*.(pval)),cex=1)
for (i in 1:2){
  text(i,3.6,bquote(italic('n=')*.(nsamp[i])))
}

text(0.6,5.7,'A',cex=2)

## Diet Class
nr.diet <- kruskal.test(data$numrohs,data$diet)
mns <- aggregate(x=data$numrohs,by=list(data$diet),FUN=mean)$x
sds <- aggregate(x=data$numrohs,by=list(data$diet),FUN=sd)$x
nsamp <- aggregate(x=data$numrohs,by=list(data$diet),FUN=length)$x
ses <- sds/sqrt(nsamp)
upper <- mns+ses
lower <- mns-ses

cols <- rev(c('black','black'))

plot(1:2,mns,pch=19,xlim=c(0.5,2.5),xaxt='n',ylim=c(0.9*min(lower),1.05*max(upper)),
     ylab=bquote('log('*italic(N)[ROH]*')'%+-%'SE'),cex=2.5,xlab="",main='Diet Category')
axis(1,at=c(1:2),labels=c('Non-carnivore','Carnivore'),tick=F)
segments(1:2,lower,1:2,upper)
wd=0.05
segments(c(1:2)-wd,lower,c(1:2)+wd,lower)
segments(c(1:2)-wd,upper,c(1:2)+wd,upper)
points(1:2,mns,pch=21,bg=cols,cex=2.5)
# pval <- round(nr.diet$p.value,3)
# text(3,6.2,bquote(italic('p = ')*.(pval)),cex=1)
for (i in 1:2){
  text(i,2.8,bquote(italic('n=')*.(nsamp[i])))
}

text(2.4,5.6,'B',cex=2)

#Mass

nr.mass <- cor.test(data$numrohs,data$mass,method='spearman')
plot(data$mass,data$numrohs,pch=19,ylab=bquote('log('*italic(N)[ROH]*')'),main='Body Mass',
     xlab="Body Mass (z-score)",ylim=c(0,13))
# rho=round(nr.mass$estimate,3)
# text(-1.5,12.3,bquote(rho == .(rho)),adj=c(0,0))
# pval <- round(nr.mass$p.value,3)
# text(-1.5,11.2,bquote(italic('p <')~0.001),adj=c(0,0))

text(-1.6,12.4,'C',cex=2)

#Latitude

nr.lat <- cor.test(data$numrohs,data$lat,method='spearman')
plot(data$lat,data$numrohs,pch=19,ylab=bquote('log('*italic(N)[ROH]*')'),main='Latitude',
     xlab="Latitude (z-score)",ylim=c(0,13))
# rho=round(nr.lat$estimate,3)
# text(1.8,12.3,bquote(rho == .(rho)),adj=c(0,0))
# pval <- round(nr.lat$p.value,3)
# text(1.8,11.3,bquote(italic('p = ')*.(pval)),adj=c(0,0))

text(2.6,12.4,'D',cex=2)

dev.off()

##################################################

#Proportion of ROHs
tiff(filename=outpath("fig6_frohs.tiff"),width=90,height=90,units="mm",res=1000, pointsize=6,
     compression = "lzw",type='cairo')

#Redlist status
data.sub <- data[data$redlist!='D',] #Remove species w/out data
data.sub$redlist <- factor(data.sub$redlist)

pr.redlist <- kruskal.test(data.sub$frohs,data.sub$redlist)
mns <- aggregate(x=data.sub$frohs,by=list(data.sub$redlist),FUN=mean)$x
sds <- aggregate(x=data.sub$frohs,by=list(data.sub$redlist),FUN=sd)$x
nsamp <- aggregate(x=data.sub$frohs,by=list(data.sub$redlist),FUN=length)$x
ses <- sds/sqrt(nsamp)
upper <- mns+ses
lower <- mns-ses

par(mfrow=c(2,2))
par(mar = c(3.5,3.5,1.5,1) + 0.1, oma=c(0,0,0,0),mgp=c(2.5,1,0))

plot(1:2,mns,pch=19,xlim=c(0.5,2.5),xaxt='n',ylim=c(0.8*min(lower),1.1*max(upper)),
     ylab=bquote('log('*italic(F)[ROH]*')'%+-%'SE'),cex=2.5,xlab="",main='Red List Status')
axis(1,at=c(1:2),labels=c('Non-threatened','Threatened'),tick=F)
segments(1:2,lower,1:2,upper)
wd=0.05
segments(c(1:2)-wd,lower,c(1:2)+wd,lower)
segments(c(1:2)-wd,upper,c(1:2)+wd,upper)
# pval <- round(pr.redlist$p.value,3)
# text(0.75,-11.1,bquote(italic('p = ')*.(pval)),cex=1)
for (i in 1:2){
  text(i,0.04,bquote(italic('n=')*.(nsamp[i])))
}

text(0.6,0.087,'A',cex=2)

## Diet Class
pr.diet <- kruskal.test(data$frohs,data$diet)
mns <- aggregate(x=data$frohs,by=list(data$diet),FUN=mean)$x
sds <- aggregate(x=data$frohs,by=list(data$diet),FUN=sd)$x
nsamp <- aggregate(x=data$frohs,by=list(data$diet),FUN=length)$x
ses <- sds/sqrt(nsamp)
upper <- mns+ses
lower <- mns-ses
cols <- rev(c('black','black'))

plot(1:2,mns,pch=19,xlim=c(0.5,2.5),xaxt='n',ylim=c(0.8*min(lower),1.1*max(upper)),
     ylab=bquote('log('*italic(F)[ROH]*')'%+-%'SE'),cex=2.5,xlab="",main='Diet Category')
axis(1,at=c(1:2),labels=c('Non-carnivore','Carnivore'),tick=F)
segments(1:2,lower,1:2,upper)
wd=0.05
segments(c(1:2)-wd,lower,c(1:2)+wd,lower)
segments(c(1:2)-wd,upper,c(1:2)+wd,upper)
points(1:2,mns,pch=21,bg=cols,cex=2.5)
# pval <- round(pr.diet$p.value,3)
# text(0.8,-10.9,bquote(italic('p = ')*.(pval)),cex=1)
for (i in 1:3){
  text(i,0.02,bquote(italic('n=')*.(nsamp[i])))
}

text(2.4,0.1,'B',cex=2)

#Mass

pr.mass <- cor.test(data$frohs,data$mass,method='spearman')
plot(data$mass,data$frohs,pch=19,ylab=bquote('log('*italic(F)[ROH]*')'),main='Body Mass',
     xlab="Body Mass (z-score)")
# rho=round(pr.mass$estimate,3)
# text(1,-18,bquote(rho == .(rho)),adj=c(0,0))
# pval <- round(pr.mass$p.value,3)
# #text(13,-13,bquote(italic('p = ')*.(pval)),adj=c(0,0))
# text(1,-19.5,bquote(italic('p <')~0.001),adj=c(0,0))

text(1.75,0.5,'C',cex=2)

#Latitude

pr.lat <- cor.test(data$frohs,data$lat,method='spearman')
plot(data$lat,data$frohs,pch=19,ylab=bquote('log('*italic(F)[ROH]*')'),main='Latitude',
     xlab="Latitude (z-score)")
# rho=round(pr.lat$estimate,3)
# text(1.9,-18,bquote(rho == .(rho)),adj=c(0,0))
# pval <- round(pr.lat$p.value,3)
# text(1.9,-19.5,bquote(italic('p = ')*.(pval)),adj=c(0,0))

text(2.6,0.5,'D',cex=2)

dev.off()

## Supplementary Info

si.table <- roh20[,c('binomial.match','lat','mass')]
names(si.table) <- c('Species','Latitude_centroid','Mass_in_g')

write.csv(si.table,file=outpath('SI_table.csv'),row.names=F)
