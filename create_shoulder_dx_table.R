dx1 <- read.csv("Ortho DX Map.csv", stringsAsFactors = FALSE)

table(dx1$Svc.Program)
dx1_shldr <- grepl("shoulder", tolower(dx1$Svc.Program))
dx1_icd <- grepl("icd", tolower(dx1$Svc.Line.ID))
dx1_cols <- c("Code", "Description")
dx1_reduced <- dx1[which(dx1_shldr & dx1_icd), dx1_cols]
names(dx1_reduced) <- c("code_fmt", "code_desc")
dx1_reduced$code <- gsub("\\.", "", dx1_reduced$code_fmt)
dx1_reduced$code_type <- "10"

dx2 <- read.csv("ICD-9 DIAG Code List.csv", stringsAsFactors = FALSE)
names(dx2) <- c("code", "code_desc")
formatICD <- function(x, sep_after = 3) {
  if(nchar(x) <= sep_after) return(x)
  code_1 <- substring(x, first = 1, last = sep_after)
  code_2 <- substring(x, sep_after+1, nchar(x))
  paste(code_1, code_2, sep = ".")
}
dx2$code_fmt <- unlist(lapply(dx2$code, formatICD))
dx2$code_type <- "9"

dxlist <- rbind(dx1_reduced[ , c("code", "code_fmt", "code_desc", "code_type")], 
                dx2[ , c("code", "code_fmt", "code_desc", "code_type")])

write.csv(dxlist, "shldr_icd.csv", row.names = FALSE)



dx3 <- read.csv("ICD10_ICD9_Crosswalk_Upper Extremity.csv", stringsAsFactors = FALSE)

dx3_icd9 <- dx3[ , c("DX_CATEGORY", "ICD9", "DX_DESCRIPTION")]
names(dx3_icd9) <- c("category", "code", "code_desc")
dx3_icd9$code_type <- "9"

dx3_icd10 <- dx3[ , c("DX_CATEGORY", "ICD10_UNSPECIFIED", "DX_DESCRIPTION")]
names(dx3_icd10) <- c("category", "code", "code_desc")
dx3_icd10$code_type <- "10"

dx3_icd10_left <- dx3[ , c("DX_CATEGORY", "ICD10_LEFT", "DX_DESCRIPTION")]
dx3_icd10_left$DX_DESCRIPTION <- paste(dx3_icd10_left$DX_DESCRIPTION, "left", sep = " - ")
names(dx3_icd10_left) <- c("category", "code", "code_desc")
dx3_icd10_left$code_type <- "10"

dx3_icd10_right <- dx3[ , c("DX_CATEGORY", "ICD10_RIGHT", "DX_DESCRIPTION")]
dx3_icd10_right$DX_DESCRIPTION <- paste(dx3_icd10_right$DX_DESCRIPTION, "right", sep = " - ")
names(dx3_icd10_right) <- c("category", "code", "code_desc")
dx3_icd10_right$code_type <- "10"

dx3_reduced <- rbind(dx3_icd9, dx3_icd10, dx3_icd10_left, dx3_icd10_right)
dx3_reduced <- dx3_reduced[nchar(dx3_reduced$code) != 0, ]
dx3_reduced$code_desc[dx3_reduced$code_desc %in% c(" - left", " - right")] <- ""

# nomiss_icd9 <- dx3_icd9$code[dx3_icd9$code != "" & dx3_icd9$code_desc != ""]
# lookup_icd9 <- icd::icd_explain_table.icd9(nomiss_icd9)[ , c("code", "long_desc")]
# 
# nomiss_icd10 <- c(dx3_icd10$code[dx3_icd10$code != "" & dx3_icd10$code_desc != ""],
#                   dx3_icd10_left$code[dx3_icd10_left$code != "" & dx3_icd10_left$code_desc != ""],
#                   dx3_icd10_right$code[dx3_icd10_right$code != "" & dx3_icd10_right$code_desc != ""])
# lookup_icd10 <- icd::icd_explain_table.icd10(nomiss_icd10)[ , c("code", "long_desc")]
# 
# dx3_reduced_filled <- merge(dx3_reduced, rbind(lookup_icd9, lookup_icd10), by = "code", all.x = TRUE)
# dx3_reduced_filled$code_desc[dx3_reduced_filled$code_desc == "" & !is.na(dx3_reduced_filled$long_desc)] <- dx3_reduced_filled$long_desc
# dx3_reduced_filled2 <- dx3_reduced_filled[ , c("category", "code", "code_desc", "code_type")]

carryDown <- function(x) {
  y <- x
  return_nonmiss <- function(x2, pos) {
    x2p <- x2[pos]
    if(!(is.na(x2p) | x2p == "")) return(x2p) 
    y2 <- x2[1:pos]
    y2 <- y2[!(is.na(y2) | y2 == "")]
    return(y2[length(y2)])
  }
  for(i in seq_along(x)) {
    y[i] <- return_nonmiss(x, i)
  }
  return(y)
}

dx3_carried <- lapply(dx3_reduced, carryDown)
dx3_carried_df <- unique(do.call("cbind.data.frame", dx3_carried))
dx3_carried_df$shoulder_related <- as.numeric(grepl("[Sh](ldr|oulder)", paste0(dx3_carried_df$code_desc, dx3_carried_df$category)))
