' ********** Copyright 2019 Roku Corp.  All Rights Reserved. ********** 
 ' inits grid screen
 ' creates all children
 ' sets all observers 
Function Init()
    ' listen on port 8089
    ? "[HomeScene] Init"

    ' GridScreen node with RowList
    m.gridScreen = m.top.findNode("GridScreen")

    ' DetailsScreen Node with description, Video Player
    m.detailsScreen = m.top.findNode("DetailsScreen")

    ' Observer to handle Item selection on RowList inside GridScreen (alias="GridScreen.rowItemSelected")
    m.top.observeField("rowItemSelected", "OnRowItemSelected")
    
    ' loading indicator starts at initializatio of channel
    m.loadingIndicator = m.top.findNode("loadingIndicator")

    feedTask = createObject("roSGNode", "FeedTask")
    feedTask.requestUrl = "http://api.delvenetworks.com/rest/organizations/59021fabe3b645968e382ac726cd6c7b/channels/1cfd09ab38e54f48be8498e0249f5c83/media.rss"
    feedTask.observeField("response", "OnFeedTaskResponse")
    feedTask.control = "run"
End Function 

' When the FeedTask finishes retrieving and formatting a response,
' this function will create the content nodes and format it so the
' rowlist inside the GridScreen component can ingest it.
Function onFeedTaskResponse(msg as Object)
    content = CreateContentNodes(msg.getData())
    m.top.gridContent = content
end Function

Function CreateContentNodes(list As Object)
    RowItems = createObject("RoSGNode","ContentNode")
    
    for each rowAA in list
    'for index = 0 to 1
        row = createObject("RoSGNode","ContentNode")
        row.Title = rowAA.Title

        for each itemAA in rowAA.ContentList
            item = createObject("RoSGNode","ContentNode")
            ' We don't use item.setFields(itemAA) as doesn't cast streamFormat to proper value
            for each key in itemAA
                item[key] = itemAA[key]
            end for
            row.appendChild(item)
        end for
        RowItems.appendChild(row)
    end for

    return RowItems
End Function

' if content set, focus on GridScreen
Function OnChangeContent()
    m.gridScreen.setFocus(true)
    m.loadingIndicator.control = "stop"
End Function

' Row item selected handler
Function OnRowItemSelected()
    ' On select any item on home scene, show Details node and hide Grid
    m.gridScreen.visible = "false"
    m.detailsScreen.content = m.gridScreen.focusedContent
    m.detailsScreen.setFocus(true)
    m.detailsScreen.visible = "true"
End Function

' Main Remote keypress event loop
Function OnKeyEvent(key, press) as Boolean
    ? ">>> HomeScene >> OnkeyEvent"
    result = false
    if press then
        if key = "options"
            ' option key handler
        else if key = "back"

            ' if Details opened
            if m.gridScreen.visible = false and m.detailsScreen.videoPlayerVisible = false
                m.gridScreen.visible = "true"
                m.detailsScreen.visible = "false"
                m.gridScreen.setFocus(true)
                result = true

            ' if video player opened
            else if m.gridScreen.visible = false and m.detailsScreen.videoPlayerVisible = true
                m.detailsScreen.videoPlayerVisible = false
                result = true
            end if

        end if
    end if
    return result
End Function
