; Usage NCL
; 20/6/21 (for main plot)
 
; max T vs mechanisms for Sep,Oct and Nov
; time series with r2
; panelling with time series is a pain
; going to make individual time series as before and stitch it together manually
 
begin

;--------------------- Set options -------------------------
 yrStrtC  = 1981                          ; First year of climatology
 yrStopC  = 2010                          ; Last year of climatology
 yrFirst  = 1979
 yrLast   = 2019

 indStrtC = yrStrtC - yrFirst 
 indStopC = yrStopC - yrFirst               ; Index of last year of climatology
 
 moStrtC  = (yrStrtC - yrFirst)*12	 ; First year of climatology
 moStopC  = (yrStopC - yrFirst)*12 + 11   ; Last month of climatology
 moStrtH  = (yrFirst - 1870)*12           ; First month (index) to use in Hurrell extended dataset (only to Nov 2019)
 moLastH  = (yrLast - 1870)*12 + 11       ; Last month (index) to use in Hurrell extended dataset
 moStrtE  = (yrFirst - 1979)*12           ; First month of climatology index for ERAI
 moStopE  = (yrLast - 1979)*12 + 11       ; ERA-I data goes to August 2019
 moStrtT  = (yrFirst - 1911)*12           ; First month of climatology for AWAP
 moStopT  = (yrLast - 1911)*12 + 11       ; Last month of anomalies for AWAP

 rad       = 4.0*atan(1.0)/180.0

 dtrns     = (/"False", "True"/)         ; Detrended ("True") or whole data ("False")?
 avgs      = (/"mthly","3mthly"/)	 ; Monthly or 3-month rolling average?
 regions   = (/"Aus","SW","SE"/)         ; which regions do I take MT time series of?
 regionSts = (/"", "SW", "SE"/)          ; for plot
 stds      = (/"False","True"/)          ; Standardise index or not?

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

do re      = 0, dimsizes(regions)-1
 region    = regions(re)
  regionSt = regionSts(re)

  if region.eq."Aus" then
   print("region is "+region)
   tass     = Amts
  else if region.eq."SW" then
   print("region is "+region)
   tass    = SWmts
  else if region.eq."SE" then
   print("region is "+region)
   tass    = SEmts
  else if region.eq."N" then
   print("region is "+region)
   tass    = Nmts
  end if
  end if
  end if
  end if

 do av = 0,dimsizes(avgs)-1
  mavg = avgs(av)
  if mavg.eq."mthly" then
   mons   =  (/"Sep", "Oct", "Nov"/)
         
   months = (/"September","October","November"/)
   u8m   = allu8
   v8m   = allv8
   w5m   = allw5
   ta    = tass
   mStr  = "Monthly "
   mFl   = "mthly"
   
  else 
   mons   = (/"ASO", "SON","OND"/)
   months = mons
   mStr   = "3 Month-rolling avg " 
   mFl    = "3mthly"
   u8m  = month_to_season12(allu8)	; 3 month rollowing averaging
   v8m  = month_to_season12(alles)
   sw5  = month_to_season12(allw5)
   ta   = month_to_season12(tass)
  
  end if 

 do trd = 1, dimsizes(dtrns)-1
  dtrnd = dtrns(trd)

  if dtrnd.eq."True" then
   trend   =  "_DT_"     ; For output file
   trendSt = "(detrended)"; For plot title
  else
   trend   = "_"
   trendSt = "(not detrended)"
  end if
  print("detrending is " + dtrnd)

 do st   = 1,dimsizes(stds)-1
  stdise = stds(st)
  if stdise.eq."True" then
   print("standardising drivers")
   stdSt   = "stdised"
   stdfx   = "std"
  else
   print("not standardising drivers")
   stdfx = ""
   stdSt = ""
  end if


