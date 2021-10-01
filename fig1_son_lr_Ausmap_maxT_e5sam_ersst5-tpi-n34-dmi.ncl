; Usage NCL
; 11/9
; son reg vs all drivers

; Using ERSST V5 and E5 SAM
; This option has just max t regs

; updating before submission

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
  ;pos = (/vpx+0.285,vpy-0.085/)          ; attempted for side panel
  ;pos = (/vpx+0.22,vpy-vph-0.03/)      ; for bottom panel
  pos = (/vpx+.09,vpy-vph-0.06/)
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
 
 mons      = (/"SON", "JJA", "DJF", "MAM"/)
 months    = (/"Spring", "Winter", "Summer", "Autumn"/)

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

  ; n34
  sfil   = obsDir + "1979_2019_ERSSTv5_n34"
  ncol   = 3                    ; years, months, sam
  nrows  = (2019 - 1979)*12 + 12
  aln34  = asciiread(sfil,(/nrows,ncol/),"float")
  alln34 = aln34(:,2)
  printVarSummary(alln34)
  copy_VarCoords(tanoms(:,0,0),alln34)
  delete(sfil)
  delete(ncol)
  delete(nrows)
  delete(aln34)

  ; DMI
  sfil   = obsDir + "1979_2019_ERSSTv5_dmi"
  ncol   = 3                    ; years, months, sam
  nrows  = (2019 - 1979)*12 + 12
  aldmi  = asciiread(sfil,(/nrows,ncol/),"float")
  alldmi = aldmi(:,2)
  copy_VarCoords(tanoms(:,0,0),alldmi)
  delete(sfil)
  delete(ncol)
  delete(nrows)
  delete(aldmi)

