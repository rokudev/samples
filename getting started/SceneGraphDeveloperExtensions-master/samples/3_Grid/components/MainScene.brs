' ********** Copyright 2017 Roku Corp.  All Rights Reserved. **********

sub Show(args as Object)
    ' Create an GridView object and assign some fields
    m.grid = CreateObject("roSGNode", "GridView")
    m.grid.setFields({
        style: "standard"
        posterShape: "16x9"
    })
    content = CreateObject("roSGNode", "ContentNode")
    ' This tells the GridView where to go to fetch the content
    content.addfields({
        HandlerConfigGrid: {
            name: "GridHandler"
        }
    })
    m.grid.content = content
    ' This will run the content handler and show the Grid
    m.top.ComponentController.callFunc("show", {
        view: m.grid
    })
end sub
