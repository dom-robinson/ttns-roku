function RegistrySection() as Object
    return CreateObject("roRegistrySection", "ttns")
end function

function ReadStationId() as String
    section = RegistrySection()
    if section.Exists("stationId")
        id = section.Read("stationId")
        if id <> invalid and id <> "" then return id
    end if
    return DefaultStationId()
end function

sub WriteStationId(id as String)
    section = RegistrySection()
    section.Write("stationId", id)
    section.Flush()
end sub
