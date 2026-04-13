loadstring(game:HttpGet("https://raw.githubusercontent.com/nesquickwe/GatyWare/refs/heads/main/ArsenalLegacy"))()
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local replacementText = "Nigger"
local function replaceTextInInstance(instance)
    if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
        if instance.Text ~= "" then
            instance.Text = replacementText
        end
    end
    
    for _, child in ipairs(instance:GetChildren()) do
        replaceTextInInstance(child)
    end
end

local playerGui = localPlayer:WaitForChild("PlayerGui")

replaceTextInInstance(playerGui)

local function onDescendantAdded(descendant)
    if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
        if descendant.Text ~= "" then
            descendant.Text = replacementText
        end
    end
    
    for _, child in ipairs(descendant:GetChildren()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
            if child.Text ~= "" then
                child.Text = replacementText
            end
        end
    end
end

playerGui.DescendantAdded:Connect(onDescendantAdded)

local function watchNametags()
    local nametagsFolder = playerGui:FindFirstChild("Nametags")
    if nametagsFolder then
        nametagsFolder.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("TextLabel") and descendant.Name == "plrname" then
                descendant.Text = replacementText
            elseif descendant:IsA("TextButton") and descendant.Name == "plrname" then
                descendant.Text = replacementText
            end
        end)
        
        for _, playerFolder in ipairs(nametagsFolder:GetChildren()) do
            local plrnameLabel = playerFolder:FindFirstChild("plrname")
            if plrnameLabel and (plrnameLabel:IsA("TextLabel") or plrnameLabel:IsA("TextButton")) then
                plrnameLabel.Text = replacementText
            end
        end
    end
end

local function watchKillFeed()
    local guiFolder = playerGui:FindFirstChild("GUI")
    if guiFolder then
        local topRight = guiFolder:FindFirstChild("TopRight")
        if topRight then
            for _, frame in ipairs(topRight:GetChildren()) do
                if frame:IsA("Frame") then
                    local killerLabel = frame:FindFirstChild("Killer")
                    if killerLabel and (killerLabel:IsA("TextLabel") or killerLabel:IsA("TextButton")) then
                        killerLabel.Text = replacementText
                    end
                    
                    local victimLabel = frame:FindFirstChild("Victim")
                    if victimLabel and (victimLabel:IsA("TextLabel") or victimLabel:IsA("TextButton")) then
                        victimLabel.Text = replacementText
                    end
                end
            end
            
            topRight.DescendantAdded:Connect(function(descendant)
                if descendant:IsA("Frame") then
                    local killerLabel = descendant:FindFirstChild("Killer")
                    if killerLabel and (killerLabel:IsA("TextLabel") or killerLabel:IsA("TextButton")) then
                        killerLabel.Text = replacementText
                    end
                    
                    local victimLabel = descendant:FindFirstChild("Victim")
                    if victimLabel and (victimLabel:IsA("TextLabel") or victimLabel:IsA("TextButton")) then
                        victimLabel.Text = replacementText
                    end
                end
            end)
        end
    end
end

local function watchKillCam()
    local guiFolder = playerGui:FindFirstChild("GUI")
    if guiFolder then
        local killCam = guiFolder:FindFirstChild("KillCamNew")
        if killCam then
            local playerNameLabel = killCam:FindFirstChild("PlayerName")
            if playerNameLabel and (playerNameLabel:IsA("TextLabel") or playerNameLabel:IsA("TextButton")) then
                playerNameLabel.Text = replacementText
            end
            
            guiFolder.DescendantAdded:Connect(function(descendant)
                if descendant.Name == "KillCamNew" then
                    local playerNameLabel = descendant:FindFirstChild("PlayerName")
                    if playerNameLabel and (playerNameLabel:IsA("TextLabel") or playerNameLabel:IsA("TextButton")) then
                        playerNameLabel.Text = replacementText
                    end
                end
            end)
        end
    end
end

task.wait()

watchNametags()
watchKillFeed()
watchKillCam()

