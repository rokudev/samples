#!/bin/bash
#
# Copyright (c) 2016-2019 Roku, Inc. All rights reserved.
#
# This script assumes ffmpeg is installed on your Linux or Mac, it gets thumbnails from a stream at fixed intervals
# For the RAFSSAI-with-jpeg example, the thumbnails were extracted at 5 seconds intervals
#
# ./gen_thumbs.sh ssai-video.mp4 thumb 5
#
# Reference:
# https://trac.ffmpeg.org/wiki/Create%20a%20thumbnail%20image%20every%20X%20seconds%20of%20the%20video
#

if [ $# -lt 3 ]; then
	echo "Usage: $0 <input-file> <output-file-prefix> <interval>"
	exit 1
fi

INFILE=$1
OUTPREFIX=$2
INTERVAL=$3

# Command to get thumbnails at specific intervals
ffmpeg -i $INFILE -vf fps=1/$INTERVAL -s 240x135 thumbs/$OUTPREFIX-%d.jpg
