; 27/6/21
; Usage NCL

; Changing partial correlatoins to remove SAM TPI from mechs, not maxT
; legend is now for features, mechs and to indicate partial/full maxT
; (currently manually combining this figure wiht hte features correlation plot)

; Correlates mechanisms vs Max T, partial MaxT (no SAM, no TPI)
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

  U8si    = allu8(0:2,0)	; dummy array to hold sig/not sig cor with max T vs features/partials
  U8si    = 0.
  U8nsi   = U8si	; U8 not sig
  U8nssi  = U8si	; U8 no SAM sig
  U8nsnsi = U8si	; U8 no SAM not sig
  U8ntsi  = U8si 	; U8 no TPI sig
  U8ntnsi = U8si	; U8 no TPI not sig
  W5si    = U8si
  W5nsi   = U8si 
  W5nssi  = U8si
  W5nsnsi = U8si 
  W5ntsi  = U8si
  W5ntnsi = U8si  
  V8si    = U8si
  V8nsi   = U8si 
  V8nssi  = U8si
  V8nsnsi = U8si  
  V8ntsi  = U8si
  V8ntnsi = U8si
  ;printVarSummary(U8si)	; [3]

 do m    = 0, dimsizes(mons)-1 ; loop through months
  mon    = mons(m)        ; for files
  month  = months(m)      ; for titles

  M      = m + 8

   tam     = mt(M::12)
   u8m   = allu8(:,m)
   v8m   = allv8(:,m)
   w5m   = allw5(:,m)
   tpi     = tpis(M::12)
   sam     = sams(M::12)

 ; ------- detrend ------
  tad    = tam
  u8d    = u8m
  v8d    = v8m
  w5d    = w5m
  samd   = sam
  tpid   = tpi
  if dtrnd.eq."True" then
   x     = ispan(1, dimsizes(tam(:)), 1)
   ;printVarSummary(x)
   tad   = dtrend_msg_n(x,tam,False,False,0)
   u8d = dtrend_msg_n(x,u8m,False,False,0)
   v8d = dtrend_msg_n(x,v8m,False,False,0)
   w5d = dtrend_msg_n(x,w5m,False,False,0)
   samd  = dtrend_msg_n(x,sam,False,False,0)
   tpid  = dtrend_msg_n(x,tpi,False,False,0)
   copy_VarMeta(tam,tad)
   copy_VarMeta(u8m, u8d)
   copy_VarMeta(v8m, v8d)
   copy_VarMeta(w5m, w5d)
   delete(x)
  end if
  delete(tam)
  delete(u8m)
  delete(v8m)
  delete(w5m)
  delete(sam)
  delete(tpi)

  u8sd    = u8d
  v8sd    = v8d
  w5sd    = w5d
  samsd   = samd
  tpisd   = tpid
  tasd    = tad
  if stdise.eq."True" then
   ;print("standardising drivers")
   u8sd   = dim_standardize_n_Wrap(u8d,0,0)
   v8sd   = dim_standardize_n_Wrap(v8d,0,0)
   w5sd   = dim_standardize_n_Wrap(w5d,0,0)
   samsd  = dim_standardize_n_Wrap(samd,0,0)
   tpisd  = dim_standardize_n_Wrap(tpid,0,0)
   tasd   = dim_standardize_n_Wrap(tad,0,0)
  end if
  delete(tad)
  delete(u8d)
  delete(v8d)
  delete(w5d)
  delete(samd)
  delete(tpid)

