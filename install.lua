print("Installing ssh...")

fs.makeDir("/bin")

local res = http.get("https://raw.githubusercontent.com/Ruthenic/cc-ssh/master/ssh.lua")
if res then
    local file = fs.open("/bin/ssh.lua", "w")
    file.write(res.readAll())
    file.close()
else
    print("Failed to download ssh.lua!")
end

local res = http.get("https://raw.githubusercontent.com/Ruthenic/cc-ssh/master/sshd.lua")
if res then
    local file = fs.open("/bin/sshd.lua", "w")
    file.write(res.readAll())
    file.close()
else
    print("Failed to download sshd.lua!")
end

local res = http.get("https://raw.githubusercontent.com/Ruthenic/cc-ssh/master/sshd.json")
if res then
    local file = fs.open("/sshd.json", "w")
    file.write(res.readAll())
    file.close()
else
    print("Failed to download sshd.json!")
end

print("Installed ssh! Please add /bin to your path.")
