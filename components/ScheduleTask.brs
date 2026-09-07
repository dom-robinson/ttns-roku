sub init()
    m.top.functionName = "exec"
end sub

sub exec()
    m.top.error = ""
    base = TrimText(m.top.apiBaseUrl)
    if base = ""
        m.top.error = "No city listings for this station"
        return
    end if

    days = m.top.days
    if days < 1 then days = 14
    if days > 21 then days = 21

    merged = {}
    lastError = ""

    for offset = 0 to days - 1
        dateKey = LondonDateOffset(offset)
        url = base + "/api/schedule?date=" + dateKey + "&public=true"
        result = FetchJson(url)
        if result.error <> ""
            lastError = result.error
        else
            AbsorbSchedule(merged, result.json)
        end if
    end for

    events = []
    for each id in merged
        events.Push(merged[id])
    end for
    if events.Count() > 1 then events.SortBy("sortKey")
    if events.Count() > 80
        slim = []
        for i = 0 to 79
            slim.Push(events[i])
        end for
        events = slim
    end if

    m.top.events = events
    if events.Count() = 0 and lastError <> ""
        m.top.error = lastError
    end if
    m.top.ready = true
end sub

function FetchJson(url as String) as Object
    port = CreateObject("roMessagePort")
    xfer = CreateObject("roUrlTransfer")
    xfer.SetPort(port)
    xfer.SetUrl(url)
    xfer.RetainBodyOnError(true)
    xfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    xfer.InitClientCertificates()
    xfer.AddHeader("Accept", "application/json")
    xfer.AddHeader("User-Agent", "TTNS-Roku/" + AppVersion())
    xfer.EnableEncodings(true)

    out = { json: invalid, error: "" }
    if not xfer.AsyncGetToString()
        out.error = "Could not start request"
        return out
    end if

    msg = wait(25000, port)
    if msg = invalid
        out.error = "Timed out"
        return out
    end if
    if type(msg) <> "roUrlEvent"
        out.error = "Unexpected response"
        return out
    end if

    code = msg.GetResponseCode()
    body = msg.GetString()
    if code < 200 or code > 299
        out.error = "HTTP " + code.ToStr()
        return out
    end if

    parsed = ParseJson(body)
    if parsed = invalid
        out.error = "Could not read listings"
        return out
    end if
    out.json = parsed
    return out
end function

sub AbsorbBulk(merged as Object, payload as Dynamic)
    if Type(payload) = "roArray"
        for each day in payload
            AbsorbSchedule(merged, day)
        end for
    else
        AbsorbSchedule(merged, payload)
    end if
end sub

sub AbsorbSchedule(merged as Object, payload as Dynamic)
    day = invalid
    if Type(payload) = "roArray" and payload.Count() > 0
        day = payload[0]
    else if Type(payload) = "roAssociativeArray"
        day = payload
    end if
    if day = invalid or day.schedule = invalid then return

    schedule = day.schedule
    for each hourKey in schedule
        block = schedule[hourKey]
        events = []
        if Type(block) = "roArray"
            events = block
        else if Type(block) = "roAssociativeArray" and block.events <> invalid
            events = block.events
        end if

        for each raw in events
            ev = MakePublicEvent(raw)
            if ev <> invalid
                existing = merged[ev.id]
                if existing = invalid
                    merged[ev.id] = ev
                else
                    merged[ev.id] = MergeEvent(existing, ev)
                end if
            end if
        end for
    end for
end sub

function MakePublicEvent(raw as Object) as Object
    if raw = invalid then return invalid
    if raw.is_bumper = true then return invalid

    id = FirstNonEmpty([raw.event_id, raw.id])
    if id = "" then return invalid

    title = FirstNonEmpty([raw.event_name, raw.name, "Event"])
    venue = FirstNonEmpty([raw.venue_name])
    town = FirstNonEmpty([raw.venue_town])
    whenIso = FirstNonEmpty([raw.event_date, raw.date])
    imageUrl = SafeHttpUrl(FirstNonEmpty([raw.image_url, raw.artwork_url]))
    description = TrimText(raw.description)
    genre = TrimText(raw.genre)
    price = TrimText(raw.ticket_price)
    whenLabel = FormatEventWhen(whenIso)
    subtitle = JoinNonEmpty([whenLabel, venue, town], "  -  ")

    return {
        id: id,
        title: title,
        venue: venue,
        town: town,
        whenIso: whenIso,
        whenLabel: whenLabel,
        subtitle: subtitle,
        description: description,
        genre: genre,
        price: price,
        imageUrl: imageUrl,
        sortKey: whenIso
    }
end function

function MergeEvent(a as Object, b as Object) as Object
    return {
        id: a.id,
        title: LongerText(a.title, b.title),
        venue: FirstNonEmpty([a.venue, b.venue]),
        town: FirstNonEmpty([a.town, b.town]),
        whenIso: FirstNonEmpty([a.whenIso, b.whenIso]),
        whenLabel: FirstNonEmpty([a.whenLabel, b.whenLabel]),
        subtitle: FirstNonEmpty([a.subtitle, b.subtitle]),
        description: LongerText(a.description, b.description),
        genre: FirstNonEmpty([a.genre, b.genre]),
        price: FirstNonEmpty([a.price, b.price]),
        imageUrl: FirstNonEmpty([a.imageUrl, b.imageUrl]),
        sortKey: FirstNonEmpty([a.sortKey, b.sortKey])
    }
end function

function LongerText(a as String, b as String) as String
    if Len(TrimText(b)) > Len(TrimText(a)) then return TrimText(b)
    return TrimText(a)
end function

function JoinNonEmpty(values as Object, sep as String) as String
    parts = []
    for each value in values
        text = TrimText(value)
        if text <> "" then parts.Push(text)
    end for
    return JoinStrings(parts, sep)
end function
