function StationCatalog() as Object
    return [
        {
            id: "brighton",
            name: "Brighton",
            shortName: "Brighton",
            streamUrl: "https://listen-ttns.sharp-stream.com/ttns-brighton.mp3",
            apiBaseUrl: "https://brighton.ttns.fm",
            siteUrl: "https://brighton.ttns.fm",
            hasListings: true,
            selectable: true,
            comingSoon: false
        },
        {
            id: "bristol",
            name: "Bristol",
            shortName: "Bristol",
            streamUrl: "https://listen-ttns.sharp-stream.com/ttns-bristol.mp3",
            apiBaseUrl: "https://bristol.ttns.fm",
            siteUrl: "https://bristol.ttns.fm",
            hasListings: true,
            selectable: true,
            comingSoon: true
        },
        {
            id: "national",
            name: "The Thursday Night Show",
            shortName: "National",
            streamUrl: "https://listen.thethursdaynightshow.com/live",
            apiBaseUrl: "",
            siteUrl: "https://www.ttns.fm",
            hasListings: false,
            selectable: true,
            comingSoon: false
        }
    ]
end function

function DefaultStationId() as String
    return "brighton"
end function

function GetStation(id as String) as Object
    for each station in StationCatalog()
        if station.id = id then return station
    end for
    return GetStation(DefaultStationId())
end function

function GetSelectedStation() as Object
    return GetStation(ReadStationId())
end function

function CityForListings(station as Object) as Object
    if station <> invalid and station.hasListings = true then return station
    return GetStation("brighton")
end function

function CycleLiveStationId(currentId as String, direction as Integer) as String
    live = []
    for each station in StationCatalog()
        if station.selectable = true and station.comingSoon <> true
            live.Push(station)
        end if
    end for
    count = live.Count()
    if count = 0 then return currentId
    idx = 0
    i = 0
    for each station in live
        if station.id = currentId then idx = i
        i = i + 1
    end for
    nextIdx = idx + direction
    while nextIdx < 0
        nextIdx = nextIdx + count
    end while
    while nextIdx >= count
        nextIdx = nextIdx - count
    end while
    chosen = live[nextIdx]
    return chosen.id
end function
