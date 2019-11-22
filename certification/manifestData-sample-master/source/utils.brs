'
' Copyright (c) 2016 Roku, Inc. All rights reserved.
'
' File: utils.brs
'

'=======================================================
' Converts the object to a displayable string.
' If obj is invalid, returns <<invalid>>
'
function roToString(obj as Dynamic) as String
    return roToStringInv(obj, "<<invalid>>")
end function


'=======================================================
' Similar to roToString() but if the object is invalid, invalidString is returnd
'
function roToStringInv(obj as Dynamic, invalidString as string) as String
    s = invalidString
    if obj = invalid
        typeStr = invalid
    else
        typeStr = type(obj)
    end if

    if typeStr = invalid
        ' Do nothing, leave s as it is
    else if typeStr = "Boolean"
        if obj
            s = "true"
        else
            s = "false"
        end if
    else if typeStr = "Double"
        s = obj.toStr()
    else if typeStr = "Float"
        s = obj.toStr()
    else if typeStr = "Integer"
        s = obj.toStr()
    else if typeStr = "roArray"
        s = _arrayToStringInv(obj, invalidString)
    else if typeStr = "roAssociativeArray"
        s = _aaToStringInv(obj, invalidString)
    else if typeStr = "roBoolean"
        if obj
            s = "true"
        else
            s = "false"
        endif
    else if typeStr = "roFloat"
        s = obj.toStr()
    else if typeStr = "roInt"
        s = obj.toStr()
    else if typeStr = "roSGNodeEvent"
        event = obj
        node = event.getNode()
        fieldName = event.getField()
        s = typeStr + "[node=" + roToString(node) + ",field=" + fieldName + "]"
    else if typeStr = "roSGNode"
        s = typeStr + ":" + obj.subtype()
        s = s + "["
        if (obj.id <> invalid) and (obj.id <> "") then
            s = s + "id=" + obj.id + ","
        end if
        s = s + "]"
    else if typeStr = "roString"
        s = obj
    else if typeStr = "String"
        s = obj
    else
        s = "instance of " + typeStr
    end if

    return s

end function

function _aaToStringInv(aa as Dynamic, invalidString as String) as String
    if (aa = invalid)
        s = invalidString
    else
        s = "{"
        i = -1
        aa.reset()
        while aa.isNext()
            if len(s) > 250
                s = s + ", ..."
                exit while
            end if

            i = i + 1
            key = aa.next()
            value = aa[key]
            if value = invalid
                valid = "<<invalid>>"
            end if

            if (i > 0)
                s = s + ", "
            end if
            s = s + roToString(key)
            s = s + ":"
            s = s + roToString(value)
        end while
        s = s + "}"
    end if
    return s
end function

function _arrayToStringInv(array as Dynamic, invalidString as String) as String
    if array = invalid
        s = invalidString
    else
        s = "["
        first = true
        for each val in array
            if not first then
                s = s + ","
            end if
            first = false

            s = s + roToStringInv(val, invalidString)

        end for
        s = s + "]"
    end if
    return s
end function
