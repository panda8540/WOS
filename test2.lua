--------------------------------------------------------------------
-- FollowBehindScript  ★ LocalScript ★
--  - 画面左上にプレイヤー一覧を表示（自動更新）
--  - クリックしたプレイヤーの背後 3 stud に追従
--  - 同じボタン or ⏸ 停止ボタンで解除
--------------------------------------------------------------------

----------------------
-- 0. サービス取得
----------------------
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")

----------------------
-- 1. 変数
----------------------
local localPlr       = Players.LocalPlayer
local currentTarget  = nil           -- 今追っている相手 (Player)
local buttons        = {}            -- [Player] = TextButton
local BACK_OFFSET    = 3             -- 背後距離（+Z が背後）

--------------------------------------------------------------------
-- 2. UI 生成
--------------------------------------------------------------------
local gui   = Instance.new("ScreenGui")
gui.Name           = "FollowGui"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn   = false
gui.Parent         = localPlr:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size                   = UDim2.new(0, 220, 0, 340)
frame.Position               = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3       = Color3.fromRGB(35, 35, 35)
frame.BackgroundTransparency = 0.05
frame.BorderSizePixel        = 0
frame.Active, frame.Draggable = true, true
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 32)
title.Text = "🎯 追従ターゲット"
title.Font = Enum.Font.SourceSansBold
title.TextScaled = true
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Parent = frame

-- ⏸ 停止ボタン
local stopBtn = Instance.new("TextButton")
stopBtn.Size  = UDim2.new(1, -10, 0, 30)
stopBtn.Position = UDim2.new(0, 5, 0, 38)
stopBtn.Text = "⏸ 追従停止"
stopBtn.TextScaled = true
stopBtn.Font = Enum.Font.SourceSans
stopBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
stopBtn.TextColor3 = Color3.new(1,1,1)
stopBtn.Parent = frame

-- スクロールリスト
local list = Instance.new("ScrollingFrame")
list.Position = UDim2.new(0, 0, 0, 72)
list.Size     = UDim2.new(1, 0, 1, -72)
list.CanvasSize = UDim2.new(0,0,0,0)
list.ScrollBarThickness = 6
list.BackgroundTransparency = 1
list.Parent = frame

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.Name
layout.Padding   = UDim.new(0, 4)
layout.Parent    = list

--------------------------------------------------------------------
-- 3. ボタン生成・更新関数
--------------------------------------------------------------------
local function refreshHighlights()
	for plr, btn in pairs(buttons) do
		btn.BackgroundColor3 = (plr == currentTarget)
			and Color3.fromRGB(0,120,215)
			or  Color3.fromRGB(55,55,55)
	end
	stopBtn.BackgroundColor3 = currentTarget and Color3.fromRGB(150,0,0)
	                                            or  Color3.fromRGB(80,80,80)
end

local function createButton(plr)
	if plr == localPlr or buttons[plr] then return end

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 28)
	btn.Position = UDim2.new(0, 5, 0, 0)
	btn.Text = plr.DisplayName
	btn.TextScaled = true
	btn.Font = Enum.Font.SourceSans
	btn.BackgroundColor3 = Color3.fromRGB(55,55,55)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Parent = list
	buttons[plr] = btn

	btn.Activated:Connect(function()
		currentTarget = (currentTarget == plr) and nil or plr
		refreshHighlights()
	end)
end

local function removeButton(plr)
	local btn = buttons[plr]
	if btn then btn:Destroy() end
	buttons[plr] = nil
	if currentTarget == plr then currentTarget = nil end
	refreshHighlights()
end

local function rebuildList()
	-- 一度全削除
	for plr in pairs(buttons) do
		removeButton(plr)
	end
	-- 再作成
	for _, plr in ipairs(Players:GetPlayers()) do
		createButton(plr)
	end
	list.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y)
end

--------------------------------------------------------------------
-- 4. イベント接続
--------------------------------------------------------------------
stopBtn.Activated:Connect(function()
	currentTarget = nil
	refreshHighlights()
end)

Players.PlayerAdded:Connect(function(plr)
	createButton(plr)
	list.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y)
end)

Players.PlayerRemoving:Connect(removeButton)

rebuildList()  -- 初期化

--------------------------------------------------------------------
-- 5. 追従処理 (RenderStepped)
--------------------------------------------------------------------
RunService.RenderStepped:Connect(function()
	if not currentTarget then return end

	local myChar     = localPlr.Character or localPlr.CharacterAdded:Wait()
	local targetChar = currentTarget.Character
	if not targetChar then return end  -- 相手がリスポーン中はスキップ

	local myHRP      = myChar:FindFirstChild("HumanoidRootPart")
	local trgHRP     = targetChar:FindFirstChild("HumanoidRootPart")
	if not (myHRP and trgHRP) then return end

	-- 背後 3 stud（+Z が背後）
	myHRP.CFrame = trgHRP.CFrame * CFrame.new(0, 0, BACK_OFFSET)
end)
