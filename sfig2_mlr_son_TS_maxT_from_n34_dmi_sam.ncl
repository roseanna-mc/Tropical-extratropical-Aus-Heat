; Usage NCL
; 28/6/21 (for main plot)

; max T vs n34, dmi,sam for Sep,Oct and Nov
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
 mtDir05 = "/g/data/rr8/OBS/AWAP_ongoing/v0.4/grid_05/monthly/tmax/" 
;------------------ Get data ---------------------
 ; maximum temperture
 tfils = systemfunc (" ls /g/data/rr8/OBS/AWAP_ongoing/v0.4/grid_05/monthly/tmax/tmax_mean_monthly_0.05*")
 tfs   = addfiles (tfils, "r")
 ListSetType( tfs, "cat")
 t    = tfs[:]->tmax(moStrtT:moStopT,0,0)
 delete(tfils)
 delete(tfs)

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
 copy_VarCoords(t,sams)

  ; n34
  sfil   = obsDir + "1979_2019_ERSSTv5_n34"
  ncol   = 3                    ; years, months, sam
  nrows  = (2019 - 1979)*12 + 12
  aln34  = asciiread(sfil,(/nrows,ncol/),"float")
  alln34 = aln34(:,2)
  printVarSummary(alln34)
  delete(sfil)
  delete(ncol)
  delete(nrows)
  delete(aln34)
 copy_VarCoords(t,alln34)

  ; DMI
  sfil   = obsDir + "1979_2019_ERSSTv5_dmi"
  ncol   = 3                    ; years, months, sam
  nrows  = (2019 - 1979)*12 + 12
  aldmi  = asciiread(sfil,(/nrows,ncol/),"float")
  alldmi = aldmi(:,2)
  delete(sfil)
  delete(ncol)
  delete(nrows)
  delete(aldmi)
 copy_VarCoords(t,alldmi)

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
 ;printVarSummary(Amts)
 copy_VarCoords(t,Amts)
 copy_VarCoords(t,SEmts)
 copy_VarCoords(t,SWmts)
 copy_VarCoords(t,Nmts)
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

   mStr  = "3 Month-rolling avg " 
   mFl   = "3mthly"
   n34   = month_to_season(alln34,"SON")	; 3 month rollowing averaging
   samEm = month_to_season(sams,"SON")
   dmi   = month_to_season(alldmi,"SON")
   tamm  = month_to_season(tass,"SON")
 

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


 outPath = outDir +yrFirst+"_"+yrLast+"_"+"obs"+trend +"son_"+region+"maxTtimeseries_mlr"+stdfx+"_N34-DMIersstv5_SAMe5"
 wks     = gsn_open_wks(outType, outPath)

  tam     = tamm - dim_avg_n_Wrap(tamm(:indStopC),0)
  copy_VarCoords(tamm,tam)
  delete(tamm)

 ; ------- detrend ------
  n34d    = n34
  dmid    = dmi
  samEd   = samEm
  tad     = tam
  if dtrnd.eq."True" then
   n34d   = 0.
   dmid   = 0.
   samEd  = 0.
   tad    = 0.
    x     = ispan(1, dimsizes(n34), 1)
    ;printVarSummary(x)
    n34d   = dtrend_msg_n(x,n34,False,False,0)
    dmid   = dtrend_msg_n(x,dmi,False,False,0)
    samEd  = dtrend_msg_n(x,samEm,False,False,0)
    tad    = dtrend_msg_n(x,tam,False,False,0)
    copy_VarMeta(samEm,samEd)
    copy_VarMeta(tam,tad)
    delete(x)
  end if
  delete(tam)
  dmisd  = dmid
  n34sd  = n34d
  samsd  = samEd
  if stdise.eq."True" then
   n34sd  = dim_standardize_n_Wrap(n34d,0,0)
   dmisd  = dim_standardize_n_Wrap(dmid,0,0)
   samsd  = dim_standardize_n_Wrap(samEd,0,0)
  end if
  delete(n34d)
  delete(samEd)
  delete(dmid)

  ;create array for the predictors
  ntim    = dimsizes(tad)
  xp      = new((/ntim,3/),typeof(n34sd))
  xp(:,0) = n34sd
  xp(:,1) = samsd
  xp(:,2) = dmisd
 ; multi linear regression to get reg coef
 ; bvar(yintercept, reg coef1, regcoef2, regcoef3)
 bt      = reg_multlin_stats(tad,xp,True)
 rcn34   = bt(1)
 rcsam   = bt(2)
 rcdmi   = bt(3)
 rse     = bt@RSE               ; stderr -> standard error of each index
 r2val    = bt@r2

 ; recreate specified year's anomaly from predictors
 ;printVarSummary(obsT)
 n34T = rcn34*n34sd
 samT = rcsam*samsd
 dmiT = rcdmi*dmisd
 reconT = n34T  + samT + dmiT
 copy_VarCoords(tad,reconT)

 up95   = reconT + conform_dims(dimsizes(tad),1.96*rse,(/0/))
 lw95   = reconT - conform_dims(dimsizes(tad),1.96*rse,(/0/))
 copy_VarCoords(tad,up95)
 copy_VarCoords(tad,lw95)
 delete(n34sd)
 delete(samsd)
 delete(dmisd)
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
  res@trYMinF               = -4. 		   ; set to same for both plots
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
 
  sres@tiYAxisFontHeightF     = 0.025		; make Y axis string bigger (default 0.025)
  sres@tiYAxisOffsetXF        = 0.03		; move Y axis string parallel to x-axis (default zero) 
   sres@tiYAxisString         = "Max. T from Nino3.4,DMI,SAM"
  sres@tiYAxisSide           = "Left"
  sres@tiYAxisAngleF         = 90              ; Rotate the Y-axis title 270 degrees
  sres@gsnYRefLine           = 0.               ; Draw horiz line at y=0
  sres@gsnYRefLineColor      = "Black"
  sres@gsnYRefLineThicknessF = 1.0

  sres@gsnLeftStringOrthogonalPosF  = -0.14
  sres@gsnRightStringOrthogonalPosF = -0.14      ; try to put r2 value inside plot
  sres@gsnLeftStringParallelPosF    = 0.03
  sres@gsnRightStringParallelPosF   = 0.96
  
  sres@gsnStringFontHeightF          = 0.033
  letters                           = (/"a","b","c"/)
  sres@gsnRightString               = "r~S~2~N~ = " + sprintf("%5.2f",r2val) 

  sres@tmXBOn              = True
  sres@tmYROn              = True
  sres@tmXTOn              = True
  sres@tmYLOn              = True
  sres@cnFillScales        = 0.5

  opat                       = 4                 ;fill pattern for observed max t
  mpat                       = 0                 ; fill pattern for statistical model t
  fillscale                  = 0.4               ; FillScale for pattern
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
  lbres@lbFillScaleF       = fillscale

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

 break
 end do         ; standardisation loop
 break
 end do         ; trend loop
;break
 end do		; region loop

end



















