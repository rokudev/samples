' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

'Main Scene Initialization with menu and video.
sub init()
	m.player = m.top.FindNode("Video")
	m.list = m.top.FindNode("MenuList")
	m.player.setFocus(true)

  'Set the initial video player to some content'
  content = CreateObject("roSGNode", "ContentNode")
  content.url = "http://video.ted.com/talks/podcast/JeffHan_2006_480.mp4"
  content.streamformat = "mp4"
  m.itemfocused = 0
  m.player.content = content
  'Tell the video player to play the content'
  m.player.control = "play"
end sub

'Handle remote control key presses'
function onKeyEvent(key as String, press as Boolean) as boolean
  print key + ":" ; press
  if press
    if key = "OK"
      print m.list.visible
      print m.list.itemfocused
      print m.itemfocused
      if m.list.ItemFocused = m.itemfocused and m.list.visible = true
        m.list.visible = false
        m.player.setfocus(true)
      else if m.list.visible = false
        m.list.visible = true
      else if m.list.visible = true
        m.itemfocused = m.list.itemfocused
        m.player.visible = false
        m.player.control = "stop"
        selectedContent = m.list.content.getChild(m.list.itemfocused)
        content = CreateObject("roSGNode", "ContentNode")
        content.url = selectedContent.url
        content.streamformat = selectedContent.description
        m.player.content = content
        m.player.visible = true
        m.player.control = "play"
      end if
    else if key = "play"
      if m.player.control = "pause"
        m.player.control = "resume"
      else
        m.player.control = "pause"
      end if
    else if key = "back"
      if m.list.visible = true
        m.list.visible = false
        m.player.setfocus(true)
        return true
      else
        m.list.visible = true
        m.list.setfocus(true)
        return true
      end if
    else
      print key
    end if
  else
    m.list.setfocus(true)
  end if
end function
