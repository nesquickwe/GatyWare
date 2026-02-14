--[[ Enhanced ESP with 3D Boxes, China Hat, and Team Colors
    Features:
    - 2D/Corner/3D Box ESP
    - Skeleton ESP with team colors
    - Tracers with team colors
    - China Hat (circular indicator above head)
    - Health bars with multiple styles
    - Distance display
    - Rainbow modes
    - Chams support
    - Wall checks
]]

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Drawings = {
    ESP = {},
    Tracers = {},
    Boxes = {},
    Healthbars = {},
    Names = {},
    Distances = {},
    Snaplines = {},
    Skeleton = {},
    ChinaHat = {}
}

local Colors = {
    Enemy = Color3.fromRGB(255, 25, 25),
    Ally = Color3.fromRGB(25, 255, 25),
    Neutral = Color3.fromRGB(255, 255, 255),
    Selected = Color3.fromRGB(255, 210, 0),
    Health = Color3.fromRGB(0, 255, 0),
    Distance = Color3.fromRGB(200, 200, 200),
    Rainbow = nil
}

local Highlights = {}

local Settings = {
    Enabled = false,
    TeamCheck = false,
    ShowTeam = false,
    VisibilityCheck = true,
    BoxESP = false,
    BoxStyle = "Corner", -- "Corner", "Full", "ThreeD"
    BoxOutline = true,
    BoxFilled = false,
    BoxFillTransparency = 0.5,
    BoxThickness = 1,
    TracerESP = false,
    TracerOrigin = "Bottom",
    TracerStyle = "Line",
    TracerThickness = 1,
    TracerTeamColor = false, -- NEW: Use team colors for tracers
    HealthESP = false,
    HealthStyle = "Bar",
    HealthBarSide = "Left",
    HealthTextSuffix = "HP",
    NameESP = false,
    NameMode = "DisplayName",
    ShowDistance = true,
    DistanceUnit = "studs",
    TextSize = 14,
    TextFont = 2,
    RainbowSpeed = 1,
    MaxDistance = 1000,
    RefreshRate = 1/144,
    Snaplines = false,
    SnaplineStyle = "Straight",
    RainbowEnabled = false,
    RainbowBoxes = false,
    RainbowTracers = false,
    RainbowText = false,
    ChamsEnabled = false,
    ChamsOutlineColor = Color3.fromRGB(255, 255, 255),
    ChamsFillColor = Color3.fromRGB(255, 0, 0),
    ChamsOccludedColor = Color3.fromRGB(150, 0, 0),
    ChamsTransparency = 0.5,
    ChamsOutlineTransparency = 0,
    ChamsOutlineThickness = 0.1,
    SkeletonESP = false,
    SkeletonColor = Color3.fromRGB(255, 255, 255),
    SkeletonThickness = 1.5,
    SkeletonTransparency = 1,
    SkeletonTeamColor = false, -- NEW: Use team colors for skeleton
    ChinaHatESP = false, -- NEW: China Hat toggle
    ChinaHatColor = Color3.fromRGB(255, 255, 0),
    ChinaHatRadius = 2,
    ChinaHatSegments = 32,
    ChinaHatThickness = 1,
    ChinaHatTransparency = 1,
    ChinaHatTeamColor = false -- NEW: Use team colors for china hat
}

local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local box = {
        TopLeft = Drawing.new("Line"),
        TopRight = Drawing.new("Line"),
        BottomLeft = Drawing.new("Line"),
        BottomRight = Drawing.new("Line"),
        Left = Drawing.new("Line"),
        Right = Drawing.new("Line"),
        Top = Drawing.new("Line"),
        Bottom = Drawing.new("Line")
    }
    
    for _, line in pairs(box) do
        line.Visible = false
        line.Color = Colors.Enemy
        line.Thickness = Settings.BoxThickness
    end
    
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = Colors.Enemy
    tracer.Thickness = Settings.TracerThickness
    
    local healthBar = {
        Outline = Drawing.new("Square"),
        Fill = Drawing.new("Square"),
        Text = Drawing.new("Text")
    }
    
    for _, obj in pairs(healthBar) do
        obj.Visible = false
        if obj == healthBar.Fill then
            obj.Color = Colors.Health
            obj.Filled = true
        elseif obj == healthBar.Text then
            obj.Center = true
            obj.Size = Settings.TextSize
            obj.Color = Colors.Health
            obj.Font = Settings.TextFont
        end
    end
    
    local info = {
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text")
    }
    
    for _, text in pairs(info) do
        text.Visible = false
        text.Center = true
        text.Size = Settings.TextSize
        text.Color = Colors.Enemy
        text.Font = Settings.TextFont
        text.Outline = true
    end
    
    local snapline = Drawing.new("Line")
    snapline.Visible = false
    snapline.Color = Colors.Enemy
    snapline.Thickness = 1
    
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Settings.ChamsFillColor
    highlight.OutlineColor = Settings.ChamsOutlineColor
    highlight.FillTransparency = Settings.ChamsTransparency
    highlight.OutlineTransparency = Settings.ChamsOutlineTransparency
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = Settings.ChamsEnabled
    
    Highlights[player] = highlight
    
    local skeleton = {
        -- Spine & Head
        Head = Drawing.new("Line"),
        Neck = Drawing.new("Line"),
        UpperSpine = Drawing.new("Line"),
        LowerSpine = Drawing.new("Line"),
        
        -- Left Arm
        LeftShoulder = Drawing.new("Line"),
        LeftUpperArm = Drawing.new("Line"),
        LeftLowerArm = Drawing.new("Line"),
        LeftHand = Drawing.new("Line"),
        
        -- Right Arm
        RightShoulder = Drawing.new("Line"),
        RightUpperArm = Drawing.new("Line"),
        RightLowerArm = Drawing.new("Line"),
        RightHand = Drawing.new("Line"),
        
        -- Left Leg
        LeftHip = Drawing.new("Line"),
        LeftUpperLeg = Drawing.new("Line"),
        LeftLowerLeg = Drawing.new("Line"),
        LeftFoot = Drawing.new("Line"),
        
        -- Right Leg
        RightHip = Drawing.new("Line"),
        RightUpperLeg = Drawing.new("Line"),
        RightLowerLeg = Drawing.new("Line"),
        RightFoot = Drawing.new("Line")
    }
    
    for _, line in pairs(skeleton) do
        line.Visible = false
        line.Color = Settings.SkeletonColor
        line.Thickness = Settings.SkeletonThickness
        line.Transparency = Settings.SkeletonTransparency
    end
    
    Drawings.Skeleton[player] = skeleton
    
    -- China Hat (circle above head)
    local chinaHat = {}
    for i = 1, Settings.ChinaHatSegments do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = Settings.ChinaHatColor
        line.Thickness = Settings.ChinaHatThickness
        line.Transparency = Settings.ChinaHatTransparency
        chinaHat[i] = line
    end
    
    Drawings.ChinaHat[player] = chinaHat
    
    Drawings.ESP[player] = {
        Box = box,
        Tracer = tracer,
        HealthBar = healthBar,
        Info = info,
        Snapline = snapline
    }
