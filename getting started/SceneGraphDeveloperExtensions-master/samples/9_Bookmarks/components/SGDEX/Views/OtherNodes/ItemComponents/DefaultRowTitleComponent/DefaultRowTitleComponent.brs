' Copyright (c) 2018 Roku, Inc. All rights reserved.

sub Init()
    m.titleLabel = m.top.findNode("title")
end sub

sub onContentSet()
    if m.top.content <> invalid
        m.titlelabel.text = m.top.content.title
    end if
end sub
