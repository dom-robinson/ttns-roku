sub init()
    m.border = m.top.findNode("border")
    m.bg = m.top.findNode("bg")
    m.thumb = m.top.findNode("thumb")
    m.titleMarquee = m.top.findNode("titleMarquee")
    m.metaMarquee = m.top.findNode("metaMarquee")
    m.dateLabel = m.top.findNode("dateLabel")
end sub

sub onItemContent()
    item = m.top.itemContent
    if item = invalid then return
    m.titleMarquee.text = item.title
    m.metaMarquee.text = item.description
    dateText = ""
    if item.ShortDescriptionLine1 <> invalid then dateText = item.ShortDescriptionLine1
    m.dateLabel.text = dateText
    posterUrl = ""
    if item.HDPosterUrl <> invalid then posterUrl = item.HDPosterUrl
    if posterUrl = ""
        m.thumb.uri = FallbackArtworkUrl()
    else
        m.thumb.uri = posterUrl
    end if
end sub

sub onFocusPercent()
    focused = false
    if m.top.focusPercent > 0.5 then focused = true
    if focused = true
        m.border.color = "0x00FF00FF"
        m.bg.color = "0x1C2A16FF"
        m.titleMarquee.labelColor = "0x00FF00FF"
        m.titleMarquee.active = true
        m.metaMarquee.active = true
    else
        m.border.color = "0x2A2A2AFF"
        m.bg.color = "0x141414FF"
        m.titleMarquee.labelColor = "0xF6F7F4FF"
        m.titleMarquee.active = false
        m.metaMarquee.active = false
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    item = m.top.itemContent
    idx = 0
    if item <> invalid and item.gridIndex <> invalid then idx = item.gridIndex
    jump = false
    if key = "options" then jump = true
    if key = "replay" then jump = true
    if key = "up" and idx < 5 then jump = true
    if jump = true
        if m.global <> invalid
            tick = m.global.listFilterTick
            m.global.listFilterTick = tick + 1
        end if
        return true
    end if
    return false
end function
