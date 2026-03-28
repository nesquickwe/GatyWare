-- esp.lua (GatyWare Edition)
--// Variables
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local cache = {}

local bones = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "LowerTorso"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"}
}

--// Settings
local ESP_SETTINGS = {
    -- Core
    Enabled = false,
    Teamcheck = false,
    WallCheck = false,

    -- Box
    ShowBox = false,
    BoxType = "2D",
    BoxColor = Color3.new(1, 1, 1),
    BoxOutlineColor = Color3.new(0, 0, 0),

    -- Name
    ShowName = false,
    NameColor = Color3.new(1, 1, 1),

    -- Health
    ShowHealth = false,
    HealthOutlineColor = Color3.new(0, 0, 0),
    HealthHighColor = Color3.new(0, 1, 0),
    HealthLowColor = Color3.new(1, 0, 0),

    -- Distance
    ShowDistance = false,

    -- Skeleton
    ShowSkeletons = false,
    SkeletonsColor = Color3.new(1, 1, 1),

    -- Tracer
    ShowTracer = false,
    TracerColor = Color3.new(1, 1, 1),
    TracerThickness = 2,
    TracerPosition = "Bottom",

    -- Visibility Check
    ShowVisibilityCheck = false,
    VisibleColor = Color3.new(0, 1, 0),     -- shown when enemy is visible
    OccludedColor = Color3.new(1, 0.4, 0),  -- shown when enemy is behind cover

    -- Chams (SelectionBox highlight on character)
    ShowChams = false,
    ChamsColor = Color3.new(1, 0, 0),
    ChamsTransparency = 0.5,

    -- Radar
    ShowRadar = false,
    RadarSize = 200,
    RadarRange = 500,       -- studs shown on radar
    RadarX = 100,           -- top-left anchor X
    RadarY = 100,           -- top-left anchor Y
    RadarBgColor = Color3.new(0, 0, 0),
    RadarBgTransparency = 0.5,
    RadarEnemyColor = Color3.new(1, 0, 0),
    RadarTeamColor = Color3.new(0, 1, 0),
    RadarSelfColor = Color3.new(1, 1, 1),
    RadarBorderColor = Color3.new(1, 1, 1),

    -- ChinaHat
    ShowChinaHat = false,
    ChinaHatMeshId = "rbxassetid://1778999",
    ChinaHatSize = Vector3.new(3, 0.7, 3),
    ChinaHatColor = Color3.fromRGB(180, 140, 60),
    ChinaHatMaterial = Enum.Material.SmoothPlastic,
    ChinaHatHeadOffset = Vector3.new(0, 1, 0),

    -- Custom ESP Image (GatyWare/CustomImages/)
    ShowCustomImage = false,
    CustomImageName = "esp_image.png",        -- filename inside GatyWare/CustomImages/
    CustomImageSizeRatio = Vector2.new(1, 1), -- scale relative to box (1 = fill box)
    CustomImageTransparency = 0,

    -- Custom Cursor (GatyWare/CustomCursor/)
    ShowCustomCursor = false,
    CustomCursorName = "cursor.png",          -- filename inside GatyWare/CustomCursor/
    CustomCursorSize = Vector2.new(32, 32),
    CustomCursorTransparency = 0,

    -- Misc
    CharSize = Vector2.new(4, 6),
}

-- ─────────────────────────────────────────────────────────────
--// Utility
-- ─────────────────────────────────────────────────────────────
local function create(class, properties)
    local drawing = Drawing.new(class)
    for property, value in pairs(properties) do
        drawing[property] = value
    end
    return drawing
end

local function hideDrawing(d)
    if type(d) == "table" then
        -- skip tables like skeletonlines / boxLines
        return
    end
    pcall(function() d.Visible = false end)
end

local function hideAll(esp)
    for k, v in pairs(esp) do
        if k ~= "skeletonlines" and k ~= "boxLines" and k ~= "chams" then
            hideDrawing(v)
        end
    end
    for _, lineData in ipairs(esp["skeletonlines"] or {}) do
        pcall(function() lineData[1].Visible = false end)
    end
    for _, line in ipairs(esp.boxLines or {}) do
        pcall(function() line.Visible = false end)
    end
