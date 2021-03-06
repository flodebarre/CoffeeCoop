## This is very verbose and noisy function that processes the
## accounts.  Most of the function is making sure things are sane!

## TODO: Fill in blank Milk as TRUE.
##     : Search for duplicates
##     : All dates within last period

do.accounts <- function(force.git=FALSE, force.empty=FALSE) {
  f.out <- sprintf("data/%s.csv", today)
  message("Loading data")
  dat <- load.data()
  message("Processing data/info.csv")
  info <- dat$info
  i <- nrow(info)
  if ( info$Date[i] != "Future" )
    stop("Last Date in data/info.csv must be 'Future'")
  fill.in <- c("CostBlack", "CostMilk", "Count", "Cash", #"Assets",
               "MilkOutgoing")
  fill.in <- fill.in[sapply(info[i,fill.in], is.na)]
  if ( length(fill.in) > 0 )
    stop("'Future' values required in info.csv for columns:\n\t",
         paste(fill.in, collapse=", "))

  message("Processing data/Future.csv")
  err <- character(0)
  if ( !any(dat$data$Payment[,"Future"] > 0) )
    err <- c(err, "\tNobody paid this period")
  if ( !any(dat$data$Coffee[,"Future"] > 0) )
    err <- c(err, "\tNobody drank coffee this period")
  if ( !any(dat$data$Tea[,"Future"] > 0) )
    err <- c(err, "\tNobody drank tea this period")
  if ( length(err) > 0 ) {
    str <- c("Unlikely situations found in data:", err,
             "Most likely data/Future.csv has not been filled in.")
    if ( force.empty )
      warning(paste(c(str, "\t...continuing anyway"), collapse="\n"))
    else
      stop(paste(c(str, "\t(use force.empty=TRUE to override)"),
                 collapse="\n"))
  }
    
  ## OK, by now we should be OK: No stop calls below here.
  ## Ideally we would do a rollback here if this fails (git reset HEAD
  ## might be enough)
  message(sprintf("Moving data/Future.csv -> %s", f.out))
  file.rename("data/Future.csv", f.out)

  ## Generate a new sheet for next month.
  message("Generating new signup sheet in data/Future.csv")
  people <- sort(dat$people$Name[!dat$people$Gone])
  i <- match(people, rownames(dat$data$Milk))
  d <- data.frame(Name=people,
                  Payment=NA,
                  "Payment Date"=NA,
                  Milk=dat$data$Milk[i,ncol(dat$data$Milk)-1],
                  Coffee=NA,
                  Tea=NA)
  write.csv(d, file="data/Future.csv", row.names=FALSE, na="")

  message("Updating data/info.csv")
  info <- read.csv("data/info.csv", stringsAsFactors=FALSE)
  info$Date[nrow(info)] <- today
  info[nrow(info)+1,] <- NA
  info$Date[nrow(info)] <- "Future"
  write.csv(info, "data/info.csv", row.names=FALSE, na="")

  message("Reloading data")
  dat <- load.data()
  
  message("Generating new signup sheet")
  signup.coffee(dat$status, quiet=TRUE)
  signup.tea(dat$status, quiet=TRUE)

  ## message("Updating website")
  ## www(dat)
  ## www.copy()

  ## message("Storing changes")
  ## git.add(f.out)
  ## git.commit(sprintf("Accounts on %s", today))
  ## git.tag(sprintf("accounts-%s", today))

  invisible(dat)
}

## Do the accounting!
git.is.clean <- function()
  system("[[ -n $(git status -s 2> /dev/null) ]]") == 1

## Not system safe (prone to injection)
git.commit <- function(msg)
  system(sprintf("git commit -a -m '%s'", msg))
git.tag <- function(tag)
  system(sprintf("git tag %s", tag))
git.add <- function(file)
  system(sprintf("git add %s", file))
