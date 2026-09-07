sub StartMemoryMonitor(port as Object)
    monitor = CreateObject("roAppMemoryMonitor")
    if monitor <> invalid
        monitor.SetMessagePort(port)
        enabled = monitor.EnableMemoryWarningEvent(true)
        percent = monitor.GetMemoryLimitPercent()
        available = monitor.GetChannelAvailableMemory()
        limits = monitor.GetChannelMemoryLimit()
        if percent = invalid then percent = 0
        if available = invalid then available = 0
        if limits = invalid then limits = {}
        if enabled = true then return
    end if
    info = CreateObject("roDeviceInfo")
    if info <> invalid
        info.SetMessagePort(port)
        info.EnableLowGeneralMemoryEvent(true)
    end if
end sub
