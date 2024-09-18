library("tictoc")

# tic()

library("readr")
library("tidyr")
library("dplyr")
library("rgenoud")

setwd("C:/Users/satya/OneDrive/WORKBENCH/Personal Study/Complex Systems/assignment")

## optim is a generic package


## Set objective function; adapted from Lovelace book
fun <- function(par, ind_n.Freq, con){
  sim <- colSums(par * ind_n.Freq)
  ae <- abs(sim - con) # Absolute error per category
  sum(ae) # the Total Absolute Error (TAE)
}

timerecord <- data.frame(iteration = integer(), elapsed_time = numeric())

# Create a log file for errors
error_log <- file("error_log.txt", open = "a")

for (year in 2022:2024){
  tryCatch({
    ## Import dataset
    input_complete <- read_csv(paste0("raw/",year,"_clean.csv"))
    input_complete <- unique(input_complete)
    cons <- read_csv(paste0("raw/pop_", year, ".csv"))
    input_sub1_complete <- head(input_complete,6000)
    input_sub1 <- select(input_sub1_complete, -c(empstat, educ, weight))
    cons <- select(cons, -c(region, year))
    
    out_list <- list()
    
    for (iter in 1:13){
      tryCatch({
        tic()
        out_list[[iter]] <- genoud(nvars = nrow(input_sub1), fn = fun, 
                                   ind_n.Freq = input_sub1, con = cons[iter,], 
                                   control = list(maxit = 100), 
                                   data.type.int = TRUE, 
                                   Domains = matrix(c(rep(0, nrow(input_sub1)),rep(100000, nrow(input_sub1))), ncol = 2))
        
        input_sub1_complete <- input_sub1_complete %>% 
          mutate(!!paste0("weight_", iter) := out_list[[iter]]$par)
        
        time <- toc(quiet = TRUE)
        timerecord <- rbind(timerecord, data.frame(year = year, iteration = iter, elapsed = time$toc-time$tic))
      }, error = function(e) {
        cat(paste0("Error in year ", year, ", iteration ", iter, ": ", conditionMessage(e), "\n"), file = error_log, append = TRUE)
        cat(paste0("Error in year ", year, ", iteration ", iter, ": ", conditionMessage(e), "\n"))  # Also print to console
      })
    }
    
    write_csv(input_sub1_complete, paste0("clean/simulated_",year,".csv"))
    
  }, error = function(e) {
    cat(paste0("Error processing year ", year, ": ", conditionMessage(e), "\n"), file = error_log, append = TRUE)
    cat(paste0("Error processing year ", year, ": ", conditionMessage(e), "\n"))  # Also print to console
  })
}

# Close the error log file
close(error_log)

timerecord
write_csv(timerecord, "timerecord_6000_reducediter.csv")

# for (year in 2022:2024){
#   
#   ## Import dataset
#   input_complete <- read_csv(paste0("raw/",year,"_clean.csv"))
#   input_complete <- unique(input_complete)
#   cons <- read_csv(paste0("raw/pop_", year, ".csv"))
#   input_sub1_complete <- head(input_complete,100)
#   input_sub1 <- select(input_sub1_complete, -c(empstat, educ, weight))
#   cons <- select(cons, -c(region, year))
#   
#   out_list <- list()
#   
#   for (iter in 1:13){
#     
#     tic()
#     out_list[[iter]] <- genoud(nvars = nrow(input_sub1), fn = fun, 
#                                ind_n.Freq = input_sub1, con = cons[iter,], 
#                                control = list(maxit = 10000), 
#                                data.type.int = TRUE, 
#                                Domains = matrix(c(rep(0, nrow(input_sub1)),rep(100000, nrow(input_sub1))), ncol = 2))
#     
#     input_sub1_complete <- input_sub1_complete %>% 
#       mutate(!!paste0("weight_", iter) := out_list[[iter]]$par)
#     
#     time <- toc(quiet = TRUE)
#     timerecord <- rbind(timerecord, data.frame(iteration = iter, elapsed = time$toc-time$tic))
#     
#   }
#   
#   write_csv(input_sub1_complete, paste0("clean/simulated_",year,".csv"))
#   
# }

# tic()
# out1 <- genoud(nvars = nrow(input_2), fn = fun, 
#               ind_n.Freq = input_2, con = cons[1,], 
#               control = list(maxit = 10000), 
#               data.type.int = TRUE, 
#               Domains = matrix(c(rep(0, nrow(input_2)),rep(100000, nrow(input_2))), ncol = 2))
# 
# out1$par
# toc() ##2626.98 sec elapsed

# fun(par = out$par, ind_n.Freq = input_sub1, con = cons)

