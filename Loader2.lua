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
    { name = "Arsenal", link = "https://raw.githubusercontent.com/nesquickwe/GatyWare/refs/heads/main/Arsenal.lua"},
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
