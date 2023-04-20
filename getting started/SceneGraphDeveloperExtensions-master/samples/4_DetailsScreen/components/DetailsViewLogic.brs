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
    m.top.ComponentController.callFunc("show", {
        view: details
    })
    return details
end function

sub OnDetailsContentSet(event as Object)
    details = event.getRoSGNode()
    currentItem = event.getData()
    if currentItem <> invalid
        buttonsToCreate = []

        if currentItem.url <> Invalid and currentItem.url <> ""
            buttonsToCreate.push({title:"Play", id:"play"})
        end if

        if buttonsToCreate.count() = 0
            buttonsToCreate.push({title:"No Content to play", id:"no_content"})
        end if
        m.btnsContent = Utils_ContentList2Node(buttonsToCreate)
    end if
    details.buttons = m.btnsContent
end sub
