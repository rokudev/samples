' ********** Copyright 2018 Roku Corp.  All Rights Reserved. ********** 
'        
' this example creates a SceneGraph component with a moving label that goes right
' left on the parent's enclosing boundary rectangle, the animation changes the movingLabel's
' translation field to move the label from right to left and left to right;
' finally the timer toggles the text in movingLabel between m.defaulttext and m.alternatetext
sub init()
  examplerect = m.top.boundingRect()
  centerx = (1280 - examplerect.width) / 2
  centery = (720 - examplerect.height) / 2
  m.top.translation = [ centerx, centery ]

  m.movinglabel = m.top.findNode("movingLabel")
  scrollback = m.top.findNode("scrollbackAnimation")
  texttimer = m.top.findNode("textTimer")
  m.defaulttext = "All The Best Videos!"
  m.alternatetext = "All The Time!!!"
  m.textchange = false
  texttimer.observeField("fire", "changetext")
  scrollback.control = "start"
  texttimer.control = "start"
end sub

sub changetext()
  if (m.textchange = false) then 
    m.movinglabel.text = m.alternatetext
    m.textchange = true
  else
    m.movinglabel.text = m.defaulttext
    m.textchange = false
  end if
end sub

