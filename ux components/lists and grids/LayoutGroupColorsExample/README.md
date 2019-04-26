## LayoutGroup Markup

**Node Class Reference: LayoutGroup**

The **LayoutGroup** node class allows you to create evenly-spaced arrangements of multiple screen sub-elements. You can use this to create "tables" of the sub-elements if required for your application.

In `layoutgroupcolorsscene.xml` we create several groups of **Label** and **Rectangle** node paired sub-elements. The first group at the top show the hexadecimal definitions of the fully-saturated primary and secondary colors of the **Rectangle**node. The next two groups show less-saturated colors, and the third group shows different alpha channel effects for the fully-saturated and less-saturated colors. Finally the last group at the bottom shows the two default text colors used for focused and unfocused buttons and lists, set against the corresponding opposite default color:

![img](https://sdkdocs.roku.com/download/attachments/4262981/layoutgroupcolorsdoc.jpg?version=2&modificationDate=1472838094727&api=v2)

Each group consists of a **LayoutGroup** node with **Label** and **Rectangle** node sub-elements as children of a **LayoutGroup** node. The important **LayoutGroup** fields are the `itemSpacings` and `layoutDirection` fields. These are set to `20`and `horiz` respectively for all the groups to evenly space the sub-elements in the group by 20 pixels, arranged horizontally.

```
<LayoutGroup
  id = "fullysaturatedcolors"
  translation = "[ 0, 0 ]"
  itemSpacings = "[20]"
  layoutDirection = "horiz" >

  <Rectangle
    color = "0xEB1010FF"
    height = "40"
    width = "180" >

    <Label
      color = "0x262626FF"
      height = "40"
      width = "180"
      horizAlign = "center"
      vertAlign = "center"
      text = "0xEB1010FF"/>
  ...
...
```

Of course, large groups like this *could* be generated in a loop that automatically creates and/or adds child sub-elements for each **LayoutGroup** node.