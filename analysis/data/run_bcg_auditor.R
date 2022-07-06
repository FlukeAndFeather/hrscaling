run_bcg_auditor <- function(deployid = "bb190226-53",
                            cats_path = "/Volumes/GoogleDrive/Shared drives/CATS/") {
  rmarkdown::render(
    here::here("analysis/data/bcg_auditor.Rmd"),
    output_dir = here::here("analysis/data/derived_data/bcg_audits"),
    output_file = deployid
  )
}
