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

function EstimateWrappedHeight(text as String, width as Integer, lineH as Integer, maxLines as Integer) as Integer
    raw = TrimText(text)
    if raw = "" then return 0
    per = Int(width / 14)
    if per < 16 then per = 16
    lines = 0
    chunks = raw.Split(Chr(10))
    for each chunk in chunks
        n = Len(chunk)
        if n <= 0
            lines = lines + 1
        else
            add = Int((n + per - 1) / per)
            if add < 1 then add = 1
            lines = lines + add
        end if
    end for
    if lines < 1 then lines = 1
    if lines > maxLines then lines = maxLines
    return lines * lineH
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
    factor = 0.64
    if bold = true then factor = 0.70
    return Int(Len(text) * fontSize * factor)
end function

function CountTextLines(text as String) as Integer
    raw = TrimText(text)
    if raw = "" then return 0
    n = 1
    i = 1
    total = Len(raw)
    while i <= total
        if Mid(raw, i, 1) = Chr(10) then n = n + 1
        i = i + 1
    end while
    return n
end function

function BreakLongWord(word as String, width as Integer, fontSize as Integer, bold as Boolean) as Object
    chunks = []
    if word = "" then return chunks
    current = ""
    i = 1
    total = Len(word)
    while i <= total
        ch = Mid(word, i, 1)
        trial = current + ch
        if current <> "" and TextPixelWidth(trial, fontSize, bold) > width
            chunks.Push(current)
            current = ch
        else
            current = trial
        end if
        i = i + 1
    end while
    if current <> "" then chunks.Push(current)
    return chunks
end function

function WrapTextToWidth(text as String, width as Integer, fontSize as Integer, bold as Boolean) as String
    raw = TrimText(text)
    if raw = "" then return ""
    if width < 80 then width = 80
    words = raw.Split(" ")
    lines = []
    current = ""
    for each word in words
        if word <> ""
            trial = word
            if current <> "" then trial = current + " " + word
            if TextPixelWidth(trial, fontSize, bold) <= width
                current = trial
            else
                if current <> "" then lines.Push(current)
                if TextPixelWidth(word, fontSize, bold) <= width
                    current = word
                else
                    chunks = BreakLongWord(word, width, fontSize, bold)
                    n = chunks.Count()
                    if n > 1
                        i = 0
                        while i < n - 1
                            lines.Push(chunks[i])
                            i = i + 1
                        end while
                        current = chunks[n - 1]
                    else if n = 1
                        current = chunks[0]
                    else
                        current = ""
                    end if
                end if
            end if
        end if
    end for
    if current <> "" then lines.Push(current)
    if lines.Count() > 10
        slim = []
        i = 0
        while i < 10
            slim.Push(lines[i])
            i = i + 1
        end while
        lines = slim
    end if
    return JoinStrings(lines, Chr(10))
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
    hexes = ["1f44d", "2764", "1f602", "1f525", "1f389", "2b50", "1f4af", "1f44f"]
    if idx < 0 then return ""
    if idx >= hexes.Count() then return ""
    return "https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/" + hexes[idx] + ".png"
end function

function UsableDiscordEmojiId(value as Dynamic) as String
    if value = invalid then return ""
    text = TrimText(value)
    if text = "" then return ""
    lower = LCase(text)
    if lower = "invalid" or lower = "null" or lower = "undefined" then return ""
    re = CreateObject("roRegex", "^[0-9]+$", "")
    if re.IsMatch(text) = true then return text
    return ""
end function

function IsAsciiToken(value as String) as Boolean
    text = TrimText(value)
    if text = "" then return false
    re = CreateObject("roRegex", "^[A-Za-z0-9_]+$", "")
    return re.IsMatch(text)
end function

function ToHexLower(n as Integer) as String
    digits = "0123456789abcdef"
    if n <= 0 then return "0"
    out = ""
    value = n
    while value > 0
        remv = value mod 16
        out = Mid(digits, remv + 1, 1) + out
        value = Int(value / 16)
    end while
    return out
end function

function DecodeAt(text as String, i as Integer) as Object
    v = Asc(Mid(text, i, 1))
    n = Len(text)
    if v >= 55296 and v <= 56319 and i < n
        v2 = Asc(Mid(text, i + 1, 1))
        if v2 >= 56320 and v2 <= 57343
            cp = 65536 + ((v - 55296) * 1024) + (v2 - 56320)
            return { cp: cp, nxt: i + 2 }
        end if
    end if
    if v < 128 or v >= 256 then return { cp: v, nxt: i + 1 }
    if v >= 240 and i + 3 <= n
        b2 = Asc(Mid(text, i + 1, 1))
        b3 = Asc(Mid(text, i + 2, 1))
        b4 = Asc(Mid(text, i + 3, 1))
        cp = ((v - 240) * 262144) + ((b2 - 128) * 4096) + ((b3 - 128) * 64) + (b4 - 128)
        return { cp: cp, nxt: i + 4 }
    end if
    if v >= 224 and i + 2 <= n
        b2 = Asc(Mid(text, i + 1, 1))
        b3 = Asc(Mid(text, i + 2, 1))
        cp = ((v - 224) * 4096) + ((b2 - 128) * 64) + (b3 - 128)
        return { cp: cp, nxt: i + 3 }
    end if
    if v >= 192 and i + 1 <= n
        b2 = Asc(Mid(text, i + 1, 1))
        cp = ((v - 192) * 64) + (b2 - 128)
        return { cp: cp, nxt: i + 2 }
    end if
    return { cp: v, nxt: i + 1 }
