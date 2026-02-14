local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ESPLibrary = {}
ESPLibrary.__index = ESPLibrary

local Drawings = {
    ESP = {},
    Tracers = {},
    Boxes = {},
    Healthbars = {},
    Names = {},
    Distances = {},
    Snaplines = {},
    Skeleton = {},
    ChineseHat = {},
    LookAt = {},
    Weapon = {},
    Flags = {}
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
    BoxStyle = "Corner",
    BoxOutline = true,
    BoxFilled = false,
    BoxFillTransparency = 0.5,
    BoxThickness = 1,
    TracerESP = false,
    TracerOrigin = "Bottom",
    TracerStyle = "Line",
    TracerThickness = 1,
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
    -- Chinese Hat / LookAt ESP
    ChineseHatESP = false,
    ChineseHatColor = Color3.fromRGB(255, 255, 0),
    ChineseHatRadius = 3,
    ChineseHatSides = 20,
    ChineseHatThickness = 2,
    ChineseHatTransparency = 1,
    -- LookAt Direction
    LookAtESP = false,
    LookAtColor = Color3.fromRGB(0, 255, 255),
    LookAtLength = 10,
    LookAtThickness = 2,
    LookAtTransparency = 1,
    -- Weapon ESP
    WeaponESP = false,
    WeaponColor = Color3.fromRGB(255, 165, 0),
    -- Flags (custom info text)
    FlagsESP = false,
    FlagsColor = Color3.fromRGB(255, 255, 255)
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
        if line == box.Fill then
            line.Filled = true
            line.Transparency = Settings.BoxFillTransparency
        end
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
    
    -- Chinese Hat (circle around head)
    local chineseHat = {}
    for i = 1, Settings.ChineseHatSides do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = Settings.ChineseHatColor
        line.Thickness = Settings.ChineseHatThickness
        line.Transparency = Settings.ChineseHatTransparency
        chineseHat[i] = line
    end
    
    Drawings.ChineseHat[player] = chineseHat
    
    -- LookAt Direction (arrow showing where player is looking)
    local lookAt = Drawing.new("Line")
    lookAt.Visible = false
    lookAt.Color = Settings.LookAtColor
    lookAt.Thickness = Settings.LookAtThickness
    lookAt.Transparency = Settings.LookAtTransparency
    
    Drawings.LookAt[player] = lookAt
    
    -- Weapon ESP
    local weapon = Drawing.new("Text")
    weapon.Visible = false
    weapon.Center = true
    weapon.Size = Settings.TextSize
    weapon.Color = Settings.WeaponColor
    weapon.Font = Settings.TextFont
    weapon.Outline = true
    
    Drawings.Weapon[player] = weapon
    
    -- Flags (additional info)
    local flags = Drawing.new("Text")
    flags.Visible = false
    flags.Center = false
    flags.Size = Settings.TextSize - 2
    flags.Color = Settings.FlagsColor
    flags.Font = Settings.TextFont
    flags.Outline = true
    
    Drawings.Flags[player] = flags
    
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
    
    local chineseHat = Drawings.ChineseHat[player]
    if chineseHat then
        for _, line in pairs(chineseHat) do
            line:Remove()
        end
        Drawings.ChineseHat[player] = nil
    end
    
    local lookAt = Drawings.LookAt[player]
    if lookAt then
        lookAt:Remove()
        Drawings.LookAt[player] = nil
    end
    
    local weapon = Drawings.Weapon[player]
    if weapon then
        weapon:Remove()
        Drawings.Weapon[player] = nil
    end
    
    local flags = Drawings.Flags[player]
    if flags then
        flags:Remove()
        Drawings.Flags[player] = nil
    end
end

local function GetPlayerColor(player)
    if Settings.RainbowEnabled then
        if Settings.RainbowBoxes and Settings.BoxESP then return Colors.Rainbow end
        if Settings.RainbowTracers and Settings.TracerESP then return Colors.Rainbow end
        if Settings.RainbowText and (Settings.NameESP or Settings.HealthESP) then return Colors.Rainbow end
    end
    return player.Team == LocalPlayer.Team and Colors.Ally or Colors.Enemy
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
        return
    end
    
    if Settings.TeamCheck and player.Team == LocalPlayer.Team and not Settings.ShowTeam then
        for _, obj in pairs(esp.Box) do obj.Visible = false end
        esp.Tracer.Visible = false
        for _, obj in pairs(esp.HealthBar) do obj.Visible = false end
        for _, obj in pairs(esp.Info) do obj.Visible = false end
        esp.Snapline.Visible = false
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
            local front = {
                TL = Camera:WorldToViewportPoint((cf * CFrame.new(-size.X/2, size.Y/2, -size.Z/2)).Position),
                TR = Camera:WorldToViewportPoint((cf * CFrame.new(size.X/2, size.Y/2, -size.Z/2)).Position),
                BL = Camera:WorldToViewportPoint((cf * CFrame.new(-size.X/2, -size.Y/2, -size.Z/2)).Position),
                BR = Camera:WorldToViewportPoint((cf * CFrame.new(size.X/2, -size.Y/2, -size.Z/2)).Position)
            }
            
            local back = {
                TL = Camera:WorldToViewportPoint((cf * CFrame.new(-size.X/2, size.Y/2, size.Z/2)).Position),
                TR = Camera:WorldToViewportPoint((cf * CFrame.new(size.X/2, size.Y/2, size.Z/2)).Position),
                BL = Camera:WorldToViewportPoint((cf * CFrame.new(-size.X/2, -size.Y/2, size.Z/2)).Position),
                BR = Camera:WorldToViewportPoint((cf * CFrame.new(size.X/2, -size.Y/2, size.Z/2)).Position)
            }
            
            if not (front.TL.Z > 0 and front.TR.Z > 0 and front.BL.Z > 0 and front.BR.Z > 0 and
                   back.TL.Z > 0 and back.TR.Z > 0 and back.BL.Z > 0 and back.BR.Z > 0) then
                for _, obj in pairs(esp.Box) do obj.Visible = false end
                return
            end
            
            local function toVector2(v3) return Vector2.new(v3.X, v3.Y) end
            front.TL, front.TR = toVector2(front.TL), toVector2(front.TR)
            front.BL, front.BR = toVector2(front.BL), toVector2(front.BR)
            back.TL, back.TR = toVector2(back.TL), toVector2(back.TR)
            back.BL, back.BR = toVector2(back.BL), toVector2(back.BR)
            
            esp.Box.TopLeft.From = front.TL
            esp.Box.TopLeft.To = front.TR
            esp.Box.TopLeft.Visible = true
            
            esp.Box.TopRight.From = front.TR
            esp.Box.TopRight.To = front.BR
            esp.Box.TopRight.Visible = true
            
            esp.Box.BottomLeft.From = front.BL
            esp.Box.BottomLeft.To = front.BR
            esp.Box.BottomLeft.Visible = true
            
            esp.Box.BottomRight.From = front.TL
            esp.Box.BottomRight.To = front.BL
            esp.Box.BottomRight.Visible = true
            
            esp.Box.Left.From = back.TL
            esp.Box.Left.To = back.TR
            esp.Box.Left.Visible = true
            
            esp.Box.Right.From = back.TR
            esp.Box.Right.To = back.BR
            esp.Box.Right.Visible = true
            
            esp.Box.Top.From = back.BL
            esp.Box.Top.To = back.BR
            esp.Box.Top.Visible = true
            
            esp.Box.Bottom.From = back.TL
            esp.Box.Bottom.To = back.BL
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
            
            esp.Box.TopLeft.Visible = false
            esp.Box.TopRight.Visible = false
            esp.Box.BottomLeft.Visible = false
            esp.Box.BottomRight.Visible = false
        end
        
        for _, obj in pairs(esp.Box) do
            if obj.Visible then
                obj.Color = color
                obj.Thickness = Settings.BoxThickness
            end
        end
    end
    
    if Settings.TracerESP then
        esp.Tracer.From = GetTracerOrigin()
        esp.Tracer.To = Vector2.new(pos.X, pos.Y)
        esp.Tracer.Color = color
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
        esp.Info.Name.Text = player.DisplayName
        esp.Info.Name.Position = Vector2.new(
            boxPosition.X + boxWidth/2,
            boxPosition.Y - 20
        )
        esp.Info.Name.Color = color
        esp.Info.Name.Visible = true
    else
        esp.Info.Name.Visible = false
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
            
            local fromPos = (from.CFrame * CFrame.new(0, 0, 0)).Position
            local toPos = (to.CFrame * CFrame.new(0, 0, 0)).Position
            
            local fromScreen, fromVisible = Camera:WorldToViewportPoint(fromPos)
            local toScreen, toVisible = Camera:WorldToViewportPoint(toPos)
            
            if not (fromVisible and toVisible) or fromScreen.Z < 0 or toScreen.Z < 0 then
                line.Visible = false
                return
            end
            
            local screenBounds = Camera.ViewportSize
            if fromScreen.X < 0 or fromScreen.X > screenBounds.X or
               fromScreen.Y < 0 or fromScreen.Y > screenBounds.Y or
               toScreen.X < 0 or toScreen.X > screenBounds.X or
               toScreen.Y < 0 or toScreen.Y > screenBounds.Y then
                line.Visible = false
                return
            end
            
            line.From = Vector2.new(fromScreen.X, fromScreen.Y)
            line.To = Vector2.new(toScreen.X, toScreen.Y)
            line.Color = Settings.SkeletonColor
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
    
    -- Chinese Hat ESP (circle around head)
    if Settings.ChineseHatESP then
        local head = character:FindFirstChild("Head")
        if head then
            local chineseHat = Drawings.ChineseHat[player]
            if chineseHat then
                local headPos = head.Position + Vector3.new(0, 1, 0) -- Slightly above head
                local radius = Settings.ChineseHatRadius
                local sides = Settings.ChineseHatSides
                
                for i = 1, sides do
                    local angle1 = (i / sides) * math.pi * 2
                    local angle2 = ((i + 1) / sides) * math.pi * 2
                    
                    local point1 = headPos + Vector3.new(
                        math.cos(angle1) * radius,
                        0,
                        math.sin(angle1) * radius
                    )
                    
                    local point2 = headPos + Vector3.new(
                        math.cos(angle2) * radius,
                        0,
                        math.sin(angle2) * radius
                    )
                    
                    local screen1, visible1 = Camera:WorldToViewportPoint(point1)
                    local screen2, visible2 = Camera:WorldToViewportPoint(point2)
                    
                    if visible1 and visible2 and screen1.Z > 0 and screen2.Z > 0 then
                        chineseHat[i].From = Vector2.new(screen1.X, screen1.Y)
                        chineseHat[i].To = Vector2.new(screen2.X, screen2.Y)
                        chineseHat[i].Color = Settings.ChineseHatColor
                        chineseHat[i].Thickness = Settings.ChineseHatThickness
                        chineseHat[i].Transparency = Settings.ChineseHatTransparency
                        chineseHat[i].Visible = true
                    else
                        chineseHat[i].Visible = false
                    end
                end
            end
        end
    else
        local chineseHat = Drawings.ChineseHat[player]
        if chineseHat then
            for _, line in pairs(chineseHat) do
                line.Visible = false
            end
        end
    end
    
    -- LookAt Direction ESP (arrow showing where player is looking)
    if Settings.LookAtESP then
        local head = character:FindFirstChild("Head")
        if head then
            local lookAt = Drawings.LookAt[player]
            if lookAt then
                local lookDirection = head.CFrame.LookVector
                local startPos = head.Position
                local endPos = startPos + (lookDirection * Settings.LookAtLength)
                
                local screenStart, visibleStart = Camera:WorldToViewportPoint(startPos)
                local screenEnd, visibleEnd = Camera:WorldToViewportPoint(endPos)
                
                if visibleStart and visibleEnd and screenStart.Z > 0 and screenEnd.Z > 0 then
                    lookAt.From = Vector2.new(screenStart.X, screenStart.Y)
                    lookAt.To = Vector2.new(screenEnd.X, screenEnd.Y)
                    lookAt.Color = Settings.LookAtColor
                    lookAt.Thickness = Settings.LookAtThickness
                    lookAt.Transparency = Settings.LookAtTransparency
                    lookAt.Visible = true
                else
                    lookAt.Visible = false
                end
            end
        end
    else
        local lookAt = Drawings.LookAt[player]
        if lookAt then
            lookAt.Visible = false
        end
    end
    
    -- Weapon ESP
    if Settings.WeaponESP then
        local weapon = Drawings.Weapon[player]
        if weapon then
            local tool = character:FindFirstChildOfClass("Tool")
            if tool then
                weapon.Text = tool.Name
                weapon.Position = Vector2.new(
                    boxPosition.X + boxWidth/2,
                    boxPosition.Y + boxSize.Y + 5
                )
                weapon.Color = Settings.WeaponColor
                weapon.Visible = true
            else
                weapon.Visible = false
            end
        end
    else
        local weapon = Drawings.Weapon[player]
        if weapon then
            weapon.Visible = false
        end
    end
    
    -- Flags ESP (additional info like distance, etc.)
    if Settings.FlagsESP then
        local flags = Drawings.Flags[player]
        if flags then
            local flagText = ""
            
            -- Add distance
            if Settings.ShowDistance then
                local dist = math.floor(distance)
                flagText = flagText .. dist .. " " .. Settings.DistanceUnit .. "\n"
            end
            
            -- Add health
            if humanoid then
                local hp = math.floor(humanoid.Health)
                flagText = flagText .. hp .. "HP\n"
            end
            
            -- Add tool/weapon
            local tool = character:FindFirstChildOfClass("Tool")
            if tool then
                flagText = flagText .. tool.Name .. "\n"
            end
            
            if flagText ~= "" then
                flags.Text = flagText
                flags.Position = Vector2.new(
                    boxPosition.X + boxWidth + 5,
                    boxPosition.Y
                )
                flags.Color = Settings.FlagsColor
                flags.Visible = true
            else
                flags.Visible = false
            end
        end
    else
        local flags = Drawings.Flags[player]
        if flags then
            flags.Visible = false
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
        
        local chineseHat = Drawings.ChineseHat[player]
        if chineseHat then
            for _, line in pairs(chineseHat) do
                line.Visible = false
            end
        end
        
        local lookAt = Drawings.LookAt[player]
        if lookAt then
            lookAt.Visible = false
        end
        
        local weapon = Drawings.Weapon[player]
        if weapon then
            weapon.Visible = false
        end
        
        local flags = Drawings.Flags[player]
        if flags then
            flags.Visible = false
        end
    end
end

local function CleanupESP()
    for _, player in ipairs(Players:GetPlayers()) do
        RemoveESP(player)
    end
    Drawings.ESP = {}
    Drawings.Skeleton = {}
    Drawings.ChineseHat = {}
    Drawings.LookAt = {}
    Drawings.Weapon = {}
    Drawings.Flags = {}
    Highlights = {}
end

-- Library API
function ESPLibrary.new()
    local self = setmetatable({}, ESPLibrary)
    self.Connections = {}
    self.Initialized = false
    return self
end

function ESPLibrary:Enable()
    Settings.Enabled = true
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateESP(player)
        end
    end
end

function ESPLibrary:Disable()
    Settings.Enabled = false
    DisableESP()
end

function ESPLibrary:Toggle()
    if Settings.Enabled then
        self:Disable()
    else
        self:Enable()
    end
end

function ESPLibrary:SetSetting(setting, value)
    if Settings[setting] ~= nil then
        Settings[setting] = value
        return true
    end
    return false
end

function ESPLibrary:GetSetting(setting)
    return Settings[setting]
end

function ESPLibrary:SetColor(colorName, color)
    if Colors[colorName] ~= nil then
        Colors[colorName] = color
        return true
    end
    return false
end

function ESPLibrary:GetColor(colorName)
    return Colors[colorName]
end

function ESPLibrary:Initialize()
    if self.Initialized then return end
    
    -- Rainbow color updater
    task.spawn(function()
        while task.wait(0.1) do
            Colors.Rainbow = Color3.fromHSV(tick() * Settings.RainbowSpeed % 1, 1, 1)
        end
    end)
    
    -- Main render loop
    local lastUpdate = 0
    local renderConnection = RunService.RenderStepped:Connect(function()
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
    
    table.insert(self.Connections, renderConnection)
    
    -- Player events
    local playerAddedConnection = Players.PlayerAdded:Connect(CreateESP)
    local playerRemovingConnection = Players.PlayerRemoving:Connect(RemoveESP)
    
    table.insert(self.Connections, playerAddedConnection)
    table.insert(self.Connections, playerRemovingConnection)
    
    -- Initialize ESP for existing players
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateESP(player)
        end
    end
    
    self.Initialized = true
end

function ESPLibrary:Destroy()
    CleanupESP()
    
    for _, connection in ipairs(self.Connections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    self.Connections = {}
    self.Initialized = false
end

-- Example Usage:
--[[
    local ESP = loadstring(game:HttpGet("your-url"))()
    local espInstance = ESP.new()
    espInstance:Initialize()
    espInstance:Enable()
    
    -- Configure settings
    espInstance:SetSetting("BoxESP", true)
    espInstance:SetSetting("TracerESP", true)
    espInstance:SetSetting("HealthESP", true)
    espInstance:SetSetting("SkeletonESP", true)
    espInstance:SetSetting("BoxStyle", "Corner")
    espInstance:SetSetting("ChamsEnabled", true)
    
    -- Set colors
    espInstance:SetColor("Enemy", Color3.fromRGB(255, 0, 0))
    espInstance:SetColor("Ally", Color3.fromRGB(0, 255, 0))
    
    -- Cleanup when done
    -- espInstance:Destroy()
]]

return ESPLibrary
