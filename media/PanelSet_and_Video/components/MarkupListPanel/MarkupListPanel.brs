' ********** Copyright 2016 Roku Corp.  All Rights Reserved. ********** 

'cache children nodes for future operations
function Init()
    m.top.list = m.top.FindNode("List")
    m.top.observeField("focusedChild", "OnFocusedChildChanged")
end function

'handle list item focus change
function OnFocusedChildChanged()
    if m.top.isInFocusChain() AND not m.top.list.hasFocus() then
        m.top.list.setFocus(true)
    end if
end function