end

-- ─────────────────────────────────────────────────────────────
--// Visibility Check helper
-- ─────────────────────────────────────────────────────────────
local function isVisible(player)
    local character = player.Character
    if not character then return false end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end

    local origin = camera.CFrame.Position
    local direction = (rootPart.Position - origin)
    local ray = Ray.new(origin, direction)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {localPlayer.Character, character})
    return hit == nil -- true = clear line of sight
end

local function isPlayerBehindWall(player)
    return not isVisible(player)
end

-- ─────────────────────────────────────────────────────────────
--// Image / Cursor loading helpers
-- Executors expose `readfile` for reading from workspace folder
-- ─────────────────────────────────────────────────────────────
local imageCache = {}

local function loadImage(folder, filename)
    local key = folder .. "/" .. filename
    if imageCache[key] then return imageCache[key] end

    local ok, data = pcall(readfile, "GatyWare/" .. folder .. "/" .. filename)
    if not ok or not data then
        warn("[GatyWare] Could not read image: " .. key)
        return nil
    end

    -- Use Drawing Image if available (most executors support this via Drawing.new("Image"))
    local img = Drawing.new("Image")
    img.Data = data
    img.Visible = false
    imageCache[key] = img
    return img
end

-- ─────────────────────────────────────────────────────────────
--// Custom Cursor
-- ─────────────────────────────────────────────────────────────
local cursorImage = nil

local function initCursor()
    if not ESP_SETTINGS.ShowCustomCursor then
        if cursorImage then cursorImage.Visible = false end
        return
    end

    if not cursorImage then
        cursorImage = loadImage("CustomCursor", ESP_SETTINGS.CustomCursorName)
    end
end

local function updateCursor()
    if not ESP_SETTINGS.ShowCustomCursor or not cursorImage then
        if cursorImage then cursorImage.Visible = false end
        return
    end

    local mousePos = game:GetService("UserInputService"):GetMouseLocation()
    local sz = ESP_SETTINGS.CustomCursorSize
    cursorImage.Size = sz
    cursorImage.Position = Vector2.new(mousePos.X - sz.X / 2, mousePos.Y - sz.Y / 2)
    cursorImage.Transparency = ESP_SETTINGS.CustomCursorTransparency
    cursorImage.Visible = true
end

-- ─────────────────────────────────────────────────────────────
--// Radar
-- ─────────────────────────────────────────────────────────────
local radarDrawings = {
    bg = nil,
    border = nil,
    self = nil,
    blips = {},
}

local function initRadar()
    if radarDrawings.bg then return end

    radarDrawings.bg = create("Square", {
        Color = ESP_SETTINGS.RadarBgColor,
        Transparency = ESP_SETTINGS.RadarBgTransparency,
        Filled = true,
        Visible = false,
    })
    radarDrawings.border = create("Square", {
        Color = ESP_SETTINGS.RadarBorderColor,
        Thickness = 1,
        Filled = false,
        Visible = false,
    })
    radarDrawings.self = create("Circle", {
        Color = ESP_SETTINGS.RadarSelfColor,
        Radius = 4,
        Filled = true,
        Visible = false,
    })
end

