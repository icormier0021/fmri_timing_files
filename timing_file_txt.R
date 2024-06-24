##timing_file_txt.R

#Author: Isaac Cormier
#Date: 2024-06-07
#Last Update- 2024-06-24: Modified existing script to add neccessary rows and export as txt files

#Install neccessary packages if not already installed and load the packages------------------------------------------------
if (!require(readr)) {
        install.packages("readr")
}
if (!require(dplyr)) {
        install.packages("dplyr")
}
if (!require(stringr)) {
        install.packages("stringr")
}
library(readr)
library(dplyr)
library(stringr)

##The createTiming() function takes three argumentstakes three arguments: 1) the directory where your raw data is stored 
##within your working directory, 2) the condition you are making a contrast sheet for ("Picture", "Word", or "Face"), and 
##3) the ID number of the participant (e.g., 3 for 003, 5 for 005, etc.). The function will read the csv file identified 
##by the directory and the participant ID, create a dataframe with the modified edata, and export it into txt files.

createTiming <- function(directory, condition = c("Picture", "Word", "Face"), id = 1:30){
#Check that condition is valid---------------------------------------------------------------------------------------------
        condition_list <- c("Picture", "Word", "Face")
        condition <- sapply(condition, str_to_sentence)
        if(sum(sapply(condition, grepl, condition_list, ignore.case = FALSE)) < 1) stop("invalid condition")

#Load participant data and remove rows with blank TRs----------------------------------------------------------------------
        for (i in id) {
                zero_id <- sprintf("%03d",i)
                csv <- paste(getwd(), "/", directory, "/fMRI_MEG_", zero_id, "_memoryTest_responses_withCodes.csv", sep = "")
                df <- read.csv(csv, header = TRUE, check.names = TRUE, stringsAsFactors = FALSE, blank.lines.skip = TRUE)
                df <- df %>% select(stim_type = `Stim.Type`,
                               stim = Stim,
                               postscan_trial = `PostScan.Trial`,
                               response = Response,
                               correct_answer = `Correct.Answer`,
                               code = Code,
                               TR,
                               approx_time_sec = `Approx.time..s.`) %>% 
                        filter(!is.na(TR)) %>%
                        arrange(TR)
                if (nrow(df) != 210) stop(paste("There are ", nrow(df), "number of rows, when there should be 210"))
                
#Add rows corresponding to TRs not included for the stimuli-------------------------------------------------------------------
                rows_with_TRs <- list()
                for (row in 1:nrow(df)) {
                        rows_with_TRs <- append(rows_with_TRs, list(df[row, ]))
                        new_row <- df[row, ]
                        new_row$TR <- new_row$TR + 1
                        new_row$approx_time_sec <- new_row$approx_time_sec + 2
                        new_row[2:4] <- NA
                        rows_with_TRs <- append(rows_with_TRs, list(new_row))
                }
                df_TRs <- bind_rows(rows_with_TRs)
        
# Add rows corresponding to the fixation crosshairs at the start and between blocks-------------------------------------------
        rows_with_crosshair <- list()
        count <- 0
        for (row in nrow(df_TRs):1) {
                rows_with_crosshair <- append(rows_with_crosshair, list(df_TRs[row, ]))
                
                count <- count + 1
                if (count %% 60 == 0) {
                        for (x in 1:10) {
                                new_row <- data.frame(
                                        stim_type = "Crosshair",
                                        stim = NA,
                                        postscan_trial = NA,
                                        response = NA,
                                        correct_answer = NA,
                                        code = 0,
                                        TR = NA,
                                        approx_time_sec = NA
                                )
                                rows_with_crosshair <- append(rows_with_crosshair, list(new_row))
                        }
                }
        }
        rows_with_crosshair <- rev(rows_with_crosshair)
        df_TRs_crosshair <- bind_rows(rows_with_crosshair[6:length(rows_with_crosshair)])
        
        for (p in condition) {
# Correctly remembered txt file (1=correctly remembered; 0=anything else)--------------------------------------------------------
                df_temp1 <- df_TRs_crosshair
                df_temp1 <- df_temp1 %>%
                        mutate(code = if_else(stim_type != p | code != 1, 0, code)) %>%
                        select(code, TR, approx_time_sec)
                output_txt1 <- file.path(getwd(), directory, paste0("sub-", zero_id, "_", p, "_correctly_remembered_2.txt"))
                write_tsv(df_temp1, output_txt1, col_names = FALSE)
                
# Incorrectly remembered txt file (1=incorrectly remembered; 0=anything else)-----------------------------------------------------
                df_temp2 <- df_TRs_crosshair
                df_temp2 <- df_temp2 %>%
                        mutate(code = if_else(stim_type != p | code != 4, 0, if_else(code == 4, 1, code))) %>%
                        select(code, TR, approx_time_sec)
                output_txt2 <- file.path(getwd(), directory, paste0("sub-", zero_id, "_", p, "_incorrectly_remembered_2.txt"))
                write_tsv(df_temp2, output_txt2, col_names = FALSE)
        }
        print(paste("Text files have been saved for", zero_id, "under", directory))
}
}