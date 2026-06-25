

# ML Masrshrom:

getwd()
setwd("../../mushroom/")
getwd()
data <- read.csv2("agaricus-lepiota.data",header = FALSE,sep = ",",fill = TRUE, stringsAsFactors = TRUE)


# head(data)



colnames(data) <- c("class","cap_shape","cap_surface","cap_color","bruises","odor","gill_attachment","gill_spacing","gill_size","gill_color","stalk_shape",
  "stalk_root","stalk_surface_above_ring","stalk_surface_below_ring","stalk_color_above_ring","stalk_color_below_ring","veil_type","veil_color",
  "ring_number","ring_type","spore_print_color","population","habitat")
  
  
  
 
data$class <- factor(data$class,
                     levels = c("e","p"),
                     labels = c("edible","poisonous"))




data$cap_shape <- factor(data$cap_shape,
                         levels = c("b","c","x","f","k","s"),
                         labels = c("bell","conical","convex","flat","knobbed","sunken"))

data$cap_surface <- factor(data$cap_surface,
                           levels = c("f","g","y","s"),
                           labels = c("fibrous","grooves","scaly","smooth"))

data$cap_color <- factor(data$cap_color,
                         levels = c("n","b","c","g","r","p","u","e","w","y"),
                         labels = c("brown","buff","cinnamon","gray","green","pink","purple","red","white","yellow"))

data$bruises <- factor(data$bruises,
                       levels = c("t","f"),
                       labels = c("bruises","no"))

data$odor <- factor(data$odor,
                    levels = c("a","l","c","y","f","m","n","p","s"),
                    labels = c("almond","anise","creosote","fishy","foul","musty","none","pungent","spicy"))

data$gill_attachment <- factor(data$gill_attachment,
                               levels = c("a","d","f","n"),
                               labels = c("attached","descending","free","notched"))

data$gill_spacing <- factor(data$gill_spacing,
                            levels = c("c","w","d"),
                            labels = c("close","crowded","distant"))

data$gill_size <- factor(data$gill_size,
                         levels = c("b","n"),
                         labels = c("broad","narrow"))

data$gill_color <- factor(data$gill_color,
                          levels = c("k","n","b","h","g","r","o","p","u","e","w","y"),
                          labels = c("black","brown","buff","chocolate","gray","green","orange","pink","purple","red","white","yellow"))

data$stalk_shape <- factor(data$stalk_shape,
                           levels = c("e","t"),
                           labels = c("enlarging","tapering"))

data$stalk_root <- factor(data$stalk_root,
                          levels = c("b","c","u","e","z","r","?"),
                          labels = c("bulbous","club","cup","equal","rhizomorphs","rooted","missing"))

data$stalk_surface_above_ring <- factor(data$stalk_surface_above_ring,
                                        levels = c("f","y","k","s"),
                                        labels = c("fibrous","scaly","silky","smooth"))

data$stalk_surface_below_ring <- factor(data$stalk_surface_below_ring,
                                        levels = c("f","y","k","s"),
                                        labels = c("fibrous","scaly","silky","smooth"))

data$stalk_color_above_ring <- factor(data$stalk_color_above_ring,
                                      levels = c("n","b","c","g","o","p","e","w","y"),
                                      labels = c("brown","buff","cinnamon","gray","orange","pink","red","white","yellow"))

data$stalk_color_below_ring <- factor(data$stalk_color_below_ring,
                                      levels = c("n","b","c","g","o","p","e","w","y"),
                                      labels = c("brown","buff","cinnamon","gray","orange","pink","red","white","yellow"))

data$veil_type <- factor(data$veil_type,
                         levels = c("p","u"),
                         labels = c("partial","universal"))

data$veil_color <- factor(data$veil_color,
                          levels = c("n","o","w","y"),
                          labels = c("brown","orange","white","yellow"))

data$ring_number <- factor(data$ring_number,
                           levels = c("n","o","t"),
                           labels = c("none","one","two"))

data$ring_type <- factor(data$ring_type,
                         levels = c("c","e","f","l","n","p","s","z"),
                         labels = c("cobwebby","evanescent","flaring","large","none","pendant","sheathing","zone"))

