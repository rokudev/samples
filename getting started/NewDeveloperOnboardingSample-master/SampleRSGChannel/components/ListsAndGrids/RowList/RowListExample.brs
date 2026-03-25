' ********** Copyright 2018 Roku Corp.  All Rights Reserved. ********** 
'
' Important to note in our RowList example is that in our initialization
' of the RowListExample object, we will create a ContentReader task node
' that has the responsibility of retrieving the content to give to the
' RowList object to display on screen.
sub init()
    m.top.translation = [ 130, 160 ]

    m.rowlist = m.top.findNode("exampleRowList")

    m.rowlist.itemSize = [ 536 * 3, 308 ]

    m.contentReader = createObject("roSGNode", "ContentReader")
    m.contentReader.uri = "https://stream-fastly.castr.com/5b9352dbda7b8c769937e459/live_2361c920455111ea85db6911fe397b9e/index.fmp4.m3u8"
    m.contentReader.observeField("content", "getContent")
    m.contentReader.control = "RUN"
end sub

' Once the ContentReader task sets its "content" field, this callback
' function will populate the RowList object with content.
Function getContent()
    m.contentReader.unobserveField("content")

    m.rowlist.content = m.contentReader.content
end Function