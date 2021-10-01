; Usage NCL
; 11/9/21
; fine tuning before submission.

load "~/raijin_home_2019-12-16/RossbyWaves/WaveAF3.nl"          ; Calculate Rossby wave flux

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
  pos = (/vpx*0.75-0.028,vpy-(vph/2.)/)
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
  pos = (/vpx+.172,vpy-vph-0.06/)
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

 mons      = (/"SON", "JJA", "DJF", "MAM"/)
 months    = (/"Spring", "Winter", "Summer", "Autumn"/)

 lvl       = 200.
 siglvl    = 0.05
 stdise    = stds(1)
 dtrnd     = dtrns(1)

 gsp       = 2

 ; did not get improved results by using other levels; 500hpa is good enough
 wmin      = 85000.                      ; height range for omega (height in Pa)
 wmax      = 50000.
 wminS     = 850                         ; for files
 wmaxS     = 500
;-------------------------- File options -----------------------
 outType = "png"
 outDir  = "/g/data3/w97/rm8168/data/tropVextrop/withWS/"
 era5Dir = "/g/data/eg3/rm8168/data/"
 obsDir  = "/g/data/w97/rm8168/data/obs/"
;------------------ Get data ---------------------

 ; feature lat lons
 zblon = (/-30., -40., -40., -30., -30./)
 zblat = (/120., 120., 150., 150., 120./)
 selon = (/-45., -60., -60., -45., -45./)
 selat = (/160., 160., 200., 200., 160./)
 swlon = (/-35., -55., -55., -35., -35./)
 swlat = (/70., 70., 120., 120., 70./)
 tslon = (/-40., -20., -20., -40., -40./)
 tslat = (/150., 150., 170., 170., 150./)

; mech lat lons
 uvlon = (/-25., -45., -45., -25., -25./)
 uvlat = (/105., 105., 155., 155., 105./)
 wlon  = (/-15., -25., -25., -15., -15./)
 wlat  = (/120., 120., 155., 155., 120./)

 plotcyclic = True
 ; 850 u
  ufil = era5Dir + "era5_u200_1979-2020.nc"
  ufs  = addfile(ufil,"r")
  u2   = short2flt(ufs->u(moStrtE:moStopE,{0:-70.:gsp},::gsp));{40:240:gsp}))  ; lon: [ 0..358.75]
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
  delete(zfs)
  delete(Z200)
  zcmons = clmMonTLL(z200(moStrtC:moStopC,:,:))
  zanoms = calcMonAnomTLL(z200,zcmons)
  printVarSummary(zanoms)                       ;[time | 480] x [lat | 121] x [lon | 240]
  delete(zcmons)
  delete(z200)
  zanoms@_FillValue = 9.96921e+36
  printVarSummary(zanoms)

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
 tfil    = obsDir + "tpiInd_ERSSTv5.txt"
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

  ; n34
  sfil   = obsDir + "1979_2019_ERSSTv5_n34"
  ncol   = 3                    ; years, months, sam
  nrows  = (2019 - 1979)*12 + 12
  aln34  = asciiread(sfil,(/nrows,ncol/),"float")
  alln34 = aln34(:,2)
  printVarSummary(alln34)
  copy_VarCoords(zanoms(:,0,0),alln34)
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
  copy_VarCoords(zanoms(:,0,0),alldmi)
  delete(sfil)
  delete(ncol)
  delete(nrows)
  delete(aldmi)

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

 do m    = 0, dimsizes(mons)-1 ; loop through months
  mon    = mons(m)        ; for files
  month  = months(m)      ; for titles
  print("month is "+ month)

  za  = month_to_season(zanoms,mon)
  u2c = month_to_season(u2cmons,mon)
  v2c = month_to_season(v2cmons,mon)
  ta  = month_to_season(mt,mon)
  tpi = month_to_season(alltpi,mon)
  sam = month_to_season(sams,mon)
  n34 = month_to_season(alln34,mon)
  dmi = month_to_season(alldmi,mon)

 outPath = outDir + "obs" + trend +region + "_" +m+"_"+mon+"_"+ stdfx + "lr-MT-TPIerrst-SAMe5_N34_DMIvs_ERA5_HighCirc_siglvl"+siglvl
 wks     = gsn_open_wks(outType, outPath)
 plots   = new(5, graphic) 

