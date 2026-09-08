con <- DBI::dbConnect(duckdb::duckdb(), dbdir = "my-db.duckdb")
DBI::dbWriteTable(con, "penguins", palmerpenguins::penguins, overwrite = TRUE)
DBI::dbDisconnect(con)

