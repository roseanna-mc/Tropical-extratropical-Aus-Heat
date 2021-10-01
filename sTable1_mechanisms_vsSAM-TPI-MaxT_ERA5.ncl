; 18/6/21
; Usage NCL

; Correlates mechanisms vs features, including partial (no SAM, no TPI)
; Now with ERA5

begin

;--------------------- Set options -------------------------
 yrStrtC = 1981                          ; First year of climatology
 yrStopC = 2010                          ; Last year of climatology
 yrFirst = 1979
 yrLast  = 2019

 indStrt = yrStrtC - yrFirst
 indStop = yrStopC - yrFirst               ; Index of last year of climatology

 moStrtC = (yrStrtC - yrFirst)*12        ; First year of climatology
 moStopC = (yrStopC - yrFirst)*12 + 11   ; Last month of climatology
 moStrtE = (yrFirst - 1979)*12           ; First month of climatology index for ERAI
 moStopE = (yrLast - 1979)*12 + 11       ; ERA-I data goes to August 2019
 moStrtH = (yrFirst - 1870)*12            ; First month (index) to use in Hurrell extended dataset
 moLastH = (yrLast - 1870)*12 + 11       ; Last month (index) to use in Hurrell extended dataset

 dtrns     = (/"False", "True"/)         ; Detrended ("True") or whole data ("False")?
 regions   = (/"Aus","SW","SE","N"/)         ; which regions do I take MT time series of?
 regionSts = (/"", "SW", "SE","N"/)          ; for plot
 stds      = (/"False","True"/)          ; Standardise index or not?

 mons      = (/"Sep", "Oct", "Nov"/)
 months    = (/"September", "October", "November"/)

 stdise    = stds(0)
 dtrnd     = dtrns(1)

 siglvl    = 0.05

 rad       = 4.0*atan(1.0)/180.0

;-------------------------- File options -----------------------
 obsDir  = "/g/data/w97/rm8168/data/obs/"
 outDir  = "/g/data3/w97/rm8168/data/tropVextrop/withWS/"
 erDir   = "/g/data/w97/rm8168/data/tropVextrop/"
;------------------ Get data ---------------------

 ; feature lat lons
 zblon = (/-30., -40., -40., -30., -30./)
 zblat = (/120., 120., 150., 150., 120./)
 v8lon = (/-45., -60., -60., -45., -45./)
 v8lat = (/160., 160., 200., 200., 160./)
 w5lon = (/-35., -55., -55., -35., -35./)
 w5lat = (/70., 70., 120., 120., 70./)
 u8lon = (/-40., -20., -20., -40., -40./)
 u8lat = (/150., 150., 170., 170., 150./)

