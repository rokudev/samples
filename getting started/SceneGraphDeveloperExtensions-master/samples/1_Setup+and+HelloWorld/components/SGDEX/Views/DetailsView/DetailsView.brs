' Copyright (c) 2018 Roku, Inc. All rights reserved.

sub Init()
    m.debug = false
    m.ContentManager_id = 0
    m.detailsLoadingMap = {}
    m.DetailsContentManager_id = 1

    ' setup nodes
    m.spinner =          m.top.FindNode("spinner")
    m.spinner.uri =      "pkg:/components/SGDEX/Images/loader.png"

    m.overhang =         m.top.FindNode("overhang")
    m.poster =           m.top.FindNode("poster")
    m.info1 =            m.top.FindNode("info1")
    m.info2 =            m.top.FindNode("info2")
    m.descriptionLabel = m.top.FindNode("description")
    m.actorsLabel =      m.top.FindNode("actors")
    m.buttons =          m.top.FindNode("buttons")
    m.styledPosterArea = m.top.FindNode("styledPosterArea")

    ' Observe SGDEXComnponent fields
    m.top.ObserveField("style", "OnStyleChange")
    m.top.ObserveField("wasShown", "OnWasShown")
    m.top.ObserveField("posterShape", "OnPosterShapeChange")

    m.top.ObserveField("focusedChild", "OnFocusedChildChanged")
    m.top.ObserveField("itemFocused", "OnItemFocusedChanged")
    m.top.ObserveField("content", "OnContentListSet")

    if m.LastThemeAttributes <> invalid then
        SGDEX_SetTheme(m.LastThemeAttributes)
    end if
end sub

sub OnFocusedChildChanged()
    if m.buttons <> invalid and m.top.IsInFocusChain() and not m.buttons.HasFocus() then
        m.buttons.SetFocus(true)
    end if
end sub

sub OnStyleChange()
    ' TODO implement styles
end sub

sub OnPosterShapeChange()
    m.poster.shape = m.top.posterShape
    posterX = (m.styledPosterArea.width - m.poster.width) / 2
    posterY = (m.styledPosterArea.height - m.poster.height) / 2
    m.poster.translation = [posterX, posterY]
end sub

sub OnWasShown()
    if m.top.content <> invalid
        if m.top.isContentList
            ' check if we have empty root content with proper HandlerConfig
            if m.top.content.HandlerConfigDetails <> invalid and m.top.content.GetChildCount() = 0 then
                ' Show loading indicator
                ' Content should be visible
                ShowBusySpinner(true)
                config = m.top.content.HandlerConfigDetails
                callback = {
                    config: config

                    onReceive: sub(data)
                        gthis = GetGlobalAA()
                        if data <> invalid and data.GetChildCount() > 0
                            ' replace data if needed
                            if not data.IsSameNode(gthis.top.content) then gthis.top.content = data
                            ' fire focus change that will redraw UI and tell developer which item is focused
                            gthis.top.itemFocused = gthis.top.jumpToItem
                        end if
                    end sub

                    onError: sub(data)
                        gthis = GetGlobalAA()
                        if gthis.top.content.HandlerConfigDetails <> invalid then
                            m.config = gthis.top.content.HandlerConfigDetails
                            gthis.top.content.HandlerConfigDetails = invalid
                        end if
                        GetContentData(m, m.config, gthis.top.content)
                    end sub
                }
                GetContentData(callback, config, m.top.content)
            else if m.top.content.GetChildCount() > 0
'                trigger loading of first content
                m.top.itemFocused = m.top.jumpToItem
            end if
'            this is not list of items
'            check if we need to load extra data for this item
        else if m.top.content.HandlerConfigDetails <> invalid then
'           this is one item but it needs extra data
            SetDetailsContent(m.top.content)
'           but load extra metadata
            LoadMoreContent(m.top.content, m.top.content.HandlerConfigDetails)
        else ' This is single item that has everything loaded
'           update current item so developer would know that everything is loaded
            m.top.currentItem = m.top.content
            m.top.itemLoaded = true
'           set details as is
            SetDetailsContent(m.top.content)
        end if
    end if
end sub

sub OnItemFocusedChanged(event as Object)
    focusedItem = event.GetData()
    if m.top.isContentList
        content = m.top.content.GetChild(focusedItem)

        HandlerConfigDetails = content.HandlerConfigDetails

'        we are setting details to details page even if it' s not loaded, so user can see that something has changed
'        developer should put some place holders to show user that data is loading
        SetDetailsContent(content, HandlerConfigDetails <> invalid and HandlerConfigDetails.Count() > 0)

'       if we have details to load then load them, else set item to details
        if HandlerConfigDetails <> invalid
            content.HandlerConfigDetails = invalid
            LoadMoreContent(content, HandlerConfigDetails)
            m.top.currentItem = invalid
        else
            m.top.currentItem = content
            m.top.itemLoaded = true
        end if
    else
'        ?"this is not list"
        ' TODO add logic here if needed
    end if
end sub

sub OnJumpToItem()
    content = m.top.content
    if content <> invalid and m.top.jumpToItem >= 0 and content.Getchildcount() > m.top.jumpToItem
        m.top.itemFocused = m.top.jumpToItem
    end if
end sub

sub SetDetailsContent(content as Object, isLoadinExtrainfo = false as Boolean)
    if content <> invalid
        SetOverhangTitle(content.title)
        m.poster.uri = content.hdposterurl
        contentDurationString = Utils_DurationAsString(content.length)
        m.info1.text = ConvertToStringAndJoin([content.ReleaseDate, contentDurationString])
        m.info2.text = ConvertToStringAndJoin([content.Rating, Content.categories])
        m.descriptionLabel.text = content.description
        m.actorsLabel.text = ConvertToStringAndJoin(content.actors, ", ")
    end if
    if not isLoadinExtrainfo
        ShowBusySpinner(false)
    end if