;  calculating partials
  ntim   = dimsizes(u8sd)

  ; dummy arrays for maxT associated with drivers ( ~ reg coef x tpi = maxt)
  ; i.e. how much of each max T was 'because' of each driver per year?
  U8tpi = new( dimsizes(u8sd), typeof(u8sd), u8sd@_FillValue)
  U8sam = new( dimsizes(u8sd), typeof(u8sd), u8sd@_FillValue)
  V8tpi = U8tpi
  V8sam = U8tpi
  W5tpi = U8tpi
  W5sam = U8tpi

  ;create array for the 2 predictors (tpi, sam)
  xp      = new((/ntim,2/),typeof(tpisd))
  xp(:,0) = tpisd
  xp(:,1) = samsd
  bt      = reg_multlin_stats(u8sd,xp,True)
  rcU8tpi = bt(1)
  rcU8sam = bt(2)
  delete(bt)
  bt      = reg_multlin_stats(v8sd,xp,True)
  rcV8tpi = bt(1)
  rcV8sam = bt(2)
  delete(bt)
  bt      = reg_multlin_stats(w5sd,xp,True)
  rcW5tpi = bt(1)
  rcW5sam = bt(2)
  delete(bt)
  delete(xp)

  ; calculate proportion of variables associated with drivers each year
  ; y = mx + c
  do yr = 0,ntim-1
   U8tpi(yr) = rcU8tpi*tpisd(yr)
   U8sam(yr) = rcU8sam*samsd(yr)
   V8tpi(yr) = rcV8tpi*tpisd(yr)
   V8sam(yr) = rcV8sam*samsd(yr)
   W5tpi(yr) = rcW5tpi*tpisd(yr)
   W5sam(yr) = rcW5sam*samsd(yr)
  end do
  delete(rcU8tpi)
  delete(rcU8sam)
  delete(rcV8tpi)
  delete(rcV8sam)
  delete(rcW5tpi)
  delete(rcW5sam)

  ; calculate proportion of variables not associated with drivers
  U8_ntpi  = u8sd - U8tpi
  U8_nsam  = u8sd - U8sam
  V8_ntpi  = v8sd - V8tpi
  V8_nsam  = v8sd - V8sam
  W5_ntpi  = w5sd - W5tpi
  W5_nsam  = w5sd - W5sam
  delete(U8tpi)
  delete(U8sam)
  delete(V8tpi)
  delete(V8sam)
  delete(W5tpi)
  delete(W5sam)

 ; Z
 rU8mt     = escorc_n(u8sd,tasd,0,0)
 rU8mt_ns  = escorc_n(U8_nsam,tasd,0,0)
 rU8mt_nt  = escorc_n(U8_ntpi,tasd,0,0)

 ; V8
 rV8mt     = escorc_n(v8sd,tasd,0,0)
 rV8mt_ns  = escorc_n(V8_nsam,tasd,0,0)
 rV8mt_nt  = escorc_n(V8_ntpi,tasd,0,0)

 ; W5
 rW5mt     = escorc_n(w5sd,tasd,0,0)
 rW5mt_ns  = escorc_n(W5_nsam,tasd,0,0)
 rW5mt_nt  = escorc_n(W5_ntpi,tasd,0,0)

