
sub init()
    m.poster = m.top.findNode("poster")
    m.progress_width = m.top.findNode("progress_background").width
    m.progress = m.top.findNode("progress")
    m.progress_label = m.top.findNode("remaining_label")
end sub

sub itemContentChanged()
    itemContent = m.top.itemContent

    m.poster.uri = itemContent.hdposterurl
    ' update progress indicator
    m.progress.width = m.progress_width * itemContent.position / itemContent.duration
    remaining = itemContent.duration - itemContent.position
    m.progress_label.text = "%dm remaining".format(int(remaining / 60))

end sub

sub onWidthChanged()
    m.poster.width = m.top.width
end sub

sub onHeightChanged()
    m.poster.height = m.top.height - 30
end sub
