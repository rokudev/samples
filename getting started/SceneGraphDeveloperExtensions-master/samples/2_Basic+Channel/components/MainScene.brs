' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

sub show(args as Object)
    m.grid = CreateObject("roSGNode", "GridView")
    m.grid.setFields({
        style: "standard"
        posterShape: "16x9"
    })
    content = CreateObject("roSGNode", "ContentNode")
    content.addfields({
        HandlerConfigGrid: {
            name: "RootHandler"
        }
    })
    m.grid.content = content
    m.grid.ObserveField("rowItemSelected","OnGridItemSelected")

    m.top.ComponentController.callFunc("show", {
        view: m.grid
    })
end sub

sub OnGridItemSelected(event as Object)
    grid = event.GetRoSGNode()
    selectedIndex = event.getdata()
    rowContent = grid.content.getChild(selectedIndex[0])
    detailsView = ShowDetailsView(rowContent, selectedIndex[1])
    detailsView.ObserveField("wasClosed", "OnDetailsWasClosed")
end sub

sub OnDetailsWasClosed(event as Object)
    details = event.GetRoSGNode()
    m.grid.jumpToRowItem = [m.grid.rowItemFocused[0], details.itemFocused]
end sub
