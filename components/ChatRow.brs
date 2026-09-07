sub init()
    m.top.focusable = true
    m.bg = m.top.findNode("bg")
    m.nameLabel = m.top.findNode("nameLabel")
    m.bodyLabel = m.top.findNode("bodyLabel")
    m.photo = m.top.findNode("photo")
    m.emojis = [
        m.top.findNode("emoji0"),
        m.top.findNode("emoji1"),
        m.top.findNode("emoji2"),
        m.top.findNode("emoji3")
    ]
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
    m.bodyLabel.text = TrimText(item.description)
    photo = ""
    if item.HDPosterUrl <> invalid then photo = TrimText(item.HDPosterUrl)
    if photo = ""
        m.photo.uri = ""
        m.photo.visible = false
        m.bodyLabel.width = 1108
        m.nameLabel.width = 1108
    else
        m.photo.uri = photo
        m.photo.visible = true
        m.bodyLabel.width = 780
        m.nameLabel.width = 780
    end if
    urls = [itemField(item, "emoji1"), itemField(item, "emoji2"), itemField(item, "emoji3"), itemField(item, "emoji4")]
    i = 0
    while i < 4
        poster = m.emojis[i]
        url = urls[i]
        if url = ""
            poster.uri = ""
            poster.visible = false
        else
            poster.uri = url
            poster.visible = true
        end if
        i = i + 1
    end while
end sub

function itemField(item as Object, name as String) as String
    if item = invalid then return ""
    if name = "emoji1" and item.emoji1 <> invalid then return TrimText(item.emoji1)
    if name = "emoji2" and item.emoji2 <> invalid then return TrimText(item.emoji2)
    if name = "emoji3" and item.emoji3 <> invalid then return TrimText(item.emoji3)
    if name = "emoji4" and item.emoji4 <> invalid then return TrimText(item.emoji4)
    return ""
end function

sub onFocusPercent()
    focused = false
    if m.top.focusPercent > 0.5 then focused = true
    if focused = true
        m.bg.color = "0x1C2A16FF"
    else
        m.bg.color = "0x111111FF"
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if key = "OK" or key = "play"
        if m.global <> invalid
            tick = m.global.chatToggleTick
            m.global.chatToggleTick = tick + 1
        end if
        return true
    end if
    if key = "up"
        item = m.top.itemContent
        idx = 0
        if item <> invalid and item.chatIndex <> invalid then idx = item.chatIndex
        if idx <= 0
            if m.global <> invalid
                tick = m.global.chatLeaveTick
                m.global.chatLeaveTick = tick + 1
            end if
            return true
        end if
    end if
    return false
end function
