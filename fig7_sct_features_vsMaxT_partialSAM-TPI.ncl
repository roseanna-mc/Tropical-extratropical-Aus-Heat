; 27/6/21
; Usage NCL

; Update to remove Tasman, and to try removing SAM and TPI from features, not maxT
; (should give the same answer, but cleaner order this way)
; -> it did make very slight changes, but nothing that changed the story

; Correlates features vs Max T, partial MaxT (no SAM, no TPI)
; uses era 5 data for features and mechs
; plots to scatter plot

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

;-------------------------- File options -----------------------
 outType = "png"
 obsDir  = "/g/data/w97/rm8168/data/obs/"
 outDir  = "/g/data3/w97/rm8168/data/tropVextrop/withWS/"
 erDir   = "/g/data/w97/rm8168/data/tropVextrop/timeseries/"
;------------------ Get data ---------------------

 sfil   = erDir + "1979_2019_ERA5_SWLx-1_S-O-N_timeseries"
 ncol   = 3                    ; S O N
 nrows  = (2019 - 1979) +1
 allsw  = asciiread(sfil,(/nrows,ncol/),"float")        ;[492] x [3]
 ;printVarSummary(allsw)
 delete(sfil)
 allsw@_FillValue = 9.96921e+36

 sfil   = erDir + "1979_2019_ERA5_SELx-1_S-O-N_timeseries"
 ncol   = 3                    ; S O N
 nrows  = (2019 - 1979) +1
 allse  = asciiread(sfil,(/nrows,ncol/),"float")        ;[492] x [3]
 ;printVarSummary(allse)
 delete(sfil)
 allse@_FillValue = 9.96921e+36
 
 sfil   = erDir + "1979_2019_ERA5_ZB_S-O-N_timeseries"
 ncol   = 3                    ; S O N
 nrows  = (2019 - 1979) +1
 allzb  = asciiread(sfil,(/nrows,ncol/),"float")        ;[492] x [3]
 ;printVarSummary(allzb)
 delete(sfil)
 allzb@_FillValue = 9.96921e+36

  ; max T time series
  mtfil  = obsDir + "1979_2019_A_SW_SE_N_maxT.txt"
  ncol   = 6                    ; yrs, ms, aus, sw, se, n
  nrows  = (2019 - 1979)*12 + 12
  allmt  = asciiread(mtfil,(/nrows,ncol/),"float")
  ;printVarSummary(allmt)                ; [491] x [6]
  Amts   = allmt(moStrtE:moStopE,2)
  SWmts  = allmt(moStrtE:moStopE,3)
  SEmts  = allmt(moStrtE:moStopE,4)
  Nmts   = allmt(moStrtE:moStopE,5)
  delete(mtfil)
  delete(ncol)
  delete(nrows)
  ;printVarSummary(Amts)

  ; era5 sam time series
  sfil   = obsDir + "1979_2019_era5_sam_x1.txt"
  ncol   = 3                    ; years, months, sam
  nrows  = (2019 - 1979)*12 + 12
  allsam = asciiread(sfil,(/nrows,ncol/),"float")
  sams   = (allsam(moStrtE:moStopE,2))*-1.
  delete(sfil)
  delete(ncol)
  delete(nrows)
  ;printVarSummary(sams)
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