; detrend
  if dtrnd.eq."True" then
   x    = ispan(1,dimsizes(ta),1)
   zad  = dtrend_msg_n(x,za,False,False,0)
   tad  = dtrend_msg_n(x,ta,False,False,0)
   samd = dtrend_msg_n(x,sam,False,False,0)
   tpid = dtrend_msg_n(x,tpi,False,False,0)
   n34d = dtrend_msg_n(x,n34,False,False,0)
   dmid = dtrend_msg_n(x,dmi,False,False,0)
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
   n34d = n34
   dmid = dmi
  end if
  delete(ta)
  delete(za)
  delete(tpi)
  delete(sam)
  delete(n34)
  delete(dmi)
  if stdise.eq."True" then
   print("standardising drivers")
   tads  = dim_standardize_n_Wrap(tad,0,0)
   samsd = dim_standardize_n_Wrap(samd,0,0)
   tpisd = dim_standardize_n_Wrap(tpid,0,0)
   n34sd = dim_standardize_n_Wrap(n34d,0,0)
   dmisd = dim_standardize_n_Wrap(dmid,0,0)
  else
   print("not standardising drivers")
   tads  = tad
   samsd = samd
   tpisd = tpid
   n34sd = n34d
   dmisd = dmid
  end if
  delete(tad)
  delete(tpid)
  delete(samd)
  delete(n34d)
  delete(dmid)
 ;--------------- linear regression ---------------------
  rcZmt = regCoef_n( tads, zad, 0, 0)
  copy_VarCoords(zad(0,:,:), rcZmt)
  ;printVarSummary(rcZmt)          ; [lat | 121] x [lon | 240]
  delete(tads)
  rcZsa = regCoef_n( samsd, zad, 0, 0)
  copy_VarCoords(zad(0,:,:), rcZsa)
  delete(samsd)
  rcZtp = regCoef_n( tpisd, zad, 0, 0)
  copy_VarCoords(zad(0,:,:), rcZtp)
  delete(tpisd)
  rcZn3 = regCoef_n( n34sd, zad, 0, 0)
  copy_VarCoords(zad(0,:,:), rcZn3)
  delete(n34sd)
  rcZdm = regCoef_n( dmisd, zad, 0, 0)
  copy_VarCoords(zad(0,:,:), rcZdm)
  delete(dmisd)

;------------- calculate WAF---------------
  lat      = u2c&latitude
  lon      = u2c&longitude
  RWFmt    = WaveAF3(rcZmt,u2c(0,:,:),v2c(0,:,:),lvl,lat,lon)
  Fxmt     = RWFmt[0]
  Fymt     = RWFmt[1]
  delete(RWFmt)
  RWFtpi   = WaveAF3(rcZtp,u2c(0,:,:),v2c(0,:,:),lvl,lat,lon)
  Fxtpi    = RWFtpi[0]
  Fytpi    = RWFtpi[1]
  delete(RWFtpi)
  RWFsam   = WaveAF3(rcZsa,u2c(0,:,:),v2c(0,:,:),lvl,lat,lon)
  Fxsam    = RWFsam[0]
  Fysam    = RWFsam[1]
  delete(RWFsam)
  RWFn34   = WaveAF3(rcZn3,u2c(0,:,:),v2c(0,:,:),lvl,lat,lon)
  Fxn34    = RWFn34[0]
  Fyn34    = RWFn34[1]
  delete(RWFn34)
  RWFdmi   = WaveAF3(rcZdm,u2c(0,:,:),v2c(0,:,:),lvl,lat,lon)
  Fxdmi    = RWFdmi[0]
  Fydmi    = RWFdmi[1]
  delete(RWFdmi)

  delete(lat)
  delete(lon)
  copy_VarCoords(rcZtp,Fxtpi)
  copy_VarCoords(rcZtp,Fxsam)
  copy_VarCoords(rcZtp,Fytpi)
  copy_VarCoords(rcZtp,Fysam)
  copy_VarCoords(rcZmt,Fxmt)
  copy_VarCoords(rcZmt,Fymt)
  copy_VarCoords(rcZmt,Fxn34)
  copy_VarCoords(rcZmt,Fyn34)
  copy_VarCoords(rcZmt,Fxdmi)
  copy_VarCoords(rcZmt,Fydmi)

  ;printVarSummary(rcZmt)
  ;printVarSummary(Fxmt)
  ;printVarSummary(Fxsam)

 ;------------ Significance using 2-tailed Student's t-test ----------

 ; mt
 tvalZ   = onedtond(rcZmt@tval, dimsizes(rcZmt)) 
 dfZ     = onedtond(rcZmt@nptxy, dimsizes(rcZmt)) -2 
 b       = tvalZ                                     ; b must be same dimension as tval and df
 b       = 0.5
