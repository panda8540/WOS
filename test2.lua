-- FollowBehindScript  (LocalScript)

-- サービス
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")

-- 変数
local localPlr      = Players.LocalPlayer
local currentTarget = nil      -- 追従しているプレイヤー
local buttons       = {}       -- [Player] = TextButton

---------------------------------------------------------------------
-- 🖼️  UI 生成
---------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name           = "FollowGui"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn   = false
gui.Parent         = localPlr:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size               = UDim2.new(0, 220, 0, 330)
frame.Position           = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3   = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel    = 0
frame.Active, frame.Draggable = true, true
frame.Parent = gui

-- タイトル
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "🎯 プレイヤー選択"
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)
title.Parent = frame

-- 「追従停止」ボタン
local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(1, -10, 0, 28)
stopBtn.Position = UDim2.new(0, 5, 0, 35)
stopBtn.Text = "⏸ 追従停止"
stopBtn.TextScaled = true
stopBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
stopBtn.TextColor3 = Color3.new(1,1,1)
stopBtn.Parent = frame

-- リスト用スクロール
local list = Instance.new("ScrollingFrame")
list.Position = UDim2.new(0, 0, 0, 70)
list.Size     = UDim2.new(1, 0, 1, -70)
list.CanvasSize = UDim2.new(0,0,0,0)
list.ScrollBarThickness = 6
list.BackgroundTransparency = 1
list.Parent = frame

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.Name
layout.Padding   = UDim.new(0, 4)
layout.Parent    = list

---------------------------------------------------------------------
-- 🛠️  プレイヤー一覧の生成／更新
---------------------------------------------------------------------
local function highlightButtons()
	for plr, btn in pairs(buttons) do
		local isTarget = (plr == currentTarget)
		btn.BackgroundColor3 = isTarget and Color3.fromRGB(0,120,215)
		                                   or  Color3.fromRGB(50,50,50)
	end
	stopBtn.BackgroundColor3 = currentTarget and Color3.fromRGB(150,0,0)
	                                          or  Color3.fromRGB(80,80,80)
end

local function addPlayerButton(plr)
	if plr == localPlr then return end
	if buttons[plr] then return end

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 28)

