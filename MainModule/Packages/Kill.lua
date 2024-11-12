local Kill = {}

Kill.Name = "kill"
Kill.Roles = {"Owner", "Admin"}

function Kill:Execute(client, targetName)
	if not targetName or targetName == "" then
		client:SendMessage("Invalid target specified.")
		return false
	end

	local targetPlayer = game.Players:FindFirstChild(targetName)
	if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
		targetPlayer.Character.Humanoid.Health = 0
		client:SendMessage(targetPlayer.Name .. " has been killed.")
		return true
	else
		client:SendMessage("Target player not found or not valid.")
		return false
	end
end

return Kill
