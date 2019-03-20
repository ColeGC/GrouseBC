set.seed(4231)

nbene <- 10000
nbene <- ifelse(nbene%%3 != 0, nbene - nbene%%3, nbene)

enroll_month <- matrix(data = sample(LETTERS, size = 12*nbene, replace = TRUE), nrow = nbene, ncol = 12)
enroll_month <- as.data.frame(enroll_month)
names(enroll_month) <- month.abb
enroll_month$ID <- rep(paste0("ID", 1:(nbene/3)), each = 3)
enroll_month$year_enroll <- rep(2011:2013, times = nbene/3)
yr <- as.character(sample(x = 2011:2013, size = nbene/3, replace = TRUE))
mn <- sample(x = 1:12, nbene/3, replace = TRUE)
mn <- ifelse(mn %in% 1:9, paste0("0", mn), as.character(mn))
dy <- sample(x = 1:31, size = nbene/3, replace = TRUE)
enroll_month$refdate <- rep(as.Date(paste(yr, mn, dy, sep = "-")), each = 3)
enroll_month$shift_days <- rep(sample(x = -365:365, size = nbene/3, replace = TRUE), each = 3)

enroll_month <- enroll_month[which(!is.na(enroll_month$refdate)), ]
enroll_month$refdate <- enroll_month$refdate + enroll_month$shift_days

rm(dy, mn, yr, nbene)

## Okay... don't think I actually need to think about their enrollment status each month
## Rather, just want to put some numbers on extent of problem from shifting at the day-level date for month-level variables

month2date <- function(month, year) {
  m <- ifelse(month %in% 1:9, paste0("0", month), month)
  paste(year, m, "01", sep = "-")
}
yearMonths <- function(year) {
  month12 <- lapply(1:12, function(x) month2date(x, year))
  unlist(month12)
}

month_original <- lapply(enroll_month$year_enroll, yearMonths)
month_original <- do.call("rbind", month_original)
monthdf <- cbind(enroll_month, month_original)
idx <- (ncol(monthdf)-11):ncol(monthdf)
j <- 1
for(i in idx) {
  monthdf[,i] <- as.Date(monthdf[,i])
  names(monthdf)[i] <- paste0("orig_", month.abb[j])
  j <- j + 1
}

month_shift <- monthdf[ , grep("^orig_", names(monthdf))]
for(i in 1:nrow(monthdf)) {
  month_shift[i,] <- month_shift[i,] - monthdf$shift_days[i]
}
dd <- lapply(month_shift, as.POSIXlt.Date)
dd2 <- lapply(dd, lubridate::month)
dd3 <- do.call("cbind.data.frame", dd2)

check_reps <- function(x) {
  length(unique(x)) == length(x)
}

dd3_repRow <- apply(dd3, 1, check_reps)
all(dd3_repRow)
which_dd3reps <- which(!dd3_repRow)
dd3[which_dd3reps[1:9], ]
monthdf[which_dd3reps[1:9], ]

do.call("cbind.data.frame", dd)[which_dd3reps[1:9], ]

c_old <- monthdf[which_dd3reps[1:9], ]
c_shift <- do.call("cbind.data.frame", dd)[which_dd3reps[1:9], ]
names(c_shift) <- gsub("orig", "shifted", names(c_shift))
View(cbind(c_old, c_shift))

# pct with overlap after shift
paste0(round(1 - mean(dd3_repRow), 3)*100, "%")
# ... 8.8% should be high relative to what we see in the real data...
# ... in CMS data, overlaps % only of subset with both overlap month from date shift that also has enroll status change