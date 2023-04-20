sub ConfigureRAF(adIface)
    ' Detailed RAF docs: https://sdkdocs.roku.com/display/sdkdoc/Integrating+the+Roku+Advertising+Framework#IntegratingtheRokuAdvertisingFramework-setContentLength(lengthasInteger)
    ? "[CHANNEL] ConfigureRAF"
    ? "m.top.contentID == ";m.top.contentID
    adIface.setDebugOutput(true)

    adIface.SetAdUrl("http://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/8264/vaw-can/ott/cbs_roku_app&ciu_szs=300x60,300x250&impl=s&gdfp_req=1&env=vp&output=xml_vmap1&unviewed_position_start=1&url=&description_url=&correlator=1448463345&scor=1448463345&cmsid=2289&vid=_g5o4bi39s_IRXu396UJFWPvRpGYdAYT&ppid=f47f1050c15b918eaa0db29c25aa0fd6&cust_params=sb%3D1%26ge%3D1%26gr%3D2%26ppid%3Df47f1050c15b918eaa0db29c25aa0fd6")

    ' Content details used by RAF for ad targeting
    adIface.SetContentId("MY_CONTENT_ID")
    adIface.SetContentGenre("General Variety")
    adIface.SetContentLength(1200) ' in seconds

    ' Nielsen specific data
    adIface.EnableNielsenDAR(true)
    adIface.SetNielsenProgramId("CBAA")
    adIface.SetNielsenGenre("GV")
    adIface.SetNielsenAppId("MY_NIELSEN_ID")
end sub
