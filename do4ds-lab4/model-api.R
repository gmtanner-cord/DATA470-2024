## Get Data

library(dplyr)
library(ggplot2)
library(dbplyr)
library(log4r)

log <- log4r::logger()

## Connect to DuckDB
log4r::info(log, "Connecting to DuckDB database.")
con <- DBI::dbConnect(
  duckdb::duckdb(), 
  dbdir = "my-db.duckdb"
)
df <- dplyr::tbl(con, "penguins")


## Define Model and Fit
log4r::info(log, "Building Model")
model = lm(body_mass_g ~ bill_length_mm + species + sex, data = df)
model_summary = summary(model)

## Turn into Vetiver Model
library(vetiver)
v = vetiver_model(model, model_name='penguin_model')

## Save to Board
library(pins)
model_board <- board_temp(versioned = TRUE)
model_board %>% vetiver_pin_write(v)

## Turn model into API
log4r::info(log, "Starting API")
library(plumber)
pr() %>%
  vetiver_api(v) %>%
  pr_filter(
    "logger", 
    function(req,res) {
      log4r::info(log, paste0(
        "Method: ", req$REQUEST_METHOD,
        " | PATH: ", req$PATH_INFO,
        " | IP: ", req$REMOTE_ADDR
      ))
      plumber::forward()
    }
  ) %>%
  pr_run(port = 8080)

DBI::dbDisconnect(con)
