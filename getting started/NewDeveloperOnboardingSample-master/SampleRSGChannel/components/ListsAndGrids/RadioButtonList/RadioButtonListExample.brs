' ********** Copyright 2018 Roku Corp.  All Rights Reserved. ********** 
'
' We will initialize the RadioButtonList object by checking the third
' item in the RadioButtonList and translating the RadioButtonList object
' until it is centered.
sub init()
    radiobuttonlist = m.top.findNode("exampleRadioButtonList")

    radiobuttonlist.checkedItem = 2

    examplerect = m.top.boundingRect()
    centerx = (1280 - examplerect.width) / 2
    centery = (720 - examplerect.height) / 2
    m.top.translation = [ centerx, centery ]
end sub