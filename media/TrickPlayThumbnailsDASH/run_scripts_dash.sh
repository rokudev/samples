#!/bin/bash
#
#  Copyright (c) 2019-2020 Roku, Inc. All rights reserved.
#
# 
# This script calls the scripts gen_thumbs.sh, gen_tiles.sh, and gen_manifest.sh to generate
# a .mpd manifest with thumbnails

if [ $# -lt 6 ]; then
	echo "Usage: $0 <input-file> <output-dir> <resolution> <columns> <rows> <interval>"
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
# One example of running this command:
# $ ./run_scripts_dash.sh master.mpd tile 256x144 5 4 4
#  

DIR=test-$RESOLUTION
PWD=`pwd` 
mkdir $DIR
./scripts/gen_thumbs.sh $INFILE $DIR/ind $RESOLUTION $INTERVAL
./scripts/gen_tiles.sh $DIR ind $OUTPREFIX $RESOLUTION $COLS $ROWS
echo
echo "Output for thumbnails: add the image adaptation set to master mpd file"
./scripts/gen_manifest.sh $INFILE $OUTPREFIX $RESOLUTION $COLS $ROWS $INTERVAL 

# The outputs files are saved in directory ${RESOLUTION}-${COLS}x${ROWS}
# - playlist file ${RESOLUTION}-${COLS}x${ROWS}.m3u8 
# - tile files ${OUTPREFIX}-*.jpg
#echo "mkdir ${COLS}x${ROWS}_${RESOLUTION}"
mkdir thumbnails_${RESOLUTION}
#echo "mv ${OUTPREFIX}-*.jpg $PWD/${COLS}x${ROWS}_${RESOLUTION}"
mv ${OUTPREFIX}_*.jpg $PWD/thumbnails_${RESOLUTION}
echo
echo
echo "Thumbnail files saved in directory thumbnails_${RESOLUTION}"

# Cleanup
rm -rf tile*
rm -rf $DIR