; mech lat lons
 uvlon = (/-25., -45., -45., -25., -25./)
 uvlat = (/105., 105., 155., 155., 105./)
 wlon  = (/-15., -25., -25., -15., -15./)
 wlat  = (/120., 120., 155., 155., 120./)

 ; era5 v8 time series
 sfil   = erDir + "1979_2019_ERA5_U850_S-O-N_timeseries"
 ncol   = 3                    ; S O N
 nrows  = (2019 - 1979) +1
 allu8  = asciiread(sfil,(/nrows,ncol/),"float")        ;[492] x [3]
 printVarSummary(allu8)
 delete(sfil)

 sfil   = erDir + "1979_2019_ERA5_V850x-1_S-O-N_timeseries"
 allv8  = asciiread(sfil,(/nrows,ncol/),"float")        ;[492] x [3]
 printVarSummary(allv8)

 sfil   = erDir + "1979_2019_ERA5_W500_S-O-N_timeseries"
 allw5  = asciiread(sfil,(/nrows,ncol/),"float")        ;[492] x [3]
 printVarSummary(allw5)
 
 sfil   = erDir + "1979_2019_ERA5_SWLx-1_S-O-N_timeseries"
 ncol   = 3                    ; S O N
 nrows  = (2019 - 1979) +1
 allsw  = asciiread(sfil,(/nrows,ncol/),"float")        ;[492] x [3]
 ;printVarSummary(allsw)
 delete(sfil)

 sfil   = erDir + "1979_2019_ERA5_SELx-1_S-O-N_timeseries"
 ncol   = 3                    ; S O N
 nrows  = (2019 - 1979) +1
 allse  = asciiread(sfil,(/nrows,ncol/),"float")        ;[492] x [3]
 ;printVarSummary(allse)
 delete(sfil)

 sfil   = erDir + "1979_2019_ERA5_ZB_S-O-N_timeseries"
 ncol   = 3                    ; S O N
 nrows  = (2019 - 1979) +1
 allzb  = asciiread(sfil,(/nrows,ncol/),"float")        ;[492] x [3]
 ;printVarSummary(allzb)
 delete(sfil)

 sfil   = erDir + "1979_2019_ERA5_MTas_S-O-N_timeseries"
 ncol   = 3                    ; S O N
 nrows  = (2019 - 1979) +1
 allmts = asciiread(sfil,(/nrows,ncol/),"float")        ;[492] x [3]
 ;printVarSummary(allmts)
 delete(sfil)

  ; era5 sam time series
  sfil   = obsDir + "1979_2019_era5_sam_x1.txt"
  ncol   = 3                    ; years, months, sam
  nrows  = (2019 - 1979)*12 + 12
  allsam = asciiread(sfil,(/nrows,ncol/),"float")
  sams   = (allsam(moStrtE:moStopE,2))*-1.
  delete(sfil)
  delete(ncol)
  delete(nrows)
  printVarSummary(sams)
  delete(allsam)

 ; tpi
 tfil    = obsDir + "tpiInd_ERSSTv5.txt"
 tstrt   = (yrFirst - 1891)*12
 tstop   = (yrLast - 1891)*12+11
 nrows   = (2019 - 1891 + 1 )*12 + 4    ; goes to April 2020
 ncol    = 6                            ; yr mn tri_c tri_w tri_e tpi
 alltp   = asciiread(tfil,(/nrows,ncol/),"float")
 tpis    = (alltp(tstrt:tstop,5))*-1.
 delete(tfil)
 delete(tstrt)
 delete(tstop)
 delete(nrows)
 delete(ncol)
 delete(alltp)

 if dtrnd.eq."True" then
  trend   =  "_DT_"     ; For output file
  trendSt = "detrended "; For plot title
 else
  trend   = "_"
  trendSt = ""
 end if
 if stdise.eq."True" then
  stdfx = "std"                 ; for file extension and plot title
 else
  stdfx = ""
 end if

 do m    = 0, dimsizes(mons)-1 ; loop through months
  mon    = mons(m)        ; for files
  month  = months(m)      ; for titles

  M      = m + 8

   u8sm    = allu8(:,m)
   v8sm    = allv8(:,m)
   w5sm    = allw5(:,m)
   tpi     = tpis(M::12)
   sam     = sams(M::12)
   mtasm   = allmts(:,m)
   zbigm   = allzb(:,m)
   mswlm   = allsw(:,m)
   mselm   = allse(:,m)

 ; ------- detrend ------
  u8sd  = u8sm
  w5sd  = w5sm
  v8sd  = v8sm
  samd   = sam
  tpid   = tpi
  mtasd  = mtasm
  zbigd  = zbigm
  mswld  = mswlm
  mseld  = mselm
  if dtrnd.eq."True" then
   x     = ispan(1, dimsizes(tpi(:)), 1)
   ;printVarSummary(x)
   u8sd = dtrend_msg_n(x,u8sm,False,False,0)
   w5sd = dtrend_msg_n(x,w5sm,False,False,0)
   v8sd = dtrend_msg_n(x,v8sm,False,False,0)
   samd  = dtrend_msg_n(x,sam,False,False,0)
   tpid  = dtrend_msg_n(x,tpi,False,False,0)
   mtasd = dtrend_msg_n(x,mtasm,False,False,0)
   zbigd = dtrend_msg_n(x,zbigm,False,False,0)
   mswld = dtrend_msg_n(x,mswlm,False,False,0)
   mseld = dtrend_msg_n(x,mselm,False,False,0)
   copy_VarMeta(u8sm, u8sd)
   copy_VarMeta(w5sm, w5sd)
   copy_VarMeta(v8sm, v8sd)
   delete(x)
  end if
  delete(u8sm)
  delete(w5sm)
  delete(v8sm)
  delete(mtasm)
  delete(zbigm)
  delete(mswlm)
  delete(mselm)
  delete(sam)
  delete(tpi)

  u8ssd  = u8sd
  w5ssd  = w5sd
  v8ssd  = v8sd
  samsd   = samd
  tpisd   = tpid
  mtassd  = mtasd
  zbigsd  = zbigd
  mswlsd  = mswld
  mselsd  = mseld
  if stdise.eq."True" then
   ;print("standardising drivers")
   u8ssd = dim_standardize_n_Wrap(u8sd,0,0)
   w5ssd = dim_standardize_n_Wrap(w5sd,0,0)
   v8ssd = dim_standardize_n_Wrap(v8sd,0,0)
   samsd  = dim_standardize_n_Wrap(samd,0,0)
   tpisd  = dim_standardize_n_Wrap(tpid,0,0)
   mtassd = dim_standardize_n_Wrap(mtasd,0,0)
   zbigsd = dim_standardize_n_Wrap(zbigd,0,0)
   mswlsd = dim_standardize_n_Wrap(mswld,0,0)
   mselsd = dim_standardize_n_Wrap(mseld,0,0)
  end if
  delete(u8sd)
  delete(w5sd)
  delete(v8sd)
  delete(samd)
  delete(tpid)
  delete(mtasd)
  delete(zbigd)
  delete(mswld)
  delete(mseld)
