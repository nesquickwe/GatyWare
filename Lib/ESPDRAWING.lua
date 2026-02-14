-- esp.lua (improved)
-- Features: 2D/Corner Box, Skeletons, Tracers, Health, Distance, Names
--           Rainbow mode, Team color sync, Wall check, Chams-ready structure

--// Services
local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local localPlayer   = Players.LocalPlayer
local camera        = workspace.CurrentCamera

--// Cache
local cache = {}

--// Skeleton bone pairs
local BONES = {
    {"Head",         "UpperTorso"},
    {"UpperTorso",   "RightUpperArm"},
    {"RightUpperArm","RightLowerArm"},
    {"RightLowerArm","RightHand"},
    {"UpperTorso",   "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso",   "LowerTorso"},
    {"LowerTorso",   "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso",   "RightUpperLeg"},
    {"RightUpperLeg","RightLowerLeg"},
    {"RightLowerLeg","RightFoot"},
}

--// Settings (edit these or use the returned table to toggle at runtime)
local ESP = {
    -- Master toggle
    Enabled         = false,

    -- Features
    ShowBox         = true,
    BoxType         = "2D",          -- "2D" | "Corner"
    ShowName        = true,
    ShowHealth      = true,
    ShowDistance    = true,
    ShowSkeletons   = false,
    ShowTracer      = false,
    TracerPosition  = "Bottom",      -- "Top" | "Middle" | "Bottom"

    -- Colors
    BoxColor            = Color3.fromRGB(255, 255, 255),
    BoxOutlineColor     = Color3.fromRGB(0,   0,   0),
    NameColor           = Color3.fromRGB(255, 255, 255),
    HealthHighColor     = Color3.fromRGB(0,   255, 0),
    HealthLowColor      = Color3.fromRGB(255, 0,   0),
    HealthOutlineColor  = Color3.fromRGB(0,   0,   0),
    TracerColor         = Color3.fromRGB(255, 255, 255),
    SkeletonColor       = Color3.fromRGB(255, 255, 255),

    -- Rainbow mode (overrides box/skeleton/tracer colors with HSV cycle)
    RainbowMode         = false,
    RainbowSpeed        = 1,         -- higher = faster

    -- Team options
    TeamCheck           = false,     -- skip teammates
    TeamColor           = false,     -- use team color instead of BoxColor

    -- Wall check (hide ESP if player is behind a part)
    WallCheck           = false,

    -- Tracer line thickness
    TracerThickness     = 1,

    -- Internal rainbow hue (do not touch)
    _hue = 0,
}

-- ─────────────────────────────────────────────────────────────
--// Utility
-- ─────────────────────────────────────────────────────────────

local function newDrawing(class, props)
    local d = Drawing.new(class)
    for k, v in pairs(props) do
        d[k] = v
    end
    return d
end

-- Returns true if the two players are on the same team
local function sameTeam(player)
    return localPlayer.Team and player.Team and player.Team == localPlayer.Team
end

-- Returns true if a solid part is between the camera and the player's root
local function behindWall(player)
    local char = player.Character
    if not char then return false end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return false end

    local origin  = camera.CFrame.Position
    local dir     = (root.Position - origin)
    local ray     = Ray.new(origin, dir.Unit * dir.Magnitude)
    local hit     = workspace:FindPartOnRayWithIgnoreList(ray, {localPlayer.Character, char})
    return hit ~= nil
end

-- Returns current rainbow color based on time
local function rainbowColor()
    return Color3.fromHSV(ESP._hue, 1, 1)
end

-- ─────────────────────────────────────────────────────────────
--// ESP Creation / Removal
-- ─────────────────────────────────────────────────────────────

local function createEsp(player)
    local esp = {
        -- 2D box
        boxOutline = newDrawing("Square", {
            Color     = ESP.BoxOutlineColor,
            Thickness = 3,
            Filled    = false,
            Visible   = false,
        }),
        box = newDrawing("Square", {
            Color     = ESP.BoxColor,
            Thickness = 1,
            Filled    = false,
            Visible   = false,
        }),

        -- Name label
        name = newDrawing("Text", {
            Color   = ESP.NameColor,
            Outline = true,
            Center  = true,
            Size    = 13,
            Visible = false,
        }),

        -- Health bar
        healthOutline = newDrawing("Line", {
            Thickness = 3,
            Color     = ESP.HealthOutlineColor,
            Visible   = false,
        }),
        health = newDrawing("Line", {
            Thickness = 1,
            Color     = ESP.HealthHighColor,
            Visible   = false,
        }),

        -- Distance label
        distance = newDrawing("Text", {
            Color   = Color3.fromRGB(255, 255, 255),
            Size    = 12,
            Outline = true,
            Center  = true,
            Visible = false,
        }),

        -- Tracer
        tracer = newDrawing("Line", {
            Thickness    = ESP.TracerThickness,
            Color        = ESP.TracerColor,
            Transparency = 1,
            Visible      = false,
        }),

        -- Dynamic line arrays
        boxLines      = {},
        skeletonlines = {},
    }

    cache[player] = esp
