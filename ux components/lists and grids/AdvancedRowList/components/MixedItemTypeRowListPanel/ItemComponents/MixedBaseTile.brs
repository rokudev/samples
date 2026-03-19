' Portrait-shaped poster item type

sub init()
    m.poster = m.top.findNode("poster")
end sub

sub itemContentChanged(_message as Object)
    m.poster.uri = m.top.itemContent.hdposterurl
end sub

sub onWidthChanged()
    m.poster.width = m.top.width
end sub

sub onHeightChanged()
    m.poster.height = m.top.height
end sub
