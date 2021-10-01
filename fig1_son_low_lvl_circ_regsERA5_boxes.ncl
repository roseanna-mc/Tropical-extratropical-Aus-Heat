; Usage NCL
; 11/9/21
; Adding boxes to figures

; Small refinements before submission

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
  pos = (/vpx*0.75+0.028,vpy-(vph/2.)/)
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
  ;pos = (/vpx+0.41,vpy-vph-0.032/)
  pos = (/vpx+.176,vpy-vph-0.06/)
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


  ; n34
  sfil   = obsDir + "1979_2019_ERSSTv5_n34"
  ncol   = 3                    ; years, months, sam
  nrows  = (2019 - 1979)*12 + 12
  aln34  = asciiread(sfil,(/nrows,ncol/),"float")
  alln34 = aln34(:,2)
  printVarSummary(alln34)
  copy_VarCoords(manoms(:,0,0),alln34)
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
  copy_VarCoords(manoms(:,0,0),alldmi)
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

  w5a = month_to_season(w5anoms,mon)
  u8a = month_to_season(u8anoms,mon)
  v8a = month_to_season(v8anoms,mon)
  ma  = month_to_season(manoms,mon)
  ta  = month_to_season(mt,mon)
  tpi = month_to_season(alltpi,mon)
  sam = month_to_season(sams,mon)
  n34 = month_to_season(alln34,mon)
  dmi = month_to_season(alldmi,mon)
  copy_VarCoords(alltpi(0::12),tpi)
  copy_VarCoords(sams(0::12),sam)

 outPath = outDir + "obs" + trend +region + "_" +m+"_"+mon+"_"+ stdfx + "lr-MT-TPIerrst-SAMe5_N34_DMIvs_ERA5_LowCirc_boxes_siglvl"+siglvl
 wks     = gsn_open_wks(outType, outPath)
 plots   = new(5, graphic)

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
   n34d = dtrend_msg_n(x,n34,False,False,0)
   dmid = dtrend_msg_n(x,dmi,False,False,0)
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
   n34d = n34
   dmid = dmi
  end if
  delete(ta)
  delete(w5a)
  delete(u8a)
  delete(v8a)
  delete(ma)
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
  rcU8mt = regCoef_n( tads, u8ad, 0, 0)
  rcV8mt = regCoef_n( tads, v8ad, 0, 0)
  rcMmt  = regCoef_n( tads, mad, 0, 0)
  rcW5mt = regCoef_n( tads, w5ad, 0, 0)
  copy_VarCoords(u8ad(0,:,:), rcU8mt)
  copy_VarCoords(v8ad(0,:,:), rcV8mt)
  copy_VarCoords(mad(0,:,:), rcMmt)
  copy_VarCoords(w5ad(0,:,:), rcW5mt)
  delete(tads)

  rcU8sa = regCoef_n( samsd, u8ad, 0, 0)
  rcV8sa = regCoef_n( samsd, v8ad, 0, 0)
  rcMsa  = regCoef_n( samsd, mad, 0, 0)
  rcW5sa = regCoef_n( samsd, w5ad, 0, 0)
  copy_VarCoords(u8ad(0,:,:), rcU8sa)
  copy_VarCoords(v8ad(0,:,:), rcV8sa)
  copy_VarCoords(mad(0,:,:), rcMsa)
  copy_VarCoords(w5ad(0,:,:), rcW5sa)
  delete(samsd)

  rcU8tp = regCoef_n( tpisd, u8ad, 0, 0)
  rcV8tp = regCoef_n( tpisd, v8ad, 0, 0)
  rcMtp  = regCoef_n( tpisd, mad, 0, 0)
  rcW5tp = regCoef_n( tpisd, w5ad, 0, 0)
  copy_VarCoords(u8ad(0,:,:), rcU8tp)
  copy_VarCoords(v8ad(0,:,:), rcV8tp)
  copy_VarCoords(mad(0,:,:), rcMtp)
  copy_VarCoords(w5ad(0,:,:), rcW5tp)
  delete(tpisd)

  rcU8n3 = regCoef_n( n34sd, u8ad, 0, 0)
  rcV8n3 = regCoef_n( n34sd, v8ad, 0, 0)
  rcMn3  = regCoef_n( n34sd, mad, 0, 0)
  rcW5n3 = regCoef_n( n34sd, w5ad, 0, 0)
  copy_VarCoords(u8ad(0,:,:), rcU8n3)
  copy_VarCoords(v8ad(0,:,:), rcV8n3)
  copy_VarCoords(mad(0,:,:), rcMn3)
  copy_VarCoords(w5ad(0,:,:), rcW5n3)
  delete(n34sd)

  rcU8dm = regCoef_n( dmisd, u8ad, 0, 0)
  rcV8dm = regCoef_n( dmisd, v8ad, 0, 0)
  rcMdm  = regCoef_n( dmisd, mad, 0, 0)
  rcW5dm = regCoef_n( dmisd, w5ad, 0, 0)
  copy_VarCoords(u8ad(0,:,:), rcU8dm)
  copy_VarCoords(v8ad(0,:,:), rcV8dm)
  copy_VarCoords(mad(0,:,:), rcMdm)
  copy_VarCoords(w5ad(0,:,:), rcW5dm)
  delete(dmisd)

 ;------------ Significance using 2-tailed Student's t-test ----------

 tvalM   = onedtond(rcMmt@tval, dimsizes(rcMmt))         ; Output puts tval and nptxy into 1D arrays
 dfM     = onedtond(rcMmt@nptxy, dimsizes(rcMmt)) -2     ; of size nlat*nlon
 tvalU8  = onedtond(rcU8mt@tval, dimsizes(rcU8mt))
 dfU8    = onedtond(rcU8mt@nptxy, dimsizes(rcU8mt)) -2
 tvalV8  = onedtond(rcV8mt@tval, dimsizes(rcV8mt))
 dfV8    = onedtond(rcV8mt@nptxy, dimsizes(rcV8mt)) -2
 tvalW5  = onedtond(rcW5mt@tval, dimsizes(rcW5mt))
 dfW5    = onedtond(rcW5mt@nptxy, dimsizes(rcW5mt)) -2
 bm      = tvalM                                     ; b must be same dimension as tval and df
 bm      = 0.5
 b       = tvalU8                                     ; b must be same dimension as tval and df
 b       = 0.5

