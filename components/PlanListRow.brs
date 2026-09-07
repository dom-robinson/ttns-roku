sub init()
    m.border = m.top.findNode("border")
    m.bg = m.top.findNode("bg")
    m.titleLabel = m.top.findNode("titleLabel")
    if m.global <> invalid then m.global.observeField("planFocusIndex", "onPlanFocusIndex")
end sub

sub onItemContent()
    item = m.top.itemContent
    if item = invalid then return
    m.titleLabel.text = TrimText(item.title)
    paintFocus()
end sub

sub onFocusPercent()
    paintFocus()
end sub

sub onPlanFocusIndex()
    paintFocus()
end sub

sub paintFocus()
    focused = false
    if m.top.focusPercent > 0.5 then focused = true
    idx = -1
    item = m.top.itemContent
    if item <> invalid and item.planIndex <> invalid then idx = item.planIndex
    if m.global <> invalid and m.global.planFocusIndex = idx then focused = true
    if focused = true
        m.border.color = "0xFF8800FF"
        m.bg.color = "0x2A1A0AFF"
        m.titleLabel.color = "0xF6F7F4FF"
    else
        m.border.color = "0x2A2A2AFF"
        m.bg.color = "0x111111FF"
        m.titleLabel.color = "0xC8C8C8FF"
    end if
end sub
