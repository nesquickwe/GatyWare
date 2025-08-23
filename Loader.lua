-- GatyWare Loader
local players = game:GetService("Players")
local run_service = game:GetService("RunService")
local user_input_service = game:GetService("UserInputService")
local tween_service = game:GetService("TweenService")
local core_gui = game:GetService("CoreGui")
local teleport_service = game:GetService("TeleportService")
local http_service = game:GetService("HttpService")

local loader = Instance.new("ScreenGui", core_gui)
loader.Name = "GatyWareLoader"
loader.ResetOnSpawn = false

-- Add GatyWare animated logo
local logoGui = Instance.new("ScreenGui", core_gui)
logoGui.Name = "GatyWareLogo"
logoGui.ResetOnSpawn = false

local logo = Instance.new("TextLabel", logoGui)
logo.Size = UDim2.new(0, 200, 0, 50)
logo.Position = UDim2.new(0.5, -100, 0.05, 0)
logo.BackgroundTransparency = 1
logo.Text = "GatyWare"
logo.TextScaled = true
logo.Font = Enum.Font.GothamBlack
logo.TextColor3 = Color3.fromRGB(160, 0, 200)

local gradient = Instance.new("UIGradient", logo)
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(100,0,150)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180,0,255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80,0,120))
}

local shine = Instance.new("UIGradient", logo)
shine.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.45, 1),
    NumberSequenceKeypoint.new(0.5, 0),
    NumberSequenceKeypoint.new(0.55, 1),
    NumberSequenceKeypoint.new(1, 1)
}
shine.Color = ColorSequence.new(Color3.new(1,1,1))

local stroke = Instance.new("UIStroke", logo)
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(200,0,255)

-- Animate gradient rotation
task.spawn(function()
    while true do
        for i = 0,360,1 do
            gradient.Rotation = i
            task.wait(0.02)
        end
    end
end)

-- Animate shine sweep
task.spawn(function()
    while true do
        shine.Offset = Vector2.new(-1,0)
        local tween = tween_service:Create(shine, TweenInfo.new(2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut), {Offset = Vector2.new(1,0)})
        tween:Play()
        tween.Completed:Wait()
        task.wait(0.5)
    end
end)

local games = {
    { name = "Phantom Forces", link = "https://raw.githubusercontent.com/dementiaenjoyer/homohack/refs/heads/main/pf_lite_rewrite_demo"},
    { name = "Bad Business", link = "https://raw.githubusercontent.com/dementiaenjoyer/homohack/main/bad_business.lua" },
    { name = "Fisch", link = "https://raw.githubusercontent.com/dementiaenjoyer/homohack/refs/heads/main/fisch.lua"},
    { name = "Frontlines"},
    { name = "Scorched Earth"},
    { name = "BedWars", link = "https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/NewMainScript.lua"},
    { name = "Arsenal"},
    { name = "Driving Empire", link = "https://raw.githubusercontent.com/nesquickwe/GatyWare/refs/heads/main/DrivingEmpireGatyWare.lua"},
    { name = "Universal Script", link = "https://raw.githubusercontent.com/nesquickwe/GatyWare/main/UniversalGatyWare.lua"},
}

