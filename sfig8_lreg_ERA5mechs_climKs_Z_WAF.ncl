; Usage NCL
; 28/6/21
; 200hPa Ks and WAF
; linearly regressed onto mechanisms

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
  pos = (/vpx+0.16,vpy-vph-0.027/)
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
 obsDir  = "/g/data/w97/rm8168/data/tropVextrop/timeseries/"
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

 sfil   = obsDir + "1979_2019_ERA5_U850_S-O-N_timeseries"
 ncol   = 3                    ; S O N
 nrows  = (2019 - 1979) +1
 allu8  = asciiread(sfil,(/nrows,ncol/),"float")        ;[492] x [3]
 printVarSummary(allu8)
 delete(sfil)

 sfil   = obsDir + "1979_2019_ERA5_V850x-1_S-O-N_timeseries"
 allv8  = asciiread(sfil,(/nrows,ncol/),"float")        ;[492] x [3]
 printVarSummary(allv8)

 sfil   = obsDir + "1979_2019_ERA5_W500_S-O-N_timeseries"
 allw5  = asciiread(sfil,(/nrows,ncol/),"float")        ;[492] x [3]
 printVarSummary(allw5)

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

 outPath = outDir + "obs" + trend + stdfx + "lin-Mechsvs_ERA5_Z200_WAF_Ks_siglvl"+siglvl
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
  u8  = allu8(:,m)
  v8  = allv8(:,m)
  w5  = allw5(:,m)

 ; detrend
  if dtrnd.eq."True" then
   x    = ispan(1,dimsizes(u8),1)
   zad  = dtrend_msg_n(x,za,False,False,0)
   u8d  = dtrend_msg_n(x,u8,False,False,0)
   w5d = dtrend_msg_n(x,w5,False,False,0)
   v8d = dtrend_msg_n(x,v8,False,False,0)
   copy_VarMeta(za,zad)
   copy_VarMeta(u8,u8d)
   copy_VarMeta(w5,w5d)
   copy_VarMeta(v8,v8d)
   delete(x)
  else
   zad  = za
   u8d  = u8
   w5d  = w5
   v8d  = v8
  end if
  delete(u8)
  delete(za)
  delete(v8)
  delete(w5)

  if stdise.eq."True" then
   print("standardising drivers")
   u8sd = dim_standardize_n_Wrap(u8d,0,0)
   w5sd = dim_standardize_n_Wrap(w5d,0,0)
   v8sd = dim_standardize_n_Wrap(v8d,0,0)
  else
   print("not standardising drivers")
   u8sd = u8d
   w5sd = w5d
   v8sd = v8d
  end if
  delete(u8d)
  delete(v8d)
  delete(w5d)

 ;--------------- linear regression ---------------------
  rcZu  = regCoef_n( u8sd, zad, 0, 0)
  copy_VarCoords(zad(0,:,:), rcZu)
  printVarSummary(rcZu)          ; [lat | 121] x [lon | 240]
  delete(u8sd)

  rcZv  = regCoef_n( v8sd, zad, 0, 0)
  copy_VarCoords(zad(0,:,:), rcZv)
  delete(v8sd)

  rcZw  = regCoef_n( w5sd, zad, 0, 0)
  copy_VarCoords(zad(0,:,:), rcZw)
  delete(w5sd)

