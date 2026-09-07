' Deep-link helpers. BrightScript AA lookup is case-insensitive.

function AssocLookup(aa as Dynamic, key as String) as String
    if aa = invalid then return ""
    value = aa.Lookup(key)
    return TrimText(value)
end function

function NormalizeContentId(value as String) as String
    return LCase(TrimText(value))
end function

function StationIdForDeepLink(contentId as String) as String
    id = NormalizeContentId(contentId)
    if id = "brighton" or id = "ttns-brighton" then return "brighton"
    if id = "national" or id = "ttns" or id = "ttns-national" or id = "thursday" then return "national"
    if id = "bristol" or id = "ttns-bristol" then return "bristol"
    if id = "listen" or id = "live" or id = "radio" or id = "ttns-fm" then return ReadStationId()
    return ""
end function

function DeepLinkAction(contentId as String, mediaType as String) as String
    id = NormalizeContentId(contentId)
    if id = "" then return "home"
    if id = "gigs" or id = "events" or id = "schedule" then return "gigs"
    if id = "community" or id = "listings" or id = "board" then return "community"
    if id = "promote" or id = "plans" or id = "prices" then return "promote"
    stationId = StationIdForDeepLink(id)
    if stationId = "" then return "home"
    station = GetStation(stationId)
    if station.comingSoon = true then return "home"
    return "play"
end function