end function

function IsEmojiCode(cp as Integer) as Boolean
    if cp >= 127462 and cp <= 127487 then return true
    if cp >= 127744 and cp <= 129791 then return true
    if cp >= 9728 and cp <= 10175 then return true
    if cp >= 126976 and cp <= 127487 then return true
    if cp = 169 or cp = 174 then return true
    if cp = 8482 then return true
    return false
end function

function IsEmojiJoiner(cp as Integer) as Boolean
    if cp = 8205 then return true
    if cp = 65039 then return true
    if cp >= 127995 and cp <= 127999 then return true
    return false
end function

function TwemojiUrlFromCodepoints(cps as Object) as String
    if cps = invalid or cps.Count() = 0 then return ""
    parts = []
    for each cp in cps
        if cp <> 65039 then parts.Push(ToHexLower(cp))
    end for
    if parts.Count() = 0 then return ""
    return "https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/" + JoinStrings(parts, "-") + ".png"
end function

function TwemojiUrlFromText(text as String) as String
    raw = TrimText(text)
    if raw = "" then return ""
    cps = []
    i = 1
    n = Len(raw)
    while i <= n
        piece = DecodeAt(raw, i)
        cps.Push(piece.cp)
        i = piece.nxt
    end while
    return TwemojiUrlFromCodepoints(cps)
end function

function UnicodeEmojiUrlsFromText(text as String) as Object
    urls = []
    raw = TrimText(text)
    if raw = "" then return urls
    i = 1
    n = Len(raw)
    while i <= n
        piece = DecodeAt(raw, i)
        cp = piece.cp
        i = piece.nxt
        if IsEmojiCode(cp) = true
            seq = [cp]
            while i <= n
                nxtp = DecodeAt(raw, i)
                if IsEmojiJoiner(nxtp.cp) = true or IsEmojiCode(nxtp.cp) = true
                    seq.Push(nxtp.cp)
                    i = nxtp.nxt
                else
                    exit while
                end if
            end while
            url = TwemojiUrlFromCodepoints(seq)
            if url <> "" then urls.Push(url)
        end if
    end while
    return urls
end function

function ReactionEmojiUrls(raw as Object) as Object
    urls = []
    if raw = invalid then return urls
    reactions = raw.reactions
    if reactions = invalid then return urls
    for each item in reactions
        if item <> invalid
            emoji = item.emoji
            if emoji = invalid then emoji = item
            if emoji <> invalid
                emojiId = UsableDiscordEmojiId(emoji.id)
                if emojiId <> ""
                    ext = ".png"
                    if emoji.animated = true then ext = ".gif"
                    urls.Push("https://cdn.discordapp.com/emojis/" + emojiId + ext)
                else
                    url = TwemojiUrlFromText(TrimText(emoji.name))
                    if url <> "" then urls.Push(url)
                end if
            end if
        end if
    end for
    return urls
end function

function CollectChatEmojiUrls(rawText as String, rawMsg as Object, emojiMap as Object) as Object
    urls = []
    seen = {}
    sources = []
    custom = DiscordCustomEmojiUrls(rawText)
    for each url in custom
        sources.Push(url)
    end for
    react = ReactionEmojiUrls(rawMsg)
    for each url in react
        sources.Push(url)
    end for
    uni = UnicodeEmojiUrlsFromText(rawText)
    for each url in uni
        sources.Push(url)
    end for
    if emojiMap <> invalid
        for each key in emojiMap
            if key <> "" and Instr(rawText, key) > 0
                if Left(key, 1) = ":" or IsAsciiToken(key) = false
                    url = emojiMap[key]
                    if url <> "" then sources.Push(url)
                end if
            end if
        end for
    end if
    for each url in sources
        if url <> "" and seen[url] = invalid
            seen[url] = true
            urls.Push(url)
        end if
    end for
    if urls.Count() <= 6 then return urls
    slim = []
    i = 0
    while i < 6
        slim.Push(urls[i])
        i = i + 1
    end while
    return slim
end function

function DiscordAvatarUrl(author as Object) as String
    if author = invalid then return DefaultDiscordAvatar("")
    url = SafeHttpUrl(TrimText(author.avatar))
    if url <> "" then return url
    return DefaultDiscordAvatar(TrimText(author.id))
end function

function DefaultDiscordAvatar(userId as String) as String
    n = 0
    if userId <> ""
        last = Right(userId, 1)
        n = last.ToInt()
        n = n mod 6
    end if
    return "https://cdn.discordapp.com/embed/avatars/" + n.ToStr() + ".png"
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
