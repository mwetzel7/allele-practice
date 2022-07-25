#!/usr/bin/env Rscript

#load the necessary libraries

library(optparse)
#library(tidyr)
library(tidyverse)

#make parsing command line options/arguments:

arguments <- parse_args(OptionParser(usage = "%prog [options] counts_file groups_file",
                                     description="separate allele file per ethnicity",
                                     option_list=list(
                                       make_option(c("-o","--output_directory"), default = sprintf("%s",getwd()), help = "Where files should go"),
                                       make_option(c("-a","--allele_file"), default=NULL, help="The allele file"),
                                       make_option(c("-e","--ethnicity"), default=NULL, help="The ethnicity for frequencies"))))

args=arguments

out_dir <- args$output_directory
allele_f <- args$allele_file
eth <- args$ethnicity

#load the file:

data_total <- read.table(allele_f, sep="\t") #This works to read the file into R

cnames <- c("Line", "Allele", "Population", "% of individuals that have the allele", "Allele Frequency", "Sample Size", "Location")
colnames(data_total) <- cnames
write.table(data_total,file=sprintf("%s_full.txt", eth),sep="\t", row.names = FALSE, quote = FALSE)

#Now break up into smaller, more specific tables in the correct format:

data_freq <- data_total[ , c("Allele", "Population", "Allele Frequency")]
data_ss <- data_total[ , c("Allele", "Population", "Sample Size")]
data_loc <- data_total[ , c("Allele", "Population", "Location")]
data_percent <- data_total[ , c("Allele", "Population", "% of individuals that have the allele")]

data_frequencies_table <- data_freq %>% 
  group_by(Allele) %>% 
  pivot_wider(names_from = Population, values_from = "Allele Frequency")

data_ss_table <- data_ss %>% 
  group_by(Allele) %>% 
  pivot_wider(names_from = Population, values_from = "Sample Size")

data_loc_table <- data_loc %>% 
  group_by(Allele) %>% 
  pivot_wider(names_from = Population, values_from = "Location")

data_percent_table <- data_percent %>% 
  group_by(Allele) %>% 
  pivot_wider(names_from = Population, values_from = "% of individuals that have the allele")

#Now put these tables into files:

write.table(data_frequencies_table,file=sprintf("%s_frequencies.txt", eth),sep="\t", row.names = FALSE, quote = FALSE)
write.table(data_ss_table,file=sprintf("%s_samples.txt", eth),sep="\t", row.names = FALSE, quote = FALSE)
write.table(data_loc_table,file=sprintf("%s_locations.txt", eth),sep="\t", row.names = FALSE, quote = FALSE)
write.table(data_percent_table,file=sprintf("%s_percents.txt", eth),sep="\t", row.names = FALSE, quote = FALSE)

#To run in command line:

#RScript ~/Desktop/Allele_Frequencies/AF_Parsing_Correct.R  -a /Users/meredithwetzel/Desktop/Allele_Frequencies/Amerindian_Full_Table.txt -e Amerindian
