; Usage NCL

; 16/9
; some tidying up
; 200hPa Ks and WAF

; ERA5


load "~/raijin_home_2019-12-16/RossbyWaves/WaveAF3.nl"          ; Calculate Rossby wave flux
load "/home/565/rm8168/tropVextrop/rossby_wave/RWNKs2.nl"

;**********************************************************************
; Function to retrieve the location of a plot so we can calculate
; a location for a title on the left side of the plot.
;**********************************************************************
function get_title_position(plot)
local vpy, vpx, vph
begin
  getvalues plot
      "vpYF"       : vpy
      "vpXF"       : vpx
      "vpHeightF"  : vph
  end getvalues
  pos = (/vpx*0.75-0.025,vpy-(vph/2.)/)
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
  pos = (/vpx+0.2,vpy-vph-0.027/)
  return(pos)
end

begin
;--------------------- Set options -------------------------
 yrStrt  = 1981                          ; First year of climatology
 yrStop  = 2010                          ; Last year of climatology
 yrFirst = 1979                          ; ERAI data 1979 to
 yrLast  = 2019                          ; August 2019

 indStop = yrStop - yrFirst               ; Index of last year of climatology
 indStrt = yrStrt - yrFirst
 moStrtE = (yrFirst - 1979)*12            ; First month of climatology index for ERAI
 moStopE = (yrLast - 1979)*12 + 11
 moStrtC = (yrStrt - yrFirst)*12
 moStopC = (yrStop - yrStrt)*12 + 11     ; Last month of climatology
 moStrtT = (yrFirst - 1911)*12            ; First month of climatology for AWAP
 moStopT = (yrLast - 1911)*12 + 11       ; Last month of anomalies for AWAP
 moStrtH = (yrFirst - 1870)*12            ; First month (index) to use in Hurrell extended dataset
 moLastH = (yrLast - 1870)*12 + 11       ; Last month (index) to use in Hurrell extended dataset

 rad   = 4.0*atan(1.0)/180.0

 regions   = (/"Aus","SW","SE","N"/)                    ; which regions do I take MT time series of?
 regionSts = (/"", "SW", "SE","N"/)          ; for plot
 stds      = (/"False","True"/)          ; Standardise index or not
 avgs      = (/"mthly","3mthly"/)        ; Monthly or 3-month rolling average?
 dtrns     = (/"False", "True"/)         ; Detrended ("True") or whole data ("False")?

 mons      = (/"Sep", "Oct", "Nov"/)
 months    = (/"September", "October", "November"/)

 lvl       = 200.
 siglvl    = 0.05
 stdise    = stds(1)
 dtrnd     = dtrns(1)
 
 ; did not get improved results by using other levels; 500hpa is good enough
 wmin      = 85000.                      ; height range for omega (height in Pa)
 wmax      = 50000.
 wminS     = 850                         ; for files
 wmaxS     = 500

 gsp       = 2

;-------------------------- File options -----------------------
 outType = "png"
 outDir  = "/g/data3/w97/rm8168/data/tropVextrop/withWS/"
 era5Dir = "/g/data/eg3/rm8168/data/"
 obsDir  = "/g/data/w97/rm8168/data/obs/"
