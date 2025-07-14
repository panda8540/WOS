local BACK_OFFSET = -3  -- ← マイナスに！

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
