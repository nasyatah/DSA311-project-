
# Method 1: Best subset selection
set.seed(4444)
library(randomForest)
library(glmnet)
library(e1071)
library(data.table)
library(dplyr)
hdb<-read.csv("/Users/lowtingyu/Desktop/final_hdb_resale_2023.csv", stringsAsFactors = TRUE)
hdb$area
data <- read.csv("/Users/lowtingyu/Desktop/final_hdb_resale_2023.csv", stringsAsFactors = TRUE)
names(data)
data <- subset(data, select = c(resale_price, month, area, lat, long, floor_area_sqm, flat_model, remaining_lease, avg_storey, no_of_rooms, closestMall, timeToMall, mallsIn10km, closestBeach, timeToBeach, beachesIn10km, closestMRTStation, timeToMRTStation, MRTStationsIn10km, closestPrimarySch, timeToPrimarySch, PrimarySchsIn10km, below1000Pop, below1500Pop, below2000Pop, below2500Pop, below3000Pop, below4000Pop, below5000Pop, below6000Pop, below7000Pop, below8000Pop, below9000Pop, below10000Pop, below11000Pop, below12000Pop, above12000Pop))
ncol(data)
# Converting area to target encoding
data <- data.table(data)
area_encoding <- data[,.(area_mean=mean(resale_price)),by=area]
data <- merge(data, area_encoding, by = "area", all.x = TRUE)
data[, area:=NULL]


# Converting flat_model to target encoding
flat_model_encoding <- data[,.(flat_model_mean=mean(resale_price)),by=flat_model]
data <- merge(data, flat_model_encoding, by = "flat_model", all.x=TRUE)
data[, flat_model:=NULL]
# Converting closestMall to target encoding
closestMall_encoding <- data[,.(closestMall_mean=mean(resale_price)),by=closestMall]
data <- merge(data, closestMall_encoding, by = "closestMall", all.x=TRUE)
data[, closestMall:=NULL]
# Converting closestBeach to target encoding
closestBeach_encoding <- data[,.(closestBeach_mean=mean(resale_price)),by=closestBeach]
data <- merge(data, closestBeach_encoding, by = "closestBeach", all.x=TRUE)
data[, closestBeach:=NULL]
# Converting closestMRTStation to target encoding
closestMRTStation_encoding <- data[,.(closestMRTStation_mean=mean(resale_price)),by=closestMRTStation]
data <- merge(data, closestMRTStation_encoding, by = "closestMRTStation", all.x=TRUE)
data[, closestMRTStation:=NULL]
# Converting closestPrimarySch to target encoding
closestPrimarySch_encoding <- data[,.(closestPrimarySch_mean=mean(resale_price)),by=closestPrimarySch]
data <- merge(data, closestPrimarySch_encoding, by = "closestPrimarySch", all.x=TRUE)
data[, closestPrimarySch:=NULL]
# Converting month to target encoding
month_encoding <- data[,.(month_mean=mean(resale_price)),by=month]
data <- merge(data, month_encoding, by = "month", all.x=TRUE)
data[, month:=NULL]
summary(data)
ncol(data)
# Splitting training and testing data
train <- sample(1:nrow(data),8000)
test <- -train
data.train <- data[train,]
data.test <- data[test,]
train.x <- model.matrix(resale_price~., data=data.train)[,-1]
train.y <- data.train$resale_price
test.x <- model.matrix(resale_price~., data=data.test)[,-1]
test.y <- data.test$resale_price
names(data.train)

ncol(data.train)




#------------------------------------------------------------------------
#PCR using all the variables in the model
pcr.fit.all <- pcr(resale_price~., data=data.train,
                          scale=TRUE, validation="CV")
summary(pcr.fit.all)
validationplot(pcr.fit.all, val.type="MSEP")
pcr.pred.all <- predict(pcr.fit.all, newdata=data.test, ncomp=36)

mse.pcr.all<- mean((pcr.pred.all-test.y)^2)
mse.pcr.all #3278314906
rmse.pcr.all <- mse.pcr.all^0.5
rmse.pcr.all #57256.57

