'********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

function init() as void
    m.top.title="Purchase Status"
    m.buttons =  [ "OK" ]
    m.top.buttons = m.buttons
    m.top.observeField("buttonSelected", "onButtonSelected")
end function
function onButtonSelected()
  m.top.close = true
end function