end

local function RemoveESP(player)
    local esp = Drawings.ESP[player]
    if esp then
        for _, obj in pairs(esp.Box) do obj:Remove() end
        esp.Tracer:Remove()
        for _, obj in pairs(esp.HealthBar) do obj:Remove() end
        for _, obj in pairs(esp.Info) do obj:Remove() end
        esp.Snapline:Remove()
        Drawings.ESP[player] = nil
    end
    
    local highlight = Highlights[player]
    if highlight then
        highlight:Destroy()
        Highlights[player] = nil
    end
    
    local skeleton = Drawings.Skeleton[player]
    if skeleton then
        for _, line in pairs(skeleton) do
            line:Remove()
        end
        Drawings.Skeleton[player] = nil
    end
    
    local chinaHat = Drawings.ChinaHat[player]
    if chinaHat then
        for _, line in pairs(chinaHat) do
            line:Remove()
        end
        Drawings.ChinaHat[player] = nil
    end
end

local function GetPlayerColor(player)
    if Settings.RainbowEnabled then
        if Settings.RainbowBoxes and Settings.BoxESP then return Colors.Rainbow end
        if Settings.RainbowTracers and Settings.TracerESP then return Colors.Rainbow end
        if Settings.RainbowText and (Settings.NameESP or Settings.HealthESP) then return Colors.Rainbow end
    end
    
    -- Team color logic
    if player.Team == LocalPlayer.Team then
        return Colors.Ally
    else
        return Colors.Enemy
    end
end

local function GetTracerOrigin()
    local origin = Settings.TracerOrigin
    if origin == "Bottom" then
        return Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
    elseif origin == "Top" then
        return Vector2.new(Camera.ViewportSize.X/2, 0)
    elseif origin == "Mouse" then
        return UserInputService:GetMouseLocation()
    else
        return Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    end
end

