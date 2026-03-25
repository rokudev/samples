' ********** Copyright 2018 Roku Corp.  All Rights Reserved. ********** 
'
' We will initialize the Task example by centering the example and
' starting the "ContentReader" task node to retrieve data hosted
' on a server that will be used for this example.
sub init()
    m.item = m.top.findNode("itemLabel")

    m.item.font.size = m.item.font.size+5

    examplerect = m.top.boundingRect()
    centerx = (1280 - examplerect.width) / 2
    centery = (720 - examplerect.height) / 2
    m.top.translation = [ centerx, centery ]

    m.readXMLContentTask = createObject("RoSGNode", "ContentReader")
    m.readXMLContentTask.uri = "https://stream-akamai.castr.com/5b9352dbda7b8c769937e459/live_2361c920455111ea85db6911fe397b9e/index.fmp4.m3u8"
    m.readXMLContentTask.observeField("content", "setcontent")
    m.readXMLContentTask.control = "RUN"
end sub

' When the "ContentReader" task node finishes it's task, the task
' node's "content" field will be set and this callback function gets
' called. This callback function will retrieve the content from the
' task node, get the count of how many children are contained in the
' "master" content node, and set an initial index of what child content
' node it is currently on.
sub setcontent()
    m.content = m.readXMLContentTask.content.getChild(0)
    m.contentitems = m.content.getChildCount()
    m.currentitem = 0
    showcontentitem()
end sub

' This function will get the current child content node and set the label
' in this example to the title of the child content node contained in the
' metadata.
sub showcontentitem()
    itemcontent = m.content.getChild(m.currentitem)
    m.item.text = itemcontent.title
end sub

' onKeyEvent will handle button presses it recognizes in this example.
' If the "ok" button is pressed on the remote control, the next child
' from the "master" content node will be selected and set the label in
' this example to that child's title (from the metadata).
' If a different button was pressed on the remote control (except the
' home button), this onKeyEvent will not handle the button press and
' pass this information up the focus chain until something handles
' this button event.
function onKeyEvent(key as String,press as Boolean) as Boolean
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