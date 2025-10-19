-- esp.lua with Image Billboard
--// Variables
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local cache = {}

-- Path to your saved image
local imagedownload = loadstring(game:HttpGet("https://raw.githubusercontent.com/nesquickwe/GatyWare/refs/heads/main/Imgur.png",true))();

local imagePath = "GatyWare/Esp/asstes/imgur.png"

-- Get usable asset path depending on executor
local IMAGE_URL
if getsynasset then
    IMAGE_URL = getsynasset(imagePath)
elseif getcustomasset then
    IMAGE_URL = getcustomasset(imagePath)
else
    warn("❌ Your executor does not support getsynasset or getcustomasset.")
    return
end

print("✓ Image asset loaded:", IMAGE_URL)

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
    BoxOutlineColor = Color3.new(0, 0, 0),
    BoxColor = Color3.new(1, 1, 1),
    NameColor = Color3.new(1, 1, 1),
    HealthOutlineColor = Color3.new(0, 0, 0),
    HealthHighColor = Color3.new(0, 1, 0),
    HealthLowColor = Color3.new(1, 0, 0),
    CharSize = Vector2.new(4, 6),
    Teamcheck = false,
    WallCheck = false,
    Enabled = true,
    ShowBox = false,
    BoxType = "2D",
    ShowName = false,
    ShowHealth = false,
    ShowDistance = false,
    ShowSkeletons = false,
    ShowTracer = true,
    TracerColor = Color3.new(1, 1, 1), 
    TracerThickness = 2,
    SkeletonsColor = Color3.new(1, 1, 1),
    TracerPosition = "Bottom",
    ShowImageBillboard = true,
}

local function create(class, properties)
    local drawing = Drawing.new(class)
    for property, value in pairs(properties) do
        drawing[property] = value
    end
    return drawing
end

local function createEsp(player)
    local esp = {
        tracer = create("Line", {
            Thickness = ESP_SETTINGS.TracerThickness,
            Color = ESP_SETTINGS.TracerColor,
            Transparency = 0.5
        }),
        boxOutline = create("Square", {
            Color = ESP_SETTINGS.BoxOutlineColor,
            Thickness = 3,
            Filled = false
        }),
        box = create("Square", {
            Color = ESP_SETTINGS.BoxColor,
            Thickness = 1,
            Filled = false
        }),
        name = create("Text", {
            Color = ESP_SETTINGS.NameColor,
            Outline = true,
            Center = true,
            Size = 13
        }),
        healthOutline = create("Line", {
            Thickness = 3,
            Color = ESP_SETTINGS.HealthOutlineColor
        }),
        health = create("Line", {
            Thickness = 1
        }),
        distance = create("Text", {
            Color = Color3.new(1, 1, 1),
            Size = 12,
            Outline = true,
            Center = true
        }),
        boxLines = {},
    }

    cache[player] = esp
    cache[player]["skeletonlines"] = {}

    -- Create image billboard
    if ESP_SETTINGS.ShowImageBillboard then
        local character = player.Character
        if character then
            local head = character:FindFirstChild("Head")
            if head then
                local oldBillboard = head:FindFirstChild("GatyWareImageBillboard")
                if oldBillboard then oldBillboard:Destroy() end

                local billboard = Instance.new("BillboardGui")
                billboard.Name = "GatyWareImageBillboard"
                billboard.Adornee = head
                billboard.Size = UDim2.new(0, 80, 0, 80)
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                billboard.AlwaysOnTop = true
                billboard.MaxDistance = 10000

                local img = Instance.new("ImageLabel")
                img.Size = UDim2.new(1, 0, 1, 0)
                img.BackgroundTransparency = 0
                img.BackgroundColor3 = Color3.new(0, 0, 0)
                img.Image = IMAGE_URL
                img.Parent = billboard

                billboard.Parent = head

                -- Create tracer line
                local line = Instance.new("Part")
                line.Name = "GatyWareTracer"
                line.Shape = Enum.PartType.Cylinder
                line.Material = Enum.Material.Neon
                line.CanCollide = false
                line.TopSurface = Enum.SurfaceType.Smooth
                line.BottomSurface = Enum.SurfaceType.Smooth
                line.Color = Color3.fromRGB(255, 0, 255)
                line.Transparency = 0.3
                line.Parent = workspace

                local connection
                connection = RunService.RenderStepped:Connect(function()
                    if not head or not head.Parent or not line or not line.Parent then
                        connection:Disconnect()
                        if line then line:Destroy() end
                        return
                    end

                    local headPos = head.Position
                    local cameraPos = camera.CFrame.Position
                    local distance = (headPos - cameraPos).Magnitude

                    line.Size = Vector3.new(0.2, distance, 0.2)
                    line.CFrame = CFrame.new((headPos + cameraPos) / 2, headPos)
                end)
            end
        end
    end