data$spore_print_color <- factor(data$spore_print_color,
                                 levels = c("k","n","b","h","r","o","u","w","y"),
                                 labels = c("black","brown","buff","chocolate","green","orange","purple","white","yellow"))

data$population <- factor(data$population,
                          levels = c("a","c","n","s","v","y"),
                          labels = c("abundant","clustered","numerous","scattered","several","solitary"))

data$habitat <- factor(data$habitat,
                       levels = c("g","l","m","p","u","w","d"),
                       labels = c("grasses","leaves","meadows","paths","urban","waste","woods"))
					   
					   
					   
summary(data)



# set all nominal columns as factor
data[] <- lapply(data, as.factor)

# check missing values marked as "?"
colSums(data == "?")

# replace "?" in stalk_root with NA
data$stalk_root[data$stalk_root == "?"] <- NA

# replace missing values in stalk_root with mode
mode_stalk_root <- names(which.max(table(data$stalk_root)))

data$stalk_root[is.na(data$stalk_root)] <- mode_stalk_root

# check missing values again
colSums(is.na(data))

# summary
summary(data)

########################################
# Visualization
########################################

# Distribution of target class
barplot(table(data$class),
        main = "Mushroom Class",
        col = c("lightgreen", "tomato"),
        ylab = "Count")

# Cap Shape
barplot(table(data$cap_shape),
        main = "Cap Shape",
        col = "skyblue",
        las = 2)

# Odor
barplot(table(data$odor),
        main = "Odor",
        col = "orange",
        las = 2)

# Habitat
barplot(table(data$habitat),
        main = "Habitat",
        col = "lightblue",
        las = 2)

# Population
barplot(table(data$population),
        main = "Population",
        col = "gold",
        las = 2)
		
		
		
########################################
# visualize factorial data
########################################

tab <- table(data$odor, data$class)
prop <- prop.table(tab, margin = 1)

barplot(t(prop),
        beside = TRUE,
        legend.text = TRUE,
        args.legend = list(x = "topright"),
        main = "Class by Odor",
        xlab = "Odor",
        ylab = "",
        ylim = c(0,1),
        col = c("darkgreen","red"))

tab <- table(data$gill_size, data$class)
prop <- prop.table(tab, margin = 1)

barplot(t(prop),
        beside = TRUE,
        legend.text = TRUE,
        args.legend = list(x = "topright"),
        main = "Class by Gill Size",
        xlab = "Gill Size",
        ylab = "",
        ylim = c(0,1),
        col = c("darkgreen","red"))

tab <- table(data$spore_print_color, data$class)
prop <- prop.table(tab, margin = 1)

barplot(t(prop),
        beside = TRUE,
        legend.text = TRUE,
        args.legend = list(x = "topright"),
        main = "Class by Spore Print Color",
        xlab = "Spore Print Color",
        ylab = "",
        ylim = c(0,1),
        col = c("darkgreen","red"))

tab <- table(data$habitat, data$class)
prop <- prop.table(tab, margin = 1)

barplot(t(prop),
        beside = TRUE,
        legend.text = TRUE,
        args.legend = list(x = "topright"),
        main = "Class by Habitat",
        xlab = "Habitat",
        ylab = "",
        ylim = c(0,1),
        col = c("darkgreen","red"))

tab <- table(data$population, data$class)
prop <- prop.table(tab, margin = 1)

barplot(t(prop),
        beside = TRUE,
        legend.text = TRUE,
        args.legend = list(x = "topright"),
        main = "Class by Population",
        xlab = "Population",
        ylab = "",
        ylim = c(0,1),
        col = c("darkgreen","red"))

summary(data)




########################################
# Split in training and test data
########################################

install.packages("caret")
library(caret)
set.seed(467)

trainIndex <- createDataPartition(data$class, p = 0.7, list = FALSE)

trainData <- data[trainIndex, ]
testData  <- data[-trainIndex, ]

table(trainData$class)
table(testData$class)


											> table(trainData$class)

											   edible poisonous 
												 2946      2742 
											> table(testData$class)

											   edible poisonous 
												 1262      1174 
											> 



########################################
# Define cross-validation control
########################################