; p-values
 pZ     = betainc(dfZ/(dfZ+tvalZ^2), dfZ/2.0, b)
 copy_VarCoords(rcZmt, pZ)
 delete(b)
 delete(tvalZ)
 delete(dfZ)
; Mask for significance
 mZmt   = rcZmt
 mZmt   = where( pZ.lt.siglvl, rcZmt, 0.)
 delete(pZ)

; sam
 tvalZ   = onedtond(rcZsa@tval, dimsizes(rcZsa))
 dfZ     = onedtond(rcZsa@nptxy, dimsizes(rcZsa)) -2
 b       = tvalZ                                     ; b must be same dimension as tval and df
 b       = 0.5
; p-values
 pZ     = betainc(dfZ/(dfZ+tvalZ^2), dfZ/2.0, b)
 copy_VarCoords(rcZsa, pZ)
 delete(b)
 delete(tvalZ)
 delete(dfZ)
; Mask for significance
 mZsa   = rcZsa
 mZsa   = where( pZ.lt.siglvl, rcZsa, 0.)
 delete(pZ)

; tpi
 tvalZ   = onedtond(rcZtp@tval, dimsizes(rcZtp))
 dfZ     = onedtond(rcZtp@nptxy, dimsizes(rcZtp)) -2
 b       = tvalZ                                     ; b must be same dimension as tval and df
 b       = 0.5
; p-values
 pZ     = betainc(dfZ/(dfZ+tvalZ^2), dfZ/2.0, b)
 copy_VarCoords(rcZtp, pZ)
 delete(b)
 delete(tvalZ)
 delete(dfZ)
; Mask for significance
 mZtp   = rcZtp
 mZtp   = where( pZ.lt.siglvl, rcZtp, 0.)
 delete(pZ)

; n34
 tvalZ   = onedtond(rcZn3@tval, dimsizes(rcZn3))
 dfZ     = onedtond(rcZn3@nptxy, dimsizes(rcZn3)) -2
 b       = tvalZ                                     ; b must be same dimension as tval and df
 b       = 0.5
; p-values
 pZ     = betainc(dfZ/(dfZ+tvalZ^2), dfZ/2.0, b)
 copy_VarCoords(rcZn3, pZ)
 delete(b)
 delete(tvalZ)
 delete(dfZ)
; Mask for significance
 mZn3   = rcZn3
 mZn3   = where( pZ.lt.siglvl, rcZn3, 0.)
 delete(pZ)

; dmi
 tvalZ   = onedtond(rcZdm@tval, dimsizes(rcZdm))
 dfZ     = onedtond(rcZdm@nptxy, dimsizes(rcZdm)) -2
 b       = tvalZ                                     ; b must be same dimension as tval and df
 b       = 0.5
; p-values
 pZ     = betainc(dfZ/(dfZ+tvalZ^2), dfZ/2.0, b)
 copy_VarCoords(rcZdm, pZ)
 delete(b)
 delete(tvalZ)
 delete(dfZ)
; Mask for significance
 mZdm   = rcZdm
 mZdm   = where( pZ.lt.siglvl, rcZdm, 0.)
 delete(pZ)

 rcZmt@long_name = ""
 rcZmt@units     = ""
 rcZtp@long_name = ""
 rcZsa@long_name = ""
 rcZn3@long_name = ""
 rcZdm@long_name = ""
 mZtp@long_name  = ""
 mZsa@long_name  = ""
 mZdm@long_name  = ""
 mZn3@long_name  = ""

; ------------------- pattern correlation ----------------
 clat  = cos(rcZmt&latitude*rad)
 copy_VarCoords(rcZmt(:,0),clat)
 			;cos(lat) weighting, uncentered
 zctpi = pattern_cor(rcZmt({-45:-5},{105:160}), rcZtp({-45:-5},{105:160}), clat({-45:-5}), 1)    
 zcsam = pattern_cor(rcZmt({-45:-5},{105:160}), rcZsa({-45:-5},{105:160}), clat({-45:-5}), 1)
 zcn34 = pattern_cor(rcZmt({-45:-5},{105:160}), rcZn3({-45:-5},{105:160}), clat({-45:-5}), 1)
 zcdmi = pattern_cor(rcZmt({-45:-5},{105:160}), rcZdm({-45:-5},{105:160}), clat({-45:-5}), 1)

