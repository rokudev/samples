' ********** Copyright 2018 Roku Corp.  All Rights Reserved. **********
'
' this example creates a SceneGraph component with 3 rectangles,
' the animation defined in exampleSequentialAnimation in the xml file
' defines a sequential order of execution of the animations
sub init()
  examplerect = m.top.boundingRect()
  centerx = (1280 - examplerect.width) / 2
  centery = (720 - examplerect.height) / 2
  m.top.translation = [ centerx, centery ]

  m.examplesequentialanimation = m.top.findNode("exampleSequentialAnimation")
  m.examplesequentialanimation.repeat = true
  m.examplesequentialanimation.control = "start"
end sub
