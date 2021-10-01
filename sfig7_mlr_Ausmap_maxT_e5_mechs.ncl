; Usage NCL
; 16/6/20 (for main plot)

; vs mechs instead of TPI and sAM

; max T vs TPI and SAM for Sep,Oct and Nov

function get_title_position(plot)
local vpy, vpx, vph
begin
  getvalues plot
      "vpYF"       : vpy
      "vpXF"       : vpx
      "vpHeightF"  : vph
  end getvalues
  pos = (/vpx*0.75-0.03,vpy-(vph/2.)/)
  return(pos)
end

function get_label_position(plot)
local vpy, vpx, vph
begin
  getvalues plot
      "vpYF"       : vpy                ; top of plot
      "vpXF"       : vpx                ; left side of plot
      "vpHeightF"  : vph                ; height of plot
  end getvalues
  ;pos = (/vpx+0.38,vpy+0.01/)          ; attempted for side panel
  pos = (/vpx+0.807,vpy-vph-0.045/)      ; for bottom panel
  return(pos)
end
 
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

 gspac     = 2				 ; get every gspac'd lat lon in AWAP data
 siglvl    = 0.05

 mons      = (/"Sep", "Oct", "Nov"/) 
 months    = (/"September", "October", "November"/)
;-------------------------- File options -----------------------
 outType = "png"
 obsDir  = "/g/data/w97/rm8168/data/tropVextrop/"
 outDir  = "/g/data3/w97/rm8168/data/tropVextrop/withWS/"
 mtDir05 = "/g/data/rr8/OBS/AWAP_ongoing/v0.4/grid_05/monthly/tmax/" 
;------------------ Get data ---------------------

 a         = addfile("/g/data/rr8/OBS/AWAP_ongoing/land_fixed_0.05.nc","r")
 lsA       = short2flt(  a->land(::gspac,::gspac) )       ; AWAP land - sea mask (1 = land)
 delete(a)
 ;printVarSummary(lsA)

 ; maximum temperture
 tfils = systemfunc (" ls /g/data/rr8/OBS/AWAP_ongoing/v0.4/grid_05/monthly/tmax/tmax_mean_monthly_0.05*")
 tfs   = addfiles (tfils, "r")
 ListSetType( tfs, "cat")
 t    = tfs[:]->tmax(moStrtT:moStopT,::gspac,::gspac)
 delete(tfils)
 delete(tfs)
 ;printVarSummary(t)
 tcmons = clmMonTLL(t(moStrtC:moStopC,:,:))
 tanoms = calcMonAnomTLL(t,tcmons)
 delete(tcmons)
 delete(t)
 ;printVarSummary(tanoms)

 ; era5 v8 time series
 sfil   = obsDir + "1979_2019_ERA5_U850_S-O-N_timeseries"
 ncol   = 3                    ; S O N
 nrows  = (2019 - 1979) +1
 allu8  = asciiread(sfil,(/nrows,ncol/),"float")	;[492] x [3]
 printVarSummary(allu8)
 delete(sfil)

 sfil   = obsDir + "1979_2019_ERA5_V850x-1_S-O-N_timeseries"
 allv8  = asciiread(sfil,(/nrows,ncol/),"float")        ;[492] x [3]
 printVarSummary(allv8)

 sfil   = obsDir + "1979_2019_ERA5_W500_S-O-N_timeseries"
 allw5  = asciiread(sfil,(/nrows,ncol/),"float")        ;[492] x [3]
 printVarSummary(allw5)

; ------------------ mask --------------------
 ta   = mask(tanoms,conform(tanoms, lsA, (/1,2/)), 1)
 copy_VarMeta(tanoms,ta)
 delete(tanoms)
 delete(lsA)

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

 outPath          = outDir +yrFirst+"_"+yrLast+"_"+"obs"+trend +"S-O-N_maxTausmap_mlr"+stdfx+"_ERA5mechs_siglvl"+siglvl
 wks              = gsn_open_wks(outType, outPath)

 wks      = gsn_open_wks(outType, outPath)
 plots    = new(9,graphic)


