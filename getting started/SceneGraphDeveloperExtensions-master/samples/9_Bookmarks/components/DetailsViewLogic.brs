' ********** Copyright 2017 Roku Corp.  All Rights Reserved. **********

' function will create and show DetailsView
function ShowDetailsView(content as Object, index as Integer) as Object
    details = CreateObject("roSGNode", "DetailsView")

    details.content = content
    details.jumpToItem = index
    details.ObserveFieldScoped("currentItem", "OnDetailsContentSet")
    details.ObserveFieldScoped("buttonSelected", "OnButtonSelected")

    'this will trigger job to show this View
    m.top.ComponentController.callFunc("show", {
        view: details
    })

    m.details = details
    return details
end function

' function will update buttons once item for details is loaded
sub OnDetailsContentSet(event as Object)
    ' user should decide is update buttons or not
    content = event.getData()
    if content <> invalid
        streamUrl = content.url
        details = event.getRoSGNode()
        if streamUrl <> invalid and streamUrl <> ""
            RefreshButtons(details)
        else
            btnsContent = Utils_ContentList2Node([{title:"Loading"}])
            details.buttons = btnsContent
        end if
    end if
end sub

' callback for on button selected event
sub OnButtonSelected(event as Object)
    details = event.getRoSGNode()
    button = details.buttons.getChild(event.getData())
    item = details.content.getChild(details.itemFocused)
    if button.id = "play" then
        item.bookmarkPosition = 0
    end if

    video = OpenVideoPlayer(details.content, details.itemFocused, true)
    video.ObserveFieldScoped("wasClosed", "OnVideoWasClosed")
end sub

' callback for video view close event
sub OnVideoWasClosed()
    RefreshButtons(m.details)
end sub

' function for refreshing buttons on details View
' it will check whether item has bookmark and show correct buttons
sub RefreshButtons(details as Object)
    item = details.content.getChild(details.itemFocused)
    ' play button is always available
    buttons = [{title:"Play", id:"play"}]
    ' continue button available only when this item has bookmark
    if item.bookmarkPosition > 0 then buttons.push({title : "Continue", id:"continue"})
    btnsContent = Utils_ContentList2Node(buttons)
    ' set buttons
    details.buttons = btnsContent
end sub
