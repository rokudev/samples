' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

' Component initialization, setting default properties
sub init()
    print ">>> RokuAuthScreen :: init()"
    m.top.visible = false
    
    m.top.posterSplash = m.top.CreateChild("Poster")
    
    m.top.buttonLogin = m.top.CreateChild("Button")
    m.top.buttonLogin.text = "Already a subscriber (log in)"
    m.top.buttonLogin.minWidth = 200
    m.top.buttonLogin.translation = [200,600]
    m.top.buttonLogin.showFocusFootprint = true
    
    m.top.buttonSignup = m.top.CreateChild("Button")
    m.top.buttonSignup.text = "New subscriber (sign up)"
    m.top.buttonSignup.minWidth = 200
    m.top.buttonSignup.translation = [700,600]
    m.top.buttonSignup.showFocusFootprint = true
    
    print "<<< RokuAuthScreen :: init()"
end sub


' Overridden Key event handler for button focus processing
function onKeyEvent(key as String, bPressed as Boolean) as Boolean
    result = false
    if bPressed AND (key = "left" OR key = "right" OR key = "up" OR key = "down") then
        bButtonLoginFocused = m.top.buttonLogin.hasFocus()
        m.top.buttonLogin.setFocus(not bButtonLoginFocused)
        m.top.buttonSignup.setFocus(bButtonLoginFocused)
        result = true
    end if
    return result
end function


' onChange handler for "show" field
sub On_show()
    m.top.visible = m.top.show
    m.top.setFocus(m.top.show)
end sub