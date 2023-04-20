function ShowDetailsView(content, index, isContentList = true)
    ' Create an DetailsView Object
    details = CreateObject("roSGNode", "DetailsView")
    ' Observe the content, so that when it is set the callback
    ' function will run and the buttons can be created
    details.ObserveField("currentItem", "OnDetailsContentSet")
    details.ObserveField("buttonSelected", "OnButtonSelected")
    details.content = content
    details.jumpToItem = index
    details.isContentList = isContentList
    ' This will cause the View to be shown on the View
    m.top.ComponentController.CallFunc("show", {
        view: details
    })
    return details
end function

sub OnDetailsContentSet(event as Object)
    details = event.GetRoSGNode()
    currentItem = event.GetData()
    if currentItem <> invalid
        buttonsToCreate = []

        if currentItem.url <> invalid and currentItem.url <> ""
            buttonsToCreate.Push({ title: "Play", id: "play" })
        else if details.content.TITLE = "series"
            buttonsToCreate.Push({ title: "Episodes", id: "episodes" })
        end if

        buttonsToCreate.Push({ title: "Custom", id: "thumbnail" })

        if buttonsToCreate.Count() = 0
            buttonsToCreate.Push({ title: "No Content to play", id: "no_content" })
        end if
        m.btnsContent = Utils_ContentList2Node(buttonsToCreate)
    end if
    details.buttons = m.btnsContent
end sub

sub OnButtonSelected(event as Object)
    details = event.GetRoSGNode()
    selectedButton = details.buttons.GetChild(event.GetData())

    if selectedButton.id = "play"
        OpenVideoPlayer(details.content, details.itemFocused, details.isContentList)
    else if selectedButton.id = "episodes"
        if details.currentItem.seasons <> invalid then
            ShowEpisodePickerView(details.currentItem.seasons)
        end if
    else if selectedButton.id = "thumbnail"
        if details.currentItem.hdPosterUrl <> invalid then
            ShowCustomView(details.currentItem.hdPosterUrl)
        end if
    else
        ' handle all other button presses
    end if
end sub
