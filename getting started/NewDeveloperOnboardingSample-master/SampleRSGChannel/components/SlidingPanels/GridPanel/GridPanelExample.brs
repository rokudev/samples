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
    m.readPosterGridTask.uri = "https://stream-fastly.castr.com/5b9352dbda7b8c769937e459/live_2361c920455111ea85db6911fe397b9e/index.fmp4.m3u8"
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