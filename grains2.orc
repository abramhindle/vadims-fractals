sr	=  44100
kr      =  44.1
nchnls	=  1

;;;#define SIZE #268435456#
#define SIZE #4194304#

/* f#  time  size  1  filcod  skiptime  format  channel */
;giImpulse01     ftgen   101, 0, $SIZE, 1, "samples/goldberg-aria-da-capo.wav", 0, 0, 0	
;giImpulse01     ftgen   101, 0, $SIZE, 1, "samples/peergynt4.wav", 0, 0, 0	
giImpulse01     ftgen   101, 0, $SIZE, 1, "samples/peergynt1.wav", 0, 0, 0	
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
        idur = 10*p3
	p3 = 0.2
        iamp = 1000
	ix = p4 - 250
	iy = p5 - 250
	iz = p6 - 250
	iloc = iz + 500*(ix + 500*iy)
        ipitch = ((5.0 - 4.5*(p2/30.0)) / ($SIZE / 44100)) ; 16 1.352e-12 ; 2 is 2X 0.5 is 1/2
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
