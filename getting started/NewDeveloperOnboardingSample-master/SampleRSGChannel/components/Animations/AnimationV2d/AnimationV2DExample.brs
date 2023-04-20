' ********** Copyright 2018 Roku Corp.  All Rights Reserved. ********** 
'        
' this example creates a SceneGraph component with a moving rectangle,
' the translation field of the moving rectangle is animated,
' animation defined in exampleVector2DAnimation in the xml file
sub init()
  examplerect = m.top.boundingRect()
  centerx = (1280 - examplerect.width) / 2
  centery = (720 - examplerect.height) / 2
  m.top.translation = [ centerx, centery ]

  m.vector2danimation = m.top.FindNode("exampleVector2DAnimation")
  m.vector2danimation.repeat = true
  m.vector2danimation.control = "start"
end sub