control <- trainControl(method = "cv",  number = 10, savePredictions = "all", classProbs = TRUE)
dim(trainData)
dim(testData)



							> dim(trainData)
							[1] 5688   23
							> dim(testData)
							[1] 2436   23
							> 

prop.table(table(trainData$class))

							   edible poisonous 
							0.5179325 0.4820675 
 
prop.table(table(testData$class))

							   edible poisonous 
							0.5180624 0.4819376 

########################################
# Logistic Regression
########################################

log_reg_model <- train(
  class ~ .,
  data = trainData,
  method = "glm",
  family = "binomial",
  trControl = control
)

summary(log_reg_model)


							Call:
							NULL

							Coefficients: (19 not defined because of singularities)
															 Estimate Std. Error z value Pr(>|z|)
							(Intercept)                    -5.313e+01  2.537e+05       0        1
							cap_shapeconical               -2.101e-06  2.954e+05       0        1
							cap_shapeconvex                -1.405e-09  2.666e+04       0        1
							cap_shapeflat                  -1.767e-09  2.786e+04       0        1
							cap_shapeknobbed                1.037e-09  3.021e+04       0        1
							cap_shapesunken                -1.767e-09  9.828e+04       0        1
							cap_surfacegrooves              3.848e-06  3.072e+05       0        1
							cap_surfacescaly               -3.586e-10  1.348e+04       0        1
							cap_surfacesmooth               2.613e-10  1.597e+04       0        1
							cap_colorbuff                  -3.926e-08  4.260e+04       0        1
							cap_colorcinnamon              -9.817e-10  8.477e+04       0        1
							cap_colorgray                   1.065e-09  1.720e+04       0        1
							cap_colorgreen                  2.010e-09  1.585e+05       0        1
							cap_colorpink                  -3.831e-09  4.381e+04       0        1
							cap_colorpurple                 1.894e-09  1.708e+05       0        1
							cap_colorred                   -8.053e-10  1.512e+04       0        1
							cap_colorwhite                  2.200e-09  2.177e+04       0        1
							cap_coloryellow                 8.432e-10  2.366e+04       0        1
							bruisesno                      -2.657e+01  1.360e+05       0        1
							odoranise                      -1.437e-10  3.021e+04       0        1
							odorcreosote                    5.313e+01  1.095e+05       0        1
							odorfishy                      -1.368e-05  2.986e+05       0        1
							odorfoul                       -1.367e-05  2.976e+05       0        1
							odormusty                       7.970e+01  4.810e+05       0        1
							odornone                       -5.313e+01  2.870e+05       0        1
							odorpungent                    -2.657e+01  3.807e+05       0        1
							odorspicy                      -1.366e-05  2.987e+05       0        1
							gill_attachmentdescending              NA         NA      NA       NA
							gill_attachmentfree             1.737e-07  1.582e+05       0        1
							gill_attachmentnotched                 NA         NA      NA       NA
							gill_spacingcrowded            -4.515e-06  5.963e+04       0        1
							gill_spacingdistant                    NA         NA      NA       NA
							gill_sizenarrow                -5.313e+01  2.561e+05       0        1
							gill_colorbrown                 3.388e-10  2.693e+04       0        1
							gill_colorbuff                  4.874e-07  2.109e+05       0        1
							gill_colorchocolate            -8.705e-10  2.968e+04       0        1
							gill_colorgray                 -1.737e-11  2.994e+04       0        1
							gill_colorgreen                -3.522e-07  1.096e+05       0        1
							gill_colororange                4.783e-09  7.893e+04       0        1
							gill_colorpink                  2.040e-10  2.670e+04       0        1
							gill_colorpurple                1.109e-10  3.326e+04       0        1
							gill_colorred                  -1.443e-09  6.721e+04       0        1
							gill_colorwhite                -2.072e-10  2.825e+04       0        1
							gill_coloryellow                8.897e-09  7.295e+04       0        1
							stalk_shapetapering            -2.657e+01  1.482e+05       0        1
							stalk_rootclub                 -7.970e+01  4.035e+05       0        1
							stalk_rootcup                          NA         NA      NA       NA
							stalk_rootequal                 5.313e+01  2.440e+05       0        1
							stalk_rootrhizomorphs                  NA         NA      NA       NA
							stalk_rootrooted               -1.063e+02  3.419e+05       0        1
							stalk_rootmissing               2.657e+01  1.628e+05       0        1
							stalk_surface_above_ringscaly  -2.830e-07  3.454e+05       0        1
							stalk_surface_above_ringsilky  -5.273e-11  3.166e+04       0        1
							stalk_surface_above_ringsmooth -3.050e-10  2.546e+04       0        1
							stalk_surface_below_ringscaly   2.657e+01  2.098e+05       0        1
							stalk_surface_below_ringsilky  -4.645e-10  3.163e+04       0        1
							stalk_surface_below_ringsmooth -1.091e-10  2.541e+04       0        1
							stalk_color_above_ringbuff     -2.200e-10  2.923e+04       0        1
							stalk_color_above_ringcinnamon         NA         NA      NA       NA
							stalk_color_above_ringgray      2.506e-09  3.730e+04       0        1
							stalk_color_above_ringorange   -2.657e+01  2.502e+05       0        1
							stalk_color_above_ringpink      2.491e-09  2.920e+04       0        1
							stalk_color_above_ringred       5.805e-10  7.019e+04       0        1
							stalk_color_above_ringwhite     2.529e-09  3.321e+04       0        1
							stalk_color_above_ringyellow    1.063e+02  4.470e+05       0        1
							stalk_color_below_ringbuff      1.469e-09  2.916e+04       0        1
							stalk_color_below_ringcinnamon         NA         NA      NA       NA
							stalk_color_below_ringgray      2.442e-09  3.732e+04       0        1
							stalk_color_below_ringorange           NA         NA      NA       NA
							stalk_color_below_ringpink      2.528e-09  2.914e+04       0        1
							stalk_color_below_ringred       1.840e-09  6.948e+04       0        1
							stalk_color_below_ringwhite     2.516e-09  3.315e+04       0        1
							stalk_color_below_ringyellow   -1.218e-08  1.601e+05       0        1
							veil_typeuniversal                     NA         NA      NA       NA
							veil_colororange                2.939e-10  6.314e+04       0        1
							veil_colorwhite                        NA         NA      NA       NA
							veil_coloryellow                       NA         NA      NA       NA
							ring_numberone                  1.063e+02  4.747e+05       0        1
							ring_numbertwo                         NA         NA      NA       NA
							ring_typeevanescent            -2.657e+01  1.217e+05       0        1
							ring_typeflaring                2.657e+01  1.966e+05       0        1
							ring_typelarge                         NA         NA      NA       NA
							ring_typenone                          NA         NA      NA       NA
							ring_typependant                       NA         NA      NA       NA
							ring_typesheathing                     NA         NA      NA       NA
							ring_typezone                          NA         NA      NA       NA
							spore_print_colorbrown         -6.559e-11  1.392e+04       0        1
							spore_print_colorbuff          -5.406e-10  8.967e+04       0        1
							spore_print_colorchocolate             NA         NA      NA       NA
							spore_print_colorgreen          1.328e+02  3.842e+05       0        1
							spore_print_colororange        -6.395e-10  8.909e+04       0        1
							spore_print_colorpurple        -1.576e-10  9.204e+04       0        1
							spore_print_colorwhite          7.970e+01  3.662e+05       0        1
							spore_print_coloryellow        -9.310e-10  9.118e+04       0        1
							populationclustered             1.625e-08  7.521e+04       0        1
							populationnumerous             -1.464e-11  4.268e+04       0        1
							populationscattered            -3.375e-11  3.053e+04       0        1
							populationseveral               1.636e-08  4.138e+04       0        1
							populationsolitary              1.471e-08  4.290e+04       0        1
							habitatleaves                  -1.046e-09  3.175e+04       0        1
							habitatmeadows                  1.020e-10  3.525e+04       0        1
							habitatpaths                   -6.099e-10  2.458e+04       0        1
							habitaturban                   -1.027e-07  3.656e+04       0        1
							habitatwaste                           NA         NA      NA       NA
							habitatwoods                    2.262e-10  2.561e+04       0        1

							(Dispersion parameter for binomial family taken to be 1)

								Null deviance: 7.8779e+03  on 5687  degrees of freedom
							Residual deviance: 3.2999e-08  on 5602  degrees of freedom
							AIC: 172

							Number of Fisher Scoring iterations: 25



