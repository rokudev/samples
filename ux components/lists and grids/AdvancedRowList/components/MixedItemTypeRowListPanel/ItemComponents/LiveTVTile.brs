
sub init()
    m.poster = m.top.findNode("poster")
    m.title_label = m.top.findNode("info_label")
    m.time_label = m.top.findNode("time_label")
end sub

sub itemContentChanged()
    m.poster.uri = m.top.itemContent.hdposterurl
    m.title_label.text = m.top.itemContent.TITLE
    m.time_label.text = "Today • %d:00 pm".format(m.top.itemContent.start)
end sub

sub onWidthChanged()
    m.poster.width = m.top.width
end sub

sub onHeightChanged()
    m.poster.height = m.top.height - 40
end sub
