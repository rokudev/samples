' ********** Copyright 2018 Roku Corp.  All Rights Reserved. ********** 
'
' We will initialize the Timer example by centering the example and
' starting the timer node by setting it's control field to "start".
' The example will observe when a "fire" event has occured from the
' timer and a callback function will be called at that time.
sub init()
    m.defaulttext = "Wait for it, wait for it..."
    m.alternatetext = "Timer fired!!!"
    m.exampletimerlabel = m.top.FindNode("exampleTimerLabel")
    m.exampletimerlabel.text = m.defaulttext
    m.textchange = false

    m.exampletimer = m.top.findNode("exampleTimer")
    m.exampletimer.control = "start"
    m.exampletimer.ObserveField("fire", "changetext")

    examplerect = m.top.boundingRect()
    centerx = (1280 - examplerect.width) / 2
    centery = (720 - examplerect.height) / 2
    m.top.translation = [ centerx, centery ]
end sub

' This function will change the label's text field to reflect when
' the timer fired. Each time the timer fires an event, the text will
' change from the default text to the alternative text.
sub changetext()
    if (m.textchange = false) then 
        m.exampletimerlabel.text = m.alternatetext
        m.textchange = true
    else
        m.exampletimerlabel.text = m.defaulttext
        m.textchange = false
    end if
end sub