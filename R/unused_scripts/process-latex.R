## TODO: This should use R packages for formatting LaTeX and HTML
## tables.
signup.coffee <- function(status, quiet=FALSE) {
#  sub <- subset(status, !(status$Gone), c("Name", "Milk", "Balance"))
  sub <- status[!(status$Gone), c("Name", "Milk", "Balance")]
  sub <- sub[order(sub$Name),]

#  sub$Name <- add.accents(sub$Name)

  tmp <- cbind(as.character(sub$Name),
               ifelse(!sub$Milk, "\\checkmark", ""),
               sprintf(ifelse(sub$Balance < 0, "\\textbf{-\\$%2.2f}",
                              "\\$%2.2f"),
                       abs(sub$Balance)),
               "\\\\\\hline")
  str <- paste(apply(tmp, 1, paste, collapse=" & "), collapse="\n")

  template <-
    c("\\begin{longtable}{|l|c|r|X|}\\hline",
      "\\textbf{Name} & \\textbf{No milk} & \\textbf{Balance}",
      "& \\textbf{Drinks Tally}\\endhead\\hline",
      "%s",
      "\\multicolumn{4}{l}{}\\\\[15ex]",
      "\\multicolumn{4}{l}{\\textbf{New members:}}\\\\[1ex]\\hline",
      "\\textbf{Name}&\\textbf{No milk}&&\\textbf{Drinks Tally}\\\\\\hline",
      "%s",
      "\\end{longtable}")
  writeLines(sprintf(paste(template, collapse="\n"),
                     paste(str, collapse="\n"),
                     paste(rep("&&&\\\\\\hline", 20), collapse="\n")),
             "../signup/table-coffee.tex")
  system("cd ../signup; pdflatex signup-coffee-new.tex")
}

get.flag <- function(iso, quiet=FALSE) {
  f.out <- sprintf("%s.png", iso)
  if ( file.exists(file.path("signup/flags", f.out)) )
    return(TRUE)
  countries <- c(au="Australia",
                 nz="New_Zealand",
                 cl="Chile",
                 gb="the_United_Kingdom",
                 fr="France",
                 us="the_United_States",
                 ca="Canada")

  fmt.url <-
    "http://upload.wikimedia.org/wikipedia/commons/thumb/d/d9/Flag_of_%s.svg/200px-Flag_of_%s.svg.png"
  fmt.file <- "200px-Flag_of_%s.svg.png"
  
  oldwd <- setwd("signup/flags")
  on.exit(setwd(oldwd))
  full <- countries[iso]
  system(paste("snarf", sprintf(fmt.url, full, full)),
         ignore.stdout=quiet)
  file.rename(sprintf(fmt.file, full), f.out)
}

## This is temporary, at least for now.
country <- c('Alana Schick'='ca',
             'Andrea Stephens'='nz',
             'Angelica Gonzalez'='cl',
             'Anne Bjorkman'='us',
             'Carling Gerlinsky'='ca',
             'Diane Srivastava'='ca',
             'Edd Hammill'='gb',
             'Edy Piascik'='ca',
             'Florence Debarre'='fr',
             'Greg Baute'='ca',
             'Greg Gavelis'='us',
             'Jenn Jorve'=NA,
             'Jessica Lu'='ca',
             'Jocelyn Nelson'='ca',
             'Joey Bernhardt'='ca',
             'Julian Heavyside'=NA,
             'Kathryn Turner'='us',
             'Katie Lotterhos'='us',
             'Lesha Koop Hines'='us',
             'Lizzie Wolkovich'='us',
             'Matt Barbour'='us',
             'Michael Scott'='gb',
             'Naomi Fast'='ca',
             'Rebecca Seifert'=NA,
             'Rich FitzJohn'='nz',
             'Rose Andrew'='au',
             'Ruth Sharpe'='gb',
             'Thuy Nguyen'='ca')