local function updateRadar()
    initRadar()

    local size = ESP_SETTINGS.RadarSize
    local rx, ry = ESP_SETTINGS.RadarX, ESP_SETTINGS.RadarY

    if not ESP_SETTINGS.ShowRadar or not ESP_SETTINGS.Enabled then
        radarDrawings.bg.Visible = false
        radarDrawings.border.Visible = false
        radarDrawings.self.Visible = false
        for _, blip in pairs(radarDrawings.blips) do
            blip.Visible = false
        end
        return
    end

    radarDrawings.bg.Size = Vector2.new(size, size)
    radarDrawings.bg.Position = Vector2.new(rx, ry)
    radarDrawings.bg.Visible = true

    radarDrawings.border.Size = Vector2.new(size, size)
    radarDrawings.border.Position = Vector2.new(rx, ry)
    radarDrawings.border.Visible = true

    local center = Vector2.new(rx + size / 2, ry + size / 2)
    radarDrawings.self.Position = center
    radarDrawings.self.Visible = true

    local selfRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not selfRoot then return end

    local selfPos = selfRoot.Position
    local camCF = camera.CFrame
    local range = ESP_SETTINGS.RadarRange

    local playerList = Players:GetPlayers()
    local blipIndex = 1

    for _, player in ipairs(playerList) do
        if player == localPlayer then continue end

        local character = player.Character
        if not character then continue end
        local root = character:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        local isTeammate = player.Team and player.Team == localPlayer.Team

        -- Teamcheck: show teammates on radar only when teamcheck is ON
        local shouldShow = ESP_SETTINGS.Teamcheck and isTeammate or (not ESP_SETTINGS.Teamcheck and not isTeammate)
        if not shouldShow then continue end

        -- World delta rotated into camera-local XZ
        local delta = root.Position - selfPos
        local localDelta = camCF:VectorToObjectSpace(delta)
        local relX = localDelta.X / range * (size / 2)
        local relZ = localDelta.Z / range * (size / 2)

        -- Clamp to radar circle
        local blipPos = Vector2.new(
            math.clamp(center.X + relX, rx, rx + size),
            math.clamp(center.Y + relZ, ry, ry + size)
        )

        local blip = radarDrawings.blips[blipIndex]
        if not blip then
            blip = create("Circle", {
                Radius = 4,
                Filled = true,
                Visible = false,
            })
            radarDrawings.blips[blipIndex] = blip
        end

        blip.Color = isTeammate and ESP_SETTINGS.RadarTeamColor or ESP_SETTINGS.RadarEnemyColor
        blip.Position = blipPos
        blip.Visible = true
        blipIndex += 1
    end

    -- Hide unused blips
    for i = blipIndex, #radarDrawings.blips do
        radarDrawings.blips[i].Visible = false
    end
end

-- ─────────────────────────────────────────────────────────────
--// ChinaHat
-- ─────────────────────────────────────────────────────────────
local chinaHats = {} -- [player] = {hat, weld}

local function removeChinaHat(player)
    local data = chinaHats[player]
    if not data then return end
    if data.weld then data.weld:Destroy() end
    if data.hat then data.hat:Destroy() end
    chinaHats[player] = nil
end

local function attachChinaHat(player, head)
    removeChinaHat(player)

    local hat = Instance.new("MeshPart")
    hat.Name = "GatyWareChinaHat"
    hat.MeshId = ESP_SETTINGS.ChinaHatMeshId
    hat.Size = ESP_SETTINGS.ChinaHatSize
    hat.Color = ESP_SETTINGS.ChinaHatColor
    hat.Material = ESP_SETTINGS.ChinaHatMaterial
    hat.Transparency = 0
    hat.CanCollide = false
    hat.CanQuery = false
    hat.Massless = true
    hat.CastShadow = true
    hat.Parent = camera

    hat.CFrame = head.CFrame + ESP_SETTINGS.ChinaHatHeadOffset

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = hat
    weld.Part1 = head
    weld.Parent = hat

    chinaHats[player] = {hat = hat, weld = weld}
end

local function updateChinaHats()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == localPlayer then continue end

        local isTeammate = player.Team and player.Team == localPlayer.Team
        local shouldHat = ESP_SETTINGS.ShowChinaHat and ESP_SETTINGS.Enabled
            and (not ESP_SETTINGS.Teamcheck or not isTeammate)

        if shouldHat then
            local character = player.Character
            if character then
                local head = character:FindFirstChild("Head")
                if head and not chinaHats[player] then
                    attachChinaHat(player, head)
                end
            end
        else
            removeChinaHat(player)
        end
    end
end

-- ─────────────────────────────────────────────────────────────
--// Chams (SelectionBox highlight)
-- ─────────────────────────────────────────────────────────────
local chamsCache = {} -- [player] = SelectionBox

