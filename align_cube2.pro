PRO ALIGN_CUBE2, data, FFT=FFT, FILTER=FILTER, DISPLAY=DISPLAY, shifts=shifts, $
    SILENT=SILENT, SUBPIXEL=SUBPIXEL, RUNNING=RUNNING, SUBFRAME=SUBFRAME, CROSS=CROSS

; align_cube2, data, [/fft, /subpixel, running=10, subframe=[x1,x2,y1,y2] in pixels]

dim=SIZE(data)

IF NOT KEYWORD_SET(filter) THEN filter=0
IF NOT KEYWORD_SET(running) THEN running=dim[1]+1

ref=REFORM(data[0,*,*])
dim2=SIZE(ref)

IF NOT KEYWORD_SET(subframe) THEN subframe=[0.3*dim2[1],0.7*dim2[1],0.3*dim2[2],0.7*dim2[2]]

ref=ref[subframe[0]:subframe[1],subframe[2]:subframe[3]]
dim2=SIZE(ref)

shifts=FLTARR(dim[1],2)

IF KEYWORD_SET(display) THEN WINDOW, XS=2*dim2[1], YS=dim2[2]

icnt=0
FOR i=0, dim[1]-2 DO BEGIN
   tmp=REFORM(data[i,*,*])   
   tmps=tmp[subframe[0]:subframe[1],subframe[2]:subframe[3]]

   IF FILTER THEN tmps=FILT_IMG(tmps, filter, /LOW)
   
   IF NOT KEYWORD_SET(FFT) AND KEYWORD_SET(CROSS) THEN offset=ALIGN(ref, tmps)
   IF KEYWORD_SET(FFT)   THEN offset=ALIGNOFFSET(ref, tmps, cor)
   IF KEYWORD_SET(CROSS) THEN offset=MY_C_CORRELATION(ref, tmps)

   IF NOT KEYWORD_SET(silent) THEN PRINT, 'Aligning image',i+1,'  out of', dim[1],'  ---- Offset Image#', i, offset[0], offset[1]

   IF KEYWORD_SET(subpixel) THEN data[i,*,*]=SHIFT_SUB(tmp, offset[0], offset[1]) $
                            ELSE data[i,*,*]=SHIFT(tmp, offset[0], offset[1])

   shifts[i+1,0]=offset[0]
   shifts[i+1,1]=offset[1]

;;;;;;;;;;;;;;;;;;;;;;   IF offset[0] LT 20 AND offset[1] LT 20 THEN icnt=icnt+1
   icnt=icnt+1

   IF KEYWORD_SET(display) THEN BEGIN
      TVSCL, ref, 0, 0
      TVSCL, SHIFT_SUB(tmps, offset[0], offset[1]), dim2[1], 0
      ENDIF
   
   IF RUNNING EQ icnt THEN BEGIN
      ref=REFORM(data[i,*,*])
      ref=ref[subframe[0]:subframe[1],subframe[2]:subframe[3]]
      icnt=0
      ENDIF
      
   ENDFOR

END