end sub

sub LoadMoreContent(content, HandlerConfig)
    ShowBusySpinner(true)

    callback = {
        config: HandlerConfig
        content: content

        lastFocusedItem: m.top.itemFocused
        detailsLoadingMap_ID: m.DetailsContentManager_id

'       this flag tells utilities not to fire error when we content doesn' t have children
'       because one item on details View doesn' t have children
        mAllowEmptyResponse: true

        onReceive: function(data)
            m.SetContent(data)
        end function

        onError: function(data)
            if m.content.HandlerConfigDetails <> invalid then
                m.config = m.content.HandlerConfigDetails
                m.content.HandlerConfigDetails = invalid
            end if
            GetContentData(m, m.config, m.content)
        end function

        setContent: sub(content)
            gThis =  GetGlobalAA()
            gThis.detailsLoadingMap.Delete(m.detailsLoadingMap_ID.Tostr())
            if m.lastFocusedItem = gThis.top.itemFocused
                gThis.top.currentItem = content
                gThis.top.itemLoaded = true
                SetDetailsContent(content)
            end if
        end sub
    }
    isAlreadyLoading = false
    if content <> invalid
        if not content.HasField("detailsLoadingMap_ID") then
            content.Addfields({ detailsLoadingMap_ID: m.DetailsContentManager_id })
            m.DetailsContentManager_id++

'            Check If we already load this item, if yes then skip loading
        else if m.detailsLoadingMap[content.detailsLoadingMap_ID.Tostr()] <> invalid
            isAlreadyLoading = true
        else if content.detailsLoadingMap_ID <= 0
            content.detailsLoadingMap_ID = m.DetailsContentManager_id
            m.DetailsContentManager_id++
        end if
        'don't set this item to already loading map so we don' t have issues with busy spinner
        if not isAlreadyLoading
            key = content.detailsLoadingMap_ID.Tostr()
            m.detailsLoadingMap[key] = content
        end if
    end if
    if not isAlreadyLoading then
        GetContentData(callback, HandlerConfig, content)
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    handled = false
    steps = {
        "right": + 1
        "left": - 1
'        "fastforward"   : +2
'        "rewind"        : -2
    }
    if press then
        if steps[key] <> invalid
            handled = true
            content = m.top.content
            if content <> invalid and m.top.isContentList
                newIndex = GetNextItemIndex(m.top.itemFocused, content.Getchildcount() - 1, steps[key], m.top.allowWrapContent)
                if m.top.itemFocused <> newIndex then
                    m.top.jumpToItem = newIndex
                end if
            end if
        end if
    end if

    return handled
end function

sub SetOverhangTitle(title as String)
    if m.overhang <> invalid
        m.overhang.title = title
    end if
end sub

' #################################################################################

function ConvertToStringAndJoin(dataArray as Object, divider = " | " as String) as String
    result = ""
    if Type(dataArray) = "roArray" and dataArray.Count() > 0
        for each item in dataArray
            if item <> invalid
                strFormat = invalid
                if GetInterface(item, "ifToStr") <> invalid
                    strFormat = item.Tostr()
                else if GetInterface(item, "ifArrayJoin") <> invalid
                    strFormat = item.Join(", ")
                end if
                if strFormat <> invalid then
                    if result.Len() > 0 then result += divider
                    result += strFormat
                end if
            end if
        end for
    end if
    return result
end function

function GetNextItemIndex(currentIndex as Integer, maxIndex as Integer, _step as Integer, allowCarousel = false as Boolean, minIndex = 0 as Integer) as Integer
    result = currentIndex + _step

    if result > maxIndex then
        if allowCarousel then
            result = minIndex
        else
            result = maxIndex
        end if
    else if result < minIndex then
        if allowCarousel then
            result = maxIndex
        else
            result = minIndex
        end if
    end if

    return result
end function

sub ShowBusySpinner(shouldShow)
    if shouldShow then
        if not m.spinner.visible then
            m.spinner.visible = true
            m.spinner.control = "start"
        end if
    else
        m.spinner.visible = false
        m.spinner.control = "stop"
    end if
end sub

sub SGDEX_SetTheme(theme as Object)
    colorTheme = {
        TextColor: {
            buttons: [
                "focusedColor"
                "color"
                "sectionDividerTextColor"
            ]

            info1:            "color"
            info2:            "color"
            actorsLabel:      "color"
            descriptionLabel: "color"
        }
        focusRingColor: {
            buttons: ["focusBitmapBlendColor"]
        }
    }

    SGDEX_setThemeFieldstoNode(m, colorTheme, theme)

    detailsThemeAttributes = {
        ' labels color

        descriptionColor:               { descriptionLabel: "color" }
        actorsColor:                    { actorsLabel: "color" }
        ReleaseDateColor:               { info1: "color" }
        RatingAndCategoriesColor:       { info2: "color" }

        ' buttons theme
        buttonsFocusedColor:            { buttons: "focusedColor" }
        buttonsUnFocusedColor:          { buttons: "color" }
        buttonsFocusRingColor:          { buttons: "focusBitmapBlendColor" }
        buttonsSectionDividerTextColor: { buttons: "sectionDividerTextColor" }
    }

    SGDEX_setThemeFieldstoNode(m, detailsThemeAttributes, theme)
end sub

function SGDEX_GetViewType() as String
    return "detailsView"
end function
