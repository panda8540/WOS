--------------------------------------------------------------------
-- 集合させたい NPC の条件
--------------------------------------------------------------------
local NPC_TAG = "NPC"   -- CollectionService タグ / または Model 名で判定
local RADIUS  = 6       -- プレイヤーを中心に NPC を並べる円半径
local HEIGHT  = 0       -- Y オフセット（地形がフラットなら 0）

--------------------------------------------------------------------
-- Roblox サービス
--------------------------------------------------------------------
local Players           = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- RemoteEvent（ReplicatedStorage に事前配置）
local remote: RemoteEvent = ReplicatedStorage:WaitForChild("GatherNPCs")

--------------------------------------------------------------------
-- 指定プレイヤーの周囲に NPC を集合させる
--------------------------------------------------------------------
local function gatherAround(player: Player)
	-- 中心となる HumanoidRootPart
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	-- 対象 NPC を取得
	local npcs = CollectionService:GetTagged(NPC_TAG)
	if #npcs == 0 then return end

	-- 円周上に等間隔で配置する向きベクトルを用意
	for i, npc in ipairs(npcs) do
		-- RootPart を取得（HumanoidRootPart > Torso > PrimaryPart）
		local rootPart =
			npc:FindFirstChild("HumanoidRootPart")
			or npc:FindFirstChild("Torso")
			or npc.PrimaryPart
		local humanoid = npc:FindFirstChildOfClass("Humanoid")

		if rootPart and humanoid then
			local theta = (2 * math.pi / #npcs) * (i - 1)
			local offset = Vector3.new(
				math.cos(theta) * RADIUS,
				HEIGHT,
				math.sin(theta) * RADIUS
			)
			local goalPos = root.Position + offset

			-- Humanoid の MoveTo を使うと壁/段差を自動で避ける
			humanoid:MoveTo(goalPos)
		end
	end
end

--------------------------------------------------------------------
-- RemoteEvent を受け取り、呼び出しプレイヤーの周囲に集める
--------------------------------------------------------------------
remote.OnServerEvent:Connect(function(player)
	-- ここで権限チェックを入れても OK（admin だけ許可など）
	gatherAround(player)
end)

--------------------------------------------------------------------
-- （おまけ）テスト用：チャットコマンド "!gather" でも発動
--------------------------------------------------------------------
Players.PlayerChatted:Connect(function(player, message)
	if message:lower() == "!gather" then
		gatherAround(player)
	end
end)
