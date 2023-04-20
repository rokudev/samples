' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********  

sub init()
    m.top.SetFocus(true)
    m.top.backgroundUri = ""
    m.top.backgroundColor = "0xffffffff"
    m.top.backExitsScene = false
    m.pogo = m.top.findNode("pogo")
    m.animation = m.top.findNode("pogoAnimation")
    m.pogo.observeField("translation", "onTranslation")
    m.se = m.top.findNode("se")
End sub

function onTranslation() as void
    if m.pogo.translation[1] > 400 and m.se.state <> "playing"
        m.se.control = "play"
    end if
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
    result = true
    
    if press then
        if key = "OK"
            m.animation.control = "start"
        end if
    end if
    
    return result 
end function
