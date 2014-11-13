500.sco: process.sh
	bash process.sh

500.wav: 500.sco grains2.orc
	csound -o500.wav grains2.orc 500.sco

5001.wav: 5001.sco grains2.orc
	csound -o5001.wav grains2.orc 5001.sco


live: 500.sco grains2.orc
	csound -+rtaudio=jack -dm6 -B 4096 -odac grains2.orc 500.sco

movie: 500.mov 500.wav
	mplayer 500.mov --audiofile=500.wav

play: 
	mplayer 500.mov --audiofile=500.wav

5001:
	mplayer 500.mov --audiofile=5001.wav

sine:
	go run idea.go >sine.sco
	csound -o what.wav sine.orc sine.sco
	mplayer what.wav

pict.sco: pict.go
	go run pict.go >pict.sco
pict.wav: pict.sco
	csound -o pict.wav sine.orc pict.sco
pict: pict.wav
	mplayer 50.mov --audiofile=pict.wav