;  calculating partials
  ntim   = dimsizes(mtassd)

  ; dummy arrays for maxT associated with drivers ( ~ reg coef x tpi = maxt)
  ; i.e. how much of each max T was 'because' of each driver per year?
  TStpi = new( dimsizes(mtassd), typeof(mtassd), mtassd@_FillValue)
  TSsam = new( dimsizes(mtassd), typeof(mtassd), mtassd@_FillValue)
  ZBtpi = TStpi
  ZBsam = TStpi
  SWtpi = TStpi
  SWsam = TStpi
  SEtpi = TStpi
  SEsam = TStpi

  ;create array for the 2 predictors (tpi, sam)
  xp      = new((/ntim,2/),typeof(tpisd))
  xp(:,0) = tpisd
  xp(:,1) = samsd
  bt      = reg_multlin_stats(mtassd,xp,True)
  rcTStpi = bt(1)
  rcTSsam = bt(2)
  delete(bt)
  bt      = reg_multlin_stats(zbigsd,xp,True)
  rcZBtpi = bt(1)
  rcZBsam = bt(2)
  delete(bt)
  bt      = reg_multlin_stats(mswlsd,xp,True)
  rcSWtpi = bt(1)
  rcSWsam = bt(2)
  delete(bt)
  bt      = reg_multlin_stats(mselsd,xp,True)
  rcSEtpi = bt(1)
  rcSEsam = bt(2)
  delete(bt)
  delete(xp)
 
  ; calculate proportion of variables associated with drivers each year
  ; y = mx + c
  do yr = 0,ntim-1
   TStpi(yr) = rcTStpi*tpisd(yr)
   TSsam(yr) = rcTSsam*samsd(yr)
   ZBtpi(yr) = rcZBtpi*tpisd(yr)
   ZBsam(yr) = rcZBsam*samsd(yr)
   SEtpi(yr) = rcSEtpi*tpisd(yr)
   SEsam(yr) = rcSEsam*samsd(yr) 
   SWtpi(yr) = rcSWtpi*tpisd(yr)
   SWsam(yr) = rcSWsam*samsd(yr)
  end do
  delete(rcTStpi)
  delete(rcTSsam)
  delete(rcZBtpi)
  delete(rcZBsam)
  delete(rcSWtpi)
  delete(rcSWsam)
  delete(rcSEtpi)
  delete(rcSEsam)
  ; calculate proportion of variables not associated with drivers
  TS_ntpi  = mtassd - TStpi
  TS_nsam  = mtassd - TSsam
  delete(TStpi)
  delete(TSsam)
  ZB_ntpi  = zbigsd - ZBtpi
  ZB_nsam  = zbigsd - ZBsam
  delete(ZBtpi)
  delete(ZBsam)
  SE_ntpi  = mswlsd - SEtpi
  SE_nsam  = mselsd - SEsam
  delete(SEtpi)
  delete(SEsam)
  SW_ntpi  = mswlsd - SWtpi
  SW_nsam  = mswlsd - SWsam
  delete(SWtpi)
  delete(SWsam)

 ; W5
 rW5ts     = escorc_n(w5ssd,mtassd,0,0)
 rW5ts_nt  = escorc_n(w5ssd,TS_ntpi,0,0)
 rW5ts_ns  = escorc_n(w5ssd,TS_nsam,0,0)
 rW5zb     = escorc_n(w5ssd,zbigsd,0,0)
 rW5zb_nt  = escorc_n(w5ssd,ZB_ntpi,0,0)
 rW5zb_ns  = escorc_n(w5ssd,ZB_nsam,0,0)
 rW5sw     = escorc_n(w5ssd,mswlsd,0,0)
 rW5sw_nt  = escorc_n(w5ssd,SW_ntpi,0,0)
 rW5sw_ns  = escorc_n(w5ssd,SW_nsam,0,0)
 rW5se     = escorc_n(w5ssd,mselsd,0,0)
 rW5se_nt  = escorc_n(w5ssd,SE_ntpi,0,0)
 rW5se_ns  = escorc_n(w5ssd,SE_nsam,0,0)

 ; V8
 rV8ts     = escorc_n(v8ssd,mtassd,0,0)
 rV8ts_nt  = escorc_n(v8ssd,TS_ntpi,0,0)
 rV8ts_ns  = escorc_n(v8ssd,TS_nsam,0,0)
 rV8zb     = escorc_n(v8ssd,zbigsd,0,0)
 rV8zb_nt  = escorc_n(v8ssd,ZB_ntpi,0,0)
 rV8zb_ns  = escorc_n(v8ssd,ZB_nsam,0,0)
 rV8sw     = escorc_n(v8ssd,mswlsd,0,0)
 rV8sw_nt  = escorc_n(v8ssd,SW_ntpi,0,0)
 rV8sw_ns  = escorc_n(v8ssd,SW_nsam,0,0)
 rV8se     = escorc_n(v8ssd,mselsd,0,0)
 rV8se_nt  = escorc_n(v8ssd,SE_ntpi,0,0)
 rV8se_ns  = escorc_n(v8ssd,SE_nsam,0,0)

 ; U8
 rU8ts     = escorc_n(u8ssd,mtassd,0,0)
 rU8ts_nt  = escorc_n(u8ssd,TS_ntpi,0,0)
 rU8ts_ns  = escorc_n(u8ssd,TS_nsam,0,0)
 rU8zb     = escorc_n(u8ssd,zbigsd,0,0)
 rU8zb_nt  = escorc_n(u8ssd,ZB_ntpi,0,0)
 rU8zb_ns  = escorc_n(u8ssd,ZB_nsam,0,0)
 rU8sw     = escorc_n(u8ssd,mswlsd,0,0)
 rU8sw_nt  = escorc_n(u8ssd,SW_ntpi,0,0)
 rU8sw_ns  = escorc_n(u8ssd,SW_nsam,0,0)
 rU8se     = escorc_n(u8ssd,mselsd,0,0)
 rU8se_nt  = escorc_n(u8ssd,SE_ntpi,0,0)
 rU8se_ns  = escorc_n(u8ssd,SE_nsam,0,0)

