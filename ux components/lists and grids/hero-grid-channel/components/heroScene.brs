' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

' 1st function that runs for the scene on channel startup
sub init()
  'To see print statements/debug info, telnet on port 8089
  'print "HeroScene.brs - [init]"
  ' HeroScreen Node with RowList
  m.HeroScreen = m.top.FindNode("HeroScreen")
  ' DetailsScreen Node with description & video player
  m.DetailsScreen = m.top.FindNode("DetailsScreen")
  ' The spinning wheel node
  m.LoadingIndicator = m.top.findNode("LoadingIndicator")
  ' Dialog box node. Appears if content can't be loaded
  m.WarningDialog = m.top.findNode("WarningDialog")
  ' Transitions between screens
  m.FadeIn = m.top.findNode("FadeIn")
  m.FadeOut = m.top.findNode("FadeOut")
  ' Set focus to the scene
  m.top.setFocus(true)
end sub

' Hero Grid Content handler fucntion. If content is set, stops the
' loadingIndicator and focuses on GridScreen.
sub OnChangeContent()
  'print "HeroScene.brs - [OnChangeContent]"
  m.loadingIndicator.control = "stop"
  if m.top.content <> invalid
    'Warn the user if there was a bad request
    if m.top.numBadRequests > 0
      m.HeroScreen.visible = "true"
      m.WarningDialog.visible = "true"
      m.WarningDialog.message = (m.top.numBadRequests).toStr() + " request(s) for content failed. Press '*' or OK or '<-' to continue."
    else
      m.HeroScreen.visible = "true"
      m.HeroScreen.setFocus(true)
    end if
  else
    m.WarningDialog.visible = "true"
  end if
end sub

' Row item selected handler function.
' On select any item on home scene, show Details node and hide Grid.
sub OnRowItemSelected()
  'print "HeroScene.brs - [OnRowItemSelected]"
  m.FadeIn.control = "start"
  m.HeroScreen.visible = "false"
  m.DetailsScreen.content = m.HeroScreen.focusedContent
  m.DetailsScreen.setFocus(true)
  m.DetailsScreen.visible = "true"
end sub

' Called when a key on the remote is pressed
function onKeyEvent(key as String, press as Boolean) as Boolean
  print ">>> HomeScene >> OnkeyEvent"
  result = false
  print "in HeroScene.xml onKeyEvent ";key;" "; press
  if press then
    if key = "back"
      print "------ [back pressed] ------"
      ' if WarningDialog is open
      if m.WarningDialog.visible = true
        m.WarningDialog.visible = "false"
        m.HeroScreen.setFocus(true)
        result = true
      ' if Details opened
      else if m.HeroScreen.visible = false and m.DetailsScreen.videoPlayerVisible = false
        m.FadeOut.control = "start"
        m.HeroScreen.visible = "true"
        m.detailsScreen.visible = "false"
        m.HeroScreen.setFocus(true)
        result = true
      ' if video player opened
      else if m.HeroScreen.visible = false and m.DetailsScreen.videoPlayerVisible = true
        m.DetailsScreen.videoPlayerVisible = false
        result = true
      end if
    else if key = "OK"
      print "------- [ok pressed] -------"
      if m.WarningDialog.visible = true
        m.WarningDialog.visible = "false"
        m.HeroScreen.setFocus(true)
      end if
    else if key = "options"
      print "------ [options pressed] ------"
      m.WarningDialog.visible = "false"
      m.HeroScreen.setFocus(true)
    end if
  end if
  return result
end function
