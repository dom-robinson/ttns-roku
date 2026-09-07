sub init()
    m.border = m.top.findNode("border")
    m.bg = m.top.findNode("bg")
    m.thumb = m.top.findNode("thumb")
    m.titleMarquee = m.top.findNode("titleMarquee")
    m.metaMarquee = m.top.findNode("metaMarquee")
    m.dateLabel = m.top.findNode("dateLabel")
    if m.global <> invalid then m.global.observeField("listFocusIndex", "onListFocusIndex")
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
    paintFocus()
end sub

sub onListFocusIndex()
    paintFocus()
end sub

sub onFocusPercent()
    paintFocus()
end sub

sub paintFocus()
    focused = false
    idx = -1
    item = m.top.itemContent
    if item <> invalid and item.gridIndex <> invalid then idx = item.gridIndex
    if m.global <> invalid and m.global.listFocusIndex = idx then focused = true
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
