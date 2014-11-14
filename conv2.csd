<CsoundSynthesizer>
<CsOptions>
; Select audio/midi flags here according to platform
-odac     ;;;RT audio out
-iadc    ;;;uncomment -iadc if RT audio input is needed too
; For Non-realtime ouput leave only the line below:
;-o convolve.wav -W ;;; for file output any platform
</CsOptions>
<CsInstruments>
; NB: 'Small' reverbs often require a much higher
; percentage of wet signal to sound interesting. 'Large'
; reverbs seem require less. Experiment! The wet/dry mix is
; very important - a small change can make a large difference.

sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1
;The analysis file is not system independent! 
; create "rv_mono.wav" and "rv_stereo.wav" with cvanal first!
#define SIZE #4194304#

giImpulse01     ftgen   101, 0, $SIZE, 1, "goldberg-aria-da-capo.wav", 0, 0, 0	

instr 1 

imix = 0.25	;wet/dry mix. Vary as desired.
ivol = 1 	;Overall volume level of reverb. May need to adjust
ipitch = (1.0 / ($SIZE / 44100)) 
iphase = 0.0
iamp = 100
adry      oscili iamp, ipitch, 101, iphase
awet    convolve adry,p4 ; "0005-10.000000-5800.000000.cv"	; mono convolved (wet) audio
awet    diff    awet                    ; brighten
out    ivol*(awet)

endin

</CsInstruments>
<CsScore>

i 1 + 5 "0000-10.000000-5800.000000.cv"
i 1 + 5 "0001-10.000000-5800.000000.cv"
i 1 + 5 "0002-10.000000-5800.000000.cv"
i 1 + 5 "0003-10.000000-5800.000000.cv"
i 1 + 5 "0004-10.000000-5800.000000.cv"
i 1 + 5 "0005-10.000000-5800.000000.cv"
i 1 + 5 "0006-10.000000-5800.000000.cv"
i 1 + 5 "0007-10.000000-5800.000000.cv"

e
</CsScore>
</CsoundSynthesizer>
