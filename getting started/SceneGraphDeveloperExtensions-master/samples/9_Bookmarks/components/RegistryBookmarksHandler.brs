'BookmarksHandler interface functions'
Sub SaveBookmark()
    content = m.top.content
    position = m.top.position
    BookmarksHelper_SetBookmarkData(content.id, position)
End Sub

Function GetBookmark() as Integer
    content = m.top.content
    return BookmarksHelper_GetBookmarkData(content.id)
End Function

Sub RemoveBookmark()
    content = m.top.content
    BookmarksHelper_DeleteBookmark(content.id)
End Sub