; p-values
 pM   = betainc(dfM/(dfM+tvalM^2), dfM/2.0, bm)
 pU8  = betainc(dfU8/(dfU8+tvalU8^2), dfU8/2.0, b)
 pV8  = betainc(dfV8/(dfV8+tvalV8^2), dfV8/2.0, b)
 pW5  = betainc(dfW5/(dfW5+tvalW5^2), dfW5/2.0, b)
 copy_VarCoords(rcMmt, pM)
 copy_VarCoords(rcW5mt, pW5)
 copy_VarCoords(rcU8mt, pU8)
 copy_VarCoords(rcV8mt, pV8)
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
 mMmt   = rcMsa
 mV8mt  = rcV8sa
 mU8mt  = rcU8sa
 rU8mt  = rcU8sa
 rV8mt  = rcV8sa
 mW5mt  = rcW5sa 
 mMmt   = where( pM.lt.siglvl, rcMmt, 0.)
 mW5mt  = where( pW5.lt.siglvl, rcW5mt, 0.);mask(rcW5sa,pW5.lt.siglvl,True); where( pW5.lt.0.5, rcW5sa, rcW5sa@_FillValue)
 mU8mt  = where( (pU8.lt.siglvl).or.(pV8.lt.siglvl), rcU8mt, rcU8mt@_FillValue)     ; significant u,v
 mV8mt  = where( (pU8.lt.siglvl).or.(pV8.lt.siglvl), rcV8mt, rcU8mt@_FillValue)
 rU8mt  = where( (pU8.lt.siglvl).or.(pV8.lt.siglvl), rcU8mt@_FillValue, rcU8mt)  ; not significant u,v
 rV8mt  = where( (pU8.lt.siglvl).or.(pV8.lt.siglvl), rcU8mt@_FillValue, rcV8mt)
 delete(pM)
 delete(pU8)
 delete(pV8)

 ;sam

 tvalM   = onedtond(rcMsa@tval, dimsizes(rcMsa))         ; Output puts tval and nptxy into 1D arrays
 dfM     = onedtond(rcMsa@nptxy, dimsizes(rcMsa)) -2     ; of size nlat*nlon
 tvalU8  = onedtond(rcU8sa@tval, dimsizes(rcU8sa))
 dfU8    = onedtond(rcU8sa@nptxy, dimsizes(rcU8sa)) -2
 tvalV8  = onedtond(rcV8sa@tval, dimsizes(rcV8sa))
 dfV8    = onedtond(rcV8sa@nptxy, dimsizes(rcV8sa)) -2
 tvalW5  = onedtond(rcW5sa@tval, dimsizes(rcW5sa))
 dfW5    = onedtond(rcW5sa@nptxy, dimsizes(rcW5sa)) -2
 bm      = tvalM                                     ; b must be same dimension as tval and df
 bm      = 0.5
 b       = tvalU8                                     ; b must be same dimension as tval and df
 b       = 0.5

