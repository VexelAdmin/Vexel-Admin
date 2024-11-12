local MainModule = {}
local Packages = script:WaitForChild("Packages")

MainModule.Commands = {}

function MainModule:GetSettings()
	local PTAdminModel = game:GetService("ServerScriptService"):FindFirstChild("PT Admin")
	if PTAdminModel then
		return require(PTAdminModel:WaitForChild("Settings"))
	else
		warn("PT Admin not found in ServerScriptService.")
		return nil
	end
end

function MainModule:Initialize()
	local Settings = self:GetSettings()
	if not Settings then return end

	for _, commandModule in ipairs(Packages:GetChildren()) do
		if commandModule:IsA("ModuleScript") then
			local command = require(commandModule)
			self.Commands[command.Name] = command
		end
	end
end

function MainModule:Log(message, level)
	level = level or "INFO"
	print(string.format("[%s][%s] %s", os.date("%Y-%m-%d %H:%M:%S"), level, message))
end

function MainModule:ExecuteCommand(player, message)
	local Settings = self:GetSettings()
	if not Settings then return end  

	if message:sub(1, 1) ~= Settings.Prefix then return end
	local commandName, argument = message:match(Settings.Prefix .. "(%w+)%s*(%w*)")
	local command = self.Commands[commandName]
	print("Executing command:", commandName, "with argument:", argument)  

	if command and self:HasPermission(player, command) then
		local targets = self:ResolveTargets(player, argument)
		for _, targetPlayer in ipairs(targets) do
			if command:Execute(player, targetPlayer.Name) then
				print("Command executed successfully for target:", targetPlayer.Name)  
			else
				print("Command execution failed for target:", targetPlayer.Name)
			end
		end
	end
end

function MainModule:ResolveTargets(player, argument)
	if argument == "me" then
		return {player}
	elseif argument == "all" then
		return game:GetService("Players"):GetPlayers()
	else
		local targetPlayer = game:GetService("Players"):FindFirstChild(argument)
		if targetPlayer then
			return {targetPlayer}
		else
			player:SendMessage("Player not found: " .. argument)
			self:Log(string.format("Player %s tried to target non-existent player %s", player.Name, argument), "WARN")
			return {}
		end
	end
end

function MainModule:HasPermission(player, command)
	local Settings = self:GetSettings()
	if not Settings then return false end  

	local playerRole = self:GetPlayerRole(player)
	local requiredPermission = command.PermissionLevel or 0
	return playerRole and Settings.Roles[playerRole] and Settings.Roles[playerRole] >= requiredPermission
end

function MainModule:GetPlayerRole(player)
	local Settings = self:GetSettings()
	if not Settings then return "NonAdminPerson" end  

	return Settings.AdminPlayers[player.Name] or "NonAdminPerson"
end

return MainModule
