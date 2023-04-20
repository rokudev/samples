' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

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

        ' create a video view so we can start preloading content
        ' we won't show this view until the user selects the "Play" button on the DetailsView
        m.video = CreateObject("roSGNode", "VideoView")

        ' we'll use this observer to print the state of the VideoView to the console
        ' this let's us see when prebuffering starts
        m.video.observeField("state", "OnVideoState")

        ' preloading also works while endcards are displayed
        m.video.alwaysShowEndcards = true

        m.video.content = details.content
        m.video.jumpToItem = details.itemFocused

        ' turn on preloading
        ' it's off by default for backward compatibility
        m.video.preloadContent = true
    end if
end function

function onButtonSelected(event as Object) as void
    ' the video view already exists and has been preloading content
    ' all we do now is push it onto the view stack
    m.top.ComponentController.CallFunc("show", {
        view: m.video
    })
    m.video.control = "play"
end function

sub OnVideoState(event)
  ? "OnVideoState " + m.video.state
end sub
