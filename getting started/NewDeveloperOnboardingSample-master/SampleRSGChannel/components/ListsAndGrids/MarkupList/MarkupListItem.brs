' ********** Copyright 2018 Roku Corp.  All Rights Reserved. ********** 
'
' For initializing the MarkupListItem component, we are only setting
' the variables that the other functions might need.
sub init()
    m.top.id = "markuplistitem"
    m.itemicon = m.top.findNode("itemIcon")
    m.itemlabel = m.top.findNode("itemLabel")
    m.itemcursor = m.top.findNode("itemcursor")
    m.itemposter = m.top.findNode("itemPoster")
end sub

' This callback function will get called once the "itemContent" field
' from MarkupListItem is changed. This function will set the url of the
' poster inside this MarkupListItem component and will be displayed to
' the screen. It will also set the text of the label to the title of
' the content.
sub showcontent()
    itemcontent = m.top.itemContent
    m.itemlabel.text = itemcontent.title
    m.itemposter.uri = itemcontent.HDPosterUrl
end sub

' This callback function will get called once the "focusPercent" field
' from MarkupListItem is changed. If the MarkupListItem component is
' focused, the content poster and the rectangle node acting as a focus
' indicator will increase its opacity to 1. If the MarkupListItem
' component is not focused, the opacity of the content poster and
' rectangle node will be set to 0, making them not visible on-screen.
sub showfocus()
    m.itemcursor.opacity = m.top.focusPercent
    m.itemposter.opacity = m.top.focusPercent
end sub