; p-values
 pM     = betainc(dfM/(dfM+tvalM^2), dfM/2.0, bm)
 pU8    = betainc(dfU8/(dfU8+tvalU8^2), dfU8/2.0, b)
 pV8    = betainc(dfV8/(dfV8+tvalV8^2), dfV8/2.0, b)
 pW5    = betainc(dfW5/(dfW5+tvalW5^2), dfW5/2.0, b)
 copy_VarCoords(rcMsa, pM)
 copy_VarCoords(rcW5sa, pW5)
 copy_VarCoords(rcU8sa, pU8)
 copy_VarCoords(rcV8sa, pV8)
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
 mMsa   = rcMsa
 mV8sa  = rcV8sa
 mU8sa  = rcU8sa
 rU8sa  = rcU8sa
 rV8sa  = rcV8sa
 mW5sa  = rcW5sa
 mMsa   = where( pM.lt.siglvl, rcMsa, 0.)
 mW5sa  = where( pW5.lt.siglvl, rcW5sa, 0.);mask(rcW5sa,pW5.lt.siglvl,True); where( pW5.lt.0.5, rcW5sa, rcW5sa@_FillValue)
 mU8sa  = where( (pU8.lt.siglvl).or.(pV8.lt.siglvl), rcU8sa, rcU8sa@_FillValue)     ; significant u,v
 mV8sa  = where( (pU8.lt.siglvl).or.(pV8.lt.siglvl), rcV8sa, rcU8sa@_FillValue)
 rU8sa  = where( (pU8.lt.siglvl).or.(pV8.lt.siglvl), rcU8sa@_FillValue, rcU8sa)  ; not significant u,v
 rV8sa  = where( (pU8.lt.siglvl).or.(pV8.lt.siglvl), rcU8sa@_FillValue, rcV8sa)
 delete(pM)
 delete(pU8)
 delete(pV8)

 ; tpi
 tvalM   = onedtond(rcMtp@tval, dimsizes(rcMtp))         ; Output puts tval and nptxy into 1D arrays
 dfM     = onedtond(rcMtp@nptxy, dimsizes(rcMtp)) -2     ; of size nlat*nlon
 tvalU8  = onedtond(rcU8tp@tval, dimsizes(rcU8tp))
 dfU8    = onedtond(rcU8tp@nptxy, dimsizes(rcU8tp)) -2
 tvalV8  = onedtond(rcV8tp@tval, dimsizes(rcV8tp))
 dfV8    = onedtond(rcV8tp@nptxy, dimsizes(rcV8tp)) -2
 tvalW5  = onedtond(rcW5tp@tval, dimsizes(rcW5tp))
 dfW5    = onedtond(rcW5tp@nptxy, dimsizes(rcW5tp)) -2
 bm      = tvalM                                     ; b must be same dimension as tval and df
 bm      = 0.5
 b       = tvalU8                                     ; b must be same dimension as tval and df
 b       = 0.5