#------------------------------------------------------------------------
#PCR using Best Subset Selection
library(leaps)
bss1 <- regsubsets(resale_price~., data=data.train, really.big=TRUE)
best_subset1 <- which.min(summary(bss1)$bic)
coef_best_subset1 <- coef(bss1,id=best_subset1)
print(coef_best_subset1)
#Variables recommended by Best Subset Selection:
#floor_area_sqm+remaining_lease+avg_storey+mallsIn10km+below1000Pop+below4000Pop+flat_model_mean+closestPrimarySch_mean
library(pls)
pcr.fit.bestsubset <- pcr(resale_price~floor_area_sqm+remaining_lease+avg_storey+mallsIn10km+below1000Pop+below4000Pop+
                            flat_model_mean+closestPrimarySch_mean, data=data.train,
                          scale=TRUE, validation="CV")
summary(pcr.fit.bestsubset)
validationplot(pcr.fit.bestsubset, val.type="MSEP")
pcr.pred.bss <- predict(pcr.fit.bestsubset, newdata=data.test, ncomp=8)
nrow(pcr.pred.bss)
mse.pcr.bss<- mean((pcr.pred.bss-test.y)^2)
mse.pcr.bss #4300414923
rmse.pcr.bss <- mse.pcr.bss^0.5
rmse.pcr.bss #65577.55



#------------------------------------------------------------------------
#PCR using Lasso
library(glmnet)
#lasso model
lasso.mod <- cv.glmnet(train.x, train.y, alpha=1)
lambda.lasso <- lasso.mod$lambda.min
lambda.lasso
summary(lasso.mod)
coefficients.lasso <- coef(lasso.mod, s = "lambda.min")
3.083704e-01
1.973699e-01
-8.533997e+02
#lat+long+floor_area_sqm+remaining_lease+avg_storey+no_of_rooms+timeToMall+mallsIn10km+timeToBeach +beachesIn10km +timeToMRTStation+MRTStationsIn10km+timeToPrimarySch+
  #PrimarySchsIn10km+below1000Pop+below1500Pop+below2000Pop+below2500Pop+below3000Pop+below4000Pop+below5000Pop+below6000Pop+below7000Pop+below8000Pop+below9000Pop+below10000Pop +below11000Pop +below12000Pop +
  #above12000Pop+area_mean+flat_model_mean+closestMall_mean+closestBeach_mean +closestMRTStation_mean closestPrimarySch_mean+month_mean
pcr.fit.lasso <- pcr(resale_price~lat+long+floor_area_sqm+remaining_lease+avg_storey+no_of_rooms+timeToMall+mallsIn10km+timeToBeach+beachesIn10km+
                       timeToMRTStation+MRTStationsIn10km+timeToPrimarySch+PrimarySchsIn10km+below1000Pop+below1500Pop+below2000Pop+below2500Pop+
                       below3000Pop+below4000Pop+below5000Pop+below6000Pop+below7000Pop+below8000Pop+below9000Pop+below10000Pop +below11000Pop+
                       below12000Pop +above12000Pop+closestMall_mean, data=data.train,scale=TRUE, validation="CV")
summary(pcr.fit.lasso)
validationplot(pcr.fit.lasso, val.type="MSEP")
pcr.pred.ls <- predict(pcr.fit.lasso, newdata=data.test, ncomp=30)
nrow(pcr.pred.ls)
mse.pcr.ls<- mean((pcr.pred.ls-test.y)^2)
mse.pcr.ls #3741579743
rmse.pcr.ls <- mse.pcr.ls^0.5
rmse.pcr.ls #61168.45
#------------------------------------------------------------------------
#PLS using all the variables in the model
pls.fit.continuous <- plsr(resale_price~., data=data.train,scale=TRUE, validation="CV") 
summary(pls.fit.continuous)
validationplot(pls.fit.continuous, val.type="MSEP") #remember to look at the numerical output and find the one with the lowest CV value

pls.pred.continuous <- predict(pls.fit.continuous, data.test, ncomp=35)
mse.pls.continous<- mean((pls.pred.continuous-data.test$resale_price)^2)
rmse.pls.continous <- mse.pls.continous^0.5
rmse.pls.continous #57255.74



#------------------------------------------------------------------------
#PLS using best subset selection

pls.fit.bss <- plsr(resale_price~floor_area_sqm+remaining_lease+avg_storey+mallsIn10km+below1000Pop+below4000Pop+flat_model_mean+closestPrimarySch_mean, data=data.train,
                    scale=TRUE, validation="CV") 