; ------------------ mask --------------------
 tas   = mask(tanoms,conform(tanoms, lsA, (/1,2/)), 1)
 copy_VarMeta(tanoms,tas)
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

 do m    = 0, dimsizes(mons)-1 ; loop through months
  mon    = mons(m)        ; for files
  month  = months(m)      ; for titles
  print("month is "+ month)

  tam = month_to_season(tas,mon)
  tpi = month_to_season(alltpi,mon)
  sam = month_to_season(sams,mon)
  n34 = month_to_season(alln34,mon)
  dmi = month_to_season(alldmi,mon)


 outPath          = outDir +yrFirst+"_"+yrLast+"_"+"obs"+trend +m+"_"+mon+"_maxTausmap_lr"+stdfx+"_neg_SAMe5_ersstV5-tpi-n34-dmi_siglvl"+siglvl
 wks              = gsn_open_wks(outType, outPath)

 wks      = gsn_open_wks(outType, outPath)
 plots    = new(5,graphic)

 ; ------- detrend ------
  tpid    = tpi
  samEd   = sam
  tad     = tam
  if dtrnd.eq."True" then
   tpid   = 0.
   samEd  = 0.
   tad    = 0.
    x     = ispan(1, dimsizes(tpi), 1)
    ;printVarSummary(x)
    tpid   = dtrend_msg_n(x,tpi,False,False,0)
    samEd  = dtrend_msg_n(x,sam,False,False,0)
    tad    = dtrend_msg_n(x,tam,False,False,0)
    n34d   = dtrend_msg_n(x,n34,False,False,0)
    dmid   = dtrend_msg_n(x,dmi,False,False,0)
    copy_VarMeta(tpi,tpid)
    copy_VarMeta(sam,samEd)
    copy_VarMeta(tam(:,:,:),tad)
    delete(x)
  end if
  delete(tam)
  delete(tpi)
  delete(sam)
  delete(n34)
  delete(dmi)

  tpisd  = tpid
  samsd  = samEd
  n34sd  = n34d
  dmisd  = dmid
  if stdise.eq."True" then
   tpisd  = dim_standardize_n_Wrap(tpid,0,0)
   samsd  = dim_standardize_n_Wrap(samEd,0,0)
   n34sd = dim_standardize_n_Wrap(n34d,0,0)
   dmisd = dim_standardize_n_Wrap(dmid,0,0)
  end if
  delete(tpid)
  delete(samEd)
  delete(n34d)
  delete(dmid)

 rctpi = regCoef_n(tpisd,tad,0 ,0)
 rcsam = regCoef_n(samsd,tad,0 ,0)
 rcn34 = regCoef_n(n34sd,tad,0 ,0)
 rcdmi = regCoef_n(dmisd,tad,0 ,0)
 copy_VarCoords(tad(0,:,:),rctpi)
 copy_VarCoords(tad(0,:,:),rcsam)  
 copy_VarCoords(tad(0,:,:),rcn34)
 copy_VarCoords(tad(0,:,:),rcdmi)
 rctpi@long_name = ""
 rcsam@long_name = ""
 rcn34@long_name = ""
 rcdmi@long_name = ""
 delete(tad)
 delete(tpisd)
 delete(samsd)
 delete(n34sd)
 delete(dmisd)

 tval     = onedtond(rctpi@tval,dimsizes(rctpi))
 df       = onedtond(rctpi@nptxy,dimsizes(rctpi))-2
 b        = tval
 b        = 0.5
 p        = betainc(df/(df+tval^2), df/2.0, b)
 stpi     = mask(rctpi, p.lt.siglvl, True)
 delete(tval)
 delete(df)
 delete(p)

 tval     = onedtond(rcsam@tval,dimsizes(rcsam))
 df       = onedtond(rcsam@nptxy,dimsizes(rcsam))-2
 p        = betainc(df/(df+tval^2), df/2.0, b)
 ssam     = mask(rcsam, p.lt.siglvl, True)
 delete(tval)
 delete(df)
 delete(p)

 tval     = onedtond(rcn34@tval,dimsizes(rcn34))
 df       = onedtond(rcn34@nptxy,dimsizes(rcn34))-2
 p        = betainc(df/(df+tval^2), df/2.0, b)
 sn34     = mask(rcn34, p.lt.siglvl, True)
 delete(tval)
 delete(df)
 delete(p)

 tval     = onedtond(rcdmi@tval,dimsizes(rcdmi))
 df       = onedtond(rcdmi@nptxy,dimsizes(rcdmi))-2
 p        = betainc(df/(df+tval^2), df/2.0, b)
 sdmi     = mask(rcdmi, p.lt.siglvl, True)
 delete(tval)
 delete(df)
 delete(p)
 delete(b)

 copy_VarCoords(rctpi,stpi)
 copy_VarCoords(rctpi,ssam)
 copy_VarCoords(rctpi,sn34)
 copy_VarCoords(rctpi,sdmi)
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
  res@gsnStringFontHeightF  = 0.025       	; make all font size bigger
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

  plot                      = gsn_csm_contour_map(wks,rctpi,res1)
  plot1                     = gsn_csm_contour(wks, stpi, resS)
  overlay(plot, plot1)
  delete(plot1)
  plots(2)                = plot
  delete(plot)

  plot                      = gsn_csm_contour_map(wks,rcsam,res1)
  plot1                     = gsn_csm_contour(wks, ssam, resS)
  overlay(plot, plot1)
  delete(plot1)
  plots(1)            = plot
  delete(plot)

  plot                      = gsn_csm_contour_map(wks,rcn34,res1)
  plot1                     = gsn_csm_contour(wks, sn34, resS)
  overlay(plot, plot1)
  delete(plot1)
  plots(3)                = plot
  delete(plot)

  plot                      = gsn_csm_contour_map(wks,rcdmi,res1)
  plot1                     = gsn_csm_contour(wks, sdmi, resS)
  overlay(plot, plot1)
  delete(plot1)
  plots(4)            = plot
  delete(plot)



  resP                     = True
  resP@gsnPanelFigureStringsFontHeightF = 0.013
  resP@gsnPanelFigureStrings       = (/"","e","h","k","n"/) ; add strings to panel
  resP@amJust                      = "TopLeft"
  resP@gsnPanelLabelBar         =  True
  ;resP@lbOrientation	 	= "Vertical"
  resP@gsnMaximize    		= True
  resP@gsnFrame       		= False
  resP@gsnPanelLeft   		= 0.02
  resP@gsnPanelBottom 		= 0.08
  resP@gsnPanelSave   		= True  ; Save the state of the paneled plots so we can
                                  	; query for text strings locations. 
  resP@lbLabelStride               = 1       ; every other label

  gsn_panel(wks, plots, (/5,1/), resP)

;**********************************************************************
; Add rotated text strings on left side of paneled plots.
; Use the resized plots to determine the position of the titles
;**********************************************************************
 pos4 = get_label_position(plots(4))         ; last plot (for positioning label)

 txres               = True
 txres@txFontHeightF = 0.018
 txres@txAngleF      = 90.
 ;gsn_text_ndc(wks, "SAM",   pos1(0), pos1(1), txres)
 ;gsn_text_ndc(wks, "TPI",   pos2(0), pos2(1), txres)
 txres@txAngleF      = 0.
 gsn_text_ndc(wks, "~S~o~N~C", pos4(0), pos4(1), txres)
 frame(wks)

 end do		; season loop

 break
 end do         ; standardisation loop
 break
 end do         ; trend loop
end



