end

local function removeEsp(player)
    local esp = cache[player]
    if not esp then return end

    for _, v in pairs(esp) do
        if typeof(v) == "userdata" then
            pcall(function() v:Remove() end)
        end
    end
    for _, lineData in ipairs(esp.skeletonlines) do
        pcall(function() lineData[1]:Remove() end)
    end
    for _, line in ipairs(esp.boxLines) do
        pcall(function() line:Remove() end)
    end

    cache[player] = nil
end

-- Hide all drawings for a player (called when off-screen or filtered)
local function hideEsp(esp)
    esp.box.Visible         = false
    esp.boxOutline.Visible  = false
    esp.name.Visible        = false
    esp.healthOutline.Visible = false
    esp.health.Visible      = false
    esp.distance.Visible    = false
    esp.tracer.Visible      = false

    for _, lineData in ipairs(esp.skeletonlines) do
        pcall(function() lineData[1]:Remove() end)
    end
    esp.skeletonlines = {}

    for _, line in ipairs(esp.boxLines) do
        pcall(function() line:Remove() end)
    end
    esp.boxLines = {}
end

-- ─────────────────────────────────────────────────────────────
--// Per-player update
-- ─────────────────────────────────────────────────────────────

local function updatePlayer(player, esp)
    local char = player.Character
    if not char then hideEsp(esp) return end

    -- Team check
    if ESP.TeamCheck and sameTeam(player) then hideEsp(esp) return end

    local root     = char:FindFirstChild("HumanoidRootPart")
    local head     = char:FindFirstChild("Head")
    local humanoid = char:FindFirstChild("Humanoid")
    if not (root and head and humanoid) then hideEsp(esp) return end

    -- Wall check
    if ESP.WallCheck and behindWall(player) then hideEsp(esp) return end

    -- Project to screen
    local rootVP, onScreen = camera:WorldToViewportPoint(root.Position)
    if not onScreen then hideEsp(esp) return end

    -- Resolve active box/skeleton/tracer color
    local activeColor = ESP.RainbowMode and rainbowColor()
        or (ESP.TeamColor and player.TeamColor and player.TeamColor.Color)
        or ESP.BoxColor

    -- ── Box math ────────────────────────────────────────────
    local topY    = camera:WorldToViewportPoint(root.Position + Vector3.new(0, 2.6, 0)).Y
    local botY    = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3,   0)).Y
    local charH   = (botY - topY)
    local charW   = charH * 0.6

    local boxPos  = Vector2.new(math.floor(rootVP.X - charW / 2), math.floor(topY))
    local boxSize = Vector2.new(math.floor(charW),                  math.floor(charH))

    -- ── Box ─────────────────────────────────────────────────
    if ESP.ShowBox then
        if ESP.BoxType == "2D" then
            -- clear corner lines
            for _, l in ipairs(esp.boxLines) do pcall(function() l:Remove() end) end
            esp.boxLines = {}

            esp.box.Size        = boxSize
            esp.box.Position    = boxPos
            esp.box.Color       = activeColor
            esp.box.Visible     = true

            esp.boxOutline.Size     = boxSize
            esp.boxOutline.Position = boxPos
            esp.boxOutline.Color    = ESP.BoxOutlineColor
            esp.boxOutline.Visible  = true

        elseif ESP.BoxType == "Corner" then
            esp.box.Visible        = false
            esp.boxOutline.Visible = false

            local need = 16
            -- create lines if needed
            if #esp.boxLines < need then
                for _ = #esp.boxLines + 1, need do
                    esp.boxLines[#esp.boxLines + 1] = newDrawing("Line", {
                        Thickness    = 1,
                        Color        = activeColor,
                        Transparency = 1,
                        Visible      = false,
                    })
                end
            end

            local bx, by  = boxPos.X,  boxPos.Y
            local bw, bh  = boxSize.X, boxSize.Y
            local lw, lh  = math.floor(bw / 5), math.floor(bh / 6)
            local L       = esp.boxLines

            -- outer corners (color)
            local outerDefs = {
                -- top-left
                {Vector2.new(bx,      by),       Vector2.new(bx + lw, by)},
                {Vector2.new(bx,      by),       Vector2.new(bx,      by + lh)},
                -- top-right
                {Vector2.new(bx+bw-lw,by),       Vector2.new(bx+bw,   by)},
                {Vector2.new(bx+bw,   by),       Vector2.new(bx+bw,   by+lh)},
                -- bottom-left
                {Vector2.new(bx,      by+bh-lh), Vector2.new(bx,      by+bh)},
                {Vector2.new(bx,      by+bh),    Vector2.new(bx+lw,   by+bh)},
                -- bottom-right
                {Vector2.new(bx+bw-lw,by+bh),    Vector2.new(bx+bw,   by+bh)},
                {Vector2.new(bx+bw,   by+bh-lh), Vector2.new(bx+bw,   by+bh)},
            }
            -- inner outlines (shadow)
            local innerDefs = {
                {Vector2.new(bx+1,    by+1),      Vector2.new(bx+1,    by+lh+1)},
                {Vector2.new(bx+1,    by+1),      Vector2.new(bx+lw+1, by+1)},
                {Vector2.new(bx+bw-lw-1,by+1),   Vector2.new(bx+bw-1, by+1)},
                {Vector2.new(bx+bw-1, by+1),      Vector2.new(bx+bw-1, by+lh+1)},
                {Vector2.new(bx+1,    by+bh-lh-1),Vector2.new(bx+1,    by+bh-1)},
                {Vector2.new(bx+1,    by+bh-1),   Vector2.new(bx+lw+1, by+bh-1)},
                {Vector2.new(bx+bw-lw-1,by+bh-1),Vector2.new(bx+bw-1, by+bh-1)},
                {Vector2.new(bx+bw-1, by+bh-lh-1),Vector2.new(bx+bw-1,by+bh-1)},
            }

            for i = 1, 8 do
                L[i].From      = outerDefs[i][1]
                L[i].To        = outerDefs[i][2]
                L[i].Color     = activeColor
                L[i].Thickness = 1
                L[i].Visible   = true
            end
            for i = 1, 8 do
                L[i+8].From      = innerDefs[i][1]
                L[i+8].To        = innerDefs[i][2]
                L[i+8].Color     = ESP.BoxOutlineColor
                L[i+8].Thickness = 2
                L[i+8].Visible   = true
            end
        end
    else
        esp.box.Visible        = false
        esp.boxOutline.Visible = false
        for _, l in ipairs(esp.boxLines) do pcall(function() l:Remove() end) end
        esp.boxLines = {}
    end

    -- ── Name ────────────────────────────────────────────────
    if ESP.ShowName then
        esp.name.Text     = player.Name
        esp.name.Position = Vector2.new(boxPos.X + boxSize.X / 2, boxPos.Y - 15)
        esp.name.Color    = ESP.NameColor
        esp.name.Visible  = true
    else
        esp.name.Visible = false
    end

    -- ── Health bar ──────────────────────────────────────────
    if ESP.ShowHealth then
        local pct   = math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1)
        local barX  = boxPos.X - 5
        local barBotY = boxPos.Y + boxSize.Y
        local barTopY = boxPos.Y

        esp.healthOutline.From    = Vector2.new(barX - 1, barBotY + 1)
        esp.healthOutline.To      = Vector2.new(barX - 1, barTopY - 1)
        esp.healthOutline.Color   = ESP.HealthOutlineColor
        esp.healthOutline.Visible = true

        esp.health.From    = Vector2.new(barX, barBotY)
        esp.health.To      = Vector2.new(barX, barBotY - (pct * boxSize.Y))
        esp.health.Color   = ESP.HealthLowColor:Lerp(ESP.HealthHighColor, pct)
        esp.health.Visible = true
    else
        esp.healthOutline.Visible = false
        esp.health.Visible        = false
    end

    -- ── Distance ────────────────────────────────────────────
    if ESP.ShowDistance then
        local dist = (camera.CFrame.Position - root.Position).Magnitude
        esp.distance.Text     = string.format("[%d]", math.floor(dist))
        esp.distance.Position = Vector2.new(boxPos.X + boxSize.X / 2, boxPos.Y + boxSize.Y + 2)
        esp.distance.Visible  = true
    else
        esp.distance.Visible = false
    end

    -- ── Skeleton ────────────────────────────────────────────
    if ESP.ShowSkeletons then
        -- Build skeleton lines once per character spawn
        if #esp.skeletonlines == 0 then
            for _, pair in ipairs(BONES) do
                local p0, p1 = pair[1], pair[2]
                if char:FindFirstChild(p0) and char:FindFirstChild(p1) then
                    local line = newDrawing("Line", {
                        Thickness    = 1,
                        Color        = ESP.RainbowMode and rainbowColor() or ESP.SkeletonColor,
                        Transparency = 1,
                        Visible      = false,
                    })
                    esp.skeletonlines[#esp.skeletonlines + 1] = {line, p0, p1}
                end
            end
        end

        for _, data in ipairs(esp.skeletonlines) do
            local line, p0, p1 = data[1], data[2], data[3]
            local b0 = char:FindFirstChild(p0)
            local b1 = char:FindFirstChild(p1)
            if b0 and b1 then
                local s0 = camera:WorldToViewportPoint(b0.Position)
                local s1 = camera:WorldToViewportPoint(b1.Position)
                line.From    = Vector2.new(s0.X, s0.Y)
                line.To      = Vector2.new(s1.X, s1.Y)
                line.Color   = ESP.RainbowMode and rainbowColor() or ESP.SkeletonColor
                line.Visible = true
            else
                line.Visible = false
            end
        end
    else
        for _, data in ipairs(esp.skeletonlines) do
            pcall(function() data[1]:Remove() end)
        end
        esp.skeletonlines = {}
    end

    -- ── Tracer ──────────────────────────────────────────────
    if ESP.ShowTracer then
        local originY
        if ESP.TracerPosition == "Top" then
            originY = 0
        elseif ESP.TracerPosition == "Middle" then
            originY = camera.ViewportSize.Y / 2
        else
            originY = camera.ViewportSize.Y
        end

        esp.tracer.From      = Vector2.new(camera.ViewportSize.X / 2, originY)
        esp.tracer.To        = Vector2.new(rootVP.X, rootVP.Y)
        esp.tracer.Color     = ESP.RainbowMode and rainbowColor() or ESP.TracerColor
        esp.tracer.Thickness = ESP.TracerThickness
        esp.tracer.Visible   = true
    else
        esp.tracer.Visible = false
    end
end

-- ─────────────────────────────────────────────────────────────
--// Main loop
-- ─────────────────────────────────────────────────────────────

local function updateAll(dt)
    -- Advance rainbow hue
    if ESP.RainbowMode then
        ESP._hue = (ESP._hue + dt * ESP.RainbowSpeed * 0.1) % 1
    end

    if not ESP.Enabled then
        for _, esp in pairs(cache) do
            hideEsp(esp)
        end
        return
    end

    for player, esp in pairs(cache) do
        updatePlayer(player, esp)
    end
end

-- ─────────────────────────────────────────────────────────────
--// Player hooks
-- ─────────────────────────────────────────────────────────────

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= localPlayer then
        createEsp(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= localPlayer then
        createEsp(player)
    end
end)

Players.PlayerRemoving:Connect(removeEsp)

-- Rebuild skeleton/boxLine cache when character respawns
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        local esp = cache[player]
        if not esp then return end
        for _, data in ipairs(esp.skeletonlines) do
            pcall(function() data[1]:Remove() end)
        end
        esp.skeletonlines = {}
    end)
