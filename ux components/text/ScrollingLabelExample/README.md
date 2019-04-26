## ScrollingLabel Markup

**Node Class Reference:** **ScrollingLabel**

The **ScrollingLabel** node class is a specialized version of the **Label** node class designed specifically to automatically scroll long text strings that exceed the width of the node. 

Here's the example markup in the **<children>** element of `scrollinglabelscene.xml`:

```
<ScrollingLabel 
  id = "exampleScrollingLabel" 
  maxWidth = "300" 
  height = "0" 
  font = "font:MediumBoldSystemFont" 
  text = "Roku now offers Nielsen audience measurement software on the Roku...in your channel." 
  horizAlign = "left" 
  vertAlign = "top" />
```

We've shortened the value of the `text` field above, but in the example it is long, much longer than the width of the node as set in the `maxWidth` field. So the **ScrollingLabel** node first displays as much of the first part of the text string as will fit in the width of the node, then scrolls the remainder at a readable rate, and when the end of the string is reached, the process is repeated.

![img](https://sdkdocs.roku.com/download/attachments/4262949/scrollinglabeldoc.jpg?version=4&modificationDate=1472836538714&api=v2)