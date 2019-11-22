'* Copyright (c) 2017 Roku, Inc. All rights reserved.
'
' File: MainScene.brs
'

function init()
    print "=================== UI STARTING =================="
    print m.top.subType() + ".init()"

    m.top.findNode("sampleVideo").setFocus(true)

end function
