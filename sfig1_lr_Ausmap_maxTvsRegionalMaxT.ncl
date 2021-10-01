; Usage NCL
; 21/7/20 

; max T vs regional max t (following Harry's suggestion)
; probably for supplental
; will include spring

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
  pos = (/vpx+0.2,vpy-vph-0.06/)          ; attempted for side panel
  ;pos = (/vpx+0.807,vpy-vph-0.045/)      ; for bottom panel
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
 regions   = (/"Aus","SW","SE","N"/)         ; which regions do I take MT time series of?
 regionSts = (/"", "SW", "SE","N"/)          ; for plot
 stds      = (/"False","True"/)          ; Standardise index or not?

 gspac     = 1				 ; get every gspac'd lat lon in AWAP data
 siglvl    = 0.05

 mons      = (/"SON","Sep", "Oct", "Nov"/) 
 months    = (/"Spring","September", "October", "November"/)
;-------------------------- File options -----------------------
 outType = "png"
 obsDir  = "/g/data/w97/rm8168/data/tropVextrop/"
 outDir  = "/g/data3/w97/rm8168/data/tropVextrop/withWS/"
 mtDir05 = "/g/data/rr8/OBS/AWAP_ongoing/v0.4/grid_05/monthly/tmax/" 
 erDir   = "/g/data/w97/rm8168/data/tropVextrop/"
 obsDir  = "/g/data/w97/rm8168/data/obs/"

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
 copy_VarCoords(tanoms(:,0,0),Amts)
 copy_VarCoords(tanoms(:,0,0),SWmts)
 copy_VarCoords(tanoms(:,0,0),SEmts)
 copy_VarCoords(tanoms(:,0,0),Nmts)
 printVarSummary(Amts)

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

 outPath          = outDir +yrFirst+"_"+yrLast+"_"+"obs"+trend +"SON-S-O-N_maxTausmap_lr"+stdfx+region+"AusMT_siglvl"+siglvl
 wks              = gsn_open_wks(outType, outPath)

 wks      = gsn_open_wks(outType, outPath)
 plots    = new(4,graphic)


do m     = 0, dimsizes(mons)-1

  
   M     = m + 7
  mon    = mons(m)        ; for files
  month  = months(m)
  print("month is "+ mon) 
 if mon.eq."SON" then
  tam    = month_to_season(ta,mon)
  mts    = month_to_season(mt,mon)  
 else
  tam    = ta(M::12,:,:)
  mts    = mt(M::12)
 end if

 ; ------- detrend ------
  mtsd  = mts
  tad   = tam

  if dtrnd.eq."True" then
   mtsd   = 0.
   tad   = 0.
    x     = ispan(1, dimsizes(mts), 1)
    ;printVarSummary(x)
    mtsd  = dtrend_msg_n(x,mts,False,False,0)
    tad  = dtrend_msg_n(x,tam,False,False,0)
    copy_VarMeta(tam(:,:,:),tad)
    delete(x)
  end if
  delete(tam)
  delete(mts)

  mtssd  = mtsd
  if stdise.eq."True" then
   mtssd  = dim_standardize_n_Wrap(mtsd,0,0)
  end if
  delete(mtsd)

  rmaxt   = regCoef_n(mtssd,tad,0,0)
  copy_VarCoords(tad(0,:,:),rmaxt)
  delete(tad)

 ;------------ Significance using 2-tailed Student's t-test ----------

 tvalM   = onedtond(rmaxt@tval, dimsizes(rmaxt))         ; Output puts tval and nptxy into 1D arrays
 dfM     = onedtond(rmaxt@nptxy, dimsizes(rmaxt)) -2     ; of size nlat*nlon
 b       = tvalM                                     ; b must be same dimension as tval and df
 b       = 0.5
; p-values
 pM      = betainc(dfM/(dfM+tvalM^2), dfM/2.0, b)

; Mask for significance
 smaxt   = rmaxt
 smaxt   = mask(rmaxt, pM.lt.siglvl, True); here( pM.lt.siglvl, rmaxt, 0.)
 copy_VarCoords(rmaxt,smaxt)
 delete(tvalM)
 delete(dfM)
 delete(b)
 delete(pM)

;------------------- Plotting ----------------------

  resP = True              ; panel resources
  res  = True 		   ; common resources   
  res1 = True		   ; max t
  resS = True		   ; stippling

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
  res1@gsnCenterString      = month
  
  resS			    = res
  resS@cnMonoFillColor      = True
  resS@cnFillPattern        = 11
  resS@cnFillDotSizeF       = .003
  resS@cnFillScaleF         = 0.7
 

  plot                      = gsn_csm_contour_map(wks,rmaxt,res1)
  plot1                     = gsn_csm_contour(wks, smaxt, resS)
  overlay(plot, plot1)
  delete(plot1)
  plots(m)            = plot
  delete(plot)
  delete(rmaxt)
  delete(smaxt)
 end do		; month loop

  resP                     = True
  resP@gsnPanelFigureStringsFontHeightF = 0.02
  resP@gsnPanelFigureStrings       = (/"a","b","c","d"/);,"e","f","g","h","i","j","k","l"/) ; add strings to panel
  resP@amJust                      = "TopLeft"
  resP@gsnPanelLabelBar         =  True
  resP@gsnMaximize              = True
  resP@gsnFrame                 = False
  resP@gsnPanelLeft             = 0.02
  resP@gsnPanelBottom           = 0.08
  resP@gsnPanelSave             = True  ; Save the state of the paneled plots so we can
                                        ; query for text strings locations.
  resP@lbLabelStride               = 1       ; every other label

  gsn_panel(wks, plots, (/2,2/), resP)

;**********************************************************************
; Add rotated text strings on left side of paneled plots.
; Use the resized plots to determine the position of the titles
;**********************************************************************
 ;pos1 = get_title_position(plots(0))         ; 1st row leftmost plot
 ;pos2 = get_title_position(plots(3))         ; 2nd row leftmost plot
 ;pos3 = get_title_position(plots(6)) 
 ;pos4 = get_title_position(plots(9))
 pos5 = get_label_position(plots(3))         ; last plot (for positioning label)
 ;pos4 = get_label_position(plots(11))
 txres               = True
 txres@txFontHeightF = 0.02
 txres@txAngleF      = 90.
 ;gsn_text_ndc(wks, "SW low",   pos1(0), pos1(1), txres)
 ;gsn_text_ndc(wks, "SE low",   pos2(0), pos2(1), txres)
 ;gsn_text_ndc(wks, "Z200 Bight",   pos3(0), pos3(1), txres)
 ;gsn_text_ndc(wks, "Tasman Sea High",   pos4(0), pos4(1), txres)
 txres@txAngleF      = 0.
 gsn_text_ndc(wks, "~S~o~N~C", pos5(0), pos5(1), txres)
 frame(wks)

 end do		; region loop

 break
 end do         ; standardisation loop
 break
 end do         ; trend loop
end



















