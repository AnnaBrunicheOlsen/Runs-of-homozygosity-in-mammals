# Read in data

source('gen_filepath.R')

msat <- read.csv(datapath('msat_ROH_07092017.csv'),header=T)[1:78,]
msat$msat_Na <- as.numeric(as.character(msat$msat_Na))

roh20 <- read.csv(datapath('roh20X_full_02272018.csv'),header=T)[1:78,] #drop whale

roh20 <- roh20[order(roh20$species),]

head(msat)

#Correlation

hist(msat$hetero)
hist(log(msat$hetero))

hist(msat$msat_Ho)

plot(log(msat$hetero),msat$msat_Ho)
abline(lm(msat$msat_Ho~log(msat$hetero)))

cor(log(msat$hetero),msat$msat_Ho, use="complete.obs")

cor(msat$hetero,msat$msat_Ho,use="complete.obs")

cor.test(log(msat$hetero),msat$msat_Ho)

cor.test(log(msat$ROHlength+1),msat$msat_Ho)
cor.test(log(msat$ROHnumber+1),msat$msat_Ho,method='spearman')

frohs <- log(roh20$Froh+1) 
cor.test(frohs,msat$msat_Ho,method='spearman')

cor.test(msat$msat_Ho,log(roh20$N50))

msat$mass <- scale(roh20$mass)
msat$lat <- scale(roh20$lat)
msat$diet <- msat$Class.of.Consumption
msat$redlist <- msat$Red_list_groups

msat.new <- msat[msat$redlist!="D",]
msat.new$redlist <- factor(msat.new$redlist)

msat.new$diet <- relevel(msat.new$diet,ref="O")

shapiro.test(msat$msat_Ho)

msat.model <- lm(msat_Ho~redlist+diet+mass+lat,data=msat.new)



summary(msat.model)

ex.model <- lm(msat_Ho~redlist,data=msat.new)

## Using number of alleles instead

hist(log(msat$msat_Na))

plot(log(msat$hetero),log(msat$msat_Na))

cor.test(log(msat$hetero),log(msat$msat_Na))
cor.test(log(msat$msat_Na),msat$msat_Ho)

plot(log(msat$msat_Na),msat$msat_Ho)