validationplot(pls.fit.bss, val.type="MSEP") #remember to look at the numerical output and find the one with the lowest CV value
summary(pls.fit.bss)
pls.pred.bss <- predict(pls.fit.bss, data.test, ncomp=8)
mse.pls.bss<- mean((pls.pred.bss-data.test$resale_price)^2)
rmse.pls.bss <- mse.pls.bss^0.5
rmse.pls.bss #65577.55

#------------------------------------------------------------------------
#PCR using Lasso

pls.fit.lasso <- plsr(resale_price~lat+long+floor_area_sqm+remaining_lease+avg_storey+no_of_rooms+timeToMall+mallsIn10km+timeToBeach +beachesIn10km +timeToMRTStation+MRTStationsIn10km+timeToPrimarySch+PrimarySchsIn10km+below1000Pop+below1500Pop+below2000Pop+below2500Pop+below3000Pop+below4000Pop+below5000Pop+below6000Pop+below7000Pop+below8000Pop+below9000Pop+below10000Pop +below11000Pop +below12000Pop +above12000Pop+closestMall_mean, data=data.train,
                      scale=TRUE, validation="CV") 
validationplot(pls.fit.lasso, val.type="MSEP") #remember to look at the numerical output and find the one with the lowest CV value
summary(pls.fit.lasso)
pls.pred.lasso <- predict(pls.fit.lasso, data.test, ncomp=27)
mse.pls.lasso<- mean((pls.pred.lasso-data.test$resale_price)^2)
rmse.pls.lasso <- mse.pls.lasso^0.5
rmse.pls.lasso #61156.32

#------------------------------------------------------------------------
#Spline using one variable, Floor area
library(boot)
library(splines)
err <- sapply(3:50, function(i) {
  fit <- glm(resale_price ~ bs(floor_area_sqm, df = i), data = data.train) 
  cv.glm(data.train, fit, K = 10)$delta[1]
})
which.min(err)
optimal.spline <- which.min(err)+2
optimal.spline
predict.spline <- predict(glm(resale_price ~ bs(floor_area_sqm, df = optimal.spline), data=data.test))
mse.spline<- mean((predict.spline-data.test$resale_price)^2)
rmse.spline <- mse.spline^0.5
rmse.spline #124287.7

#------------------------------------------------------------------------
#Spline using lasso

err.lasso <- sapply(3:50, function(i) {
  fit <- glm(resale_price ~ bs(lat+long+floor_area_sqm+remaining_lease+avg_storey+no_of_rooms+timeToMall+mallsIn10km+timeToBeach +beachesIn10km +timeToMRTStation+MRTStationsIn10km+timeToPrimarySch+PrimarySchsIn10km+below1000Pop+below1500Pop+below2000Pop+below2500Pop+below3000Pop+below4000Pop+below5000Pop+below6000Pop+below7000Pop+below8000Pop+below9000Pop+below10000Pop +below11000Pop +below12000Pop +above12000Pop+closestMall_mean, df = i), data = data.train) 
  cv.glm(data.train, fit, K = 10)$delta[1]
})
which.min(err.lasso)
optimal.spline.ls <- which.min(err.lasso)+2
optimal.spline.ls
predict.spline.ls <- predict(glm(resale_price ~ bs(lat+long+floor_area_sqm+remaining_lease+avg_storey+no_of_rooms+timeToMall+mallsIn10km+timeToBeach +beachesIn10km +timeToMRTStation+MRTStationsIn10km+timeToPrimarySch+PrimarySchsIn10km+below1000Pop+below1500Pop+below2000Pop+below2500Pop+below3000Pop+below4000Pop+below5000Pop+below6000Pop+below7000Pop+below8000Pop+below9000Pop+below10000Pop +below11000Pop +below12000Pop +above12000Pop+closestMall_mean, df = optimal.spline.ls), data=data.test))
mse.spline.ls<- mean((predict.spline.ls-data.test$resale_price)^2)
rmse.spline.ls <- mse.spline.ls^0.5
rmse.spline.ls #146601.9


#------------------------------------------------------------------------
#Spline using Best Subset Selection
err.bss <- sapply(3:50, function(i) {
  fit.bss <- glm(resale_price ~ bs(floor_area_sqm+remaining_lease+avg_storey+mallsIn10km+below1000Pop+below4000Pop+flat_model_mean+closestPrimarySch_mean
                                  , df = i), data = data.train) 
  cv.glm(data.train, fit.bss, K = 10)$delta[1]
})
which.min(err.bss)
optimal.spline.bss<- which.min(err.bss)+2
optimal.spline.bss
predict.spline.bss <- predict(glm(resale_price ~ bs(floor_area_sqm+remaining_lease+avg_storey+mallsIn10km+below1000Pop+below4000Pop+flat_model_mean+closestPrimarySch_mean, df = optimal.spline.bss), data=data.test))
mse.spline.bss<- mean((predict.spline.bss-data.test$resale_price)^2)
rmse.spline.bss <- mse.spline.bss^0.5
rmse.spline.bss #126545


