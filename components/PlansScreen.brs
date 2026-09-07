sub init()
    m.top.focusable = true
    m.list = m.top.findNode("list")
    m.dlgGroup = m.top.findNode("dlgGroup")
    m.dlgTitle = m.top.findNode("dlgTitle")
    m.dlgPrice = m.top.findNode("dlgPrice")
    m.dlgBody = m.top.findNode("dlgBody")
    m.dlgUrl = m.top.findNode("dlgUrl")
    m.plans = PlanCatalog()
    m.list.observeField("itemFocused", "onPlanFocused")
    populateList()
end sub

function takeFocus() as Boolean
    m.top.visible = true
    m.list.setFocus(true)
    return true
end function

sub populateList()
    root = CreateObject("roSGNode", "ContentNode")
    i = 0
    for each plan in m.plans
        node = root.createChild("ContentNode")
        node.title = plan.title + "   " + plan.price
        node.addFields({ planIndex: i })
        i = i + 1
    end for
    m.list.content = root
    if root.getChildCount() > 0
        m.list.jumpToItem = 0
        if m.global <> invalid then m.global.planFocusIndex = 0
        showPlan(0)
    end if
end sub

sub onPlanFocused()
    idx = m.list.itemFocused
    if m.global <> invalid then m.global.planFocusIndex = idx
    showPlan(idx)
end sub

sub showPlan(idx as Integer)
    if idx < 0 then return
    if idx >= m.plans.Count() then return
    plan = m.plans[idx]
    city = CityForListings(GetSelectedStation())
    m.dlgGroup.text = UCase(plan.group)
    m.dlgTitle.text = plan.title
    m.dlgPrice.text = plan.price
    m.dlgBody.text = plan.body
    m.dlgUrl.text = "Sign up on " + city.siteUrl + PlansPath()
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if key = "back"
        m.top.action = "home"
        return true
    end if
    return false
end function
