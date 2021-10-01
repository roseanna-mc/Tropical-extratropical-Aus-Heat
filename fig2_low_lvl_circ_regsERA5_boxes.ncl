; Usage NCL
; 3/6/21
; Adding boxes to figures

; I don't think ERA5 is right still...
;  regression of low-level circulation

; Need to make boxes definining regions that I average over...

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
  pos = (/vpx*0.75-0.021,vpy-(vph/2.)/)
  return(pos)
end

function get_label_position(plot)
local vpy, vpx, vph
begin
  getvalues plot
      "vpYF"       : vpy		; top of plot
      "vpXF"       : vpx		; left side of plot
      "vpHeightF"  : vph		; height of plot
  end getvalues
  pos = (/vpx+0.22,vpy-vph-0.038/)
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

 siglvl    = 0.05
 stdise    = stds(1)
 dtrnd     = dtrns(1)

 gsp       = 2
 wndlvl    = 850                        ; pressure level for low level wind
 
 ; did not get improved results by using other levels; 500hpa is good enough
 wmin      = 85000.                      ; height range for omega (height in Pa)
 wmax      = 50000.
 wminS     = 850                         ; for files
 wmaxS     = 500
;-------------------------- File options -----------------------
 outType = "png"
 outDir  = "/g/data3/w97/rm8168/data/tropVextrop/withWS/"
 obsDir  = "/g/data/w97/rm8168/data/obs/"
 ;erDir  = "/g/data/v45/zg0866/ERA-I/monthly_avg/daily/"
 era5Dir = "/g/data/eg3/rm8168/data/"
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
 
 ; MSLP data  msl_era5_mon_global_197901_201912
 ; 	short msl(time, latitude, longitude) ; 
  mfil = era5Dir+"era5_mslp_1979-2020.nc"
  mfs  = addfile(mfil,"r")
  MSLP = short2flt(mfs->msl(moStrtE:moStopE,{0:-80:gsp},::gsp)) ;lon: [-180..178.75]
  ;printVarSummary(MSLP)
  mslp  = MSLP*0.01
  copy_VarMeta(MSLP, mslp)
  mslp@units = "hPa"
  delete(mfil)
  delete(MSLP)
  delete(mfs)
  mcmons    = clmMonTLL(mslp(moStrtC:moStopC,:,:))
  manoms    = calcMonAnomTLL(mslp,mcmons)
  delete(mslp)
  delete(mcmons)
  manoms@_FillValue = 9.96921e+36
  printVarSummary(manoms)

 ; 850 u
  ufil = era5Dir + "era5_u850_1979-2020.nc" 
  ufs  = addfile(ufil,"r")
  u8  = short2flt(ufs->u(moStrtE:moStopE,{0:-80:gsp},::gsp))	; lon: [ 0..358.75]
  delete(ufil)
  delete(ufs)
  u8cmons   = clmMonTLL(u8(moStrtC:moStopC,:,:))
  u8anoms   = calcMonAnomTLL(u8,u8cmons)
  delete(u8)
  delete(u8cmons)
  u8anoms@_FillValue = 9.96921e+36
  printVarSummary(u8anoms)
 
 ; 850 v
  vfil = era5Dir + "era5_v850_1979-2020.nc" 
  vfs  = addfile(vfil,"r")
  v8  = short2flt(vfs->v(moStrtE:moStopE,{0:-80:gsp},::gsp))
  delete(vfil)
  delete(vfs)
  v8cmons   = clmMonTLL(v8(moStrtC:moStopC,:,:))
  v8anoms   = calcMonAnomTLL(v8,v8cmons)
  delete(v8)
  delete(v8cmons)
  v8anoms@_FillValue = 9.96921e+36

 ; 850 w
  wfil = era5Dir + "era5_omega500_1979-2020.nc"
  wfs  = addfile(wfil,"r")
  w5 = short2flt(wfs->w(moStrtE:moStopE,{0:-80:gsp},::gsp))
  delete(wfil)
  delete(wfs)
  w5cmons   = clmMonTLL(w5(moStrtC:moStopC,:,:))
  w5anoms   = calcMonAnomTLL(w5,w5cmons)
  delete(w5)
  delete(w5cmons)
  w5anoms@_FillValue = 9.96921e+36

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
  copy_VarCoords(manoms(:,0,0),Amts)
  copy_VarCoords(manoms(:,0,0),SWmts)
  copy_VarCoords(manoms(:,0,0),SEmts)
  copy_VarCoords(manoms(:,0,0),Nmts)
  delete(mtfil)
  delete(ncol)
  delete(nrows)
  ;printVarSummary(Amts)

  ; era5 sam time series
  sfil   = obsDir + "1979_2019_era5_sam_x1.txt"
  ncol   = 3                    ; years, months, sam
  nrows  = (2019 - 1979)*12 + 12
  allsam = asciiread(sfil,(/nrows,ncol/),"float")
  sams   = (allsam(moStrtE:moStopE,2))*-1.
  copy_VarCoords(manoms(:,0,0),sams)
  delete(sfil)
  delete(ncol)
  delete(nrows)
  ;printVarSummary(sams)
  delete(allsam)

 ; tpi
 tfil    = obsDir + "tpiInd_ERSSTv5.txt"
 tstrt   = (yrFirst - 1891)*12
 tstop   = (yrLast - 1891)*12+11
 nrows   = (2019 - 1891 + 1 )*12 + 4    ; goes to April 2020
 ncol    = 6                            ; yr mn tri_c tri_w tri_e tpi
 alltp   = asciiread(tfil,(/nrows,ncol/),"float")
 alltpi  = (alltp(tstrt:tstop,5))*-1.
 copy_VarCoords(manoms(:,0,0),alltpi)
 ;printVarSummary(alltpi)       ;[time | 480]
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

 outPath = outDir + "obs" + trend +region + "_" + stdfx + "lin-MT-mlrTPIerrst-SAMe5vs_ERA5_LowCirc_boxes_siglvl"+siglvl
 wks     = gsn_open_wks(outType, outPath)
 plots   = new(9, graphic)

 do m    = 0, dimsizes(mons)-1 ; loop through months
  mon    = mons(m)        ; for files
  month  = months(m)	  ; for titles
  print("month is "+ month)

  M      = m + 8
 
  w5a = w5anoms(M::12,:,:)
  u8a = u8anoms(M::12,:,:)
  v8a = v8anoms(M::12,:,:)
  ma  = manoms(M::12,:,:)
  ta  = mt(M::12)
  tpi = alltpi(M::12) - dim_avg_n_Wrap(alltpi(M::12),0)
  sam = sams(M::12) - dim_avg_n_Wrap(sams(M::12),0)
  copy_VarCoords(alltpi(0::12),tpi)
  copy_VarCoords(sams(0::12),sam)

 ; detrend
  if dtrnd.eq."True" then
   x    = ispan(1,dimsizes(ta),1)
   mad  = dtrend_msg_n(x,ma,False,False,0)
   tad  = dtrend_msg_n(x,ta,False,False,0)
   u8ad = dtrend_msg_n(x,u8a,False,False,0)
   v8ad = dtrend_msg_n(x,v8a,False,False,0)
   samd = dtrend_msg_n(x,sam,False,False,0)
   tpid = dtrend_msg_n(x,tpi,False,False,0)
   w5ad = dtrend_msg_n(x,w5a,False,False,0)
   copy_VarMeta(w5a,w5ad)
   copy_VarMeta(ma,mad)
   copy_VarMeta(ta,tad)
   copy_VarMeta(u8a,u8ad)
   copy_VarMeta(v8a,v8ad)
   copy_VarMeta(sam,samd)
   copy_VarMeta(tpi,tpid)
   delete(x)
  else
   mad  = ma
   tad  = ta
   u8ad = u8a
   v8ad = v8a
   samd = sam
   tpid = tpi
   w5ad = w5a
  end if
  delete(ta)
  delete(w5a)
  delete(u8a)
  delete(v8a)
  delete(ma)
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
  rcU8 = regCoef_n( tads, u8ad, 0, 0)
  rcV8 = regCoef_n( tads, v8ad, 0, 0)
  rcM  = regCoef_n( tads, mad, 0, 0)
  rcW5 = regCoef_n( tads, w5ad, 0, 0)
  copy_VarCoords(u8ad(0,:,:), rcU8)
  copy_VarCoords(v8ad(0,:,:), rcV8)
  copy_VarCoords(mad(0,:,:), rcM)
  copy_VarCoords(w5ad(0,:,:), rcW5)
  delete(tads)

