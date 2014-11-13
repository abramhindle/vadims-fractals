#!/bin/bash
for size in 0.1 1 10 100
do
    for speed in 100 300 1000 3800 10000 100000
    do
        for decay in 0.1 0.5 0.7 0.8 0.9
        do
            echo bash mk50vid.sh $size $speed $decay
        done
    done
done
