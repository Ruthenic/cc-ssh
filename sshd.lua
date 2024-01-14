local args = { ... }

peripheral.find("modem", rednet.open)

local configFile = fs.open(shell.resolve(args[1]), "r")
local config = textutils.unserializeJSON(configFile.readAll())

local function printToTerm(term, string)
    local _, scny = term.getSize()
    local _, cury = term.getCursorPos()
    if cury == scny then
        term.scroll(1)
        cury = scny - 1
    end
    term.setCursorPos(1, cury + 1)
    term.write(string)
end

while true do
    -- handle connections
    local client_id, message = rednet.receive("ssh")
    print("Recieved attempted connection from " .. client_id .. " with hostname " .. message .. ".")
    if message == config["hostname"] then
        rednet.send(client_id, "ACK", "ssh")
        local old_term
        local new_term = {
            write = function(string)
                if config["mirror"] == true then
                    old_term.write(string)
                end
                rednet.send(client_id, {
                    type = "write",
                    data = string
                }, "sshpckt")
            end,
            scroll = function(n)
                if config["mirror"] == true then
                    old_term.scroll(n)
                end
                rednet.send(client_id, {
                    type = "scroll",
                    data = n
                }, "sshpckt")
            end,
            getCursorPos = function()
                rednet.send(client_id, {
                    type = "getCursorPos"
                }, "sshpckt")
                local _, message = rednet.receive("sshpckt")
                return message.data.x, message.data.y
            end,
            setCursorPos = function(x, y)
                if config["mirror"] == true then
                    old_term.setCursorPos(x, y)
                end
                rednet.send(client_id, {
                    type = "setCursorPos",
                    data = {
                        x = x,
                        y = y
                    }
                }, "sshpckt")
            end,
            getCursorBlink = function()
                rednet.send(client_id, {
                    type = "getCursorBlink"
                }, "sshpckt")
                local _, message = rednet.receive("sshpckt")
                return message.data
            end,
            setCursorBlink = function(blink)
                if config["mirror"] == true then
                    old_term.setCursorBlink(blink)
                end
                rednet.send(client_id, {
                    type = "setCursorBlink",
                    data = blink
                }, "sshpckt")
            end,
            getSize = function()
                rednet.send(client_id, {
                    type = "getSize"
                }, "sshpckt")
                local _, message = rednet.receive("sshpckt")
                return message.data.w, message.data.h
            end,
            clear = function()
                if config["mirror"] == true then
                    old_term.clear()
                end
                rednet.send(client_id, {
                    type = "clear"
                }, "sshpckt")
            end,
            clearLine = function()
                if config["mirror"] == true then
                    old_term.clearLine()
                end
                rednet.send(client_id, {
                    type = "clearLine"
                }, "sshpckt")
            end,
            getTextColor = function()
                rednet.send(client_id, {
                    type = "getTextColor"
                }, "sshpckt")
                local _, message = rednet.receive("sshpckt")
                return message.data
            end,
            setTextColor = function(color)
                if config["mirror"] == true then
                    old_term.setTextColor(color)
                end
                rednet.send(client_id, {
                    type = "setTextColor",
                    data = color
                }, "sshpckt")
            end,
            getTextColour = function()
                rednet.send(client_id, {
                    type = "getTextColor"
                }, "sshpckt")
                local _, message = rednet.receive("sshpckt")
                return message.data
            end,
            setTextColour = function(color)
                if config["mirror"] == true then
                    old_term.setTextColor(color)
                end
                rednet.send(client_id, {
                    type = "setTextColor",
                    data = color
                }, "sshpckt")
            end,
            getBackgroundColor = function()
                rednet.send(client_id, {
                    type = "getBackgroundColor"
                }, "sshpckt")
                local _, message = rednet.receive("sshpckt")
                return message.data
            end,
            setBackgroundColor = function(color)
                if config["mirror"] == true then
                    old_term.setBackgroundColor(color)
                end
                rednet.send(client_id, {
                    type = "setBackgroundColor",
                    data = color
                }, "sshpckt")
            end,
            getBackgroundColour = function()
                rednet.send(client_id, {
                    type = "getBackgroundColor"
                }, "sshpckt")
                local _, message = rednet.receive("sshpckt")
                return message.data
            end,
            setBackgroundColour = function(color)
                if config["mirror"] == true then
                    old_term.setBackgroundColor(color)
                end
                rednet.send(client_id, {
                    type = "setBackgroundColor",
                    data = color
                }, "sshpckt")
            end,
            isColor = function()
                return true -- we hate poor people in this building
            end,
            isColour = function()
                return true
            end,
            blit = function(text, textColor, backgroundColor)
                if config["mirror"] == true then
                    old_term.blit(text, textColor, backgroundColor)
                end
                rednet.send(client_id, {
                    type = "blit",
                    data = {
                        text = text,
                        textColor = textColor,
                        backgroundColor = backgroundColor
                    }
                }, "sshpckt")
            end,
            getPaletteColor = function(color)
                rednet.send(client_id, {
                    type = "getPaletteColor",
                    data = color
                }, "sshpckt")
                local _, message = rednet.receive("sshpckt")
                return message.data
            end,
            setPaletteColor = function(color, value)
                -- stub
            end,
            getPaletteColour = function(color)
                rednet.send(client_id, {
                    type = "getPaletteColor",
                    data = color
                }, "sshpckt")
                local _, message = rednet.receive("sshpckt")
                return message.data
            end,
            setPaletteColour = function(color, value)
                -- stub
            end,
        }
        old_term = term.redirect(new_term)
        term.clear()
        parallel.waitForAny(function()
            local startTime = os.clock()
            local timeout = 5
            while true do
                if os.clock() - startTime > timeout then
                    break
                end
                local _, message = rednet.receive("sshevnt", 1)
                if message == nil then goto continue end
                if message.type == "key" then
                    os.queueEvent("key", message.data)
                elseif message.type == "char" then
                    os.queueEvent("char", message.data)
                elseif message.type == "keepAlive" then
                    startTime = os.clock()
                end
                ::continue::
            end
        end, function()
            shell.run(config["shell"])
        end)
        term.redirect(old_term)
        term.clear()
        term.setCursorPos(1, 1)
        print("Client disconnected.")
    end
end
