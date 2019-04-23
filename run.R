rm(list = ls())

# small fix
library(Cairo)
options(bitmapType = "cairo")

library(nowac)
library(devtools)
load_all("../pippeline")
source("pippeline.R")