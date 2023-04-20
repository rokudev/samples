' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

' Helper function to select only a certain range of content
function select(array as object, first as integer, last as integer) as object
  print "UriHandler.brs - [select]"
  result = []
  for i = first to last
    result.push(array[i])
  end for
  return result
end function

' Helper function to add and set fields of a content node
function AddAndSetFields(node as object, aa as object)
  'This gets called for every content node -- commented out since it's pretty verbose
  'print "UriHandler.brs - [AddAndSetFields]"
  addFields = {}
  setFields = {}
  for each field in aa
    if node.hasField(field)
      setFields[field] = aa[field]
    else
      addFields[field] = aa[field]
    end if
  end for
  node.setFields(setFields)
  node.addFields(addFields)
end function
