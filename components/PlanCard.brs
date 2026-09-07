sub init()
    m.border = m.top.findNode("border")
    m.bg = m.top.findNode("bg")
    m.groupLabel = m.top.findNode("groupLabel")
    m.titleLabel = m.top.findNode("titleLabel")
    m.priceLabel = m.top.findNode("priceLabel")
    m.blurbLabel = m.top.findNode("blurbLabel")
end sub

sub onItemContent()
    item = m.top.itemContent
    if item = invalid then return
    m.titleLabel.text = item.title
    m.groupLabel.text = item.ShortDescriptionLine1
    m.priceLabel.text = item.ShortDescriptionLine2
    m.blurbLabel.text = item.description
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if key = "OK" or key = "play"
        item = m.top.itemContent
        idx = 0
        if item <> invalid and item.planIndex <> invalid then idx = item.planIndex
        if m.global <> invalid
            m.global.planPickIndex = idx
            tick = m.global.planPickTick
            m.global.planPickTick = tick + 1
        end if
        return true
    end if
    return false
end function

sub onFocusPercent()
    if m.top.focusPercent > 0.5
        m.border.color = "0x00FF00FF"
        m.bg.color = "0x1C2A16FF"
        m.titleLabel.color = "0x00FF00FF"
    else
        m.border.color = "0x2A2A2AFF"
        m.bg.color = "0x141414FF"
        m.titleLabel.color = "0xF6F7F4FF"
    end if
end sub