local function UpdateESP(player)
    if not Settings.Enabled then return end
    
    local esp = Drawings.ESP[player]
    if not esp then return end
    
    local character = player.Character
    if not character then 
        for _, obj in pairs(esp.Box) do obj.Visible = false end
        esp.Tracer.Visible = false
        for _, obj in pairs(esp.HealthBar) do obj.Visible = false end
        for _, obj in pairs(esp.Info) do obj.Visible = false end
        esp.Snapline.Visible = false
        
        local skeleton = Drawings.Skeleton[player]
        if skeleton then
            for _, line in pairs(skeleton) do
                line.Visible = false
            end
        end
        
        local chinaHat = Drawings.ChinaHat[player]
        if chinaHat then
            for _, line in pairs(chinaHat) do
                line.Visible = false
            end
        end
        return 
    end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then 
        for _, obj in pairs(esp.Box) do obj.Visible = false end
        esp.Tracer.Visible = false
        for _, obj in pairs(esp.HealthBar) do obj.Visible = false end
        for _, obj in pairs(esp.Info) do obj.Visible = false end
        esp.Snapline.Visible = false
        
        local skeleton = Drawings.Skeleton[player]
        if skeleton then
            for _, line in pairs(skeleton) do
                line.Visible = false
            end
        end
        
        local chinaHat = Drawings.ChinaHat[player]
        if chinaHat then
            for _, line in pairs(chinaHat) do
                line.Visible = false
            end
        end
        return 
    end
    
    local _, isOnScreen = Camera:WorldToViewportPoint(rootPart.Position)
    if not isOnScreen then
        for _, obj in pairs(esp.Box) do obj.Visible = false end
        esp.Tracer.Visible = false
        for _, obj in pairs(esp.HealthBar) do obj.Visible = false end
        for _, obj in pairs(esp.Info) do obj.Visible = false end
        esp.Snapline.Visible = false
        
        local skeleton = Drawings.Skeleton[player]
        if skeleton then
            for _, line in pairs(skeleton) do
                line.Visible = false
            end
        end
        
        local chinaHat = Drawings.ChinaHat[player]
        if chinaHat then
            for _, line in pairs(chinaHat) do
                line.Visible = false
            end
        end
        return
    end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        for _, obj in pairs(esp.Box) do obj.Visible = false end
        esp.Tracer.Visible = false
        for _, obj in pairs(esp.HealthBar) do obj.Visible = false end
        for _, obj in pairs(esp.Info) do obj.Visible = false end
        esp.Snapline.Visible = false
        
        local skeleton = Drawings.Skeleton[player]
        if skeleton then
            for _, line in pairs(skeleton) do
                line.Visible = false
            end
        end
        
        local chinaHat = Drawings.ChinaHat[player]
        if chinaHat then
            for _, line in pairs(chinaHat) do
                line.Visible = false
            end
        end
        return
    end
    
    local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
    local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
    
    if not onScreen or distance > Settings.MaxDistance then
        for _, obj in pairs(esp.Box) do obj.Visible = false end
        esp.Tracer.Visible = false
        for _, obj in pairs(esp.HealthBar) do obj.Visible = false end
        for _, obj in pairs(esp.Info) do obj.Visible = false end
        esp.Snapline.Visible = false
        
        local skeleton = Drawings.Skeleton[player]
        if skeleton then
            for _, line in pairs(skeleton) do
                line.Visible = false
            end
        end
        
        local chinaHat = Drawings.ChinaHat[player]
        if chinaHat then
            for _, line in pairs(chinaHat) do
                line.Visible = false
            end
        end
        return
    end
    
    if Settings.TeamCheck and player.Team == LocalPlayer.Team and not Settings.ShowTeam then
        for _, obj in pairs(esp.Box) do obj.Visible = false end
        esp.Tracer.Visible = false
        for _, obj in pairs(esp.HealthBar) do obj.Visible = false end
        for _, obj in pairs(esp.Info) do obj.Visible = false end
        esp.Snapline.Visible = false
        
        local skeleton = Drawings.Skeleton[player]
        if skeleton then
            for _, line in pairs(skeleton) do
                line.Visible = false
            end
        end
        
        local chinaHat = Drawings.ChinaHat[player]
        if chinaHat then
            for _, line in pairs(chinaHat) do
                line.Visible = false
            end
        end
        return
    end
    
    local color = GetPlayerColor(player)
    local size = character:GetExtentsSize()
    local cf = rootPart.CFrame
    
    local top, top_onscreen = Camera:WorldToViewportPoint(cf * CFrame.new(0, size.Y/2, 0).Position)
    local bottom, bottom_onscreen = Camera:WorldToViewportPoint(cf * CFrame.new(0, -size.Y/2, 0).Position)
    
    if not top_onscreen or not bottom_onscreen then
        for _, obj in pairs(esp.Box) do obj.Visible = false end
        return
    end
    
    local screenSize = bottom.Y - top.Y
    local boxWidth = screenSize * 0.65
    local boxPosition = Vector2.new(top.X - boxWidth/2, top.Y)
    local boxSize = Vector2.new(boxWidth, screenSize)
    
    for _, obj in pairs(esp.Box) do
        obj.Visible = false
    end
    
    if Settings.BoxESP then
        if Settings.BoxStyle == "ThreeD" then
            local corners = {
                FrontTopLeft = Camera:WorldToViewportPoint((cf * CFrame.new(-size.X/2, size.Y/2, -size.Z/2)).Position),
                FrontTopRight = Camera:WorldToViewportPoint((cf * CFrame.new(size.X/2, size.Y/2, -size.Z/2)).Position),
                FrontBottomLeft = Camera:WorldToViewportPoint((cf * CFrame.new(-size.X/2, -size.Y/2, -size.Z/2)).Position),
                FrontBottomRight = Camera:WorldToViewportPoint((cf * CFrame.new(size.X/2, -size.Y/2, -size.Z/2)).Position),
                BackTopLeft = Camera:WorldToViewportPoint((cf * CFrame.new(-size.X/2, size.Y/2, size.Z/2)).Position),
                BackTopRight = Camera:WorldToViewportPoint((cf * CFrame.new(size.X/2, size.Y/2, size.Z/2)).Position),
                BackBottomLeft = Camera:WorldToViewportPoint((cf * CFrame.new(-size.X/2, -size.Y/2, size.Z/2)).Position),
                BackBottomRight = Camera:WorldToViewportPoint((cf * CFrame.new(size.X/2, -size.Y/2, size.Z/2)).Position)
            }
            
            local allVisible = true
            for _, corner in pairs(corners) do
                if corner.Z <= 0 then
                    allVisible = false
                    break
                end
            end
            
            if not allVisible then
                for _, obj in pairs(esp.Box) do obj.Visible = false end
                return
            end
            
            local function toVec2(v3) return Vector2.new(v3.X, v3.Y) end
            
            -- Front face
            esp.Box.TopLeft.From = toVec2(corners.FrontTopLeft)
            esp.Box.TopLeft.To = toVec2(corners.FrontTopRight)
            esp.Box.TopLeft.Visible = true
            
            esp.Box.TopRight.From = toVec2(corners.FrontTopRight)
            esp.Box.TopRight.To = toVec2(corners.FrontBottomRight)
            esp.Box.TopRight.Visible = true
            
            esp.Box.BottomLeft.From = toVec2(corners.FrontBottomLeft)
            esp.Box.BottomLeft.To = toVec2(corners.FrontBottomRight)
            esp.Box.BottomLeft.Visible = true
            
            esp.Box.BottomRight.From = toVec2(corners.FrontTopLeft)
            esp.Box.BottomRight.To = toVec2(corners.FrontBottomLeft)
            esp.Box.BottomRight.Visible = true
            
            -- Back face
            esp.Box.Left.From = toVec2(corners.BackTopLeft)
            esp.Box.Left.To = toVec2(corners.BackTopRight)
            esp.Box.Left.Visible = true
            
            esp.Box.Right.From = toVec2(corners.BackTopRight)
            esp.Box.Right.To = toVec2(corners.BackBottomRight)
            esp.Box.Right.Visible = true
            
            esp.Box.Top.From = toVec2(corners.BackBottomLeft)
            esp.Box.Top.To = toVec2(corners.BackBottomRight)
            esp.Box.Top.Visible = true
            
            esp.Box.Bottom.From = toVec2(corners.BackTopLeft)
            esp.Box.Bottom.To = toVec2(corners.BackBottomLeft)
            esp.Box.Bottom.Visible = true
            
        elseif Settings.BoxStyle == "Corner" then
            local cornerSize = boxWidth * 0.2
            
            esp.Box.TopLeft.From = boxPosition
            esp.Box.TopLeft.To = boxPosition + Vector2.new(cornerSize, 0)
            esp.Box.TopLeft.Visible = true
            
            esp.Box.TopRight.From = boxPosition + Vector2.new(boxSize.X, 0)
            esp.Box.TopRight.To = boxPosition + Vector2.new(boxSize.X - cornerSize, 0)
            esp.Box.TopRight.Visible = true
            
            esp.Box.BottomLeft.From = boxPosition + Vector2.new(0, boxSize.Y)
            esp.Box.BottomLeft.To = boxPosition + Vector2.new(cornerSize, boxSize.Y)
            esp.Box.BottomLeft.Visible = true
            
            esp.Box.BottomRight.From = boxPosition + Vector2.new(boxSize.X, boxSize.Y)
            esp.Box.BottomRight.To = boxPosition + Vector2.new(boxSize.X - cornerSize, boxSize.Y)
            esp.Box.BottomRight.Visible = true
            
            esp.Box.Left.From = boxPosition
            esp.Box.Left.To = boxPosition + Vector2.new(0, cornerSize)
            esp.Box.Left.Visible = true
            
            esp.Box.Right.From = boxPosition + Vector2.new(boxSize.X, 0)
            esp.Box.Right.To = boxPosition + Vector2.new(boxSize.X, cornerSize)
            esp.Box.Right.Visible = true
            
            esp.Box.Top.From = boxPosition + Vector2.new(0, boxSize.Y)
            esp.Box.Top.To = boxPosition + Vector2.new(0, boxSize.Y - cornerSize)
            esp.Box.Top.Visible = true
            
            esp.Box.Bottom.From = boxPosition + Vector2.new(boxSize.X, boxSize.Y)
            esp.Box.Bottom.To = boxPosition + Vector2.new(boxSize.X, boxSize.Y - cornerSize)
            esp.Box.Bottom.Visible = true
            
        else -- Full box
            esp.Box.Left.From = boxPosition
            esp.Box.Left.To = boxPosition + Vector2.new(0, boxSize.Y)
            esp.Box.Left.Visible = true
            
            esp.Box.Right.From = boxPosition + Vector2.new(boxSize.X, 0)
            esp.Box.Right.To = boxPosition + Vector2.new(boxSize.X, boxSize.Y)
            esp.Box.Right.Visible = true
            
            esp.Box.Top.From = boxPosition
            esp.Box.Top.To = boxPosition + Vector2.new(boxSize.X, 0)
            esp.Box.Top.Visible = true
            
            esp.Box.Bottom.From = boxPosition + Vector2.new(0, boxSize.Y)
            esp.Box.Bottom.To = boxPosition + Vector2.new(boxSize.X, boxSize.Y)
            esp.Box.Bottom.Visible = true
        end
        
        for _, obj in pairs(esp.Box) do
            if obj.Visible then
                obj.Color = color
                obj.Thickness = Settings.BoxThickness
            end
        end
    end
    
    if Settings.TracerESP then
        local tracerColor = color
        if Settings.TracerTeamColor then
            tracerColor = player.Team == LocalPlayer.Team and Colors.Ally or Colors.Enemy
        end
        if Settings.RainbowEnabled and Settings.RainbowTracers then
            tracerColor = Colors.Rainbow
        end
        
        esp.Tracer.From = GetTracerOrigin()
        esp.Tracer.To = Vector2.new(pos.X, pos.Y)
        esp.Tracer.Color = tracerColor
        esp.Tracer.Thickness = Settings.TracerThickness
        esp.Tracer.Visible = true
    else
        esp.Tracer.Visible = false
    end
    
    if Settings.HealthESP then
        local health = humanoid.Health
        local maxHealth = humanoid.MaxHealth
        local healthPercent = health/maxHealth
        
        local barHeight = screenSize * 0.8
        local barWidth = 4
        local barPos = Vector2.new(
            boxPosition.X - barWidth - 2,
            boxPosition.Y + (screenSize - barHeight)/2
        )
        
        esp.HealthBar.Outline.Size = Vector2.new(barWidth, barHeight)
        esp.HealthBar.Outline.Position = barPos
        esp.HealthBar.Outline.Visible = true
        
        esp.HealthBar.Fill.Size = Vector2.new(barWidth - 2, barHeight * healthPercent)
        esp.HealthBar.Fill.Position = Vector2.new(barPos.X + 1, barPos.Y + barHeight * (1-healthPercent))
        esp.HealthBar.Fill.Color = Color3.fromRGB(255 - (255 * healthPercent), 255 * healthPercent, 0)
        esp.HealthBar.Fill.Visible = true
        
        if Settings.HealthStyle == "Both" or Settings.HealthStyle == "Text" then
            esp.HealthBar.Text.Text = math.floor(health) .. Settings.HealthTextSuffix
            esp.HealthBar.Text.Position = Vector2.new(barPos.X + barWidth + 2, barPos.Y + barHeight/2)
            esp.HealthBar.Text.Visible = true
        else
            esp.HealthBar.Text.Visible = false
        end
    else
        for _, obj in pairs(esp.HealthBar) do
            obj.Visible = false
        end
    end
    
    if Settings.NameESP then
        local nameText = Settings.NameMode == "DisplayName" and player.DisplayName or player.Name
        esp.Info.Name.Text = nameText
        esp.Info.Name.Position = Vector2.new(
            boxPosition.X + boxWidth/2,
            boxPosition.Y - 20
        )
        esp.Info.Name.Color = color
        esp.Info.Name.Size = Settings.TextSize
        esp.Info.Name.Visible = true
    else
        esp.Info.Name.Visible = false
    end
    
    if Settings.ShowDistance then
        esp.Info.Distance.Text = string.format("[%d %s]", math.floor(distance), Settings.DistanceUnit)
        esp.Info.Distance.Position = Vector2.new(
            boxPosition.X + boxWidth/2,
            boxPosition.Y + screenSize + 5
        )
        esp.Info.Distance.Color = Colors.Distance
        esp.Info.Distance.Size = Settings.TextSize - 2
        esp.Info.Distance.Visible = true
    else
        esp.Info.Distance.Visible = false
    end
    
    if Settings.Snaplines then
        esp.Snapline.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
        esp.Snapline.To = Vector2.new(pos.X, pos.Y)
        esp.Snapline.Color = color
        esp.Snapline.Visible = true
    else
        esp.Snapline.Visible = false
    end
    
    local highlight = Highlights[player]
    if highlight then
        if Settings.ChamsEnabled and character then
            highlight.Parent = character
            highlight.FillColor = Settings.ChamsFillColor
            highlight.OutlineColor = Settings.ChamsOutlineColor
            highlight.FillTransparency = Settings.ChamsTransparency
            highlight.OutlineTransparency = Settings.ChamsOutlineTransparency
            highlight.Enabled = true
        else
            highlight.Enabled = false
        end
    end
    
    -- Skeleton ESP with team colors
    if Settings.SkeletonESP then
        local function getBonePositions(character)
            if not character then return nil end
            
            local bones = {
                Head = character:FindFirstChild("Head"),
                UpperTorso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso"),
                LowerTorso = character:FindFirstChild("LowerTorso") or character:FindFirstChild("Torso"),
                RootPart = character:FindFirstChild("HumanoidRootPart"),
                
                LeftUpperArm = character:FindFirstChild("LeftUpperArm") or character:FindFirstChild("Left Arm"),
                LeftLowerArm = character:FindFirstChild("LeftLowerArm") or character:FindFirstChild("Left Arm"),
                LeftHand = character:FindFirstChild("LeftHand") or character:FindFirstChild("Left Arm"),
                
                RightUpperArm = character:FindFirstChild("RightUpperArm") or character:FindFirstChild("Right Arm"),
                RightLowerArm = character:FindFirstChild("RightLowerArm") or character:FindFirstChild("Right Arm"),
                RightHand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm"),
                
                LeftUpperLeg = character:FindFirstChild("LeftUpperLeg") or character:FindFirstChild("Left Leg"),
                LeftLowerLeg = character:FindFirstChild("LeftLowerLeg") or character:FindFirstChild("Left Leg"),
                LeftFoot = character:FindFirstChild("LeftFoot") or character:FindFirstChild("Left Leg"),
                
                RightUpperLeg = character:FindFirstChild("RightUpperLeg") or character:FindFirstChild("Right Leg"),
                RightLowerLeg = character:FindFirstChild("RightLowerLeg") or character:FindFirstChild("Right Leg"),
                RightFoot = character:FindFirstChild("RightFoot") or character:FindFirstChild("Right Leg")
            }
            
            if not (bones.Head and bones.UpperTorso) then return nil end
            
            return bones
        end
        
        local function drawBone(from, to, line)
            if not from or not to then 
                line.Visible = false
                return 
            end
            
            local fromPos = from.Position
            local toPos = to.Position
            
            local fromScreen, fromVisible = Camera:WorldToViewportPoint(fromPos)
            local toScreen, toVisible = Camera:WorldToViewportPoint(toPos)
            
            if not (fromVisible and toVisible) or fromScreen.Z < 0 or toScreen.Z < 0 then
                line.Visible = false
                return
            end
            
            line.From = Vector2.new(fromScreen.X, fromScreen.Y)
            line.To = Vector2.new(toScreen.X, toScreen.Y)
            
            -- Apply team color if enabled
            if Settings.SkeletonTeamColor then
                line.Color = player.Team == LocalPlayer.Team and Colors.Ally or Colors.Enemy
            else
                line.Color = Settings.SkeletonColor
            end
            
            line.Thickness = Settings.SkeletonThickness
            line.Transparency = Settings.SkeletonTransparency
            line.Visible = true
        end
        
        local bones = getBonePositions(character)
        if bones then
            local skeleton = Drawings.Skeleton[player]
            if skeleton then
                drawBone(bones.Head, bones.UpperTorso, skeleton.Head)
                drawBone(bones.UpperTorso, bones.LowerTorso, skeleton.UpperSpine)
                
                drawBone(bones.UpperTorso, bones.LeftUpperArm, skeleton.LeftShoulder)
                drawBone(bones.LeftUpperArm, bones.LeftLowerArm, skeleton.LeftUpperArm)
                drawBone(bones.LeftLowerArm, bones.LeftHand, skeleton.LeftLowerArm)
                
                drawBone(bones.UpperTorso, bones.RightUpperArm, skeleton.RightShoulder)
                drawBone(bones.RightUpperArm, bones.RightLowerArm, skeleton.RightUpperArm)
                drawBone(bones.RightLowerArm, bones.RightHand, skeleton.RightLowerArm)
                
                drawBone(bones.LowerTorso, bones.LeftUpperLeg, skeleton.LeftHip)
                drawBone(bones.LeftUpperLeg, bones.LeftLowerLeg, skeleton.LeftUpperLeg)
                drawBone(bones.LeftLowerLeg, bones.LeftFoot, skeleton.LeftLowerLeg)
                
                drawBone(bones.LowerTorso, bones.RightUpperLeg, skeleton.RightHip)
                drawBone(bones.RightUpperLeg, bones.RightLowerLeg, skeleton.RightUpperLeg)
                drawBone(bones.RightLowerLeg, bones.RightFoot, skeleton.RightLowerLeg)
            end
        end
    else
        local skeleton = Drawings.Skeleton[player]
        if skeleton then
            for _, line in pairs(skeleton) do
                line.Visible = false
            end
        end
    end
    
    -- China Hat ESP
    if Settings.ChinaHatESP then
        local head = character:FindFirstChild("Head")
        if head then
            local hatCenter = head.Position + Vector3.new(0, Settings.ChinaHatRadius + 0.5, 0)
            local hatCenterScreen, hatVisible = Camera:WorldToViewportPoint(hatCenter)
            
            if hatVisible and hatCenterScreen.Z > 0 then
                local chinaHat = Drawings.ChinaHat[player]
                if chinaHat then
                    local segments = Settings.ChinaHatSegments
                    local angleStep = (2 * math.pi) / segments
                    
                    -- Determine color for china hat
                    local hatColor = Settings.ChinaHatColor
                    if Settings.ChinaHatTeamColor then
                        hatColor = player.Team == LocalPlayer.Team and Colors.Ally or Colors.Enemy
                    end
                    if Settings.RainbowEnabled then
                        hatColor = Colors.Rainbow
                    end
                    
                    for i = 1, segments do
                        local angle1 = angleStep * (i - 1)
                        local angle2 = angleStep * i
                        
                        local point1 = hatCenter + Vector3.new(
                            math.cos(angle1) * Settings.ChinaHatRadius,
                            0,
                            math.sin(angle1) * Settings.ChinaHatRadius
                        )
                        local point2 = hatCenter + Vector3.new(
                            math.cos(angle2) * Settings.ChinaHatRadius,
                            0,
                            math.sin(angle2) * Settings.ChinaHatRadius
                        )
                        
                        local screen1, vis1 = Camera:WorldToViewportPoint(point1)
                        local screen2, vis2 = Camera:WorldToViewportPoint(point2)
                        
                        if vis1 and vis2 and screen1.Z > 0 and screen2.Z > 0 then
                            chinaHat[i].From = Vector2.new(screen1.X, screen1.Y)
                            chinaHat[i].To = Vector2.new(screen2.X, screen2.Y)
                            chinaHat[i].Color = hatColor
                            chinaHat[i].Thickness = Settings.ChinaHatThickness
                            chinaHat[i].Transparency = Settings.ChinaHatTransparency
                            chinaHat[i].Visible = true
                        else
                            chinaHat[i].Visible = false
                        end
                    end
                end
            else
                local chinaHat = Drawings.ChinaHat[player]
                if chinaHat then
                    for _, line in pairs(chinaHat) do
                        line.Visible = false
                    end
                end
            end
        else
            local chinaHat = Drawings.ChinaHat[player]
            if chinaHat then
                for _, line in pairs(chinaHat) do
                    line.Visible = false
                end
            end
        end
    else
        local chinaHat = Drawings.ChinaHat[player]
        if chinaHat then
            for _, line in pairs(chinaHat) do
                line.Visible = false
            end
        end
    end
