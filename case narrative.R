setwd("~/OneDrive - New York State Office of Information Technology Services/Rscripts/PDF")

###############CASE NARRATIVE##################
# GENERATES 1 DATAFRAME OF ALL THE CASE NARRATIVES FROM THE SUMMARY DOCS
# INCLUDES SAMPLE NAME, SAMPLE RECEIPT, METALS AND GENERAL CHEMISTRY
# WRITES TO CSV 
#
# Required packages: pdftools, stringr
#
# -Sabrina Xie

#list all files in directory with "summary" in the name
list <- list.files("~/New York State Office of Information Technology Services/BWAM - lci", pattern = "*Summary*")

df.full <- data.frame("Sample.name" = as.character(),
                      "Sample.receipt" = as.character(), 
                      "Metals" = as.character(), 
                      "General.chemistry" = as.character())

for(j in 1:length(list)){ #run on each summary file
  
  pdf.file <- paste("~/New York State Office of Information Technology Services/BWAM - lci",list[j],sep="/") #create full filename
  pdf.text <- pdftools::pdf_text(pdf.file) #convert to text
  sample.name <- substr(list[j],1,8)
  
  pdf.text.str<-unlist(pdf.text) #unlist text

  res <- data.frame(stringr::str_detect(pdf.text.str,"CASE NARRATIVE")) #find page
  page <- as.numeric(row.names(subset(res,res[,1]==TRUE))) #save page number
  
  pdf.text.page <- strsplit(pdf.text[[page]], "\n") #split string by new lines

  df <- data.frame(matrix(unlist(pdf.text.page))) #create dataframe with each line of text as a row
  
  sample.receipt.row <- which(str_detect(df[,1],"Sample Receipt\\:")) #find paragraph on sample receipt
  metals.row <- which(str_detect(df[,1],"Metals\\:")) #find paragraph on metals
  gen.chem.row <- which(str_detect(df[,1],"General Chemistry\\:")) #find paragraph on gen chem
  end.row <- max(which(str_detect(df[,1],"\\."))) #find last row
  
  df.receipt <- data.frame(df[(sample.receipt.row+1):(metals.row-1),]) #subset dataframe to sample receipt section
  df.metals <- data.frame(df[(metals.row+1):(gen.chem.row-1),]) #subset dataframe to metals section
  df.gen.chem <- data.frame(df[(gen.chem.row+1):(end.row),]) #subset dataframe to general chemistry section
  
  df <- data.frame("Sample receipt"=toString(df.receipt$df..sample.receipt.row...1...metals.row...1....), #concatenate all the rows into one string
                   "Metals"=toString(df.metals$df..metals.row...1...gen.chem.row...1....),
                   "General chemistry"=toString(df.gen.chem$df..gen.chem.row...1...end.row....))
  names(df) <- c("Sample receipt","Metals","General chemistry")
  
  df.full[j, 1] <- sample.name #add to large df outside of loop
  df.full[j, 2:4] <- df[1, ]
  
}

#write table to csv
names(df.full) <- c("Sample name","Sample receipt","Metals","General chemistry")
write.csv(df.full,file=paste("~/OneDrive - New York State Office of Information Technology Services/Rscripts/PDF.scrape/Case Narrative.csv",sep=""))
