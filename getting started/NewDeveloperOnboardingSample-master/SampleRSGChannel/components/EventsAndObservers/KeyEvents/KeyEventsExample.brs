' ********** Copyright 2018 Roku Corp.  All Rights Reserved. ********** 
'        
' this example creates a SceneGraph component with a simple label,
' the visible field is toggled between true and false when the OK key
' is pressed on the remote; the function onKeyEvent() returns the keyHandled information,
' in this case returns true for OK key pressed and returns false for any other cases
sub init()
  m.label = m.top.findNode("exampleLabel")

  examplerect = m.top.boundingRect()
  centerx = (1280 - examplerect.width) / 2
  centery = (720 - examplerect.height) / 2
  m.top.translation = [ centerx, centery ]
end sub 

function onKeyEvent(key as String, press as Boolean) as Boolean
  if press then
    if (key = "OK") then 
      if (m.label.visible = true)
        m.label.visible = false
      else
        m.label.visible = true
      endif

      return true
    end if
  end if

  return false
end function