end

local function DisableESP()
    for _, player in ipairs(Players:GetPlayers()) do
        local esp = Drawings.ESP[player]
        if esp then
            for _, obj in pairs(esp.Box) do obj.Visible = false end
            esp.Tracer.Visible = false
            for _, obj in pairs(esp.HealthBar) do obj.Visible = false end
            for _, obj in pairs(esp.Info) do obj.Visible = false end
            esp.Snapline.Visible = false
        end
        
        local skeleton = Drawings.Skeleton[player]
        if skeleton then
            for _, line in pairs(skeleton) do
                line.Visible = false
            end
        end
        
        local chinaHat = Drawings.ChinaHat[player]
        if chinaHat then
            for _, line in pairs(chinaHat) do
                line.Visible = false
            end
        end
    end
end

local function CleanupESP()
    for _, player in ipairs(Players:GetPlayers()) do
        RemoveESP(player)
    end
    Drawings.ESP = {}
    Drawings.Skeleton = {}
    Drawings.ChinaHat = {}
    Highlights = {}
end

local Window = Fluent:CreateWindow({
    Title = "WA Universal ESP - Enhanced",
    SubTitle = "by WA",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
    Config = Window:AddTab({ Title = "Config", Icon = "save" })
}

do
    local MainSection = Tabs.ESP:AddSection("Main ESP")
    
    local EnabledToggle = MainSection:AddToggle("Enabled", {
        Title = "Enable ESP",
        Default = false
    })
    EnabledToggle:OnChanged(function()
        Settings.Enabled = EnabledToggle.Value
        if not Settings.Enabled then
            CleanupESP()
        else
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    CreateESP(player)
                end
            end
        end
    end)
    
    local TeamCheckToggle = MainSection:AddToggle("TeamCheck", {
        Title = "Team Check",
        Default = false
    })
    TeamCheckToggle:OnChanged(function()
        Settings.TeamCheck = TeamCheckToggle.Value
    end)
    
    local ShowTeamToggle = MainSection:AddToggle("ShowTeam", {
        Title = "Show Team",
        Default = false
    })
    ShowTeamToggle:OnChanged(function()
        Settings.ShowTeam = ShowTeamToggle.Value
    end)
    
    local BoxSection = Tabs.ESP:AddSection("Box ESP")
    
    local BoxESPToggle = BoxSection:AddToggle("BoxESP", {
        Title = "Box ESP",
        Default = false
    })
    BoxESPToggle:OnChanged(function()
        Settings.BoxESP = BoxESPToggle.Value
    end)
    
    local BoxStyleDropdown = BoxSection:AddDropdown("BoxStyle", {
        Title = "Box Style",
        Values = {"Corner", "Full", "ThreeD"},
        Default = "Corner"
    })
    BoxStyleDropdown:OnChanged(function(Value)
        Settings.BoxStyle = Value
    end)
    
    local BoxThickness = BoxSection:AddSlider("BoxThickness", {
        Title = "Box Thickness",
        Default = 1,
        Min = 1,
        Max = 5,
        Rounding = 1
    })
    BoxThickness:OnChanged(function(Value)
        Settings.BoxThickness = Value
    end)
    
    local TracerSection = Tabs.ESP:AddSection("Tracer ESP")
    
    local TracerESPToggle = TracerSection:AddToggle("TracerESP", {
        Title = "Tracer ESP",
        Default = false
    })
    TracerESPToggle:OnChanged(function()
        Settings.TracerESP = TracerESPToggle.Value
    end)
    
    local TracerOriginDropdown = TracerSection:AddDropdown("TracerOrigin", {
        Title = "Tracer Origin",
        Values = {"Bottom", "Top", "Mouse", "Center"},
        Default = "Bottom"
    })
    TracerOriginDropdown:OnChanged(function(Value)
        Settings.TracerOrigin = Value
    end)
    
    local TracerThickness = TracerSection:AddSlider("TracerThickness", {
        Title = "Tracer Thickness",
        Default = 1,
        Min = 1,
        Max = 5,
        Rounding = 1
    })
    TracerThickness:OnChanged(function(Value)
        Settings.TracerThickness = Value
    end)
    
    local TracerTeamColorToggle = TracerSection:AddToggle("TracerTeamColor", {
        Title = "Use Team Colors",
        Default = false
    })
    TracerTeamColorToggle:OnChanged(function()
        Settings.TracerTeamColor = TracerTeamColorToggle.Value
    end)
    
    local ChamsSection = Tabs.ESP:AddSection("Chams")
    
    local ChamsToggle = ChamsSection:AddToggle("ChamsEnabled", {
        Title = "Enable Chams",
        Default = false
    })
    ChamsToggle:OnChanged(function()
        Settings.ChamsEnabled = ChamsToggle.Value
    end)
    
    local ChamsFillColor = ChamsSection:AddColorpicker("ChamsFillColor", {
        Title = "Fill Color",
        Description = "Color for visible parts",
        Default = Settings.ChamsFillColor
    })
    ChamsFillColor:OnChanged(function(Value)
        Settings.ChamsFillColor = Value
    end)
    
    local ChamsOccludedColor = ChamsSection:AddColorpicker("ChamsOccludedColor", {
        Title = "Occluded Color",
        Description = "Color for parts behind walls",
        Default = Settings.ChamsOccludedColor
    })
    ChamsOccludedColor:OnChanged(function(Value)
        Settings.ChamsOccludedColor = Value
    end)
    
    local ChamsOutlineColor = ChamsSection:AddColorpicker("ChamsOutlineColor", {
        Title = "Outline Color",
        Description = "Color for character outline",
        Default = Settings.ChamsOutlineColor
    })
    ChamsOutlineColor:OnChanged(function(Value)
        Settings.ChamsOutlineColor = Value
    end)
    
    local ChamsTransparency = ChamsSection:AddSlider("ChamsTransparency", {
        Title = "Fill Transparency",
        Description = "Transparency of the fill color",
        Default = 0.5,
        Min = 0,
        Max = 1,
        Rounding = 2
    })
    ChamsTransparency:OnChanged(function(Value)
        Settings.ChamsTransparency = Value
    end)
    
    local HealthSection = Tabs.ESP:AddSection("Health ESP")
    
    local HealthESPToggle = HealthSection:AddToggle("HealthESP", {
        Title = "Health Bar",
        Default = false
    })
    HealthESPToggle:OnChanged(function()
        Settings.HealthESP = HealthESPToggle.Value
    end)
    
    local HealthStyleDropdown = HealthSection:AddDropdown("HealthStyle", {
        Title = "Health Style",
        Values = {"Bar", "Text", "Both"},
        Default = "Bar"
    })
    HealthStyleDropdown:OnChanged(function(Value)
        Settings.HealthStyle = Value
    end)
    
    local SkeletonSection = Tabs.ESP:AddSection("Skeleton ESP")
    
    local SkeletonESPToggle = SkeletonSection:AddToggle("SkeletonESP", {
        Title = "Skeleton ESP",
        Default = false
    })
    SkeletonESPToggle:OnChanged(function()
        Settings.SkeletonESP = SkeletonESPToggle.Value
    end)
    
    local SkeletonColor = SkeletonSection:AddColorpicker("SkeletonColor", {
        Title = "Skeleton Color",
        Default = Settings.SkeletonColor
    })
    SkeletonColor:OnChanged(function(Value)
        Settings.SkeletonColor = Value
    end)
    
    local SkeletonThickness = SkeletonSection:AddSlider("SkeletonThickness", {
        Title = "Line Thickness",
        Default = 1.5,
        Min = 1,
        Max = 5,
        Rounding = 1
    })
    SkeletonThickness:OnChanged(function(Value)
        Settings.SkeletonThickness = Value
    end)
    
    local SkeletonTeamColorToggle = SkeletonSection:AddToggle("SkeletonTeamColor", {
        Title = "Use Team Colors",
        Default = false
    })
    SkeletonTeamColorToggle:OnChanged(function()
        Settings.SkeletonTeamColor = SkeletonTeamColorToggle.Value
    end)
    
    local ChinaHatSection = Tabs.ESP:AddSection("China Hat")
    
    local ChinaHatToggle = ChinaHatSection:AddToggle("ChinaHatESP", {
        Title = "Enable China Hat",
        Default = false
    })
    ChinaHatToggle:OnChanged(function()
        Settings.ChinaHatESP = ChinaHatToggle.Value
    end)
    
    local ChinaHatColor = ChinaHatSection:AddColorpicker("ChinaHatColor", {
        Title = "China Hat Color",
        Default = Settings.ChinaHatColor
    })
    ChinaHatColor:OnChanged(function(Value)
        Settings.ChinaHatColor = Value
    end)
    
    local ChinaHatRadius = ChinaHatSection:AddSlider("ChinaHatRadius", {
        Title = "Hat Radius",
        Default = 2,
        Min = 1,
        Max = 5,
        Rounding = 1
    })
    ChinaHatRadius:OnChanged(function(Value)
        Settings.ChinaHatRadius = Value
    end)
    
    local ChinaHatThickness = ChinaHatSection:AddSlider("ChinaHatThickness", {
        Title = "Line Thickness",
        Default = 1,
        Min = 1,
        Max = 3,
        Rounding = 1
    })
    ChinaHatThickness:OnChanged(function(Value)
        Settings.ChinaHatThickness = Value
    end)
    
    local ChinaHatTeamColorToggle = ChinaHatSection:AddToggle("ChinaHatTeamColor", {
        Title = "Use Team Colors",
        Default = false
    })
    ChinaHatTeamColorToggle:OnChanged(function()
        Settings.ChinaHatTeamColor = ChinaHatTeamColorToggle.Value
    end)
    
    local NameSection = Tabs.ESP:AddSection("Name & Info")
    
    local NameESPToggle = NameSection:AddToggle("NameESP", {
        Title = "Show Names",
        Default = false
    })
    NameESPToggle:OnChanged(function()
        Settings.NameESP = NameESPToggle.Value
    end)
    
    local NameModeDropdown = NameSection:AddDropdown("NameMode", {
        Title = "Name Mode",
        Values = {"DisplayName", "Username"},
        Default = "DisplayName"
    })
    NameModeDropdown:OnChanged(function(Value)
        Settings.NameMode = Value
    end)
    
    local ShowDistanceToggle = NameSection:AddToggle("ShowDistance", {
        Title = "Show Distance",
        Default = true
    })
    ShowDistanceToggle:OnChanged(function()
        Settings.ShowDistance = ShowDistanceToggle.Value
    end)
end

do
    local ColorsSection = Tabs.Settings:AddSection("Colors")
    
    local EnemyColor = ColorsSection:AddColorpicker("EnemyColor", {
        Title = "Enemy Color",
        Description = "Color for enemy players",
        Default = Colors.Enemy
    })
    EnemyColor:OnChanged(function(Value)
        Colors.Enemy = Value
    end)
    
    local AllyColor = ColorsSection:AddColorpicker("AllyColor", {
        Title = "Ally Color",
        Description = "Color for team members",
        Default = Colors.Ally
    })
    AllyColor:OnChanged(function(Value)
        Colors.Ally = Value
    end)
    
    local EffectsSection = Tabs.Settings:AddSection("Effects")
    
    local RainbowToggle = EffectsSection:AddToggle("RainbowEnabled", {
        Title = "Rainbow Mode",
        Default = false
    })
    RainbowToggle:OnChanged(function()
        Settings.RainbowEnabled = RainbowToggle.Value
    end)
    
    local RainbowSpeed = EffectsSection:AddSlider("RainbowSpeed", {
        Title = "Rainbow Speed",
        Default = 1,
        Min = 0.1,
        Max = 5,
        Rounding = 1
    })
    RainbowSpeed:OnChanged(function(Value)
        Settings.RainbowSpeed = Value
    end)
    
    local RainbowOptions = EffectsSection:AddDropdown("RainbowParts", {
        Title = "Rainbow Parts",
        Values = {"All", "Box Only", "Tracers Only", "Text Only"},
        Default = "All",
        Multi = false
    })
    RainbowOptions:OnChanged(function(Value)
        if Value == "All" then
            Settings.RainbowBoxes = true
            Settings.RainbowTracers = true
            Settings.RainbowText = true
        elseif Value == "Box Only" then
            Settings.RainbowBoxes = true
            Settings.RainbowTracers = false
            Settings.RainbowText = false
        elseif Value == "Tracers Only" then
            Settings.RainbowBoxes = false
            Settings.RainbowTracers = true
            Settings.RainbowText = false
        elseif Value == "Text Only" then
            Settings.RainbowBoxes = false
            Settings.RainbowTracers = false
            Settings.RainbowText = true
        end
    end)
    
    local PerformanceSection = Tabs.Settings:AddSection("Performance")
    
    local MaxDistance = PerformanceSection:AddSlider("MaxDistance", {
        Title = "Max Distance",
        Default = 1000,
        Min = 100,
        Max = 5000,
        Rounding = 0
    })
    MaxDistance:OnChanged(function(Value)
        Settings.MaxDistance = Value
    end)
    
    local RefreshRate = PerformanceSection:AddSlider("RefreshRate", {
        Title = "Refresh Rate (FPS)",
        Default = 144,
        Min = 1,
        Max = 144,
        Rounding = 0
    })
    RefreshRate:OnChanged(function(Value)
        Settings.RefreshRate = 1/Value
    end)
    
    local TextSection = Tabs.Settings:AddSection("Text Settings")
    
    local TextSize = TextSection:AddSlider("TextSize", {
        Title = "Text Size",
        Default = 14,
        Min = 10,
        Max = 24,
        Rounding = 0
    })
    TextSize:OnChanged(function(Value)
        Settings.TextSize = Value
    end)
end

do
    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({})
    InterfaceManager:SetFolder("WAUniversalESP")
    SaveManager:SetFolder("WAUniversalESP/configs")
    
    InterfaceManager:BuildInterfaceSection(Tabs.Config)
    SaveManager:BuildConfigSection(Tabs.Config)
    
    local UnloadSection = Tabs.Config:AddSection("Unload")
    
    local UnloadButton = UnloadSection:AddButton({
        Title = "Unload ESP",
        Description = "Completely remove the ESP",
        Callback = function()
            CleanupESP()
            for _, connection in pairs(getconnections(RunService.RenderStepped)) do
                connection:Disable()
            end
            Window:Destroy()
            Drawings = nil
            Settings = nil
            for k, v in pairs(getfenv(1)) do
                getfenv(1)[k] = nil
            end
        end
    })
end

task.spawn(function()
    while task.wait(0.1) do
        Colors.Rainbow = Color3.fromHSV(tick() * Settings.RainbowSpeed % 1, 1, 1)
    end
end)

local lastUpdate = 0
RunService.RenderStepped:Connect(function()
    if not Settings.Enabled then 
        DisableESP()
        return 
    end
    
    local currentTime = tick()
    if currentTime - lastUpdate >= Settings.RefreshRate then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if not Drawings.ESP[player] then
                    CreateESP(player)
                end
                UpdateESP(player)
            end
        end
        lastUpdate = currentTime
    end
end)

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

Window:SelectTab(1)

Fluent:Notify({
    Title = "esp",
    Content = "Loaded successfully! New features: 3D Boxes, China Hat, Team Colors",
    Duration = 5
})
