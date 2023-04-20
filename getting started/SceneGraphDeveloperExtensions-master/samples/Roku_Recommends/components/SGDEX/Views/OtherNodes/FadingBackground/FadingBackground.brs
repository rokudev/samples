' Copyright (c) 2018 Roku, Inc. All rights reserved.

Sub Init()
    m.background = m.top.findNode("background")
    m.oldBackground = m.top.findNode("oldBackground")
    m.shade = m.top.findNode("shade")

    m.fadeoutAnimation = m.top.findNode("fadeoutAnimation")
    m.fadeinAnimation = m.top.findNode("fadeinAnimation")
    m.shadeAnimation = m.top.findNode("shadeAnimation")
    
    m.shadeAnimationInterp = m.top.findNode("shadeAnimationInterp")
    m.backgroundInterpolator = m.top.findNode("backgroundInterpolator")
    m.oldbackgroundInterpolator = m.top.findNode("oldbackgroundInterpolator")
    
    m.fadeoutAnimation.observeField("state", "OnAnimationStateChange")
    m.fadeinAnimation.observeField("state", "OnAnimationStateChange")

    m.background.observeField("bitmapWidth", "OnBackgroundLoaded")
    m.background.observeField("loadStatus", "OnBackgroundLoadStatusChange")
    m.top.observeField("width", "OnSizeChange")
    m.top.observeField("height", "OnSizeChange")
End Sub

' If background changes, start animation and populate fields
Sub OnBackgroundUriChange()
    oldUrl = m.background.uri

    m.isValidURL = m.top.uri <> invalid and m.top.uri.len() > 0
    if m.isValidURL then m.shade.visible = m.isValidURL

    if oldUrl <> "" then
        m.oldBackground.uri = oldUrl
        m.oldBackground.opacity = m.background.opacity
        m.background.opacity = 0.0
        m.fadeinAnimation.control = "stop"
        m.oldbackgroundInterpolator.keyValue = [m.oldBackground.opacity, 0.0]
        m.fadeoutAnimation.control = "start"
    end if

    m.background.uri = m.top.uri
End Sub

' If Size changed, change parameters to childrens
Sub OnSizeChange()
    size = m.top.size
    
    m.background.width = m.top.width
    m.background.loadWidth = m.top.width
    m.oldBackground.width = m.top.width
    m.oldBackground.loadWidth = m.top.width
    m.shade.width = m.top.width

    m.oldBackground.height = m.top.height
    m.oldBackground.loadHeight = m.top.height
    m.background.height = m.top.height
    m.background.loadHeight = m.top.height
    m.shade.height = m.top.height
End Sub

' When Background image loaded, start animation
Sub OnBackgroundLoaded()
    m.backgroundInterpolator.keyValue = [0.0, 1.0]
    m.fadeinAnimation.control = "start"
End Sub

Sub OnBackgroundLoadStatusChange()
    ''?"Background load status : "m.background.loadStatus
    if m.background.loadStatus = "failed" AND m.isValidURL
        ShowShade(false)
    end if
End Sub

sub OnAnimationStateChange()
    if m.fadeoutAnimation.state = "stopped" or m.fadeinAnimation.state = "running"
        ShowShade(m.isValidURL)
    end if
end sub

sub ShowShade(show as Boolean)
    currentOpacity = m.shade.opacity

    if show
        desiredOpacity = m.top.shadeOpacity
    else
        desiredOpacity = 0.0
    end if

    if desiredOpacity <> currentOpacity
        m.shadeAnimationInterp.keyValue = [currentOpacity, desiredOpacity]
        m.shadeAnimation.control = "start"
    end if
end sub

sub OnAnimationDurationChange(event as Object)
    animationDuration = event.getData()

    m.fadeinAnimation.duration = animationDuration
    m.fadeoutAnimation.duration = animationDuration
    m.shadeAnimation.duration = animationDuration
end sub

sub OnShadeOpacityChange()
    m.shade.opacity = m.top.shadeOpacity
end sub
