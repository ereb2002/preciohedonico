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
modelo1 <- train(valor_total_avaluo ~ ., data = trainModel, method = "rpart", trControl = trainControl(method = "cv", 7), ntree = 14)

trainTest$prediccion2 <- predict(modelo2, trainTest)
trainTest$prediccion1 <- predict(modelo1, trainTest)

hist(trainTest$prediccion2, main = "Regresion lineal", xlab = "Valor avaluo")
hist(trainTest$prediccion1, main = "Random Forest", xlab = "Valor avaluo")

summary(trainTest$prediccion2)
summary(trainTest$prediccion1)
summary(trainTest$valor_total_avaluo)

modelo2$finalModel

plot(modelo1$finalModel, uniform=TRUE, main="Classification Tree")

summary(modelo1$finalModel)

library(rattle)
library(RColorBrewer)
fancyRpartPlot(modelo1, caption = NULL)

plot(modelo1$finalModel, rmse, type = 'l', lwd = 2)


library(dplyr)
library(ggraph)
library(igraph)

tree_func <- function(final_model, 
                      tree_num) {
  
  # get tree by index
  tree <- randomForest::getTree(final_model, 
                                k = tree_num, 
                                labelVar = TRUE) %>%
    tibble::rownames_to_column() %>%
    # make leaf split points to NA, so the 0s won't get plotted
    mutate(`split point` = ifelse(is.na(prediction), `split point`, NA))
  
  # prepare data frame for graph
  graph_frame <- data.frame(from = rep(tree$rowname, 2),
                            to = c(tree$`left daughter`, tree$`right daughter`))
  
  # convert to graph and delete the last node that we don't want to plot
  graph <- graph_from_data_frame(graph_frame) %>%
    delete_vertices("0")
  
  # set node labels
  V(graph)$node_label <- gsub("_", " ", as.character(tree$`split var`))
  V(graph)$leaf_label <- as.character(tree$prediction)
  V(graph)$split <- as.character(round(tree$`split point`, digits = 2))
  
  # plot
  plot <- ggraph(graph, 'dendrogram') + 
    theme_bw() +
    geom_edge_link() +
    geom_node_point() +
    geom_node_text(aes(label = node_label), na.rm = TRUE, repel = TRUE) +
    geom_node_label(aes(label = split), vjust = 2.5, na.rm = TRUE, fill = "white") +
    geom_node_label(aes(label = leaf_label, fill = leaf_label), na.rm = TRUE, 
                    repel = TRUE, colour = "white", fontface = "bold", show.legend = FALSE) +
    theme(panel.grid.minor = element_blank(),
          panel.grid.major = element_blank(),
          panel.background = element_blank(),
          plot.background = element_rect(fill = "white"),
          panel.border = element_blank(),
          axis.line = element_blank(),
          axis.text.x = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks = element_blank(),
          axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          plot.title = element_text(size = 18))
  
  print(plot)
}

tree_num <- which(modelo1$finalModel$forest$ndbigtree == min(modelo1$finalModel$forest$ndbigtree))
tree_func(final_model = modelo1$finalModel, tree_num)

plot(modelo1)
ggplot(modelo1)

plot(modelo1$finalModel)

varImp(modelo1)

varImp(modelo2)

