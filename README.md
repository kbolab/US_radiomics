# US_radiomics

Directory structure: each image folder contains two dcm file: root_path/pat0/image.dcm (the US image) and root_path/pat0/image_m.dcm (the corresponding RTStruct). The only requsite on the file names is that the RTStruct has to contain the pattern "_m"

A_roi_extraction.R : set "root_path" to the path containing all patient folders (e.g. root_path/pat0, root_path/pat1, ...). Outputs a list with the ROI pixel matrix for each subdirectory of the root_path.

B_feature_extraction.R: takes as input the output of A_roi_extraction.R and creates the radiomics features dataframe.
