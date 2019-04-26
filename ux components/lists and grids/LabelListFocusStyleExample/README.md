## LabelListFocusStyle 

This example sets a few custom field values to change the text alignment, focused color, and focus style of the list:

| Custom Field Name         | Set To        | Result from Custom Setting                                   |
| :------------------------ | :------------ | :----------------------------------------------------------- |
| `vertFocusAnimationStyle` | floatingFocus | Changes how focus moves up and down the list, and what happens when the end or top of the list is reached |
| `drawFocusFeedback`       | false         | Does not display the default focus indicator graphic         |
| `focusedColor`            | 0xEBEB10FF    | Changes the focused text color from the default inverse color |
| `textHorizAlign`          | right         | Aligns the right edges of the item strings rather than the default left alignment |


From the above Custom Fields and Settings, we derive the following code sample: 

```
<LabelList 
  id = "exampleLabelList" 
  vertFocusAnimationStyle = "floatingFocus" 
  drawFocusFeedback = "false" 
  focusedColor = "0xEBEB10FF" 
  textHorizAlign = "right" >
  ...
</LabelList>
```

And the result is: 

![img](https://sdkdocs.roku.com/download/attachments/4266149/labellistfocusstyledoc.jpg?version=1&modificationDate=1498664216132&api=v2)