; p-values
 pM   = betainc(dfM/(dfM+tvalM^2), dfM/2.0, bm)
 pU8  = betainc(dfU8/(dfU8+tvalU8^2), dfU8/2.0, b)
 pV8  = betainc(dfV8/(dfV8+tvalV8^2), dfV8/2.0, b)
 pW5  = betainc(dfW5/(dfW5+tvalW5^2), dfW5/2.0, b)
 copy_VarCoords(rcMtp, pM)
 copy_VarCoords(rcW5tp, pW5)
 copy_VarCoords(rcU8tp, pU8)
 copy_VarCoords(rcV8tp, pV8)
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
 mMtp   = rcMsa
 mV8tp  = rcV8sa
 mU8tp  = rcU8sa
 rU8tp  = rcU8sa
 rV8tp  = rcV8sa
 mW5tp  = rcW5sa
 mMtp   = where( pM.lt.siglvl, rcMtp, 0.)
 mW5tp  = where( pW5.lt.siglvl, rcW5tp, 0.);mask(rcW5sa,pW5.lt.siglvl,True); where( pW5.lt.0.5, rcW5sa, rcW5sa@_FillValue)
 mU8tp  = where( (pU8.lt.siglvl).or.(pV8.lt.siglvl), rcU8tp, rcU8tp@_FillValue)     ; significant u,v
 mV8tp  = where( (pU8.lt.siglvl).or.(pV8.lt.siglvl), rcV8tp, rcU8tp@_FillValue)
 rU8tp  = where( (pU8.lt.siglvl).or.(pV8.lt.siglvl), rcU8tp@_FillValue, rcU8tp)  ; not significant u,v
 rV8tp  = where( (pU8.lt.siglvl).or.(pV8.lt.siglvl), rcU8tp@_FillValue, rcV8tp)
 delete(pM)
 delete(pU8)
 delete(pV8)
 
 ; n34
 tvalM   = onedtond(rcMn3@tval, dimsizes(rcMn3))         ; Output puts tval and nptxy into 1D arrays
 dfM     = onedtond(rcMn3@nptxy, dimsizes(rcMn3)) -2     ; of size nlat*nlon
 tvalU8  = onedtond(rcU8n3@tval, dimsizes(rcU8n3))
 dfU8    = onedtond(rcU8n3@nptxy, dimsizes(rcU8n3)) -2
 tvalV8  = onedtond(rcV8n3@tval, dimsizes(rcV8n3))
 dfV8    = onedtond(rcV8n3@nptxy, dimsizes(rcV8n3)) -2
 tvalW5  = onedtond(rcW5n3@tval, dimsizes(rcW5n3))
 dfW5    = onedtond(rcW5n3@nptxy, dimsizes(rcW5n3)) -2
 bm      = tvalM                                     ; b must be same dimension as tval and df
 bm      = 0.5
 b       = tvalU8                                     ; b must be same dimension as tval and df
 b       = 0.5

