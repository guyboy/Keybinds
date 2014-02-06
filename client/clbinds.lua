local toBind = nil
local binds = {}
local unbind = false
local color = Color(242, 195, 55)


HandleChat = function(args)
	if string.sub(args.text,1,6) == "/bind " then
		toBind = string.sub(args.text, 7)
		if string.sub(toBind,1,1) == "/" then
			Chat:Print("Press the key you would like to bind the command "..toBind.." to...", color)
		else
			Chat:Print("Press the key you would like to bind the command "..toBind.." to. Are you sure it's a command? Cause it doesn't start with /", color)
		end
	elseif string.sub(args.text,1,5) == "/bind" then
		Chat:Print("Example usage: /bind /tp airport", color)
		Chat:Print("You will be prompted for a key to bind the command to.", color)
		Chat:Print("Other commands: /unbind, /unbindall, /list", color)
	elseif args.text == "/unbindall" then
		binds = {}
		Chat:Print("All keys unbound.", color)
		UpdateKeys()
	elseif string.sub(args.text,1,7) == "/unbindall" then
		Chat:Print("Just type /unbindall to unbind all keys.", color)
	elseif args.text == "/unbind" then
		unbind = true
		Chat:Print("Press the key you would like to unbind a command from...", color)
	elseif string.sub(args.text,1,7) == "/unbind" then
		Chat:Print("Just type /unbind to unbind a key.", color)
	elseif args.text == "/list" then
		for k,v in pairs(binds) do
			Chat:Print(k.." ("..string.char(k)..") does "..v, color)
		end
	end
end

Events:Subscribe("LocalPlayerChat", HandleChat)


HandleKey = function(args)
	if unbind then
		if binds[args.key] then
			Chat:Print("Command "..binds[args.key].." unbound from key "..args.key.." ("..string.char(args.key)..")", color)
			binds[args.key] = nil
			unbind = false
			UpdateKeys()
		else
			Chat:Print("No command was bound to key "..args.key.." ("..string.char(args.key)..")", color)
			unbind = false
		end
	elseif toBind then
		local message = ""
		if string.sub(toBind,1,1) == "/" then
			message = message.."Command "
		else
			message = message.."Chat message "
		end
		message = message..toBind.." bound to key "..args.key.." ("..string.char(args.key)..")"
		if binds[args.key] then message = message..", replacing "..binds[args.key] end
		if string.sub(toBind,1,1) ~= "/" then message = message..". Note that only commands can be bound, chat text won't broadcast." end
		binds[args.key] = toBind
		Chat:Print(message, color)
		toBind = nil
		UpdateKeys()
	elseif binds[args.key] then
		Events:Fire("LocalPlayerChat", {text=binds[args.key]})
		Network:Send("SimulateCommand", binds[args.key])
	end
end

Events:Subscribe("KeyDown", HandleKey)


function UpdateKeys()
	Network:Send("SQLSave", binds)
	-- Chat:Print("Keybinds sent to server.", Color(255, 255, 255))
end

Network:Subscribe("SQLLoad", function(args)
	binds = args
	if next(binds) == nil then
		-- Chat:Print("No keybinds loaded.", Color(255, 255, 255))
	else
		Chat:Print("Keybinds loaded!", color)
	end
end)



-- Register with help menu.

Events:Subscribe("ModulesLoad" , function()
    Events:Fire( "HelpAddItem",
        {
            name = "Keybinds",
            text = [[
You can bind commands to keys using this script. Do /bind for quick help.

Detailed help:

To bind a key, do /bind followed by a space, followed by the command you want to bind it to.
For example: /bind /tp airport
or: /bind /woet
You will then be prompted to press a key to bind that command to.

Next time you press that key, it will execute that command, be it a client-side or server-side command.

To unbind a key, enter the command /unbind, then press the key you want to unbind from.
To return a list of bound commands, do /list
To unbind all keys, do /unbindall


Keybind script version 1.0 by guyboy
]]
        } )
end)
Events:Subscribe("ModuleUnload" , function()
    Events:Fire( "HelpRemoveItem",
        {
            name = "Keybinds"
        } )
end)