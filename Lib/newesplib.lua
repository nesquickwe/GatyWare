-- esp.lua (GatyWare Edition)
--// Variables
local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local UserInput     = game:GetService("UserInputService")
local localPlayer   = Players.LocalPlayer
local camera        = workspace.CurrentCamera
local cache         = {}

local bones = {
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

-- ─────────────────────────────────────────────────────────────
--// Settings
-- ─────────────────────────────────────────────────────────────
local ESP_SETTINGS = {
    Enabled     = false,
    Teamcheck   = false,
    WallCheck   = false,

    ShowBox         = false,
    BoxType         = "2D",
    BoxColor        = Color3.new(1,1,1),
    BoxOutlineColor = Color3.new(0,0,0),

    ShowName  = false,
    NameColor = Color3.new(1,1,1),

    ShowHealth         = false,
    HealthOutlineColor = Color3.new(0,0,0),
    HealthHighColor    = Color3.new(0,1,0),
    HealthLowColor     = Color3.new(1,0,0),

    ShowDistance = false,

    ShowSkeletons  = false,
    SkeletonsColor = Color3.new(1,1,1),

    ShowTracer      = false,
    TracerColor     = Color3.new(1,1,1),
    TracerThickness = 2,
    TracerPosition  = "Bottom",

    ShowVisibilityCheck = false,
    VisibleColor        = Color3.new(0,1,0),
    OccludedColor       = Color3.new(1,0.4,0),

    ShowChams        = false,
    ChamsColor       = Color3.new(1,0,0),
    ChamsTransparency= 0.5,

    ShowRadar           = false,
    RadarSize           = 200,
    RadarRange          = 500,
    RadarX              = 100,
    RadarY              = 100,
    RadarBgColor        = Color3.new(0,0,0),
    RadarBgTransparency = 0.5,
    RadarEnemyColor     = Color3.new(1,0,0),
    RadarTeamColor      = Color3.new(0,1,0),
    RadarSelfColor      = Color3.new(1,1,1),
    RadarBorderColor    = Color3.new(1,1,1),

    ShowChinaHat       = false,
    ChinaHatMeshId     = "rbxassetid://1778999",
    ChinaHatSize       = Vector3.new(3,0.7,3),
    ChinaHatColor      = Color3.fromRGB(180,140,60),
    ChinaHatMaterial   = Enum.Material.SmoothPlastic,
    ChinaHatHeadOffset = Vector3.new(0,1,0),

    ShowCustomImage         = false,
    CustomImageName         = "esp_image.png",
    CustomImageSizeRatio    = Vector2.new(1,1),
    CustomImageTransparency = 0,

    ShowCustomCursor         = false,
    CustomCursorName         = "cursor.png",
    CustomCursorSize         = Vector2.new(32,32),
    CustomCursorTransparency = 0,

    CharSize = Vector2.new(4,6),
}

-- ─────────────────────────────────────────────────────────────
--// Folder Setup
-- ─────────────────────────────────────────────────────────────
local function initFolders()
    for _, path in ipairs({"GatyWare","GatyWare/CustomImages","GatyWare/CustomCursor"}) do
        if not isfolder(path) then makefolder(path) end
    end
end
initFolders()

-- ─────────────────────────────────────────────────────────────
--// Utility
-- ─────────────────────────────────────────────────────────────
local function newDrawing(class, props)
    local d = Drawing.new(class)
    for k,v in pairs(props) do d[k]=v end
    return d
end

local function hideAll(esp)
    for k,v in pairs(esp) do
        if k=="skeletonlines" or k=="boxLines" or k=="espImage" or k=="cachedName" then continue end
        pcall(function() v.Visible=false end)
    end
    for _,ld in ipairs(esp.skeletonlines or {}) do
        pcall(function() ld[1].Visible=false end)
    end
    for _,line in ipairs(esp.boxLines or {}) do
        pcall(function() line.Visible=false end)
    end
    if esp.espImage then pcall(function() esp.espImage.Visible=false end) end
end

local function clearSkeletonLines(esp)
    for _,ld in ipairs(esp.skeletonlines or {}) do
        pcall(function() ld[1]:Remove() end)
    end
    esp.skeletonlines = {}
end

local function clearBoxLines(esp)
    for _,line in ipairs(esp.boxLines or {}) do
        pcall(function() line:Remove() end)
    end
    esp.boxLines = {}
end

-- ─────────────────────────────────────────────────────────────
--// Visibility / raycast  (throttled at 10 hz per player)
-- ─────────────────────────────────────────────────────────────
local visCache     = {}
local visTimestamp = {}
local VIS_INTERVAL = 1/10

local function isVisible(player)
    local now = tick()
    if visTimestamp[player] and (now - visTimestamp[player]) < VIS_INTERVAL then
        return visCache[player]
    end
    visTimestamp[player] = now

    local char = player.Character
    if not char then visCache[player]=false return false end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then visCache[player]=false return false end

    local origin = camera.CFrame.Position
    local ray    = Ray.new(origin, root.Position - origin)
    local hit    = workspace:FindPartOnRayWithIgnoreList(ray, {localPlayer.Character, char})
    local result = (hit == nil)
    visCache[player] = result
    return result
end

-- ─────────────────────────────────────────────────────────────
--// Image loading
-- ─────────────────────────────────────────────────────────────
local imageCache = {}

local function loadImage(folder, filename)
    local key  = folder.."/"..filename
    if imageCache[key] then return imageCache[key] end
    local path = "GatyWare/"..folder.."/"..filename
    if not isfile(path) then warn("[GatyWare] File not found: "..path) return nil end
    local ok, data = pcall(readfile, path)
    if not ok or not data then warn("[GatyWare] Could not read: "..path) return nil end
    local img   = Drawing.new("Image")
    img.Data    = data
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
        if cursorImage then cursorImage.Visible=false end
        return
    end
    if not cursorImage then
        cursorImage = loadImage("CustomCursor", ESP_SETTINGS.CustomCursorName)
    end
end

local function updateCursor()
    if not ESP_SETTINGS.ShowCustomCursor or not cursorImage then
        if cursorImage then cursorImage.Visible=false end
        return
    end
    local mp = UserInput:GetMouseLocation()
    local sz = ESP_SETTINGS.CustomCursorSize
    cursorImage.Size         = sz
    cursorImage.Position     = Vector2.new(mp.X-sz.X/2, mp.Y-sz.Y/2)
    cursorImage.Transparency = ESP_SETTINGS.CustomCursorTransparency
    cursorImage.Visible      = true
end

-- ─────────────────────────────────────────────────────────────
--// Radar
-- ─────────────────────────────────────────────────────────────
local radarDrawings = { bg=nil, border=nil, self=nil, blips={} }
local RADAR_BLIP_POOL = 50
local _radarLastTick  = 0
local RADAR_HZ        = 1/20

local function initRadar()
    if radarDrawings.bg then return end
    radarDrawings.bg = newDrawing("Square",{
        Color=ESP_SETTINGS.RadarBgColor, Transparency=ESP_SETTINGS.RadarBgTransparency,
        Filled=true, Visible=false,
    })
    radarDrawings.border = newDrawing("Square",{
        Color=ESP_SETTINGS.RadarBorderColor, Thickness=1, Filled=false, Visible=false,
    })
    radarDrawings.self = newDrawing("Circle",{
        Color=ESP_SETTINGS.RadarSelfColor, Radius=4, Filled=true, Visible=false,
    })
    for i=1,RADAR_BLIP_POOL do
        radarDrawings.blips[i] = newDrawing("Circle",{Radius=4, Filled=true, Visible=false})
    end
end

local function updateRadar()
    local now = tick()
    if now - _radarLastTick < RADAR_HZ then return end
    _radarLastTick = now

    initRadar()

    local s     = ESP_SETTINGS
    local size  = s.RadarSize
    local rx,ry = s.RadarX, s.RadarY

    if not s.ShowRadar or not s.Enabled then
        radarDrawings.bg.Visible     = false
        radarDrawings.border.Visible = false
        radarDrawings.self.Visible   = false
        for i=1,#radarDrawings.blips do radarDrawings.blips[i].Visible=false end
        return
    end

    local sizeV = Vector2.new(size,size)
    local posV  = Vector2.new(rx,ry)

    radarDrawings.bg.Size         = sizeV
    radarDrawings.bg.Position     = posV
    radarDrawings.bg.Color        = s.RadarBgColor
    radarDrawings.bg.Transparency = s.RadarBgTransparency
    radarDrawings.bg.Visible      = true

    radarDrawings.border.Size     = sizeV
    radarDrawings.border.Position = posV
    radarDrawings.border.Color    = s.RadarBorderColor
    radarDrawings.border.Visible  = true

    local cx = rx + size/2
    local cy = ry + size/2
    radarDrawings.self.Position = Vector2.new(cx, cy)
    radarDrawings.self.Color    = s.RadarSelfColor
    radarDrawings.self.Visible  = true

    local selfRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not selfRoot then return end

    local selfPos  = selfRoot.Position
    local camCF    = camera.CFrame
    local camRight = camCF.RightVector
    local camLook  = camCF.LookVector
    local invRange = (size/2) / s.RadarRange
    local myTeam   = localPlayer.Team
    local tc       = s.Teamcheck
    local eCol     = s.RadarEnemyColor
    local tCol     = s.RadarTeamColor

    local idx = 1
    for _, player in ipairs(Players:GetPlayers()) do
        if player == localPlayer then continue end
        local char = player.Character
        if not char then continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        local isTm = player.Team == myTeam
        if tc  and not isTm then continue end
        if not tc and isTm  then continue end

        local delta = root.Position - selfPos
        -- project world delta onto camera right/look for correct orientation
        local relX =  camRight.X*delta.X + camRight.Z*delta.Z
        local relZ = -(camLook.X*delta.X  + camLook.Z*delta.Z)

        local bx = math.clamp(cx + relX*invRange, rx, rx+size)
        local bz = math.clamp(cy + relZ*invRange, ry, ry+size)

        local blip = radarDrawings.blips[idx]
        if not blip then
            blip = newDrawing("Circle",{Radius=4,Filled=true,Visible=false})
            radarDrawings.blips[idx] = blip
        end
        blip.Color    = isTm and tCol or eCol
        blip.Position = Vector2.new(bx, bz)
        blip.Visible  = true
        idx += 1
    end

    for i=idx, #radarDrawings.blips do
        radarDrawings.blips[i].Visible = false
    end
end

-- ─────────────────────────────────────────────────────────────
--// ChinaHat
-- ─────────────────────────────────────────────────────────────
local chinaHats = {}

local function removeChinaHat(player)
    local d = chinaHats[player]
    if not d then return end
    if d.weld then d.weld:Destroy() end
    if d.hat  then d.hat:Destroy()  end
    chinaHats[player] = nil
end

local function attachChinaHat(player, head)
    removeChinaHat(player)
    local s   = ESP_SETTINGS
    local hat = Instance.new("MeshPart")
    hat.Name         = "GatyWareChinaHat"
    hat.MeshId       = s.ChinaHatMeshId
    hat.Size         = s.ChinaHatSize
    hat.Color        = s.ChinaHatColor
    hat.Material     = s.ChinaHatMaterial
    hat.Transparency = 0
    hat.CanCollide   = false
    hat.CanQuery     = false
    hat.Massless     = true
    hat.CastShadow   = true
    hat.Parent       = camera
    hat.CFrame       = head.CFrame + s.ChinaHatHeadOffset
    local weld  = Instance.new("WeldConstraint")
    weld.Part0  = hat
    weld.Part1  = head
    weld.Parent = hat
    chinaHats[player] = {hat=hat, weld=weld}
end

local function updateChinaHats()
    local s = ESP_SETTINGS
    for _, player in ipairs(Players:GetPlayers()) do
        if player == localPlayer then continue end
        local isTm   = player.Team and player.Team == localPlayer.Team
        local should = s.ShowChinaHat and s.Enabled and (not s.Teamcheck or not isTm)
        if should then
            local char = player.Character
            if char then
                local head = char:FindFirstChild("Head")
                if head and not chinaHats[player] then attachChinaHat(player,head) end
            end
        else
            removeChinaHat(player)
        end
    end
end

-- ─────────────────────────────────────────────────────────────
--// Chams
-- ─────────────────────────────────────────────────────────────
local chamsCache = {}

local function removeChams(player)
    if chamsCache[player] then chamsCache[player]:Destroy() chamsCache[player]=nil end
end

local function applyChams(player)
    local char = player.Character
    if not char then removeChams(player) return end
    local s = ESP_SETTINGS
    if not chamsCache[player] then
        local sb              = Instance.new("SelectionBox")
        sb.LineThickness      = 0.05
        sb.SurfaceTransparency= s.ChamsTransparency
        sb.SurfaceColor3      = s.ChamsColor
        sb.Color3             = s.ChamsColor
        sb.Adornee            = char
        sb.Parent             = camera
        chamsCache[player]    = sb
    else
        chamsCache[player].Adornee             = char
        chamsCache[player].SurfaceColor3       = s.ChamsColor
        chamsCache[player].Color3              = s.ChamsColor
        chamsCache[player].SurfaceTransparency = s.ChamsTransparency
    end
end

local function updateChams()
    local s = ESP_SETTINGS
    for _, player in ipairs(Players:GetPlayers()) do
        if player == localPlayer then continue end
        local isTm   = player.Team and player.Team == localPlayer.Team
        local should = s.ShowChams and s.Enabled and (not s.Teamcheck or not isTm)
        if should then applyChams(player) else removeChams(player) end
    end
end

-- ─────────────────────────────────────────────────────────────
--// ESP per-player create / remove
-- ─────────────────────────────────────────────────────────────
local function createEsp(player)
    local s   = ESP_SETTINGS
    local esp = {
        cachedName   = string.lower(player.Name),
        boxOutline   = newDrawing("Square",{Color=s.BoxOutlineColor, Thickness=3, Filled=false, Visible=false}),
        box          = newDrawing("Square",{Color=s.BoxColor,        Thickness=1, Filled=false, Visible=false}),
        name         = newDrawing("Text",  {Color=s.NameColor, Outline=true, Center=true, Size=13, Visible=false}),
        healthOutline= newDrawing("Line",  {Thickness=3, Color=s.HealthOutlineColor, Visible=false}),
        health       = newDrawing("Line",  {Thickness=1, Color=Color3.new(0,1,0),    Visible=false}),
        distance     = newDrawing("Text",  {Color=Color3.new(1,1,1), Size=12, Outline=true, Center=true, Visible=false}),
        tracer       = newDrawing("Line",  {Thickness=s.TracerThickness, Color=s.TracerColor, Visible=false}),
        espImage     = nil,
        boxLines     = {},
        skeletonlines= {},
    }
    if s.ShowCustomImage then
        esp.espImage = loadImage("CustomImages", s.CustomImageName)
    end
    cache[player] = esp
end

local function removeEsp(player)
    local esp = cache[player]
    if not esp then return end
    for k,v in pairs(esp) do
        if k=="skeletonlines" or k=="boxLines" or k=="espImage" or k=="cachedName" then continue end
        pcall(function() v:Remove() end)
    end
    clearSkeletonLines(esp)
    clearBoxLines(esp)
    removeChinaHat(player)
    removeChams(player)
    visCache[player]     = nil
    visTimestamp[player] = nil
    cache[player]        = nil
end

-- ─────────────────────────────────────────────────────────────
--// Main ESP update
-- ─────────────────────────────────────────────────────────────
local function updateEsp()
    local s = ESP_SETTINGS

    for player, esp in pairs(cache) do
        local char = player.Character
        local isTm = player.Team and player.Team == localPlayer.Team

        if s.Teamcheck and isTm then hideAll(esp) continue end
        if not char            then hideAll(esp) continue end

        local root     = char:FindFirstChild("HumanoidRootPart")
        local head     = char:FindFirstChild("Head")
        local humanoid = char:FindFirstChildOfClass("Humanoid")

        if not root or not humanoid then hideAll(esp) continue end

        local visible    = isVisible(player)
        local shouldShow = s.Enabled and (not s.WallCheck or visible)

        if not shouldShow then hideAll(esp) continue end

        local hrp2D, onScreen = camera:WorldToViewportPoint(root.Position)
        if not onScreen or hrp2D.Z <= 0 then hideAll(esp) continue end

        local topY    = camera:WorldToViewportPoint(root.Position + Vector3.new(0,2.6,0)).Y
        local bottomY = camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0)).Y
        local charSize = math.abs(bottomY - topY) / 2
        if charSize < 1 then hideAll(esp) continue end

        local boxW = math.floor(charSize * 1.8)
        local boxH = math.floor(charSize * 1.9)
        local boxX = math.floor(hrp2D.X - boxW/2)
        local boxY = math.floor(hrp2D.Y - charSize*1.6/2)
        local boxSize     = Vector2.new(boxW, boxH)
        local boxPosition = Vector2.new(boxX, boxY)

        -- visibility-check color overrides
        local activeBox    = s.BoxColor
        local activeTracer = s.TracerColor
        local activeName   = s.NameColor
        if s.ShowVisibilityCheck then
            local vc    = visible and s.VisibleColor or s.OccludedColor
            activeBox   = vc
            activeTracer= vc
            activeName  = vc
        end

        -- ── Name ──────────────────────────────────────────────
        if s.ShowName then
            esp.name.Text     = esp.cachedName
            esp.name.Position = Vector2.new(boxX + boxW/2, boxY - 16)
            esp.name.Color    = activeName
            esp.name.Visible  = true
        else
            esp.name.Visible = false
        end

        -- ── Box ───────────────────────────────────────────────
        if s.ShowBox then
            if s.BoxType == "2D" then
                if #esp.boxLines > 0 then clearBoxLines(esp) end
                esp.boxOutline.Size     = boxSize
                esp.boxOutline.Position = boxPosition
                esp.box.Size            = boxSize
                esp.box.Position        = boxPosition
                esp.box.Color           = activeBox
                esp.box.Visible         = true
                esp.boxOutline.Visible  = true
            elseif s.BoxType == "Corner Box Esp" then
                esp.box.Visible        = false
                esp.boxOutline.Visible = false

                local lineW = boxW/5
                local lineH = boxH/6
                local T     = 1

                if #esp.boxLines == 0 then
                    for i=1,16 do
                        esp.boxLines[i] = newDrawing("Line",{Thickness=1, Visible=false})
                    end
                end

                local bl = esp.boxLines
                -- update colors every frame so visibility-check changes apply
                for i=1,8  do bl[i].Color=activeBox       bl[i].Thickness=1 end
                for i=9,16 do bl[i].Color=s.BoxOutlineColor bl[i].Thickness=2 end

                bl[1].From=Vector2.new(boxX-T,boxY-T)          bl[1].To=Vector2.new(boxX+lineW,boxY-T)
                bl[2].From=Vector2.new(boxX-T,boxY-T)          bl[2].To=Vector2.new(boxX-T,boxY+lineH)
                bl[3].From=Vector2.new(boxX+boxW-lineW,boxY-T) bl[3].To=Vector2.new(boxX+boxW+T,boxY-T)
                bl[4].From=Vector2.new(boxX+boxW+T,boxY-T)     bl[4].To=Vector2.new(boxX+boxW+T,boxY+lineH)
                bl[5].From=Vector2.new(boxX-T,boxY+boxH-lineH) bl[5].To=Vector2.new(boxX-T,boxY+boxH+T)
                bl[6].From=Vector2.new(boxX-T,boxY+boxH+T)     bl[6].To=Vector2.new(boxX+lineW,boxY+boxH+T)
                bl[7].From=Vector2.new(boxX+boxW-lineW,boxY+boxH+T) bl[7].To=Vector2.new(boxX+boxW+T,boxY+boxH+T)
                bl[8].From=Vector2.new(boxX+boxW+T,boxY+boxH-lineH) bl[8].To=Vector2.new(boxX+boxW+T,boxY+boxH+T)
                bl[9].From=Vector2.new(boxX,boxY)              bl[9].To=Vector2.new(boxX,boxY+lineH)
                bl[10].From=Vector2.new(boxX,boxY)             bl[10].To=Vector2.new(boxX+lineW,boxY)
                bl[11].From=Vector2.new(boxX+boxW-lineW,boxY)  bl[11].To=Vector2.new(boxX+boxW,boxY)
                bl[12].From=Vector2.new(boxX+boxW,boxY)        bl[12].To=Vector2.new(boxX+boxW,boxY+lineH)
                bl[13].From=Vector2.new(boxX,boxY+boxH-lineH)  bl[13].To=Vector2.new(boxX,boxY+boxH)
                bl[14].From=Vector2.new(boxX,boxY+boxH)        bl[14].To=Vector2.new(boxX+lineW,boxY+boxH)
                bl[15].From=Vector2.new(boxX+boxW-lineW,boxY+boxH) bl[15].To=Vector2.new(boxX+boxW,boxY+boxH)
                bl[16].From=Vector2.new(boxX+boxW,boxY+boxH-lineH) bl[16].To=Vector2.new(boxX+boxW,boxY+boxH)

                for _,line in ipairs(bl) do line.Visible=true end
            end
        else
            esp.box.Visible        = false
            esp.boxOutline.Visible = false
            if #esp.boxLines > 0 then clearBoxLines(esp) end
        end

        -- ── Health ────────────────────────────────────────────
        if s.ShowHealth then
            local hp = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
            esp.healthOutline.From    = Vector2.new(boxX-6, boxY+boxH)
            esp.healthOutline.To      = Vector2.new(boxX-6, boxY)
            esp.health.From           = Vector2.new(boxX-5, boxY+boxH)
            esp.health.To             = Vector2.new(boxX-5, boxY+boxH - hp*boxH)
            esp.health.Color          = s.HealthLowColor:Lerp(s.HealthHighColor, hp)
            esp.healthOutline.Visible = true
            esp.health.Visible        = true
        else
            esp.healthOutline.Visible = false
            esp.health.Visible        = false
        end

        -- ── Distance ──────────────────────────────────────────
        if s.ShowDistance then
            local dist = (camera.CFrame.Position - root.Position).Magnitude
            esp.distance.Text     = string.format("%.1f studs", dist)
            esp.distance.Position = Vector2.new(boxX + boxW/2, boxY + boxH + 5)
            esp.distance.Visible  = true
        else
            esp.distance.Visible = false
        end

        -- ── Skeleton ──────────────────────────────────────────
        if s.ShowSkeletons then
            local isR15 = char:FindFirstChild("UpperTorso") ~= nil
            if isR15 then
                if #esp.skeletonlines == 0 then
                    for _, bp in ipairs(bones) do
                        local p,c = bp[1],bp[2]
                        if char:FindFirstChild(p) and char:FindFirstChild(c) then
                            local sl = newDrawing("Line",{Thickness=1, Color=s.SkeletonsColor, Visible=false})
                            esp.skeletonlines[#esp.skeletonlines+1] = {sl,p,c}
                        end
                    end
                end
                for _, ld in ipairs(esp.skeletonlines) do
                    local sl,p,c = ld[1],ld[2],ld[3]
                    local partP  = char:FindFirstChild(p)
                    local partC  = char:FindFirstChild(c)
                    if partP and partC then
                        local pp2D = camera:WorldToViewportPoint(partP.Position)
                        local cp2D = camera:WorldToViewportPoint(partC.Position)
                        if pp2D.Z > 0 and cp2D.Z > 0 then
                            sl.From    = Vector2.new(pp2D.X, pp2D.Y)
                            sl.To      = Vector2.new(cp2D.X, cp2D.Y)
                            sl.Color   = s.SkeletonsColor
                            sl.Visible = true
                        else
                            sl.Visible = false
                        end
                    else
                        sl.Visible = false
                    end
                end
            else
                -- R6 or non-standard rig: just hide lines
                for _, ld in ipairs(esp.skeletonlines) do
                    pcall(function() ld[1].Visible=false end)
                end
            end
        else
            if #esp.skeletonlines > 0 then clearSkeletonLines(esp) end
        end

        -- ── Tracer ────────────────────────────────────────────
        if s.ShowTracer then
            local tracerY
            if s.TracerPosition == "Top" then
                tracerY = 0
            elseif s.TracerPosition == "Middle" then
                tracerY = camera.ViewportSize.Y / 2
            else
                tracerY = camera.ViewportSize.Y
            end
            esp.tracer.Color        = activeTracer
            esp.tracer.Thickness    = s.TracerThickness
            esp.tracer.Transparency = 0
            esp.tracer.From         = Vector2.new(camera.ViewportSize.X/2, tracerY)
            esp.tracer.To           = Vector2.new(hrp2D.X, hrp2D.Y)
            esp.tracer.Visible      = true
        else
            esp.tracer.Visible = false
        end

        -- ── Custom ESP Image ──────────────────────────────────
        if s.ShowCustomImage and esp.espImage then
            local imgW = boxW * s.CustomImageSizeRatio.X
            local imgH = boxH * s.CustomImageSizeRatio.Y
            esp.espImage.Size         = Vector2.new(imgW, imgH)
            esp.espImage.Position     = Vector2.new(boxX+(boxW-imgW)/2, boxY+(boxH-imgH)/2)
            esp.espImage.Transparency = s.CustomImageTransparency
            esp.espImage.Visible      = true
        elseif esp.espImage then
            esp.espImage.Visible = false
        end
    end

    updateChams()
    updateChinaHats()
    updateRadar()
    updateCursor()
end

-- ─────────────────────────────────────────────────────────────
--// Player hooks
-- ─────────────────────────────────────────────────────────────
local function hookPlayer(player)
    createEsp(player)
    player.CharacterAdded:Connect(function()
        local esp = cache[player]
        if not esp then return end
        clearSkeletonLines(esp)
        clearBoxLines(esp)
        visCache[player]     = nil
        visTimestamp[player] = nil
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= localPlayer then hookPlayer(player) end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= localPlayer then hookPlayer(player) end
end)

Players.PlayerRemoving:Connect(function(player)
    removeEsp(player)
end)

RunService.RenderStepped:Connect(updateEsp)

initRadar()
initCursor()

return ESP_SETTINGS