; ---------- multilinear regression ---------------
  ntim     = dimsizes(mad&time)
  nlonm    = dimsizes(mad&longitude)
  nlatm    = dimsizes(mad&latitude)
  mrctpi   = new((/nlatm,nlonm/),float,mad@_FillValue)
  mrcsam   = mrctpi
  mptpi    = mrctpi
  mpsam    = mrcsam

  nlon     = dimsizes(u8ad&longitude)
  nlat     = dimsizes(u8ad&latitude)
  urctpi   = new((/nlat,nlon/),float,mad@_FillValue)
  urcsam   = urctpi
  uptpi    = urctpi
  upsam    = urcsam
  vrctpi   = urctpi
  vrcsam   = urctpi
  vptpi    = urctpi
  vpsam    = urcsam
  wrctpi   = urctpi
  wrcsam   = urctpi
  wptpi    = urctpi
  wpsam    = urcsam

  ;create array for the 2 predictors (tpi, sam)
  xp      = new((/ntim,2/),typeof(tpisd))
  xp(:,0) = tpisd
  xp(:,1) = samsd
  do la     = 0, nlatm-1
  do lo     = 0, nlonm-1
    ; bvar(yintercept, reg coef1, regcoef2, regcoef3)
   mbt           = reg_multlin_stats(mad(:,la,lo),xp,True)
   mrctpi(la,lo) = mbt(1)
   mrcsam(la,lo) = mbt(2)
   mpval         = mbt@pval
   ;printVarSummary(pval)
   mptpi(la,lo)  = mpval(1)
   mpsam(la,lo)  = mpval(2)
   delete(mbt)
  end do
  end do
  do la     = 0, nlat-1
  do lo     = 0, nlon-1
   ubt           = reg_multlin_stats(u8ad(:,la,lo),xp,True)
   urctpi(la,lo) = ubt(1)
   urcsam(la,lo) = ubt(2)
   upval         = ubt@pval
   ;printVarSummary(pval)
   uptpi(la,lo)  = upval(1)
   upsam(la,lo)  = upval(2)
   delete(ubt)
   vbt           = reg_multlin_stats(v8ad(:,la,lo),xp,True)
   vrctpi(la,lo) = vbt(1)
   vrcsam(la,lo) = vbt(2)
   vpval         = vbt@pval
   ;printVarSummary(pval)
   vptpi(la,lo)  = vpval(1)
   vpsam(la,lo)  = vpval(2)
   delete(vbt)
   wbt           = reg_multlin_stats(w5ad(:,la,lo),xp,True)
   wrctpi(la,lo) = wbt(1)
   wrcsam(la,lo) = wbt(2)
   wpval         = wbt@pval
   wptpi(la,lo)  = wpval(1)
   wpsam(la,lo)  = wpval(2)
   delete(wbt)
  end do
 end do
 delete(xp)
 copy_VarCoords(mad(0,:,:),mrctpi)
 copy_VarCoords(mad(0,:,:),mrcsam)
 copy_VarCoords(u8ad(0,:,:),urctpi)
 copy_VarCoords(u8ad(0,:,:),urcsam)
 copy_VarCoords(v8ad(0,:,:),vrctpi)
 copy_VarCoords(v8ad(0,:,:),vrcsam)
 copy_VarCoords(w5ad(0,:,:),wrctpi)
 copy_VarCoords(w5ad(0,:,:),wrcsam)
 delete(tpisd)
 delete(samsd)
 delete(mad)
 delete(u8ad)
 delete(v8ad)
 delete(w5ad)

 ;------------ Significance using 2-tailed Student's t-test ----------

 tvalM   = onedtond(rcM@tval, dimsizes(rcM))         ; Output puts tval and nptxy into 1D arrays
 dfM     = onedtond(rcM@nptxy, dimsizes(rcM)) -2     ; of size nlat*nlon
 tvalU8  = onedtond(rcU8@tval, dimsizes(rcU8))
 dfU8    = onedtond(rcU8@nptxy, dimsizes(rcU8)) -2
 tvalV8  = onedtond(rcV8@tval, dimsizes(rcV8))
 dfV8    = onedtond(rcV8@nptxy, dimsizes(rcV8)) -2
 tvalW5  = onedtond(rcW5@tval, dimsizes(rcW5))
 dfW5    = onedtond(rcW5@nptxy, dimsizes(rcW5)) -2
 bm      = tvalM                                     ; b must be same dimension as tval and df
 bm      = 0.5
 b       = tvalU8                                     ; b must be same dimension as tval and df
 b       = 0.5