; ----------------- Plotting -----------------------
  res   = True		    ; Options for common resources
  resZ  = True		    ; Options for not sig z and waf
  resZs = True		    ; Options for sig z
  plres = True              ; Polyline resources for shapes

/;
  print("MT waf")
  printMinMax(Fxmt,1)
  printMinMax(Fymt,1)
  print("SAM waf")
  printMinMax(Fxsam,1)
  printMinMax(Fysam,1)
  print("TPI waf")
  printMinMax(Fxtpi,1)
  printMinMax(Fytpi,1)
;/

  plres@gsLineColor         = "black"
  plres@gsLineThicknessF    = 3.5

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
  res@gsnStringFontHeightF  = 0.04       	 ; make all font size bigger
  res@cnLevelSelectionMode  = "ManualLevels"
  res@gsnContourZeroLineThicknessF = 0.
  res@gsnContourNegLineDashPattern = 1
  res@gsnLeftString	    = ""
  res@gsnRightString        = ""
  res@gsnCenterString       = ""
  res@gsnAddCyclic          = plotcyclic;True
 
  resZs                       = res
  resZs@pmTickMarkDisplayMode = "Always"
  resZs@mpFillOn              =  False          ; turn off map fill
  resZs@mpOutlineDrawOrder    = "PostDraw"      ; draw continental outline last
  resZs@mpMinLatF             = -70.            ; range to zoom in on
  resZs@mpMaxLatF             = 0.
  resZs@mpMinLonF             = 40.
  resZs@mpMaxLonF             = 240.
  resZs@mpCenterLonF          = 180.

  zmin                       = -50.
  zmax                       = 50.
  zstep                      = 5.
  resZs@cnMinLevelValF       = zmin
  resZs@cnMaxLevelValF       = zmax
  resZs@cnLevelSpacingF      = zstep
  resZs@cnLinesOn            = False           ; turn off contour lines
  resZs@cnFillOn             = True            ; Turn on fill True
  ;resZs@cnFillPalette       = "BlueDarkRed18"
  cmap                       = read_colormap_file("precip4_diff_19lev")
  resZs@cnFillPalette        = cmap(::-1,:)

  ; Set resources for when we turn on labelbar later
  ;resZs@lbTitleFontHeightF         = .025                 ; make title smaller
  ;resZs@lbTitleString              = "hPa"            ; title string
  ;resZs@lbTitlePosition            = "Bottom"            ; title position
  ;resZs@lbTitleDirection           = "Across"            ; title direction
  resZs@lbLabelStride              = 2
  resZs@lbLabelFontHeightF         = 0.025
  resZs@pmLabelBarHeightF          = 0.2
  resZs@pmLabelBarWidthF           = 1.5
  resZs@lbOrientation              = "Horizontal"; "Vertical"        ; orientation
  resZs@pmLabelBarOrthogonalPosF   = 0.1       ; move label bar down
 
  ; z200 and waf
  resZ			     = res
  resZ@cnMonoLineColor       = True  
  resZ@cnLineColor           = "grey22" ;span_color_rgba ("BlueDarkOrange18",colSpnz)
  resZ@cnMinLevelValF        = zmin
  resZ@cnMaxLevelValF        = zmax
  resZ@cnLevelSpacingF       = zstep
  resZ@gsnScalarContour      = True
  resZ@cnLineThicknessF      = 2.
  resZ@vcRefMagnitudeF       = .35               ; define vector ref mag
  resZ@vcRefLengthF          = .05              ; define length of vec ref
  resZ@vcRefAnnoOn           = True
  resZ@vcRefAnnoOrthogonalPosF = -0.35
  resZ@vcMinDistanceF          = 0.032;0.025        ; thin vectors (small is more crowded)
  resZ@vcMonoLineArrowColor    = True
  resZ@vcLineArrowColor	       = "grey27"
  resZ@vcLineArrowThicknessF   = 3. ;2.1   ;2.3
  resZ@vcGlyphOpacityF         = 1.
  resZ@vcLineArrowHeadMinSizeF = 0.00           ; keep arrow heads similar size.
  resZ@vcLineArrowHeadMaxSizeF = 0.025
  resZ@vcLabelFontHeightF      = 0.07
 
  resZs@gsnCenterString             = "Upper-level circulation"
  plot                              = gsn_csm_contour_map(wks, mZmt, resZs)
  plotMs                            = gsn_csm_vector_scalar(wks, Fxmt, Fymt, rcZmt, resZ)
  overlay(plot,plotMs)
  plots(0)                          = plot
  delete(plot)
  delete(plotMs)
  delete(rcZmt)
  delete(Fxmt)
  delete(Fymt)
  delete(mZmt)
 
  delete(resZs@gsnCenterString) ;    = ""
  ;resZs@gsnRightString     = "Corr: " +sprintf("%5.2f",zctpi)
  plot                      = gsn_csm_contour_map(wks, mZtp, resZs)
  plotMs                    = gsn_csm_vector_scalar(wks, Fxtpi, Fytpi, rcZtp, resZ)
  overlay(plot,plotMs)
  plots(2)                  = plot
  delete(plot)
  delete(plotMs)
  delete(rcZtp)
  delete(Fxtpi)
  delete(Fytpi)
  delete(mZtp)
  resZs@lbLabelBarOn        = False      ; turn label back of for the las tplot
 
  ;resZs@gsnRightString     = "Corr: " +sprintf("%5.2f",zcsam)
  plot                      = gsn_csm_contour_map(wks, mZsa, resZs)
  plotMs                    = gsn_csm_vector_scalar(wks,Fxsam,Fysam, rcZsa, resZ)
  overlay(plot,plotMs)
  plots(1)                  = plot
  delete(plot)
  delete(plotMs)
  delete(rcZsa)
  delete(Fxsam)
  delete(Fysam)
  delete(mZsa)

  ;resZs@gsnRightString     = "Corr: " +sprintf("%5.2f",zcn34)
  plot                      = gsn_csm_contour_map(wks, mZn3, resZs)
  plotMs                    = gsn_csm_vector_scalar(wks,Fxn34,Fyn34, rcZn3, resZ)
  overlay(plot,plotMs)
  plots(3)                  = plot
  delete(plot)
  delete(plotMs)
  delete(rcZn3)
  delete(Fxn34)
  delete(Fyn34)
  delete(mZn3)

  ;resZs@gsnRightString      = "Corr: " +sprintf("%5.2f",zcdmi)
  plot                      = gsn_csm_contour_map(wks, mZdm, resZs)
  plotMs                    = gsn_csm_vector_scalar(wks,Fxdmi,Fydmi, rcZdm, resZ)
  overlay(plot,plotMs)
  plots(4)             = plot
  delete(plot)
  delete(plotMs)
  delete(rcZdm)
  delete(Fxdmi)
  delete(Fydmi)
  delete(mZdm)


 resP                = True
 resP@gsnMaximize    = True
 resP@gsnPanelYWhiteSpacePercent = 0.	; no white space (default 0)
 resP@gsnFrame       = False
 resP@gsnPanelLeft   = 0.015
 resP@gsnPanelBottom = 0.08
 resP@gsnPanelSave   = True      ; Save the state of the paneled plots so we can
                                 ; query for text strings locations.
 resP@gsnPanelFigureStringsFontHeightF = 0.013
 resP@gsnPanelFigureStrings       = (/"b","d","g", "j", "m"/) ; add strings to panel
 resP@amJust                      = "TopLeft"
 resP@gsnPanelLabelBar            = True    ; add common colorbar
 
 gsn_panel(wks, plots, (/5,1/), resP)  ; plots