local custom_callbacks = {
    ["Scorched Earth"] = function()
        if (game.GameId == 4785126950) then
            players.LocalPlayer:Kick("Run the scorched earth script inside of another game, like 'a literal baseplate'. GatyWare will teleport you")
            return
        end

        setfflag("DebugRunParallelLuaOnMainThread", "True")
        teleport_service:Teleport(13794093709, players.LocalPlayer)
        queue_on_teleport([[
            repeat task.wait() until game:IsLoaded()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/dementiaenjoyer/homohack/refs/heads/main/scorched_earth.lua"))()
        ]])
    end,

    ["Frontlines"] = function()
        local success = false
        if (run_on_actor) then
            success = true
            run_on_actor(getactors()[1], [=[
                loadstring(game:HttpGet("https://raw.githubusercontent.com/dementiaenjoyer/homohack/refs/heads/main/frontlines.lua"))()
            ]=])
        elseif (run_on_thread and getactorthreads) then
            success = true
            run_on_thread(getactorthreads()[1], [=[
                loadstring(game:HttpGet("https://raw.githubusercontent.com/dementiaenjoyer/homohack/refs/heads/main/frontlines.lua"))()
            ]=])
        end

        if (not success) then
            players.LocalPlayer:Kick("Your executor does not support 'run_on_actor' or 'run_on_thread'")
        end
    end,
    
    ["Arsenal"] = function()
        -- Fov
        local FOV_Circle = Drawing.new("Circle")
        -- Fov setins
        FOV_Circle.Color = Color3.fromRGB(255, 255, 255) -- White color
        FOV_Circle.Transparency = 1 -- Fully visible
        FOV_Circle.Radius = 45 -- Adjust size for FOV (45 degrees)
        FOV_Circle.NumSides = 100 -- Smooth circle edges
        FOV_Circle.Thickness = 1.5 -- Circle border thickness
        FOV_Circle.Filled = false -- Ensure it's a circle outline
        FOV_Circle.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2,
                                          workspace.CurrentCamera.ViewportSize.Y / 2)


        game:GetService("RunService").RenderStepped:Connect(function()
            local camera = workspace.CurrentCamera
            FOV_Circle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
            FOV_Circle.Visible = true -- Always ensure it's visible
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
        coroutine.resume(coroutine.create(function()
        while  wait(1) do
        coroutine.resume(coroutine.create(function()
        for _,v in pairs(game[players]:GetPlayers()) do
        if v.Name ~= plr.Name and v.Character then
        v.Character.RightUpperLeg.CanCollide = false
        v.Character.RightUpperLeg.Transparency = 10
        v.Character.RightUpperLeg.Size = Vector3.new(13,13,13)

        v.Character.LeftUpperLeg.CanCollide = false
        v.Character.LeftUpperLeg.Transparency = 10
        v.Character.LeftUpperLeg.Size = Vector3.new(13,13,13)

        v.Character.HeadHB.CanCollide = false
        v.Character.HeadHB.Transparency = 10
        v.Character.HeadHB.Size = Vector3.new(13,13,13)

        v.Character.HumanoidRootPart.CanCollide = false
        v.Character.HumanoidRootPart.Transparency = 10
        v.Character.HumanoidRootPart.Size = Vector3.new(13,13,13)

        end
        end
        end))
        end
        end))

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

        --// ========================================
        --// GatyWare Animated UI Logo
        --// ========================================
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

        -- Animate gradient rotation
        task.spawn(function()
            while true do
                for i = 0,360,1 do
                    gradient.Rotation = i
                    task.wait(0.02)
                end
            end
        end)

        -- Animate shine sweep
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

            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and
                    player.Character and
                    player.Character:FindFirstChild("Head") and
                    player.Character:FindFirstChild("Humanoid") and
                    player.Character.Humanoid.Health > 0 and
                    IsEnemy(player) then

                    local distance = (player.Character.Head.Position - LocalPlayer.Character.Head.Position).Magnitude
                    if distance <= MAX_DISTANCE then
                        if isWithinFOV(player.Character.Head.Position) then
                            local screenPoint = Camera:WorldToScreenPoint(player.Character.Head.Position)
                            if screenPoint.Z > 0 and distance < shortestDistance then
                                closest = player
                                shortestDistance = distance
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
    end
}

