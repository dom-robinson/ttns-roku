sub init()
    m.top.functionName = "exec"
end sub

sub exec()
    url = m.top.url
    m.top.error = ""
    m.top.response = ""
    m.top.status = 0

    if url = invalid or url = ""
        m.top.error = "Missing URL"
        m.top.ready = true
        return
    end if

    port = CreateObject("roMessagePort")
    xfer = CreateObject("roUrlTransfer")
    xfer.SetPort(port)
    xfer.SetUrl(url)
    xfer.RetainBodyOnError(true)
    xfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    xfer.InitClientCertificates()
    xfer.AddHeader("Accept", "application/json")
    xfer.AddHeader("User-Agent", "TTNS-Roku/" + AppVersion())
    xfer.EnableEncodings(true)

    if not xfer.AsyncGetToString()
        m.top.error = "Could not start request"
        m.top.ready = true
        return
    end if

    msg = wait(25000, port)
    if msg = invalid
        m.top.error = "Timed out"
        m.top.ready = true
        return
    end if
    if type(msg) <> "roUrlEvent"
        m.top.error = "Unexpected response"
        m.top.ready = true
        return
    end if

    code = msg.GetResponseCode()
    m.top.status = code
    m.top.response = msg.GetString()
    if code < 200 or code > 299
        failure = msg.GetFailureReason()
        if failure = invalid or failure = "" then failure = "HTTP " + code.ToStr()
        m.top.error = failure
    end if
    m.top.ready = true
end sub