# prediction and confusion matrix
log_reg_pred <- predict(log_reg_model, newdata = testData)

log_reg_cm <- confusionMatrix(
  log_reg_pred,
  testData$class
)

print(log_reg_cm)



										Confusion Matrix and Statistics

												   Reference
										Prediction  edible poisonous
										  edible      1262         0
										  poisonous      0      1174
																			 
													   Accuracy : 1          
														 95% CI : (0.9985, 1)
											No Information Rate : 0.5181     
											P-Value [Acc > NIR] : < 2.2e-16  
																			 
														  Kappa : 1          
																			 
										 Mcnemar's Test P-Value : NA         
																			 
													Sensitivity : 1.0000     
													Specificity : 1.0000     
												 Pos Pred Value : 1.0000     
												 Neg Pred Value : 1.0000     
													 Prevalence : 0.5181     
												 Detection Rate : 0.5181     
										   Detection Prevalence : 0.5181     
											  Balanced Accuracy : 1.0000     
																			 
											   'Positive' Class : edible     



########################################
# Decision Tree
########################################


install.packages("rpart.plot")
library(rpart)

tree_model <- train(
  class ~ .,
  data = trainData,
  method = "rpart",
  trControl = control
)

# prediction and confusion matrix
tree_pred <- predict(tree_model, newdata = testData)