do m     = 0,2
   M     = m + 8
  mon    = mons(m)        ; for files
  month  = months(m)
  print("month is "+ mon) 
  tam     = ta(M::12,:,:)
  w5     = allw5(:,m)
  u8     = allu8(:,m)
  v8     = allv8(:,m)
 
 ; ------- detrend ------
  u8d   = u8
  v8d   = v8
  w5d   = w5

  tad    = tam
  if dtrnd.eq."True" then
   u8d   = 0.
   v8d   = 0.
   w5d   = 0.
   tad    = 0.
    x     = ispan(1, dimsizes(u8), 1)
    ;printVarSummary(x)
    u8d  = dtrend_msg_n(x,u8,False,False,0)
    v8d  = dtrend_msg_n(x,v8,False,False,0)
    w5d  = dtrend_msg_n(x,w5,False,False,0)
    tad   = dtrend_msg_n(x,tam,False,False,0)
    copy_VarMeta(tam(:,:,:),tad)
    delete(x)
  end if
  delete(tam)

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

  ntim      = dimsizes(tad&time)
  nlon      = dimsizes(tad&lon)
  nlat      = dimsizes(tad&lat)
  rcu8     = new((/nlat,nlon/),float,tad@_FillValue)
  rcv8     = rcu8
  rcw5     = rcu8
  pu8      = rcu8
  pv8      = rcv8
  pw5      = rcv8
  r2       = rcv8
  u8big    = rcv8
  v8big    = rcv8
  w5big    = rcv8 
 
  ;create array for the 3 predictors (u8, v8,25)
  xp      = new((/ntim,3/),typeof(u8sd))
  xp(:,0) = u8sd
  xp(:,1) = v8sd
  xp(:,2) = w5sd

  do la     = 0, nlat-1
  do lo     = 0, nlon-1
    ; bvar(yintercept, reg coef1, regcoef2, regcoef3)
    if all(ismissing(tad(:,la,lo))) then
	; regmultilinstats can't do missing values, which maxT has because it the land was masked
    rcu8(la,lo) = 0.
    rcv8(la,lo) = 0.
    rcw5(la,lo) = 0.
   else
    bt            = reg_multlin_stats(tad(:,la,lo),xp,True)
    rcu8(la,lo) = bt(1)
    rcv8(la,lo) = bt(2)
    rcw5(la,lo) = bt(3)
    pval        = bt@pval
    ;printVarSummary(pval)
    pu8(la,lo)  = pval(1)
    pv8(la,lo)  = pval(2)
    pw5(la,lo)  = pval(3)
    r2(la,lo)   = bt@r2
    delete(bt)

   if ( abs(rcv8(la,lo)).gt.abs(rcw5(la,lo))).and.( abs(rcv8(la,lo)).gt.abs(rcu8(la,lo))) then
    v8big(la,lo) = rcv8(la,lo)
   else
    v8big(la,lo) = 0.
   end if

   if ( abs(rcw5(la,lo)).gt.abs(rcv8(la,lo))).and.( abs(rcw5(la,lo)).gt.abs(rcu8(la,lo))) then
    w5big(la,lo) = rcw5(la,lo)
   else
    w5big(la,lo) = 0.
   end if

   if ( abs(rcu8(la,lo)).gt.abs(rcw5(la,lo))).and.( abs(rcu8(la,lo)).gt.abs(rcv8(la,lo))) then
    u8big(la,lo)  = rcu8(la,lo)
   else
    u8big(la,lo)  = 0.
   end if
   end if
  end do
 end do
 delete(xp)

 copy_VarCoords(tad(0,:,:),rcu8)
 copy_VarCoords(tad(0,:,:),rcv8)
 copy_VarCoords(tad(0,:,:),rcw5)
 copy_VarCoords(tad(0,:,:),r2)
 copy_VarCoords(tad(0,:,:),u8big)
 copy_VarCoords(tad(0,:,:),v8big)
 copy_VarCoords(tad(0,:,:),w5big)
 rcu8@long_name = ""
 rcv8@long_name = ""
 rcw5@long_name = ""
 r2@long_name    = ""
 u8big@long_name = ""
 v8big@long_name = ""
 w5big@long_name = ""
 delete(tad)
 delete(u8sd)
 delete(v8sd)

 ;mask for significance
 su8     = rcu8
 sv8     = rcv8
 sw5     = rcw5
 su8     = mask(su8, pu8.lt.siglvl, True)
 sv8     = mask(sv8, pv8.lt.siglvl, True)
 sw5     = mask(sw5, pw5.lt.siglvl, True)
 copy_VarCoords(rcu8,su8)
 copy_VarCoords(rcu8,sv8)
 copy_VarCoords(rcu8,sw5)
 sw5@long_name = ""
 su8@long_name = ""
 sv8@long_name = ""
