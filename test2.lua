--------------------------------------------------------------------
-- FollowBehindScript  ▶︎ LocalScript ◀︎
--   ・UI で相手を選択 → 背後 3 stud に常時追従
--   ・R6 / R15 どちらでも OK（Torso フォールバック付き）
--   ・同じボタンを再クリック or ⏸ 停止ボタンで解除
--------------------------------------------------------------------
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlr      = Players.LocalPlayer
local currentTarget = nil                    -- 今追いかけている相手
local buttons       = {}                     -- [Player] = TextButton
local BACK_OFFSET   = 3                      -- 背後 3 stud（+Z が背後）

--------------------------------------------------------------------
-- ① UI 生成
--------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name, gui.IgnoreGuiInset, gui.ResetOnSpawn =
    "FollowGui", true, false
gui.Parent = localPlr:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size  = UDim2.new(0, 220, 0, 340)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(35,35,35)
frame.BackgroundTransparency = 0.05
frame.BorderSizePixel = 0
frame.Active, frame.Draggable = true, true
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 32)
title.Text = "🎯 追従ターゲット"
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Parent = frame

local stopBtn = Instance.new("TextButton")
stopBtn.Size  = UDim2.new(1, -10, 0, 30)
stopBtn.Position = UDim2.new(0, 5, 0, 38)
stopBtn.Text = "⏸ 追従停止"
stopBtn.TextScaled = true
stopBtn.Font = Enum.Font.SourceSans
stopBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
stopBtn.TextColor3 = Color3.new(1,1,1)
stopBtn.Parent = frame

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
-- ② ボタン生成／削除／ハイライト
--------------------------------------------------------------------
local function highlight()
	for plr, btn in pairs(buttons) do
		btn.BackgroundColor3 = (plr == currentTarget)
			and Color3.fromRGB(0,120,215)
			or  Color3.fromRGB(55,55,55)
	end
	stopBtn.BackgroundColor3 = currentTarget and Color3.fromRGB(150,0,0)
	                                            or  Color3.fromRGB(80,80,80)
end

local function addButton(plr)
	if plr == localPlr or buttons[plr] then return end
	local btn = Instance.new("TextButton")
	btn.Size  = UDim2.new(1, -10, 0, 28)
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
		highlight()
	end)
end

local function removeButton(plr)
	local b = buttons[plr]
	if b then b:Destroy() end
	buttons[plr] = nil
	if currentTarget == plr then currentTarget = nil end
	highlight()
end

local function rebuild()
	for plr in pairs(buttons) do
		removeButton(plr)
	end
	for _, plr in ipairs(Players:GetPlayers()) do
		addButton(plr)
	end
	list.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y)
end

Players.PlayerAdded:Connect(function(plr)
	addButton(plr)
	list.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y)
end)
Players.PlayerRemoving:Connect(removeButton)
stopBtn.Activated:Connect(function()
	currentTarget = nil
	highlight()
end)

rebuild()

--------------------------------------------------------------------
-- ③ 追従ロジック
--------------------------------------------------------------------
-- R6 互換: HumanoidRootPart がなければ Torso を返す
local function getRoot(char)
	return char:FindFirstChild("HumanoidRootPart")
	    or char:FindFirstChild("Torso")
end

RunService.RenderStepped:Connect(function()
	if not currentTarget then return end

	local myChar = localPlr.Character or localPlr.CharacterAdded:Wait()
	local targetChar = currentTarget.Character
	if not targetChar then return end  -- リスポーン待ち

	local myRoot  = getRoot(myChar)
	local trgRoot = getRoot(targetChar)
	if not (myRoot and trgRoot) then return end

	-- 背後 3 stud（+Z が背後）
	myRoot.CFrame = trgRoot.CFrame * CFrame.new(0, 0, BACK_OFFSET)
end)
