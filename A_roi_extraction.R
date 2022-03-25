#######################################################################################################
##############MAIN CODE TO EXTRACT ROIs PER PATIENT ###################################################
#######################################################################################################
source("./moddicom_functions/dicom_utils.R")
library(png)

root_path <- "./test_img"
final.image <- list()

for(patient_path in list.dirs(root_path)[-1]){
  
  if(dir.exists(patient_path)){
    
    if(length(file.path(patient_path,list.files(patient_path)[grep(list.files(patient_path),pattern = ".xml")]))>0){
      file.remove(file.path(patient_path,list.files(patient_path)[grep(list.files(patient_path),pattern = ".xml")]))
    }
    if(file.exists(paste0(patient_path,"/roi.png"))){
      file.remove(paste0(patient_path,"/roi.png"))
    }
    if(length(file.path(patient_path,list.files(patient_path)[grep(list.files(patient_path),pattern = ".dcm",invert = T)]))>0){
      file.remove(file.path(patient_path,list.files(patient_path)[grep(list.files(patient_path),pattern = ".dcm",invert = T)]))
    }
  
  pat <- basename(patient_path)
  image_path <- list.files(patient_path)[grep(list.files(patient_path),pattern = "_m",invert = T)]
  rtstruct_path <- list.files(patient_path)[grep(list.files(patient_path),pattern = "_m")][1]
  cmd <- paste("dcmj2pnm +G +on2", 
               file.path(patient_path, image_path),
               file.path(patient_path, paste0(gsub('.{4}$', '', image_path))))
  system(cmd)
  final.image[[pat]] <- eco.pipeline(imagefile = gsub('.{4}$', '', paste(patient_path,image_path,sep = "/")), paste(patient_path,rtstruct_path,sep = "/"))
  }
}