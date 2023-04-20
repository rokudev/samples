' Copyright (c) 2018 Roku, Inc. All rights reserved.

sub Init()
    m.poster = m.top.FindNode("poster")
    m.title = m.top.FindNode("title")
    m.description = m.top.FindNode("description")
    
    m.title.font.size = 20
    m.description.font.size = 16
end sub

sub itemContentChanged()
    itemContent = m.top.itemContent    
    parent = Utils_getParentbyIndex(1, m.top)
    if itemContent <> invalid
        m.poster.uri = itemContent.hdPosterUrl
        m.title.text = itemContent.title
        m.description.text = itemContent.description
        m.description.width = parent.itemSize[0] - m.poster.width - 10
    end if
    
    if parent <> invalid
        if parent.itemTitleColor <> invalid
            m.title.color = parent.itemTitleColor
        end if
        if parent.itemDescriptionColor <> invalid
            m.description.color = parent.itemDescriptionColor
        end if
        if parent.posterShape <> invalid
            m.poster.shape = parent.posterShape
        end if
    end if  
end sub
