sub init()
    m.bg = m.top.findNode("bg")
    m.accent = m.top.findNode("accent")
    m.thumb = m.top.findNode("thumb")
    m.titleLabel = m.top.findNode("titleLabel")
    m.metaLabel = m.top.findNode("metaLabel")
end sub

sub onItemContent()
    item = m.top.itemContent
    if item = invalid then return
    m.titleLabel.text = item.title
    m.metaLabel.text = item.HDDescription
    if item.HDPosterUrl <> invalid and item.HDPosterUrl <> ""
        m.thumb.uri = item.HDPosterUrl
    else
        m.thumb.uri = FallbackArtworkUrl()
    end if
end sub

sub onFocusPercent()
    if m.top.focusPercent > 0.5
        m.bg.color = "0x1C2A16FF"
        m.accent.color = "0x00FF00FF"
        m.titleLabel.color = "0x00FF00FF"
    else
        m.bg.color = "0x141414FF"
        m.accent.color = "0x2A2A2AFF"
        m.titleLabel.color = "0xF6F7F4FF"
    end if
end sub
