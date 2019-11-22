Library "Roku_Ads.brs"

' ********** Copyright 2016 Roku Corp.  All Rights Reserved. ********** 

'Roku Advertising Framework for Video Ads Main Entry Point
'Creation and configuration of list menu and video screens.
sub Main()
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)
    m.scene = screen.CreateScene("VideoScene")
    screen.show()

    'AA for base video, ad and Nielsen configuration.
    'For additional information please see official RAF documentation.
    m.videoContent = { 
        streamFormat : "mp4",
        'Lengthy (20+ min.) TED talk to allow time for testing ad pods
        stream: {
            url:  "http://video.ted.com/talks/podcast/DavidKelley_2002_480.mp4",
            bitrate: 800,
            quality: false
        }

        'Provider ad url, can be configurable with URL Parameter Macros.
        'Some parameter values can be substituted dinamicly in ad request and tracking URLs.
        'For example: ROKU_ADS_APP_ID - Identifies the client application making the ad request.
        adUrl: "http://1c6e2.v.fwmrm.net/ad/g/1?nw=116450&ssnw=116450&asnw=116450&caid=493509699603&csid=fxn_shows_roku&prof=116450:Fox_Live_Roku&resp=vast&metr=1031&flag=+exvt+emcr+sltp&;_fw_ae=d8b58f7bfce28eefcc1cdd5b95c3b663;app_id=ROKU_ADS_APP_ID",
        
        contentId: "TED", 'String value representing content to allow potential ad targeting.
        contentGenre: "General Variety", 'Comma-delimited string or array of genre tag strings.
        conntentLength: "1200", 'Integer value representing total length of content (in seconds).
        
        nielsenProgramId: "CBAA", 'String identifying content program for Nielsen DAR tags.
        nielsenAppId: "P2871BBFF-1A28-44AA-AF68-C7DE4B148C32", 'String identifying Nielsen-assigned application ID.      
        nielsenGenre: "GV" 'String identifying primary content genre for Nielsen DAR tags.
        
        ' path to the file containing non-standard ads feed
        nonStandardAdsFilePath: "pkg:/feed/ads_nonstandard.json"
    }

    'Array of AA for main menu bulding.
    m.contentList = [
        {
            title: "Full RAF Integration",   
            playWithRaf: PlayContentWithFullRAFIntegration   
        },
        ' {
        '     title: "Server-Side Ad Insertion",     
        '     playWithRaf: PlayContentWithServerSideAdInsertion  
        ' },
        {
            title: "Custom Ad Parsing",    
            playWithRaf: PlayContentWithNonStandardRAFIntegration   
        },
'        {
'            Title: "Test Stitched Ads: Mixed",
'            playWithRaf: TestMixedStitchedAds
'        },
'        {
'            Title: "Test Stitched Ads: Innovid",
'            playWithRaf: TestInnovidStitchedAds
'        }
    ]


    'menu list node
    m.list = m.scene.findNode("MenuList")
    m.list.ObserveField("itemSelected", m.port)

    'video node
    m.video = m.scene.FindNode("MainVideo")
    m.video.observeField("position", m.port)
    m.video.observeField("state", m.port)
    m.video.observeField("navBack", m.port)

    'content node for video node
    contentVideoNode = CreateObject("RoSGNode", "ContentNode")
    contentVideoNode.URL= m.videoContent.stream.url
    m.video.content = contentVideoNode

    'main facade creation.
    m.loading = m.scene.FindNode("LoadingScreen")
    m.loadingText = m.loading.findNode("LoadingScreenText")

    'menu content
    m.content = createObject("RoSGNode","ContentNode")

    'Populating menu with items and setting it to LabelList content
    addSection("")
    for each item in m.contentList
        addItem(item.title)
    end for
    m.list.content = m.content

    'main while loop
    while(true)
        msg = wait(0, m.port)
        msgType = type(msg)

        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return
                else if msgType = "roSGNodeEvent"
            if (msg.GetField() = "itemSelected")

            menuItemTitle = m.contentList[m.list.itemSelected].title
            m.video.infoLabelText = "RAF sample: " + menuItemTitle
            
            'showing facade
            m.list.visible = false
            m.loadingText.text = menuItemTitle
            m.loading.visible = true
            m.loading.setFocus(true)
            
            'wait for 0.5 second before proceeding to RAF
            sleep(500)

            'calling proper method based on list item selected from main menu
            playWithRaf = m.contentList[m.list.itemSelected].playWithRaf
            playWithRaf()

            'showing main menu
            m.list.visible = true
            m.video.visible = false
            m.list.setFocus(true)

            end if
        end if
    end while

end sub

'Add section for list items menu grouping.
'@param sectiontext [String] title of the section.
sub addSection(sectiontext as string)
    m.sectionContent = m.content.createChild("ContentNode")
    m.sectionContent.CONTENTTYPE = "SECTION"
    m.sectionContent.TITLE = sectiontext
end sub

'Add item to list menu.
'@param itemtext [String] title of the item.
sub addItem(itemtext as string)
    item = m.sectionContent.createChild("ContentNode")
    item.title = itemtext
end sub

'Video events handling.
'@param position [Integer] video position.
'@param completed [Boolean] flag if video is completed
'@param started [Boolean] flag if video is started
'@return [AA] object of video event in structured format.
function createPlayPosMsg(position as Integer, completed = false as Boolean, started = false as Boolean) as Object
    videoEvent = { pos: position,
                   done: completed,
                   started: started,
                   isStreamStarted : function () as Boolean
                                           return m.started
                                       end function,
                   isFullResult : function () as Boolean
                                      return m.done
                                  end function,
                   isPlaybackPosition : function () as Boolean
                                            return true
                                        end function,
                   isStatusMessage : function () as Boolean
                                        return (m.done or m.started)
                                     end function,
                   getIndex : function () as Integer
                                  return m.pos
                              end function,
                   getMessage : function () as String
                                    result = ""
                                    if m.done
                                        result = "end of stream"
                                    else if m.started
                                        result = "start of play"
                                    end if
                                    return result
                                end function
                 }
    return videoEvent
end function