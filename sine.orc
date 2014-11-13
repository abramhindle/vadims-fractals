sr	=  44100
;kr      =  100
ksmps   =  16
nchnls	=  1
0dbfs = 4

/* Bartlett window */
itmp	ftgen 1, 0, 16384, 20, 3, 1
/* sawtooth wave */
itmp	ftgen 2, 0, 16384, 7, 1, 16384, -1
/* sine */
itmp	ftgen 4, 0, 1024, 10, 1


        instr   sine
        idur = p3
        iloud = p4
        ihz = (p5>0)?p5:440
aamp    adsr (p3*0.1), (p3*0.1), 0.7, (p3*0.6)
a1      oscil   iloud, ihz, 4
        out     a1*aamp
        endin
