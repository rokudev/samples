' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********
sub Show(args as Object)
    m.grid = CreateObject("roSGNode", "GridView")

    ' setup UI of view
    m.grid.SetFields({
        style: "zoom"
        posterShape: "16x9"
    })
    ' This is root content that describes how to populate rest of rows
    content = CreateObject("roSGNode", "ContentNode")
    content.AddFields({
        HandlerConfigGrid: {
            name: "CHRoot"
        }
    })
    m.grid.ObserveField("rowItemSelected", "OnGridItemSelected")
    m.grid.content = content

    m.top.ComponentController.CallFunc("show", {
        view: m.grid
    })
end sub

sub OnGridItemSelected(event as Object)
    grid = event.GetRoSGNode()
    selectedIndex = event.GetData()
    row = grid.content.getChild(selectedIndex[0])
    detailsView = ShowDetailsView(row, selectedIndex[1])
end sub