do re      = 0, dimsizes(regions)-1
 region    = regions(re)
  regionSt = regionSts(re)

  if region.eq."Aus" then
   print("region is "+region)
   mt      = Amts
  else if region.eq."SW" then
   print("region is "+region)
   mt      = SWmts
  else if region.eq."SE" then
   print("region is "+region)
   mt      = SEmts
  else if region.eq."N" then
   print("region is "+region)
   mt      = Nmts
  end if
  end if
  end if
  end if

  ZBsi    = allzb(0:2,0)	; dummy array to hold sig/not sig cor with max T vs features/partials
  ZBsi    = 0.
  ZBnsi   = ZBsi	; ZB not sig
  ZBnssi  = ZBsi	; ZB no SAM sig
  ZBnsnsi = ZBsi	; ZB no SAM not sig
  ZBntsi  = ZBsi 	; ZB no TPI sig
  ZBntnsi = ZBsi	; ZB no TPI not sig
  SEsi    = ZBsi
  SEnsi   = ZBsi 
  SEnssi  = ZBsi
  SEnsnsi = ZBsi 
  SEntsi  = ZBsi
  SEntnsi = ZBsi  
  SWsi    = ZBsi
  SWnsi   = ZBsi 
  SWnssi  = ZBsi
  SWnsnsi = ZBsi  
  SWntsi  = ZBsi
  SWntnsi = ZBsi
  ;printVarSummary(ZBsi)	; [3]

 do m    = 0, dimsizes(mons)-1 ; loop through months
  mon    = mons(m)        ; for files
  month  = months(m)      ; for titles

  M      = m + 8

   tam     = mt(M::12)
   zbigm   = allzb(:,m)
   mswlm   = allsw(:,m)
   mselm   = allse(:,m)
   tpi     = tpis(M::12)
   sam     = sams(M::12)

 ; ------- detrend ------
  tad    = tam
  zbigd  = zbigm
  mswld  = mswlm
  mseld  = mselm
  samd   = sam
  tpid   = tpi
  if dtrnd.eq."True" then
   x     = ispan(1, dimsizes(tam(:)), 1)
   ;printVarSummary(x)
   tad   = dtrend_msg_n(x,tam,False,False,0)
   zbigd = dtrend_msg_n(x,zbigm,False,False,0)
   mswld = dtrend_msg_n(x,mswlm,False,False,0)
   mseld = dtrend_msg_n(x,mselm,False,False,0)
   samd  = dtrend_msg_n(x,sam,False,False,0)
   tpid  = dtrend_msg_n(x,tpi,False,False,0)
   copy_VarMeta(tam,tad)
   copy_VarMeta(zbigm, zbigd)
   copy_VarMeta(mswlm, mswld)
   copy_VarMeta(mselm, mseld)
   delete(x)
  end if
  delete(tam)
  delete(zbigm)
  delete(mswlm)
  delete(mselm)
  delete(sam)
  delete(tpi)

  zbigsd  = zbigd
  mswlsd  = mswld
  mselsd  = mseld
  samsd   = samd
  tpisd   = tpid
  tasd    = tad
  if stdise.eq."True" then
   ;print("standardising drivers")
   zbigsd = dim_standardize_n_Wrap(zbigd,0,0)
   mswlsd = dim_standardize_n_Wrap(mswld,0,0)
   mselsd = dim_standardize_n_Wrap(mseld,0,0)
   samsd  = dim_standardize_n_Wrap(samd,0,0)
   tpisd  = dim_standardize_n_Wrap(tpid,0,0)
   tasd   = dim_standardize_n_Wrap(tad,0,0)
  end if
  delete(tad)
  delete(zbigd)
  delete(mswld)
  delete(mseld)
  delete(samd)
  delete(tpid)

;  calculating partials
  ntim   = dimsizes(zbigsd)

  ; dummy arrays for maxT associated with drivers ( ~ reg coef x tpi = maxt)
  ; i.e. how much of each max T was 'because' of each driver per year?
  ZBtpi = new( dimsizes(zbigsd), typeof(zbigsd), zbigsd@_FillValue)
  ZBsam = new( dimsizes(zbigsd), typeof(zbigsd), zbigsd@_FillValue)
  SWtpi = ZBtpi
  SWsam = ZBtpi
  SEtpi = ZBtpi
  SEsam = ZBtpi

  ;create array for the 2 predictors (tpi, sam)
  xp      = new((/ntim,2/),typeof(tpisd))
  xp(:,0) = tpisd
  xp(:,1) = samsd
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
   ZBtpi(yr) = rcZBtpi*tpisd(yr)
   ZBsam(yr) = rcZBsam*samsd(yr)
   SWtpi(yr) = rcSWtpi*tpisd(yr)
   SWsam(yr) = rcSWsam*samsd(yr)
   SEtpi(yr) = rcSEtpi*tpisd(yr)
   SEsam(yr) = rcSEsam*samsd(yr)
  end do
  delete(rcZBtpi)
  delete(rcZBsam)
  delete(rcSWtpi)
  delete(rcSWsam)
  delete(rcSEtpi)
  delete(rcSEsam)

  ; calculate proportion of variables not associated with drivers
  ZB_ntpi  = zbigsd - ZBtpi
  ZB_nsam  = zbigsd - ZBsam
  SW_ntpi  = mswlsd - SWtpi
  SW_nsam  = mswlsd - SWsam
  SE_ntpi  = mselsd - SEtpi
  SE_nsam  = mselsd - SEsam
  delete(ZBtpi)
  delete(ZBsam)
  delete(SWtpi)
  delete(SWsam)
  delete(SEtpi)
  delete(SEsam)

 ; Z
 rZBmt     = escorc_n(zbigsd,tasd,0,0)
 rZBmt_ns  = escorc_n(ZB_nsam,tasd,0,0)
 rZBmt_nt  = escorc_n(ZB_ntpi,tasd,0,0)

 ; SW
 rSWmt     = escorc_n(mswlsd,tasd,0,0)
 rSWmt_ns  = escorc_n(SW_nsam,tasd,0,0)
 rSWmt_nt  = escorc_n(SW_ntpi,tasd,0,0)

 ; SE
 rSEmt     = escorc_n(mselsd,tasd,0,0)
 rSEmt_ns  = escorc_n(SE_nsam,tasd,0,0)
 rSEmt_nt  = escorc_n(SE_ntpi,tasd,0,0)


