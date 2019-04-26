## MarkupList Markup

**Node Class Reference:** **MarkupList**

The **MarkupList** node class provides a customizable list that can include multiple graphic images and labels, in virtually any type of design and configuration for the list items.

For example, `MarkupListExample.zip` is a list where each item has two graphic images (an icon and a small poster image), a label, and a custom underline focus indicator:

![img](https://sdkdocs.roku.com/download/attachments/4266153/markuplistdoc.jpg?version=1&modificationDate=1498664357873&api=v2)

The method to configure a custom list like this is to have a separate component definition of the appearance and behavior of the list items. The name of this component is set as the `itemComponentName` field value of the **MarkupList** node. Then as the user moves focus to an individual item in the list, the appearance and behavior of the item is configured according to the item component scripting. In the example, as each item is focused, the red underline focus indicator appears, along with the small poster image. The icon, label, and small poster image for each item are contained in the **ContentNode** node set as the `content` field value of the **MarkupList** node, the same way the graphic images and other content meta-data are set in [**PosterGrid Markup**](https://github.com/rokudev/samples/tree/master/ux%20components/screen%20elements/renderable%20nodes).

In `markuplistscene.xml`, we define the basic dimensions and configuration of the **MarkupList** node in the **<children>** element in a way that is similar to how lists and grids were defined in [**LabelList Markup**](https://github.com/rokudev/samples/tree/master/ux%20components/lists%20and%20grids) and [**PosterGrid Markup**](https://github.com/rokudev/samples/tree/master/ux%20components/screen%20elements/renderable%20nodes). In addition to the `itemComponentName` field where we set name of the component with the list item configuration, we set the `itemSize` field (similar to the `basePosterSize` field of a **PosterGrid** node) and the `itemSpacing` field (identical to the **PosterGrid** node `itemSpacing` field):

```
<children >
  <MarkupList 
    id = "exampleMarkupList" 
    itemComponentName = "MarkupListItem" 
    itemSize = "[ 586, 154 ]" 
    itemSpacing = "[ 0, 10 ]" 
    drawFocusFeedback = "false" 
    vertFocusAnimationStyle = "floatingFocus" />
</children>
```

Then we set the `drawFocusFeedback` field to false, since we will be using a custom underline focus indicator, and set `vertFocusAnimationStyle` to `floatingFocus` (again, these fields are the same as in the **LabelList** node and several other list and grid nodes).

Now let's look at `markuplistitem.xml`, which is the list item configuration component file:

**MarkupList Item Component Example** 
```
<component name = "MarkupListItem" extends = "Group" >
 
  <interface>
    <field id = "itemContent" type = "node" onChange = "showcontent" />
    <field id = "focusPercent" type = "float" onChange = "showfocus" />
  </interface>
 
  <script type = "text/brightscript" >
 
    <![CDATA[
 
    sub init()
      m.top.id = "markuplistitem"
      m.itemicon = m.top.findNode("itemIcon")
      m.itemlabel = m.top.findNode("itemLabel")
      m.itemcursor = m.top.findNode("itemcursor")
      m.itemposter = m.top.findNode("itemPoster")
    end sub
 
    sub showcontent()
      itemcontent = m.top.itemContent
      m.itemicon.uri = itemcontent.url
      m.itemlabel.text = itemcontent.title
      m.itemposter.uri = itemcontent.HDPosterUrl
    end sub
 
    sub showfocus()
      m.itemcursor.opacity = m.top.focusPercent
      m.itemposter.opacity = m.top.focusPercent
    end sub
 
    ]]>
 
  </script>
 
  <children>
 
    <Poster
      id = "itemIcon"
      translation = "[ 0, 114 ]"
      width = "53"
      height = "30" />
 
    <Label
      id = "itemLabel"
      translation = "[ 60, 120 ]" />
 
    <Rectangle
      id = "itemcursor"
      translation = "[ 0, 148 ]"
      width = "596"
      height = "6"
      color = "0xEB3333FF"
      opacity = "0.0" />
 
    <Poster
      id = "itemPoster"
      translation = "[ 334, 0 ]"
      width = "256"
      height = "144"
      opacity = "0.0" />
 
  </children>
 
</component>
```

The **<children>** element of `markuplistitem.xml` contains the renderable nodes that will be in each list item. It's a typical markup for renderable nodes as described in [**Renderable Node Markup**](https://sdkdocs.roku.com/display/sdkdoc/Renderable+Node+Markup), except for a couple of things. Note that we don't supply a `uri` field value for the **Poster** nodes, or a text field value for the **Label** node. We do provide an ID for each renderable node, because we intend to supply the missing field values in the **<script>** element using BrightScript.

As the **ContentNode** node for the list is set, and a user moves focus to an item in the list, the **<interface>** element fields are updated by the **MarkupList** node to the value for that item. So to script the custom appearance and behavior of the list items, we set observers on the relevant **<interface>** fields using the `onChange` attribute to identify the callback functions triggered by the field value change:

```
<interface> 
  <field id = "itemContent" type = "node" onChange = "showcontent" />
  <field id = "focusPercent" type = "float" onChange = "showfocus" />
</interface>
```

When the **ContentNode** node for the list is set, the `itemContent` field value change triggers the `showcontent()` callback function, and `focusPercent` field value change triggers the `showfocus()` callback function. The `showcontent()` callback function sets the URL of the each item icon and the small poster image, and the text of the item label, according the attributes in the child **ContentNode** node for the item:

```
sub showcontent()
  itemcontent = m.top.itemContent
  m.itemicon.uri = itemcontent.url
  m.itemlabel.text = itemcontent.title
  m.itemposter.uri = itemcontent.HDPosterUrl
end sub
```

Then the `showfocus()` callback function makes visible the custom red underline focus indicator and the small poster image when the item is focused:

```
sub showfocus()
  m.itemcursor.opacity = m.top.focusPercent
  m.itemposter.opacity = m.top.focusPercent
end sub
```

The `showfocus()` callback function makes use of the `focusPercent` field value, which varies from 0 to 1.0 as focus moves to the item, and from 1.0 to 0 as focus leaves the item. Since this varying value has the identical range as the `key` field range of an **Animation** node (see [**Animation Markup**](https://github.com/rokudev/samples/tree/master/ux%20components/animation), this field value can be used as an animation "key" to smoothly "fade" in and out an item element as focus moves to and from the item. In this example, we key the cursor and small poster image opacity to the value of the `focusPercent` field.

This method of creating a custom list or grid item appearance is used in the **MarkupGrid** and **RowList** nodes too, so spend a little time now to understand how it works... 