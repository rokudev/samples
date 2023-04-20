' ********** Copyright 2018 Roku Corp.  All Rights Reserved. ********** 
'
' We will initialize the Panel example by setting the size of the Panel
' component and disabling the panel's ability to switch between another
' Panel.
sub init()
    m.top.panelSize = "medium"
    m.top.hasNextPanel = false

    m.panelLabel = m.top.findNode("panelLabel")
end sub

' When the "description" field is updated, this function will update
' the label's text.
sub updateLabel()
    m.panelLabel.text = m.top.description
end sub