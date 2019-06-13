' ********** Copyright 2016 Roku Corp.  All Rights Reserved. ********** 
Library "Roku_Ads.brs"

function Main() as void
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)
    scene = screen.CreateScene("MainScene")
    screen.show()
    PlayContentWithCSAS(scene)
end function

sub PlayContentWithCSAS(scene as Object)
    adUrl = "https://devtools.web.roku.com/samples/sample.xml"
    videoUrl = "http://pmd205604tn.download.theplatform.com.edgesuite.net/Demo_Sub_Account_2/411/535/ED_HD__571970.m3u8"
    m.adIface = Roku_Ads() 'RAF initialize
    m.adIface.enableAdMeasurements(true)
    m.adIface.setContentGenre("Entertainment")
    m.adIface.setContentId("CSASAdSample" )
    m.adIface.setContentLength(600)

    m.adIface.SetDebugOutput(true) 'for debug purpose
    m.adIface.SetAdPrefs(false)
    m.adIface.SetAdURL(adUrl)

    m.adPods = m.adIface.GetAds()
    myContentNode = createObject("roSgNode", "ContentNode")
    myContentNode.url = videoUrl
    myContentNode.length = 600
    myContentNode.streamFormat = "hls"

    csasStream = m.adIface.constructStitchedStream(myContentNode, m.adPods)
    m.adIface.renderStitchedStream(csasStream, scene)
end sub
