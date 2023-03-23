function ReadConfigFile(filename) as Object
    configAA = {}
    configStr = ReadAsciiFile(filename)
    configAA = parseJson(configStr)
    return configAA
end function

function GetProductGroups(configAA) as object
    return configAA.groups
end function

function GetPartnerProducts() as object
end function
