' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

' 1st function that runs for the scene component on channel startup
sub init()
  'To see print statements/debug info, telnet on port 8089
  m.Image       = m.top.findNode("Image")
  m.ButtonGroup = m.top.findNode("ButtonGroup")
  m.Details     = m.top.findNode("Details")
  m.Title       = m.top.findNode("Title")
  m.Video       = m.top.findNode("Video")
  m.Warning     = m.top.findNode("WarningDialog")
  m.Exiter      = m.top.findNode("Exiter")
  setContent()
  m.ButtonGroup.setFocus(true)
  m.ButtonGroup.observeField("buttonSelected","onButtonSelected")
end sub

sub onButtonSelected()
  'Ok'
  if m.ButtonGroup.buttonSelected = 0
    m.Video.visible = "true"
    m.Video.control = "play"
    m.Video.setFocus(true)
  'Exit button pressed'
  else
    m.Exiter.control = "RUN"
  end if
end sub

'Set your information here
sub setContent()

  'Change the image
  'm.Image.uri="pkg:/images/DanGilbert.jpg"
  'ContentNode = CreateObject("roSGNode", "ContentNode")
  'ContentNode.streamFormat = "mp4"
  'ContentNode.url = "http://video.ted.com/talks/podcast/DanGilbert_2004_480.mp4"
  'ContentNode.ShortDescriptionLine1 = "Dan Gilbert asks, Why are we happy?"
  'ContentNode.Description = "Harvard psychologist Dan Gilbert says our beliefs about what will make us happy are often wrong -- a premise he supports with intriguing research, and explains in his accessible and unexpectedly funny book, Stumbling on Happiness."
  'ContentNode.StarRating = 80
  'ContentNode.Length = 1280
  'ContentNode.Title = "Dan Gilbert asks, Why are we happy?"

  m.Image.uri="pkg:/images/CraigVenter-2008.jpg"
  ContentNode = CreateObject("roSGNode", "ContentNode")
  ContentNode.streamFormat = "mp4"
  ContentNode.url = "http://video.ted.com/talks/podcast/DanGilbert_2004_480.mp4"
  ContentNode.ShortDescriptionLine1 = "Can we create new life out of our digital universe?"
  ContentNode.Description = "He walks the TED2008 audience through his latest research into fourth-generation fuels -- biologically created fuels with CO2 as their feedstock. His talk covers the details of creating brand-new chromosomes using digital technology, the reasons why we would want to do this, and the bioethics of synthetic life. A fascinating Q and A with TED's Chris Anderson follows."
  ContentNode.StarRating = 80
  ContentNode.Length = 1972
  ContentNode.Title = "Craig Venter asks, Can we create new life out of our digital universe?"
  ContentNode.subtitleConfig = {Trackname: "pkg:/source/CraigVenter.srt" }

  'm.Image.uri="pkg:/images/BigBuckBunny.jpg"
  'ContentNode = CreateObject("roSGNode", "ContentNode")
  'ContentNode.streamFormat = "mp4"
  'ContentNode.url = "http://video.ted.com/talks/podcast/CraigVenter_2008_480.mp4"
  'ContentNode.ShortDescriptionLine1 = "Big Buck Bunny"
  'ContentNode.Description = "Big Buck Bunny is being served using a Wowza server running on Amazon EC2 cloud services. The video is transported via HLS HTTP Live Streaming. A team of small artists from the Blender community produced this open source content..."
  'ContentNode.StarRating = 80
  'ContentNode.Length = 600
  'ContentNode.Title = "Big Buck Bunny"

  m.Video.content = ContentNode

  'Change the buttons
  Buttons = ["Play","Exit"]
  m.ButtonGroup.buttons = Buttons

  'Change the details
  'm.Title.text = "Dan Gilbert asks, Why are we happy?"
  'm.Details.text = "Harvard psychologist Dan Gilbert says our beliefs about what will make us happy are often wrong -- a premise he supports with intriguing research, and explains in his accessible and unexpectedly funny book, Stumbling on Happiness."

  m.Title.text = "Craig Venter asks, Can we create new life out of our digital universe?"
  m.Details.text =  "He walks the TED2008 audience through his latest research into fourth-generation fuels -- biologically created fuels with CO2 as their feedstock. His talk covers the details of creating brand-new chromosomes using digital technology, the reasons why we would want to do this, and the bioethics of synthetic life. A fascinating Q and A with TED's Chris Anderson follows."

end sub

' Called when a key on the remote is pressed
function onKeyEvent(key as String, press as Boolean) as Boolean
  print "in SimpleVideoScene.xml onKeyEvent ";key;" "; press
  if press then
    if key = "back"
      print "------ [back pressed] ------"
      if m.Warning.visible
        m.Warning.visible = false
        m.ButtonGroup.setFocus(true)
        return true
      else if m.Video.visible
        m.Video.control = "stop"
        m.Video.visible = false
        m.ButtonGroup.setFocus(true)
        return true
      else
        return false
      end if
    else if key = "OK"
      print "------- [ok pressed] -------"
      if m.Warning.visible
        m.Warning.visible = false
        m.ButtonGroup.setFocus(true)
        return true
      end if
    else
      return false
    end if
  end if
  return false
end function
