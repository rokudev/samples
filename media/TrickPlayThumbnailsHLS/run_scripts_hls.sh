#!/bin/bash
#
#  Copyright (c) 2019-2020 Roku, Inc. All rights reserved.
#
# 
# This script calls the scripts gen_thumbs.sh, gen_tiles.sh, and gen_playlist.sh to generate
# a .m3u8 playlist with thumbnails

if [ $# -lt 6 ]; then
	echo "Usage: $0 <input-file> <output-dir> <output-prefix> <resolution> <columns> <rows> <interval>"
	exit 1
fi

INFILE=$1
OUTPREFIX=$2
RESOLUTION=$3
COLS=$4
ROWS=$5
INTERVAL=$6

# All parameters need to be specified
# The $INFILE is a stream like .mp4 or .m3u8
# The $OUTPREFIX parameter is usually a name, e.g. in
# The $RESOLUTION parameter is widthxheight, e.g. 320x180
# The $COLS parameter is tile vertical count, e.g. 5
# The $ROWS parameter is tile horizontal count, e.g. 4
# The $INTERVAL is specified in seconds
#
# Two examples of running this command:
# $ ./run_scripts_hls.sh master.m3u8 thumb-tile 320x180 5 4 10
# $ ./run_scripts_hls.sh master.m3u8 thumb-tile 640x360 5 4 10
#  

DIR=test-$RESOLUTION
PWD=`pwd` 
mkdir $DIR
./scripts/gen_thumbs.sh $INFILE $DIR/ind $RESOLUTION $INTERVAL
./scripts/gen_tiles.sh $DIR ind $OUTPREFIX $RESOLUTION $COLS $ROWS
./scripts/gen_playlist.sh $OUTPREFIX $RESOLUTION $COLS $ROWS $INTERVAL 

# The outputs files are saved in directory ${RESOLUTION}-${COLS}x${ROWS}
# - playlist file ${RESOLUTION}-${COLS}x${ROWS}.m3u8 
# - tile files ${OUTPREFIX}_*.jpg
#echo "mkdir ${COLS}x${ROWS}_${RESOLUTION}"
mkdir ${COLS}x${ROWS}_${RESOLUTION}
#echo "mv ${RESOLUTION}-${COLS}x${ROWS}.m3u8 $PWD/${COLS}x${ROWS}_${RESOLUTION}"
mv ${RESOLUTION}-${COLS}x${ROWS}.m3u8 $PWD/${COLS}x${ROWS}_${RESOLUTION}
#echo "mv ${OUTPREFIX}_*.jpg $PWD/${COLS}x${ROWS}_${RESOLUTION}"
mv ${OUTPREFIX}_*.jpg $PWD/${COLS}x${ROWS}_${RESOLUTION}
echo "Thumbnail files saved in directory ${COLS}x${ROWS}_${RESOLUTION}"

# Cleanup
rm -rf tile*
rm -rf $DIR
