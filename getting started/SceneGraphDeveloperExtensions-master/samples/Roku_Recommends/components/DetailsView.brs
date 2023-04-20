function ShowDetailsView(content, index) as Object
    details = CreateObject("roSGNode", "DetailsView")
    details.content = content
    details.jumpToItem = index
    details.observeField("currentItem","onDetailsContentSet")
    details.observeField("buttonSelected", "onButtonSelected")
    m.top.ComponentController.CallFunc("show", {
        view: details
    })
    return details
end function

function onDetailsContentSet(event as Object) as void
    content = event.getData()
    if (content <> invalid)
        m.btnsContent = CreateObject("roSGNode", "ContentNode")
        streamUrl = content.url
        if (streamUrl <> invalid and streamUrl <> "")
            playButton = CreateObject("roSGNode", "ContentNode")
            playButton.title = "Play"
            m.btnsContent.AppendChild(playButton)
        else
            loadingButton = CreateObject("roSGNode", "ContentNode")
            loadingButton.title = "Loading..."
            m.btnsContent.AppendChild(loadingButton)
        endif
        details = event.getRoSGNode()
        details.buttons = m.btnsContent
    endif
end function

function onButtonSelected(event as Object) as void
    details = event.getRoSGNode()
    OpenVideoView(details.content, details.itemFocused)
end function
