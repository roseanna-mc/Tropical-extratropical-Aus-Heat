; Usage NCL

; 16/9
; tidying up
; Using ERSST V5 and E5 SAM
; This option has just max t regs

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
  pos = (/vpx+0.285,vpy-0.085/)          ; attempted for side panel
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
 regions   = (/"Aus","SW","SE"/)         ; which regions do I take MT time series of?
 regionSts = (/"", "SW", "SE"/)          ; for plot
 stds      = (/"False","True"/)          ; Standardise index or not?

 gspac     = 1				 ; get every gspac'd lat lon in AWAP data
 siglvl    = 0.05
 
;-------------------------- File options -----------------------
 outType = "png"
 obsDir  = "/g/data/w97/rm8168/data/obs/"
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

 ; era5 sam time series
 sfil   = obsDir + "1979_2019_era5_sam_x1.txt"
 ncol   = 3                    ; years, months, sam
 nrows  = (2019 - 1979)*12 + 12
 allsam = asciiread(sfil,(/nrows,ncol/),"float")	;[492] x [3]
 ;printVarSummary(allsam)
 sams   = ((allsam(moStrtE:moStopE,2)))*-1.
 copy_VarCoords(tanoms(:,0,0),sams)
 delete(sfil)
 delete(ncol)
 delete(nrows)
 printVarSummary(sams)

 tfil    = obsDir + "tpiInd_ERSSTv5.txt"
 tstrt   = (yrFirst - 1891)*12
 tstop   = (yrLast - 1891)*12+11
 nrows   = (2019 - 1891 + 1 )*12 + 4    ; goes to April 2020
 ncol    = 6                            ; yr mn tri_c tri_w tri_e tpi
 alltp   = asciiread(tfil,(/nrows,ncol/),"float")
 alltpi  = (alltp(tstrt:tstop,5))*-1.
 copy_VarCoords(tanoms(:,0,0),alltpi)
 ;printVarSummary(alltpi)       ;[time | 480]
 ;printVarSummary(alltp)        ;[1552] x [6]
 delete(tfil)
 delete(tstrt)
 delete(tstop)
 delete(nrows)
 delete(ncol)
 delete(alltp)

; ------------------ mask --------------------
 tas   = mask(tanoms,conform(tanoms, lsA, (/1,2/)), 1)
 copy_VarMeta(tanoms,tas)
 delete(tanoms)
 delete(lsA)

 do av = 0,dimsizes(avgs)-1
  mavg = avgs(av)
  if mavg.eq."mthly" then
   mons   = (/"Sep", "Oct", "Nov"/)
   months = (/"September", "October", "November"/)
   tpim   = alltpi
   samm   = sams
   ta     = tas
   mStr   = "Monthly "
   mFl    = "mthly"
   
  else 
   mons   = (/"ASO", "SON","OND"/)
   months = (/"ASO", "SON","OND"/)
   mStr   = "3 Month-rolling avg " 
   mFl    = "3mthly"
   tpim   = month_to_season12(alltpi)	; 3 month rollowing averaging
   samm   = month_to_season12(sams)
   ta     = month_to_season12(tas)
 
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

 outPath          = outDir +yrFirst+"_"+yrLast+"_"+"obs"+trend +"S-O-N_maxTausmap_mlr"+stdfx+"_neg_TPIersstv5_SAMe5_siglvl"+siglvl
 wks              = gsn_open_wks(outType, outPath)

 wks      = gsn_open_wks(outType, outPath)
 plots    = new(6,graphic)


