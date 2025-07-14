----------------------------------------------------
-- 追従処理
----------------------------------------------------
local BACK_OFFSET = 3      -- ←ここを正の値に
RunService.RenderStepped:Connect(function()
    if not currentTarget then return end
    local myChar     = localPlr.Character
    local targetChar = currentTarget.Character
    if not (myChar and targetChar) then return end

    local myRoot  = myChar:FindFirstChild("HumanoidRootPart")
    local trgRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not (myRoot and trgRoot) then return end

    -- 相手と同じ向きを保ったまま背後 3 stud へ
    myRoot.CFrame = trgRoot.CFrame * CFrame.new(0, 0, BACK_OFFSET)
end)
