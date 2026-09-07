sub init()
    m.top.functionName = "exec"
end sub

sub exec()
    m.top.error = ""
    base = TrimText(m.top.apiBaseUrl)
    if base = ""
        m.top.error = "Pick Brighton or Bristol for community listings"
        return
    end if

    listingsResult = FetchJson(base + "/api/community/listings?limit=40")
    actsResult = FetchJson(base + "/api/community/acts?limit=40")

    items = []
    if actsResult.json <> invalid then AppendActs(items, actsResult.json)
    if listingsResult.json <> invalid then AppendListings(items, listingsResult.json)

    if items.Count() > 60
        slim = []
        for i = 0 to 59
            slim.Push(items[i])
        end for
        items = slim
    end if
    m.top.items = items
    if items.Count() = 0
        if listingsResult.error <> ""
            m.top.error = listingsResult.error
        else if actsResult.error <> ""
            m.top.error = actsResult.error
        end if
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
        out.error = "Could not read community"
        return out
    end if
    out.json = parsed
    return out
end function

sub AppendActs(items as Object, payload as Object)
    acts = []
    if payload.acts <> invalid then acts = payload.acts
    for each raw in acts
        if raw <> invalid and raw.status = "active"
            id = TrimText(raw.id)
            title = FirstNonEmpty([raw.act_name, "Act / DJ"])
            kindLabel = "Act / DJ"
            categoryId = "acts"
            if raw.profile_kind = "directory"
                kindLabel = "Directory"
                categoryId = "directory"
            end if
            items.Push({
                id: id,
                kind: "act",
                title: title,
                category: kindLabel,
                categoryId: categoryId,
                subtitle: JoinNonEmpty([kindLabel, TrimText(raw.genres), TrimText(raw.home_city)], "  -  "),
                body: TrimText(raw.description),
                imageUrl: SafeHttpUrl(TrimText(raw.image_url)),
                webPath: "/community/acts"
            })
        end if
    end for
end sub

sub AppendListings(items as Object, payload as Object)
    listings = []
    if payload.listings <> invalid then listings = payload.listings
    for each raw in listings
        if raw <> invalid and raw.status = "active"
            id = TrimText(raw.id)
            category = TrimText(raw.category)
            items.Push({
                id: id,
                kind: "listing",
                title: FirstNonEmpty([raw.title, "Listing"]),
                category: CategoryLabel(category),
                categoryId: category,
                subtitle: JoinNonEmpty([CategoryLabel(category), TrimText(raw.asking_price), TrimText(raw.home_city)], "  -  "),
                body: TrimText(raw.body),
                imageUrl: SafeHttpUrl(TrimText(raw.image_url)),
                webPath: "/community/listing/" + id
            })
        end if
    end for
end sub

function JoinNonEmpty(values as Object, sep as String) as String
    parts = []
    for each value in values
        text = TrimText(value)
        if text <> "" then parts.Push(text)
    end for
    return JoinStrings(parts, sep)
end function
