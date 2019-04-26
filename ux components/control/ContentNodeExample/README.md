## ContentNode Markup

**Node Class Reference: ContentNode**

The **ContentNode** node class largely replaces associative arrays as a method of storing and passing data items to Roku SceneGraph application screens. The **ContentNode** node class is designed to use the descriptive and playback attributes listed in [**Content Meta-Data**](https://developer.roku.com/docs/developer-program/getting-started/architecture/content-metadata.md), and like all SceneGraph node classes can be extended to use custom attributes not found in **Content Meta-Data**, by creating a custom **<interface>** element with fields for the extended class attributes.

But generally, every attribute you need to describe and play media content items can be found and used in **Content Meta-Data**. Let's look at just how easy it is to get **Content Meta-Data** attributes into a SceneGraph **ContentNode** node.

In the `contentnodescene.xml` component file in `ContentNodeExample.zip`, note that there is a typical SceneGraph XML markup in the **<children>** element, with one difference: there is a **ContentNode** node at the bottom of the SceneGraph:

**ContentNode Markup Example**

```
<ContentNode id = "exampleContentNode" >
  <ContentNode title = "Renderable Nodes" />
  <ContentNode title = "Z-Order/Parent-Child" />
  <ContentNode title = "Animations" />
  <ContentNode title = "Events and Observers" />
  <ContentNode title = "Typography" />
  <ContentNode title = "Control Nodes" />
  <ContentNode title = "Lists and Grids" />
  <ContentNode title = "Dialogs" />
  <ContentNode title = "Widgets" />
  <ContentNode title = "Layout/Groups" />
  <ContentNode title = "Sliding Panels"  />
  <ContentNode title = "Media Playback" />
</ContentNode>
```

This simple **ContentNode** node contains 12 children **ContentNode** nodes, each of which only has one **Content Meta-Data** descriptive attribute: `title` (see [**Content Meta-Data**](https://developer.roku.com/docs/developer-program/getting-started/architecture/content-metadata.md)). However, each child **ContentNode** node could have any number of the attributes listed in **Content Meta-Data**, or even custom attributes for an extended **ContentNode** node set as fields in a **<interface>** element.

The `contentnodescene.xml` component file in `ContentNodeExample.zip` demonstrates how to use BrightScript in the **<script>** element to get the child **ContentNode** node attributes, and use them in an application:

**ContentNode Data Item Usage**

```
sub init()
  m.top.backgroundURI = "pkg:/images/rsgde_bg_hd.jpg"
 
  m.top.setFocus(true)
 
  m.item = m.top.findNode("itemLabel")
 
  m.item.font.size = m.item.font.size+5
 
  example = m.top.findNode("exampleDisplay")
  examplerect = example.boundingRect()
  centerx = (1280 - examplerect.width) / 2
  centery = (720 - examplerect.height) / 2
  example.translation = [ centerx, centery ]
 
  m.content = m.top.findNode("exampleContentNode")
  m.contentitems = m.content.getChildCount()
  m.currentitem = 0
 
  showcontentitem()
end sub
 
sub showcontentitem()
  itemcontent = m.content.getChild(m.currentitem)
  m.item.text = itemcontent.title
end sub
 
function onKeyEvent(key as String, press as Boolean) as Boolean
  if press then
    if key = "OK"
      m.currentitem++
 
      if (m.currentitem = m.contentitems)
        m.currentitem = 0
      end if
 
      showcontentitem()
 
      return true
    end if
  end if
 
  return false
end function
```

This BrightScript code shows the following scene:

![img](https://sdkdocs.roku.com/download/attachments/4262849/contentnodedoc.jpg?version=5&modificationDate=1472836807285&api=v2)

When you press the remote control **OK** key, the next child **ContentNode** node data item is shown. The key to this is using the **getChild()** method, with the `m.currentitem` object as the argument, using the object value as an index into the **ContentNode** node children:

```
sub showcontentitem()`
  itemcontent = m.content.getChild(m.currentitem)
  m.item.text = itemcontent.title
end sub
```

Then the **Content Meta-Data** `title` attribute can be assigned to the `text` field of the `itemLabel` **Label** node created in the **<children>** element. The remainder of the code in the **<script>** element is used to initialize this operation, most notably by using the **getChildCount()** method to determine the number of **ContentNode** node child nodes, and then using the **onKeyEvent()** function to respond to **OK** key presses by cycling through the **ContentNode** node child node index numbers.