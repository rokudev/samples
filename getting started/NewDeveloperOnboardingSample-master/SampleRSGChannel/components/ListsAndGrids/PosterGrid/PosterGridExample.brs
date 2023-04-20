' ********** Copyright 2018 Roku Corp.  All Rights Reserved. ********** 
'
' Important to note in our PosterGrid example is that in our initialization
' of the PosterGridExample object, we will create a ContentReader task node
' that has the responsibility of retrieving the content to give to the
' PosterGrid object to display on screen.
sub init()
    m.top.translation = [ 130, 160 ]

    m.postergrid = m.top.findNode("examplePosterGrid")

    m.readPosterGridTask = createObject("roSGNode", "ContentReader")
    m.readPosterGridTask.uri = "http://api.delvenetworks.com/rest/organizations/59021fabe3b645968e382ac726cd6c7b/channels/1cfd09ab38e54f48be8498e0249f5c83/media.rss"
    m.readPosterGridTask.observeField("content", "showpostergrid")
    m.readPosterGridTask.control = "RUN"
end sub

' Once the ContentReader task sets its "content" field, this callback
' function will populate the PosterGrid object with content. Since the
' ContentReader task returns a sample with two rows with the same assets,
' we will only use one of the rows to display the content.
sub showpostergrid()
    m.postergrid.content = m.readPosterGridTask.content.getchild(0)
end sub