# SGDEX Guide: Bookmarks

The starting point for this sample is sample with details. We will modify DetailsViewLogic to add bookmarks support.

## Part 1: Add logic for Bookmarks

Take a look to the file DetailsViewLogic.brs in the components folder.

The buttons are refreshed according to bookmarks availability. We need to have an ability to update them in run-time. For this reason, we should make some refactoring and move logic for button creation to separate function. Let's create function RefreshButtons(details) it will have one parameter DetailsView object. This should be made like this because function RefreshButtons shouldn't care about where to take View for update.

```
sub RefreshButtons(details)
    item = details.content.getChild(details.itemFocused)
    ' play button is always available
    buttons = [{title:"Play", id:"play"}]
    ' continue button available only when this item has bookmark
    if item.bookmarkPosition > 0 then buttons.push({title : "Continue", id:"continue"})
    btnsContent = Utils_ContentList2Node(buttons)
    ' set buttons
    details.buttons = btnsContent
end sub
```

Now we should decide at what point buttons should be refreshed. It should be done once user gets to it. For this reason, we can observe *wasClosed* field of video view.

Add one line of code to OnButtonSelected method

```
    video.ObserveField("wasClosed", "OnVideoWasClosed")
```

In OnVideoWasClosed callback should update buttons.

```
sub OnVideoWasClosed(event as Object)
    RefreshButtons(m.details)
end sub
```

## Part 2: Save bookmarks

For now, bookmark is saved only when user press back from video playback. But Roku best practice is to save it additionally every 10 seconds for cases if user press *Home* or some internet interruption happen.

For this reason, we should define RegistryBookmarksHandler which extends SGDEX's BookmarksHandler and set it configuration into *contentItem*.

```
    contentItem.BookmarksHandler = {
        name : "RegistryBookmarksHandler",
        fields : {
            minBookmark : 10 ' if position > minBookmark (position > 10)
            maxBookmark : 10 ' if position < duration - maxBookmark (position < duration - 10)
            interval : 10 ' bookmark saving interface
        }
    }
```

In RegistryBookmarksHandler we should define SaveBookmark, GetBookmark and RemoveBookmark functions which will be called by inner BookmarksHandler logic.

```
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

```

The last major point we should cover is how to save bookmarks between sessions. For this reason, Roku SDK has object roRegistrySection.

In GetBookmarkData we check if bookmark exists for some id in registry.

```
function BookmarksHelper_GetBookmarkData(id as Object) as Integer
    sec = CreateObject("roRegistrySection", "Bookmarks")
    if sec.Exists("Bookmark_" + id.toStr())
        return sec.Read("Bookmark_" + id.toStr()).ToInt()
    end if

    return 0
end function

sub BookmarksHelper_SetBookmarkData(id as String, position as String)
    sec = CreateObject("roRegistrySection", "Bookmarks")
    sec.Write("Bookmark_" + id, position)
    sec.Flush()
end sub
```

For more info about roRegistrySection see SDK Docs https://sdkdocs.roku.com/display/sdkdoc/roRegistrySection

###### Copyright (c) 2018 Roku, Inc. All rights reserved.
