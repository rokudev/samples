' ********** Copyright 2018 Roku Corp.  All Rights Reserved. ********** 
'
' The GridPanel example will initialize the GridPanel to certain values.
' We will set the panelSize and isFullScreen fields to only display this
' panel within the context of the PanelSet. We also want to be able to focus
' the GridPanel so we set the focusable field to true. Additionally, we will
' set the hasNextPanel and createNextPanelOnItemFocus fields of the GridPanel
' to false in order to only have focus on the GridPanel example.
'
' An important step for GridPanels is to set the grid field to point to the
' PosterGrid that will be displayed. For more information on how to retrieve
' content to populate the PosterGrid, refer to the example in
' pkg:/components/ListsAndGrids/PosterGrid
sub init()
    m.top.panelSize = "full"
    m.top.isFullScreen = true
    m.top.focusable = true
    m.top.hasNextPanel = false
    m.top.createNextPanelOnItemFocus = false

    m.postergrid = m.top.findNode("examplePosterGrid")
    m.top.grid = m.postergrid

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

' If the example sets the "gridContent" field of this GridPanel example,
' this function will be called to update the content that will be displayed
' in the PosterGrid component.
'
' To avoid the concurrency problem where creating the GridPanel example and
' immediately setting the "gridContent" field can cause inconsistency with
' what items will appear in the PosterGrid, this function will stop the
' ContentReader task and set the PosterGrid content to what is specified
' in the "gridContent" field.
sub updateGridContent()
    m.readPosterGridTask.control = "STOP"
    m.postergrid.caption1NumLines = 1
    m.postergrid.content = m.top.gridContent
end sub