local CommandExecutor = {}

CommandExecutor.Commands = {}
CommandExecutor.Settings = {}

function CommandExecutor:Initialize(commands, settings)
	self.Commands = commands
	self.Settings = settings or {}
end

function CommandExecutor:Log(message, level)
	level = level or "INFO"
	print(string.format("[%s][%s] %s", os.date("%Y-%m-%d %H:%M:%S"), level, message))
end

function CommandExecutor:ExecuteCommand(player, message)
	if not self.Settings or not self.Settings.Prefix then
		self:Log("Settings not loaded or missing prefix.", "ERROR")
		return
	end

	if message:sub(1, 1) ~= self.Settings.Prefix then return end

	local commandName, argument = message:match(self.Settings.Prefix .. "(%w+)%s*(%w*)")
	if not commandName then
		self:Log("Unrecognized command format in message: " .. message, "WARN")
		return
	end

	local command = self.Commands[commandName]
	if not command then
		self:Log("Unknown command: " .. commandName, "WARN")
		return
	end

	self:Log("Executing command: " .. commandName .. " with argument: " .. argument, "INFO")

	if self:HasPermission(player, command) then
		self:ProcessCommand(player, command, argument)
	else
		self:Log("Player " .. player.Name .. " does not have permission for command: " .. commandName, "WARN")
	end
end

function CommandExecutor:ProcessCommand(player, command, argument)
	local targets = self:ResolveTargets(player, argument)
	if #targets == 0 then
		self:Log("No valid targets for command: " .. command.Name, "WARN")
		return
	end

	for _, targetPlayer in ipairs(targets) do
		if command:Execute(player, targetPlayer.Name) then
			self:Log("Executed command " .. command.Name .. " on target: " .. targetPlayer.Name, "INFO")
		else
			self:Log("Failed to execute command " .. command.Name .. " on target: " .. targetPlayer.Name, "ERROR")
		end
	end
end

function CommandExecutor:ResolveTargets(player, argument)
	if argument == "me" then
		return {player}
	elseif argument == "all" then
		return game:GetService("Players"):GetPlayers()
	else
		local targetPlayer = game:GetService("Players"):FindFirstChild(argument)
		if targetPlayer then
			return {targetPlayer}
		else
			self:Log("Player " .. player.Name .. " attempted to target non-existent player: " .. argument, "WARN")
			return {}
		end
	end
end

function CommandExecutor:HasPermission(player, command)
	local playerRole = self:GetPlayerRole(player)
	local requiredPermission = command.PermissionLevel or 0

	if not playerRole or not self.Settings.Roles[playerRole] then
		self:Log("Role not found or invalid for player: " .. player.Name, "WARN")
		return false
	end

	return self.Settings.Roles[playerRole] >= requiredPermission
end

function CommandExecutor:GetPlayerRole(player)
	if player.UserId == game.CreatorId then
		return "Creator"
	end
	return self.Settings.AdminPlayers[player.Name] or "NonAdminPerson"
end

return CommandExecutor
