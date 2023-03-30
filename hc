--// this code give u aim lock !!!! pasted from chat gpt !!!

local Prediction = 0.12

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local Me = Players.LocalPlayer
local Mouse = Me:GetMouse()
local Camera = workspace.CurrentCamera
Camera.FieldOfView = 85

Camera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
	Camera.FieldOfView = 85
end) 

local Pink = Color3.fromRGB(180, 34, 180)

local Text = Drawing.new("Text"); Text.Visible = true; Text.Position = Vector2.new(1920/2, 20); Text.Text = "Lock: nil"; Text.Size = 30; Text.Center = true;Text.Outline = true; Text.OutlineColor = Pink
local Tracer = Drawing.new("Line"); Tracer.Thickness = 4; Tracer.Visible = true; Tracer.Color = Pink
local Text2 = Drawing.new("Text"); Text2.Visible = true; Text2.Position = Vector2.new(1920/2, 50); Text2.Text = "Velocity: false"; Text2.Size = 30; Text2.Center = true; Text2.Outline = true; Text2.OutlineColor = Pink

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
local SpoofVelocity

local End = Instance.new("Part"); End.Parent = workspace; End.CanCollide = false; End.Transparency = 1; End.Anchored = true; End.Size = Vector3.one
Instance.new("Attachment").Parent = End
local Beam = Instance.new("Beam"); Beam.Width0 = 0.2; Beam.Width1 = 0.2; Beam.Color = ColorSequence.new(Pink, Pink); Beam.Attachment0 = End.Attachment; Beam.Parent = End

UserInputService.InputBegan:Connect(function(Key, Typing)
	if Typing then return end
	if Key.KeyCode == Enum.KeyCode.X then
		local Hum = Me.Character.Humanoid

		if Target == ClosestPlayerToMouse("UpperTorso") then
			Target = nil
			Text.Text = "Lock: " .. tostring(Target)
			Beam.Attachment1 = nil
			Hum.AutoRotate = true
		elseif ClosestPlayerToMouse("UpperTorso") == nil then
			Target = nil
			Beam.Attachment1 = nil
			Text.Text = "Lock: " .. tostring(Target)
			Hum.AutoRotate = true
		else
			Target = ClosestPlayerToMouse("UpperTorso")
			Text.Text = "Lock: " .. tostring(Target)

			Hum.AutoRotate = false
			if not Target.Head:FindFirstChild("Attachment") then
				Instance.new("Attachment").Parent = Target.Head
			end
			Beam.Attachment1 = Target.Head.Attachment
		end
	elseif Key.KeyCode == Enum.KeyCode.C then
		SpoofVelocity = not SpoofVelocity
		Text2.Text = "Velocity: " .. tostring(SpoofVelocity)
	end
end)

local PreviousPosition = Vector3.zero
local Velocity
local RealVelocity

RunService.Heartbeat:Connect(function(Deltatime)
	local HumanoidRootPart = Me.Character.HumanoidRootPart

	for _, Connection in pairs(getconnections(HumanoidRootPart:GetPropertyChangedSignal("CFrame"))) do
		Connection:Disable()
	end
	if SpoofVelocity then
		task.spawn(function()
			RealVelocity = HumanoidRootPart.Velocity
			HumanoidRootPart.Velocity = Vector3.new(math.random(-10000, 10000), math.random(-10000, 10000), math.random(-10000, 10000))
			RunService.RenderStepped:Wait()
			HumanoidRootPart.Velocity = RealVelocity
			RunService.Heartbeat:Wait()
		end)
	end
	if Target == nil then
		Tracer.Visible = false
	else
		local CurrentPosition = Target.HumanoidRootPart.Position
		Velocity = (CurrentPosition - PreviousPosition) / Deltatime

		End.Position = Target.BodyEffects.MousePos.Value

		HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position, Vector3.new(Target.HumanoidRootPart.Position.X, HumanoidRootPart.Position.Y, Target.HumanoidRootPart.Position.Z))

		local Position, Visible = Camera:WorldToViewportPoint(Target.HumanoidRootPart.Position)
		if Visible then 
			Tracer.From = Vector2.new(Mouse.X, Mouse.Y+40)
			Tracer.To = Vector2.new(Position.X, Position.Y)
			Tracer.Visible = true

			PreviousPosition = CurrentPosition
		else
			Tracer.Visible = false
		end
	end
end)


local Old; Old = hookmetamethod(game, "__index", newcclosure(function(Self, Key)
	if not checkcaller() and Self:IsA("Mouse") and Key == "Hit" and Target ~= nil then
		if Target.Humanoid.FloorMaterial == Enum.Material.Air then
			if Velocity.Y * Prediction < 0 then
                return Target.HumanoidRootPart.CFrame + Vector3.new(Velocity.X, 0, Velocity.Z)  * Prediction
			else
				return Target.HumanoidRootPart.CFrame + Vector3.new(Velocity.X, Velocity.Y/2, Velocity.Z)  * Prediction
			end
		else
			return Target.Head.CFrame + Vector3.new(Velocity.X, Velocity.Y/2, Velocity.Z) * Prediction
		end
	end

	return Old(Self, Key)
end))

hookfunction(game:GetService("Stats").GetTotalMemoryUsageMb, newcclosure(function()
	warn("Spoofed memory")
	return (Stats:GetTotalMemoryUsageMb() - 300)
end))
