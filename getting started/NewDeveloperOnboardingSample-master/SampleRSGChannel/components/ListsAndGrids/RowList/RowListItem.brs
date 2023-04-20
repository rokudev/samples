sub init()
    ? "[RowListItem] init"
    m.itemposter = m.top.findNode("itemPoster") 
    m.itemmask = m.top.findNode("itemMask")
    m.itemlabel = m.top.findNode("itemLabel")
end sub

sub showcontent()
    ? "[RowListItem] showcontent"
    itemcontent = m.top.itemContent
    m.itemposter.uri = itemcontent.HDPosterUrl
    m.itemlabel.text = itemcontent.title
end sub

sub showfocus()
    scale = 1 + (m.top.focusPercent * 0.08)
    m.itemposter.scale = [scale, scale]
end sub

sub showrowfocus()
    m.itemmask.opacity = 0.75 - (m.top.rowFocusPercent * 0.75)
    m.itemlabel.opacity = m.top.rowFocusPercent
end sub