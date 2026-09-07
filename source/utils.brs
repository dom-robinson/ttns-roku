function JoinStrings(parts as Object, sep as String) as String
    out = ""
    for i = 0 to parts.Count() - 1
        if i > 0 then out = out + sep
        out = out + parts[i]
    end for
    return out
end function

function PrettyToken(value as String) as String
    if value = invalid or value = "" then return ""
    cleaned = value.Replace("_", " ")
    parts = cleaned.Split(" ")
    out = []
    for each part in parts
        if part <> ""
            out.Push(UCase(Left(part, 1)) + Mid(part, 2))
        end if
    end for
    return JoinStrings(out, " ")
end function

function TrimText(value as Dynamic) as String
    if value = invalid then return ""
    text = "" + value
    return text.Trim()
end function

function FirstNonEmpty(values as Object) as String
    for each value in values
        text = TrimText(value)
        if text <> "" then return text
    end for
    return ""
end function

function ClampText(value as String, maxLen as Integer) as String
    text = TrimText(value)
    if Len(text) <= maxLen then return text
    return Left(text, maxLen - 1) + "..."
end function

function FormatEventWhen(iso as String) as String
    text = TrimText(iso)
    if text = "" then return ""
    datePart = Left(text, 10)
    timePart = ""
    if Len(text) >= 16 then timePart = Mid(text, 12, 5)

    parts = datePart.Split("-")
    if parts.Count() <> 3 then return text

    months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    monthIndex = parts[1].ToInt()
    monthName = ""
    if monthIndex >= 1 and monthIndex <= 12 then monthName = months[monthIndex - 1]

    dayNum = parts[2].ToInt()
    day = dayNum.ToStr()
    label = day + " " + monthName
    if timePart <> "" and timePart <> "00:00" then label = label + "  " + timePart
    return label
end function

function FormatIsoDate(iso as String) as String
    text = Left(TrimText(iso), 10)
    return text
end function

function LondonDateOffset(daysAhead as Integer) as String
    now = CreateObject("roDateTime")
    now.ToLocalTime()
    seconds = now.AsSeconds() + (daysAhead * 86400)
    later = CreateObject("roDateTime")
    later.FromSeconds(seconds)
    iso = later.ToISOString()
    return Left(iso, 10)
end function

function SafeHttpUrl(value as String) as String
    text = TrimText(value)
    if text = "" then return ""
    lower = LCase(text)
    if Left(lower, 8) = "https://" or Left(lower, 7) = "http://" then return text
    return ""
end function

function Pad2(n as Integer) as String
    if n < 10 then return "0" + n.ToStr()
    return n.ToStr()
end function

function IsoDateOnly(iso as String) as String
    return Left(TrimText(iso), 10)
end function

function TodayDate() as String
    now = CreateObject("roDateTime")
    now.ToLocalTime()
    return Left(now.ToISOString(), 10)
end function

function AddDaysToIsoDate(isoDate as String, days as Integer) as String
    dt = CreateObject("roDateTime")
    dt.FromISO8601String(isoDate + "T12:00:00Z")
    later = CreateObject("roDateTime")
    later.FromSeconds(dt.AsSeconds() + (days * 86400))
    return Left(later.ToISOString(), 10)
end function

function StartOfWeekDate() as String
    now = CreateObject("roDateTime")
    now.ToLocalTime()
    dow = now.GetDayOfWeek()
    seconds = now.AsSeconds() - (dow * 86400)
    weekStart = CreateObject("roDateTime")
    weekStart.FromSeconds(seconds)
    weekStart.ToLocalTime()
    return Left(weekStart.ToISOString(), 10)
end function

function EndOfMonthDate() as String
    now = CreateObject("roDateTime")
    now.ToLocalTime()
    yearNum = now.GetYear()
    monthNum = now.GetMonth()
    if monthNum = 12 then return yearNum.ToStr() + "-12-31"
    nextMonth = monthNum + 1
    firstNext = yearNum.ToStr() + "-" + Pad2(nextMonth) + "-01"
    return AddDaysToIsoDate(firstNext, -1)
end function

function WhenMatchesFilter(whenIso as String, filterId as String) as Boolean
    if filterId = "" or filterId = "all" then return true
    whenDate = IsoDateOnly(whenIso)
    if whenDate = "" then return false
    today = TodayDate()
    weekStart = StartOfWeekDate()
    nextWeek = AddDaysToIsoDate(weekStart, 7)
    weekAfter = AddDaysToIsoDate(weekStart, 14)
    monthEnd = EndOfMonthDate()
    if filterId = "this-week"
        if whenDate >= weekStart and whenDate < nextWeek then return true
        return false
    else if filterId = "next-week"
        if whenDate >= nextWeek and whenDate < weekAfter then return true
        return false
    else if filterId = "this-month"
        if whenDate >= today and whenDate <= monthEnd then return true
        return false
    end if
    return true
end function

