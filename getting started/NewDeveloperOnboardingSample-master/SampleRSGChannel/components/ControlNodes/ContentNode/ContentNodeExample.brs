' ********** Copyright 2018 Roku Corp.  All Rights Reserved. ********** 
'
' We will initialize the ContentNode example by centering
' the example and setting variables to know how many children
' are in the "master" content node and know what position in
' the "master" content node is currently on (in other words,
' what child content node is currently being displayed)
sub init()
    m.item = m.top.findNode("itemLabel")

    m.item.font.size = m.item.font.size+5
      
    m.content = m.top.findNode("exampleContentNode")
    m.contentitems = m.content.getChildCount()
    m.currentitem = 0

    examplerect = m.top.boundingRect()
    centerx = (1280 - examplerect.width) / 2
    centery = (720 - examplerect.height) / 2
    m.top.translation = [ centerx, centery ]

    showcontentitem()
end sub

' This function displays the title of the current child content
' node from the "master" content Node by replacing the text
' from the bottom-most label.
sub showcontentitem()
    itemcontent = m.content.getChild(m.currentitem) 
    m.item.text = itemcontent.title 
end sub

' onKeyEvent will handle button presses it recognizes in this example.
' If the "ok" button is pressed on the remote control, the next child
' in the "master" content node will display its title. If it reaches
' the end of the list, it wraps around and starts again with the first
' content node. If a different button was pressed on the remote control
' (except the home button), this onKeyEvent will not handle the button
' press and pass this information up the focus chain until something
' handles this button event.
function onKeyEvent(key as String, press as Boolean) as Boolean
    if press then 
        if key = "OK" 
            m.currentitem++ 

            if (m.currentitem = m.contentitems) 
                m.currentitem = 0
            end if

            showcontentitem()

            return true 
        end if
    end if

    return false
end function