;------------------ Get data ---------------------
 ; 850 u
  ufil = era5Dir + "era5_u200_1979-2020.nc"
  ufs  = addfile(ufil,"r")
  u2   = short2flt(ufs->u(moStrtE:moStopE,{0:-70.:gsp},::gsp))  ; lon: [ 0..358.75]
  ;u2   = short2flt(ufs->u(moStrtE:moStopE,::gsp,::gsp))
  delete(ufil)
  delete(ufs)
  u2cmons   = clmMonTLL(u2(moStrtC:moStopC,:,:))
  u2cmons@_FillValue = 9.96921e+36
  printVarSummary(u2cmons)

 ; 850 v
  vfil = era5Dir + "era5_v200_1979-2020.nc"
  vfs  = addfile(vfil,"r")
  v2   = short2flt(vfs->v(moStrtE:moStopE,{0:-70.:gsp},::gsp));,{40:240:gsp}))
  ;v2   = short2flt(vfs->v(moStrtE:moStopE,::gsp,::gsp))
  delete(vfil)
  delete(vfs)
  v2cmons   = clmMonTLL(v2(moStrtC:moStopC,:,:))
  v2cmons@_FillValue = 9.96921e+36

  ;z200
  zfil = era5Dir + "era5_zv200_1979-2020.nc"
  zfs  = addfile(zfil,"r")
  Z200 = short2flt(zfs->z(moStrtE:moStopE,{0:-70.:gsp},::gsp)) ;,{40:240:gsp}))
  ;Z200 = short2flt(zfs->z(moStrtE:moStopE,::gsp,::gsp))
  z200  = Z200/9.81
  copy_VarMeta(Z200, z200)
  z200@units = "m"
  delete(zfil)
  delete(Z200)
  zcmons = clmMonTLL(z200(moStrtC:moStopC,:,:))
  zanoms = calcMonAnomTLL(z200,zcmons)
  printVarSummary(zanoms)                       ;[time | 480] x [lat | 121] x [lon | 240]
  delete(zcmons)
  delete(z200)
  zanoms@_FillValue = 9.96921e+36
  printVarSummary(zanoms)

 lat   = zfs->latitude({0:-70.:gsp})
 lon   = zfs->longitude(::gsp)
 delete(zfs)

  ; max T time series
  mtfil  = obsDir + "1979_2019_A_SW_SE_N_maxT.txt"
  ncol   = 6                    ; yrs, ms, aus, sw, se, n
  nrows  = (2019 - 1979)*12 + 12
  allmt  = asciiread(mtfil,(/nrows,ncol/),"float")
  printVarSummary(allmt)                ; [491] x [6]
  Amts   = allmt(moStrtE:moStopE,2)
  SWmts  = allmt(moStrtE:moStopE,3)
  SEmts  = allmt(moStrtE:moStopE,4)
  Nmts   = allmt(moStrtE:moStopE,5)
  copy_VarCoords(zanoms(:,0,0),Amts)
  copy_VarCoords(zanoms(:,0,0),SWmts)
  copy_VarCoords(zanoms(:,0,0),SEmts)
  copy_VarCoords(zanoms(:,0,0),Nmts)
  delete(mtfil)
  delete(ncol)
  delete(nrows)
  printVarSummary(Amts)

  ; era5 sam time series
  sfil   = obsDir + "1979_2019_era5_sam_x1.txt"
  ncol   = 3                    ; years, months, sam
  nrows  = (2019 - 1979)*12 + 12
  allsam = asciiread(sfil,(/nrows,ncol/),"float")
  sams   = (allsam(moStrtE:moStopE,2))*-1.
  copy_VarCoords(zanoms(:,0,0),sams)
  delete(sfil)
  delete(ncol)
  delete(nrows)
  printVarSummary(sams)
  delete(allsam)

 ; tpi
 tfil    = obsDir + "tpiInd_HadISST.txt"
 tstrt   = (yrFirst - 1891)*12
 tstop   = (yrLast - 1891)*12+11
 nrows   = (2019 - 1891 + 1 )*12 + 4    ; goes to April 2020
 ncol    = 6                            ; yr mn tri_c tri_w tri_e tpi
 alltp   = asciiread(tfil,(/nrows,ncol/),"float")
 alltpi  = (alltp(tstrt:tstop,5))*-1.
 copy_VarCoords(zanoms(:,0,0),alltpi)
 printVarSummary(alltpi)       ;[time | 480]
 ;printVarSummary(alltp)        ;[1552] x [6]
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
   mt      = Mmts
  end if
  end if
  end if
  end if

 outPath = outDir + "obs" + trend +region + "_" + stdfx + "lin-MT-mlrTPI-SAMvs_ERA5_WAF_Ks_siglvl"+siglvl
 wks     = gsn_open_wks(outType, outPath)
 plots   = new(9, graphic)
 

 do m    = 0, dimsizes(mons)-1 ; loop through months
  mon    = mons(m)        ; for files
  month  = months(m)	  ; for titles
  print("month is "+ month)

  M      = m + 8

  za  = zanoms(M::12,:,:)
  u2c = u2cmons(M,:,:)
  v2c = v2cmons(M,:,:)
  ta  = mt(M::12)
  tpi = alltpi(M::12) - dim_avg_n_Wrap(alltpi(M::12),0)
  sam = sams(M::12) - dim_avg_n_Wrap(sams(M::12),0)
  copy_VarCoords(alltpi(0::12),tpi)
  copy_VarCoords(sams(0::12),sam)

 ; detrend
  if dtrnd.eq."True" then
   x    = ispan(1,dimsizes(ta),1)
   zad  = dtrend_msg_n(x,za,False,False,0)
   tad  = dtrend_msg_n(x,ta,False,False,0)
   samd = dtrend_msg_n(x,sam,False,False,0)
   tpid = dtrend_msg_n(x,tpi,False,False,0)
   copy_VarMeta(za,zad)
   copy_VarMeta(ta,tad)
   copy_VarMeta(sam,samd)
   copy_VarMeta(tpi,tpid)
   delete(x)
  else
   zad  = za
   tad  = ta
   samd = sam
   tpid = tpi
  end if
  delete(ta)
  delete(za)
  delete(tpi)
  delete(sam)

  if stdise.eq."True" then
   print("standardising drivers")
   tads  = dim_standardize_n_Wrap(tad,0,0)
   samsd = dim_standardize_n_Wrap(samd,0,0)
   tpisd = dim_standardize_n_Wrap(tpid,0,0)
  else
   print("not standardising drivers")
   tads  = tad
   samsd = samd
   tpisd = tpid
  end if
  delete(tad)
  delete(tpid)
  delete(samd)

 ;--------------- linear regression ---------------------
  rcZ  = regCoef_n( tads, zad, 0, 0)
  copy_VarCoords(zad(0,:,:), rcZ)
  printVarSummary(rcZ)          ; [lat | 121] x [lon | 240]
  delete(tads)

