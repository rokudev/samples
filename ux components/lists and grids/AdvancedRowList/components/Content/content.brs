'********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

function makeMetaData()
    'database(DB) file loaction and its name
    DBdir = "pkg:/Database/"
    DBfile = DBdir + "Database.json"
    'Get artists data structure
    Content = getDatabase(DBdir, DBfile)
    'Convert to content meta-data node  
    ContentNode = ConvertToContentNode(Content)
    'return result by assigning it to top interface
    m.top.content = ContentNode
end function


function ConvertToContentNode(Content as Object) as Object
    ContentNode = createObject("RoSGNode","ContentNode")
    count = 0
    for each key in Content.Keys()
        itemContent = ContentNode.createChild("ContentNode")
        itemContent.title = key
        subItems = Content[key]
        for each subItem in subItems
            subItemContent = itemContent.createChild("ContentNode")
            subItemContent.title = subItem.title
            subItemContent.hdposterurl = subItem.artwork
            
            tracks = subItem.tracks
            for each track in tracks
                trackContent = subItemContent.createChild("ContentNode")
                trackContent.title = track.title
                trackContent.starrating = track.rating
            end for
        end for
    end for
    return ContentNode
end function


function getDatabase(fileDir as string, fileName as String) as object
    'get data from source
    rawText = ReadAsciiFile(fileName)
    
    'Parse JSON string
    dbJson = parseJSON(rawText)
    'Convert data to AA with artist name as keys name
    db = {}
    for each artist in dbJson.artists
        for each album in artist.albums
            album.artwork = PosterUrlsDynamic()
        end for
        db[artist.name] = artist.albums
		print "db[artist.name] = " + artist.name
    end for
    return db
end function

function PosterUrlsDynamic() as Object
    if m.PosterCounter = invalid then
        itemUri = "http://devtools.web.roku.com/samples/images/Portrait_"
        format = ".jpg"
        m.PosterCounter = 0
        m.PosterUrls = []
        for i = 1 to 12
            m.PosterUrls.Push(itemUri + i.toStr() + format)   
        end for 
    else if m.PosterCounter > 10
        m.PosterCounter = 0
    else     
        m.PosterCounter = m.PosterCounter + 1
    end if
    return m.PosterUrls[m.PosterCounter]
end function