tree_cm <- confusionMatrix(
  tree_pred,
  testData$class
)

print(tree_cm)


											Confusion Matrix and Statistics

													   Reference
											Prediction  edible poisonous
											  edible      1173        54
											  poisonous     89      1120
																					  
														   Accuracy : 0.9413          
															 95% CI : (0.9312, 0.9503)
												No Information Rate : 0.5181          
												P-Value [Acc > NIR] : < 2.2e-16       
																					  
															  Kappa : 0.8826          
																					  
											 Mcnemar's Test P-Value : 0.004466        
																					  
														Sensitivity : 0.9295          
														Specificity : 0.9540          
													 Pos Pred Value : 0.9560          
													 Neg Pred Value : 0.9264          
														 Prevalence : 0.5181          
													 Detection Rate : 0.4815          
											   Detection Prevalence : 0.5037          
												  Balanced Accuracy : 0.9417          
																					  
												   'Positive' Class : edible 

# visualization of decision tree
par(mfrow = c(1, 1))

library(rpart.plot)

rpart.plot(
  tree_model$finalModel,
  box.palette = "Blues",
  main = "Decision Tree for Mushroom Classification"
)




#######################################
# Random Forest
#######################################

install.packages("randomForest")
library(randomForest)

rf_model <- train(
  class ~ .,
  data = trainData,
  method = "rf",
  trControl = control,
  importance = TRUE
)

# prediction and confusion matrix
rf_pred <- predict(rf_model, newdata = testData)

rf_cm <- confusionMatrix(
  rf_pred,
  testData$class
)

print(rf_cm)



						Confusion Matrix and Statistics

								   Reference
						Prediction  edible poisonous
						  edible      1262         0
						  poisonous      0      1174
															 
									   Accuracy : 1          
										 95% CI : (0.9985, 1)
							No Information Rate : 0.5181     
							P-Value [Acc > NIR] : < 2.2e-16  
															 
										  Kappa : 1          
															 
						 Mcnemar's Test P-Value : NA         
															 
									Sensitivity : 1.0000     
									Specificity : 1.0000     
								 Pos Pred Value : 1.0000     
								 Neg Pred Value : 1.0000     
									 Prevalence : 0.5181     
								 Detection Rate : 0.5181     
						   Detection Prevalence : 0.5181     
							  Balanced Accuracy : 1.0000     
															 
							   'Positive' Class : edible     


# variable importance visualization
varImpPlot(
  rf_model$finalModel,
  sort = TRUE,
  main = "Variable Importance Random Forest"
)



		foto ...51