do m     = 0,2
   M     = m + 8
   mon   = mons(m)        ; for files
   month = months(m)
 outPath = outDir +yrFirst+"_"+yrLast+"_"+"obs"+trend +mon+"_"+region+"maxTtimeseries_mlr"+stdfx+"_era5_mechanisms"
 wks     = gsn_open_wks(outType, outPath)

 wks     = gsn_open_wks(outType, outPath)

  print("month is "+ mon) 
  v8mm   = v8m(:,m)
  tamm   = ta(M::12)
  u8mm   = u8m(:,m)
  w5mm   = w5m(:,m)

  tam    = tamm - dim_avg_n_Wrap(tamm(:indStopC),0)
  copy_VarCoords(tamm,tam)
  delete(tamm)

 ; ------- detrend ------
  u8d    = u8mm
  v8d    = v8mm
  w5d    = w5mm
  tad    = tam
  if dtrnd.eq."True" then
   u8d   = 0.
   v8d   = 0.
   w5d   = 0.
   tad   = 0.
    x    = ispan(1, dimsizes(u8mm), 1)
    ;printVarSummary(x)
    u8d  = dtrend_msg_n(x,u8mm,False,False,0)
    v8d  = dtrend_msg_n(x,v8mm,False,False,0)
    w5d  = dtrend_msg_n(x,w5mm,False,False,0)
    tad  = dtrend_msg_n(x,tam,False,False,0)
    delete(x)
  end if
  delete(tam)
  delete(v8mm)
  delete(u8mm)
  delete(w5mm)

  u8sd  = u8d
  v8sd  = v8d
  w5sd  = w5d
  if stdise.eq."True" then
   u8sd  = dim_standardize_n_Wrap(u8d,0,0)
   v8sd  = dim_standardize_n_Wrap(v8d,0,0)
   w5sd  = dim_standardize_n_Wrap(w5d,0,0)
  end if
  delete(u8d)
  delete(v8d)
  delete(w5d)

  ;create array for the predictors
  ntim    = dimsizes(tad)
  xp      = new((/ntim,3/),typeof(u8sd))
  xp(:,0) = u8sd
  xp(:,1) = v8sd
  xp(:,2) = w5sd

 ; multi linear regression to get reg coef
 ; bvar(yintercept, reg coef1, regcoef2, regcoef3)
 bt     = reg_multlin_stats(tad,xp,True)
 rcu8   = bt(1)
 rcv8   = bt(2)
 rcw5   = bt(3)
 rse    = bt@RSE               ; stderr -> standard error of each index
 r2val  = bt@r2

 ; recreate specified year's anomaly from predictors
 ;printVarSummary(obsT)
 u8T = rcu8*u8sd
 v8T = rcv8*v8sd
 w5T = rcw5*w5sd

 reconT = u8T  + v8T + w5T  
 copy_VarCoords(tad,reconT)

 up95   = reconT + conform_dims(dimsizes(tad),1.96*rse,(/0/))
 lw95   = reconT - conform_dims(dimsizes(tad),1.96*rse,(/0/))
 copy_VarCoords(tad,up95)
 copy_VarCoords(tad,lw95)
 delete(u8sd)
 delete(v8sd)

 ;------------------- Plotting ----------------------
 years            = ispan(yrFirst,yrLast,1)

 dataMT           = new((/dimsizes(years),2/),"float")       ; to hold the data
 dataMT(:,0)      = tad
 dataMT(:,1)      = reconT
 delete(tad)
 delete(reconT) 
 bw                         = 0.35

;---Set resources common to both plots
  res                       = True                 ; plot mods desired
  res@gsnFrame              = False
  res@gsnDraw               = False
  res@vpWidthF              = 0.8                  ; change aspect ratio
  res@vpHeightF             = 0.5
  res@vpXF                  = .15
  res@trXMinF               = yrFirst - bw
  res@trXMaxF               = yrLast  + bw
  res@trYMinF               = -4. 		   ; set to see for both plots
  res@trYMaxF               = 4.
  res@tmXBOn                = False		   ; default tick marks and labels off
  res@tmXTOn                = False
  res@tmYLOn                = False
  res@tmYROn                = False
  res@tmYBMinorOn           = False           ; turn off Y axis minor tickmarks
  res@tmYRLabelsOn          = False
  res@tmXBLabelFontHeightF  = 0.025
  res@tmXTLabelFontHeightF  = 0.025
  res@tmYLLabelFontHeightF  = 0.025
  res@tmXBMode              = "Manual"
  res@tmXBTickStartF        = 1980; res@trXMinF   ; Force tickmark labelling to start at first value
  res@tmXBTickEndF          = 2019;res@trXMaxF
  res@tmXBTickSpacingF      = 5


;---XY curve resources
  xyres                     = res
  xyres@xyLineThicknessF    = 4.0               ; default is 1.0
  xyres@xyLineColor         = "Black"
  xyres@tmYRLabelsOn        = True
  ;xyres@tiYAxisString       = "Error range"
  ;xyres@tiYAxisSide         = "Right"
  ;xyres@tiYAxisAngleF       = 270              ; Rotate the Y-axis title 270 degrees
 
  ;xyres@gsnYRefLine           = 0               ; Draw horiz line at y=20
  ;xyres@gsnYRefLineColor      = "Black"
  ;xyres@gsnYRefLineThicknessF = 1.0
  xyres@xyDashPattern         = 14
  
