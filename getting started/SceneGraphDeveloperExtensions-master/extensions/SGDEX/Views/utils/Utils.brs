' Copyright (c) 2018 Roku, Inc. All rights reserved.

' Converts associative array to a node of a given type
' @param inputAA associative array, which will be transformed to roSGNode
' @param nodeType type of node, which will be created
function Utils_AAToNode(inputAA = {} as Object, nodeType = "Node" as String) as Object
    node = createObject("roSGNode", nodeType)

    Utils_forceSetFields(node, inputAA)

    return node
end function


'converts AA to ContentNode
Function Utils_AAToContentNode(inputAA = {} as Object, nodeType = "ContentNode" as String)
    return Utils_AAToNode(inputAA, nodeType)
End Function


' Force sets fields to a given node. If node doesn't have a field, it adds it and then sets
' @param node roSGNode, to which you want to set fields
' @param fieldsToSet associative array of field names and values to be set
sub Utils_forceSetFields(node as Object, fieldsToSet as Object)
    ' if not fw_isSGNode(node) or not fw_isAssociativeArray(fieldsToSet) then return

    existingFields = {}
    newFields = {}

      'AA of node read-only fields for filtering'
    fieldsFilterAA = {
        focusedChild    :   "focusedChild"
        change          :   "change"
        metadata        :   "metadata"
    }

    for each field in fieldsToSet
        if node.hasField(field)
            if NOT fieldsFilterAA.doesExist(field) then existingFields[field] = fieldsToSet[field]
        else
            newFields[field] = fieldsToSet[field]
        end if
    end for

    node.setFields(existingFields)
    node.addFields(newFields)
end sub

'get parent based on subtype
' @param nodeName [String] parent subtype
Function Utils_getParent(nodeName as String, node = GetGlobalAA().top as Object) as Object
    
    while node <> invalid and lCase(node.subtype()) <> lCase(nodeName)
        node = node.getParent()
    end while

    return node
End Function

'get parent based on index
' @param index [Integer] parent subtype
Function Utils_getParentbyIndex(index as Integer, node = GetGlobalAA().top as Object) as Object
    
    while node <> invalid and index > 0 
        node = node.getParent()
        index--
    end while
    
    'if node <> invalid AND index = 0 
    return node
End Function

'converts array of AAs to content node with child content nodes
Function Utils_ContentList2Node(contentList as Object) as Object
    result = createObject("roSGNode","ContentNode")

    for each itemAA in contentList
        item = Utils_AAToContentNode(itemAA, "ContentNode")
        result.appendChild(item)
    end for

    return result
End Function


Function Utils_CopyNode(node as Object) as Object
    if node = invalid then return invalid
    result = createObject("roSGNode","ContentNode")
    Utils_forceSetFields(result, node.getFields())
    return result
End Function


Function Utils_DurationAsString(durationSeconds as Integer) as String
    duration = ""

    if durationSeconds > 0
        date = createObject("roDateTime")
        date.fromSeconds(durationSeconds)

        hours = date.getHours()
        minutes = date.getMinutes()
        seconds = date.getSeconds()

        if hours > 0
            duration = hours.toStr() + tr("h")
        end if

        if minutes > 0
            if isnonemptystr(duration)
                duration = duration + " "
            end if
            duration = duration + minutes.toStr() + tr("m")
        end if

        if hours = 0 AND minutes < 10
            if isnonemptystr(duration)
                duration = duration + " "
            end if
            duration = duration + seconds.toStr() + tr("s")
        end if
    end if

    return duration
End Function



REM ******************************************************
REM Copyright Roku 2011,2012,2013.
REM All Rights Reserved
REM ******************************************************

REM Functions in this file:
REM     isnonemptystr
REM     isnullorempty
REM     strtobool
REM     itostr
REM     strTrim
REM     strTokenize
REM     joinStrings
REM     strReplace
REM     

'******************************************************
'isnonemptystr
'
'Determine if the given object supports the ifString interface
'and returns a string of non zero length
'******************************************************
Function isnonemptystr(obj) As Boolean
    return ((obj <> invalid) AND (GetInterface(obj, "ifString") <> invalid) AND (Len(obj) > 0))
End Function


'******************************************************
'isnullorempty
'
'Determine if the given object is invalid or supports
'the ifString interface and returns a string of zero length
'******************************************************
Function isnullorempty(obj) As Boolean
    return ((obj = invalid) OR (GetInterface(obj, "ifString") = invalid) OR (Len(obj) = 0))
