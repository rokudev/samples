' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

sub show(args as Object)
    ' Create an GridView object and assign some fields
    m.grid = CreateObject("roSGNode", "GridView")
    m.grid.SetFields({
        style: "standard"
        posterShape: "16x9"
    })
    content = CreateObject("roSGNode", "ContentNode")
    ' This tells the GridView where to go to fetch the content
    content.Addfields({
        HandlerConfigGrid: {
            name: "GridHandler"
        }
    })
    m.grid.content = content
    m.grid.ObserveField("rowItemSelected", "OnGridItemSelected")
    m.grid.ObserveField("content", "OnContentChanged")
    ' This will run the content handler and show the Grid
    m.top.ComponentController.CallFunc("show", {
        view: m.grid
    })
end sub

sub OnGridItemSelected(event as Object)
    grid = event.GetRoSGNode()
    selectedIndex = event.Getdata()
    rowContent = grid.content.GetChild(selectedIndex[0])
    detailsView = ShowDetailsView(rowContent, selectedIndex[1])
    detailsView.ObserveField("wasClosed", "OnDetailsWasClosed")
end sub

sub OnDetailsWasClosed(event as Object)
    details = event.GetRoSGNode()
    m.grid.jumpToRowItem = [m.grid.rowItemFocused[0], details.itemFocused]
end sub

function listToNode(list as Object, nodeType as String) as Object
    result = CreateObject("roSGNode", nodeType)
    for each itemAA in list
        item = CreateObject("roSGNode", nodeType)
        item.SetFields(itemAA)
        result.AppendChild(item)
    end for
    return result
end function
