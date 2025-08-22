--// LocalScript for "GatyWare" (smaller, darker purple, animated with shine)
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- Remove old gui if it exists
if CoreGui:FindFirstChild("GatyWareUI") then
    CoreGui.GatyWareUI:Destroy()
end

-- Main ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GatyWareUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = CoreGui

-- Container Frame (top center, lowered slightly)
local container = Instance.new("Frame")
container.Size = UDim2.new(1, 0, 0, 80) -- smaller height
container.Position = UDim2.new(0, 0, 0, 100)
container.BackgroundTransparency = 1
container.Parent = screenGui

-- TextLabel
local text = Instance.new("TextLabel")
text.Size = UDim2.new(0, 500, 1, 0) -- smaller width
text.Position = UDim2.new(0.5, -250, 0, 0) -- recentered
text.BackgroundTransparency = 1
text.Text = "GatyWare"
text.TextScaled = true
text.Font = Enum.Font.GothamBlack
text.TextTransparency = 0
text.TextColor3 = Color3.fromRGB(160, 0, 200) -- darker neon purple base
text.Parent = container

-- Animated purple gradient
local gradient = Instance.new("UIGradient")
gradient.Rotation = 0
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 0, 150)), -- dark violet
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 0, 255)), -- neon purple
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 0, 120)) -- deep purple
}
gradient.Parent = text

-- White shine reflection gradient
local shine = Instance.new("UIGradient")
shine.Rotation = 0
shine.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.45, 1),
    NumberSequenceKeypoint.new(0.5, 0),   -- shine visible
    NumberSequenceKeypoint.new(0.55, 1),
    NumberSequenceKeypoint.new(1, 1)
}
shine.Color = ColorSequence.new(Color3.new(1, 1, 1))
shine.Parent = text

-- Subtle glow with stroke
local stroke = Instance.new("UIStroke")
stroke.Thickness = 2 -- thinner since text is smaller
stroke.Color = Color3.fromRGB(200, 0, 255) -- glowing purple edge
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Outside
stroke.Parent = text

-- Animate purple gradient rotation
task.spawn(function()
    while true do
        for i = 0, 360, 1 do
            gradient.Rotation = i
            task.wait(0.02)
        end
    end
end)

-- Animate white shine sweep
task.spawn(function()
    while true do
        shine.Offset = Vector2.new(-1, 0)
        local tween = TweenService:Create(
            shine,
            TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            {Offset = Vector2.new(1, 0)}
        )
        tween:Play()
        tween.Completed:Wait()
        task.wait(0.5) -- shorter pause for frequent shine
    end
end)

-- Prevent GUI removal
screenGui.AncestryChanged:Connect(function(_, parent)
    if not parent then
        screenGui.Parent = CoreGui
    end
end)



--GatyWare
        LocalPlayer = game:GetService("Players").LocalPlayer

        Camera = workspace.CurrentCamera

        VirtualUser = game:GetService("VirtualUser")

        MarketplaceService = game:GetService("MarketplaceService")

        

        --Get Current Vehicle

        function GetCurrentVehicle()

            return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.SeatPart and LocalPlayer.Character.Humanoid.SeatPart.Parent

        end

        

        --Regular TP

        function TP(cframe)

            GetCurrentVehicle():SetPrimaryPartCFrame(cframe)

        end

        

        --Velocity TP

        function VelocityTP(cframe)

            TeleportSpeed = math.random(600, 600)

            Car = GetCurrentVehicle()

            local BodyGyro = Instance.new("BodyGyro", Car.PrimaryPart)

            BodyGyro.P = 5000

            BodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)

            BodyGyro.CFrame = Car.PrimaryPart.CFrame

            local BodyVelocity = Instance.new("BodyVelocity", Car.PrimaryPart)

            BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)

            BodyVelocity.Velocity = CFrame.new(Car.PrimaryPart.Position, cframe.p).LookVector * TeleportSpeed

            wait((Car.PrimaryPart.Position - cframe.p).Magnitude / TeleportSpeed)

            BodyVelocity.Velocity = Vector3.new()

            wait(0.1)

            BodyVelocity:Destroy()

            BodyGyro:Destroy()

        end

        

        --Auto Farm

        StartPosition = CFrame.new(Vector3.new(4940.19775, 66.0195084, -1933.99927, 0.343969434, -0.00796990748, -0.938947022, 0.00281227613, 0.999968231, -0.00745762791, 0.938976645, -7.53822824e-05, 0.343980938), Vector3.new())

        EndPosition = CFrame.new(Vector3.new(1827.3407, 66.0150146, -658.946655, -0.366112858, 0.00818905979, 0.930534422, 0.00240773871, 0.999966264, -0.00785277691, -0.930567324, -0.000634518801, -0.366120219), Vector3.new())

        AutoFarmFunc = coroutine.create(function()

            while wait() do

                if not AutoFarm then

                    AutoFarmRunning = false

                    coroutine.yield()

                end

                AutoFarmRunning = true

                pcall(function()

                    if not GetCurrentVehicle() and tick() - (LastNotif or 0) > 5 then

                        LastNotif = tick()

                    else

                        TP(StartPosition + (TouchTheRoad and Vector3.new(0,0,0) or Vector3.new(0, 0, 0)))

                        VelocityTP(EndPosition + (TouchTheRoad and Vector3.new() or Vector3.new(0, 0, 0)))

                        TP(EndPosition + (TouchTheRoad and Vector3.new() or Vector3.new(0, 0, 0)))

                        VelocityTP(StartPosition + (TouchTheRoad and Vector3.new() or Vector3.new(0, 0, 0)))

                    end

                end)

            end

        end)

        

        --Anti AFK

        AntiAFK = true

        LocalPlayer.Idled:Connect(function()

            VirtualUser:CaptureController()

            VirtualUser:ClickButton2(Vector2.new(), Camera.CFrame)

        end)

        

        local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Simak90/pfsetcetc/main/fluxed.lua"))() -- UI Library

                local win = lib:Window("GatyWare", "by Gaty", Color3.fromRGB(111, 0, 0), _G.closeBind) -- done mess with

            

                ---------Spins--------------------------------

                local Visual = win:Tab("Farm Section", "http://www.roblox.com/asset/?id=6023426915")

                Visual:Label("Farms")

                Visual:Line()

                

                Visual:Toggle("Auto Farm", "Activates farm. Get in car to start",false, function(value)

                    AutoFarm = value

                        if value and not AutoFarmRunning then

                            coroutine.resume(AutoFarmFunc)

                        end

                end)

                Visual:Toggle("TouchTheRoad", "doesnt work for some cars",false, function(value)

                    TouchTheRoad = value

                end)

                Visual:Toggle("AntiAFK", "simulates keypressing",false, function(value)

                    AntiAFK = value

                end)


                                        

                                    
