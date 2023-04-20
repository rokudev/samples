' Copyright (c) 2018 Roku, Inc. All rights reserved.

sub Init()
    m.label = m.top.findNode("title")
    m.poster = m.top.findNode("poster")
end sub 

sub onContentSet()
    content = m.top.itemContent
    if content <> invalid
        m.poster.uri = content.hdPosterUrl
        m.label.text = content.shortDescriptionLine1
    end if

    parent = Utils_getParentbyIndex(3, m.top)
    if parent <> invalid AND parent.itemTextColorLine1 <> invalid
        m.label.color = parent.itemTextColorLine1
    end if
end sub

sub onWidthChange()
    m.poster.width      = m.top.width
    m.poster.loadWidth  = m.top.width
    setTitleLabelStyle(m.top.width,m.top.height)
end sub

sub onHeightChange()
    m.poster.height     = m.top.height
    m.poster.loadHeight = m.top.height
    setTitleLabelStyle(m.top.width,m.top.height)
end sub

sub setTitleLabelStyle(width as Integer, height as Integer)
    if height > 0 and width > 0
        padding = 5
        font = "font:SmallSystemFont"
        if height > 200 ' big size
            padding = 10
            font = "font:MediumSystemFont"
        end if
        m.label.translation = [padding,padding]
        m.label.height      = height - padding * 2
        m.label.width       = width  - padding * 2
        m.label.font        = font
    end if
end sub