while true do
    task.wait()
    
    local nametagsFolder = playerGui:FindFirstChild("Nametags")
    if nametagsFolder then
        for _, playerFolder in ipairs(nametagsFolder:GetChildren()) do
            local plrnameLabel = playerFolder:FindFirstChild("plrname")
            if plrnameLabel and (plrnameLabel:IsA("TextLabel") or plrnameLabel:IsA("TextButton")) then
                if plrnameLabel.Text ~= replacementText then
                    plrnameLabel.Text = replacementText
                end
            end
        end
    end
    
    local guiFolder = playerGui:FindFirstChild("GUI")
    if guiFolder then
        local topRight = guiFolder:FindFirstChild("TopRight")
        if topRight then
            for _, frame in ipairs(topRight:GetChildren()) do
                if frame:IsA("Frame") then
                    local killerLabel = frame:FindFirstChild("Killer")
                    if killerLabel and (killerLabel:IsA("TextLabel") or killerLabel:IsA("TextButton")) then
                        if killerLabel.Text ~= replacementText then
                            killerLabel.Text = replacementText
                        end
                    end
                    
                    local victimLabel = frame:FindFirstChild("Victim")
                    if victimLabel and (victimLabel:IsA("TextLabel") or victimLabel:IsA("TextButton")) then
                        if victimLabel.Text ~= replacementText then
                            victimLabel.Text = replacementText
                        end
                    end
                end
            end
        end
        
        local killCam = guiFolder:FindFirstChild("KillCamNew")
        if killCam then
            local playerNameLabel = killCam:FindFirstChild("PlayerName")
            if playerNameLabel and (playerNameLabel:IsA("TextLabel") or playerNameLabel:IsA("TextButton")) then
                if playerNameLabel.Text ~= replacementText then
                    playerNameLabel.Text = replacementText
                end
            end
        end
    end
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local dmgtxt = {
    "Nigger", "Nigga", "Ngga", "Faggot", "Fag", "Retard", "Retarded",
    "Kike", "Spic", "Chink", "Ching Chong", "Tranny", "Tran", "Cunt",
    "Skid", "Orphan", "Jew", "Monkey", "Porch Monkey", "Ape", "Dyke", "Pedo",
    "Autistic", "Downie", "Spastic", "Cancer", "KYS", "Kill Yourself",
    "Inbred", "Bastard", "Cuck", "Virgin", "Incel", "Cumslut",
    "Whore", "Bitch", "Cumdump", "Subhuman", "Filth", "Fatherless", "Motherless",
    "Adopted", "Sybau", "Stfu", "Sand Nigger", "Torta", "Over Wath player", "Nate"
}

local function shuffle(tbl)
    local copy = table.clone(tbl)
    for i = #copy, 2, -1 do
        local j = math.random(i)
        copy[i], copy[j] = copy[j], copy[i]
    end
    return copy
end

local CRIT_TEXTS = shuffle(dmgtxt)
local DAMAGE_TEXTS_SHUFFLED = shuffle(dmgtxt)

local assignedCrit = {}
local assignedDamage = {}