; ------------ significance -----------------
 n        = dimsizes(samsd)
 df       = n-2

 tval     = rZBmt*sqrt((n-2)/(1-rZBmt^2))
 pZBmt    = student_t(tval, df)
 tval     = rZBmt_ns*sqrt((n-2)/(1-rZBmt_ns^2))
 pZBmt_ns = student_t(tval, df)
 tval     = rZBmt_nt*sqrt((n-2)/(1-rZBmt_nt^2))
 pZBmt_nt = student_t(tval, df)
 delete(tval)

 tval     = rSWmt*sqrt((n-2)/(1-rSWmt^2))
 pSWmt    = student_t(tval, df)
 tval     = rSWmt_ns*sqrt((n-2)/(1-rSWmt_ns^2))
 pSWmt_ns = student_t(tval, df)
 tval     = rSWmt_nt*sqrt((n-2)/(1-rSWmt_nt^2))
 pSWmt_nt = student_t(tval, df)
 delete(tval)

 tval     = rSEmt*sqrt((n-2)/(1-rSEmt^2))
 pSEmt    = student_t(tval, df)
 tval     = rSEmt_ns*sqrt((n-2)/(1-rSEmt_ns^2))
 pSEmt_ns = student_t(tval, df)
 tval     = rSEmt_nt*sqrt((n-2)/(1-rSEmt_nt^2))
 pSEmt_nt = student_t(tval, df)
 delete(tval)

 delete(df)
 delete(n)
 delete(zbigsd)
 delete(mswlsd)
 delete(mselsd)
 delete(samsd)
 delete(tpisd)
 delete(tasd)

 ; check pvalues and format values for output
 if pZBmt.lt.siglvl then
  ZBsi(m)  = rZBmt
  ZBnsi(m) = allsw@_FillValue
 else
  ZBnsi(m)  = rZBmt
  ZBsi(m)   = allsw@_FillValue
 end if
 if pZBmt_ns.lt.siglvl then
  ZBnssi(m)  = rZBmt_ns
  ZBnsnsi(m) = allsw@_FillValue
 else
  ZBnsnsi(m) = rZBmt_ns
  ZBnssi(m)  = allsw@_FillValue
 end if
 if pZBmt_nt.lt.siglvl then
  ZBntsi(m)  = rZBmt_nt
  ZBntnsi(m) = allsw@_FillValue
 else
  ZBntnsi(m) = rZBmt_nt
  ZBntsi(m)  = allsw@_FillValue
 end if
 delete(rZBmt)
 delete(rZBmt_ns)
 delete(rZBmt_nt)
 delete(pZBmt)
 delete(pZBmt_ns)
 delete(pZBmt_nt)

 if pSEmt.lt.siglvl then
  SEsi(m)  = rSEmt
  SEnsi(m) = allsw@_FillValue
 else
  SEnsi(m)  = rSEmt
  SEsi(m)   = allsw@_FillValue
 end if
 if pSEmt_ns.lt.siglvl then
  SEnssi(m)  = rSEmt_ns
  SEnsnsi(m) = allsw@_FillValue
 else
  SEnsnsi(m) = rSEmt_ns
  SEnssi(m)  = allsw@_FillValue
 end if
 if pSEmt_nt.lt.siglvl then
  SEntsi(m)  = rSEmt_nt
  SEntnsi(m) = allsw@_FillValue
 else
  SEntnsi(m) = rSEmt_nt
  SEntsi(m)  = allsw@_FillValue
 end if
 delete(rSEmt)
 delete(rSEmt_ns)
 delete(rSEmt_nt)
 delete(pSEmt)
 delete(pSEmt_ns)
 delete(pSEmt_nt)

 if pSWmt.lt.siglvl then
  SWsi(m)  = rSWmt
  SWnsi(m) = allsw@_FillValue
 else
  SWnsi(m)  = rSWmt
  SWsi(m)   = allsw@_FillValue
 end if
 if pSWmt_ns.lt.siglvl then
  SWnssi(m)  = rSWmt_ns
  SWnsnsi(m) = allsw@_FillValue
 else
  SWnsnsi(m) = rSWmt_ns
  SWnssi(m)  = allsw@_FillValue
 end if
 if pSWmt_nt.lt.siglvl then
  SWntsi(m)  = rSWmt_nt
  SWntnsi(m) = allsw@_FillValue
 else
  SWntnsi(m) = rSWmt_nt
  SWntsi(m)  = allsw@_FillValue
 end if
 delete(rSWmt)
 delete(rSWmt_ns)
 delete(rSWmt_nt)
 delete(pSWmt)
 delete(pSWmt_ns)
 delete(pSWmt_nt)

 end do		; month loop
  ; ------------ Plotting ------------
 outPath   = outDir + "ERA5_feats_noTas_VS"+region+"maxT-partialSAM-TPI_nolegend_siglvl"+siglvl
 wks       = gsn_open_wks(outType, outPath)

 data      = new( (/18,3/), float)
 data(0,:) = ZBsi
 data(1,:) = ZBnssi 
 data(2,:) = ZBntsi
 data(3,:) = ZBnsi
 data(4,:) = ZBnsnsi
 data(5,:) = ZBntnsi

 data(6,:)  = SEsi
 data(7,:)  = SEnssi
 data(8,:)  = SEntsi
 data(9,:)  = SEnsi
 data(10,:) = SEnsnsi
 data(11,:) = SEntnsi

 data(12,:) = SWsi
 data(13,:) = SWnssi
 data(14,:) = SWntsi
 data(15,:) = SWnsi
 data(16,:) = SWnsnsi
 data(17,:) = SWntnsi


 res                   = True
 resZBsi               = True
 resSEsi               = True
 resSWsi               = True
 resZBnsi              = True
 resSEnsi              = True
 resSWnsi              = True

 res@xyDashPattern     = 0                ; Make curves all solid
 res@xyMarkLineModes   = "Markers"        ; markers not lines

 monvals               = ispan(1,3,1) 
 res@tmXBMode          = "Explicit"              ; explicit labels
 res@tmXBValues        = monvals                 ; location of labels
 res@tmXBLabels        = mons                    ; labels themselves
 res@tmLabelAutoStride = True                    ; nice stride on labels
 res@tiYAxisAngleF    = 90.
 res@tiYAxisString    = "Correlation with circulation features"

 res@vpHeightF= 0.7                    ; change aspect ratio of plot
 res@vpWidthF = 0.2
 ; since we stretch the plot, we need to slide it over a bit so it does not
 ; run off the page. we do this by:
 ;res@vpXF     = 0.1                   ; start plot at x ndc coord
 res@gsnMaximize = True
 
 res@trYMinF  = -.05                   ; min value on y-axis
 res@trYMaxF  = 0.8                   ; max value on y-axis
 res@trXMinF  = .7                    ; min and max on x-axis slightly before values for
 res@trXMaxF  = 3.3                   ; clearer plotting

 res@gsnFrame = False              ; don't advance frame yet

 ; copy over common resources
 res@xyMarkerThicknessF = 12.      ; make markers thicker
 res@xyMarkerSizeF     = 0.03      ; make markers bigger (0.01 is default)
 resZBsi               = res 
 resSEsi               = res
 resSWsi               = res
 res@xyMarkerThicknessF = 4
 resZBnsi              = res
 resSEnsi              = res
 resSWnsi              = res
						;x,y offset,default aspect, size and angle
 resZBsi@xyMarker      = 12 ; NhlNewMarker(wks,"z",35,0.,0.,1.,1.,0.)	; solid star
 resSEsi@xyMarker      = 6  ; NhlNewMarker(wks,"y",35,0.,0.,1.,1.,0.)	; solid square
 resSWsi@xyMarker      = 4  ; 16					; solid circle
 resZBnsi@xyMarker     = 12						; hollow star
 resSEnsi@xyMarker     = 6                                              ; hollow square 
 resSWnsi@xyMarker     = 4                                              ; hollow circle

 mtCol		 	= "red"
 tpCol			= "darkturquoise"; "blue"
 saCol			= "darkorchid4"; "purple"
 
 resZBsi@xyMarkerColor  = saCol
 resSEsi@xyMarkerColor  = saCol
 resSWsi@xyMarkerColor  = saCol
 resZBnsi@xyMarkerColor = saCol
 resSEnsi@xyMarkerColor = saCol
 resSWnsi@xyMarkerColor = saCol
 plot  = gsn_csm_xy(wks,monvals,data(1,:),resZBsi)
 plot  = gsn_csm_xy(wks,monvals,data(4,:),resZBnsi)
 plot  = gsn_csm_xy(wks,monvals,data(7,:),resSEsi)
 plot  = gsn_csm_xy(wks,monvals,data(10,:),resSEnsi)
 plot  = gsn_csm_xy(wks,monvals,data(13,:),resSWsi)
 plot  = gsn_csm_xy(wks,monvals,data(16,:),resSWnsi)

 resZBsi@xyMarkerColor  = tpCol
 resSEsi@xyMarkerColor  = tpCol
 resSWsi@xyMarkerColor  = tpCol
 resZBnsi@xyMarkerColor = tpCol
 resSEnsi@xyMarkerColor = tpCol
 resSWnsi@xyMarkerColor = tpCol
 plot  = gsn_csm_xy(wks,monvals,data(2,:),resZBsi)
 plot  = gsn_csm_xy(wks,monvals,data(5,:),resZBnsi)
 plot  = gsn_csm_xy(wks,monvals,data(8,:),resSEsi)
 plot  = gsn_csm_xy(wks,monvals,data(11,:),resSEnsi)
 plot  = gsn_csm_xy(wks,monvals,data(14,:),resSWsi)
 plot  = gsn_csm_xy(wks,monvals,data(17,:),resSWnsi)

 res@xyMarkerSizeF     = 0.027 
 resZBsi@xyMarkerColor  = mtCol
 resSEsi@xyMarkerColor  = mtCol
 resSWsi@xyMarkerColor  = mtCol
 resZBnsi@xyMarkerColor = mtCol
 resSEnsi@xyMarkerColor = mtCol
 resSWnsi@xyMarkerColor = mtCol
 plot  = gsn_csm_xy(wks,monvals,data(0,:),resZBsi)
 plot  = gsn_csm_xy(wks,monvals,data(3,:),resZBnsi)
 plot  = gsn_csm_xy(wks,monvals,data(6,:),resSEsi)
 plot  = gsn_csm_xy(wks,monvals,data(9,:),resSEnsi)
 plot  = gsn_csm_xy(wks,monvals,data(12,:),resSWsi)
 plot  = gsn_csm_xy(wks,monvals,data(15,:),resSWnsi)

