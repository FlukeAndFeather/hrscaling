find_prh <- function(cats_path, deployid) {
  tag_folder <- dir(file.path(cats_path, "tag_data"),
                    deployid,
                    full.names = TRUE)
  stopifnot(length(tag_folder) == 1)
  prh_path <- dir(tag_folder, paste0(deployid, "_prh10.nc"), full.names = TRUE)
  stopifnot(length(prh_path) == 1)
  prh_path
}

dn_to_posix <- function(dn, tz = "UTC") {
  lubridate::force_tz(as.POSIXct((dn - 719529) * 86400,
                                 origin = "1970-01-01",
                                 tz = "UTC"),
                      tz)
}

make_bcg <- function(acc400, phase3) {
  acc400 %>%
    mutate(
      across(surge:heave,
             filter_acc, fs = 400, upper = 10.0,
             .names = "{.col}_filt"),
      jerk = jerk(cbind(surge_filt, sway_filt, heave_filt),
                  fs = 400, p = 4, n = 2 * 400 + 1),
      jerk_se = shannon_entropy(jerk),
      jerk_smooth = tma(jerk_se, 2 * 400),
      # Annotate regions
      rid_left = approx(phase3$motionlessstart,
                        phase3$motionlessid,
                        dt,
                        "constant")$y,
      rid_right = approx(phase3$motionlessend,
                         phase3$motionlessid,
                         dt,
                         "constant",
                         yleft = 0)$y + 1,
      region_id = ifelse(rid_left == rid_right, rid_left, NA),
      # Zero-out signal in non-valid regions (i.e. remove movement artifacts)
      jerk_smooth = ifelse(is.na(region_id), 0, jerk_smooth),
      bcg_beat = find_beats(jerk_smooth, 400, 2)
    ) %>%
    # Calculate heart rate within each region
    group_by(region_id) %>%
    mutate(bcg_bpm = bpm(bcg_beat, dt)) %>%
    ungroup() %>%
    select(-c(rid_left, rid_right))
}