; p-values
 pM   = betainc(dfM/(dfM+tvalM^2), dfM/2.0, bm)
 pU8  = betainc(dfU8/(dfU8+tvalU8^2), dfU8/2.0, b)
 pV8  = betainc(dfV8/(dfV8+tvalV8^2), dfV8/2.0, b)
 pW5  = betainc(dfW5/(dfW5+tvalW5^2), dfW5/2.0, b)
 copy_VarCoords(rcMn3, pM)
 copy_VarCoords(rcW5n3, pW5)
 copy_VarCoords(rcU8n3, pU8)
 copy_VarCoords(rcV8n3, pV8)
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
 mMn3   = rcMsa
 mV8n3  = rcV8sa
 mU8n3  = rcU8sa
 rU8n3  = rcU8sa
 rV8n3  = rcV8sa
 mW5n3  = rcW5sa
 mMn3   = where( pM.lt.siglvl, rcMn3, 0.)
 mW5n3  = where( pW5.lt.siglvl, rcW5n3, 0.);mask(rcW5sa,pW5.lt.siglvl,True); where( pW5.lt.0.5, rcW5sa, rcW5sa@_FillValue)
 mU8n3  = where( (pU8.lt.siglvl).or.(pV8.lt.siglvl), rcU8n3, rcU8n3@_FillValue)     ; significant u,v
 mV8n3  = where( (pU8.lt.siglvl).or.(pV8.lt.siglvl), rcV8n3, rcU8n3@_FillValue)
 rU8n3  = where( (pU8.lt.siglvl).or.(pV8.lt.siglvl), rcU8n3@_FillValue, rcU8n3)  ; not significant u,v
 rV8n3  = where( (pU8.lt.siglvl).or.(pV8.lt.siglvl), rcU8n3@_FillValue, rcV8n3)
 delete(pM)
 delete(pU8)
 delete(pV8)

 ;dmi
 tvalM   = onedtond(rcMdm@tval, dimsizes(rcMdm))         ; Output puts tval and nptxy into 1D arrays
 dfM     = onedtond(rcMdm@nptxy, dimsizes(rcMdm)) -2     ; of size nlat*nlon
 tvalU8  = onedtond(rcU8dm@tval, dimsizes(rcU8dm))
 dfU8    = onedtond(rcU8dm@nptxy, dimsizes(rcU8dm)) -2
 tvalV8  = onedtond(rcV8dm@tval, dimsizes(rcV8dm))
 dfV8    = onedtond(rcV8dm@nptxy, dimsizes(rcV8dm)) -2
 tvalW5  = onedtond(rcW5dm@tval, dimsizes(rcW5dm))
 dfW5    = onedtond(rcW5dm@nptxy, dimsizes(rcW5dm)) -2
 bm      = tvalM                                     ; b must be same dimension as tval and df
 bm      = 0.5
 b       = tvalU8                                     ; b must be same dimension as tval and df
 b       = 0.5

