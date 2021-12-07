setwd("~/OneDrive - New York State Office of Information Technology Services/Rscripts/PDF.scrape")

#list all files in directory with "summary" in the name
list <- list.files("~/New York State Office of Information Technology Services/BWAM - lci", pattern = "*Summary*\\.pdf")

for(j in 1:length(list)){ #run on each summary file
  
  library(pdftools)
  
  pdf.file <- paste("~/New York State Office of Information Technology Services/BWAM - lci",list[j],sep="/") #creat full filename
  pdf.text <- pdf_text(pdf.file) #convert to text
  
  pdf.text.str<-unlist(pdf.text) #unlist text
  pdf.text.str<-tolower(pdf.text) #to lower case for search
  
  library(stringr)
  
  res <- data.frame(str_detect(pdf.text.str,"sample cross-reference")) #find page with sample name table
  page <- as.numeric(row.names(subset(res,res[,1]==TRUE))) #save page number
  
  pdf.text.page <- strsplit(pdf.text[[page]], "\n") #split string by new lines
  pdf.text.page <- head(pdf.text.page)
  
  df <- data.frame(matrix(unlist(pdf.text.page))) #create dataframe with each line of text as a row
  
  for(i in 1:nrow(df)){ #find row where table starts
    check <- str_detect(df[i,],"CLIENT SAMPLE ID")
    if(check=="TRUE"){
      header.row <- i
    }else{}
  }
  
  for(i in 1:nrow(df)){ #find last row of table
    check <- str_detect(df[i,],"21L")
    if(check=="TRUE"){
      end.row <- i
    }else{}
  }
  
  df <- data.frame(df[(header.row+1):end.row,]) #subset dataframe to rows with the table
  
  df.split <- data.frame(sample=as.character(), #create empty dataframe
                         client.id=as.character(),
                         date=as.character(),
                         time=as.character())
  
  for(i in 1:nrow(df)){ #extract each element of each row and put into new dataframe
    loop.split <- data.frame(matrix(unlist(strsplit(df[i,], "\\s{2,}"))))
    df.split[i,1] <- loop.split[2,]
    df.split[i,2] <- loop.split[3,]
    df.split[i,3] <- loop.split[4,]
    df.split[i,4] <- loop.split[5,]
  }
  
  #write table to csv
  write.csv(df.split,file=paste("~/OneDrive - New York State Office of Information Technology Services/Rscripts/PDF.scrape/Tables/",df.split[1,1],".csv",sep=""))
  
}