local function getRandomText(list)
    return list[math.random(#list)]
end

PlayerGui.ChildAdded:Connect(function(gui)
    if gui.Name:sub(1, 7) ~= "HurtGui" then return end

    local critText = getRandomText(CRIT_TEXTS)
    local damageText = getRandomText(DAMAGE_TEXTS_SHUFFLED)

    if critText == damageText then
        DAMAGE_TEXTS_SHUFFLED = shuffle(dmgtxt)
        damageText = getRandomText(DAMAGE_TEXTS_SHUFFLED)

        if critText == damageText then
            CRIT_TEXTS = shuffle(dmgtxt)
            critText = getRandomText(CRIT_TEXTS)
        end
    end

    assignedCrit[gui] = critText
    assignedDamage[gui] = damageText

    local textBtn = gui:FindFirstChild("TextButton")
    if textBtn then
        textBtn.Text = damageText
    end

    local crit = gui:FindFirstChild("Crit")
    if crit then
        crit.Text = critText
    end

    gui.AncestryChanged:Connect(function()
        if not gui:IsDescendantOf(game) then
            assignedCrit[gui] = nil
            assignedDamage[gui] = nil
        end
    end)
end)

local KillCamSuccess, KillCam = pcall(function()
    return LocalPlayer.PlayerGui:WaitForChild("GUI", 5)
        :WaitForChild("KillCamNew", 5)
        :WaitForChild("PlayerName", 5)
end)

if KillCamSuccess and KillCam then
    KillCam.Text = "Nigga"
end

local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Color = Color3.fromRGB(255, 255, 255)
FOV_Circle.Transparency = 0.5 
FOV_Circle.Radius = 45
FOV_Circle.NumSides = 100
FOV_Circle.Thickness = 1.5
FOV_Circle.Filled = false
FOV_Circle.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2,
                                  workspace.CurrentCamera.ViewportSize.Y / 2)

game:GetService("RunService").RenderStepped:Connect(function()
    local camera = workspace.CurrentCamera
    if camera and FOV_Circle then
        FOV_Circle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        FOV_Circle.Visible = true
    end
end)

game:GetService("Players").LocalPlayer.AncestryChanged:Connect(function()
    FOV_Circle:Remove()
end)

function getplrsname()
for i,v in pairs(game:GetChildren()) do
if v.ClassName == "Players" then
return v.Name
end
end
end
local players = getplrsname()
local plr = game[players].LocalPlayer
spawn(function()
    while wait(0.1) do
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character then
                local char = v.Character
                
                local function modifyPart(partName)
                    local part = char:FindFirstChild(partName)
                    if part then
                        pcall(function()
                            part.CanCollide = false
                            part.Size = Vector3.new(5, 5, 5)
                        end)
                    end
                end
                
                local function modifyHitbox(partName)
                    local part = char:FindFirstChild(partName)
                    if part then
                        pcall(function()
                            part.Size = Vector3.new(10, 10, 10)
                            part.Transparency = 0.7
                        end)
                    end
                end
                
                modifyPart("Head")
                modifyPart("HumanoidRootPart")
                modifyPart("UpperTorso")
                modifyPart("LowerTorso")
                modifyPart("RightUpperLeg")
                modifyPart("LeftUpperLeg")
                modifyPart("RightLowerLeg")
                modifyPart("LeftLowerLeg")
                modifyPart("RightUpperArm")
                modifyPart("LeftUpperArm")
                modifyPart("RightLowerArm")
                modifyPart("LeftLowerArm")
                
                modifyHitbox("HeadHB")
            end
        end
    end
end)

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local PlaceId = game.PlaceId

local ASSIST_RADIUS = 1000
local ASSIST_STRENGTH = 1
local MAX_DISTANCE = 1000
local isAiming = false
local FOV_DEGREES = 22.5
local FOV_RADIUS = math.cos(math.rad(FOV_DEGREES / 2))

local BOX_COLOR = Color3.new(1, 0, 0)
local BOX_TRANSPARENCY = 0.45
local BOX_SIZE = UDim2.new(4, 0, 6, 0)
local REFRESH_INTERVAL = 0.4

local infiniteJumpEnabled = true

local Configuration = {
	TeamCheck = true,
}

if CoreGui:FindFirstChild("GatyWareUI") then 
    CoreGui.GatyWareUI:Destroy() 
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GatyWareUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = CoreGui

local container = Instance.new("Frame")
container.Size = UDim2.new(1, 0, 0, 80)
container.Position = UDim2.new(0, 0, 0, 100)
container.BackgroundTransparency = 1
container.Parent = screenGui

local text = Instance.new("TextLabel")
text.Size = UDim2.new(0, 500, 1, 0)
text.Position = UDim2.new(0.5, -250, 0, 0)
text.BackgroundTransparency = 1
text.Text = "GatyWare"
text.TextScaled = true
text.Font = Enum.Font.GothamBlack
text.TextColor3 = Color3.fromRGB(160, 0, 200)
text.Parent = container

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(100,0,150)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180,0,255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(80,0,120))
}
gradient.Parent = text

local shine = Instance.new("UIGradient")
shine.Transparency = NumberSequence.new{
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.45, 1),
	NumberSequenceKeypoint.new(0.5, 0),
	NumberSequenceKeypoint.new(0.55, 1),
	NumberSequenceKeypoint.new(1, 1)
}
shine.Color = ColorSequence.new(Color3.new(1,1,1))
shine.Parent = text

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(200,0,255)
stroke.Parent = text

task.spawn(function()
	while true do
		for i = 0,360,1 do
			gradient.Rotation = i
			task.wait(0.02)
		end
	end
end)

task.spawn(function()
	while true do
		shine.Offset = Vector2.new(-1,0)
		local tween = TweenService:Create(shine, TweenInfo.new(2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut), {Offset = Vector2.new(1,0)})
		tween:Play()
		tween.Completed:Wait()
		task.wait(0.5)
	end
end)

local function IsEnemy(Player)
	if Configuration.TeamCheck then
		return Player.Team ~= LocalPlayer.Team
	end
	return true
end