; p-values
 pM   = betainc(dfM/(dfM+tvalM^2), dfM/2.0, bm)
 pU8  = betainc(dfU8/(dfU8+tvalU8^2), dfU8/2.0, b)
 pV8  = betainc(dfV8/(dfV8+tvalV8^2), dfV8/2.0, b)
 pW5  = betainc(dfW5/(dfW5+tvalW5^2), dfW5/2.0, b)
 copy_VarCoords(rcMdm, pM)
 copy_VarCoords(rcW5dm, pW5)
 copy_VarCoords(rcU8dm, pU8)
 copy_VarCoords(rcV8dm, pV8)
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
 mMdm   = rcMsa
 mV8dm  = rcV8sa
 mU8dm  = rcU8sa
 rU8dm  = rcU8sa
 rV8dm  = rcV8sa
 mW5dm  = rcW5sa
 mMdm   = where( pM.lt.siglvl, rcMdm, 0.)
 mW5dm  = where( pW5.lt.siglvl, rcW5dm, 0.);mask(rcW5sa,pW5.lt.siglvl,True); where( pW5.lt.0.5, rcW5sa, rcW5sa@_FillValue)
 mU8dm  = where( (pU8.lt.siglvl).or.(pV8.lt.siglvl), rcU8dm, rcU8dm@_FillValue)     ; significant u,v
 mV8dm  = where( (pU8.lt.siglvl).or.(pV8.lt.siglvl), rcV8dm, rcU8dm@_FillValue)
 rU8dm  = where( (pU8.lt.siglvl).or.(pV8.lt.siglvl), rcU8dm@_FillValue, rcU8dm)  ; not significant u,v
 rV8dm  = where( (pU8.lt.siglvl).or.(pV8.lt.siglvl), rcU8dm@_FillValue, rcV8dm)
 delete(pM)
 delete(pU8)
 delete(pV8)

 rcMmt@long_name   = ""           ; remove so it doesn't appear on plots
 rcMmt@units       = ""
 rU8mt@long_name   = ""
 rU8mt@units       = ""
 rV8mt@long_name   = ""
 rV8mt@units       = ""
 mMmt@long_name    = ""           ; remove so it doesn't appear on plots
 mMmt@units        = ""
 mU8mt@long_name   = ""
 mU8mt@units       = ""
 mV8mt@long_name   = ""
 mV8mt@units       = ""

 rcMsa@long_name   = ""           ; remove so it doesn't appear on plots
 rcMsa@units       = ""
 rU8sa@long_name   = ""
 rU8sa@units       = ""
 rV8sa@long_name   = ""
 rV8sa@units       = ""
 mMsa@long_name    = ""           ; remove so it doesn't appear on plots
 mMsa@units        = ""
 mU8sa@long_name   = ""
 mU8sa@units       = ""
 mV8sa@long_name   = ""
 mV8sa@units       = ""

 rcMtp@long_name   = ""           ; remove so it doesn't appear on plots
 rcMtp@units       = ""
 rU8tp@long_name   = ""
 rU8tp@units       = ""
 rV8tp@long_name   = ""
 rV8tp@units       = ""
 mMtp@long_name    = ""           ; remove so it doesn't appear on plots
 mMtp@units        = ""
 mU8tp@long_name   = ""
 mU8tp@units       = ""
 mV8tp@long_name   = ""
 mV8tp@units       = ""

 rcMn3@long_name   = ""           ; remove so it doesn't appear on plots
 rcMn3@units       = ""
 rU8n3@long_name   = ""
 rU8n3@units       = ""
 rV8n3@long_name   = ""
 rV8n3@units       = ""
 mMn3@long_name    = ""           ; remove so it doesn't appear on plots
 mMn3@units        = ""
 mU8n3@long_name   = ""
 mU8n3@units       = ""
 mV8n3@long_name   = ""
 mV8n3@units       = ""

 rcMdm@long_name   = ""           ; remove so it doesn't appear on plots
 rcMdm@units       = ""
 rU8dm@long_name   = ""
 rU8dm@units       = ""
 rV8dm@long_name   = ""
 rV8dm@units       = ""
 mMdm@long_name    = ""           ; remove so it doesn't appear on plots
 mMdm@units        = ""
 mU8dm@long_name   = ""
 mU8dm@units       = ""
 mV8dm@long_name   = ""
 mV8dm@units       = ""




