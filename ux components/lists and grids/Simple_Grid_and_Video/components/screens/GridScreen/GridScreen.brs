' ********** Copyright 2016 Roku Corp.  All Rights Reserved. ********** 
 ' inits grid screen
 ' creates all children
 ' sets all observers 
Function Init()
    ? "[GridScreen] Init"
    m.top.observeField("focusedChild", "OnChildFocused")
    m.rowList = m.top.findNode("RowList")

    m.Description = m.top.findNode("Description")
    m.Background = m.top.findNode("Background")
End Function

' handler of focused child in GridScreen
Sub OnChildFocused()
    if m.top.isInFocusChain() and not m.rowList.hasFocus() then
        m.rowList.setFocus(true)
    end if
End Sub

' handler of focused item in RowList
Sub OnItemFocused()
    itemFocused = m.top.itemFocused
    ? ">> GridScreen > OnItemFocused"; itemFocused

    'When an item gains the key focus, set to a 2-element array, 
    'where element 0 contains the index of the focused row, 
    'and element 1 contains the index of the focused item in that row.
    if itemFocused.Count() = 2 then
        'get content node by index from grid 
        focusedContent = m.top.content.getChild(itemFocused[0]).getChild(itemFocused[1])

        if focusedContent <> invalid then
            'set focused content to top interface
            m.top.focusedContent = focusedContent
            
            'set content to description node
            m.Description.content = focusedContent
            
            'set background wallpaper
            m.Background.uri = focusedContent.hdBackgroundImageUrl
        end if
    end if
end Sub