local function removeChams(player)
    if chamsCache[player] then
        chamsCache[player]:Destroy()
        chamsCache[player] = nil
    end
end

local function applyChams(player)
    local character = player.Character
    if not character then removeChams(player) return end

    if not chamsCache[player] then
        local sb = Instance.new("SelectionBox")
        sb.LineThickness = 0.05
        sb.SurfaceTransparency = ESP_SETTINGS.ChamsTransparency
        sb.SurfaceColor3 = ESP_SETTINGS.ChamsColor
        sb.Color3 = ESP_SETTINGS.ChamsColor
        sb.Adornee = character
        sb.Parent = camera
        chamsCache[player] = sb
    else
        chamsCache[player].Adornee = character
        chamsCache[player].SurfaceColor3 = ESP_SETTINGS.ChamsColor
        chamsCache[player].Color3 = ESP_SETTINGS.ChamsColor
        chamsCache[player].SurfaceTransparency = ESP_SETTINGS.ChamsTransparency
    end
end

local function updateChams()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == localPlayer then continue end
        local isTeammate = player.Team and player.Team == localPlayer.Team
        local should = ESP_SETTINGS.ShowChams and ESP_SETTINGS.Enabled
            and (not ESP_SETTINGS.Teamcheck or not isTeammate)

        if should then
            applyChams(player)
        else
            removeChams(player)
        end
    end
end

-- ─────────────────────────────────────────────────────────────
--// ESP per-player setup & removal
-- ─────────────────────────────────────────────────────────────
local function createEsp(player)
    local esp = {
        boxOutline = create("Square", {
            Color = ESP_SETTINGS.BoxOutlineColor,
            Thickness = 3,
            Filled = false,
            Visible = false,
        }),
        box = create("Square", {
            Color = ESP_SETTINGS.BoxColor,
            Thickness = 1,
            Filled = false,
            Visible = false,
        }),
        name = create("Text", {
            Color = ESP_SETTINGS.NameColor,
            Outline = true,
            Center = true,
            Size = 13,
            Visible = false,
        }),
        healthOutline = create("Line", {
            Thickness = 3,
            Color = ESP_SETTINGS.HealthOutlineColor,
            Visible = false,
        }),
        health = create("Line", {
            Thickness = 1,
            Visible = false,
        }),
        distance = create("Text", {
            Color = Color3.new(1, 1, 1),
            Size = 12,
            Outline = true,
            Center = true,
            Visible = false,
        }),
        tracer = create("Line", {
            Thickness = ESP_SETTINGS.TracerThickness,
            Color = ESP_SETTINGS.TracerColor,
            Transparency = 1,
            Visible = false,
        }),
        -- Custom ESP image (Drawing Image inside box)
        espImage = nil,
        boxLines = {},
        skeletonlines = {},
    }

    -- Try to load the custom ESP image drawing once
    if ESP_SETTINGS.ShowCustomImage then
        local img = loadImage("CustomImages", ESP_SETTINGS.CustomImageName)
        esp.espImage = img
    end

    cache[player] = esp
end

local function removeEsp(player)
    local esp = cache[player]
    if not esp then return end

    for k, v in pairs(esp) do
        if k ~= "skeletonlines" and k ~= "boxLines" and k ~= "espImage" and k ~= "chams" then
            pcall(function() v:Remove() end)
        end
    end
    for _, lineData in ipairs(esp.skeletonlines or {}) do
        pcall(function() lineData[1]:Remove() end)
    end
    for _, line in ipairs(esp.boxLines or {}) do
        pcall(function() line:Remove() end)
    end

    removeChinaHat(player)
    removeChams(player)
    cache[player] = nil
end

