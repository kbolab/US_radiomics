source("./moddicom_functions//01_statisticalFeatures.R")
source("./moddicom_functions/03_GLCMtexturalFeatures.R")
source("./moddicom_functions/04_GLRLMtexturalFeatures.R")
source("./moddicom_functions/05_GLSZMtexturalFeatures.R")
source("./moddicom_functions/services.R")
source("./moddicom_functions/features.R")

library(entropy)
library(e1071)
library(misc3d)
library(plyr)
library(reshape2)
library(radiomics)
library(data.table)

patientsPath <- c()
features_df <- as.data.frame(matrix(data = NA, nrow = length(names(final.image)), ncol = 75))
i = 1
for(pat in names(final.image)){
  cat(pat)
  cat("\n")
  rigaFeatures <- extract_features(voxelCube = round(final.image[[pat]]*255), n_grey = 100)
  features_df[i,1] <- pat
  features_df[i,2:75] <- unlist(rigaFeatures)
  i <- i + 1
}

names(features_df) <- c("patID",names(rigaFeatures))

################################################################################################