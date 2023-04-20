' function for getting bookmark position for item by id
' read bookmark from registry
function BookmarksHelper_GetBookmarkData(id as Object) As Integer
    ?"BookmarksHelper_GetBookmarkData(" id ")"
    sec = CreateObject("roRegistrySection", "Bookmarks")
    ' check whether bookmark for this item exists
    if sec.Exists("Bookmark_" + id.toStr())
        return sec.Read("Bookmark_" + id.toStr()).ToInt()
    end if
    return 0
end function

' function for setting bookmark position for item by id
' write bookmark to registry
sub BookmarksHelper_SetBookmarkData(id as String, position as Integer)
    ?"BookmarksHelper_SetBookmarkData(" id "," position ")"
    sec = CreateObject("roRegistrySection", "Bookmarks")
    sec.Write("Bookmark_" + id, position.tostr())
    sec.Flush()
end sub

' function for removing bookmark from registry
sub BookmarksHelper_DeleteBookmark(id as String)
    ?"BookmarksHelper_DeleteBookmark(" id ")"
    sec = CreateObject("roRegistrySection", "Bookmarks")
    sec.Delete("Bookmark_" + id)
    sec.Flush()
end sub