; p-values
 pM     = betainc(dfM/(dfM+tvalM^2), dfM/2.0, bm)
 pU8    = betainc(dfU8/(dfU8+tvalU8^2), dfU8/2.0, b)
 pV8    = betainc(dfV8/(dfV8+tvalV8^2), dfV8/2.0, b)
 pW5    = betainc(dfW5/(dfW5+tvalW5^2), dfW5/2.0, b)
 copy_VarCoords(rcM, pM)
 copy_VarCoords(rcW5, pW5)
 copy_VarCoords(rcU8, pU8)
 copy_VarCoords(rcV8, pV8)
 ;printVarSummary(pM)                                    ; lat | 121] x [lon | 240]
 delete(tvalM)
 delete(dfM)
 delete(tvalU8)
 delete(dfU8)
 delete(tvalV8)
 delete(dfV8)
 delete(b)
 delete(bm)
 delete(tvalW5)
 delete(dfW5)

; Mask for significance
 mM     = rcM
 mV8    = rcV8
 mU8    = rcU8
 rU8    = rcU8
 rV8    = rcV8
 mW5    = rcW5 
 mM     = where( pM.lt.siglvl, rcM, 0.)
 mW5    = where( pW5.lt.siglvl, rcW5, 0.);mask(rcW5,pW5.lt.siglvl,True); where( pW5.lt.0.5, rcW5, rcW5@_FillValue)
 mU8    = where( (pU8.lt.siglvl).or.(pV8.lt.siglvl), rcU8, rcU8@_FillValue)     ; significant u,v
 mV8    = where( (pU8.lt.siglvl).or.(pV8.lt.siglvl), rcV8, rcU8@_FillValue)
 rU8    = where( (pU8.lt.siglvl).or.(pV8.lt.siglvl), rcU8@_FillValue, rcU8)  ; not significant u,v
 rV8    = where( (pU8.lt.siglvl).or.(pV8.lt.siglvl), rcU8@_FillValue, rcV8)
 delete(pM)
 delete(pU8)
 delete(pV8)

 mstpi     = where(mptpi.lt.siglvl, mrctpi, 0.)
 mssam     = where(mpsam.lt.siglvl, mrcsam, 0.)
 wstpi     = where(wptpi.lt.siglvl, wrctpi, 0.); mask(wrctpi,wptpi.lt.siglvl,True); where(wptpi.lt.0.5, wrctpi, rcW5@_FillValue)
 wssam     = where(wpsam.lt.siglvl, wrcsam, 0.); mask(wrcsam,wpsam.lt.siglvl,True); where(wpsam.lt.0.5, wrcsam, rcW5@_FillValue)
 ustpi     = where((uptpi.lt.siglvl).or.(vptpi.lt.siglvl),urctpi,rcU8@_FillValue)
 vstpi     = where((uptpi.lt.siglvl).or.(vptpi.lt.siglvl),vrctpi,rcU8@_FillValue)
 urtpi     = where((uptpi.lt.siglvl).or.(vptpi.lt.siglvl),rcU8@_FillValue,urctpi)
 vrtpi     = where((uptpi.lt.siglvl).or.(vptpi.lt.siglvl),rcU8@_FillValue,vrctpi)
 ussam     = where((upsam.lt.siglvl).or.(vpsam.lt.siglvl),urcsam,rcU8@_FillValue)
 vssam     = where((upsam.lt.siglvl).or.(vpsam.lt.siglvl),vrcsam,rcU8@_FillValue)
 ursam     = where((upsam.lt.siglvl).or.(vpsam.lt.siglvl),rcU8@_FillValue,urcsam)
 vrsam     = where((upsam.lt.siglvl).or.(vpsam.lt.siglvl),rcU8@_FillValue,vrcsam)

 rcM@long_name   = ""           ; remove so it doesn't appear on plots
 rcM@units       = ""
 rU8@long_name   = ""
 rU8@units       = ""
 rV8@long_name   = ""
 rV8@units       = ""
 mrctpi@long_name = ""
 mrcsam@long_name = ""
 urtpi@long_name = ""
 ursam@long_name = ""
 vrtpi@long_name = ""
 vrsam@long_name = ""
 mstpi@long_name = ""
 mssam@long_name = ""
 ustpi@long_name = ""
 ussam@long_name = ""
 vstpi@long_name = ""
 vssam@long_name = ""

 copy_VarCoords(mrctpi,mstpi)
 copy_VarCoords(mrctpi,mssam)
 copy_VarCoords(urctpi,ustpi)
 copy_VarCoords(urctpi,ussam)
 copy_VarCoords(vrctpi,vstpi)
 copy_VarCoords(vrctpi,vssam)
 copy_VarCoords(vrctpi,urtpi)
 copy_VarCoords(vrctpi,ursam)
 copy_VarCoords(vrctpi,vrtpi)
 copy_VarCoords(vrctpi,vrsam)
 copy_VarCoords(wrctpi,wssam)
 copy_VarCoords(wrctpi,wstpi)
 delete(urctpi)
 delete(vrctpi)
 delete(urcsam)
 delete(vrcsam)

 ;printMinMax(rcW5,1)
 ;printMinMax(wrctpi,1)
 ;printMinMax(wrcsam,1)
 printMinMax(mW5,1)
 printMinMax(wstpi,1)
 printMinMax(wssam,1)

