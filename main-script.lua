-- スクリプトが実行されるタイミングを確認
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local UserInputService = game:GetService("UserInputService")

-- ジャンプ制御をカスタマイズする
local jumpKey = Enum.KeyCode.Space  -- スペースキーでジャンプする設定

local function enableDoubleJump()
    -- ジャンプが発生した時
    humanoid.Jumping:Connect(function()
        -- ジャンプ時にチェック
        if humanoid:GetState() == Enum.HumanoidStateType.Physics then
            -- 空中でジャンプを再度許可
            humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        end
    end)
end

-- 空中でもジャンプを複数回許可する処理
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == jumpKey then
        if humanoid:GetState() ~= Enum.HumanoidStateType.Seated then
            humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            humanoid:Move(Vector3.new(0, 0, 0))  -- 空中でジャンプを処理
            humanoid:Jump()
        end
    end
end)

-- 関数を有効化
enableDoubleJump()
