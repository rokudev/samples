' ********** Copyright 2018 Roku Corp.  All Rights Reserved. ********** 
'
' We will initialize the MaskGroup example by centering
' the example and starting the animation that demonstrates
' the MaskGroup's behavior.
sub init()
    examplerect = m.top.boundingRect()
    centerx = (1280 - examplerect.width) / 2
    centery = (720 - examplerect.height) / 2
    m.top.translation = [ centerx, centery ]

    maskgroupanimation = m.top.findNode("MaskGroupAnimation")
    maskgroupanimation.control = "start"
end sub