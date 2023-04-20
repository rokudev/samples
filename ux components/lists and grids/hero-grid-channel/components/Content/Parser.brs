' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

sub init()
  print "Parser.brs - [init]"
end sub

' Parses the response string as XML
' The parsing logic will be different for different RSS feeds
sub parseResponse()
  print "Parser.brs - [parseResponse]"
  str = m.top.response.content
  num = m.top.response.num

  if str = invalid return
  xml = CreateObject("roXMLElement")
  ' Return invalid if string can't be parsed
  if not xml.Parse(str) return

  if xml <> invalid then
    xml = xml.getchildelements()
    responsearray = xml.getchildelements()
  end if

  result = []
  'responsearray - <channel>'
  for each xmlitem in responsearray
    ' <title>, <link>, <description>, <pubDate>, <image>, and lots of <item>'s
    if xmlitem.getname() = "item"
      ' All things related to one item (title, link, description, media:content, etc.)
      itemaa = xmlitem.getchildelements()
      if itemaa <> invalid
        item = {}
        ' Get all <item> attributes
        for each xmlitem in itemaa
          item[xmlitem.getname()] = xmlitem.gettext()
          if xmlitem.getname() = "media:content"
            item.stream = {url : xmlitem.url}
            item.url = xmlitem.getattributes().url
            item.streamformat = "mp4"
            'Add subtitles here - example below
            'item.subtitleConfig = { Trackname: "pkg:/source/CraigVenter.srt" }

            mediacontent = xmlitem.getchildelements()
            for each mediacontentitem in mediacontent
              if mediacontentitem.getname() = "media:thumbnail"
                item.hdposterurl = mediacontentitem.getattributes().url
                item.hdbackgroundimageurl = mediacontentitem.getattributes().url
                item.uri = mediacontentitem.getattributes().url
              end if
            end for
          end if
        end for
        result.push(item)
      end if
    end if
  end for

  'For the 3 rows before the "grid"
  list = [
    {
        Title:"Big Hits"
        ContentList : result
    }
    {
        Title:"Action"
        ContentList : result
    }
    {
        Title:"Drama"
        ContentList : result
    }
  ]

  'Logic for creating a "row" vs. a "grid"
  contentAA = {}
  content = invalid
  if num = 3
    content = createGrid(result)
  else
    content = createRow(list, num)
  end if

  'Add the newly parsed content row/grid to the cache until everything is ready
  if content <> invalid
    contentAA[num.toStr()] = content
    if m.UriHandler = invalid then m.UriHandler = m.top.getParent()
    m.UriHandler.contentCache.addFields(contentAA)
  else
    print "Error: content was invalid"
  end if
end sub

'Create a row of content
function createRow(list as object, num as Integer)
  print "Parser.brs - [createRow]"
  Parent = createObject("RoSGNode", "ContentNode")
  row = createObject("RoSGNode", "ContentNode")
  row.Title = list[num].Title
  for each itemAA in list[num].ContentList
    item = createObject("RoSGNode","ContentNode")
    AddAndSetFields(item, itemAA)
    row.appendChild(item)
  end for
  Parent.appendChild(row)
  return Parent
end function

'Create a grid of content - simple splitting of a feed to different rows
'with the title of the row hidden.
'Set the for loop parameters to adjust how many columns there
'should be in the grid.
function createGrid(list as object)
  print "Parser.brs - [createGrid]"
  Parent = createObject("RoSGNode","ContentNode")
  for i = 0 to list.count() step 4
    row = createObject("RoSGNode","ContentNode")
    if i = 0
      row.Title = "The Grid"
    end if
    for j = i to i + 3
      if list[j] <> invalid
        item = createObject("RoSGNode","ContentNode")
        AddAndSetFields(item,list[j])
        row.appendChild(item)
      end if
    end for
    Parent.appendChild(row)
  end for
  return Parent
end function
