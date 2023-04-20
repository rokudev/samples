' ********** Copyright 2018 Roku Corp.  All Rights Reserved. **********
'
' this example creates a SceneGraph component with a rectangle,
' the color hex value of the example rectangle is animated,
' animation defined in exampleColorAnimation in the xml file
sub init()
  examplerect = m.top.boundingRect()
  centerx = (1280 - examplerect.width) / 2
  centery = (720 - examplerect.height) / 2
  m.top.translation = [ centerx, centery ]

  m.coloranimation = m.top.FindNode("exampleColorAnimation")
  m.coloranimation.repeat = true
  m.coloranimation.control = "start"
end sub
