library(dplyr)
library(lubridate)
library(readr)

path_to_prh <- "/Volumes/GoogleDrive/Shared drives/CATS/tag_data/bb190226-53 (Antarctic)/bb190226-53_prh10.nc"
path_to_prh <- "~/Downloads/bb190226-53_prh10.nc"
prh <- catsr::read_nc(path_to_prh)

path_to_phaseiii <- here::here("analysis/data/raw_data/bb190226-53.csv")
bb_motionless <- readr::read_csv(path_to_phaseiii, show_col_types = FALSE) %>%
  mutate(across(c(motionlessstart, motionlessend),
                ~ ymd_hms(.x, tz = attr(prh, "tz"))))

dn_to_posix <- function(dn, tz = "UTC") {
  lubridate::force_tz(as.POSIXct((dn - 719529) * 86400,
                                 origin = "1970-01-01",
                                 tz = "UTC"),
                      tz)
}

path_to_400_hz <- here::here("analysis/data/raw_data/400hz/bb190226-53_400hz.csv")
bb_400hz <- readr::read_csv(path_to_400_hz,
                            col_names = c("dn", "surge", "sway", "heave"),
                            col_types = "dddd") %>%
  mutate(dt = dn_to_posix(dn, tz = attr(prh, "tz")))

library(dplyr)
library(cetaceanbcg)
bb_bcg <- bb_400hz %>%
  mutate(
    across(surge:heave,
           filter_acc, fs = 400, upper = 10.0,
           .names = "{.col}_filt"),
    jerk = jerk(cbind(surge_filt, sway_filt, heave_filt),
                fs = 400, p = 4, n = 2 * 400 + 1),
    jerk_se = shannon_entropy(jerk),
    jerk_smooth = tma(jerk_se, 2 * 400),
    # Annotate regions
    rid_left = approx(bb_motionless$motionlessstart,
                      bb_motionless$motionlessid,
                      dt,
                      "constant")$y,
    rid_right = approx(bb_motionless$motionlessend,
                       bb_motionless$motionlessid,
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
