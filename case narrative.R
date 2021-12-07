setwd("~/OneDrive - New York State Office of Information Technology Services/Rscripts/PDF.scrape")

#list all files in directory with "summary" in the name
list <- list.files("~/New York State Office of Information Technology Services/BWAM - lci", pattern = "*Summary*")

df.full <- data.frame("Sample.name" = as.character(),
                      "Sample.receipt" = as.character(), 
                      "Metals" = as.character(), 
                      "General.chemistry" = as.character())

for(j in 1:length(list)){ #run on each summary file
  
  library(pdftools)
  
  pdf.file <- paste("~/New York State Office of Information Technology Services/BWAM - lci",list[j],sep="/") #creat full filename
  pdf.text <- pdf_text(pdf.file) #convert to text
  sample.name <- substr(list[j],1,8)
  
  pdf.text.str<-unlist(pdf.text) #unlist text

  library(stringr)
  
  res <- data.frame(str_detect(pdf.text.str,"CASE NARRATIVE")) #find page
  page <- as.numeric(row.names(subset(res,res[,1]==TRUE))) #save page number
  
  pdf.text.page <- strsplit(pdf.text[[page]], "\n") #split string by new lines
  pdf.text.page <- head(pdf.text.page)
  
  df <- data.frame(matrix(unlist(pdf.text.page))) #create dataframe with each line of text as a row
  
  for(i in 1:nrow(df)){ #find paragraph on sample receipt
    check <- str_detect(df[i,],"Sample Receipt\\:")
    if(check=="TRUE"){
      sample.receipt.row <- i
    }else{}
  }
  
  for(i in 1:nrow(df)){ #find paragraph on metals
    check <- str_detect(df[i,],"Metals\\:")
    if(check=="TRUE"){
      metals.row <- i
    }else{}
  }
  
  for(i in 1:nrow(df)){ #find paragraph on gen chem
    check <- str_detect(df[i,],"General Chemistry\\:")
    if(check=="TRUE"){
      gen.chem.row <- i
    }else{}
  }
  
  for(i in 1:nrow(df)){ #find last row of text
    check <- str_detect(df[i,],"\\.")
    if(check=="TRUE"){
      end.row <- i
    }else{}
  }
  
  library(tidyverse)
  
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