end

local function isPlayerBehindWall(player)
    local character = player.Character
    if not character then
        return false
    end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return false
    end

    local ray = Ray.new(camera.CFrame.Position, (rootPart.Position - camera.CFrame.Position).Unit * (rootPart.Position - camera.CFrame.Position).Magnitude)
    local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, {localPlayer.Character, character})
    
    return hit and hit:IsA("Part")
end

local function removeEsp(player)
    local esp = cache[player]
    if not esp then return end

    for _, drawing in pairs(esp) do
        if typeof(drawing) == "userdata" and drawing.Remove then
            drawing:Remove()
        end
    end

    cache[player] = nil
end

local function updateEsp()
    for player, esp in pairs(cache) do
        local character, team = player.Character, player.Team
        if character and (not ESP_SETTINGS.Teamcheck or (team and team ~= localPlayer.Team)) then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            local head = character:FindFirstChild("Head")
            local humanoid = character:FindFirstChild("Humanoid")
            local isBehindWall = ESP_SETTINGS.WallCheck and isPlayerBehindWall(player)
            local shouldShow = not isBehindWall and ESP_SETTINGS.Enabled
            
            if rootPart and head and humanoid and shouldShow then
                local position, onScreen = camera:WorldToViewportPoint(rootPart.Position)
                if onScreen then
                    local hrp2D = camera:WorldToViewportPoint(rootPart.Position)
                    local charSize = (camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0)).Y - camera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, 2.6, 0)).Y) / 2
                    local boxSize = Vector2.new(math.floor(charSize * 1.8), math.floor(charSize * 1.9))
                    local boxPosition = Vector2.new(math.floor(hrp2D.X - charSize * 1.8 / 2), math.floor(hrp2D.Y - charSize * 1.6 / 2))

                    if ESP_SETTINGS.ShowTracer and ESP_SETTINGS.Enabled then
                        local tracerY
                        if ESP_SETTINGS.TracerPosition == "Top" then
                            tracerY = 0
                        elseif ESP_SETTINGS.TracerPosition == "Middle" then
                            tracerY = camera.ViewportSize.Y / 2
                        else
                            tracerY = camera.ViewportSize.Y
                        end
                        if ESP_SETTINGS.Teamcheck and player.TeamColor == localPlayer.TeamColor then
                            esp.tracer.Visible = false
                        else
                            esp.tracer.Visible = true
                            esp.tracer.From = Vector2.new(camera.ViewportSize.X / 2, tracerY)
                            esp.tracer.To = Vector2.new(hrp2D.X, hrp2D.Y)            
                        end
                    else
                        esp.tracer.Visible = false
                    end
                else
                    for _, drawing in pairs(esp) do
                        if typeof(drawing) == "userdata" and drawing.Visible ~= nil then
                            drawing.Visible = false
                        end
                    end
                end
            else
                for _, drawing in pairs(esp) do
                    if typeof(drawing) == "userdata" and drawing.Visible ~= nil then
                        drawing.Visible = false
                    end
                end
            end
        else
            for _, drawing in pairs(esp) do
                if typeof(drawing) == "userdata" and drawing.Visible ~= nil then
                    drawing.Visible = false
                end
            end
        end
    end
end

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
return ESP_SETTINGS