; ------------------- pattern correlation ----------------
 clat  = cos(rcMmt&latitude*rad)
 copy_VarCoords(rcMmt(:,0),clat)
 ;cos(lat) weighting, uncentered
 mctpi = pattern_cor(rcMmt({-45:-5},{105:160}), rcMtp({-45:-5},{105:160}), clat({-45:-5}), 1)    
 mcsam = pattern_cor(rcMmt({-45:-5},{105:160}), rcMsa({-45:-5},{105:160}), clat({-45:-5}), 1)
 mcn34 = pattern_cor(rcMmt({-45:-5},{105:160}), rcMn3({-45:-5},{105:160}), clat({-45:-5}), 1) 
 mcdmi = pattern_cor(rcMmt({-45:-5},{105:160}), rcMdm({-45:-5},{105:160}), clat({-45:-5}), 1)

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
  res@gsnStringFontHeightF  = 0.09        	 ; make all font size bigger
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
  
  resM@vcMinDistanceF          = 0.027  ; 017      ; thin vectors (small is more crowded)
  resM@vcMonoLineArrowColor    = True
  resM@vcLineArrowThicknessF   = 3.	;2.4   ;2.3
  resM@vcGlyphOpacityF         = 0.4
  resM@vcLineArrowHeadMinSizeF = 0.00          ; keep arrow heads similar size.
  resM@vcLineArrowHeadMaxSizeF = 0.025
  resM@vcRefMagnitudeF         = 2.               ; define vector ref mag
  resM@vcRefLengthF            = .05               ; define length of vec ref
  resM@vcRefAnnoOn             = True
  resM@vcRefAnnoOrthogonalPosF = -0.12          ; move reference vector up
  resM@vcLabelFontHeightF      = 0.25

  resMs			        = resM
  resMs@cnLinesOn               = False           ; turn off contour lines
  resMs@cnFillOn                = True            ; Turn on fill True
  resMs@cnFillPalette           = "CBR_coldhot"
  resMs@vcRefAnnoOn             = False
  resMs@vcGlyphOpacityF         = 1.; 0.8
  resMs@lbLabelStride              = 2
  ;resMs@lbLabelFontHeightF         = 0.025
  resMs@pmLabelBarHeightF          = 0.2
  resMs@pmLabelBarWidthF           = 1.5
  resMs@lbOrientation              = "Horizontal"; "Vertical"        ; orientation
  resMs@pmLabelBarOrthogonalPosF   = 0.15	; move label bar down
  ;resMs@gsnRightStringFontHeightF  = 0.06
  ; sig omega 500
  resW			     = res
  resW@cnMinLevelValF        = -0.02; -.035
  resW@cnMaxLevelValF        = 0.02; .035
  resW@cnLevelSpacingF       = 0.01; .01
  resW@cnLineThicknessF      = 3.
  ;resW@cnInfoLabelOn        = False
  resW@gsnContourZeroLineThicknessF = 0.

  resMs@gsnCenterString             = "Low-level circulation"
  plot                              = gsn_csm_vector_scalar_map(wks, rU8mt, rV8mt, rcMmt, resM)
  plotMs                            = gsn_csm_vector_scalar(wks,mU8mt,mV8mt, mMmt, resMs)
  plotw                             = gsn_csm_contour(wks,mW5mt, resW)
  plotW                             = ColorNegDashZeroPosContour(plotw,"chartreuse1","black","violetred")
  overlay(plot,plotMs)
  overlay(plot,plotW)
  plots(0)                          = plot
  delete(plot)
  delete(plotMs)
  delete(rcMmt)
  delete(rcU8mt)
  delete(rcV8mt)
  delete(rU8mt)
  delete(rV8mt)
  delete(mMmt)
  delete(mU8mt)
  delete(mV8mt)
  delete(plotw)
  delete(plotW)
  delete(mW5mt)

  resMs@gsnCenterString             = ""
  ;resMs@gsnLeftString		    = "Corr " +   sprintf("%5.2f",mcsam)
  plot                              = gsn_csm_vector_scalar_map(wks, rU8sa, rV8sa, rcMsa, resM)
  plotMs                            = gsn_csm_vector_scalar(wks,mU8sa,mV8sa, mMsa, resMs)
  plotw                             = gsn_csm_contour(wks,mW5sa, resW)
  plotW                             = ColorNegDashZeroPosContour(plotw,"chartreuse1","black","violetred")
  overlay(plot,plotMs)
  overlay(plot,plotW)
  plots(1)                          = plot
  delete(plot)
  delete(plotMs)
  delete(rcMsa)
  delete(rcU8sa)
  delete(rcV8sa)
  delete(rU8sa)
  delete(rV8sa)
  delete(mMsa)
  delete(mU8sa)
  delete(mV8sa)
  delete(plotw)
  delete(plotW)
  delete(mW5sa)

  ;resMs@gsnLeftString               = "Corr " +   sprintf("%5.2f",mctpi)
  plot                              = gsn_csm_vector_scalar_map(wks, rU8tp, rV8tp, rcMtp, resM)
  plotMs                            = gsn_csm_vector_scalar(wks,mU8tp,mV8tp, mMtp, resMs)
  plotw                             = gsn_csm_contour(wks,mW5tp, resW)
  plotW                             = ColorNegDashZeroPosContour(plotw,"chartreuse1","black","violetred")
  overlay(plot,plotMs)
  overlay(plot,plotW)
  plots(2)                          = plot
  delete(plot)
  delete(plotMs)
  delete(rcMtp)
  delete(rcU8tp)
  delete(rcV8tp)
  delete(rU8tp)
  delete(rV8tp)
  delete(mMtp)
  delete(mU8tp)
  delete(mV8tp)
  delete(plotw)
  delete(plotW)      
  delete(mW5tp)

  ;resMs@gsnLeftString               = "Corr " +   sprintf("%5.2f",mcn34)
  plot                              = gsn_csm_vector_scalar_map(wks, rU8n3, rV8n3, rcMn3, resM)
  plotMs                            = gsn_csm_vector_scalar(wks,mU8n3,mV8n3, mMn3, resMs)
  plotw                             = gsn_csm_contour(wks,mW5n3, resW)
  plotW                             = ColorNegDashZeroPosContour(plotw,"chartreuse1","black","violetred")
  overlay(plot,plotMs)
  overlay(plot,plotW)
  plots(3)                          = plot
  delete(plot)
  delete(plotMs)
  delete(rcMn3)
  delete(rcU8n3)
  delete(rcV8n3)
  delete(rU8n3)
  delete(rV8n3)
  delete(mMn3)
  delete(mU8n3)
  delete(mV8n3)
  delete(plotw)
  delete(plotW)      
  delete(mW5n3)

  ;resMs@gsnLeftString               = "Corr " +   sprintf("%5.2f",mcdmi)
  plot                              = gsn_csm_vector_scalar_map(wks, rU8dm, rV8dm, rcMdm, resM)
  plotMs                            = gsn_csm_vector_scalar(wks,mU8dm,mV8dm, mMdm, resMs)
  plotw                             = gsn_csm_contour(wks,mW5dm, resW)
  plotW                             = ColorNegDashZeroPosContour(plotw,"chartreuse1","black","violetred")
  overlay(plot,plotMs)
  overlay(plot,plotW)
  plots(4)                          = plot
  delete(plot)
  delete(plotMs)
  delete(rcMdm)
  delete(rcU8dm)
  delete(rcV8dm)
  delete(rU8dm)
  delete(rV8dm)
  delete(mMdm)
  delete(mU8dm)
  delete(mV8dm)
  delete(plotw)
  delete(plotW)      
  delete(mW5dm)
  resMs@gsnLeftString               = ""

 resP                = True
 resP@gsnMaximize    = True
 resP@gsnFrame       = False
 resP@gsnPanelLeft   = 0.015
 resP@gsnPanelBottom = 0.08
 resP@gsnPanelSave   = True      ; Save the state of the paneled plots so we can
                                 ; query for text strings locations.
 resP@gsnPanelFigureStringsFontHeightF = 0.013
 resP@gsnPanelFigureStrings       = (/"a","c","f","i","l"/);,"f","h", "i", "j"/) ; add strings to panel
 resP@amJust                      = "TopLeft"
 resP@gsnPanelLabelBar            = True    ; add common colorbar

 gsn_panel(wks, plots, (/5,1/), resP)  ; plots
