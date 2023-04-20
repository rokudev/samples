sub GetContent()
    ' Emulate API call
    sleep(200)
    ' Create item for details View
    item = Utils_AAToContentNode({
        title: "Supre cinema"
        releaseDate: "25.12.2018"
        rating: "7.5"
        categories: "comedy, triller"
        description: "Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of ""de Finibus Bonorum et Malorum"" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, ""Lorem ipsum dolor sit amet.."", comes from a line in section 1.10.32."
        actors: "Barack Gates, Bill Obama"
        url: "http://roku.content.video.llnw.net/smedia/59021fabe3b645968e382ac726cd6c7b/Gb/siCt-V7LOSU08W_Ve1ByJY5N9emKZeXZvnrH2Yb9c/117_segment_2_twitch__nw_060515.mp4"
        hdposterUrl: "http://s2.content.video.llnw.net/lovs/images-prod/59021fabe3b645968e382ac726cd6c7b/media/decbe34b64ea4ca281dc09997d0f23fd/j5_.540x304.jpeg"
        bookmarkPosition: BookmarksHelper_GetBookmarkData(m.top.content.id)
    })

    m.top.content.AppendChild(item)
end sub
