local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Clean up existing instance if already running
if playerGui:FindFirstChild("LeftClickerGui") then
    playerGui.LeftClickerGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LeftClickerGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local leftButton = Instance.new("TextButton")
leftButton.Name = "LeftClickBtn"
leftButton.Size = UDim2.new(0, 65, 0, 65)
leftButton.Position = UDim2.new(0.5, -75, 0.4, 0)
leftButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
leftButton.BackgroundTransparency = 0.2
leftButton.Text = "L-CLICK"
leftButton.TextColor3 = Color3.fromRGB(255, 255, 255)
leftButton.Font = Enum.Font.GothamBold
leftButton.TextSize = 12
leftButton.Active = true
leftButton.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = leftButton

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(0, 170, 255)
stroke.Parent = leftButton

-- Draggable Logic (Ensures dragging doesn't accidentally trigger a click)
local dragging, dragStart, startPos = false, nil, nil
local hasMoved = false

leftButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        hasMoved = false
        dragStart = input.Position
        startPos = leftButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then 
                dragging = false 
            end
        end)
    end
end)

leftButton.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        if delta.Magnitude > 5 then
            hasMoved = true -- Mark that the user is dragging, not clicking
        end
        leftButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Click Action with Debounce (Prevents glitching / spam locking)
local isCooldown = false

leftButton.MouseButton1Click:Connect(function()
    -- If the user was dragging the button, don't trigger a click
    if hasMoved then return end
    
    -- Prevent spam-glitching
    if isCooldown then return end
    isCooldown = true

    -- Perform click action safely
    local character = player.Character
    if character then
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
        else
            pcall(function()
                local mouse = player:GetMouse()
                local vim = game:GetService("VirtualInputManager")
                vim:SendMouseButtonEvent(mouse.X, mouse.Y, 0, true, game, 0)
                task.wait(0.02)
                vim:SendMouseButtonEvent(mouse.X, mouse.Y, 0, false, game, 0)
            end)
        end
    end

    -- Small cool-down delay (0.15 seconds) before it can be pressed again
    task.wait(0.15)
    isCooldown = false
end)
