library("dplyr")
library("caret")
library("ggplot2")
library("openxlsx")

setwd("/home/ron/Documentos/prueba_cientifico_datos/data/")

df <- read.xlsx("precio_vivienda.xlsx")

df <- as.data.frame(unclass(df),stringsAsFactors = TRUE)

entrenamiento <- createDataPartition(df$valor_total_avaluo, p=0.7, list = FALSE)
trainModel <- df[entrenamiento,]
trainTest <- df[-entrenamiento,]

modelo2 <- train(valor_total_avaluo ~ ., data = trainModel, method = "lm", trControl = trainControl(method = "boot", 7), ntree = 14)
modelo1 <- train(valor_total_avaluo ~ ., data = trainModel, method = "rf", trControl = trainControl(method = "cv", 7), ntree = 14)

trainTest$prediccion2 <- predict(modelo2, trainTest)
trainTest$prediccion1 <- predict(modelo1, trainTest)

hist(trainTest$prediccion2, main = "Regresion lineal", xlab = "Valor avaluo")
hist(trainTest$prediccion1, main = "Random Forest", xlab = "Valor avaluo")

summary(trainTest$prediccion2)
summary(trainTest$prediccion1)
summary(trainTest$valor_total_avaluo)

modelo2
