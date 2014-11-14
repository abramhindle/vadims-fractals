<CsoundSynthesizer>
<CsOptions>
; -L stdin -odac           -iadc     -dm6    ;;;RT audio I/O
-L stdin -odac           -iadc     -dm6  -+rtaudio=jack -+jack_client=csoundGrain  -b 1024 -B 2048   ;;;RT audio I/O
; For Non-realtime ouput leave only the line below:
; -o grain3.wav -W ;;; for file output any platform
</CsOptions>
<CsInstruments>

sr	=  44100
;kr      =  100
ksmps   =  16
nchnls	=  1

;;;#define SIZE #268435456#
#define SIZE #4194304#


maxalloc 556, 600; Limit instances
maxalloc 550, 600; Limit instances
maxalloc 551, 600; Limit instances
maxalloc 552, 600; Limit instances


maxalloc 700, 75; Limit instances
maxalloc 701, 75; Limit instances
maxalloc 702, 75; Limit instances
maxalloc 703, 75; Limit instances
maxalloc 704, 75; Limit instances



/* f#  time  size  1  filcod  skiptime  format  channel */
giImpulse01     ftgen   101, 0, $SIZE, 1, "goldberg-aria-da-capo.wav", 0, 0, 0	
;giImpulse02     ftgen   102, 0, $SIZE, 1, "/opt/hindle1/hdprojects/granular/videogames.wav", 0, 0, 0	
;giImpulse03     ftgen   103, 0, $SIZE, 1, "/home/hindle1/projects/granular/palette/some-jam.wav", 0, 0, 0	
;giImpulse04     ftgen   104, 0, $SIZE, 1, "/opt/hindle1/Music/20140420/ferry-sounds3-good.WAV", 0, 0, 0	
;giImpulse05     ftgen   105, 0, $SIZE, 1, "/opt/hindle1/Music/20140420/Sabatini-Scaramouche-01-01.wav", 0, 0, 0	


/* Bartlett window */
itmp	ftgen 1, 0, 16384, 20, 3, 1
/* sawtooth wave */
itmp	ftgen 2, 0, 16384, 7, 1, 16384, -1
/* sine */
itmp	ftgen 4, 0, 1024, 10, 1

        instr 1
        idur = 0.05
	p3 = idur
        iamp = 100
	ix = p4
	iy = p5
	iz = p6
	iloc = p6 + 500*(ix + 500*iy)
        ipitch = (1.0 / ($SIZE / 44100)) ; 16 1.352e-12 ; 2 is 2X 0.5 is 1/2
	iTab = 101
iphase  wrap iloc/(500*500*500), 0.0, 1.0
aenv    oscili iamp, 1/idur, 1        
; aa01     poscil iamp01, ipitch, 101, iphase
aa      oscili 1.0, ipitch, iTab, iphase
        out aenv*(aa)
        endin


; the grain
        instr 556
        idur = p3
        iamp = p4
        ipitch = (p5 / ($SIZE / 44100)) ; 16 1.352e-12 ; 2 is 2X 0.5 is 1/2
        iphase = p6
        iamp01 =  p7
aenv    oscili iamp, 1/idur, 1        
aa01     poscil iamp01, ipitch, 101, iphase
        out aenv*(aa01)
        endin

        instr 557
        idur = p3
        iamp = p4
        ipitch = p5 * (1.0 / ($SIZE / 44100)) ; 16 1.352e-12 ; 2 is 2X 0.5 is 1/2
        iphase = p6
aa      oscili iamp, ipitch, 101, iphase
        out aa
        endin





</CsInstruments>
<CsScore>

t 0 60

f 0 3600

i556 0 0.1 11111 4.0 0.52 1.0
i556 0.1 0.1 11111 4.0 0.53 1.0
i556 0.2 0.1 11111 4.0 0.54 1.0
i556 0.3 0.1 11111 4.0 0.55 1.0
i556 0.4 0.1 11111 4.0 0.56 1.0
i556 0.5 0.1 11111 4.0 0.57 1.0
i556 0 0.1 11111 4.0 0.42 1.0
i556 0.1 0.1 11111 4.0 0.43 1.0
i556 0.2 0.1 11111 4.0 0.44 1.0
i556 0.3 0.1 11111 4.0 0.45 1.0
i556 0.4 0.1 11111 4.0 0.46 1.0
i556 0.5 0.1 11111 4.0 0.47 1.0


</CsScore>
</CsoundSynthesizer>
