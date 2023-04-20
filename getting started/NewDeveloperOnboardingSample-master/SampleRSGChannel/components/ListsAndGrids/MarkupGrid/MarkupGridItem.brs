' ********** Copyright 2018 Roku Corp.  All Rights Reserved. ********** 
'
' For initializing the MarkupGridItem component, we are only setting
' the variables that the other functions might need.
sub init()
    m.top.id = "markupgriditem"
    m.itemposter = m.top.findNode("itemPoster") 
    m.itemmask = m.top.findNode("itemMask")
    m.focuslabel = m.top.findNode("focusLabel")
end sub

' This callback function will get called once the "itemContent" field
' from MarkupGridItem is changed. This function will set the url of the
' poster inside this MarkupGridItem component and will be displayed to
' the screen.
sub showcontent()
    itemcontent = m.top.itemContent
    m.itemposter.uri = itemcontent.hdposterurl
end sub

' This callback function will get called once the "focusPercent" field
' from MarkupGridItem is changed. If the MarkupGridItem component is
' focused, the size of the poster will increase by 8% and the rectangle
' node acting as a mask will reduce its opacity to 0. If the MarkupGridItem
' component is not focused, the size of the poster will return to normal size
' and the opacity of the mask will return to 0.75 (the original value)
sub showfocus()
    scale = 1 + (m.top.focusPercent * 0.08)
    m.itemposter.scale = [scale, scale]
    m.itemmask.opacity = 0.75 - (m.top.focusPercent * 0.75)
end sub