local infiniteJumpEnabled = false;
MainTab:AddToggle({Name="無限ジャンプ",Default=false,Callback=function(value)
    infiniteJumpEnabled = value;
end});
game:GetService("UserInputService").JumpRequest:Connect(function()
    if (infiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")) then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping);
    end
end);
local noclipEnabled = false;
MainTab:AddToggle({Name="壁貫通（Noclip）",Default=false,Callback=function(value)
    noclipEnabled = value;
end});
game:GetService("RunService").Stepped:Connect(function()
    if (noclipEnabled and LocalPlayer.Character) then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false;
            end
        end
    end
end);
