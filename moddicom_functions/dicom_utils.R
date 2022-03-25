##################################################
###########UTILITY FUNCTIONS######################
##################################################

library(stringr)
library(XML)

getXMLStructureFromDICOMFile<-function(fileName) {
  # aggiungi estensione xml
  fileNameXML<-paste(fileName,".xml")
  fileNameXML<-str_replace_all(string = fileNameXML , pattern = " .xml",replacement = ".xml")
  # salva solo path senza nome oggetto DICOM
  #pathToStore<-substr(fileName,1,tail(which(strsplit(fileName, '')[[1]]=='/'),1)-1)
  # se file con estensione xml gia' esiste nella cartella non fare nulla altrimenti lo aggiunge
  if(!file.exists( fileNameXML )) {
    stringa1<-"dcm2xml";
    stringa2<-paste(" +M  ",fileName,fileNameXML,collapse='')
    options(warn=-1)
    system2(stringa1,stringa2,stdout=NULL)
    options(warn=0)
  }
  # Load the XML file: restituisce il file xml nella variabile doc
  doc = xmlInternalTreeParse(fileNameXML)
  return(doc);
}


library(oro.dicom)
library(XML)
library(sp)

eco.pipeline <- function(imagefile, rtstrucfile){
  
  image_path <- sub("/[^/]+$", "", imagefile)
  
  
  #image <- readDICOM(imagefile, recursive=FALSE, exclude="sql")
  image <- readPNG(imagefile, native = FALSE, info = FALSE)
  
  doc<-getXMLStructureFromDICOMFile(fileName = rtstrucfile)
  #ROIPointList<-xpathApply(doc,'/file-format/data-set/sequence[@tag="3006,0039"]/item/sequence/item/element[@tag="3006,0050"]',xmlValue)
  ROIPointList<-xpathApply(doc,'/file-format/data-set/sequence[@tag="3006,0039"]/item/sequence[@tag="3006,0040"]/item/element[@tag="3006,0050"]',xmlValue)
  if(is.null(ROIPointList)){
    cat("warning: roi file has no contour")
    cat("\n")
    final.image <- NULL
  } else {
    
    splittedROIPointList<-strsplit(ROIPointList[[1]],split = "\\\\")
    splittedROIPointList_num <- as.numeric(splittedROIPointList[[1]])
    
    index_x <- seq(1,length(splittedROIPointList_num),by=3)
    index_y <- seq(2,length(splittedROIPointList_num),by=3)
    index_z <- seq(3,length(splittedROIPointList_num),by=3)
    
    # Separa in vettori diversi le coordinate dei punti x, y, z
    fPoint.x<-splittedROIPointList_num[index_x]
    fPoint.y<-splittedROIPointList_num[index_y]
    fPoint.z<-splittedROIPointList_num[index_z]
    cont <- cbind(round(fPoint.y),round(fPoint.x))
    
    #numberOfRows <- dim(image$img[[1]])[2]
    #numberOfColumns <- dim(image$img[[1]])[1]
    
    numberOfRows <- dim(image)[2]
    numberOfColumns <- dim(image)[1]
    
    image_grid <- expand.grid(1:numberOfRows,1:numberOfColumns)
    pip <- point.in.polygon(image_grid[,1],image_grid[,2],round(fPoint.x), round(fPoint.y))
    new_image <- image_grid[which(pip==1),]
    
    image.arr<-array( data = 1, dim = c(numberOfColumns, numberOfRows) )
    immagineMascherata<- array(NA, dim=c(  dim(image.arr)[2],dim(image.arr)[1]  ))
    immagineMascherata[which(pip==1,arr.ind = TRUE)]<-image.arr[ which(pip==1,arr.ind = TRUE) ]
    
    png(filename=paste0(image_path,"/roi.png"))
    image(t(image[numberOfColumns:1,]),col = grey.colors(256,start=0))
    image(immagineMascherata[,numberOfColumns:1], add=T, col = rgb(red = 1, green = 0, blue = 0, alpha = .5))
    dev.off()
    
    final.image <- immagineMascherata[,numberOfColumns:1] * t(image[numberOfColumns:1,])
    #image(final.image)
    #hist(final.image, breaks = 100)
  }
  return(final.image)
  
}