; ------------------- pattern correlation ----------------
 clat  = cos(rcM&latitude*rad)
 lamin = -70.		;-45
 lamax = -5.		;-5
 lomin = 70.		;105
 lomax = 170.		;160
 copy_VarCoords(rcM(:,0),clat)
 ;cos(lat) weighting, uncentered
 mctpi = pattern_cor(rcM({lamin:lamax},{lomin:lomax}), mrctpi({lamin:lamax},{lomin:lomax}), clat({lamin:lamax}), 1)    
 mcsam = pattern_cor(rcM({lamin:lamax},{lomin:lomax}), mrcsam({lamin:lamax},{lomin:lomax}), clat({lamin:lamax}), 1)

; ----------------- Plotting -----------------------
  res    = True		    ; Options for common resources
  resM   = True             ; Options for mslp and wind (not sig)
  resMs  = True             ; Options for sig mslp and sig vectors
  resW   = True		    ; Options for sig omega(for now not plot not sig omega
  plresf = True		    ; Polyline resources for features shapes
  plresm = True 

  plresf@gsLineColor         = "black"
  plresf@gsLineThicknessF    = 3.5
  plresm	             = plresf
  plresm@gsLineDashPattern   = 2		; dashed line for mechanisms 


  res@pmTickMarkDisplayMode = "Always"
  res@mpFillOn              =  False          ; turn off map fill
  res@mpOutlineDrawOrder    = "PostDraw"      ; draw continental outline last
  res@mpMinLatF             = -70.            ; range to zoom in on
  res@mpMaxLatF             = 0.
  res@mpMinLonF             = 40.
  res@mpMaxLonF             = 240.
  res@mpCenterLonF	    = 180.
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
  res@gsnStringFontHeightF  = 0.1        	 ; make all font size bigger
  res@cnLevelSelectionMode  = "ManualLevels"
  res@gsnContourZeroLineThicknessF = 0.
  res@gsnContourNegLineDashPattern = 1
  res@gsnLeftString	    = ""
  res@gsnRightString        = ""
  res@gsnCenterString       = ""
    
  resM                      = res
  mmin                      = -5.
  mmax                      = 5.
  mstep			    = .5
  resM@cnMonoLineColor      = True
  resM@cnLineColor	    = "grey22"
  ;colSpn = floattointeger((mmax - mmin/mstep) + 1)
  ;resM@cnLineColors         = span_color_rgba ("CBR_coldhot",colSpn)
  resM@gsnScalarContour     = True
  resM@cnMinLevelValF       = mmin
  resM@cnMaxLevelValF       = mmax
  resM@cnLevelSpacingF      = mstep
  resM@cnLineThicknessF     = 2.
  
  resM@vcMinDistanceF          = 0.028  ; 017      ; thin vectors (small is more crowded)
  resM@vcMonoLineArrowColor    = True
  resM@vcLineArrowThicknessF   = 2.4   ;2.3
  resM@vcGlyphOpacityF         = 0.4
  resM@vcLineArrowHeadMinSizeF = 0.005           ; keep arrow heads similar size.
  resM@vcLineArrowHeadMaxSizeF = 0.010
  resM@vcRefMagnitudeF         = 2.               ; define vector ref mag
  resM@vcRefLengthF            = .04               ; define length of vec ref
  resM@vcRefAnnoOn             = False; True
  ;resM@vcRefAnnoOrthogonalPosF = -0.12          ; move reference vector up
  ;resM@vcLabelFontHeightF      = 0.2

  resMs			        = resM
  resMs@cnLinesOn               = False           ; turn off contour lines
  resMs@cnFillOn                = True            ; Turn on fill True
  resMs@cnFillPalette           = "CBR_coldhot"
  resMs@vcRefAnnoOn             = True; False
  resMs@vcRefAnnoOrthogonalPosF = -0.35          ; move reference vector up
  resMs@vcLabelFontHeightF      = 0.1
  resMs@vcGlyphOpacityF         = 1.; 0.8
  resMs@lbLabelStride              = 2
  resMs@lbLabelFontHeightF         = 0.025
  resMs@pmLabelBarHeightF          = 0.2
  resMs@pmLabelBarWidthF           = 1.5
  resMs@lbOrientation              = "Horizontal"; "Vertical"        ; orientation
  resMs@pmLabelBarOrthogonalPosF   = 0.15	; move label bar down
  resMs@gsnRightStringFontHeightF  = 0.09
  ; sig omega 500
  resW			     = res
  resW@cnMinLevelValF        = -0.02; -.035
  resW@cnMaxLevelValF        = 0.02; .035
  resW@cnLevelSpacingF       = 0.01; .005
  resW@cnLineThicknessF      = 3.
  ;resW@cnInfoLabelOn        = False
  resW@gsnContourZeroLineThicknessF = 0.

  resMs@gsnLeftString               = "" ; "Aus. maxT"
  resMs@gsnCenterString             = month
  plot                              = gsn_csm_vector_scalar_map(wks, rU8, rV8, rcM, resM)
  plotMs                            = gsn_csm_vector_scalar(wks,mU8,mV8, mM, resMs)
  plotw                             = gsn_csm_contour(wks,mW5, resW)
  plotW                             = ColorNegDashZeroPosContour(plotw,"chartreuse1","black","violetred")
  overlay(plot,plotMs)
  overlay(plot,plotW)
  plots(m)                          = plot
  delete(plot)
  delete(plotMs)
  delete(rcM)
  delete(rcU8)
  delete(rcV8)
  delete(rU8)
  delete(rV8)
  delete(mM)
  delete(mU8)
  delete(mV8)
  delete(plotw)
  delete(plotW)
  delete(mW5)

  if m.eq.1 then
   resMs@lbLabelBarOn        = True     ; turb label back on for the las tplot
  end if 
  resMs@gsnLeftString       = "";"Tripole Index"
  resMs@gsnCenterString     = ""
  resMs@gsnRightString      = "Corr: " +sprintf("%5.2f",mctpi)
  plot                      = gsn_csm_vector_scalar_map(wks,urtpi,vrtpi,mrctpi, resM)
  plotMs                    = gsn_csm_vector_scalar(wks,ustpi,vstpi, mstpi, resMs)
  plotw                     = gsn_csm_contour(wks,wstpi, resW)
  plotW                     = ColorNegDashZeroPosContour(plotw,"chartreuse1","black","violetred")
  overlay(plot,plotMs)
  overlay(plot,plotW)
  plots(m + 6)              = plot
  delete(plot)
  delete(plotMs)
  delete(plotw)
  delete(plotW)
  resMs@lbLabelBarOn        = False      ; turn label back of for the las tplot
 
  resMs@gsnLeftString       = "" ; "SAM"
  resMs@gsnCenterString     = ""
  resMs@gsnRightString      = "Corr: " +sprintf("%5.2f",mcsam)
  plot                      = gsn_csm_vector_scalar_map(wks,ursam,vrsam, mrcsam, resM)
  plotMs                    = gsn_csm_vector_scalar(wks,ussam,vssam, mssam, resMs)
  plotw                     = gsn_csm_contour(wks,wssam, resW)
  plotW                     = ColorNegDashZeroPosContour(plotw,"chartreuse1","black","violetred")
  overlay(plot,plotMs)
  overlay(plot,plotW)
  overlay(plot,plotW)
  plots(m + 3)               = plot
  delete(plot)
  delete(plotMs)
  delete(plotw)
  delete(plotW)

 end do		; month loop

 resP                = True
 resP@gsnMaximize    = True
 resP@gsnFrame       = False
 resP@gsnPanelLeft   = 0.017
 resP@gsnPanelBottom = 0.08
 resP@gsnPanelSave   = True      ; Save the state of the paneled plots so we can
                                 ; query for text strings locations.
 resP@gsnPanelFigureStringsFontHeightF = 0.013
 resP@gsnPanelFigureStrings       = (/"a","b","c","d","e","f","g","h", "i"/) ; add strings to panel
 resP@amJust                      = "TopLeft"
 ;resP@gsnPanelLabelBar            = True    ; add common colorbar

  dumsw  = new(4,graphic)
  dumow  = new(4,graphic)
  dumnw  = new(4,graphic)
  dumse  = new(4,graphic)
  dumoe  = new(4,graphic)
  dumne  = new(4,graphic)
  ;dumsU  = new(4,graphic)
  ;dumoU  = new(4,graphic)
  ;dumnU  = new(4,graphic)
  ;dumsW  = new(4,graphic)
  ;dumoW  = new(4,graphic)
  ;dumnW  = new(4,graphic)
  dumnt = new(4,graphic)

  do i=0,3
   dumsw(i) = gsn_add_polyline(wks,plots(0),swlat(i:i+1),swlon(i:i+1),plresf)
   dumow(i) = gsn_add_polyline(wks,plots(1),swlat(i:i+1),swlon(i:i+1),plresf)
   ;dumnw(i) = gsn_add_polyline(wks,plots(2),swlat(i:i+1),swlon(i:i+1),plresf)
   dumse(i) = gsn_add_polyline(wks,plots(0),selat(i:i+1),selon(i:i+1),plresf)
   dumoe(i) = gsn_add_polyline(wks,plots(1),selat(i:i+1),selon(i:i+1),plresf)
   ;dumne(i) = gsn_add_polyline(wks,plots(2),selat(i:i+1),selon(i:i+1),plresf)
   dumnt(i) = gsn_add_polyline(wks,plots(2),tslat(i:i+1),tslon(i:i+1),plresf)
   ;dumsU(i) = gsn_add_polyline(wks,plots(3),uvlat(i:i+1),uvlon(i:i+1),plresm)
   ;dumoU(i) = gsn_add_polyline(wks,plots(4),uvlat(i:i+1),uvlon(i:i+1),plresm)
   ;dumnU(i) = gsn_add_polyline(wks,plots(5),uvlat(i:i+1),uvlon(i:i+1),plresm)
   ;dumsW(i) = gsn_add_polyline(wks,plots(6),wlat(i:i+1),wlon(i:i+1),plresm)
   ;dumoW(i) = gsn_add_polyline(wks,plots(7),wlat(i:i+1),wlon(i:i+1),plresm)
   ;dumnW(i) = gsn_add_polyline(wks,plots(8),wlat(i:i+1),wlon(i:i+1),plresm)
  end do
 
 gsn_panel(wks, plots, (/3,3/), resP)  ; plots
;**********************************************************************
; Add rotated text strings on left side of paneled plots.
; Use the resized plots to determine the position of the titles
;**********************************************************************
 pos1 = get_title_position(plots(0))         ; 1st row leftmost plot
 pos2 = get_title_position(plots(3))         ; 2nd row leftmost plot
 pos3 = get_title_position(plots(6))         ; 3rd row leftmost plot
 pos4 = get_label_position(plots(8))	     ; last plot (for positioning label)
 txres               = True
 txres@txFontHeightF = 0.014
 txres@txAngleF      = 90.
 gsn_text_ndc(wks, "Max. T.",   pos1(0), pos1(1), txres)
 gsn_text_ndc(wks, "SAMx-1",   pos2(0), pos2(1), txres)
 gsn_text_ndc(wks, "TPIx-1", pos3(0), pos3(1), txres)
 txres@txAngleF      = 0.
 gsn_text_ndc(wks, "hPa", pos4(0), pos4(1), txres)    
 frame(wks)

break
end do		; region loop

end