;---Bar chart resources
  sres                       = res
  sres@gsnXYBarChart         = True            ; Turn on bar chart
  sres@gsnXYBarChartBarWidth = bw            ; Change bar widths
  sres@tiYAxisFontHeightF     = 0.037           ; make Y axis string bigger (default 0.025)
  sres@tiYAxisOffsetXF        = 0.03            ; move Y axis string parallel to x-axis (default zero)
  if m.eq.0.then
   sres@tiYAxisString         = "~S~o~N~C (from mechanisms)"
  else
   sres@tiYAxisString         = ""
  end if
  sres@tiYAxisSide           = "Left"
  sres@tiYAxisAngleF         = 90              ; Rotate the Y-axis title 270 degrees
  sres@gsnYRefLine           = 0.               ; Draw horiz line at y=0
  sres@gsnYRefLineColor      = "Black"
  sres@gsnYRefLineThicknessF = 1.0

  sres@gsnLeftStringOrthogonalPosF  = -0.14
  sres@gsnRightStringOrthogonalPosF = -0.14      ; try to put r2 value inside plot
  sres@gsnLeftStringParallelPosF    = 0.03
  sres@gsnRightStringParallelPosF   = 0.96
  
  sres@gsnStringFontHeightF         = 0.037
  letters			    = (/"d","e","f"/)
  sres@gsnLeftString                = letters(m)
  sres@gsnRightString               = "r~S~2~N~ = " + sprintf("%5.2f",r2val)


  sres@tmXBOn              = True
  sres@tmYROn              = True
  sres@tmXTOn              = True
  sres@tmYLOn              = True
  sres@cnFillScales        = 0.5

  opat                       = 4		 ;fill pattern for observed max t
  mpat                       = 0		 ; fill pattern for statistical model t
  fillscale		     = 0.4		 ; FillScale for pattern
  sres@gsnXYBarChartFillScaleF = fillscale       ; less than 1 increases density of pattern 
 
  sres@gsnXYBarChartPatterns = opat 
  sres@gsnXYBarChartColors = (/"red"/)
  plot1 = gsn_csm_xy(wks,fspan(yrFirst-bw/2 ,yrLast-bw/2 ,dimsizes(years)),dataMT(:,0),sres)    ; draw each time series

  sres@tmXBOn              = False
  sres@tmXTOn              = False
  sres@tmYLOn              = False
  sres@tmYROn              = False
  sres@tiYAxisString       = ""
  sres@gsnLeftString       = ""
  sres@gsnRightString      = ""
  sres@gsnCenterString      = ""
  sres@gsnXYBarChartPatterns = mpat
  sres@gsnXYBarChartColors = (/"blue"/)                                  
  plot2 = gsn_csm_xy(wks,fspan(yrFirst+bw/2 ,yrLast+bw/2 ,dimsizes(years)),dataMT(:,1),sres)   ; advancing the frame

 delete(dataMT)


  lbres                    = res           ; labelbar only resources
  lbres@vpWidthF           = 0.1           ; labelbar width
  lbres@vpHeightF          = 0.075           ; labelbar height
  lbres@lbBoxMajorExtentF  = .4            ; puts space between color boxes
  lbres@lbMonoFillPattern  = False          ; Solid fill pattern
  lbres@cnFillDotSizeF     = 0.5
  ;lbres@lbLabelFontHeightF = 0.01         ; font height. default is small
  lbres@lbLabelJust        = "CenterLeft"  ; left justify labels
  lbres@lbPerimOn          = False
  lbres@lgPerimColor       = "white"

  lbres@lbFillPatterns     = (/opat,mpat/)
  lbres@lbFillColors       = (/"red","blue"/)
  lbres@lbFillScaleF = fillscale
  labels = (/"Obs.","Recon."/)
  gsn_labelbar_ndc(wks,2,labels,.22,0.37,lbres)          ; draw right labelbar column

;---Get viewport values for bar plot
  getvalues plot2
    "vpXF"      : vpx
    "vpYF"      : vpy
    "vpWidthF"  : vpw
    "vpHeightF" : vph
  end getvalues
  xyres@vpXF      = vpx
  xyres@vpYF      = vpy
  xyres@vpWidthF  = vpw
  xyres@vpHeightF = vph
  xydata              = new((/2,dimsizes(years)/),float)
  xydata(0,:)         = up95
  xydata(1,:)         = lw95

  delete(up95)
  delete(lw95)

  xy_plot  = gsn_csm_xy (wks,years,xydata,xyres)
  anno_id  = gsn_add_annotation(plot2, xy_plot, False)
 
  pres             = True
  pres@gsnDraw     = False
  pres@gsnFrame    = False 
  pres@gsnMaximize = True
  maximize_output(wks,pres)

 draw(wks)
 frame(wks)

 end do		; month loop

 break
 end do         ; standardisation loop
 break
 end do         ; trend loop
 break
 end do         ; month-averages loop

 end do		; region loop

end



















