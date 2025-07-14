-- FollowUI.local.lua  (diagnostic edition)  -------------------------
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlr   = Players.LocalPlayer

----------------------------------------------------
-- UI セットアップ
----------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "FollowGui"
gui.ResetOnSpawn = false
gui.Parent = localPlr:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 320)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.25
frame.Active   = true   -- ← ドラッグ可能に
frame.Draggable = true
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.TextColor3 = Color3.new(1,1,1)
title.Text = "Follow Player"
title.Parent = frame

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

----------------------------------------------------
-- データ保持
----------------------------------------------------
local currentTarget   -- 追従相手（Player）
local buttonsByPlayer = {}  -- [Player] = TextButton

----------------------------------------------------
-- ボタン生成 & 更新
----------------------------------------------------
local function updateButtonHighlight()
    for plr, btn in pairs(buttonsByPlayer) do
        btn.BackgroundColor3 = (plr == currentTarget) and Color3.fromRGB(0,120,215)
                                                   or  Color3.fromRGB(50,50,50)
    end
end

local function addPlayerButton(plr)
    if plr == localPlr then return end   -- 自分は出さない

    local btn = Instance.new("TextButton")
    btn.Name  = plr.Name
    btn.Size  = UDim2.new(1, -6, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Text = (`{plr.DisplayName} ({plr.Name})`)
    btn.Parent = list
    buttonsByPlayer[plr] = btn

    btn.Activated:Connect(function()
        if currentTarget == plr then
            currentTarget = nil
        else
            currentTarget = plr
        end
        updateButtonHighlight()
    end)
end

local function removePlayerButton(plr)
    local btn = buttonsByPlayer[plr]
    if btn then btn:Destroy() end
    buttonsByPlayer[plr] = nil
    if currentTarget == plr then
        currentTarget = nil
        updateButtonHighlight()
    end
end

local function rebuildList(firstTime)
    print("Rebuilding list … Players:", #Players:GetPlayers())  -- デバッグ表示
    for plr, _ in pairs(buttonsByPlayer) do
        removePlayerButton(plr)
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        addPlayerButton(plr)
    end
    list.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)

    -- ソロなら「誰もいません」表示
    if next(buttonsByPlayer) == nil then
        local empty = Instance.new("TextLabel")
        empty.Size = UDim2.new(1, -6, 0, 24)
        empty.BackgroundTransparency = 1
        empty.TextColor3 = Color3.new(1,1,1)
        empty.Text = "ほかのプレイヤーはいません"
        empty.Parent = list
    end

    if firstTime then
        print("LocalScript started for", localPlr.Name)
    end
end

----------------------------------------------------
-- イベント接続
----------------------------------------------------
Players.PlayerAdded:Connect(function(plr)
    print("PlayerAdded:", plr.Name)
    addPlayerButton(plr)
    list.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
end)

Players.PlayerRemoving:Connect(function(plr)
    print("PlayerRemoving:", plr.Name)
    removePlayerButton(plr)
    list.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
end)

rebuildList(true)   -- 初期化

----------------------------------------------------
-- 追従処理
----------------------------------------------------
local BACK_OFFSET = -3
RunService.RenderStepped:Connect(function()
    if not currentTarget then return end
    local myChar     = localPlr.Character
    local targetChar = currentTarget.Character
    if not (myChar and targetChar) then return end

    local myRoot     = myChar:FindFirstChild("HumanoidRootPart")
    local trgRoot    = targetChar:FindFirstChild("HumanoidRootPart")
    if not (myRoot and trgRoot) then return end

    myRoot.CFrame = trgRoot.CFrame * CFrame.new(0, 0, BACK_OFFSET)
end)
-----------------------------------------------------------------------
