' Copyright (c) 2018 Roku, Inc. All rights reserved.

sub Init()
    m.debug = false
    m.ContentManager_id = 0
    m.spinner = m.top.findNode("spinner")
    m.spinner.uri = "pkg:/components/SGDEX/Images/loader.png"

    m.top.ObserveField("content", "OnContentSet")

    if m.LastThemeAttributes <> invalid then
        SGDEX_SetTheme(m.LastThemeAttributes)
    end if
end sub

sub OnContentSet()
    if m.top.content <> invalid and m.top.content.HandlerConfigCustom <> invalid then
        HandlerConfigCustom = m.top.content.HandlerConfigCustom
        m.top.content.HandlerConfigCustom = invalid
        LoadMoreContent(m.top.content, HandlerConfigCustom)
    end if
end sub

sub LoadMoreContent(content, HandlerConfig)
    ShowBusySpinner(true)

    callback = {
        config: HandlerConfig
        content: content

        onReceive: function(data)
            m.SetContent(data)
        end function

        onError: function(data)
            if m.content.HandlerConfigCustom <> invalid then
                m.config = m.content.HandlerConfigCustom
                m.content.HandlerConfigCustom = invalid
                GetContentData(m, m.config, m.content)
            end if
        end function

        setContent: sub(content)
            ShowBusySpinner(false)
        end sub
    }

    GetContentData(callback, HandlerConfig, content)
end sub

' #################################################################################

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
    return "customView"
end function
