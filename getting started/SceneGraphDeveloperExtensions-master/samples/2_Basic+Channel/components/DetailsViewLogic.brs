function ShowDetailsView(content, index, isContentList = true)
    details = CreateObject("roSGNode", "DetailsView")
    details.ObserveField("content", "OnDetailsContentSet")
    details.ObserveField("buttonSelected", "OnButtonSelected")

    details.content = content
    details.jumpToItem = index
    details.isContentList = isContentList

    'this will trigger job to show this View
    m.top.ComponentController.callFunc("show", {
        view: details
    })

    return details
end function

sub OnDetailsContentSet(event as Object)
    if event.getData().TITLE = "series"
        m.btnsContent = Utils_ContentList2Node([{title:"Episodes", id:"episodes"}])
    else
        m.btnsContent = Utils_ContentList2Node([{title:"Play", id:"play"}])
    end if

    details = event.getRoSGNode()
    details.buttons = m.btnsContent
end sub

sub OnButtonSelected(event as Object)
    details = event.GetRoSGNode()
    selectedButton = details.buttons.GetChild(event.GetData())

    if selectedButton.id = "play"
        OpenVideoPlayer(details.content, details.itemFocused, details.isContentList)
    else if selectedButton.id = "episodes"
        ShowEpisodePickerView(details.currentItem.seasons)
    end if
end sub