#------------------------------------------------------------------------
#natural spline using only 1 variable
err.ns1 <- sapply(3:50, function(i) {
  fit.ns1 <- glm(resale_price ~ ns(floor_area_sqm, df = i), data = data.train) 
  cv.glm(data.train, fit.ns1, K = 10)$delta[1]
})
which.min(err.ns1)
optimal.natural.s.1 <- which.min(err.ns1)+2
optimal.natural.s.1
predict.natural.spline1 <- predict(glm(resale_price ~ ns(floor_area_sqm, df = optimal.natural.s.1), data=data.test))
mse.nat.spline1<- mean((predict.natural.spline1-data.test$resale_price)^2)
rmse.spline.nat <- mse.nat.spline1^0.5
rmse.spline.nat #124389.9


#------------------------------------------------------------------------

#spline with variables according to the LASSO model
err.ns1.3 <- sapply(3:50, function(i) {
  nsfit1.3 <- glm(resale_price ~ ns(lat+long+floor_area_sqm+remaining_lease+avg_storey+no_of_rooms+timeToMall+mallsIn10km+timeToBeach +beachesIn10km +timeToMRTStation+MRTStationsIn10km+timeToPrimarySch+PrimarySchsIn10km+below1000Pop+below1500Pop+below2000Pop+below2500Pop+below3000Pop+below4000Pop+below5000Pop+below6000Pop+below7000Pop+below8000Pop+below9000Pop+below10000Pop +below11000Pop +below12000Pop +above12000Pop+closestMall_mean
                                    , df = i), data = data.train) 
  cv.glm(data.train, nsfit1.3, K = 10)$delta[1]
})
which.min(err.ns1.3)
optimal.natural.s.3 <- which.min(err.ns1.3)+2
optimal.natural.s.3
predict.natural.spline1.3 <- predict(glm(resale_price ~ ns(lat+long+floor_area_sqm+remaining_lease+avg_storey+no_of_rooms+timeToMall+mallsIn10km+timeToBeach +beachesIn10km +timeToMRTStation+MRTStationsIn10km+timeToPrimarySch+PrimarySchsIn10km+below1000Pop+below1500Pop+below2000Pop+below2500Pop+below3000Pop+below4000Pop+below5000Pop+below6000Pop+below7000Pop+below8000Pop+below9000Pop+below10000Pop +below11000Pop +below12000Pop +above12000Pop+closestMall_mean, df = optimal.natural.s.3), data=data.test))
mse.nat.spline1.3<- mean((predict.natural.spline1.3-data.test$resale_price)^2)
rmse.spline.nat1.3 <- mse.nat.spline1.3^0.5
rmse.spline.nat1.3 #145617.4

#------------------------------------------------------------------------

#spline with variables according to Best Subset Selection
err1.4 <- sapply(3:50, function(i) {
  fit1.4 <- glm(resale_price ~ bs(floor_area_sqm+remaining_lease+avg_storey+mallsIn10km+below1000Pop+below4000Pop+flat_model_mean+closestPrimarySch_mean
                                  , df = i), data = data.train) 
  cv.glm(data.train, fit1.4, K = 10)$delta[1]
})
which.min(err1.4)
optimal.spline1.4 <- which.min(err1.4)+2
optimal.spline1.4
predict.spline1.4 <- predict(glm(resale_price ~ bs(floor_area_sqm+remaining_lease+avg_storey+mallsIn10km+below1000Pop+below4000Pop+flat_model_mean+closestPrimarySch_mean, df = optimal.spline1.4), data=data.test))
mse.spline1.4<- mean((predict.spline1.4-data.test$resale_price)^2)
rmse.spline1.4 <- mse.spline1.4^0.5
rmse.spline1.4 #126545

