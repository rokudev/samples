' ********** Copyright 2018 Roku Corp.  All Rights Reserved. ********** 
'
' We will initialize the ListPanel example by setting the size of the
' ListPanel component and disabling the panel's ability to switch between
' another Panel.
'
' An important step here is to set the ListPanel's list field to point
' to the LabelList, so the ListPanel will populate.'
sub init()
    m.top.panelSize = "medium"
    m.top.hasNextPanel = false
    m.top.focusable = true
    m.top.leftOnly = true

    m.labelList = m.top.findNode("exampleLabelList")
    m.top.list = m.labelList
end sub
