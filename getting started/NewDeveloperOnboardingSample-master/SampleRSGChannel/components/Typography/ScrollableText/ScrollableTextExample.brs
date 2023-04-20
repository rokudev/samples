' ********** Copyright 2018 Roku Corp.  All Rights Reserved. ********** 
'
' We will initialize the ScrollableText example by setting sizes and
' padding to the ScrollableText component, along with the instructional
' items. This initialization also centers the example.
sub init()
    textrect = m.top.findNode("textRectangle")
    scrolltext = m.top.findNode("exampleScrollableText")
    instructbar = m.top.findNode("instructionbar")
    updnins = m.top.findNode("updninstruct")
    ffrwins = m.top.findNode("ffrwinstruct")
    padding = 20
    hcenterpadding = padding * 2
    vcenterpadding = padding * 3
    instructbar.height = vcenterpadding
    scrolltext.width = textrect.width - hcenterpadding
    scrolltext.height = textrect.height - (instructbar.height + vcenterpadding)
    instructbar.width = scrolltext.width
    instructbar.translation = [ padding, textrect.height - (instructbar.height + padding) ]
    updnins.width = 300
    updnins.height = 40
    updnins.translation = [ padding, 10 ]
    ffrwins.width = 300
    ffrwins.height = 40
    ffrwins.translation = [ instructbar.width / 2, 10 ]

    examplerect = m.top.boundingRect()
    centerx = (1280 - examplerect.width)  / 2
    centery = (720 - examplerect.height) / 2
    m.top.translation = [ centerx, centery ]
end sub