; ------------ significance -----------------
 n        = dimsizes(samsd)
 df       = n-2

 tval     = rU8mt*sqrt((n-2)/(1-rU8mt^2))
 pU8mt    = student_t(tval, df)
 tval     = rU8mt_ns*sqrt((n-2)/(1-rU8mt_ns^2))
 pU8mt_ns = student_t(tval, df)
 tval     = rU8mt_nt*sqrt((n-2)/(1-rU8mt_nt^2))
 pU8mt_nt = student_t(tval, df)
 delete(tval)

 tval     = rV8mt*sqrt((n-2)/(1-rV8mt^2))
 pV8mt    = student_t(tval, df)
 tval     = rV8mt_ns*sqrt((n-2)/(1-rV8mt_ns^2))
 pV8mt_ns = student_t(tval, df)
 tval     = rV8mt_nt*sqrt((n-2)/(1-rV8mt_nt^2))
 pV8mt_nt = student_t(tval, df)
 delete(tval)

 tval     = rW5mt*sqrt((n-2)/(1-rW5mt^2))
 pW5mt    = student_t(tval, df)
 tval     = rW5mt_ns*sqrt((n-2)/(1-rW5mt_ns^2))
 pW5mt_ns = student_t(tval, df)
 tval     = rW5mt_nt*sqrt((n-2)/(1-rW5mt_nt^2))
 pW5mt_nt = student_t(tval, df)
 delete(tval)

 delete(df)
 delete(n)
 delete(u8sd)
 delete(v8sd)
 delete(w5sd)
 delete(samsd)
 delete(tpisd)
 delete(tasd)

 ; check pvalues and format values for output
 if pU8mt.lt.siglvl then
  U8si(m)  = rU8mt
  U8nsi(m) = allv8@_FillValue
 else
  U8nsi(m)  = rU8mt
  U8si(m)   = allv8@_FillValue
 end if
 if pU8mt_ns.lt.siglvl then
  U8nssi(m)  = rU8mt_ns
  U8nsnsi(m) = allv8@_FillValue
 else
  U8nsnsi(m) = rU8mt_ns
  U8nssi(m)  = allv8@_FillValue
 end if
 if pU8mt_nt.lt.siglvl then
  U8ntsi(m)  = rU8mt_nt
  U8ntnsi(m) = allv8@_FillValue
 else
  U8ntnsi(m) = rU8mt_nt
  U8ntsi(m)  = allv8@_FillValue
 end if
 delete(rU8mt)
 delete(rU8mt_ns)
 delete(rU8mt_nt)
 delete(pU8mt)
 delete(pU8mt_ns)
 delete(pU8mt_nt)

 if pW5mt.lt.siglvl then
  W5si(m)  = rW5mt
  W5nsi(m) = allv8@_FillValue
 else
  W5nsi(m)  = rW5mt
  W5si(m)   = allv8@_FillValue
 end if
 if pW5mt_ns.lt.siglvl then
  W5nssi(m)  = rW5mt_ns
  W5nsnsi(m) = allv8@_FillValue
 else
  W5nsnsi(m) = rW5mt_ns
  W5nssi(m)  = allv8@_FillValue
 end if
 if pW5mt_nt.lt.siglvl then
  W5ntsi(m)  = rW5mt_nt
  W5ntnsi(m) = allv8@_FillValue
 else
  W5ntnsi(m) = rW5mt_nt
  W5ntsi(m)  = allv8@_FillValue
 end if
 delete(rW5mt)
 delete(rW5mt_ns)
 delete(rW5mt_nt)
 delete(pW5mt)
 delete(pW5mt_ns)
 delete(pW5mt_nt)

 if pV8mt.lt.siglvl then
  V8si(m)  = rV8mt
  V8nsi(m) = allv8@_FillValue
 else
  V8nsi(m)  = rV8mt
  V8si(m)   = allv8@_FillValue
 end if
 if pV8mt_ns.lt.siglvl then
  V8nssi(m)  = rV8mt_ns
  V8nsnsi(m) = allv8@_FillValue
 else
  V8nsnsi(m) = rV8mt_ns
  V8nssi(m)  = allv8@_FillValue
 end if
 if pV8mt_nt.lt.siglvl then
  V8ntsi(m)  = rV8mt_nt
  V8ntnsi(m) = allv8@_FillValue
 else
  V8ntnsi(m) = rV8mt_nt
  V8ntsi(m)  = allv8@_FillValue
 end if
 delete(rV8mt)
 delete(rV8mt_ns)
 delete(rV8mt_nt)
 delete(pV8mt)
 delete(pV8mt_ns)
 delete(pV8mt_nt)

 end do		; month loop
  ; ------------ Plotting ------------
 outPath   = outDir + "ERA5_mechs_VS"+region+"maxT-partialSAM-TPI_siglvl"+siglvl
 wks       = gsn_open_wks(outType, outPath)

 data      = new( (/18,3/), float)
 data(0,:) = U8si
 data(1,:) = U8nssi 
 data(2,:) = U8ntsi
 data(3,:) = U8nsi
 data(4,:) = U8nsnsi
 data(5,:) = U8ntnsi

 data(6,:)  = W5si
 data(7,:)  = W5nssi
 data(8,:)  = W5ntsi
 data(9,:)  = W5nsi
 data(10,:) = W5nsnsi
 data(11,:) = W5ntnsi

 data(12,:) = V8si
 data(13,:) = V8nssi
 data(14,:) = V8ntsi
 data(15,:) = V8nsi
 data(16,:) = V8nsnsi
 data(17,:) = V8ntnsi

 printMinMax(data,1)

 res                   = True
 resU8si               = True
 resW5si               = True
 resV8si               = True
 resU8nsi              = True
 resW5nsi              = True
 resV8nsi              = True

 res@xyDashPattern     = 0                ; Make curves all solid
 res@xyMarkLineModes   = "Markers"        ; markers not lines

 monvals               = ispan(1,3,1) 
 res@tmXBMode          = "Explicit"              ; explicit labels
 res@tmXBValues        = monvals                 ; location of labels
 res@tmXBLabels        = mons                    ; labels themselves
 res@tmLabelAutoStride = True                    ; nice stride on labels
 ;res@tmXBLabelAngleF   = 90.
 ;res@tmXBMajorThicknessF = 0.
 ;res@tmXBLabelJust       = "BottomCenter"; default is TopCenter
 res@tiYAxisAngleF    = 90.
 res@tiYAxisString    = "Correlation with heat mechanisms"

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

 res@gsnFrame = False                  ; don't advance frame yet
 ; copy over common resources
 res@xyMarkerThicknessF = 12. 		; make markers thicker
 res@xyMarkerSizeF     = 0.03           ; make markers bigger (0.01 is default)
 resU8si               = res 
 resW5si               = res
 resV8si               = res
 res@xyMarkerThicknessF = 4
 resU8nsi              = res
 resW5nsi              = res
