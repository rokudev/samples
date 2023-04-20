' Copyright (c) 2018 Roku, Inc. All rights reserved.

'cashe chidren nodes for future operations
Sub Init()
    m.background = m.top.findNode("background")
    m.progress = m.top.findNode("progress")
end Sub

'triggers when duration bar width changes
Sub OnWidthChanged()
    m.background.width = m.top.width
end Sub

'triggers when duration bar height changes
Sub OnHeightChanged()
    m.background.height = m.top.height
    m.progress.height = m.top.height
end Sub

'triggers when duration bar color changes
Sub OnProgressColorChanged()
    m.progress.color = m.top.progressColor
end Sub

'triggers when duration bar background changes
Sub OnBackgroundColorChanged()
    m.background.color = m.top.backgroundColor
end Sub

'update progress on duration bar
Sub UpdateBookmark()
    if m.top.length > 0 AND m.top.length > m.top.BookmarkPosition
        progress = Int(m.top.BookmarkPosition / m.top.length * 100)
        if progress > 100
            progress = 100
        else if progress < 0
            progress = 0
        end if           
        m.progress.width = Int(progress * m.background.width / 100)
    else
        m.progress.width = 0
    end if
end Sub
