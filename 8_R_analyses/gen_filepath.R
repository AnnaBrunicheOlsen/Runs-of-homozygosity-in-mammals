if(!file.exists('filepath.R')){
  require(tcltk)
  cat('Set data directory\n')
  data.dir <- tk_choose.dir(caption="Select data directory")
  cat('Set output directory\n')
  out.dir <- tk_choose.dir(caption="Select output directory")
  out.string <- paste("data.dir <- \"",data.dir,"/\"\nout.dir <- \"",out.dir,"/\"",sep="")
  cat(out.string,file="filepath.R",sep="\n")
  rm(out.string)
}

source('filepath.R')

datapath <- function(x){paste(data.dir,x,sep="")}

outpath <- function(x){paste(out.dir,x,sep="")}
