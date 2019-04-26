## ScrollableText Markup

**Node Class Reference: ScrollableText**

The **ScrollableText** node class allows a user to scroll through many pages of text using the **Up**, **Down**, **Fast Forward**, and **Rewind** remote control keys.

The `scrollabletextscene.xml` component file in `ScrollableTextExample.zip` may look like it has a lot of XML markup and BrightScript code, but most of it is there to supply user instructions for the example. The actual example **ScrollableText** node markup in the **<children>** element is:

```
<ScrollableText 
  id = "exampleScrollableText"
  translation = "[ 20, 20 ]"
  font = "font:SmallBoldSystemFont"
  text = "Roku now offers Nielsen audience measurement software on the Roku...FURTHER INFORMATION."
  horizAlign = "left" 
  vertAlign = "top" />
```

This node markup is similar to the several variations of the **Label** node class we've seen before. But for the **ScrollableText** node class, it is assumed you will be supplying a large amount of text, for example, a license agreement. So the **ScrollableText** node supplies a visual slider bar to mark the current position of the text, and automatically responds to **Up** and **Down** remote control key presses by scrolling the text one line up or down, and **Fast Forward** and **Rewind** key presses by scrolling an entire page up or down (a page is the amount of text that fits into the width and height dimensions of the **ScrollableText** node).

After the example **ScrollableText** node is fully constructed with a background and a user instruction bar, it appears as follows:

![img](https://sdkdocs.roku.com/download/attachments/4262949/scrollabletextdoc.jpg?version=3&modificationDate=1472836614856&api=v2)