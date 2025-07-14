-- OrionLib 読み込み
local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))();
local Window = OrionLib:MakeWindow({Name = "Infinite Jump", HidePremium = false, SaveConfig = false})

-- 状態保持変数
getgenv().infiniteJumpEnabled = false

-- 無限ジャンプ処理
local UserInputService = game:GetService("UserInputService")
local JumpConnection

local function enableInfiniteJump()
    JumpConnection = UserInputService.JumpRequest:Connect(function()
        if getgenv().infiniteJumpEnabled then
            local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

-- 初期化
enableInfiniteJump()

-- GUIタブ作成
local tab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998", PremiumOnly = false})

-- トグルスイッチ
tab:AddToggle({
    Name = "無限ジャンプを有効にする",
    Default = false,
    Callback = function(state)
        getgenv().infiniteJumpEnabled = state
    end
})

OrionLib:Init()
-- FollowUI.local.lua  🔧 LocalScript
local Players   = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
--------------------------------------------------------------------
-- 1️⃣ UI 生成
--------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "FollowGui"
gui.ResetOnSpawn = false
gui.Parent = localPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 320)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.3
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.TextColor3 = Color3.new(1,1,1)
title.Text      = "Follow Player"
title.Parent    = frame

local list = Instance.new("ScrollingFrame")
list.Position = UDim2.new(0, 0, 0, 30)
list.Size     = UDim2.new(1, 0, 1, -30)
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.ScrollBarThickness = 6
list.BackgroundTransparency = 1
list.Parent = frame

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.Name
layout.Padding   = UDim.new(0, 4)
layout.Parent    = list

--------------------------------------------------------------------
-- 2️⃣ プレイヤー一覧を作る / 更新
--------------------------------------------------------------------
local targetPlayer  -- 現在追従している相手

local function makeButton(plr)
    local button = Instance.new("TextButton")
    button.Name  = plr.Name
    button.Size  = UDim2.new(1, -6, 0, 28)
    button.BackgroundColor3 = Color3.fromRGB(50,50,50)
    button.TextColor3 = Color3.new(1,1,1)
    button.Text = plr.DisplayName .. " (" .. plr.Name .. ")"
    button.Parent = list

    button.Activated:Connect(function()
        -- 同じ人をもう一度押したら解除
        if targetPlayer == plr then
            targetPlayer = nil
            button.BackgroundColor3 = Color3.fromRGB(50,50,50)
            return
        end

        -- ハイライトを付け替え
        for _, child in ipairs(list:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = Color3.fromRGB(50,50,50)
            end
        end
        button.BackgroundColor3 = Color3.fromRGB(0,120,215)
        targetPlayer = plr
    end)
end

local function refreshList()
    list:ClearAllChildren()
    layout.Parent = list    -- ClearAllChildren で layout が消えるので付け直す
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= localPlayer then
            makeButton(plr)
        end
    end
    list.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
end

refreshList()
Players.PlayerAdded:Connect(refreshList)
Players.PlayerRemoving:Connect(refreshList)

--------------------------------------------------------------------
-- 3️⃣ 追従ロジック（RenderStepped で毎フレーム）
--------------------------------------------------------------------
local OFFSET_BACK = -3   -- 後ろへ 3 stud（CFrame の Z は後ろ方向が正）
local OFFSET_UP   =  0   -- 必要なら 1‑2 で少し浮かせる

RunService.RenderStepped:Connect(function()
    if not targetPlayer then return end
    local myChar      = localPlayer.Character
    local targetChar  = targetPlayer.Character
    if not (myChar and targetChar) then return end

    local myRoot      = myChar:FindFirstChild("HumanoidRootPart")
    local targetRoot  = targetChar:FindFirstChild("HumanoidRootPart")
    if not (myRoot and targetRoot) then return end

    -- 相手の後ろへワープ
    local goalCFrame = targetRoot.CFrame * CFrame.new(0, OFFSET_UP, OFFSET_BACK)
    myRoot.CFrame    = CFrame.new(goalCFrame.Position, targetRoot.Position)
end)

