' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********  

sub init()
    m.top.SetFocus(true)
    
    infoPane = m.top.findNode("infoPane")
    infoPane.infoText = "The InfoPane node class is used to display an opaque, white-bordered, rounded rectangular label with text providing help for a specific setting." + chr(10) + chr(10) + "This component can be used to help customers successfully configure settings related to their account profile, closed captioning, parental controls, and so on."
End sub