;------------- calculate WAF---------------
  ;lat      = u2c&lat
  ;lon      = u2c&lon
  RWFu8    = WaveAF3(rcZu,u2c,v2c,lvl,lat,lon)
  Fxu8     = RWFu8[0]
  Fyu8     = RWFu8[1]
  delete(RWFu8)
  RWFv8   = WaveAF3(rcZv,u2c,v2c,lvl,lat,lon)
  Fxv8    = RWFv8[0]
  Fyv8    = RWFv8[1]
  delete(RWFv8)
  RWFw5   = WaveAF3(rcZw,u2c,v2c,lvl,lat,lon)
  Fxw5    = RWFw5[0]
  Fyw5    = RWFw5[1]
  delete(RWFw5)
  copy_VarCoords(rcZv,Fxv8)
  copy_VarCoords(rcZv,Fxw5)
  copy_VarCoords(rcZv,Fyv8)
  copy_VarCoords(rcZv,Fyw5)
  copy_VarCoords(rcZu,Fxu8)
  copy_VarCoords(rcZu,Fyu8)

 
  rcZu@long_name   = ""
  rcZu@units       = ""
  rcZv@long_name   = ""
  rcZv@units       = ""
  rcZw@long_name   = ""
  rcZw@units       = ""
  Fxu8@long_name   = "" 
  Fyu8@long_name   = "" 
  Fxv8@long_name  = "" 
  Fyv8@long_name  = "" 
  Fxw5@long_name  = "" 
  Fyw5@long_name  = "" 
  Fxu8@units       = "" 
  Fyu8@units       = "" 
  Fxv8@units      = "" 
  Fyv8@units      = ""
  Fxw5@units      = "" 
  Fyw5@units      = ""


 ;------------ Significance using 2-tailed Student's t-test ----------
 tvalM   = onedtond(rcZu@tval, dimsizes(rcZu))         ; Output puts tval and nptxy into 1D arrays
 dfM     = onedtond(rcZu@nptxy, dimsizes(rcZu)) -2     ; of size nlat*nlon
 b       = tvalM                                     ; b must be same dimension as tval and df
 b       = 0.5
 ; p-values
 pMu    = betainc(dfM/(dfM+tvalM^2), dfM/2.0, b)
 delete(tvalM)
 delete(dfM)

 tvalM   = onedtond(rcZv@tval, dimsizes(rcZv))         ; Output puts tval and nptxy into 1D arrays
 dfM     = onedtond(rcZv@nptxy, dimsizes(rcZv)) -2     ; of size nlat*nlon
 b       = tvalM                                     ; b must be same dimension as tval and df
 b       = 0.5
 ; p-values
 pMv    = betainc(dfM/(dfM+tvalM^2), dfM/2.0, b)
 delete(tvalM)
 delete(dfM)

 tvalM   = onedtond(rcZw@tval, dimsizes(rcZw))         ; Output puts tval and nptxy into 1D arrays
 dfM     = onedtond(rcZw@nptxy, dimsizes(rcZw)) -2     ; of size nlat*nlon
 b       = tvalM                                     ; b must be same dimension as tval and df
 b       = 0.5
 ; p-values
 pMw    = betainc(dfM/(dfM+tvalM^2), dfM/2.0, b)
 delete(tvalM)
 delete(dfM)

