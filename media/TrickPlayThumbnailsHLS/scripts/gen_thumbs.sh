#!/bin/bash
#
# #  Copyright (c) 2019-2020 Roku, Inc. All rights reserved.
#
# References:
# https://superuser.com/questions/613002/ffmpeg-how-to-create-cropped-thumbnails
# https://trac.ffmpeg.org/wiki/Create%20a%20thumbnail%20image%20every%20X%20seconds%20of%20the%20video

if [ $# -lt 4 ]; then
	echo "Usage: $0 <input-file> <output-file-prefix> <resolution> <interval>"
	exit 1
fi

INFILE=$1
OUTPREFIX=$2
RESOLUTION=$3
INTERVAL=$4

# All parameters need to be specified
# The $INFILE is a stream like .mp4 or .hls (it didn't work for me for remote hosted segments)
# The $OUTPREFIX parameter is usually a directory plus a name (e.g. ind)
# The $RESOLUTION parameter is widthxheight, e.g. 320x180
# The $INTERVAL is specified in seconds
#
# One example of running this command:
# $ ./scripts/gen_thumbs.sh master.m3u8 /tmp/test-320x180/ind 320x180 10
#  

# Simple command to get thumbnails at specific intervals
# If possible, it is better to use segment size and key-frames that matches the interval
ffmpeg -i $INFILE -vf fps=1/$INTERVAL -s $RESOLUTION $OUTPREFIX-%03d.jpg