function WhenFilterLabel(filterId as String) as String
    if filterId = "this-week" then return "This week"
    if filterId = "next-week" then return "Next week"
    if filterId = "this-month" then return "This month"
    return "All upcoming"
end function

function TextPixelWidth(text as String, fontSize as Integer, bold as Boolean) as Integer
    if text = "" then return 0
    factor = 0.52
    if bold = true then factor = 0.58
    return Int(Len(text) * fontSize * factor)
end function

function CssToRokuColor(css as String) as String
    text = TrimText(css)
    if text = "" then return "0x00FF00FF"
    if Left(text, 1) = "#" then text = Mid(text, 2)
    if Len(text) = 6 then return "0x" + UCase(text) + "FF"
    return "0x00FF00FF"
end function

function DiscordDisplayText(raw as String) as String
    text = TrimText(raw)
    if text = "" then return ""
    emojiRe = CreateObject("roRegex", "<a?:([A-Za-z0-9_]+):([0-9]+)>", "")
    text = emojiRe.ReplaceAll(text, "")
    mentionRe = CreateObject("roRegex", "<@!?([0-9]+)>", "")
    text = mentionRe.ReplaceAll(text, "")
    shortRe = CreateObject("roRegex", ":([A-Za-z0-9_]+):", "")
    text = shortRe.ReplaceAll(text, "")
    urlRe = CreateObject("roRegex", "https?://\S+", "")
    text = urlRe.ReplaceAll(text, "")
    spaceRe = CreateObject("roRegex", "\s+", "")
    text = spaceRe.ReplaceAll(text, " ")
    return TrimText(text)
end function

function DiscordCustomEmojiUrls(raw as String) as Object
    urls = []
    text = TrimText(raw)
    if text = "" then return urls
    emojiRe = CreateObject("roRegex", "<a?:([A-Za-z0-9_]+):([0-9]+)>", "")
    matches = emojiRe.MatchAll(text)
    if matches = invalid then return urls
    for each match in matches
        if match <> invalid and match.Count() >= 3
            emojiId = match[2]
            urls.Push("https://cdn.discordapp.com/emojis/" + emojiId + ".png")
        end if
    end for
    return urls
end function

function LooksLikeImageUrl(url as String) as Boolean
    lower = LCase(TrimText(url))
    if lower = "" then return false
    q = Instr(lower, "?")
    if q > 0 then lower = Left(lower, q - 1)
    if Right(lower, 4) = ".jpg" then return true
    if Right(lower, 5) = ".jpeg" then return true
    if Right(lower, 4) = ".png" then return true
    if Right(lower, 4) = ".gif" then return true
    if Right(lower, 5) = ".webp" then return true
    return false
end function

function FirstAttachmentUrl(raw as Object) as String
    if raw = invalid then return ""
    atts = raw.attachments
    if atts <> invalid and atts.Count() > 0
        first = atts[0]
        if first <> invalid
            url = SafeHttpUrl(FirstNonEmpty([first.proxy_url, first.url]))
            if url <> "" then return url
        end if
    end if
    embeds = raw.embeds
    if embeds <> invalid and embeds.Count() > 0
        emb = embeds[0]
        if emb <> invalid
            thumb = emb.thumbnail
            if thumb <> invalid
                url = SafeHttpUrl(FirstNonEmpty([thumb.proxy_url, thumb.url]))
                if url <> "" then return url
            end if
            url = SafeHttpUrl(TrimText(emb.url))
            if LooksLikeImageUrl(url) = true then return url
        end if
    end if
    return ""
end function

function TwemojiUrlForIndex(idx as Integer) as String
    hexes = ["1f44d", "2764-fe0f", "1f602", "1f525", "1f389", "2b50", "1f4af", "1f44f"]
    if idx < 0 then return ""
    if idx >= hexes.Count() then return ""
    return "https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/" + hexes[idx] + ".png"
end function

function CollectChatEmojiUrls(raw as String, emojiMap as Object) as Object
    urls = []
    seen = {}
    custom = DiscordCustomEmojiUrls(raw)
    for each url in custom
        if url <> "" and seen[url] = invalid
            seen[url] = true
            urls.Push(url)
        end if
    end for
    if emojiMap <> invalid
        for each key in emojiMap
            if key <> "" and Instr(raw, key) >= 0
                url = emojiMap[key]
                if url <> "" and seen[url] = invalid
                    seen[url] = true
                    urls.Push(url)
                end if
            end if
        end for
    end if
    if urls.Count() <= 4 then return urls
    slim = []
    i = 0
    while i < 4
        slim.Push(urls[i])
        i = i + 1
    end while
    return slim
end function

function StripMappedEmojiText(text as String, emojiMap as Object) as String
    out = TrimText(text)
    if out = "" then return ""
    if emojiMap <> invalid
        for each key in emojiMap
            if key <> "" then out = out.Replace(key, "")
        end for
    end if
    spaceRe = CreateObject("roRegex", "\s+", "")
    out = spaceRe.ReplaceAll(out, " ")
    return TrimText(out)
end function