;**********************************************************************
; Add rotated text strings on left side of paneled plots.
; Use the resized plots to determine the position of the titles
;**********************************************************************
 pos1 = get_title_position(plots(0))         ; 1st row leftmost plot
 pos2 = get_title_position(plots(1))         ; 2nd row leftmost plot
 pos3 = get_title_position(plots(2))         ; 3rd row leftmost plot
 pos4 = get_title_position(plots(3)) 
 pos5= get_title_position(plots(4)) 
 posL = get_label_position(plots(4))	     ; last plot (for positioning label)


 txres               = True
 txres@txFontHeightF = 0.015
 txres@txAngleF      = 90.
 gsn_text_ndc(wks, "Max. T.",   pos1(0), pos1(1), txres)
 gsn_text_ndc(wks, "SAMx-1",   pos2(0), pos2(1), txres)
 gsn_text_ndc(wks, "TPIx-1", pos3(0), pos3(1), txres)
 gsn_text_ndc(wks, "Nino3.4",   pos4(0), pos4(1), txres)
 gsn_text_ndc(wks, "DMI", pos5(0), pos5(1), txres)
 txres@txAngleF      = 0.
 txres@txFontHeightF = 0.013
 gsn_text_ndc(wks, "hPa", posL(0), posL(1), txres)    
 frame(wks)

 end do		; season loop
 
break
end do		; region loop

end