End Function


'******************************************************
'strtobool
'
'Convert string to boolean safely. Don't crash
'Looks for certain string values
'******************************************************
Function strtobool(obj As dynamic) As Boolean
    if obj = invalid return false
    if type(obj) <> "roString" and type(obj) <> "String" return false
    o = strTrim(obj)
    o = Lcase(o)
    if o = "true" return true
    if o = "t" return true
    if o = "y" return true
    if o = "1" return true
    return false
End Function

'******************************************************
'booltostr
'
'Converts a boolean value to a cannonical string value
'******************************************************
Function booltostr(bool As Boolean) As String
    if bool = true then return "true"
    return "false"
End Function

'******************************************************
'itostr
'
'Convert int to string. This is necessary because
'the builtin Stri(x) prepends whitespace
'******************************************************
Function itostr(i As Integer) As String
    str = Stri(i)
    return strTrim(str)
End Function


'******************************************************
'Trim a string
'******************************************************
Function strTrim(str As String) As String
    st=CreateObject("roString")
    st.SetString(str)
    return st.Trim()
End Function


'******************************************************
'Tokenize a string. Return roList of strings
'******************************************************
Function strTokenize(str As String, delim As String) As Object
    st=CreateObject("roString")
    st.SetString(str)
    return st.Tokenize(delim)
End Function

'******************************************************
' Joins an array or list of strings together.
' Performs the opposite function of strTokenize().
'
'@param stringArray An array or list of strings
'@param separator   The separator string to be placed between each string

'@return A single string which is the concatenation of all
'        the strings in the string array/list and spaced apart
'        by the separator string.
'******************************************************
Function joinStrings(stringArray as Object, separator as String) as String
    joinedString = ""

    addedPreviousString = false
    for each stringEntry in stringArray
        if isnonemptystr(stringEntry)
            if addedPreviousString
                joinedString = joinedString + separator
            else
                addedPreviousString = true
            end if
            joinedString = joinedString + stringEntry
        end if
    end for
 
    return joinedString
End Function

'******************************************************
'Replace substrings in a string. Return new string
'******************************************************
Function strReplace(basestr As String, oldsub As String, newsub As String) As String
    newstr = ""

    i = 1
    while i <= Len(basestr)
        x = Instr(i, basestr, oldsub)
        if x = 0 then
            newstr = newstr + Mid(basestr, i)
            exit while
        endif

        if x > i then
            newstr = newstr + Mid(basestr, i, x-i)
            i = x
        endif

        newstr = newstr + newsub
        i = i + Len(oldsub)
    end while

    return newstr
End Function

'TODO: move NormalizeURL() to Http.brs

'
' NWM 130811
' attempt to parse, decode, and re-encode a URL to fix any poorly encoded characters 
' that might cause roURLTransfer.SetURL() to fail
'
function NormalizeURL(url)
  result = url
  
  xfer = CreateObject("roURLTransfer")
  xfer.SetURL(url)
  if xfer.GetURL() = url
    ? "NormalizeURL: SetURL() succeeded, normalization not necessary"
    return result
  end if
  
  bits = url.Tokenize("?")
  if bits.Count() > 1
    result = bits[0] + "?"
    
    pairs = bits[1].Tokenize("&")
    for each pair in pairs
      keyValue = pair.Tokenize("=")

      key = xfer.UnEscape(keyValue[0])
      ? "NormalizeURL: un-escaped key " + key
      key = xfer.Escape(key)
      ? "NormalizeURL: re-escaped key " + key
      
      result = result + key

      if keyValue.Count() > 1
        value = xfer.UnEscape(keyValue[1])
        ? "NormalizeURL: un-escaped value " + value
        value = xfer.Escape(value)
        ? "NormalizeURL: re-escaped value " + value
        
        result = result + "=" + value
      end if

      result = result + "&"
    next
    
    result = result.Left(result.Len() - 1)
    ? "NormalizeURL: normalized URL " + result

    xfer.SetURL(result)
    if xfer.GetURL() = result
      ? "NormalizeURL: SetURL() succeeded with normalized URL"
    else
      ? "NormalizeURL: ***ERROR*** SetURL() failed with normalized URL"
    end if
  end if
  
  return result
end function
