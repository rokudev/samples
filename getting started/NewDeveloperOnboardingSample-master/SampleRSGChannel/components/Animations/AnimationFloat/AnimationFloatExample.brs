' ********** Copyright 2018 Roku Corp.  All Rights Reserved. ********** 
'        
' this example creates a SceneGraph component with a poster,
' the opacity float value of the example poster is animated,
' animation defined in exampleFloatAnimation in the xml file
sub init()
  examplerect = m.top.boundingRect()
  centerx = (1280 - examplerect.width) / 2
  centery = (720 - examplerect.height) / 2
  m.top.translation = [ centerx, centery ]

  m.floatanimation = m.top.FindNode("exampleFloatAnimation")
  m.floatanimation.repeat = true
  m.floatanimation.control = "start"
end sub
