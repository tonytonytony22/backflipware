--// dis code give u aimlock?? i copied it all from chat gpt

local Prediction = 0.12

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Me = Players.LocalPlayer

local Mouse = Me:GetMouse()
local Camera = workspace.CurrentCamera

local Pink = Color3.fromRGB(180, 34, 180)

local Text = Drawing.new("Text"); Text.Visible = true; Text.Position = Vector2.new(1920/2, 20); Text.Text = "Lock: nil"; Text.Size = 30; Text.Center = true;Text.Outline = true; Text.OutlineColor = Pink
local Tracer = Drawing.new("Line"); Tracer.Thickness = 4; Tracer.Visible = true; Tracer.Color = Pink

local function ClosestPlayerToMouse(Part)
	for _, Player in pairs(Players:GetPlayers()) do
		if Player == Me then continue end
		local Character = Player.Character
		if Character and Character:FindFirstChild("Humanoid") and Character:FindFirstChild("Humanoid") ~= 0 and Character:FindFirstChild("HumanoidRootPart") and Character:FindFirstChild(Part) then
			local Position, Visible = Camera:WorldToViewportPoint(Character[Part].Position)
			local Distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(Position.X, Position.Y)).Magnitude

			if Distance < 100 and Visible then
				return Character
			end
		end
	end
end

local Target

local End = Instance.new("Part"); End.Parent = workspace; End.CanCollide = false; End.Transparency = 1; End.Anchored = true; End.Size = Vector3.one
Instance.new("Attachment").Parent = End
local Beam = Instance.new("Beam"); Beam.Width0 = 0.2; Beam.Width1 = 0.2; Beam.Color = ColorSequence.new(Pink, Pink); Beam.Attachment0 = End.Attachment; Beam.Parent = End

UserInputService.InputBegan:Connect(function(Key, Typing)
	if Typing then return end
	if Key.KeyCode == Enum.KeyCode.X then
		if Target == ClosestPlayerToMouse("UpperTorso") then
			Target = nil
			Text.Text = "Lock: " .. tostring(Target)
			Beam.Attachment1 = nil
		elseif ClosestPlayerToMouse("UpperTorso") == nil then
			Target = nil
			Beam.Attachment1 = nil
			Text.Text = "Lock: " .. tostring(Target)
		else
			Target = ClosestPlayerToMouse("UpperTorso")
			Text.Text = "Lock: " .. tostring(Target)

			if not Target.Head:FindFirstChild("Attachment") then
				Instance.new("Attachment").Parent = Target.Head
			end
			Beam.Attachment1 = Target.Head.Attachment
		end
	end
end)

local PreviousPosition = Vector3.zero

local function MoveMouse(Position)
	local Position, Visible =  Camera:WorldToScreenPoint(Position)
	local X, Y = Position.X - Mouse.X, Position.Y - Mouse.Y

	mousemoverel(X, Y)
end

RunService.Heartbeat:Connect(function(Deltatime)
	local HumanoidRootPart = Me.Character.HumanoidRootPart


	if Target == nil then
		Tracer.Visible = false
	else
		local Velocity 

		local CurrentPosition = Target.HumanoidRootPart.Position
		Velocity = (CurrentPosition - PreviousPosition) / Deltatime

		End.Position = Target.BodyEffects.MousePos.Value

		local Position, Visible = Camera:WorldToViewportPoint(Target.HumanoidRootPart.Position)
		if Visible then 
			Tracer.From = Vector2.new(Mouse.X, Mouse.Y+40)
			Tracer.To = Vector2.new(Position.X, Position.Y)
			Tracer.Visible = true

			PreviousPosition = CurrentPosition
		else
			Tracer.Visible = false
		end

		if Target.Humanoid.FloorMaterial == Enum.Material.Air then
			if Velocity.Y * Prediction < 0 then
				MoveMouse(Target.LowerTorso.Position + Vector3.new(Velocity.X, 0, Velocity.Z)  * Prediction)
			else 
				MoveMouse(Target.HumanoidRootPart.Position + Vector3.new(Velocity.X, Velocity.Y/2, Velocity.Z)  * Prediction)
			end
		else
			MoveMouse(Target.Head.Position + Vector3.new(Velocity.X, Velocity.Y/2, Velocity.Z) * Prediction)
		end
	end
end)
