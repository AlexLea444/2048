#!/bin/bash

for i in *.png
do
    filename=$(basename $i _bkp.png)
    ffmpeg -i $i -vf scale="150:150" "${filename}.png" -y
done