;**********************************************************************
; Add rotated text strings on left side of paneled plots.
; Use the resized plots to determine the position of the titles
;**********************************************************************
 ;pos1 = get_title_position(plots(0))         ; 1st row leftmost plot
 ;pos2 = get_title_position(plots(1))         ; 2nd row leftmost plot
 ;pos3 = get_title_position(plots(2))         ; 3rd row leftmost plot
 ;pos4 = get_title_position(plots(3))
 ;pos5= get_title_position(plots(4))
 posL = get_label_position(plots(4))         ; last plot (for positioning label)


 txres               = True
 txres@txFontHeightF = 0.015
 txres@txAngleF      = 90.
 ;gsn_text_ndc(wks, "Max. T.",   pos1(0), pos1(1), txres)
 ;gsn_text_ndc(wks, "SAMx-1",   pos2(0), pos2(1), txres)
 ;gsn_text_ndc(wks, "TPIx-1", pos3(0), pos3(1), txres)
 ;gsn_text_ndc(wks, "Nino3.4",   pos4(0), pos4(1), txres)
 ;gsn_text_ndc(wks, "DMI", pos5(0), pos5(1), txres)
 txres@txAngleF      = 0.
 txres@txFontHeightF = 0.013
 gsn_text_ndc(wks, "m", posL(0), posL(1), txres)

 frame(wks)

end do		; month loop


break
end do		; region loop

end