;------------------- Plotting ----------------------

  resP = True              ; panel resources
  res  = True 		   ; common resources   
  res1 = True		   ; max t
  resS = True		   ; stippling
  res2 = True		   ; r2

  pltstr = (/"a","b","c","d","e","f","g","h","i"/)

  res@pmTickMarkDisplayMode = "Always"
  res@mpFillOn              =  False          ; turn off map fill
  res@mpOutlineDrawOrder    = "PostDraw"      ; draw continental outline last
  res@mpMinLatF             = -44.          ; range to zoom in on
  res@mpMaxLatF             = -10.
  res@mpMinLonF             = 112.
  res@mpMaxLonF             = 155.
  res@gsnAddCyclic          = False
  res@gsnMaximize           = True    ; Maximize in frame
  res@cnLineLabelsOn        = False
  res@NoDataLabel           = True            ; Don't put label on
  res@cnLinesOn             = False           ; turn off contour lines
  res@cnFillOn              = True            ; Turn on fill True
  res@gsnDraw               = False          ; do not draw the plot
  res@gsnFrame              = False          ; do not advance the frame
  res@lbLabelBarOn          = False
  res@cnInfoLabelOn         = False
  res@gsnStringFontHeightF  = 0.03       	; make all font size bigger
  res@gsnLeftStringOrthogonalPosF  = -0.15	; move strings into plots
  res@gsnLeftStringParallelPosF    = 0.04
  res@gsnRightStringParallelPosF   = 0.96
  res@gsnRightStringOrthogonalPosF = -0.15
 
  res1			    = res
  res1@cnLevelSelectionMode = "ManualLevels"
  res1@cnFillPalette        = "CBR_coldhot"
  res1@cnMonoLineColor      = False
  res1@cnMinLevelValF       = -1.2
  res1@cnMaxLevelValF       = 1.2
  res1@cnLevelSpacingF      = .2
  ;res1@gsnRightString       = "~S~o~N~C "
 
  resS			    = res
  resS@cnMonoFillColor      = True
  resS@cnFillPattern        = 11
  resS@cnFillDotSizeF       = .003
  resS@cnFillScaleF         = 0.7
 
  res2			    = res
  res2@cnLinesOn            = True
  res2@cnLevelSelectionMode = "ManualLevels"
  res2@cnFillPalette        = "precip_11lev"
  res2@cnMinLevelValF       = 0.
  res2@cnMaxLevelValF       = 1.
  res2@cnLevelSpacingF      = .1


  res1@gsnCenterString      = month
  ;plot                      = gsn_csm_contour_map(wks,u8big,res1)
  plot                      = gsn_csm_contour_map(wks,rcu8,res1)
  plot1                     = gsn_csm_contour(wks, su8, resS)
  overlay(plot, plot1)
  delete(plot1)
  plots(m)                = plot
  delete(plot)
 
  res1@gsnCenterString      = ""
  ;plot                      = gsn_csm_contour_map(wks,v8big,res1)
  plot                      = gsn_csm_contour_map(wks,rcv8,res1)
  plot1                     = gsn_csm_contour(wks, sv8, resS)
  overlay(plot, plot1)
  delete(plot1)
  plots(m+3)            = plot
  delete(plot)

  ;plot                      = gsn_csm_contour_map(wks,w5big,res1)
  plot                      = gsn_csm_contour_map(wks,rcw5,res1)
  plot1                     = gsn_csm_contour(wks, sw5, resS)
  overlay(plot, plot1)
  delete(plot1)
  plots(m+6)            = plot
  delete(plot)

  ;res2@gsnLeftString        = pltstr(m+6) + ") "+ mon
  ;res2@gsnRightString       = "r~S~2~N~"
  ;plot                      = gsn_csm_contour_map(wks,r2,res2)
  ;plots(m+9)                  = plot
  ;delete(plot)


 end do		; month loop

  resP                     = True
  resP@gsnPanelFigureStringsFontHeightF = 0.015
  resP@gsnPanelFigureStrings       = (/"a","b","c","d","e","f","g","h","i"/) ; add strings to panel
  resP@amJust                      = "TopLeft"
  resP@gsnPanelLabelBar         =  True
  resP@gsnMaximize              = True
  resP@gsnFrame                 = False
  resP@gsnPanelLeft             = 0.02
  resP@gsnPanelBottom           = 0.08
  resP@gsnPanelSave             = True  ; Save the state of the paneled plots so we can
                                        ; query for text strings locations.
  resP@lbLabelStride               = 1       ; every other label

  gsn_panel(wks, plots, (/3,3/), resP)

;**********************************************************************
; Add rotated text strings on left side of paneled plots.
; Use the resized plots to determine the position of the titles
;**********************************************************************
 pos1 = get_title_position(plots(0))         ; 1st row leftmost plot
 pos2 = get_title_position(plots(3))         ; 2nd row leftmost plot
 pos3 = get_title_position(plots(6)) 
 pos4 = get_label_position(plots(6))         ; last plot (for positioning label)
 ;pos4 = get_label_position(plots(11))
 txres               = True
 txres@txFontHeightF = 0.02
 txres@txAngleF      = 90.
 gsn_text_ndc(wks, "u 850hPa",   pos1(0), pos1(1), txres)
 gsn_text_ndc(wks, "v 850hPa x-1",   pos2(0), pos2(1), txres)
 gsn_text_ndc(wks, "omega 500hPa",   pos3(0), pos3(1), txres)
 txres@txAngleF      = 0.
 gsn_text_ndc(wks, "~S~o~N~C", pos4(0), pos4(1), txres)
 frame(wks)


 break
 end do         ; standardisation loop
 break
 end do         ; trend loop
end



