-- ─────────────────────────────────────────────────────────────
--// Main ESP Update
-- ─────────────────────────────────────────────────────────────
local function updateEsp()
    for player, esp in pairs(cache) do
        local character = player.Character
        local team = player.Team
        local isTeammate = team and team == localPlayer.Team

        -- Teamcheck: skip teammates unless we want to show them
        if ESP_SETTINGS.Teamcheck and isTeammate then
            hideAll(esp)
            continue
        end

        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            local head = character:FindFirstChild("Head")
            local humanoid = character:FindFirstChild("Humanoid")

            local visible = isVisible(player)
            local isBehindWall = not visible
            local shouldShow = ESP_SETTINGS.Enabled and (not ESP_SETTINGS.WallCheck or not isBehindWall)

            if rootPart and head and humanoid and shouldShow then
                local hrp2D, onScreen = camera:WorldToViewportPoint(rootPart.Position)

                if onScreen then
                    local charSize = (camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0)).Y
                        - camera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, 2.6, 0)).Y) / 2
                    local boxSize = Vector2.new(math.floor(charSize * 1.8), math.floor(charSize * 1.9))
                    local boxPosition = Vector2.new(
                        math.floor(hrp2D.X - charSize * 1.8 / 2),
                        math.floor(hrp2D.Y - charSize * 1.6 / 2)
                    )

                    -- Visibility Check color
                    local activeBoxColor = ESP_SETTINGS.BoxColor
                    local activeTracerColor = ESP_SETTINGS.TracerColor
                    local activeNameColor = ESP_SETTINGS.NameColor
                    if ESP_SETTINGS.ShowVisibilityCheck then
                        local vc = visible and ESP_SETTINGS.VisibleColor or ESP_SETTINGS.OccludedColor
                        activeBoxColor = vc
                        activeTracerColor = vc
                        activeNameColor = vc
                    end

                    -- Name
                    if ESP_SETTINGS.ShowName then
                        esp.name.Visible = true
                        esp.name.Text = string.lower(player.Name)
                        esp.name.Position = Vector2.new(boxSize.X / 2 + boxPosition.X, boxPosition.Y - 16)
                        esp.name.Color = activeNameColor
                    else
                        esp.name.Visible = false
                    end

                    -- Box
                    if ESP_SETTINGS.ShowBox then
                        if ESP_SETTINGS.BoxType == "2D" then
                            esp.boxOutline.Size = boxSize
                            esp.boxOutline.Position = boxPosition
                            esp.box.Size = boxSize
                            esp.box.Position = boxPosition
                            esp.box.Color = activeBoxColor
                            esp.box.Visible = true
                            esp.boxOutline.Visible = true
                            for _, line in ipairs(esp.boxLines) do line:Remove() end
                            esp.boxLines = {}
                        elseif ESP_SETTINGS.BoxType == "Corner Box Esp" then
                            local lineW = boxSize.X / 5
                            local lineH = boxSize.Y / 6
                            local lineT = 1

                            if #esp.boxLines == 0 then
                                for i = 1, 16 do
                                    esp.boxLines[i] = create("Line", {
                                        Thickness = 1,
                                        Color = activeBoxColor,
                                        Transparency = 1,
                                    })
                                end
                            end

                            local bl = esp.boxLines
                            bl[1].From  = Vector2.new(boxPosition.X - lineT, boxPosition.Y - lineT)
                            bl[1].To    = Vector2.new(boxPosition.X + lineW,  boxPosition.Y - lineT)
                            bl[2].From  = Vector2.new(boxPosition.X - lineT, boxPosition.Y - lineT)
                            bl[2].To    = Vector2.new(boxPosition.X - lineT, boxPosition.Y + lineH)
                            bl[3].From  = Vector2.new(boxPosition.X + boxSize.X - lineW, boxPosition.Y - lineT)
                            bl[3].To    = Vector2.new(boxPosition.X + boxSize.X + lineT, boxPosition.Y - lineT)
                            bl[4].From  = Vector2.new(boxPosition.X + boxSize.X + lineT, boxPosition.Y - lineT)
                            bl[4].To    = Vector2.new(boxPosition.X + boxSize.X + lineT, boxPosition.Y + lineH)
                            bl[5].From  = Vector2.new(boxPosition.X - lineT, boxPosition.Y + boxSize.Y - lineH)
                            bl[5].To    = Vector2.new(boxPosition.X - lineT, boxPosition.Y + boxSize.Y + lineT)
                            bl[6].From  = Vector2.new(boxPosition.X - lineT, boxPosition.Y + boxSize.Y + lineT)
                            bl[6].To    = Vector2.new(boxPosition.X + lineW,  boxPosition.Y + boxSize.Y + lineT)
                            bl[7].From  = Vector2.new(boxPosition.X + boxSize.X - lineW, boxPosition.Y + boxSize.Y + lineT)
                            bl[7].To    = Vector2.new(boxPosition.X + boxSize.X + lineT, boxPosition.Y + boxSize.Y + lineT)
                            bl[8].From  = Vector2.new(boxPosition.X + boxSize.X + lineT, boxPosition.Y + boxSize.Y - lineH)
                            bl[8].To    = Vector2.new(boxPosition.X + boxSize.X + lineT, boxPosition.Y + boxSize.Y + lineT)
                            for i = 9, 16 do
                                bl[i].Thickness = 2
                                bl[i].Color = ESP_SETTINGS.BoxOutlineColor
                                bl[i].Transparency = 1
                            end
                            bl[9].From  = Vector2.new(boxPosition.X, boxPosition.Y)
                            bl[9].To    = Vector2.new(boxPosition.X, boxPosition.Y + lineH)
                            bl[10].From = Vector2.new(boxPosition.X, boxPosition.Y)
                            bl[10].To   = Vector2.new(boxPosition.X + lineW, boxPosition.Y)
                            bl[11].From = Vector2.new(boxPosition.X + boxSize.X - lineW, boxPosition.Y)
                            bl[11].To   = Vector2.new(boxPosition.X + boxSize.X, boxPosition.Y)
                            bl[12].From = Vector2.new(boxPosition.X + boxSize.X, boxPosition.Y)
                            bl[12].To   = Vector2.new(boxPosition.X + boxSize.X, boxPosition.Y + lineH)
                            bl[13].From = Vector2.new(boxPosition.X, boxPosition.Y + boxSize.Y - lineH)
                            bl[13].To   = Vector2.new(boxPosition.X, boxPosition.Y + boxSize.Y)
                            bl[14].From = Vector2.new(boxPosition.X, boxPosition.Y + boxSize.Y)
                            bl[14].To   = Vector2.new(boxPosition.X + lineW, boxPosition.Y + boxSize.Y)
                            bl[15].From = Vector2.new(boxPosition.X + boxSize.X - lineW, boxPosition.Y + boxSize.Y)
                            bl[15].To   = Vector2.new(boxPosition.X + boxSize.X, boxPosition.Y + boxSize.Y)
                            bl[16].From = Vector2.new(boxPosition.X + boxSize.X, boxPosition.Y + boxSize.Y - lineH)
                            bl[16].To   = Vector2.new(boxPosition.X + boxSize.X, boxPosition.Y + boxSize.Y)
                            for _, line in ipairs(bl) do line.Visible = true end
                            esp.box.Visible = false
                            esp.boxOutline.Visible = false
                        end
                    else
                        esp.box.Visible = false
                        esp.boxOutline.Visible = false
                        for _, line in ipairs(esp.boxLines) do line:Remove() end
                        esp.boxLines = {}
                    end

                    -- Health
                    if ESP_SETTINGS.ShowHealth then
                        local hp = humanoid.Health / humanoid.MaxHealth
                        esp.healthOutline.From = Vector2.new(boxPosition.X - 6, boxPosition.Y + boxSize.Y)
                        esp.healthOutline.To   = Vector2.new(boxPosition.X - 6, boxPosition.Y)
                        esp.health.From        = Vector2.new(boxPosition.X - 5, boxPosition.Y + boxSize.Y)
                        esp.health.To          = Vector2.new(boxPosition.X - 5, boxPosition.Y + boxSize.Y - hp * boxSize.Y)
                        esp.health.Color       = ESP_SETTINGS.HealthLowColor:Lerp(ESP_SETTINGS.HealthHighColor, hp)
                        esp.healthOutline.Visible = true
                        esp.health.Visible = true
                    else
                        esp.healthOutline.Visible = false
                        esp.health.Visible = false
                    end

                    -- Distance
                    if ESP_SETTINGS.ShowDistance then
                        local dist = (camera.CFrame.p - rootPart.Position).Magnitude
                        esp.distance.Text = string.format("%.1f studs", dist)
                        esp.distance.Position = Vector2.new(boxPosition.X + boxSize.X / 2, boxPosition.Y + boxSize.Y + 5)
                        esp.distance.Visible = true
                    else
                        esp.distance.Visible = false
                    end

                    -- Skeleton
                    if ESP_SETTINGS.ShowSkeletons then
                        if #esp.skeletonlines == 0 then
                            for _, bonePair in ipairs(bones) do
                                local p, c = bonePair[1], bonePair[2]
                                if character[p] and character[c] then
                                    local sl = create("Line", {
                                        Thickness = 1,
                                        Color = ESP_SETTINGS.SkeletonsColor,
                                        Transparency = 1,
                                    })
                                    esp.skeletonlines[#esp.skeletonlines + 1] = {sl, p, c}
                                end
                            end
                        end
                        for _, lineData in ipairs(esp.skeletonlines) do
                            local sl, p, c = lineData[1], lineData[2], lineData[3]
                            if character[p] and character[c] then
                                local pp = camera:WorldToViewportPoint(character[p].Position)
                                local cp = camera:WorldToViewportPoint(character[c].Position)
                                sl.From = Vector2.new(pp.X, pp.Y)
                                sl.To   = Vector2.new(cp.X, cp.Y)
                                sl.Color = ESP_SETTINGS.SkeletonsColor
                                sl.Visible = true
                            else
                                sl:Remove()
                            end
                        end
                    else
                        for _, lineData in ipairs(esp.skeletonlines) do
                            lineData[1]:Remove()
                        end
                        esp.skeletonlines = {}
                    end

                    -- Tracer
                    if ESP_SETTINGS.ShowTracer then
                        local tracerY
                        if ESP_SETTINGS.TracerPosition == "Top" then
                            tracerY = 0
                        elseif ESP_SETTINGS.TracerPosition == "Middle" then
                            tracerY = camera.ViewportSize.Y / 2
                        else
                            tracerY = camera.ViewportSize.Y
                        end
                        esp.tracer.Color = activeTracerColor
                        esp.tracer.From  = Vector2.new(camera.ViewportSize.X / 2, tracerY)
                        esp.tracer.To    = Vector2.new(hrp2D.X, hrp2D.Y)
                        esp.tracer.Visible = true
                    else
                        esp.tracer.Visible = false
                    end

                    -- Custom ESP Image
                    if ESP_SETTINGS.ShowCustomImage and esp.espImage then
                        local imgW = boxSize.X * ESP_SETTINGS.CustomImageSizeRatio.X
                        local imgH = boxSize.Y * ESP_SETTINGS.CustomImageSizeRatio.Y
                        esp.espImage.Size = Vector2.new(imgW, imgH)
                        esp.espImage.Position = Vector2.new(
                            boxPosition.X + (boxSize.X - imgW) / 2,
                            boxPosition.Y + (boxSize.Y - imgH) / 2
                        )
                        esp.espImage.Transparency = ESP_SETTINGS.CustomImageTransparency
                        esp.espImage.Visible = true
                    elseif esp.espImage then
                        esp.espImage.Visible = false
                    end

                else
                    -- Off screen
                    hideAll(esp)
                end
            else
                hideAll(esp)
            end
        else
            hideAll(esp)
        end
    end

    updateChams()
    updateChinaHats()
    updateRadar()
    updateCursor()
end

-- ─────────────────────────────────────────────────────────────
--// Init existing players
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

Players.PlayerRemoving:Connect(function(player)
    removeEsp(player)
end)

RunService.RenderStepped:Connect(updateEsp)

initRadar()
initCursor()

return ESP_SETTINGS