#------------------------------------------------------------------------
#smoothing spline one 1 predictor variable : floor_area_sqm
smoothingspline.train <- smooth.spline(data.train$floor_area_sqm, data.train$resale_price, cv=TRUE) 
smoothingspline.train$df
smooth.spine.model<- smooth.spline(data.train$floor_area_sqm, data.train$resale_price, df=smoothingspline.train$df)
smooth.spine.predict <- predict(smooth.spine.model, data.test$floor_area_sqm)

mse.smooth.spline<- mean((smooth.spine.predict$y-data.test$resale_price)^2)
rmse.smooth.spline <- mse.smooth.spline^0.5
rmse.smooth.spline #125551.8

#------------------------------------------------------------------------
#smoothing spline with continuous variables according to the LASSO model

data.train$lat+data.train$long+data.train$floor_area_sqm+data.train$remaining_lease+data.train$avg_storey+data.train$no_of_rooms+data.train$timeToMall+data.train$mallsIn10km+data.train$timeToBeach +data.train$beachesIn10km +data.train$timeToMRTStation+data.train$MRTStationsIn10km+data.train$timeToPrimarySch+data.train$PrimarySchsIn10km+data.train$below1000Pop+data.train$below1500Pop+data.train$below2000Pop+data.train$below2500Pop+data.train$below3000Pop+data.train$below4000Pop+data.train$below5000Pop+data.train$below6000Pop+data.train$below7000Pop+data.train$below8000Pop+data.train$below9000Pop+data.train$below10000Pop +data.train$below11000Pop +data.train$below12000Pop +data.train$above12000Pop+data.train$closestMall_mean

smoothingspline.train1.2 <- smooth.spline(data.train$lat+data.train$long+data.train$floor_area_sqm+data.train$remaining_lease+data.train$avg_storey+data.train$no_of_rooms+data.train$timeToMall+data.train$mallsIn10km+data.train$timeToBeach +data.train$beachesIn10km +data.train$timeToMRTStation+data.train$MRTStationsIn10km+data.train$timeToPrimarySch+data.train$PrimarySchsIn10km+data.train$below1000Pop+data.train$below1500Pop+data.train$below2000Pop+data.train$below2500Pop+data.train$below3000Pop+data.train$below4000Pop+data.train$below5000Pop+data.train$below6000Pop+data.train$below7000Pop+data.train$below8000Pop+data.train$below9000Pop+data.train$below10000Pop +data.train$below11000Pop +data.train$below12000Pop +data.train$above12000Pop+data.train$closestMall_mean
, y=data.train$resale_price, cv=TRUE) 
smoothingspline.train1.2$df
smooth.spine.model1.2<- smooth.spline(data.train$lat+data.train$long+data.train$floor_area_sqm+data.train$remaining_lease+data.train$avg_storey+data.train$no_of_rooms+data.train$timeToMall+data.train$mallsIn10km+data.train$timeToBeach +data.train$beachesIn10km +data.train$timeToMRTStation+data.train$MRTStationsIn10km+data.train$timeToPrimarySch+data.train$PrimarySchsIn10km+data.train$below1000Pop+data.train$below1500Pop+data.train$below2000Pop+data.train$below2500Pop+data.train$below3000Pop+data.train$below4000Pop+data.train$below5000Pop+data.train$below6000Pop+data.train$below7000Pop+data.train$below8000Pop+data.train$below9000Pop+data.train$below10000Pop +data.train$below11000Pop +data.train$below12000Pop +data.train$above12000Pop+data.train$closestMall_mean
, df=smoothingspline.train1.2$df)
smooth.spine.predict1.2 <- predict(smooth.spine.model1.2, data.test$floor_area_sqm)

mse.smooth.spline1.2<- mean((smooth.spine.predict1.2$y-data.test$resale_price)^2)
rmse.smooth.spline1.2 <- mse.smooth.spline1.2^0.5
rmse.smooth.spline1.2 #183994.8

#------------------------------------------------------------------------
#smoothing spline with continuous variables according to the Best Subset Selection

smoothingspline.train1.3 <- smooth.spline(data.train$floor_area_sqm+data.train$remaining_lease+data.train$avg_storey+data.train$mallsIn10km+data.train$below1000Pop+data.train$below4000Pop+data.train$flat_model_mean+data.train$closestPrimarySch_mean
                                          , y=data.train$resale_price, cv=TRUE) 