; Mask for significance
 mZu    = rcZu
 mZu    = mask(rcZu,pMu.lt.siglvl,True);where( pMu.lt.siglvl, rcZu, 0.)
 mZv    = rcZv
 mZv    = mask(rcZv,pMv.lt.siglvl,True);where( pMu.lt.siglvl, rcZv, 0.)
 mZw    = rcZw
 mZw    = mask(rcZw,pMw.lt.siglvl,True);where( pMu.lt.siglvl, rcZw, 0.)
 delete(rcZu)
 delete(rcZv)
 delete(rcZw)
  slon   = 15.           ; smooth with running 15 deg longitude. No smooth if set 0. Recommend 15-30
  slat   = 5.            ; w5e but for smooth with running 5 deg latitude. No smooth if set 0. Recommend 0
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
  resZs@cnMinLevelValF       = -50.;zmin
  resZs@cnMaxLevelValF       = 50.  ; zmax
  resZs@cnLevelSpacingF      = 10. ;zstep
  resZs@cnLinesOn            = True           ; turn off contour lines
  resZs@cnFillOn             = True            ; Turn on fill True
  cmap                       = read_colormap_file("precip4_diff_19lev")
  resZs@cnFillPalette        = cmap(::-1,:)
  resZs@cnMonoLineColor      = True
  resZs@cnLineColor          = "grey22"

  resZs@lbLabelStride              = 2
  resZs@lbLabelFontHeightF         = 0.025
  resZs@pmLabelBarHeightF          = 0.2
  resZs@pmLabelBarWidthF           = 1.5
  resZs@lbOrientation              = "Horizontal"; "Vertical"        ; orientation
  resZs@pmLabelBarOrthogonalPosF   = 0.15       ; move label bar down
 
  resZ			     = res
  resZ@cnMonoLineColor       = True
  resZ@cnMinLevelValF        = 0. ; -50.
  resZ@cnMaxLevelValF        = 10. ;50.
  resZ@cnLevelSpacingF       = 1.; 10.
  resZ@cnLineThicknessF      = 2.
  resZ@cnLineColor	     = "grey58"
  resZ@gsnScalarContour      = True
  resZ@vcRefMagnitudeF       = .6               ; define vector ref mag
  resZ@vcRefLengthF          = .04             ; define length of vec ref
  resZ@vcRefAnnoOn           = True
  resZ@vcRefAnnoOrthogonalPosF = -0.35
  resZ@vcMinDistanceF          = 0.03  ; 017      ; thin vectors (small is more crowded)
  resZ@vcMonoLineArrowColor    = True
  resZ@vcLineArrowThicknessF   = 2.3   ;2.3
  resZ@vcGlyphOpacityF         = 1.
  resZ@vcLineArrowHeadMinSizeF = 0.005           ; keep arrow heads similar size.
  resZ@vcLineArrowHeadMaxSizeF = 0.010
  resZ@vcLabelFontHeightF      = 0.3
  resZ@vcRefAnnoString2        = ""		; default 'Refernce Vector" 
  resZs@gsnRightStringFontHeightF  = 0.15

  resZs@gsnCenterString             = month
  plot                              = gsn_csm_contour_map(wks,mZu, resZs)
  plotV				    = gsn_csm_vector_scalar(wks,Fxu8, Fyu8, Ks,resZ)
  overlay(plot,plotV)
  plots(m)                          = plot
  delete(plot)
  delete(plotV)
  delete(Fxu8)
  delete(Fyu8)

  resZs@gsnCenterString     = ""
  plot                      = gsn_csm_contour_map(wks,mZv, resZs)
  plotV                     = gsn_csm_vector_scalar(wks,Fxv8, Fyv8,Ks,resZ)
  overlay(plot,plotV)
  plots(m + 6)              = plot
  delete(plot)
  delete(plotV)
  delete(Fxv8)
  delete(Fyv8)
  resZs@lbLabelBarOn        = False      ; turn label back of for the las tplot

  plot                      = gsn_csm_contour_map(wks,mZw, resZs)
  plotV                     = gsn_csm_vector_scalar(wks,Fxw5, Fyw5,Ks,resZ)
  overlay(plot,plotV)
  plots(m + 3)              = plot
  delete(plot)
  delete(Fxw5)
  delete(Fyw5)
  delete(plotV)
 end do		; month loop

 resP                = True
 resP@gsnMaximize    = True
 resP@gsnFrame       = False
 resP@gsnPanelLeft   = 0.015
 resP@gsnPanelBottom = 0.08
 resP@gsnPanelSave   = True      ; Save the state of the paneled plots so we can
                                 ; query for text strings locations.
 resP@gsnPanelFigureStringsFontHeightF = 0.012
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
 txres@txFontHeightF = 0.014
 txres@txAngleF      = 90.
 gsn_text_ndc(wks, "u850",   pos1(0), pos1(1), txres)
 gsn_text_ndc(wks, "v850",   pos2(0), pos2(1), txres)
 gsn_text_ndc(wks, "w500", pos3(0), pos3(1), txres)
 txres@txAngleF      = 0.
 gsn_text_ndc(wks, "m", pos4(0), pos4(1), txres)
 frame(wks)


end




