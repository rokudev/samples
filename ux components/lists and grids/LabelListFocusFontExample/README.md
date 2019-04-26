## LabelListFocusFontExample

This is another example of a custom **LabelList** node configuration. This example sets the same values as the previous example for the `textHorizAlign`, `vertFocusAnimationStyle`, `drawFocusFeedback`, and `focusedColor` fields. But the example changes the default unfocused text color by setting the `color`field value to `0xAAAA10FF`:

```
<LabelList 
  id = "exampleLabelList" 
  vertFocusAnimationStyle = "floatingFocus" 
  drawFocusFeedback = "false" 
  color = "0xAAAA10FF" 
  focusedColor = "0xEBEB10FF" 
  textHorizAlign = "right" >
  ...
</LabelList>
```


But then the example configures the focused item to have a font size five points larger than the unfocused items. This has to be done in the **<script>** element **init()** function of `labellistfocusfontscene.xml`:

```
<script >
  <![CDATA[
  sub init()
    ...
    example = m.top.findNode("exampleLabelList")
    ...
    example.font = "font:MediumSystemFont"
    example.focusedFont = "font:MediumSystemFont"
    example.focusedFont.size = labellist.font.size+5
    ...
  end sub
  ]]>
</script>
```

And the result is:

![img](https://sdkdocs.roku.com/download/attachments/4266149/labellistfocusfontdoc.jpg?version=1&modificationDate=1498664216139&api=v2)