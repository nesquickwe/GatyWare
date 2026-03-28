-- ═══════════════════════════════════════════════════════════════
--  esp.lua  ·  GatyWare Edition
-- ═══════════════════════════════════════════════════════════════
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInput  = game:GetService("UserInputService")
local lp         = Players.LocalPlayer
local camera     = workspace.CurrentCamera
local cache      = {}   -- [player] = esp-table

-- R15 bone pairs
local BONES = {
    {"Head","UpperTorso"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"UpperTorso","LeftUpperArm"}, {"LeftUpperArm","LeftLowerArm"},  {"LeftLowerArm","LeftHand"},
    {"UpperTorso","LowerTorso"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
    {"LowerTorso","LeftUpperLeg"}, {"LeftUpperLeg","LeftLowerLeg"},  {"LeftLowerLeg","LeftFoot"},
}

-- ─────────────────────────────────────────────────────────────
--  SETTINGS  (returned to caller so loader can mutate them)
-- ─────────────────────────────────────────────────────────────
local S = {
    -- ── Core ─────────────────────────────────────────────────
    Enabled   = false,
    -- Who gets ESP drawn on them:
    --   "Enemies"  = only players NOT on your team
    --   "Team"     = only players ON your team
    --   "All"      = everyone (including yourself if ShowSelfESP true)
    ESPTarget = "Enemies",
    WallCheck = false,      -- hide ESP when target is behind cover

    -- ── Self ESP ─────────────────────────────────────────────
    ShowSelfESP = false,    -- draw ESP on your own character

    -- ── Box ──────────────────────────────────────────────────
    ShowBox         = false,
    BoxType         = "2D",         -- "2D" | "Corner Box Esp"
    BoxColor        = Color3.new(1,1,1),
    BoxOutlineColor = Color3.new(0,0,0),
    BoxThickness    = 1,

    -- ── Name ─────────────────────────────────────────────────
    ShowName      = false,
    NameColor     = Color3.new(1,1,1),
    NameSize      = 13,
    NameUppercase = false,

    -- ── Health ───────────────────────────────────────────────
    ShowHealth         = false,
    HealthBar          = "Left",    -- "Left" | "Right" | "Bottom"
    HealthOutlineColor = Color3.new(0,0,0),
    HealthHighColor    = Color3.new(0,1,0),
    HealthLowColor     = Color3.new(1,0,0),
    ShowHealthText     = false,     -- show "HP: 75" text next to bar

    -- ── Distance ─────────────────────────────────────────────
    ShowDistance   = false,
    DistanceColor  = Color3.new(1,1,1),
    MaxESPDistance = 0,             -- 0 = unlimited

    -- ── Skeleton ─────────────────────────────────────────────
    ShowSkeletons    = false,
    SkeletonsColor   = Color3.new(1,1,1),
    SkeletonThickness= 1,

    -- ── Tracer ───────────────────────────────────────────────
    ShowTracer      = false,
    TracerColor     = Color3.new(0,1,0),
    TracerThickness = 1,
    TracerOrigin    = "Bottom",     -- "Bottom" | "Middle" | "Top" | "Mouse"

    -- ── Visibility Check ─────────────────────────────────────
    ShowVisibilityCheck = false,
    VisibleColor        = Color3.new(0,1,0),
    OccludedColor       = Color3.new(1,0.4,0),

    -- ── Chams ────────────────────────────────────────────────
    ShowChams          = false,
    ChamsColor         = Color3.new(1,0,0),
    ChamsTransparency  = 0.5,
    ChamsLineThickness = 0.05,

    -- ── Head Dot ─────────────────────────────────────────────
    ShowHeadDot      = false,
    HeadDotColor     = Color3.new(1,1,1),
    HeadDotRadius    = 4,
    HeadDotFilled    = true,

    -- ── Radar ────────────────────────────────────────────────
    ShowRadar            = false,
    RadarShowEnemies     = true,    -- show enemy blips
    RadarShowTeammates   = false,   -- show teammate blips
    RadarShowSelf        = true,    -- show self dot
    RadarSize            = 200,
    RadarRange           = 500,
    RadarX               = 100,
    RadarY               = 100,
    RadarBgColor         = Color3.new(0,0,0),
    RadarBgTransparency  = 0.5,
    RadarBorderColor     = Color3.new(1,1,1),
    RadarBorderThickness = 1,
    RadarEnemyColor      = Color3.new(1,0,0),
    RadarTeamColor       = Color3.new(0,1,0),
    RadarSelfColor       = Color3.new(1,1,1),
    RadarBlipSize        = 4,
    RadarSelfSize        = 5,
    RadarRotates         = true,    -- rotate radar with camera

    -- ── ChinaHat ─────────────────────────────────────────────
    ShowChinaHat        = false,
    ChinaHatMeshId      = "rbxassetid://1778999",
    ChinaHatSize        = Vector3.new(3,0.7,3),
    ChinaHatColor       = Color3.fromRGB(180,140,60),
    ChinaHatTransparency= 0,
    ChinaHatMaterial    = Enum.Material.SmoothPlastic,
    ChinaHatOffset      = Vector3.new(0,1,0),

    -- ── Custom ESP Image ─────────────────────────────────────
    ShowCustomImage         = false,
    CustomImageName         = "esp_image.png",
    CustomImageSizeRatio    = Vector2.new(1,1),
    CustomImageTransparency = 0,

    -- ── Custom Cursor ────────────────────────────────────────
    ShowCustomCursor         = false,
    CustomCursorName         = "cursor.png",
    CustomCursorSize         = Vector2.new(32,32),
    CustomCursorTransparency = 0,
    HideDefaultCursor        = true,
}

-- ─────────────────────────────────────────────────────────────
--  Folder setup
-- ─────────────────────────────────────────────────────────────
for _,p in ipairs({"GatyWare","GatyWare/CustomImages","GatyWare/CustomCursor"}) do
    if not isfolder(p) then makefolder(p) end
end

-- ─────────────────────────────────────────────────────────────
--  Drawing helpers
-- ─────────────────────────────────────────────────────────────
local function D(class, props)
    local d = Drawing.new(class)
    for k,v in pairs(props) do d[k]=v end
    return d
end

local function hideAll(esp)
    for k,v in pairs(esp) do
        if k=="sk" or k=="bl" or k=="img" or k=="name_" then continue end
        pcall(function() v.Visible=false end)
    end
    for _,ld in ipairs(esp.sk or {}) do pcall(function() ld[1].Visible=false end) end
    for _,l  in ipairs(esp.bl or {}) do pcall(function() l.Visible=false    end) end
    if esp.img then pcall(function() esp.img.Visible=false end) end
end

local function clearSk(esp)
    for _,ld in ipairs(esp.sk or {}) do pcall(function() ld[1]:Remove() end) end
    esp.sk={}
end

local function clearBl(esp)
    for _,l in ipairs(esp.bl or {}) do pcall(function() l:Remove() end) end
    esp.bl={}
end

-- ─────────────────────────────────────────────────────────────
--  Visibility cache (10 hz raycast per player)
-- ─────────────────────────────────────────────────────────────
local visVal = {}
local visTick= {}
local VIS_HZ = 1/10

local function checkVis(player, char, root)
    local now = tick()
    if visTick[player] and now-visTick[player] < VIS_HZ then return visVal[player] end
    visTick[player] = now
    local origin = camera.CFrame.Position
    local hit    = workspace:FindPartOnRayWithIgnoreList(
        Ray.new(origin, root.Position-origin), {lp.Character, char})
    visVal[player] = (hit==nil)
    return visVal[player]
end

-- ─────────────────────────────────────────────────────────────
--  Image loading
-- ─────────────────────────────────────────────────────────────
local imgCache = {}
local function loadImg(folder, name)
    local key = folder.."/"..name
    if imgCache[key] then return imgCache[key] end
    local path = "GatyWare/"..folder.."/"..name
    if not isfile(path) then warn("[GatyWare] Missing: "..path) return nil end
    local ok,data = pcall(readfile, path)
    if not ok or not data or data=="" then warn("[GatyWare] Read failed: "..path) return nil end
    local img=Drawing.new("Image"); img.Data=data; img.Visible=false
    imgCache[key]=img; return img
end

-- ─────────────────────────────────────────────────────────────
--  Custom Cursor
-- ─────────────────────────────────────────────────────────────
local cursorImg  = nil
local cursorGui  = nil  -- used to hide default cursor via ImageLabel trick

local function updateCursor()
    if not S.ShowCustomCursor then
        if cursorImg then cursorImg.Visible=false end
        if cursorGui then cursorGui:Destroy() cursorGui=nil end
        return
    end

    -- lazy-load image
    if not cursorImg then
        cursorImg = loadImg("CustomCursor", S.CustomCursorName)
        if not cursorImg then return end
    end

    -- hide default cursor
    if S.HideDefaultCursor and not cursorGui then
        -- use a transparent ImageLabel parented to PlayerGui to suppress cursor
        local sg = Instance.new("ScreenGui")
        sg.Name="GWCursorHider" sg.ResetOnSpawn=false sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
        local il=Instance.new("ImageLabel",sg)
        il.Size=UDim2.new(1,0,1,0) il.BackgroundTransparency=1 il.ImageTransparency=1
        sg.Parent=lp.PlayerGui
        cursorGui=sg
        UserInput.MouseIconEnabled=false
    elseif not S.HideDefaultCursor then
        if cursorGui then cursorGui:Destroy() cursorGui=nil end
        UserInput.MouseIconEnabled=true
    end

    local mp = UserInput:GetMouseLocation()
    local sz = S.CustomCursorSize
    cursorImg.Size         = sz
    cursorImg.Position     = Vector2.new(mp.X-sz.X/2, mp.Y-sz.Y/2)
    cursorImg.Transparency = 1 - (1-S.CustomCursorTransparency)  -- Drawing uses 0=opaque
    cursorImg.Visible      = true
end

-- ─────────────────────────────────────────────────────────────
--  Radar
-- ─────────────────────────────────────────────────────────────
local RD = { bg=nil, border=nil, selfDot=nil, blips={} }
local _rTick = 0
local RADAR_HZ = 1/20

local function initRadar()
    if RD.bg then return end
    RD.bg      = D("Square",{Filled=true,  Visible=false})
    RD.border  = D("Square",{Filled=false, Visible=false})
    RD.selfDot = D("Circle",{Filled=true,  Visible=false})
    for i=1,100 do RD.blips[i]=D("Circle",{Filled=true,Visible=false}) end
end

local function updateRadar()
    local now=tick()
    if now-_rTick < RADAR_HZ then return end
    _rTick=now
    initRadar()

    if not S.ShowRadar or not S.Enabled then
        RD.bg.Visible=false RD.border.Visible=false RD.selfDot.Visible=false
        for _,b in ipairs(RD.blips) do b.Visible=false end
        return
    end

    local sz=S.RadarSize; local rx=S.RadarX; local ry=S.RadarY
    local sv=Vector2.new(sz,sz); local pv=Vector2.new(rx,ry)
    local cx=rx+sz/2; local cy=ry+sz/2

    RD.bg.Size=sv; RD.bg.Position=pv
    RD.bg.Color=S.RadarBgColor; RD.bg.Transparency=S.RadarBgTransparency
    RD.bg.Visible=true

    RD.border.Size=sv; RD.border.Position=pv
    RD.border.Color=S.RadarBorderColor; RD.border.Thickness=S.RadarBorderThickness
    RD.border.Visible=true

    local selfRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")

    if S.RadarShowSelf and selfRoot then
        RD.selfDot.Position=Vector2.new(cx,cy)
        RD.selfDot.Color=S.RadarSelfColor
        RD.selfDot.Radius=S.RadarSelfSize
        RD.selfDot.Visible=true
    else
        RD.selfDot.Visible=false
    end

    if not selfRoot then
        for _,b in ipairs(RD.blips) do b.Visible=false end
        return
    end

    local selfPos  = selfRoot.Position
    local camCF    = camera.CFrame
    local camRight = camCF.RightVector
    local camLook  = camCF.LookVector
    local invRange = (sz/2)/S.RadarRange
    local myTeam   = lp.Team
    local idx=1

    for _,player in ipairs(Players:GetPlayers()) do
        if player==lp then continue end
        local char=player.Character
        if not char then continue end
        local root=char:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        local isTm = (player.Team~=nil) and (player.Team==myTeam)

        -- filter by radar settings
        if isTm  and not S.RadarShowTeammates then continue end
        if not isTm and not S.RadarShowEnemies   then continue end

        local delta=root.Position-selfPos
        local relX,relZ

        if S.RadarRotates then
            -- rotate relative to camera facing
            relX =  camRight.X*delta.X + camRight.Z*delta.Z
            relZ = -(camLook.X*delta.X  + camLook.Z*delta.Z)
        else
            -- north-up (world space)
            relX =  delta.X
            relZ = -delta.Z
        end

        local bx=math.clamp(cx+relX*invRange, rx, rx+sz)
        local bz=math.clamp(cy+relZ*invRange, ry, ry+sz)

        local blip=RD.blips[idx]
        if not blip then
            blip=D("Circle",{Filled=true,Visible=false})
            RD.blips[idx]=blip
        end
        blip.Color    = isTm and S.RadarTeamColor or S.RadarEnemyColor
        blip.Radius   = S.RadarBlipSize
        blip.Position = Vector2.new(bx,bz)
        blip.Visible  = true
        idx+=1
    end

    for i=idx,#RD.blips do RD.blips[i].Visible=false end
end

-- ─────────────────────────────────────────────────────────────
--  ChinaHat
-- ─────────────────────────────────────────────────────────────
local hats={}

local function removeHat(player)
    local d=hats[player]; if not d then return end
    if d.weld then d.weld:Destroy() end
    if d.hat  then d.hat:Destroy()  end
    hats[player]=nil
end

local function attachHat(player, head)
    removeHat(player)
    local hat=Instance.new("MeshPart")
    hat.Name=         "GWChinaHat"
    hat.MeshId=       S.ChinaHatMeshId
    hat.Size=         S.ChinaHatSize
    hat.Color=        S.ChinaHatColor
    hat.Material=     S.ChinaHatMaterial
    hat.Transparency= S.ChinaHatTransparency
    hat.CanCollide=   false; hat.CanQuery=false; hat.Massless=true; hat.CastShadow=true
    hat.Parent=       camera
    hat.CFrame=       head.CFrame+S.ChinaHatOffset
    local w=Instance.new("WeldConstraint"); w.Part0=hat; w.Part1=head; w.Parent=hat
    hats[player]={hat=hat,weld=w}
end

local function updateHats()
    for _,player in ipairs(Players:GetPlayers()) do
        if player==lp and not S.ShowSelfESP then continue end
        local isTm=(player.Team~=nil) and (player.Team==lp.Team)
        local should=S.ShowChinaHat and S.Enabled and _shouldDrawPlayer(player, isTm)
        if should then
            local char=player.Character
            if char then
                local head=char:FindFirstChild("Head")
                if head and not hats[player] then attachHat(player,head) end
                -- update transparency live
                if hats[player] then hats[player].hat.Transparency=S.ChinaHatTransparency end
            end
        else removeHat(player) end
    end
end

-- ─────────────────────────────────────────────────────────────
--  Chams
-- ─────────────────────────────────────────────────────────────
local chams={}

local function removeChams(player)
    if chams[player] then chams[player]:Destroy(); chams[player]=nil end
end

local function applyChams(player)
    local char=player.Character; if not char then removeChams(player) return end
    if not chams[player] then
        local sb=Instance.new("SelectionBox")
        sb.LineThickness=S.ChamsLineThickness; sb.SurfaceTransparency=S.ChamsTransparency
        sb.SurfaceColor3=S.ChamsColor; sb.Color3=S.ChamsColor; sb.Adornee=char; sb.Parent=camera
        chams[player]=sb
    else
        chams[player].Adornee=char; chams[player].SurfaceColor3=S.ChamsColor
        chams[player].Color3=S.ChamsColor; chams[player].SurfaceTransparency=S.ChamsTransparency
        chams[player].LineThickness=S.ChamsLineThickness
    end
end

local function updateChams()
    for _,player in ipairs(Players:GetPlayers()) do
        if player==lp and not S.ShowSelfESP then removeChams(player) continue end
        local isTm=(player.Team~=nil) and (player.Team==lp.Team)
        if S.ShowChams and S.Enabled and _shouldDrawPlayer(player,isTm) then
            applyChams(player)
        else removeChams(player) end
    end
end

-- ─────────────────────────────────────────────────────────────
--  Target filter helper
--  Returns true if we should draw ESP on this player
-- ─────────────────────────────────────────────────────────────
-- (defined here so hat/chams updates above can reference it;
--  Lua resolves upvalues at call time so forward-refs are fine)
_shouldDrawPlayer = function(player, isTm)
    if player==lp then return S.ShowSelfESP end
    local t=S.ESPTarget
    if t=="Enemies"  then return not isTm end
    if t=="Team"     then return isTm     end
    return true  -- "All"
end

-- ─────────────────────────────────────────────────────────────
--  Per-player ESP create / remove
-- ─────────────────────────────────────────────────────────────
local function createEsp(player)
    local esp={
        name_=string.lower(player.Name),
        box        =D("Square",{Thickness=S.BoxThickness,   Filled=false,Visible=false}),
        boxOutline =D("Square",{Thickness=S.BoxThickness+2, Filled=false,Visible=false}),
        name       =D("Text",  {Outline=true,Center=true,Size=S.NameSize,Visible=false}),
        hpOutline  =D("Line",  {Thickness=3,Visible=false}),
        hp         =D("Line",  {Thickness=1,Visible=false}),
        hpText     =D("Text",  {Outline=true,Center=true,Size=11,Visible=false}),
        dist       =D("Text",  {Outline=true,Center=true,Size=12,Visible=false}),
        tracer     =D("Line",  {Thickness=S.TracerThickness,Visible=false}),
        headDot    =D("Circle",{Radius=S.HeadDotRadius,Filled=S.HeadDotFilled,Visible=false}),
        img        =nil,
        bl         ={},
        sk         ={},
    }
    if S.ShowCustomImage then esp.img=loadImg("CustomImages",S.CustomImageName) end
    cache[player]=esp
end

local function removeEsp(player)
    local esp=cache[player]; if not esp then return end
    for k,v in pairs(esp) do
        if k=="sk" or k=="bl" or k=="img" or k=="name_" then continue end
        pcall(function() v:Remove() end)
    end
    clearSk(esp); clearBl(esp)
    removeHat(player); removeChams(player)
    visVal[player]=nil; visTick[player]=nil
    cache[player]=nil
end

-- ─────────────────────────────────────────────────────────────
--  Main update
-- ─────────────────────────────────────────────────────────────
local function drawEspForPlayer(player, esp, isSelf)
    local s     = S
    local char  = player.Character
    if not char then hideAll(esp) return end

    local root     = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local head     = char:FindFirstChild("Head")
    if not root or not humanoid then hideAll(esp) return end

    -- distance gate
    local distV = (camera.CFrame.Position - root.Position)
    local dist  = distV.Magnitude
    if s.MaxESPDistance > 0 and dist > s.MaxESPDistance then hideAll(esp) return end

    -- wall check (skip for self)
    local visible = isSelf or checkVis(player, char, root)
    if s.WallCheck and not visible and not isSelf then hideAll(esp) return end

    local hrp2D, onScreen = camera:WorldToViewportPoint(root.Position)
    if not onScreen or hrp2D.Z <= 0 then hideAll(esp) return end

    local topY    = camera:WorldToViewportPoint(root.Position+Vector3.new(0,2.6,0)).Y
    local botY    = camera:WorldToViewportPoint(root.Position-Vector3.new(0,3,0)).Y
    local cs      = math.abs(botY-topY)/2
    if cs < 1 then hideAll(esp) return end

    local bW=math.floor(cs*1.8); local bH=math.floor(cs*1.9)
    local bX=math.floor(hrp2D.X-bW/2); local bY=math.floor(hrp2D.Y-cs*1.6/2)

    -- active colors
    local acBox,acTr,acName = s.BoxColor, s.TracerColor, s.NameColor
    if s.ShowVisibilityCheck and not isSelf then
        local vc = visible and s.VisibleColor or s.OccludedColor
        acBox=vc; acTr=vc; acName=vc
    end

    -- ── Name ─────────────────────────────────────────────────
    if s.ShowName then
        local txt = s.NameUppercase and string.upper(esp.name_) or esp.name_
        esp.name.Text=txt; esp.name.Size=s.NameSize; esp.name.Color=acName
        esp.name.Position=Vector2.new(bX+bW/2, bY-s.NameSize-2)
        esp.name.Visible=true
    else esp.name.Visible=false end

    -- ── Box ──────────────────────────────────────────────────
    if s.ShowBox then
        if s.BoxType=="2D" then
            if #esp.bl>0 then clearBl(esp) end
            local bsz=Vector2.new(bW,bH); local bpos=Vector2.new(bX,bY)
            esp.boxOutline.Size=bsz; esp.boxOutline.Position=bpos
            esp.boxOutline.Color=s.BoxOutlineColor; esp.boxOutline.Thickness=s.BoxThickness+2
            esp.box.Size=bsz; esp.box.Position=bpos
            esp.box.Color=acBox; esp.box.Thickness=s.BoxThickness
            esp.box.Visible=true; esp.boxOutline.Visible=true
        elseif s.BoxType=="Corner Box Esp" then
            esp.box.Visible=false; esp.boxOutline.Visible=false
            local lW=bW/5; local lH=bH/6; local T=1
            if #esp.bl==0 then for i=1,16 do esp.bl[i]=D("Line",{Visible=false}) end end
            local bl=esp.bl
            for i=1,8  do bl[i].Color=acBox;           bl[i].Thickness=s.BoxThickness   end
            for i=9,16 do bl[i].Color=s.BoxOutlineColor; bl[i].Thickness=s.BoxThickness+1 end
            bl[1].From=Vector2.new(bX-T,bY-T);          bl[1].To=Vector2.new(bX+lW,bY-T)
            bl[2].From=Vector2.new(bX-T,bY-T);          bl[2].To=Vector2.new(bX-T,bY+lH)
            bl[3].From=Vector2.new(bX+bW-lW,bY-T);      bl[3].To=Vector2.new(bX+bW+T,bY-T)
            bl[4].From=Vector2.new(bX+bW+T,bY-T);       bl[4].To=Vector2.new(bX+bW+T,bY+lH)
            bl[5].From=Vector2.new(bX-T,bY+bH-lH);      bl[5].To=Vector2.new(bX-T,bY+bH+T)
            bl[6].From=Vector2.new(bX-T,bY+bH+T);       bl[6].To=Vector2.new(bX+lW,bY+bH+T)
            bl[7].From=Vector2.new(bX+bW-lW,bY+bH+T);  bl[7].To=Vector2.new(bX+bW+T,bY+bH+T)
            bl[8].From=Vector2.new(bX+bW+T,bY+bH-lH);  bl[8].To=Vector2.new(bX+bW+T,bY+bH+T)
            bl[9].From=Vector2.new(bX,bY);               bl[9].To=Vector2.new(bX,bY+lH)
            bl[10].From=Vector2.new(bX,bY);              bl[10].To=Vector2.new(bX+lW,bY)
            bl[11].From=Vector2.new(bX+bW-lW,bY);       bl[11].To=Vector2.new(bX+bW,bY)
            bl[12].From=Vector2.new(bX+bW,bY);          bl[12].To=Vector2.new(bX+bW,bY+lH)
            bl[13].From=Vector2.new(bX,bY+bH-lH);       bl[13].To=Vector2.new(bX,bY+bH)
            bl[14].From=Vector2.new(bX,bY+bH);          bl[14].To=Vector2.new(bX+lW,bY+bH)
            bl[15].From=Vector2.new(bX+bW-lW,bY+bH);   bl[15].To=Vector2.new(bX+bW,bY+bH)
            bl[16].From=Vector2.new(bX+bW,bY+bH-lH);   bl[16].To=Vector2.new(bX+bW,bY+bH)
            for _,l in ipairs(bl) do l.Visible=true end
        end
    else
        esp.box.Visible=false; esp.boxOutline.Visible=false
        if #esp.bl>0 then clearBl(esp) end
    end

    -- ── Health bar ───────────────────────────────────────────
    if s.ShowHealth then
        local hp=math.clamp(humanoid.Health/humanoid.MaxHealth,0,1)
        local hCol=s.HealthLowColor:Lerp(s.HealthHighColor,hp)
        if s.HealthBar=="Left" then
            esp.hpOutline.From=Vector2.new(bX-6,bY+bH); esp.hpOutline.To=Vector2.new(bX-6,bY)
            esp.hp.From=Vector2.new(bX-5,bY+bH);        esp.hp.To=Vector2.new(bX-5,bY+bH-hp*bH)
        elseif s.HealthBar=="Right" then
            esp.hpOutline.From=Vector2.new(bX+bW+6,bY+bH); esp.hpOutline.To=Vector2.new(bX+bW+6,bY)
            esp.hp.From=Vector2.new(bX+bW+5,bY+bH);        esp.hp.To=Vector2.new(bX+bW+5,bY+bH-hp*bH)
        elseif s.HealthBar=="Bottom" then
            esp.hpOutline.From=Vector2.new(bX,bY+bH+6); esp.hpOutline.To=Vector2.new(bX+bW,bY+bH+6)
            esp.hp.From=Vector2.new(bX,bY+bH+5);        esp.hp.To=Vector2.new(bX+hp*bW,bY+bH+5)
        end
        esp.hpOutline.Color=s.HealthOutlineColor; esp.hpOutline.Thickness=3
        esp.hp.Color=hCol; esp.hp.Thickness=1
        esp.hpOutline.Visible=true; esp.hp.Visible=true
        if s.ShowHealthText then
            local hpPct=math.floor(hp*100)
            local tx=s.HealthBar=="Right" and bX+bW+10 or bX-10
            local ty=bY+bH/2
            esp.hpText.Text=hpPct.."%"; esp.hpText.Color=hCol
            esp.hpText.Position=Vector2.new(tx,ty); esp.hpText.Visible=true
        else esp.hpText.Visible=false end
    else
        esp.hpOutline.Visible=false; esp.hp.Visible=false; esp.hpText.Visible=false
    end

    -- ── Distance ─────────────────────────────────────────────
    if s.ShowDistance then
        esp.dist.Text=string.format("%.0f studs",dist)
        esp.dist.Color=s.DistanceColor
        esp.dist.Position=Vector2.new(bX+bW/2, bY+bH+4)
        esp.dist.Visible=true
    else esp.dist.Visible=false end

    -- ── Head dot ─────────────────────────────────────────────
    if s.ShowHeadDot and head then
        local h2D,hs=camera:WorldToViewportPoint(head.Position)
        if hs and h2D.Z>0 then
            esp.headDot.Position=Vector2.new(h2D.X,h2D.Y)
            esp.headDot.Color=s.HeadDotColor
            esp.headDot.Radius=s.HeadDotRadius
            esp.headDot.Filled=s.HeadDotFilled
            esp.headDot.Visible=true
        else esp.headDot.Visible=false end
    else esp.headDot.Visible=false end

    -- ── Skeleton ─────────────────────────────────────────────
    if s.ShowSkeletons then
        if char:FindFirstChild("UpperTorso") then
            if #esp.sk==0 then
                for _,bp in ipairs(BONES) do
                    local p,c=bp[1],bp[2]
                    if char:FindFirstChild(p) and char:FindFirstChild(c) then
                        local sl=D("Line",{Thickness=s.SkeletonThickness,Color=s.SkeletonsColor,Visible=false})
                        esp.sk[#esp.sk+1]={sl,p,c}
                    end
                end
            end
            for _,ld in ipairs(esp.sk) do
                local sl,p,c=ld[1],ld[2],ld[3]
                local pp=char:FindFirstChild(p); local pc=char:FindFirstChild(c)
                if pp and pc then
                    local a=camera:WorldToViewportPoint(pp.Position)
                    local b=camera:WorldToViewportPoint(pc.Position)
                    if a.Z>0 and b.Z>0 then
                        sl.From=Vector2.new(a.X,a.Y); sl.To=Vector2.new(b.X,b.Y)
                        sl.Color=s.SkeletonsColor; sl.Thickness=s.SkeletonThickness
                        sl.Visible=true
                    else sl.Visible=false end
                else sl.Visible=false end
            end
        else
            for _,ld in ipairs(esp.sk) do pcall(function() ld[1].Visible=false end) end
        end
    else
        if #esp.sk>0 then clearSk(esp) end
    end

    -- ── Tracer ───────────────────────────────────────────────
    if s.ShowTracer then
        local tY
        if     s.TracerOrigin=="Top"    then tY=0
        elseif s.TracerOrigin=="Middle" then tY=camera.ViewportSize.Y/2
        elseif s.TracerOrigin=="Mouse"  then
            local mp=UserInput:GetMouseLocation(); tY=mp.Y
        else tY=camera.ViewportSize.Y end
        local tX = s.TracerOrigin=="Mouse" and UserInput:GetMouseLocation().X
                   or camera.ViewportSize.X/2
        esp.tracer.From=Vector2.new(tX,tY); esp.tracer.To=Vector2.new(hrp2D.X,hrp2D.Y)
        esp.tracer.Color=acTr; esp.tracer.Thickness=s.TracerThickness
        esp.tracer.Visible=true
    else esp.tracer.Visible=false end

    -- ── Custom Image ─────────────────────────────────────────
    if s.ShowCustomImage and esp.img then
        local iW=bW*s.CustomImageSizeRatio.X; local iH=bH*s.CustomImageSizeRatio.Y
        esp.img.Size=Vector2.new(iW,iH)
        esp.img.Position=Vector2.new(bX+(bW-iW)/2, bY+(bH-iH)/2)
        esp.img.Visible=true
    elseif esp.img then esp.img.Visible=false end
end

local function updateEsp()
    local s=S
    if not s.Enabled then
        for _,esp in pairs(cache) do hideAll(esp) end
        updateChams(); updateHats(); updateRadar(); updateCursor()
        return
    end

    for player,esp in pairs(cache) do
        local isSelf=(player==lp)
        local isTm  =(player.Team~=nil) and (player.Team==lp.Team)

        if not _shouldDrawPlayer(player,isTm) then hideAll(esp) continue end

        drawEspForPlayer(player,esp,isSelf)
    end

    updateChams()
    updateHats()
    updateRadar()
    updateCursor()
end

-- ─────────────────────────────────────────────────────────────
--  Player hooks
-- ─────────────────────────────────────────────────────────────
local function hookPlayer(player)
    createEsp(player)
    player.CharacterAdded:Connect(function()
        local esp=cache[player]; if not esp then return end
        clearSk(esp); clearBl(esp)
        visVal[player]=nil; visTick[player]=nil
    end)
end

-- include localPlayer so self-ESP works
for _,player in ipairs(Players:GetPlayers()) do hookPlayer(player) end

Players.PlayerAdded:Connect(function(player) hookPlayer(player) end)
Players.PlayerRemoving:Connect(function(player) removeEsp(player) end)

RunService.RenderStepped:Connect(updateEsp)

initRadar()

return S
