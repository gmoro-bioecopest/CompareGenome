

for (FInfoN in FFInfo$Info) {
  FFInfoTemp <- subset(FFInfo, Info == FInfoN)
  MyFinName <- paste0("'", FFInfoTemp$Detail, "'")
  FInfoV <- paste0(FInfoN, '=', MyFinName)
  eval(parse(text = FInfoV))
}
