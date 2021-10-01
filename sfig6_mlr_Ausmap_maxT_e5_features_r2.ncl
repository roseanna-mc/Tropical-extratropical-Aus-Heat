; Usage NCL
; 20/6/20 (for main plot)

; vs features instead of TPI and sAM
; probably for supplemental 

; max T vs TPI and SAM for Sep,Oct and Nov

function get_title_position(plot)
local vpy, vpx, vph
begin
  getvalues plot
      "vpYF"       : vpy
      "vpXF"       : vpx
      "vpHeightF"  : vph
  end getvalues
  pos = (/vpx*0.75,vpy-(vph/2.)/)
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
  ;pos = (/vpx+0.15,vpy-vph-0.04/)          ; attempted for side panel
  pos = (/vpx+0.804,vpy-vph-0.033/)      ; for bottom panel
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

 gspac     = 5				 ; get every gspac'd lat lon in AWAP data
 siglvl    = 0.05

 mons      = (/"Sep", "Oct", "Nov"/) 
 months    = (/"September", "October", "November"/)
;-------------------------- File options -----------------------
 outType = "png"
 obsDir  = "/g/data/w97/rm8168/data/tropVextrop/"
 outDir  = "/g/data3/w97/rm8168/data/tropVextrop/withWS/"
 mtDir05 = "/g/data/rr8/OBS/AWAP_ongoing/v0.4/grid_05/monthly/tmax/" 
 erDir   = "/g/data/w97/rm8168/data/tropVextrop/"

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

 sfil   = erDir + "1979_2019_ERA5_MTas_S-O-N_timeseries"
 ncol   = 3                    ; S O N
 nrows  = (2019 - 1979) +1
 allmts = asciiread(sfil,(/nrows,ncol/),"float")        ;[492] x [3]
 ;printVarSummary(allmts)
 delete(sfil)
 allmts@_FillValue = 9.96921e+36

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

 outPath          = outDir +yrFirst+"_"+yrLast+"_"+"obs"+trend +"S-O-N_maxTausmap_mlr"+stdfx+"_ERA5feats_r2"
 wks              = gsn_open_wks(outType, outPath)

 wks      = gsn_open_wks(outType, outPath)
 plots    = new(3,graphic)


do m     = 0,2
   M     = m + 8
  mon    = mons(m)        ; for files
  month  = months(m)
  print("month is "+ mon) 
  tam     = ta(M::12,:,:)
  zb     = allzb(:,m)
  sw     = allsw(:,m)
  se     = allse(:,m)
  ts     = allmts(:,m) 

 ; ------- detrend ------
  swd   = sw
  sed   = se
  zbd   = zb
  tsd   = ts
  tad   = tam

  if dtrnd.eq."True" then
   swd   = 0.
   sed   = 0.
   zbd   = 0.
   tsd   = 0.
   tsd   = 0.
    x     = ispan(1, dimsizes(sw), 1)
    ;printVarSummary(x)
    swd  = dtrend_msg_n(x,sw,False,False,0)
    sed  = dtrend_msg_n(x,se,False,False,0)
    zbd  = dtrend_msg_n(x,zb,False,False,0)
    tsd  = dtrend_msg_n(x,ts,False,False,0)
    tad  = dtrend_msg_n(x,tam,False,False,0)
    copy_VarMeta(tam(:,:,:),tad)
    delete(x)
  end if
  delete(tam)

  swsd  = swd
  sesd  = sed
  zbsd  = zbd
  tssd  = tsd
  if stdise.eq."True" then
   swsd  = dim_standardize_n_Wrap(swd,0,0)
   sesd  = dim_standardize_n_Wrap(sed,0,0)
   zbsd  = dim_standardize_n_Wrap(zbd,0,0)
   tssd  = dim_standardize_n_Wrap(tsd,0,0)
  end if
  delete(swd)
  delete(sed)
  delete(zbd)
  delete(tsd)

  ntim      = dimsizes(tad&time)
  nlon      = dimsizes(tad&lon)
  nlat      = dimsizes(tad&lat)
  rcsw     = new((/nlat,nlon/),float,tad@_FillValue)
  rcse     = rcsw
  rczb     = rcsw
  psw      = rcsw
  pse      = rcse
  pzb      = rcse
  rcts     = rcsw
  pts      = rcse
  r2       = rcse
  swbig    = rcse
  sebig    = rcse
  zbbig    = rcse 
  tsbig    = rcse
 
  ;create array for the 3 predictors (sw, se,25)
  xp      = new((/ntim,4/),typeof(swsd))
  xp(:,0) = swsd
  xp(:,1) = sesd
  xp(:,2) = zbsd
  xp(:,3) = tssd
  do la     = 0, nlat-1
  do lo     = 0, nlon-1
    ; bvar(yintercept, reg coef1, regcoef2, regcoef3)
    if all(ismissing(tad(:,la,lo))) then
	; regmultilinstats can't do missing values, which maxT has because it the land was masked
    rcsw(la,lo) = 0.
    rcse(la,lo) = 0.
    rczb(la,lo) = 0.
    rcts(la,lo) = 0.
   else
    bt            = reg_multlin_stats(tad(:,la,lo),xp,True)
    rcsw(la,lo) = bt(1)
    rcse(la,lo) = bt(2)
    rczb(la,lo) = bt(3)
    rcts(la,lo) = bt(4)
    pval        = bt@pval
    ;printVarSummary(pval)
    psw(la,lo)  = pval(1)
    pse(la,lo)  = pval(2)
    pzb(la,lo)  = pval(3)
    pts(la,lo)  = pval(4)
    r2(la,lo)   = bt@r2
    delete(bt)

   if ( abs(rcse(la,lo)).gt.abs(rczb(la,lo))).and.( abs(rcse(la,lo)).gt.abs(rcsw(la,lo))).and.( abs(rcse(la,lo)).gt.abs(rcts(la,lo))) then
    sebig(la,lo) = rcse(la,lo)
   else
    sebig(la,lo) = 0.
   end if

   if ( abs(rczb(la,lo)).gt.abs(rcse(la,lo))).and.( abs(rczb(la,lo)).gt.abs(rcsw(la,lo))).and.( abs(rczb(la,lo)).gt.abs(rcts(la,lo)))  then
    zbbig(la,lo) = rczb(la,lo)
   else
    zbbig(la,lo) = 0.
   end if

   if ( abs(rcsw(la,lo)).gt.abs(rczb(la,lo))).and.( abs(rcsw(la,lo)).gt.abs(rcse(la,lo))).and.( abs(rcsw(la,lo)).gt.abs(rcts(la,lo)))  then
    swbig(la,lo)  = rcsw(la,lo)
   else
    swbig(la,lo)  = 0.
   end if

   if ( abs(rcts(la,lo)).gt.abs(rczb(la,lo))).and.( abs(rcts(la,lo)).gt.abs(rcse(la,lo))).and.( abs(rcts(la,lo)).gt.abs(rcsw(la,lo)))  then
    tsbig(la,lo)  = rcts(la,lo)
   else
    tsbig(la,lo)  = 0.
   end if

   end if

  end do
 end do
 delete(xp)

 copy_VarCoords(tad(0,:,:),rcsw)
 copy_VarCoords(tad(0,:,:),rcse)
 copy_VarCoords(tad(0,:,:),rczb)
 copy_VarCoords(tad(0,:,:),rcts)
 copy_VarCoords(tad(0,:,:),r2)
 copy_VarCoords(tad(0,:,:),swbig)
 copy_VarCoords(tad(0,:,:),sebig)
 copy_VarCoords(tad(0,:,:),zbbig)
 copy_VarCoords(tad(0,:,:),tsbig)
 rcsw@long_name = ""
 rcse@long_name = ""
 rczb@long_name = ""
 rcts@long_name = ""
 r2@long_name    = ""
 swbig@long_name = ""
 sebig@long_name = ""
 zbbig@long_name = ""
 tsbig@long_name = ""
 delete(tad)
 delete(swsd)
 delete(sesd)

 ;mask for significance
 ssw     = rcsw
 sse     = rcse
 szb     = rczb
 sts     = rcts
 ssw     = mask(ssw, psw.lt.siglvl, True)
 sse     = mask(sse, pse.lt.siglvl, True)
 szb     = mask(szb, pzb.lt.siglvl, True)
 sts     = mask(sts, pts.lt.siglvl, True)
 copy_VarCoords(rcsw,ssw)
 copy_VarCoords(rcsw,sse)
 copy_VarCoords(rcsw,szb)
 copy_VarCoords(rcsw,sts)
 szb@long_name = ""
 ssw@long_name = ""
 sse@long_name = ""
 sts@long_name = ""