signup.tea <- function(status, quiet=FALSE) {
  sub <- subset(status, !Gone & TotalTea > 0,
                c("Name", "Balance"))
  sub <- sub[order(sub$Name),]
  strut <- sub$Name[which.max(nchar(sub$Name))]
  sub$Name <- add.accents(sub$Name)

  tmp <- cbind(as.character(sub$Name),
               sprintf(ifelse(sub$Balance < 0, "\\textbf{-\\$%2.2f}",
                              "\\$%2.2f"),
                       abs(sub$Balance)),
               "\\\\\\midrule")
  str <- paste(apply(tmp, 1, paste, collapse=" & "), collapse="\n")

  template <-
    c("\\begin{tabularx}{\\textwidth}{l>{\\columncolor{vlightgray}}rX}",
      "\\toprule",
      "\\sc Name & \\sc Balance &\\sc Tally\\\\\\toprule",
      "%s",
      "\\arrayrulecolor{black}\\bottomrule",
      "\\end{tabularx}")
  res <- sprintf(paste(template, collapse="\n"),
                 paste(str, collapse="\n"))

  template2 <- 
    c("\\begin{tabularx}{\\textwidth}{lr|X}",
      "\\toprule",
      "\\sc Name & \\sc\\phantom{Balance} &\\sc Tally\\\\\\toprule",
      "\\phantom{%s}&&\\\\\\midrule",
      "%s",
      "\\arrayrulecolor{black}\\bottomrule",
      "\\end{tabularx}")
  res2 <- sprintf(paste(template2, collapse="\n"), strut, 
                 paste(rep("&&\\\\\\midrule", 7), collapse="\n"))
  writeLines(res, "signup/table-tea.tex")
  writeLines(res2, "signup/table-tea-new.tex")
  system("cd signup; xelatex signup-tea.tex", ignore.stdout=quiet)
}

signup.tea.flag <- function(status, quiet=FALSE) {
  sub <- subset(status, !Gone & TotalTea > 0,
                c("Name", "Balance"))
  sub <- sub[order(sub$Name),]
  strut <- sub$Name[which.max(nchar(sub$Name))]
  code <- country[match(sub$Name, names(country))]
  sub$Name <- add.accents(sub$Name)

  ok <- sapply(sort(na.omit(unique(country))), get.flag)
  
  flag <- sprintf2("\\includegraphics[height=.82em]{flags/%s.png}", code)
  flag[is.na(flag)] <- ""
  tmp <- cbind(flag,
               as.character(sub$Name),
               sprintf(ifelse(sub$Balance < 0, "\\textbf{-\\$%2.2f}",
                              "\\$%2.2f"),
                       abs(sub$Balance)),
               "\\\\\\midrule")
  str <- paste(apply(tmp, 1, paste, collapse=" & "), collapse="\n")
  template <-
    c("\\begin{tabularx}{\\textwidth}{cl>{\\columncolor{vlightgray}}rX}",
    "\\toprule", "&\\sc Name & \\sc Balance &\\sc Tally\\\\\\toprule",
    "%s", "\\arrayrulecolor{black}\\bottomrule", "\\end{tabularx}")
    res <- sprintf(paste(template, collapse="\n"), paste(str,
    collapse="\n"))
  template2 <- 
    c("\\begin{tabularx}{\\textwidth}{l|X}",
      "\\toprule",
      "\\sc Name &\\sc Tally\\\\\\toprule",
      "\\hspace*{.36\\textwidth}&\\\\\\midrule",
      "%s",
      "\\arrayrulecolor{black}\\bottomrule",
      "\\end{tabularx}")
  res2 <- sprintf(paste(template2, collapse="\n"),
                 paste(rep("&\\\\\\midrule", 7), collapse="\n"))
  writeLines(res, "signup/table-tea.tex")
  writeLines(res2, "signup/table-tea-new.tex")
  system("cd signup; xelatex signup-tea.tex", ignore.stdout=quiet)
}

add.accents <- function(str) {
  tr <- c(Chenard="Ch\\\\'enard",
          Debarre="D\\\\'ebarre",
          "Angelica Gonzalez"="Ang\\\\'elica Gonz\\\\'alez",
          "Andrea Stephens"="Andr\\\\'ea Stephens",
          "Sebastien Renaut"="S\\\\'ebastien Renaut",
          "Anna Gonzalves"="Anna Gon\\\\c{c}alves")
  for ( i in seq_along(tr) )
    str <- sub(names(tr)[[i]], tr[[i]], str)
  str
}