/;
 ; legend
 labels = (/" SAA "," SWC    ","  SEC  "/)                         ; don't want labels
 lgres                    = True

 lgres@vpWidthF           = 0.25                   ; width of legend (NDC)
 lgres@vpHeightF          = 0.15                   ; height of legend (NDC)
 lgres@lgLabelAlignment	  = "ItemCenters"	; default is Item Centers, also have AboveItems
 lgres@lgTitleString      = "" 
 lgres@lgItemType         = "Markers"
 lgres@xyMarkLineModes    = "Markers"           ; markers not lines
 lgres@lgMarkerSizeF      = 0.023                ; maker bigger
 lgres@lgMarkerIndexes    = (/12,4,6/)          ; marker indexes
 lgres@lgMarkerThicknessF  = 5.
 lgres@lgMarkerColors     = (/"black","black","black"/) ; marker colors
 ;lgres@xyExplicitLegendLabels = labels
 lgres@lgMonoItemType     = True                  ; only want markers
 
 lgres@lgAutoManage       = False
 lgres@lgLabelFontHeightF = 0.03
 lgres@lgLabelAngleF      = 0.

 lgres@lgPerimOn          = False               ; turn off box
 lgres@lgOrientation      = "horizontal"		;"horizontal"
;
; Draw the legend, indicating the number of items, a label for each
; item, and the X, Y position of the legend in NDC coordinates.
; gsn_legend_ndc uses ndc grid (0,0) = lower left; (1,1) = top right
 gsn_legend_ndc(wks,3,labels,0.1,.1,lgres)

 labels2 = (/"max. T. "," no SAM   "," no TPI "/)
 lgres@lgItemType         = "Markers"
 lgres@xyMarkLineModes    = "Markers"
 lgres@lgMarkerIndexes    = (/16,16,16/)          ; marker indexes 
 lgres@lgMarkerColors     = (/mtCol,saCol,tpCol/) ; marker colors
 gsn_legend_ndc(wks,3,labels2,.1,.2,lgres)

 drawNDCGrid(wks)
;/

 frame(wks)
 
;break
end do		;region loop








end