local holder_stroke = Instance.new("UIStroke")
holder_stroke.Color = Color3.fromRGB(24, 24, 24)
holder_stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- UI Creation
do
    local dragging = false
    local mouse_start = nil
    local frame_start = nil
    
    local main = Instance.new("Frame", loader)
    main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    main.BorderColor3 = Color3.fromRGB(0, 0, 0)
    main.BorderSizePixel = 0
    main.Position = UDim2.new(0.427, 0, 0.393, 0)
    main.Size = UDim2.new(0.145, 0, 0.267, 0)
    main.Name = "MainFrame"
    
    local title = Instance.new("TextLabel", main)
    title.BackgroundColor3 = Color3.fromRGB(13, 13, 13)
    title.BorderColor3 = Color3.fromRGB(0, 0, 0)
    title.BorderSizePixel = 0
    title.Position = UDim2.new(0.036, 0, 0.02, 0)
    title.Size = UDim2.new(0.927, 0, 0.112, 0)
    title.Font = Enum.Font.RobotoMono
    title.Text = "GatyWare"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextStrokeTransparency = 0.000
    title.TextWrapped = true
    title.TextSize = 18
    
    title.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = true
            mouse_start = user_input_service:GetMouseLocation()
            frame_start = main.Position
        end
    end)

    user_input_service.InputChanged:Connect(function(input)
        if (dragging and input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = user_input_service:GetMouseLocation() - mouse_start
            tween_service:Create(main, TweenInfo.new(0.1), {Position = UDim2.new(frame_start.X.Scale, frame_start.X.Offset + delta.X, frame_start.Y.Scale, frame_start.Y.Offset + delta.Y)}):Play()
        end
    end)
    
    user_input_service.InputEnded:Connect(function(input)
        if (dragging) then
            dragging = false
        end
    end)
    
    local ui_stroke = Instance.new("UIStroke", main)
    ui_stroke.Thickness = 2
    ui_stroke.Color = Color3.fromRGB(255, 255, 255)
    
    -- Updated to purple and white gradient like GatyWare logo
    local ui_gradient = Instance.new("UIGradient", ui_stroke)
    ui_gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 0, 150)),  -- Dark purple
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 0, 255)), -- Bright purple
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 255, 255)), -- White
        ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 0, 120))  -- Deep purple
    })

    local ui_corner = Instance.new("UICorner", title)
    ui_corner.CornerRadius = UDim.new(0, 2)

    local holder = Instance.new("Frame", main)
    holder.BackgroundColor3 = Color3.fromRGB(13, 13, 13)
    holder.BorderColor3 = Color3.fromRGB(0, 0, 0)
    holder.BorderSizePixel = 0
    holder.Position = UDim2.new(0.036, 0, 0.167, 0)
    holder.Size = UDim2.new(0.927, 0, 0.782, 0)
    holder.Name = "GameHolder"
    
    local stroke = holder_stroke:Clone()
    stroke.Parent = holder

    local ui_corner_2 = Instance.new("UICorner", holder)
    ui_corner_2.CornerRadius = UDim.new(0, 4)

    local scrolling_frame = Instance.new("ScrollingFrame", holder)
    scrolling_frame.Active = true
    scrolling_frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    scrolling_frame.BackgroundTransparency = 1.000
    scrolling_frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    scrolling_frame.BorderSizePixel = 0
    scrolling_frame.Position = UDim2.new(0, 0, 0, 0)
    scrolling_frame.Size = UDim2.new(1, 0, 1, 0)
    scrolling_frame.CanvasSize = UDim2.new(0, 0, 0, #games * 35)
    scrolling_frame.ScrollBarThickness = 4

    local ui_padding = Instance.new("UIPadding", scrolling_frame)
    ui_padding.PaddingTop = UDim.new(0, 10)

    local ui_list_layout = Instance.new("UIListLayout", scrolling_frame)
    ui_list_layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ui_list_layout.SortOrder = Enum.SortOrder.LayoutOrder
    ui_list_layout.Padding = UDim.new(0, 10)
    
    local heartbeat = nil

    for _, supported_game in ipairs(games) do
        local name = supported_game.name
        local text_button = Instance.new("TextButton", scrolling_frame)
        text_button.MouseButton1Click:Connect(function()
            -- Make both logo and menu disappear when a script is loaded
            logoGui.Enabled = false
            loader.Enabled = false
            
            local custom_callback = custom_callbacks[name]
            
            if (not custom_callback) then
                if supported_game.link then
                    loadstring(game:HttpGet(supported_game.link))()
                else
                    warn("No link provided for " .. name)
                end
            else
                custom_callback()
            end

            if heartbeat then
                heartbeat:Disconnect()
            end
        end)
        
        text_button.Text = `Load {supported_game.name}`
        text_button.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
        text_button.BorderColor3 = Color3.fromRGB(0, 0, 0)
        text_button.BorderSizePixel = 0
        text_button.Size = UDim2.new(0.9, 0, 0, 25)
        text_button.Font = Enum.Font.RobotoMono
        text_button.TextColor3 = Color3.fromRGB(255, 255, 255)
        text_button.TextSize = 12
        text_button.TextWrapped = true
        text_button.LayoutOrder = #scrolling_frame:GetChildren()

        local stroke = holder_stroke:Clone()
        stroke.Parent = text_button

        local ui_corner_3 = Instance.new("UICorner", text_button)
        ui_corner_3.CornerRadius = UDim.new(0, 4)
        
        -- Add purple highlight effect on hover
        text_button.MouseEnter:Connect(function()
            tween_service:Create(text_button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 0, 60)}):Play()
        end)
        
        text_button.MouseLeave:Connect(function()
            tween_service:Create(text_button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(14, 14, 14)}):Play()
        end)
    end
    
    heartbeat = run_service.Heartbeat:Connect(function()
        ui_gradient.Rotation = (ui_gradient.Rotation + 4) % 360
    end)
end

print("GatyWare Loader initialized!")
