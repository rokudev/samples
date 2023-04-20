' ********** Copyright 2018 Roku Corp.  All Rights Reserved. ********** 
'
' Important to note in our MarkupGrid example is that in our initialization
' of the MarkupGridExample object, we will create a ContentReader task node
' that has the responsibility of retrieving the content to give to the
' MarkupGrid object to display on screen.
sub init()
    m.top.translation = [ 130, 160 ]

    m.markupgrid = m.top.findNode("exampleMarkupGrid")

    m.readMarkupGridTask = createObject("roSGNode", "ContentReader")
    m.readMarkupGridTask.uri = "http://api.delvenetworks.com/rest/organizations/59021fabe3b645968e382ac726cd6c7b/channels/1cfd09ab38e54f48be8498e0249f5c83/media.rss"
    m.readMarkupGridTask.observeField("content", "showmarkupgrid")
    m.readMarkupGridTask.control = "RUN"
end sub

' Once the ContentReader task sets its "content" field, this callback
' function will populate the MarkupGrid object with content. Since the
' ContentReader task returns a sample with two rows with the same assets,
' we will only use one of the rows to display the content.
sub showmarkupgrid()
    m.readMarkupGridTask.unobserveField("content")
    m.markupgrid.content = m.readMarkupGridTask.content.getchild(0)
end sub