local function joinDifferentServer()
	local success, serverList = pcall(function()
		return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
	end)

	if success and serverList then
		for _, server in pairs(serverList.data) do
			if server.id ~= game.JobId and server.playing < server.maxPlayers then
				TeleportService:TeleportToPlaceInstance(PlaceId, server.id, LocalPlayer)
				return
			end
		end
	else
		warn("Failed to retrieve server list.")
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.K and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		joinDifferentServer()
	end
end)

local function isWithinFOV(targetPosition)
	local directionToTarget = (targetPosition - Camera.CFrame.Position).unit
	local cameraDirection = Camera.CFrame.LookVector
	return directionToTarget:Dot(cameraDirection) >= FOV_RADIUS
end

local function getClosestPlayerToCursor()
	local closest = nil
	local shortestDistance = math.huge
	local mousePos = UserInputService:GetMouseLocation()

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and
			player.Character and
			player.Character:FindFirstChild("Head") and
			player.Character:FindFirstChild("Humanoid") and
			player.Character.Humanoid.Health > 0 and
			IsEnemy(player) then

			local headPos = player.Character.Head.Position
			local distance = (headPos - LocalPlayer.Character.Head.Position).Magnitude
			
			if distance <= MAX_DISTANCE then
				local screenPoint = Camera:WorldToScreenPoint(headPos)
				if screenPoint.Z > 0 then
					local mouseDistance = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
					if mouseDistance < shortestDistance then
						closest = player
						shortestDistance = mouseDistance
					end
				end
			end
		end
	end

	return closest
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		isAiming = true
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		isAiming = false
	end
end)

RunService:BindToRenderStep("MaxAimAssist", Enum.RenderPriority.Camera.Value + 1, function()
	if not isAiming then return end

	if not LocalPlayer.Character or
		not LocalPlayer.Character:FindFirstChild("Humanoid") or
		LocalPlayer.Character.Humanoid.Health <= 0 then
		return
	end

	local target = getClosestPlayerToCursor()
	if target then
		local targetPos = target.Character.Head.Position
		Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
	end
end)

UserInputService.JumpRequest:Connect(function()
	if infiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.F then
		infiniteJumpEnabled = not infiniteJumpEnabled
		print("Infinite Jump:", infiniteJumpEnabled)
	end
end)

local ScreenGui = Instance.new("ScreenGui")
local Indicator = Instance.new("TextLabel")

ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

Indicator.Size = UDim2.new(0, 200, 0, 25)
Indicator.Position = UDim2.new(0.5, -100, 0.9, 0)
Indicator.BackgroundTransparency = 1
Indicator.TextColor3 = Color3.new(1, 0, 0)
Indicator.Font = Enum.Font.GothamBold
Indicator.TextSize = 16
Indicator.Parent = ScreenGui

RunService.RenderStepped:Connect(function()
	Indicator.Text = isAiming and "MAX AIM ASSIST ACTIVE" or ""
end)

local function createOrRefreshTargetBox(player)
	if player ~= LocalPlayer and player.Character and IsEnemy(player) then
		local character = player.Character
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if rootPart then
			local existingBox = character:FindFirstChild("BillboardGui")
			if existingBox then
				existingBox:Destroy()
			end
			local billboard = Instance.new("BillboardGui")
			billboard.Adornee = rootPart
			billboard.Size = BOX_SIZE
			billboard.AlwaysOnTop = true
			billboard.LightInfluence = 0
			local boxFrame = Instance.new("Frame")
			boxFrame.Size = UDim2.new(1, 0, 1, 0)
			boxFrame.BackgroundTransparency = BOX_TRANSPARENCY
			boxFrame.BackgroundColor3 = BOX_COLOR
			boxFrame.BorderSizePixel = 0
			boxFrame.Parent = billboard
			billboard.Parent = character
		end
	end
end

local function refreshAllBoxes()
	for _, player in pairs(Players:GetPlayers()) do
		createOrRefreshTargetBox(player)
	end
end

refreshAllBoxes()

while true do
	wait(REFRESH_INTERVAL)
	refreshAllBoxes()
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		createOrRefreshTargetBox(player)
	end)
end)

while wait() do
	game:GetService("Players").LocalPlayer.PlayerGui.GUI.Client.Variables.ammocount.Value = 999
	game:GetService("Players").LocalPlayer.PlayerGui.GUI.Client.Variables.ammocount2.Value = 999
end
