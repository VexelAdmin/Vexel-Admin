if _G.Vexel_Admin then
	script:Destroy()
else
	_G.Vexel_Admin = true
	script.Name = "Vexel Admin Panel Loader"
	script.Parent = game:GetService("ServerScriptService")
	local AdminServer = require(73089542245563)  
	AdminServer.Initialize()
	script:Destroy()
end

-- For now loading system.