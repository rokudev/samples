' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

sub Show(args as Object)
    grid = CreateObject("roSGNode", "GridView")

    ' setup UI of view
    grid.SetFields({
        posterShape: "16x9"
    })

    ' This is root content that describes how to populate rest of rows
    content = CreateObject("roSGNode", "ContentNode")
    content.AddFields({
        HandlerConfigGrid: {
            name: "CHRoot"
        }
    })
    grid.ObserveField("rowItemSelected", "OnGridItemSelected")
    grid.content = content

    m.top.ComponentController.CallFunc("show", {
        view: grid
    })
end sub

sub OnGridItemSelected(event as Object)
    grid = event.GetRoSGNode()
    selectedIndex = event.GetData()
    row = grid.content.getChild(selectedIndex[0])
    detailsView = ShowDetailsView(row, selectedIndex[1])
end sub