do m     = 0,2
   M     = m + 8
  mon    = mons(m)        ; for files
  month  = months(m)
  print("month is "+ mon) 
  samEm   = samm(M::12)
  tam     = ta(M::12,:,:)
  tpi     = tpim(M::12)
 ; ------- detrend ------
  tpid    = tpi
  samEd   = samEm
  tad     = tam
  if dtrnd.eq."True" then
   tpid   = 0.
   samEd  = 0.
   tad    = 0.
    x     = ispan(1, dimsizes(tpi), 1)
    ;printVarSummary(x)
    tpid   = dtrend_msg_n(x,tpi,False,False,0)
    samEd  = dtrend_msg_n(x,samEm,False,False,0)
    tad    = dtrend_msg_n(x,tam,False,False,0)
    copy_VarMeta(tpi,tpid)
    copy_VarMeta(samEm,samEd)
    copy_VarMeta(tam(:,:,:),tad)
    delete(x)
  end if
  delete(tam)

  tpisd  = tpid
  samsd  = samEd
  if stdise.eq."True" then
   tpisd  = dim_standardize_n_Wrap(tpid,0,0)
   samsd  = dim_standardize_n_Wrap(samEd,0,0)
  end if
  delete(tpid)
  delete(samEd)

  ntim      = dimsizes(tad&time)
  nlon      = dimsizes(tad&lon)
  nlat      = dimsizes(tad&lat)
  rctpi     = new((/nlat,nlon/),float,tad@_FillValue)
  rcsam     = rctpi
  ptpi      = rctpi
  psam      = rcsam
  r2        = rcsam
  ;create array for the 2 predictors (tpi, sam)
  xp      = new((/ntim,2/),typeof(tpisd))
  xp(:,0) = tpisd
  xp(:,1) = samsd  

  do la     = 0, nlat-1
  do lo     = 0, nlon-1
    ; bvar(yintercept, reg coef1, regcoef2, regcoef3)
    if all(ismissing(tad(:,la,lo))) then
	; regmultilinstats can't do missing values, which maxT has because it the land was masked
    rctpi(la,lo) = 0.
    rcsam(la,lo) = 0.
   else
    bt            = reg_multlin_stats(tad(:,la,lo),xp,True)
    rctpi(la,lo) = bt(1)
    rcsam(la,lo) = bt(2)
    pval         = bt@pval
    ;printVarSummary(pval)
    ptpi(la,lo)  = pval(1)
    psam(la,lo)  = pval(2)
    r2(la,lo)    = bt@r2
    delete(bt)
   end if
  end do
 end do
 delete(xp)
 
 copy_VarCoords(tad(0,:,:),rctpi)
 copy_VarCoords(tad(0,:,:),rcsam)
 copy_VarCoords(tad(0,:,:),r2)
 rctpi@long_name = ""
 rcsam@long_name = ""
 r2@long_name    = ""
 delete(tad)
 delete(tpisd)
 delete(samsd)

 ;mask for significance
 stpi     = rctpi
 ssam     = rcsam
 stpi     = mask(stpi, ptpi.lt.siglvl, True)
 ssam     = mask(ssam, psam.lt.siglvl, True)
 copy_VarCoords(rctpi,stpi)
 copy_VarCoords(rctpi,ssam)

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
  res@gsnMaximize           = False    ; Maximize in frame
  res@cnLineLabelsOn        = False
  res@NoDataLabel           = True            ; Don't put label on
  res@cnLinesOn             = False           ; turn off contour lines
  res@cnFillOn              = True            ; Turn on fill True
  res@gsnDraw               = False          ; do not draw the plot
  res@gsnFrame              = False          ; do not advance the frame
  res@lbLabelBarOn          = False
  res@cnInfoLabelOn         = False
  res@gsnStringFontHeightF  = 0.04       	; make all font size bigger
  res@gsnLeftStringOrthogonalPosF  = -0.15	; move strings into plots
  res@gsnLeftStringParallelPosF    = 0.04
  res@gsnRightStringParallelPosF   = 0.96
  res@gsnRightStringOrthogonalPosF = -0.15
  res@gsnLeftString	    = ""
  res@gsnRightString        = ""
  res@gsnCenterString       = ""
  
  res1			    = res
  res1@cnLevelSelectionMode = "ManualLevels"
  res1@cnFillPalette        = "CBR_coldhot"
  res1@cnMonoLineColor      = False
  res1@cnMinLevelValF       = -1.2
  res1@cnMaxLevelValF       = 1.2
  res1@cnLevelSpacingF      = .2
 
  resS			    = res
  resS@cnMonoFillColor      = True
  resS@cnFillPattern        = 11
  resS@cnFillDotSizeF       = .003
  resS@cnFillScaleF         = 0.7

  res1@gsnCenterString      = "" 
  plot                      = gsn_csm_contour_map(wks,rctpi,res1)
  plot1                     = gsn_csm_contour(wks, stpi, resS)
  overlay(plot, plot1)
  delete(plot1)
  plots(m+3)                = plot
  delete(plot)

  res1@gsnCenterString      = month
  plot                      = gsn_csm_contour_map(wks,rcsam,res1)
  plot1                     = gsn_csm_contour(wks, ssam, resS)
  overlay(plot, plot1)
  delete(plot1)
  plots(m)            = plot
  delete(plot)


 end do		; month loop

  resP                     = True
  resP@gsnPanelFigureStringsFontHeightF = 0.017
  resP@gsnPanelFigureStrings       = (/"a","b","c","d","e","f"/) ; add strings to panel
  resP@amJust                      = "TopLeft"
  resP@gsnPanelLabelBar         =  True
  resP@lbOrientation	 	= "Vertical"
  resP@gsnMaximize    		= True
  resP@gsnFrame       		= False
  resP@gsnPanelLeft   		= 0.023
  resP@gsnPanelBottom 		= 0.08
  resP@gsnPanelSave   		= True  ; Save the state of the paneled plots so we can
                                  	; query for text strings locations. 
  resP@lbLabelStride               = 1       ; every other label

  gsn_panel(wks, plots, (/2,3/), resP)

;**********************************************************************
; Add rotated text strings on left side of paneled plots.
; Use the resized plots to determine the position of the titles
;**********************************************************************
 pos1 = get_title_position(plots(0))         ; 1st row leftmost plot
 pos2 = get_title_position(plots(3))         ; 2nd row leftmost plot
 pos4 = get_label_position(plots(2))         ; last plot (for positioning label)

 txres               = True
 txres@txFontHeightF = 0.017
 txres@txAngleF      = 90.
 gsn_text_ndc(wks, "SAMx-1",   pos1(0), pos1(1), txres)
 gsn_text_ndc(wks, "TPIx-1",   pos2(0), pos2(1), txres)
 txres@txAngleF      = 0.
 txres@txFontHeightF = 0.015
 gsn_text_ndc(wks, "~S~o~N~C", pos4(0), pos4(1), txres)
 frame(wks)

 break
 end do         ; standardisation loop
 break
 end do         ; trend loop
 break
 end do         ; month-averages loop
end



















