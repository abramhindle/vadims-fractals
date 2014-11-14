<CsoundSynthesizer>
<CsOptions>
; Select audio/midi flags here according to platform
; Audio out   Audio in    No messages
;-odac           -iadc     -d     ;;;RT audio I/O
; For Non-realtime ouput leave only the line below:
 -o dconv.wav -W ;;; for file output any platform
</CsOptions>
<CsInstruments>

sr = 44100
kr = 4410
ksmps = 10
nchnls = 1
 
#define SIZE #32768#
giImpulse01     ftgen   101, 0, $SIZE, 1, "0005-10.000000-5800.000000.wav", 0, 0, 0	

itmp	ftgen 4, 0, 1024, 10, 1

instr 1
itable  init    101
iseed   init    .6
isize   init    ftlen(itable)
iloud   = 10000
ihz     =    440
kfq     line    1, p3, 10
;asig    rand    10000, .5, 1
aamp    adsr (p3*0.1), (p3*0.1), 0.7, (p3*0.6)
asig      oscil   iloud, ihz, 4
;        out     a1*aamp
;asig    butlp   asig, 5000
asig    dconv   asig, isize, itable
        out     asig *.5
endin


</CsInstruments>
<CsScore>

f1 0 16 10 1
i1 0 10
e


</CsScore>
</CsoundSynthesizer>
