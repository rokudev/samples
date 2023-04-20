' ********** Copyright 2016 Roku Inc.  All Rights Reserved. **********

Function loadContentFeed() as Object
    arr = [ {
                Title: "DD+ 5.1 MP4"
                streamFormat: "mp4"
                Logo: "pkg:/images/dolby-poster.png"
                Stream: "http://developerdownload.dolby.com/video_stream_content/Dolby_Digital_Plus51_AVC/MP4/MP4_HPL40_30fps_channel_id_51.mp4"
            }
            {
                Title: "DD+ 5.1 HLS"
                streamFormat: "hls"
                Logo: "pkg:/images/dolby-poster.png"
                Stream: "http://d9zmmjtv72w5o.cloudfront.net/developer_portal/Dolby_Digital_Plus51_AVC/HLS/Living-Room_51_30p.m3u8"
            }
            {
                Title: "DD+ 5.1 Smooth"
                streamFormat: "ism"
                Logo: "pkg:/images/dolby-poster.png"
                Stream: "http://d9zmmjtv72w5o.cloudfront.net/developer_portal/Dolby_Digital_Plus51_AVC/Smooth/Living-Room_51_30p.ism/manifest"
            }
            {
                Title: "DD+ 7.1 MP4"
                streamFormat: "mp4"
                Logo: "pkg:/images/dolby-poster.png"
                Stream: "http://developerdownload.dolby.com/video_stream_content/Dolby_Digital_Plus_71_AVC/MP4/MP4_HPL40_30fps_channel_id_71.mp4"
            }
            {
                Title: "DD+ 7.1 HLS"
                streamFormat: "hls"
                Logo: "pkg:/images/dolby-poster.png"
                Stream: "http://d9zmmjtv72w5o.cloudfront.net/developer_portal/Dolby_Digital_Plus_71_AVC/HLS/Living-Room_71_30p.m3u8"
            }
            {
                Title: "DD+ 7.1 Smooth"
                streamFormat: "ism"
                Logo: "pkg:/images/dolby-poster.png"
                Stream: "http://d9zmmjtv72w5o.cloudfront.net/developer_portal/Dolby_Digital_Plus_71_AVC/Smooth/Living-Room_71_30p.ism/manifest"
            } ]
    return arr
End Function
