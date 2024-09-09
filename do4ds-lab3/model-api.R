## Get Data

library(dplyr)
library(ggplot2)
library(dbplyr)

con <- DBI::dbConnect(
  duckdb::duckdb(), 
  dbdir = "my-db.duckdb"
)
df <- dplyr::tbl(con, "penguins")


## Define Model and Fit
model = lm(body_mass_g ~ bill_length_mm + species + sex, data = df)
model_summary = summary(model)

## Turn into Vetiver Model
library(vetiver)
v = vetiver_model(model, model_name='penguin_model')

## Save to Board
library(pins)
model_board <- board_folder("/data/model", versioned = TRUE)
model_board %>% vetiver_pin_write(v)

## Turn model into API
library(plumber)
pr() %>%
  vetiver_api(v) %>%
  pr_run(port = 8080)

DBI::dbDisconnect(con)
