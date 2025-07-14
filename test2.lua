-- 📍 LocalScript in StarterPlayer ▸ StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlr = Players.LocalPlayer
local currentTarget = nil

-- ✅ UIの作成
local gui = Instance.new("ScreenGui")
gui.Name = "FollowGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = localPlr:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 300)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "🎯 プレイヤー選択"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextScaled = true
title.Parent = frame

local playerList = Instance.new("UIListLayout")
playerList.Parent = frame
playerList.Padding = UDim.new(0, 5)
playerList.SortOrder = Enum.SortOrder.Name

-- ✅ プレイヤーボタンを作成する関数
local function createPlayerButton(plr)
	if plr == localPlr then return end

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 30)
	btn.Text = plr.DisplayName
	btn.TextScaled = true
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.SourceSans
	btn.Parent = frame

	btn.MouseButton1Click:Connect(function()
		currentTarget = plr
	end)
end

-- ✅ プレイヤー一覧を更新
local function rebuildList()
	for _, child in pairs(frame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	for _, plr in pairs(Players:GetPlayers()) do
		createPlayerButton(plr)
	end
end

-- 🔁 プレイヤー参加／退出時に更新
Players.PlayerAdded:Connect(rebuildList)
Players.PlayerRemoving:Connect(rebuildList)
rebuildList()

-- ✅ 背後に追従
local BACK_OFFSET = -3 -- 後方3スタッド（Z軸マイナス方向）

RunService.RenderStepped:Connect(function()
	if not currentTarget then return end

	local myChar = localPlr.Character
	local targetChar = currentTarget.Character
	if not (myChar and targetChar) then return end

	local myHRP = myChar:FindFirstChild("HumanoidRootPart")
	local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
	if not (myHRP and targetHRP) then return end

	-- ターゲットの背後に自分を移動
	myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, BACK_OFFSET)
end)
