' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

Sub Init()
  print "FadingBackground.brs - [Init]"
  ' setting top interfaces
  m.backgroundColor = m.top.findNode("backgroundColor")
  m.oldBackground = m.top.findNode("oldBackground")
  m.background = m.top.findNode("background")
  m.shade = m.top.findNode("shade")
  m.fadeoutAnimation = m.top.findNode("fadeoutAnimation")
  m.oldbackgroundInterpolator = m.top.findNode("oldbackgroundInterpolator")
  m.fadeinAnimation = m.top.findNode("fadeinAnimation")

  ' setting observers
  m.background.observeField("bitmapWidth", "OnBackgroundLoaded")
  m.top.observeField("width", "OnSizeChange")
  m.top.observeField("height", "OnSizeChange")
End Sub

' If background changes, start animation and populate fields
Sub OnBackgroundUriChange()
  print "FadingBackground.brs - [OnBackgroundUriChange]"
  oldUrl = m.background.uri
  m.background.uri = m.top.uri
  if oldUrl <> "" then
    m.oldBackground.uri = oldUrl
    m.oldbackgroundInterpolator = [m.background.opacity, 0]
    m.fadeoutAnimation.control = "start"
  end if
End Sub

' If Size changed, change parameters to childrens'
Sub OnSizeChange()
  print "FadingBackground.brs - [OnSizeChange]"
  size = m.top.size

  m.background.width = m.top.width
  m.oldBackground.width = m.top.width
  m.shade.width = m.top.width
  m.backgroundColor.width = m.top.width

  m.oldBackground.height = m.top.height
  m.background.height = m.top.height
  m.shade.height = m.top.height
  m.backgroundColor.height = m.top.height
End Sub

' When Background image loaded, start animation
Sub OnBackgroundLoaded()
  print "FadingBackground.brs - [OnBackgroundLoaded]"
  m.fadeinAnimation.control = "start"
End Sub