;------------------- Plotting ----------------------

  resP = True              ; panel resources
  res  = True 		   ; common resources   
  res1 = True		   ; max t
  resS = True		   ; stippling
  res2 = True		   ; r2

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
  res@gsnStringFontHeightF  = 0.035       	; make all font size bigger
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

  res2@gsnCenterString      = month
  plot                      = gsn_csm_contour_map(wks,r2,res2)
  plots(m)                  = plot
  delete(plot)

 end do		; month loop

  resP                     = True
  resP@gsnPanelFigureStringsFontHeightF = 0.013
  resP@gsnPanelFigureStrings       = (/"a","b","c"/);,"d","e","f","g","h","i","j","k","l"/) ; add strings to panel
  resP@amJust                      = "TopLeft"
  resP@gsnPanelLabelBar         =  True
  resP@gsnMaximize              = True
  resP@gsnFrame                 = False
  resP@gsnPanelLeft             = 0.02
  resP@gsnPanelBottom           = 0.08
  resP@gsnPanelSave             = True  ; Save the state of the paneled plots so we can
                                        ; query for text strings locations.
  resP@lbLabelStride               = 1       ; every other label

  gsn_panel(wks, plots, (/1,3/), resP)

;**********************************************************************
; Add rotated text strings on left side of paneled plots.
; Use the resized plots to determine the position of the titles
;**********************************************************************
 ;pos1 = get_title_position(plots(0))         ; 1st row leftmost plot
 ;pos2 = get_title_position(plots(3))         ; 2nd row leftmost plot
 ;pos3 = get_title_position(plots(6)) 
 ;pos4 = get_title_position(plots(9))
 pos5 = get_label_position(plots(0))         ; last plot (for positioning label)
 ;pos4 = get_label_position(plots(11))
 txres               = True
 txres@txFontHeightF = 0.02
 txres@txAngleF      = 90.
 ;gsn_text_ndc(wks, "SW low",   pos1(0), pos1(1), txres)
 ;gsn_text_ndc(wks, "SE low",   pos2(0), pos2(1), txres)
 ;gsn_text_ndc(wks, "Z200 Bight",   pos3(0), pos3(1), txres)
 ;gsn_text_ndc(wks, "Tasman Sea High",   pos4(0), pos4(1), txres)
 txres@txAngleF      = 0.
 gsn_text_ndc(wks, "r~S~2~N~", pos5(0), pos5(1), txres)
 frame(wks)


 break
 end do         ; standardisation loop
 break
 end do         ; trend loop
end



