; ---------- multilinear regression ---------------
  ntim     = dimsizes(zad&time)
  nlon     = dimsizes(zad&longitude)
  nlat     = dimsizes(zad&latitude)
  zrctpi   = new((/nlat,nlon/),float,zad@_FillValue)
  zrcsam   = zrctpi
  zptpi    = zrctpi
  zpsam    = zrcsam

  ;create array for the 2 predictors (tpi, sam)
  xp      = new((/ntim,2/),typeof(tpisd))
  xp(:,0) = tpisd
  xp(:,1) = samsd
  do la     = 0, nlat-1
  do lo     = 0, nlon-1
    ; bvar(yintercept, reg coef1, regcoef2, regcoef3)
   zbt           = reg_multlin_stats(zad(:,la,lo),xp,True)
   zrctpi(la,lo) = zbt(1)
   zrcsam(la,lo) = zbt(2)
   zpval         = zbt@pval
   zptpi(la,lo)  = zpval(1)
   zpsam(la,lo)  = zpval(2)
   delete(zbt)
  end do
 end do
 delete(xp)
 copy_VarCoords(zad(0,:,:),zrctpi)
 copy_VarCoords(zad(0,:,:),zrcsam)
 delete(tpisd)
 delete(samsd)
 delete(zad)

;------------- calculate WAF---------------
  ;lat      = u2c&lat
  ;lon      = u2c&lon
  RWFmt    = WaveAF3(rcZ,u2c,v2c,lvl,lat,lon)
  Fxmt     = RWFmt[0]
  Fymt     = RWFmt[1]
  delete(RWFmt)
  RWFtpi   = WaveAF3(zrctpi,u2c,v2c,lvl,lat,lon)
  Fxtpi    = RWFtpi[0]
  Fytpi    = RWFtpi[1]
  delete(RWFtpi)
  RWFsam   = WaveAF3(zrcsam,u2c,v2c,lvl,lat,lon)
  Fxsam    = RWFsam[0]
  Fysam    = RWFsam[1]
  delete(RWFsam)
  copy_VarCoords(zrctpi,Fxtpi)
  copy_VarCoords(zrctpi,Fxsam)
  copy_VarCoords(zrctpi,Fytpi)
  copy_VarCoords(zrctpi,Fysam)
  copy_VarCoords(rcZ,Fxmt)
  copy_VarCoords(rcZ,Fymt)
  ;printVarSummary(rcZ)
  ;printVarSummary(Fxmt)
  ;printVarSummary(Fxsam)
  delete(rcZ)
  delete(zrctpi)
  delete(zrcsam)

  Fxmt@long_name   = "" 
  Fymt@long_name   = "" 
  Fxtpi@long_name  = "" 
  Fytpi@long_name  = "" 
  Fxsam@long_name  = "" 
  Fysam@long_name  = "" 
  Fxmt@units       = "" 
  Fymt@units       = "" 
  Fxtpi@units      = "" 
  Fytpi@units      = ""
  Fxsam@units      = "" 
  Fysam@units      = ""

  slon   = 15.           ; smooth with running 15 deg longitude. No smooth if set 0. Recommend 15-30
  slat   = 5.            ; same but for smooth with running 5 deg latitude. No smooth if set 0. Recommend 0
  lk     = RWNKs2(u2c,v2c,lat,lon,slat,slon)
  Ks     = lk[0]
  Ks@long_name     = "" 
