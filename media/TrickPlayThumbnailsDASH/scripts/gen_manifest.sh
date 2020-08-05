#!/bin/bash
#
# Copyright (c) 2019-2020 Roku, Inc. All rights reserved.
#
# References:
# https://dashif.org/docs/DASH-IF-IOP-v4.2-clean.htm#_Toc511040840
# https://stackoverflow.com/questions/15409947/how-to-split-a-string-in-shell

if [ $# -lt 6 ]; then
    echo "Usage: $0 <input-file> <input-prefix> <resolution> <cols> <rows> <duration>"
    exit 1
fi

INFILE=$1
INPREFIX=$2
RESOLUTION=$3
COLS=$4
ROWS=$5
TARGETDURATION=$6

# Calculate width and height from resolution
# @width and @height expresses the spatial resolution of the tile. 
#    Note that the maximum dimension of a JPEG image is 64k in width and height.
[[ $RESOLUTION =~ ^([0-9]+)[xX]([0-9]+) ]]
let "WIDTH=${BASH_REMATCH[1]} * $COLS"
let "HEIGHT=${BASH_REMATCH[2]} * $ROWS"

# TBD: Figure out how to calculate bandwidth
# @bandwidth expresses the maximum tile size in bits divided by the duration of one tile
BW=24000

# Find the next adaptation set id for the thumbnail adaptation set, assuming a single period
# NOTE: this is optional, python3 needs to be installed to run get_thumbid.py and parse mpd manifest
#
# Uncomment the following lines to auto-detect next manifest id using python3 script
#
# ID=$( scripts/get_thumbid.py $INFILE )
# if [ "${ID:0:18}" = "Already has images" ]; then
#	echo $ID
#	exit 1
#else
#	echo -e "Please include the adaptation set in the master manifest\c "
#	echo " and the directory thumbnails_${RESOLUTION} in the segments directory:"
#	echo
#fi

# The alternative is to inspect manifest and manually fill in the next id
ID=3

# All parameters need to be specified
# The $INFILE parameter is usually a name, e.g. master.mpd
# The $INPREFIX parameter is usually a name, e.g. tile
# The $RESOLUTION parameter is widthxheight, e.g. 320x180
# The $COLS parameter is tile vertical count, e.g. 5
# The $ROWS parameter is tile horizontal count, e.g. 4
# The $INTERVAL is specified in seconds
#
# One example of running this command:
# $ ./gen_manifest.sh master.mpd tile 320x180 5 4 10

let "TILEDURATION=$TARGETDURATION * $COLS * $ROWS"
#echo "TILEDURATION = $TILEDURATION"

ADAPTSET_START="  <AdaptationSet id=\"$ID\" mimeType=\"image/jpeg\" contentType=\"image\">
    <SegmentTemplate media=\"\$RepresentationID$/${INPREFIX}_\$Number\$.jpg\" duration=\"$TILEDURATION\" startNumber=\"1\"/>"

REPR="      <Representation bandwidth=\"$BW\" id=\"thumbnails_${RESOLUTION}\" width=\"${WIDTH}\" height=\"${HEIGHT}\">
        <EssentialProperty schemeIdUri=\"http://dashif.org/guidelines/thumbnail_tile\" value=\"${COLS}x${ROWS}\"/>
      </Representation>"
ADAPTSET_END="  </AdaptationSet>"

echo "$ADAPTSET_START"
echo "$REPR"
echo "$ADAPTSET_END"
