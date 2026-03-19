sub init()
    ' onChange does not fire when columnIndex is already at its default (0),
    ' so call the handler directly to initialise TITLE and start for column 0.
    onColumnIndex()
end sub

sub onColumnIndex()
    titles = ["SceneGraph Olympics", "BrightScript Bonanza", "XML Extravaganza"]
    m.top.TITLE = titles[m.top.columnIndex mod titles.count()]
    m.top.start = 5 + m.top.columnIndex
end sub
