local MainModule = {}
local Packages = script:WaitForChild("Packages")
local Modules = script:WaitForChild("Modules")
local CommandExecutor = require(Modules:WaitForChild("CommandExecutor"))

MainModule.Commands = {}

function MainModule:GetSettings()
	local PTAdminModel = game:GetService("ServerScriptService"):FindFirstChild("Vexel Admin")
	if PTAdminModel then
		return require(PTAdminModel:WaitForChild("Settings"))
	else
		self:Log("Vexel Admin not found in ServerScriptService.", "WARN")
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
			self:Log("Loaded command: " .. command.Name, "INFO")
		end
	end

	CommandExecutor:Initialize(self.Commands, Settings)
end

function MainModule:Log(message, level)
	level = level or "INFO"
	print(string.format("[%s][%s] %s", os.date("%Y-%m-%d %H:%M:%S"), level, message))
end

return MainModule
