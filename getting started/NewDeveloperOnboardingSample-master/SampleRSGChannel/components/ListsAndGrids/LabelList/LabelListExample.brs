' ********** Copyright 2018 Roku Corp.  All Rights Reserved. ********** 
'
' We will initialize the CheckList object by checking the first and third
' items in the checklist and translating the CheckList object until it is
' centered.
sub init()
    examplerect = m.top.boundingRect()
    centerx = (1280 - examplerect.width) / 2
    centery = (720 - examplerect.height) / 2
    m.top.translation = [ centerx, centery ]
end sub