end)
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= localPlayer then
        player.CharacterAdded:Connect(function()
            local esp = cache[player]
            if not esp then return end
            for _, data in ipairs(esp.skeletonlines) do
                pcall(function() data[1]:Remove() end)
            end
            esp.skeletonlines = {}
        end)
    end
end

RunService.RenderStepped:Connect(updateAll)

-- ─────────────────────────────────────────────────────────────
--// Helper API (optional quality-of-life)
-- ─────────────────────────────────────────────────────────────

--[[
    ESP.Enabled         = true/false    master switch
    ESP.ShowBox         = true/false
    ESP.BoxType         = "2D" | "Corner"
    ESP.ShowName        = true/false
    ESP.ShowHealth      = true/false
    ESP.ShowDistance    = true/false
    ESP.ShowSkeletons   = true/false
    ESP.ShowTracer      = true/false
    ESP.TracerPosition  = "Top" | "Middle" | "Bottom"

    ESP.RainbowMode     = true/false    cycles box/skeleton/tracer color
    ESP.RainbowSpeed    = number        1 = default speed

    ESP.TeamCheck       = true/false    hide teammates
    ESP.TeamColor       = true/false    use Roblox team color for box

    ESP.WallCheck       = true/false    hide when behind a wall

    -- Color fields (Color3):
    ESP.BoxColor, ESP.BoxOutlineColor, ESP.NameColor
    ESP.HealthHighColor, ESP.HealthLowColor, ESP.HealthOutlineColor
    ESP.TracerColor, ESP.SkeletonColor
]]

return ESP
