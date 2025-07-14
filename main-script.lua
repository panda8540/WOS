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
