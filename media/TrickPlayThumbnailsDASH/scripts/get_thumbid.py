#!/usr/bin/env python3
import xml.etree.ElementTree as ET
import re
import sys

# References:
# 1. https://stackoverflow.com/questions/18231415/best-way-to-return-a-value-from-a-python-script/18231470

def get_image_adaptation_id(filename):
    tree = ET.parse(filename)
    # print('filename: ',filename)
    root = tree.getroot()
    period = root.findall('{urn:mpeg:dash:schema:mpd:2011}Period')

    # Assumption: all adaptation sets are in period[0]
    maxThumbId = 0
    hasImages = False
    for adaptationSet in period[0]:
        # print(adaptationSet.attrib)
        attributes = {}

        if adaptationSet.tag != '{urn:mpeg:dash:schema:mpd:2011}AdaptationSet':
            continue
        else:
            attributes = adaptationSet.attrib
            thisId = attributes['id']

        contentType = attributes['contentType']
        if contentType == 'image':
            hasImages = True
            maxThumbId = attributes['id']
            break
        
        if int(thisId) > maxThumbId:
            maxThumbId = int(thisId)

    if hasImages == False:
        # Pick the next id
        maxThumbId += 1

    ret = { 'hasImages': hasImages, 'thumbId': maxThumbId }
    return ret

if __name__ == '__main__':

    if len(sys.argv) < 2:
        print("Usage: " + sys.argv[0] + " mpd-file")
        exit(1)
    else:
        filename=sys.argv[1]

    ret = get_image_adaptation_id(filename)
    if ret["hasImages"] == True:
        output = 'Already has images adaptation set id = ' + str(ret["thumbId"])
    else:
        output = str(ret["thumbId"])

    sys.stdout.write(output)
    sys.stdout.flush()
    sys.exit(0)
