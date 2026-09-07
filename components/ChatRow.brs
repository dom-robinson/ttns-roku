sub init()
    m.top.focusable = false
    m.border = m.top.findNode("border")
    m.bg = m.top.findNode("bg")
    m.nameLabel = m.top.findNode("nameLabel")
    m.bodyLabel = m.top.findNode("bodyLabel")
    m.photo = m.top.findNode("photo")
    m.avatar = m.top.findNode("avatar")
    m.emojis = [
        m.top.findNode("emoji0"),
        m.top.findNode("emoji1"),
        m.top.findNode("emoji2"),
        m.top.findNode("emoji3"),
        m.top.findNode("emoji4"),
        m.top.findNode("emoji5")
    ]
    m.emojiXs = [160, 208, 256, 304, 352, 400]
    m.hasEmoji = false
    m.bodyLabel.wrap = true
    m.bodyLabel.ellipsizeOnBoundary = false
    if m.global <> invalid then m.global.observeField("chatFocusIndex", "onChatFocusIndex")
end sub

sub onItemContent()
    item = m.top.itemContent
    if item = invalid then return
    m.nameLabel.text = TrimText(item.title)
    color = "0x00FF00FF"
    if item.ShortDescriptionLine1 <> invalid and item.ShortDescriptionLine1 <> ""
        color = item.ShortDescriptionLine1
    end if
    m.nameLabel.color = color
    avatar = ""
    if item.avatarUrl <> invalid then avatar = TrimText(item.avatarUrl)
    if avatar = ""
        m.avatar.uri = "pkg:/images/ttns-logo.png"
    else
        m.avatar.uri = avatar
    end if
    photo = rowPhotoUrl(item)
    if photo = ""
        m.photo.uri = ""
        m.photo.visible = false
        m.bodyLabel.width = 920
        m.nameLabel.width = 920
    else
        m.photo.uri = photo
        m.photo.visible = true
        m.bodyLabel.width = 620
        m.nameLabel.width = 620
    end if
    urls = rowEmojiUrls(item)
    m.hasEmoji = false
    i = 0
    while i < 6
        poster = m.emojis[i]
        url = ""
        if i < urls.Count() then url = urls[i]
        if url = ""
            poster.uri = ""
            poster.visible = false
        else
            poster.uri = url
            poster.visible = true
            m.hasEmoji = true
        end if
        i = i + 1
    end while
    wrapped = WrapTextToWidth(TrimText(item.description), m.bodyLabel.width, 24, false)
    applyRowSizeForText(wrapped)
    m.bodyLabel.text = wrapped
    paintFocus()
end sub

function rowPhotoUrl(item as Object) as String
    if item = invalid then return ""
    if item.photoUrl <> invalid
        url = TrimText(item.photoUrl)
        if url <> "" then return url
    end if
    if item.HDPosterUrl <> invalid then return TrimText(item.HDPosterUrl)
    return ""
end function

function rowEmojiUrls(item as Object) as Object
    urls = []
    if item = invalid then return urls
    line = ""
    if item.emojiLine <> invalid then line = TrimText(item.emojiLine)
    if line <> ""
        parts = line.Split("|")
        for each part in parts
            url = TrimText(part)
            if url <> "" then urls.Push(url)
        end for
        return urls
    end if
    names = ["emoji1", "emoji2", "emoji3", "emoji4"]
    for each name in names
        url = ""
        if name = "emoji1" and item.emoji1 <> invalid then url = TrimText(item.emoji1)
        if name = "emoji2" and item.emoji2 <> invalid then url = TrimText(item.emoji2)
        if name = "emoji3" and item.emoji3 <> invalid then url = TrimText(item.emoji3)
        if name = "emoji4" and item.emoji4 <> invalid then url = TrimText(item.emoji4)
        if url <> "" then urls.Push(url)
    end for
    return urls
end function

sub applyRowSizeForText(text as String)
    lines = CountTextLines(text)
    if lines < 1 then lines = 1
    lineH = 40
    bodyH = lines * lineH
    if bodyH > 400 then bodyH = 400
    m.bodyLabel.height = bodyH
    m.bodyLabel.maxLines = lines
    emojiY = 38 + bodyH + 8
    i = 0
    while i < 6
        m.emojis[i].translation = [m.emojiXs[i], emojiY]
        i = i + 1
    end while
    h = emojiY
    if m.hasEmoji = true then h = h + 40
    h = h + 8
    if h < 152 then h = 152
    m.border.height = h
    m.bg.height = h - 8
    m.top.clippingRect = [0, 0, 1140, h]
    m.top.rowHeight = h
end sub

sub onFocusPercent()
    paintFocus()
end sub

sub onChatFocusIndex()
    paintFocus()
end sub

sub paintFocus()
    focused = false
    idx = -1
    item = m.top.itemContent
    if item <> invalid and item.chatIndex <> invalid then idx = item.chatIndex
    if m.global <> invalid and m.global.chatFocusIndex = idx then focused = true
    if focused = true
        m.border.color = "0xFF8800FF"
        m.bg.color = "0x2A1A0AFF"
    else
        m.border.color = "0x2A2A2AFF"
        m.bg.color = "0x111111FF"
    end if
end sub
