500.sco: process.sh
	bash process.sh

500.wav: 500.sco grains2.orc
	csound -o500.wav grains2.orc 500.sco

live: 500.sco grains2.orc
	csound -+rtaudio=jack -dm6 -B 4096 -odac grains2.orc 500.sco