; ----------------- Plotting -----------------------
  res   = True		    ; Options for common resources
  resZs = True		    ; Options for sig z
  resZ  = True		    ; Option for vectors

  res@gsnAddCyclic          = True
 
  res@gsnMaximize           = False    		 ; Maximize in frame
  res@cnLineLabelsOn        = False
  ;res@NoDataLabel           = True           	 ; Don't put label on
  res@cnLinesOn             = True          	 ; turn on contour lines
  res@cnFillOn              = False           	 ; Turn on fill True
  res@gsnDraw               = False          	 ; do not draw the plot
  res@gsnFrame              = False          	 ; do not advance the frame
  res@lbLabelBarOn          = False
  res@cnInfoLabelOn         = False
  res@gsnStringFontHeightF  = 0.05        	 ; make all font size bigger
  res@gsnRightStringFontHeightF  = 0.04
  res@cnLevelSelectionMode  = "ManualLevels"
  res@gsnContourZeroLineThicknessF = 0.
  res@gsnContourNegLineDashPattern = 1
  res@gsnLeftString	    = ""
  res@gsnRightString        = ""
  res@gsnCenterString       = ""

  resZs                       = res
  resZs@pmTickMarkDisplayMode = "Always"
  resZs@mpFillOn              =  False          ; turn off map fill
  resZs@mpOutlineDrawOrder    = "PostDraw"      ; draw continental outline last
  resZs@mpMinLatF             = -70.            ; range to zoom in on
  resZs@mpMaxLatF             = 0.
  resZs@mpMinLonF             = 40.
  resZs@mpMaxLonF             = 240.
  resZs@mpCenterLonF          = 180.
  resZs@gsnAddCyclic          = True

  zmin                       = 0.
  zmax                       = 10.
  zstep                      = 1.
  resZs@cnMinLevelValF       = zmin
  resZs@cnMaxLevelValF       = zmax
  resZs@cnLevelSpacingF      = zstep
  resZs@cnLinesOn            = True           ; turn off contour lines
  resZs@cnFillOn             = True            ; Turn on fill True
  ;resZs@cnFillPalette       = "perc2_9lev"
  resZs@cnMonoLineColor      = True
  resZs@cnLineColor          = "grey22"

  resZs@lbLabelStride              = 2
  resZs@lbLabelFontHeightF         = 0.025
  resZs@pmLabelBarHeightF          = 0.2
  resZs@pmLabelBarWidthF           = 1.5
  resZs@lbOrientation              = "Horizontal"; "Vertical"        ; orientation
  resZs@pmLabelBarOrthogonalPosF   = 0.15       ; move label bar down
 
  resZ			      = res
  resZ@vcRefMagnitudeF       = .8               ; define vector ref mag
  resZ@vcRefLengthF          = .04             ; define length of vec ref
  resZ@vcRefAnnoOn           = True
  resZ@vcRefAnnoOrthogonalPosF = -0.32
  resZ@vcMinDistanceF          = 0.025  ; 017      ; thin vectors (small is more crowded)
  resZ@vcMonoLineArrowColor    = True
  resZ@vcLineArrowThicknessF   = 2.1   ;2.3
  resZ@vcGlyphOpacityF         = 1.
  resZ@vcLineArrowHeadMinSizeF = 0.005           ; keep arrow heads similar size.
  resZ@vcLineArrowHeadMaxSizeF = 0.010
  resZ@vcLabelFontHeightF      = 0.3
  resZ@vcRefAnnoString2        = ""		; default 'Refernce Vector" 
  resZs@gsnRightStringFontHeightF  = 0.15

  resZs@gsnCenterString             = month
  plot                              = gsn_csm_contour_map(wks,Ks, resZs)
  plotV				    = gsn_csm_vector(wks,Fxmt, Fymt,resZ)
  overlay(plot,plotV)
  plots(m)                          = plot
  delete(plot)
  delete(plotV)
  delete(Fxmt)
  delete(Fymt)

  resZs@gsnCenterString     = ""
  plot                      = gsn_csm_contour_map(wks,Ks, resZs)
  plotV                     = gsn_csm_vector(wks,Fxtpi, Fytpi,resZ)
  overlay(plot,plotV)
  plots(m + 6)              = plot
  delete(plot)
  delete(plotV)
  delete(Fxtpi)
  delete(Fytpi)
  resZs@lbLabelBarOn        = False      ; turn label back of for the las tplot

  plot                      = gsn_csm_contour_map(wks,Ks, resZs)
  plotV                     = gsn_csm_vector(wks,Fxsam, Fysam,resZ)
  overlay(plot,plotV)
  plots(m + 3)              = plot
  delete(plot)
  delete(Fxsam)
  delete(Fysam)
  delete(plotV)
 end do		; month loop

 resP                = True
 resP@gsnMaximize    = True
 resP@gsnFrame       = False
 resP@gsnPanelLeft   = 0.018
 resP@gsnPanelBottom = 0.08
 resP@gsnPanelSave   = True      ; Save the state of the paneled plots so we can
                                 ; query for text strings locations.
 resP@gsnPanelFigureStringsFontHeightF = 0.013
 resP@gsnPanelFigureStrings       = (/"a","b","c","d","e","f","h", "i", "j"/) ; add strings to panel
 resP@amJust                      = "TopLeft"
 resP@gsnPanelLabelBar            = True    ; add common colorbar

 gsn_panel(wks, plots, (/3,3/), resP)  ; plots
;**********************************************************************
; Add rotated text strings on left side of paneled plots.
; Use the resized plots to determine the position of the titles
;**********************************************************************
 pos1 = get_title_position(plots(0))         ; 1st row leftmost plot
 pos2 = get_title_position(plots(3))         ; 2nd row leftmost plot
 pos3 = get_title_position(plots(6))         ; 3rd row leftmost plot
 pos4 = get_label_position(plots(8))         ; last plot (for positioning label)
 txres               = True
 txres@txFontHeightF = 0.016
 txres@txAngleF      = 90.
 gsn_text_ndc(wks, "Max. T.",   pos1(0), pos1(1), txres)
 gsn_text_ndc(wks, "SAMx-1",   pos2(0), pos2(1), txres)
 gsn_text_ndc(wks, "TPIx-1", pos3(0), pos3(1), txres)
 txres@txFontHeightF = 0.013
 txres@txAngleF      = 0.
 gsn_text_ndc(wks, "Wave number", pos4(0), pos4(1), txres)
 frame(wks)



break
end do		; region loop

end