resV8nsi              = res 
						;x,y offset,default aspect, size and angle
 resU8si@xyMarker      = 11   ;NhlNewMarker(wks,"z",35,0.,0.,1.,1.,0.)	; right stripy traingle
 resW5si@xyMarker      = 14    ;NhlNewMarker(wks,"y",35,0.,0.,1.,1.,0.)	; circle dot
 resV8si@xyMarker      = 8    ;16					; downtriangle
 resU8nsi@xyMarker     = 11						; right stripy triangle
 resW5nsi@xyMarker     = 14                                              ; circle dot 
 resV8nsi@xyMarker     = 8                                              ; down triang

 mtCol		 	= "red"
 tpCol			= "darkturquoise"; "blue"
 saCol			= "darkorchid4"; "purple"
 
 resU8si@xyMarkerColor  = saCol
 resW5si@xyMarkerColor  = saCol
 resV8si@xyMarkerColor  = saCol
 resU8nsi@xyMarkerColor = saCol
 resW5nsi@xyMarkerColor = saCol
 resV8nsi@xyMarkerColor = saCol
 plot  = gsn_csm_xy(wks,monvals,data(1,:),resU8si)
 plot  = gsn_csm_xy(wks,monvals,data(4,:),resU8nsi)
 plot  = gsn_csm_xy(wks,monvals,data(7,:),resW5si)
 plot  = gsn_csm_xy(wks,monvals,data(10,:),resW5nsi)
 plot  = gsn_csm_xy(wks,monvals,data(13,:),resV8si)
 plot  = gsn_csm_xy(wks,monvals,data(16,:),resV8nsi)

 resU8si@xyMarkerColor  = tpCol
 resW5si@xyMarkerColor  = tpCol
 resV8si@xyMarkerColor  = tpCol
 resU8nsi@xyMarkerColor = tpCol
 resW5nsi@xyMarkerColor = tpCol
 resV8nsi@xyMarkerColor = tpCol
 plot  = gsn_csm_xy(wks,monvals,data(2,:),resU8si)
 plot  = gsn_csm_xy(wks,monvals,data(5,:),resU8nsi)
 plot  = gsn_csm_xy(wks,monvals,data(8,:),resW5si)
 plot  = gsn_csm_xy(wks,monvals,data(11,:),resW5nsi)
 plot  = gsn_csm_xy(wks,monvals,data(14,:),resV8si)
 plot  = gsn_csm_xy(wks,monvals,data(17,:),resV8nsi)

 res@xyMarkerSizeF     = 0.027 
 resU8si@xyMarkerColor  = mtCol
 resW5si@xyMarkerColor  = mtCol
 resV8si@xyMarkerColor  = mtCol
 resU8nsi@xyMarkerColor = mtCol
 resW5nsi@xyMarkerColor = mtCol
 resV8nsi@xyMarkerColor = mtCol
 plot  = gsn_csm_xy(wks,monvals,data(0,:),resU8si)
 plot  = gsn_csm_xy(wks,monvals,data(3,:),resU8nsi)
 plot  = gsn_csm_xy(wks,monvals,data(6,:),resW5si)
 plot  = gsn_csm_xy(wks,monvals,data(9,:),resW5nsi)
 plot  = gsn_csm_xy(wks,monvals,data(12,:),resV8si)
 plot  = gsn_csm_xy(wks,monvals,data(15,:),resV8nsi)

 ; legend
 labels = (/" U850 "," V850  ","  W500  "/)
 lgres                    = True

 lgres@vpWidthF           = 0.13                   ; width of legend (NDC)
 lgres@vpHeightF          = 0.2                   ; height of legend (NDC)
 lgres@lgLabelAlignment	  = "ItemCenters"	; default is Item Centers, also have AboveItems
 lgres@lgTitleString      = "" 
 lgres@lgItemType         = "Markers"
 lgres@xyMarkLineModes    = "Markers"           ; markers not lines
 lgres@lgMarkerSizeF      = 0.028                ; maker bigger
 lgres@lgMarkerIndexes    = (/11,8,14/)          ; marker indexes
 lgres@lgMarkerThicknessF  = 5.
 lgres@lgMarkerColors     = (/"black","black","black"/) ; marker colors
 ;lgres@xyExplicitLegendLabels = labels
 lgres@lgMonoItemType     = True                  ; only want markers
 
 lgres@lgAutoManage       = False
 lgres@lgLabelFontHeightF = 0.08
 lgres@lgLabelAngleF      = 0.

 lgres@lgPerimOn          = False               ; turn off box
 lgres@lgOrientation      = "vertical"		;"horizontal"
;
; Draw the legend, indicating the number of items, a label for each
; item, and the X, Y position of the legend in NDC coordinates.
;
 gsn_legend_ndc(wks,3,labels,0.7,0.6,lgres)

 labels = (/" SAA "," SWC    ","  SEC  "/) 
 lgres@lgMarkerIndexes    = (/12,4,6/)
 gsn_legend_ndc(wks,3,labels,0.7,.8,lgres)

 labels = (/"  no TPI "," no SAM   "," max. T. "/)
 lgres@lgMarkerIndexes    = (/16,16,16/)          ; marker indexes
 lgres@lgMarkerColors     = (/tpCol,saCol,mtCol/) ; marker colors
 gsn_legend_ndc(wks,3,labels,0.7,.4,lgres)

 frame(wks)

break
end do		;region loop








end