smoothingspline.train1.3$df
smooth.spine.model1.3<- smooth.spline(data.train$floor_area_sqm+data.train$remaining_lease+data.train$avg_storey+data.train$mallsIn10km+data.train$below1000Pop+data.train$below4000Pop+data.train$flat_model_mean+data.train$closestPrimarySch_mean
                                      , df=smoothingspline.train1.3$df)
smooth.spine.predict1.3 <- predict(smooth.spine.model1.3, data.test$floor_area_sqm)

mse.smooth.spline1.3<- mean((smooth.spine.predict1.3$y-data.test$resale_price)^2)
rmse.smooth.spline1.3 <- mse.smooth.spline1.3^0.5
rmse.smooth.spline1.3 #596500.8

#------------------------------------------------------------------------
#lasso

lasso.mod <- cv.glmnet(train.x, train.y, alpha=1)
lambda.lasso <- lasso.mod$lambda.min
lambda.lasso
summary(lasso.mod)
coefficients <- coef(lasso.mod, s = "lambda.min")
lasso.pred <- predict(lasso.mod, newx=test.x, s=lambda.lasso) # Lasso test MSE
mse.lasso <- mean((test.y-lasso.pred)^2) 
mse.lasso
rmse.lasso <- mse.lasso^0.5
#3274298213
rmse.lasso # 57221.48

#------------------------------------------------------------------------
#ridge
ridge.mod <- glmnet(train.x, train.y, alpha=0) #ridge regression uses alpha=0, lasso uses alpha=1
cv.out <- cv.glmnet(train.x, train.y, alpha=0) 
lambda.rr <- cv.out$lambda.min #lambda.min is the lambda that minimises the cv error

lambda.rr #11983.24
#Once we have gotten lambda that minimises CV Error, we use test.x to predict Y values using ridge regression model
ridge.pred <- predict(ridge.mod, newx=test.x, s=lambda.rr) 
mse.ridge<- mean((test.y-ridge.pred)^2)
rmse.ridge<- mse.ridge^0.5
rmse.ridge #59440.03





#------------------------------------------------------------------------
#local regression model

#4 predictors model
library(leaps)
bss.lr.4 <- regsubsets(resale_price~., data=data.train, really.big=TRUE, nvmax=4)
best_subset1 <- which.min(summary(bss.lr.4)$bic)
coef_best_subset.lr.4 <- coef(bss.lr.4,id=best_subset1)
print(coef_best_subset.lr.4)
lr.4var <- loess(resale_price~floor_area_sqm+remaining_lease+avg_storey+mallsIn10km, span=0.2, data=data.train)
lr.4var.pred <- predict(lr.4var, data.test)
which(is.na(lr.4var.pred)) #3326th obs is NA
mse.lr.4var<- mean((lr.4var.pred[-c(182, 979,1624) ]-data.test$resale_price[-c(182, 979,1624)])^2)
rmse.lr.4var <- mse.lr.4var^0.5
rmse.lr.4var #71474.69



#3 predictors model                
bss.lr.3 <- regsubsets(resale_price~., data=data.train, really.big=TRUE, nvmax=3)
best_subsetlr.3 <- which.min(summary(bss.lr.3)$bic)
coef_best_subset.lr.3 <- coef(bss.lr.3,id=best_subsetlr.3)
print(coef_best_subset.lr.3)                
lr.3var <- loess(resale_price~floor_area_sqm+remaining_lease+mallsIn10km, span=0.2, data=data.train)
lr.3var.pred <- predict(lr.3var, data.test)
mse.lr.3var<- mean((lr.3var.pred[-c(182, 979,1624) ]-data.test$resale_price[-c(182, 979,1624) ])^2)
rmse.lr.3var <- mse.lr.3var^0.5
rmse.lr.3var #78658.81

#2 predictors model
bss.lr.2 <- regsubsets(resale_price~., data=data.train, really.big=TRUE, nvmax=2)
best_subsetlr.2 <- which.min(summary(bss.lr.2)$bic)
coef_best_subset.lr.2 <- coef(bss.lr.2,id=best_subsetlr.2)
print(coef_best_subset.lr.2)              
lr.2var <- loess(resale_price~floor_area_sqm+closestMall_mean, span=0.2, data=data.train)
lr.2var.pred <- predict(lr.2var, data.test)
mse.lr.2var<- mean((lr.2var.pred[-c(182, 979,1624)]-data.test$resale_price[-c(182, 979,1624)])^2)
rmse.lr.2var <- mse.lr.2var^0.5
rmse.lr.2var #106268.5






