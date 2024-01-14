local args = { ... }

local modem = peripheral.find("modem", rednet.open)

rednet.broadcast(args[1], "ssh")
print("Trying to connect...")

local server_id, message = rednet.receive("ssh")
repeat
    if message == "ACK" then
        print("Recieved ACK!")
        break
    end
    server_id, message = rednet.receive("ssh")
until false

local function sendKeyEvents()
    while true do
        local _, button = os.pullEvent("key")

        rednet.send(server_id, {
            type = "key",
            data = button
        }, "sshevnt")
    end
end

local function sendCharEvents()
    while true do
        local _, char = os.pullEvent("char")

        rednet.send(server_id, {
            type = "char",
            data = char
        }, "sshevnt")
    end
end

local function respondToTerm()
    while true do
        local _, message = rednet.receive("sshpckt")
        if message.type == "write" then
            term.write(message.data)
        elseif message.type == "scroll" then
            term.scroll(message.data)
        elseif message.type == "getCursorPos" then
            local x, y = term.getCursorPos()
            rednet.send(server_id, {
                type = "getCursorPos",
                data = {
                    x = x,
                    y = y
                }
            }, "sshpckt")
        elseif message.type == "setCursorPos" then
            term.setCursorPos(message.data.x, message.data.y)
        elseif message.type == "getCursorBlink" then
            local blink = term.getCursorBlink()
            rednet.send(server_id, {
                type = "getCursorBlink",
                data = blink
            }, "sshpckt")
        elseif message.type == "setCursorBlink" then
            term.setCursorBlink(message.data)
        elseif message.type == "getSize" then
            local w, h = term.getSize()
            rednet.send(server_id, {
                type = "getSize",
                data = {
                    w = w,
                    h = h
                }
            }, "sshpckt")
        elseif message.type == "clear" then
            term.clear()
        elseif message.type == "clearLine" then
            term.clearLine()
        elseif message.type == "getTextColor" then
            local color = term.getTextColor()
            rednet.send(server_id, {
                type = "getTextColor",
                data = color
            }, "sshpckt")
        elseif message.type == "setTextColor" then
            term.setTextColor(message.data)
        elseif message.type == "getBackgroundColor" then
            local color = term.getBackgroundColor()
            rednet.send(server_id, {
                type = "getBackgroundColor",
                data = color
            }, "sshpckt")
        elseif message.type == "setBackgroundColor" then
            term.setBackgroundColor(message.data)
        elseif message.type == "blit" then
            term.blit(message.data.text, message.data.textColor, message.data.backgroundColor)
        elseif message.type == "getPaletteColor" then
            local color = term.getPaletteColor(message.data)
            rednet.send(server_id, {
                type = "getPaletteColor",
                data = color
            }, "sshpckt")
        end
    end
end

local function sendKeepAlives()
    while true do
        rednet.send(server_id, {
            type = "keepAlive"
        }, "sshevnt")
        sleep(1)
    end
end

parallel.waitForAll(sendKeyEvents, sendCharEvents, sendKeepAlives, respondToTerm)