; ------------ significance -----------------
 n        = dimsizes(samsd)
 df       = n-2

 tval     = rW5ts*sqrt((n-2)/(1-rW5ts^2))
 pW5ts    = student_t(tval, df)
 tval     = rW5ts_nt*sqrt((n-2)/(1-rW5ts_nt^2))
 pW5ts_nt = student_t(tval, df)
 tval     = rW5ts_ns*sqrt((n-2)/(1-rW5ts_ns^2))
 pW5ts_ns = student_t(tval, df)
 tval     = rW5zb*sqrt((n-2)/(1-rW5zb^2))
 pW5zb    = student_t(tval, df)
 tval     = rW5zb_nt*sqrt((n-2)/(1-rW5zb_nt^2))
 pW5zb_nt = student_t(tval, df)
 tval     = rW5zb_ns*sqrt((n-2)/(1-rW5zb_ns^2))
 pW5zb_ns = student_t(tval, df)
 tval     = rW5sw*sqrt((n-2)/(1-rW5sw^2))
 pW5sw    = student_t(tval, df)
 tval     = rW5sw_nt*sqrt((n-2)/(1-rW5sw_nt^2))
 pW5sw_nt = student_t(tval, df)
 tval     = rW5sw_ns*sqrt((n-2)/(1-rW5sw_ns^2))
 pW5sw_ns = student_t(tval, df)
 tval     = rW5se*sqrt((n-2)/(1-rW5se^2))
 pW5se    = student_t(tval, df)
 tval     = rW5se_nt*sqrt((n-2)/(1-rW5se_nt^2))
 pW5se_nt = student_t(tval, df)
 tval     = rW5se_ns*sqrt((n-2)/(1-rW5se_ns^2))
 pW5se_ns = student_t(tval, df)

 tval     = rV8ts*sqrt((n-2)/(1-rV8ts^2))
 pV8ts    = student_t(tval, df)
 tval     = rV8ts_nt*sqrt((n-2)/(1-rV8ts_nt^2))
 pV8ts_nt = student_t(tval, df)
 tval     = rV8ts_ns*sqrt((n-2)/(1-rV8ts_ns^2))
 pV8ts_ns = student_t(tval, df)
 tval     = rV8zb*sqrt((n-2)/(1-rV8zb^2))
 pV8zb    = student_t(tval, df)
 tval     = rV8zb_nt*sqrt((n-2)/(1-rV8zb_nt^2))
 pV8zb_nt = student_t(tval, df)
 tval     = rV8zb_ns*sqrt((n-2)/(1-rV8zb_ns^2))
 pV8zb_ns = student_t(tval, df)
 tval     = rV8sw*sqrt((n-2)/(1-rV8sw^2))
 pV8sw    = student_t(tval, df)
 tval     = rV8sw_nt*sqrt((n-2)/(1-rV8sw_nt^2))
 pV8sw_nt = student_t(tval, df)
 tval     = rV8sw_ns*sqrt((n-2)/(1-rV8sw_ns^2))
 pV8sw_ns = student_t(tval, df)
 tval     = rV8se*sqrt((n-2)/(1-rV8se^2))
 pV8se    = student_t(tval, df)
 tval     = rV8se_nt*sqrt((n-2)/(1-rV8se_nt^2))
 pV8se_nt = student_t(tval, df)
 tval     = rV8se_ns*sqrt((n-2)/(1-rV8se_ns^2))
 pV8se_ns = student_t(tval, df)

 tval     = rU8ts*sqrt((n-2)/(1-rU8ts^2))
 pU8ts    = student_t(tval, df)
 tval     = rU8ts_nt*sqrt((n-2)/(1-rU8ts_nt^2))
 pU8ts_nt = student_t(tval, df)
 tval     = rU8ts_ns*sqrt((n-2)/(1-rU8ts_ns^2))
 pU8ts_ns = student_t(tval, df)
 tval     = rU8zb*sqrt((n-2)/(1-rU8zb^2))
 pU8zb    = student_t(tval, df)
 tval     = rU8zb_nt*sqrt((n-2)/(1-rU8zb_nt^2))
 pU8zb_nt = student_t(tval, df)
 tval     = rU8zb_ns*sqrt((n-2)/(1-rU8zb_ns^2))
 pU8zb_ns = student_t(tval, df)
 tval     = rU8sw*sqrt((n-2)/(1-rU8sw^2))
 pU8sw    = student_t(tval, df)
 tval     = rU8sw_nt*sqrt((n-2)/(1-rU8sw_nt^2))
 pU8sw_nt = student_t(tval, df)
 tval     = rU8sw_ns*sqrt((n-2)/(1-rU8sw_ns^2))
 pU8sw_ns = student_t(tval, df)
 tval     = rU8se*sqrt((n-2)/(1-rU8se^2))
 pU8se    = student_t(tval, df)
 tval     = rU8se_nt*sqrt((n-2)/(1-rU8se_nt^2))
 pU8se_nt = student_t(tval, df)
 tval     = rU8se_ns*sqrt((n-2)/(1-rU8se_ns^2))
 pU8se_ns = student_t(tval, df)

 delete(tval)
 delete(df)
 delete(n)
 delete(u8ssd)
 delete(w5ssd)
 delete(v8ssd)
 delete(samsd)
 delete(tpisd)
 delete(mtassd)

 ; check pvalues and format values for output

 if pW5ts.lt.siglvl then
  sW5ts    = sprintf("%5.2f",rW5ts)+"*"
 else
  sW5ts    = sprintf("%5.2f",rW5ts)
 end if
 if pW5ts_nt.lt.siglvl then
  sW5ts_nt = sprintf("%5.2f",rW5ts_nt)+"*"
 else
  sW5ts_nt = sprintf("%5.2f",rW5ts_nt)
 end if
 if pW5ts_ns.lt.siglvl then
  sW5ts_ns = sprintf("%5.2f",rW5ts_ns)+"*"
 else
  sW5ts_ns = sprintf("%5.2f",rW5ts_ns)
 end if
 delete(pW5ts)
 delete(rW5ts)
 delete(pW5ts_nt)
 delete(rW5ts_nt)
 delete(pW5ts_ns)
 delete(rW5ts_ns)
 if pW5zb.lt.siglvl then
  sW5zb    = sprintf("%5.2f",rW5zb)+"*"
 else
  sW5zb    = sprintf("%5.2f",rW5zb)
 end if
 if pW5zb_nt.lt.siglvl then
  sW5zb_nt = sprintf("%5.2f",rW5zb_nt)+"*"
 else
  sW5zb_nt = sprintf("%5.2f",rW5zb_nt)
 end if
 if pW5zb_ns.lt.siglvl then
  sW5zb_ns = sprintf("%5.2f",rW5zb_ns)+"*"
 else
  sW5zb_ns = sprintf("%5.2f",rW5zb_ns)
 end if
 delete(pW5zb)
 delete(rW5zb)
 delete(pW5zb_nt)
 delete(rW5zb_nt)
 delete(pW5zb_ns)
 delete(rW5zb_ns)
 if pW5sw.lt.siglvl then
  sW5sw    = sprintf("%5.2f",rW5sw)+"*"
 else
  sW5sw    = sprintf("%5.2f",rW5sw)
 end if
 if pW5sw_nt.lt.siglvl then
  sW5sw_nt = sprintf("%5.2f",rW5sw_nt)+"*"
 else
  sW5sw_nt = sprintf("%5.2f",rW5sw_nt)
 end if
 if pW5sw_ns.lt.siglvl then
  sW5sw_ns = sprintf("%5.2f",rW5sw_ns)+"*"
 else
  sW5sw_ns = sprintf("%5.2f",rW5sw_ns)
 end if
 delete(pW5sw)
 delete(rW5sw)
 delete(pW5sw_nt)
 delete(rW5sw_nt)
 delete(pW5sw_ns)
 delete(rW5sw_ns)
 if pW5se.lt.siglvl then
  sW5se    = sprintf("%5.2f",rW5se)+"*"
 else
  sW5se    = sprintf("%5.2f",rW5se)
 end if    
 if pW5se_nt.lt.siglvl then
  sW5se_nt = sprintf("%5.2f",rW5se_nt)+"*"
 else
  sW5se_nt = sprintf("%5.2f",rW5se_nt)
 end if    
 if pW5se_ns.lt.siglvl then
  sW5se_ns = sprintf("%5.2f",rW5se_ns)+"*"
 else
  sW5se_ns = sprintf("%5.2f",rW5se_ns)
 end if    
 delete(pW5se)
 delete(rW5se)
 delete(pW5se_nt)
 delete(rW5se_nt)
 delete(pW5se_ns)
 delete(rW5se_ns)

 if pV8ts.lt.siglvl then
  sV8ts    = sprintf("%5.2f",rV8ts)+"*"
 else
  sV8ts    = sprintf("%5.2f",rV8ts)
 end if
 if pV8ts_nt.lt.siglvl then
  sV8ts_nt = sprintf("%5.2f",rV8ts_nt)+"*"
 else
  sV8ts_nt = sprintf("%5.2f",rV8ts_nt)
 end if
 if pV8ts_ns.lt.siglvl then
  sV8ts_ns = sprintf("%5.2f",rV8ts_ns)+"*"
 else
  sV8ts_ns = sprintf("%5.2f",rV8ts_ns)
 end if
 delete(pV8ts)
 delete(rV8ts)
 delete(pV8ts_nt)
 delete(rV8ts_nt)
 delete(pV8ts_ns)
 delete(rV8ts_ns)
 if pV8zb.lt.siglvl then
  sV8zb    = sprintf("%5.2f",rV8zb)+"*"
 else
  sV8zb    = sprintf("%5.2f",rV8zb)
 end if
 if pV8zb_nt.lt.siglvl then
  sV8zb_nt = sprintf("%5.2f",rV8zb_nt)+"*"
 else
  sV8zb_nt = sprintf("%5.2f",rV8zb_nt)
 end if
 if pV8zb_ns.lt.siglvl then
  sV8zb_ns = sprintf("%5.2f",rV8zb_ns)+"*"
 else
  sV8zb_ns = sprintf("%5.2f",rV8zb_ns)
 end if
 delete(pV8zb)
 delete(rV8zb)
 delete(pV8zb_nt)
 delete(rV8zb_nt)
 delete(pV8zb_ns)
 delete(rV8zb_ns)
 if pV8sw.lt.siglvl then
  sV8sw    = sprintf("%5.2f",rV8sw)+"*"
 else
  sV8sw    = sprintf("%5.2f",rV8sw)
 end if
 if pV8sw_nt.lt.siglvl then
  sV8sw_nt = sprintf("%5.2f",rV8sw_nt)+"*"
 else
  sV8sw_nt = sprintf("%5.2f",rV8sw_nt)
 end if
 if pV8sw_ns.lt.siglvl then
  sV8sw_ns = sprintf("%5.2f",rV8sw_ns)+"*"
 else
  sV8sw_ns = sprintf("%5.2f",rV8sw_ns)
 end if
 delete(pV8sw)
 delete(rV8sw)
 delete(pV8sw_nt)
 delete(rV8sw_nt)
 delete(pV8sw_ns)
 delete(rV8sw_ns)
 if pV8se.lt.siglvl then
  sV8se    = sprintf("%5.2f",rV8se)+"*"
 else
  sV8se    = sprintf("%5.2f",rV8se)
 end if
 if pV8se_nt.lt.siglvl then
  sV8se_nt = sprintf("%5.2f",rV8se_nt)+"*"
 else
  sV8se_nt = sprintf("%5.2f",rV8se_nt)
 end if
 if pV8se_ns.lt.siglvl then
  sV8se_ns = sprintf("%5.2f",rV8se_ns)+"*"
 else
  sV8se_ns = sprintf("%5.2f",rV8se_ns)
 end if
 delete(pV8se)
 delete(rV8se)
 delete(pV8se_nt)
 delete(rV8se_nt)
 delete(pV8se_ns)
 delete(rV8se_ns)

 if pU8ts.lt.siglvl then
  sU8ts    = sprintf("%5.2f",rU8ts)+"*"
 else
  sU8ts    = sprintf("%5.2f",rU8ts)
 end if
 if pU8ts_nt.lt.siglvl then
  sU8ts_nt = sprintf("%5.2f",rU8ts_nt)+"*"
 else
  sU8ts_nt = sprintf("%5.2f",rU8ts_nt)
 end if
 if pU8ts_ns.lt.siglvl then
  sU8ts_ns = sprintf("%5.2f",rU8ts_ns)+"*"
 else
  sU8ts_ns = sprintf("%5.2f",rU8ts_ns)
 end if
 delete(pU8ts)
 delete(rU8ts)
 delete(pU8ts_nt)
 delete(rU8ts_nt)
 delete(pU8ts_ns)
 delete(rU8ts_ns)
 if pU8zb.lt.siglvl then
  sU8zb    = sprintf("%5.2f",rU8zb)+"*"
 else
  sU8zb    = sprintf("%5.2f",rU8zb)
 end if
 if pU8zb_nt.lt.siglvl then
  sU8zb_nt = sprintf("%5.2f",rU8zb_nt)+"*"
 else
  sU8zb_nt = sprintf("%5.2f",rU8zb_nt)
 end if
 if pU8zb_ns.lt.siglvl then
  sU8zb_ns = sprintf("%5.2f",rU8zb_ns)+"*"
 else
  sU8zb_ns = sprintf("%5.2f",rU8zb_ns)
 end if
 delete(pU8zb)
 delete(rU8zb)
 delete(pU8zb_nt)
 delete(rU8zb_nt)
 delete(pU8zb_ns)
 delete(rU8zb_ns)
 if pU8sw.lt.siglvl then
  sU8sw    = sprintf("%5.2f",rU8sw)+"*"
 else
  sU8sw    = sprintf("%5.2f",rU8sw)
 end if
 if pU8sw_nt.lt.siglvl then
  sU8sw_nt = sprintf("%5.2f",rU8sw_nt)+"*"
 else
  sU8sw_nt = sprintf("%5.2f",rU8sw_nt)
 end if
 if pU8sw_ns.lt.siglvl then
  sU8sw_ns = sprintf("%5.2f",rU8sw_ns)+"*"
 else
  sU8sw_ns = sprintf("%5.2f",rU8sw_ns)
 end if
 delete(pU8sw)
 delete(rU8sw)
 delete(pU8sw_nt)
 delete(rU8sw_nt)
 delete(pU8sw_ns)
 delete(rU8sw_ns)
 if pU8se.lt.siglvl then
  sU8se    = sprintf("%5.2f",rU8se)+"*"
 else
  sU8se    = sprintf("%5.2f",rU8se)
 end if
 if pU8se_nt.lt.siglvl then
  sU8se_nt = sprintf("%5.2f",rU8se_nt)+"*"
 else
  sU8se_nt = sprintf("%5.2f",rU8se_nt)
 end if
 if pU8se_ns.lt.siglvl then
  sU8se_ns = sprintf("%5.2f",rU8se_ns)+"*"
 else
  sU8se_ns = sprintf("%5.2f",rU8se_ns)
 end if
 delete(pU8se)
 delete(rU8se)
 delete(pU8se_nt)
 delete(rU8se_nt)
 delete(pU8se_ns)
 delete(rU8se_ns)



 print(month +" TS TSns TSnt ZB ZBns ZBnt SW SWns SWnt SE SEns SEnt")
 print("W5"+" "+sW5ts+" "+sW5ts_ns+" "+sW5ts_nt+" "+sW5zb+" "+sW5zb_ns+" "+sW5zb_nt+" "+sW5sw+" "+sW5sw_ns+" "+sW5sw_nt+" "+sW5se+" "+sW5se_ns+" "+sW5se_nt) 
 print("V8"+" "+sV8ts+" "+sV8ts_ns+" "+sV8ts_nt+" "+sV8zb+" "+sV8zb_ns+" "+sV8zb_nt+" "+sV8sw+" "+sV8sw_ns+" "+sV8sw_nt+" "+sV8se+" "+sV8se_ns+" "+sV8se_nt) 
 print("U8"+" "+sU8ts+" "+sU8ts_ns+" "+sU8ts_nt+" "+sU8zb+" "+sU8zb_ns+" "+sU8zb_nt+" "+sU8sw+" "+sU8sw_ns+" "+sU8sw_nt+" "+sU8se+" "+sU8se_ns+" "+sU8se_nt) 
 end do		; month loop






end



