--[[
    ══════════════════════════════════════════════════════════════════
    👻 GHOST SCRIPT | ULTRA-STABLE MM2 AUTO FARM ENGINE (v2.0 FIXED)
    - Kesintisiz Tur / Harita Değişim Yönetimi (Sonsuz Döngü)
    - Bellek / Referans Sızıntısı Koruması (Garbage Collection Fix)
    - Yerin Altından 20 Hızında Güvenli Farm & Noclip
    - Dinamik Ada GUI & Koyu Karşılama Ekranı
    - Discord: https://discord.gg/KHVHAgQRCN & Anti-AFK
    ══════════════════════════════════════════════════════════════════
--]]

-- Temizlik
pcall(function()
    if getgenv and getgenv().GhostScriptGui then
        getgenv().GhostScriptGui:Destroy()
    end
    if getgenv and getgenv().GhostCleanUp then
        getgenv().GhostCleanUp()
    end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local function getSafeGuiParent()
    local parent = nil
    if typeof(gethui) == "function" then
        pcall(function() parent = gethui() end)
    end
    if not parent and pcall(function() return CoreGui end) then
        pcall(function() parent = CoreGui end)
    end
    if not parent then
        parent = LocalPlayer:WaitForChild("PlayerGui", 10)
    end
    return parent or LocalPlayer:FindFirstChildOfClass("PlayerGui")
end

-- Sistem Ayarları
local Config = {
    AutoCoin = false,        
    FlyEnabled = false,      
    FlySpeed = 20,           
    UndergroundDepth = 1.8,  
    FPSBoost = false,
    AntiAFK = false,
    CollectedCoins = {},
    FailedAttempts = {}
}

-- Hafıza Temizleme Fonksiyonu (Turlar arası kilitlenmeyi çözer)
local function wipeMemory()
    table.clear(Config.CollectedCoins)
    table.clear(Config.FailedAttempts)
end

-- ══════════════════════════════════════════════════════════════════
-- 🛡️ ANTI-AFK ENGINE
-- ══════════════════════════════════════════════════════════════════
LocalPlayer.Idled:Connect(function()
    if Config.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- ══════════════════════════════════════════════════════════════════
-- 🕊️ KESİNTİSİZ FİZİK VE FLY MOTORU
-- ══════════════════════════════════════════════════════════════════
local isPhysicsActive = false
local bodyVel = nil
local bodyGyro = nil

local function fullResetPhysics()
    isPhysicsActive = false
    local char = LocalPlayer.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        for _, desc in ipairs(char:GetDescendants()) do
            if desc:IsA("BodyVelocity") or desc:IsA("BodyGyro") or desc:IsA("BodyPosition") or desc:IsA("LinearVelocity") then
                pcall(function() desc:Destroy() end)
            end
        end
        
        if hum then
            hum.PlatformStand = false
        end
        
        if root then
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
    end
    bodyVel = nil
    bodyGyro = nil
end

local function setupPhysics(root)
    if isPhysicsActive and bodyVel and bodyVel.Parent == root and bodyGyro and bodyGyro.Parent == root then
        return
    end
    
    fullResetPhysics()
    isPhysicsActive = true

    bodyVel = Instance.new("BodyVelocity")
    bodyVel.MaxForce = Vector3.new(400000, 400000, 400000)
    bodyVel.Velocity = Vector3.zero
    bodyVel.Parent = root

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
    bodyGyro.P = 3000
    bodyGyro.D = 300
    bodyGyro.CFrame = root.CFrame
    bodyGyro.Parent = root
end

getgenv().GhostCleanUp = fullResetPhysics

-- ══════════════════════════════════════════════════════════════════
-- 🎨 GUI DESIGN (DİNAMİK ADA & MODERN PANEL)
-- ══════════════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GhostScript_v2_Stable"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if getgenv then getgenv().GhostScriptGui = ScreenGui end
ScreenGui.Parent = getSafeGuiParent()

-- Dinamik Ada
local DynamicIsland = Instance.new("TextButton")
DynamicIsland.Name = "DynamicIsland"
DynamicIsland.Size = UDim2.new(0, 260, 0, 36)
DynamicIsland.Position = UDim2.new(0.5, -130, 0, 48)
DynamicIsland.BackgroundColor3 = Color3.fromRGB(8, 9, 12)
DynamicIsland.BorderSizePixel = 0
DynamicIsland.AutoButtonColor = false
DynamicIsland.Text = ""
DynamicIsland.Parent = ScreenGui

local UICorner_Island = Instance.new("UICorner")
UICorner_Island.CornerRadius = UDim.new(1, 0)
UICorner_Island.Parent = DynamicIsland

local UIStroke_Island = Instance.new("UIStroke")
UIStroke_Island.Color = Color3.fromRGB(50, 56, 70)
UIStroke_Island.Thickness = 1.2
UIStroke_Island.Parent = DynamicIsland

local IslandLogo = Instance.new("ImageLabel")
IslandLogo.Size = UDim2.new(0, 22, 0, 22)
IslandLogo.Position = UDim2.new(0, 8, 0.5, -11)
IslandLogo.BackgroundTransparency = 1
IslandLogo.Image = "rbxassetid://15263884876"
IslandLogo.ImageColor3 = Color3.fromRGB(245, 248, 255)
IslandLogo.ScaleType = Enum.ScaleType.Fit
IslandLogo.Parent = DynamicIsland

local IslandText = Instance.new("TextLabel")
IslandText.Size = UDim2.new(0, 120, 1, 0)
IslandText.Position = UDim2.new(0, 34, 0, 0)
IslandText.BackgroundTransparency = 1
IslandText.Text = "GHOST SCRIPT"
IslandText.Font = Enum.Font.GothamBold
IslandText.TextSize = 12
IslandText.TextColor3 = Color3.fromRGB(240, 245, 255)
IslandText.TextXAlignment = Enum.TextXAlignment.Left
IslandText.Parent = DynamicIsland

local IslandBadge = Instance.new("TextLabel")
IslandBadge.Size = UDim2.new(0, 90, 0, 20)
IslandBadge.Position = UDim2.new(1, -96, 0.5, -10)
IslandBadge.BackgroundColor3 = Color3.fromRGB(16, 20, 28)
IslandBadge.Text = "● PASİF"
IslandBadge.Font = Enum.Font.GothamBold
IslandBadge.TextSize = 10
IslandBadge.TextColor3 = Color3.fromRGB(240, 150, 60)
IslandBadge.Parent = DynamicIsland

local UICorner_Badge = Instance.new("UICorner")
UICorner_Badge.CornerRadius = UDim.new(1, 0)
UICorner_Badge.Parent = IslandBadge

-- Ana Panel
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 490)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -245)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 11, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local UICorner_Main = Instance.new("UICorner")
UICorner_Main.CornerRadius = UDim.new(0, 14)
UICorner_Main.Parent = MainFrame

local UIStroke_Main = Instance.new("UIStroke")
UIStroke_Main.Color = Color3.fromRGB(55, 62, 78)
UIStroke_Main.Thickness = 1.4
UIStroke_Main.Parent = MainFrame

-- Başlık
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Color3.fromRGB(16, 18, 24)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local UICorner_Title = Instance.new("UICorner")
UICorner_Title.CornerRadius = UDim.new(0, 14)
UICorner_Title.Parent = TitleBar

local TitleLogo = Instance.new("ImageLabel")
TitleLogo.Size = UDim2.new(0, 30, 0, 30)
TitleLogo.Position = UDim2.new(0, 14, 0.5, -15)
TitleLogo.BackgroundTransparency = 1
TitleLogo.Image = "rbxassetid://15263884876"
TitleLogo.ImageColor3 = Color3.fromRGB(240, 245, 255)
TitleLogo.ScaleType = Enum.ScaleType.Fit
TitleLogo.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -100, 0, 20)
TitleText.Position = UDim2.new(0, 52, 0, 8)
TitleText.BackgroundTransparency = 1
TitleText.Text = "GHOST SCRIPT v2"
TitleText.TextSize = 14
TitleText.Font = Enum.Font.GothamBold
TitleText.TextColor3 = Color3.fromRGB(245, 248, 255)
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, -100, 0, 16)
SubTitle.Position = UDim2.new(0, 52, 0, 27)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "STABLE MULTI-ROUND ENGINE"
SubTitle.TextSize = 9
SubTitle.Font = Enum.Font.GothamMedium
SubTitle.TextColor3 = Color3.fromRGB(130, 140, 165)
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -38, 0, 11)
CloseBtn.BackgroundColor3 = Color3.fromRGB(26, 30, 42)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(180, 190, 215)
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = TitleBar

local UICorner_Close = Instance.new("UICorner")
UICorner_Close.CornerRadius = UDim.new(0, 8)
UICorner_Close.Parent = CloseBtn

-- İçerik Kutusu
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -24, 1, -62)
Container.Position = UDim2.new(0, 12, 0, 54)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Container

-- Durum Kartı
local StatsCard = Instance.new("Frame")
StatsCard.Size = UDim2.new(1, 0, 0, 62)
StatsCard.BackgroundColor3 = Color3.fromRGB(16, 18, 25)
StatsCard.BorderSizePixel = 0
StatsCard.LayoutOrder = 1
StatsCard.Parent = Container

local StatsCorner = Instance.new("UICorner")
StatsCorner.CornerRadius = UDim.new(0, 10)
StatsCorner.Parent = StatsCard

local StatsStroke = Instance.new("UIStroke")
StatsStroke.Color = Color3.fromRGB(38, 44, 58)
StatsStroke.Thickness = 1
StatsStroke.Parent = StatsCard

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -20, 0, 20)
StatusText.Position = UDim2.new(0, 12, 0, 8)
StatusText.BackgroundTransparency = 1
StatusText.Text = "● Sistem Hazır"
StatusText.Font = Enum.Font.GothamBold
StatusText.TextSize = 13
StatusText.TextColor3 = Color3.fromRGB(240, 160, 60)
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = StatsCard

local TargetInfoText = Instance.new("TextLabel")
TargetInfoText.Size = UDim2.new(0.6, -10, 0, 18)
TargetInfoText.Position = UDim2.new(0, 12, 0, 32)
TargetInfoText.BackgroundTransparency = 1
TargetInfoText.Text = "📍 Farm Kapalı"
TargetInfoText.Font = Enum.Font.Gotham
TargetInfoText.TextSize = 11
TargetInfoText.TextColor3 = Color3.fromRGB(140, 155, 180)
TargetInfoText.TextXAlignment = Enum.TextXAlignment.Left
TargetInfoText.Parent = StatsCard

local FPSText = Instance.new("TextLabel")
FPSText.Size = UDim2.new(0.4, -10, 0, 18)
FPSText.Position = UDim2.new(0.6, 0, 0, 32)
FPSText.BackgroundTransparency = 1
FPSText.Text = "⚡ Hız: 20 | FPS: --"
FPSText.Font = Enum.Font.GothamMedium
FPSText.TextSize = 11
FPSText.TextColor3 = Color3.fromRGB(190, 205, 235)
FPSText.TextXAlignment = Enum.TextXAlignment.Right
FPSText.Parent = StatsCard

-- Toggle Yapıcı
local function addToggle(title, desc, defaultVal, order, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 52)
    Frame.BackgroundColor3 = Color3.fromRGB(16, 18, 25)
    Frame.BorderSizePixel = 0
    Frame.LayoutOrder = order
    Frame.Parent = Container

    local FrameCorner = Instance.new("UICorner")
    FrameCorner.CornerRadius = UDim.new(0, 10)
    FrameCorner.Parent = Frame

    local FrameStroke = Instance.new("UIStroke")
    FrameStroke.Color = Color3.fromRGB(38, 44, 58)
    FrameStroke.Thickness = 1
    FrameStroke.Parent = Frame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -70, 0, 18)
    Title.Position = UDim2.new(0, 12, 0, 8)
    Title.BackgroundTransparency = 1
    Title.Text = title
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 12
    Title.TextColor3 = Color3.fromRGB(240, 245, 255)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Frame

    local Desc = Instance.new("TextLabel")
    Desc.Size = UDim2.new(1, -70, 0, 16)
    Desc.Position = UDim2.new(0, 12, 0, 28)
    Desc.BackgroundTransparency = 1
    Desc.Text = desc
    Desc.Font = Enum.Font.Gotham
    Desc.TextSize = 10
    Desc.TextColor3 = Color3.fromRGB(130, 140, 165)
    Desc.TextXAlignment = Enum.TextXAlignment.Left
    Desc.Parent = Frame

    local Switch = Instance.new("TextButton")
    Switch.Size = UDim2.new(0, 42, 0, 22)
    Switch.Position = UDim2.new(1, -54, 0.5, -11)
    Switch.BackgroundColor3 = defaultVal and Color3.fromRGB(230, 235, 245) or Color3.fromRGB(38, 44, 58)
    Switch.Text = ""
    Switch.AutoButtonColor = false
    Switch.Parent = Frame

    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = Switch

    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 16, 0, 16)
    Circle.Position = defaultVal and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    Circle.BackgroundColor3 = defaultVal and Color3.fromRGB(15, 17, 22) or Color3.fromRGB(255, 255, 255)
    Circle.BorderSizePixel = 0
    Circle.Parent = Switch

    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = Circle

    local active = defaultVal
    Switch.MouseButton1Click:Connect(function()
        active = not active
        local bg = active and Color3.fromRGB(230, 235, 245) or Color3.fromRGB(38, 44, 58)
        local circleBg = active and Color3.fromRGB(15, 17, 22) or Color3.fromRGB(255, 255, 255)
        local pos = active and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        
        TweenService:Create(Switch, TweenInfo.new(0.15), {BackgroundColor3 = bg}):Play()
        TweenService:Create(Circle, TweenInfo.new(0.15), {Position = pos, BackgroundColor3 = circleBg}):Play()
        callback(active)
    end)
end

-- Toggles Entegrasyonu
addToggle("👻 Ghost Auto-Farm", "Otomatik harita algılama & kesintisiz sonsuz tur desteği", Config.AutoCoin, 2, function(v)
    Config.AutoCoin = v
    wipeMemory()
    if not v then
        fullResetPhysics()
        StatusText.Text = "● Mod Kapalı"
        StatusText.TextColor3 = Color3.fromRGB(240, 150, 60)
        IslandBadge.Text = "● PASİF"
        IslandBadge.TextColor3 = Color3.fromRGB(240, 150, 60)
        TargetInfoText.Text = "📍 Normal Mod"
    else
        StatusText.Text = "● Ghost Modu: Aktif"
        StatusText.TextColor3 = Color3.fromRGB(120, 235, 160)
        IslandBadge.Text = "● AKTİF"
        IslandBadge.TextColor3 = Color3.fromRGB(100, 240, 160)
        TargetInfoText.Text = "📍 Harita Aranıyor..."
    end
end)

addToggle("🕊️ Fly (Uçma Modu)", "Kamera açısına göre serbest uçuş", Config.FlyEnabled, 3, function(v)
    Config.FlyEnabled = v
    if not v and not Config.AutoCoin then
        fullResetPhysics()
    end
end)

addToggle("🛡️ Anti-AFK Koruması", "20 Dakikalık atılma engelleyici", Config.AntiAFK, 4, function(v)
    Config.AntiAFK = v
end)

addToggle("📉 Ultra FPS Boost", "Çoklu hesap kasmalarını ve ısınmayı engeller", Config.FPSBoost, 5, function(v)
    Config.FPSBoost = v
    pcall(function()
        Lighting.GlobalShadows = not v
        settings().Rendering.QualityLevel = v and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic
    end)
end)

-- Discord Kartı
local DiscordCard = Instance.new("TextButton")
DiscordCard.Size = UDim2.new(1, 0, 0, 48)
DiscordCard.BackgroundColor3 = Color3.fromRGB(16, 19, 28)
DiscordCard.BorderSizePixel = 0
DiscordCard.AutoButtonColor = false
DiscordCard.LayoutOrder = 6
DiscordCard.Text = ""
DiscordCard.Parent = Container

local DiscordCorner = Instance.new("UICorner")
DiscordCorner.CornerRadius = UDim.new(0, 10)
DiscordCorner.Parent = DiscordCard

local DiscordStroke = Instance.new("UIStroke")
DiscordStroke.Color = Color3.fromRGB(60, 70, 95)
DiscordStroke.Thickness = 1.2
DiscordStroke.Parent = DiscordCard

local DiscordText = Instance.new("TextLabel")
DiscordText.Size = UDim2.new(1, -110, 0, 18)
DiscordText.Position = UDim2.new(0, 14, 0, 6)
DiscordText.BackgroundTransparency = 1
DiscordText.Text = "💬 Discord: https://discord.gg/KHVHAgQRCN"
DiscordText.Font = Enum.Font.GothamBold
DiscordText.TextSize = 11
DiscordText.TextColor3 = Color3.fromRGB(230, 238, 255)
DiscordText.TextXAlignment = Enum.TextXAlignment.Left
DiscordText.Parent = DiscordCard

local DiscordSub = Instance.new("TextLabel")
DiscordSub.Size = UDim2.new(1, -110, 0, 14)
DiscordSub.Position = UDim2.new(0, 14, 0, 26)
DiscordSub.BackgroundTransparency = 1
DiscordSub.Text = "Kopyalamak için tıkla"
DiscordSub.Font = Enum.Font.Gotham
DiscordSub.TextSize = 9
DiscordSub.TextColor3 = Color3.fromRGB(130, 145, 175)
DiscordSub.TextXAlignment = Enum.TextXAlignment.Left
DiscordSub.Parent = DiscordCard

local CopyBadge = Instance.new("TextLabel")
CopyBadge.Size = UDim2.new(0, 64, 0, 24)
CopyBadge.Position = UDim2.new(1, -72, 0.5, -12)
CopyBadge.BackgroundColor3 = Color3.fromRGB(28, 34, 50)
CopyBadge.Text = "Kopyala"
CopyBadge.Font = Enum.Font.GothamBold
CopyBadge.TextSize = 10
CopyBadge.TextColor3 = Color3.fromRGB(200, 215, 245)
CopyBadge.Parent = DiscordCard

local CopyBadgeCorner = Instance.new("UICorner")
CopyBadgeCorner.CornerRadius = UDim.new(0, 6)
CopyBadgeCorner.Parent = CopyBadge

DiscordCard.MouseButton1Click:Connect(function()
    if typeof(setclipboard) == "function" then setclipboard("https://discord.gg/KHVHAgQRCN") end
    CopyBadge.Text = "✓ Alındı"
    CopyBadge.BackgroundColor3 = Color3.fromRGB(35, 120, 70)
    task.delay(2, function()
        CopyBadge.Text = "Kopyala"
        CopyBadge.BackgroundColor3 = Color3.fromRGB(28, 34, 50)
    end)
end)

-- ══════════════════════════════════════════════════════════════════
-- 🌟 EKRAN KONTROLLERİ & ANİMASYON
-- ══════════════════════════════════════════════════════════════════
local WelcomeOverlay = Instance.new("Frame")
WelcomeOverlay.Size = UDim2.new(1, 0, 1, 0)
WelcomeOverlay.BackgroundColor3 = Color3.fromRGB(6, 7, 9)
WelcomeOverlay.BackgroundTransparency = 0.08
WelcomeOverlay.ZIndex = 50
WelcomeOverlay.Parent = ScreenGui

local WelcomeBox = Instance.new("Frame")
WelcomeBox.Size = UDim2.new(0, 500, 0, 260)
WelcomeBox.Position = UDim2.new(0.5, -250, 0.5, -130)
WelcomeBox.BackgroundColor3 = Color3.fromRGB(12, 14, 18)
WelcomeBox.ZIndex = 51
WelcomeBox.Parent = WelcomeOverlay

local WelcomeCorner = Instance.new("UICorner")
WelcomeCorner.CornerRadius = UDim.new(0, 16)
WelcomeCorner.Parent = WelcomeBox

local WelcomeStroke = Instance.new("UIStroke")
WelcomeStroke.Color = Color3.fromRGB(65, 75, 95)
WelcomeStroke.Thickness = 1.4
WelcomeStroke.Parent = WelcomeBox

local SplashTitle = Instance.new("TextLabel")
SplashTitle.Size = UDim2.new(1, 0, 0, 30)
SplashTitle.Position = UDim2.new(0, 0, 0, 20)
SplashTitle.BackgroundTransparency = 1
SplashTitle.Text = "GHOST SCRIPT v2 STABLE"
SplashTitle.Font = Enum.Font.GothamBold
SplashTitle.TextSize = 18
SplashTitle.TextColor3 = Color3.fromRGB(250, 252, 255)
SplashTitle.ZIndex = 52
SplashTitle.Parent = WelcomeBox

local InfoTR = Instance.new("TextLabel")
InfoTR.Size = UDim2.new(1, -40, 0, 40)
InfoTR.Position = UDim2.new(0, 20, 0, 60)
InfoTR.BackgroundTransparency = 1
InfoTR.Text = "⌨️ Sağ Shift tuşu veya üstteki Dinamik Ada ile menüyü açıp kapatabilirsiniz.\nSonsuz tur desteği aktif edildi!"
InfoTR.Font = Enum.Font.GothamMedium
InfoTR.TextSize = 11
InfoTR.TextColor3 = Color3.fromRGB(200, 210, 235)
InfoTR.ZIndex = 52
InfoTR.Parent = WelcomeBox

local StartBtn = Instance.new("TextButton")
StartBtn.Size = UDim2.new(0, 160, 0, 36)
StartBtn.Position = UDim2.new(0.5, -80, 0, 190)
StartBtn.BackgroundColor3 = Color3.fromRGB(235, 240, 250)
StartBtn.Text = "Başla / Start"
StartBtn.TextColor3 = Color3.fromRGB(10, 12, 16)
StartBtn.Font = Enum.Font.GothamBold
StartBtn.TextSize = 13
StartBtn.ZIndex = 52
StartBtn.Parent = WelcomeBox

local StartBtnCorner = Instance.new("UICorner")
StartBtnCorner.CornerRadius = UDim.new(0, 8)
StartBtnCorner.Parent = StartBtn

StartBtn.MouseButton1Click:Connect(function()
    WelcomeOverlay:Destroy()
end)

local isExpanded = false
local function toggleDynamicIsland()
    isExpanded = not isExpanded
    if isExpanded then
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 420, 0, 490)
        MainFrame.Position = UDim2.new(0.5, -210, 0.5, -245)
        DynamicIsland.Visible = false
    else
        MainFrame.Visible = false
        DynamicIsland.Visible = true
    end
end

DynamicIsland.MouseButton1Click:Connect(toggleDynamicIsland)
CloseBtn.MouseButton1Click:Connect(toggleDynamicIsland)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and (input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.Insert) then
        toggleDynamicIsland()
    end
end)

-- ══════════════════════════════════════════════════════════════════
-- 🛠️ HARİTA DİNAMİK ALGINAMA VE GELİŞMİŞ COIN TARAYICI
-- ══════════════════════════════════════════════════════════════════

-- MM2 Haritasını Bulur
local function getCurrentMap()
    for _, child in ipairs(Workspace:GetChildren()) do
        if child:FindFirstChild("CoinContainer") or child:FindFirstChild("Coin_Container") or child:FindFirstChild("CoinArea") then
            return child
        end
    end
    return Workspace
end

-- Dinamik Coin Tarama
local function getValidCoins()
    local coins = {}
    local activeMap = getCurrentMap()
    
    local containers = {}
    for _, desc in ipairs(activeMap:GetDescendants()) do
        if desc.Name == "CoinContainer" or desc.Name == "Coin_Container" or desc.Name == "CoinArea" then
            table.insert(containers, desc)
        end
    end

    for _, container in ipairs(containers) do
        for _, item in ipairs(container:GetChildren()) do
            local targetPart = nil
            if item:IsA("BasePart") then
                targetPart = item
            elseif item:IsA("Model") then
                targetPart = item:FindFirstChild("Coin") or item:FindFirstChild("CoinVisual") or item:FindFirstChildWhichIsA("BasePart")
            end

            if targetPart and targetPart.Parent and not Config.CollectedCoins[targetPart] and (Config.FailedAttempts[targetPart] or 0) < 3 then
                table.insert(coins, targetPart)
            end
        end
    end

    return coins
end

-- ══════════════════════════════════════════════════════════════════
-- 🔄 KESİNTİSİZ / DİNAMİK ANA DÖNGÜ (TUR BOZULMALARINI ÇÖZER)
-- ══════════════════════════════════════════════════════════════════
local lastMapName = ""

task.spawn(function()
    while true do
        task.wait(0.03)

        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        -- Harita değişim kontrolü (Harita değiştiyse hafızayı otomatik sıfırla)
        local currentMap = getCurrentMap()
        if currentMap.Name ~= lastMapName then
            lastMapName = currentMap.Name
            wipeMemory()
        end

        -- 1. FLY MOTORU
        if Config.FlyEnabled and root and hum and hum.Health > 0 then
            setupPhysics(root)
            hum.PlatformStand = true

            local cam = Workspace.CurrentCamera
            local moveDir = Vector3.zero

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

            if moveDir.Magnitude > 0 then
                bodyVel.Velocity = moveDir.Unit * Config.FlySpeed
            else
                bodyVel.Velocity = Vector3.zero
            end
            bodyGyro.CFrame = cam.CFrame

        -- 2. AUTO-FARM MOTORU
        elseif Config.AutoCoin and root and hum and hum.Health > 0 then
            local coins = getValidCoins()

            if #coins > 0 then
                setupPhysics(root)
                hum.PlatformStand = false

                -- En yakın Coin'i Bul
                local closestCoin = nil
                local minDistance = math.huge

                for _, coin in ipairs(coins) do
                    if coin and coin.Parent then
                        local dist = (root.Position - coin.Position).Magnitude
                        if dist < minDistance then
                            minDistance = dist
                            closestCoin = coin
                        end
                    end
                end

                if closestCoin and closestCoin.Parent then
                    StatusText.Text = string.format("● Toplanıyor (%d Coin)", #coins)
                    StatusText.TextColor3 = Color3.fromRGB(120, 235, 160)
                    TargetInfoText.Text = string.format("📍 Mesafe: %.1f m", minDistance)

                    local targetPosition = closestCoin.Position - Vector3.new(0, Config.UndergroundDepth, 0)
                    local startTime = tick()

                    -- Coin'e gitme iç döngüsü
                    while Config.AutoCoin and not Config.FlyEnabled and closestCoin.Parent and not Config.CollectedCoins[closestCoin] and hum and hum.Health > 0 do
                        local curPos = root.Position
                        local dist = (curPos - closestCoin.Position).Magnitude

                        -- Takılma / Zaman Aşımı Kontrolü (2 saniyede ulaşamazsa es geç)
                        if tick() - startTime > 2.0 then
                            Config.FailedAttempts[closestCoin] = (Config.FailedAttempts[closestCoin] or 0) + 1
                            break
                        end

                        -- Coin Toplama Alanı
                        if dist <= 3.5 then
                            if typeof(firetouchinterest) == "function" then
                                pcall(function()
                                    firetouchinterest(root, closestCoin, 0)
                                    task.wait()
                                    firetouchinterest(root, closestCoin, 1)
                                end)
                            end
                            Config.CollectedCoins[closestCoin] = true
                            break
                        end

                        -- Yerin altından hareket etme fiziği
                        local dir = (targetPosition - curPos)
                        if dir.Magnitude > 0.2 then
                            bodyVel.Velocity = dir.Unit * Config.FlySpeed
                            bodyGyro.CFrame = CFrame.lookAt(curPos, curPos + Vector3.new(dir.X, 0, dir.Z))
                        else
                            bodyVel.Velocity = Vector3.zero
                        end

                        RunService.Heartbeat:Wait()
                    end
                end
            else
                -- Haritada Coin Kalmadı veya Lobi Sırası
                if isPhysicsActive then
                    fullResetPhysics()
                end
                StatusText.Text = "● Bekleniyor (Tur/Lobi)"
                StatusText.TextColor3 = Color3.fromRGB(240, 180, 70)
                TargetInfoText.Text = "📍 Yeni harita bekleniyor..."
                task.wait(0.5)
            end
        else
            if isPhysicsActive then
                fullResetPhysics()
            end
            task.wait(0.2)
        end
    end
end)

-- ══════════════════════════════════════════════════════════════════
-- 👻 MÜKEMMEL NOCLIP & FPS MOTORU
-- ══════════════════════════════════════════════════════════════════
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if char and (Config.AutoCoin or Config.FlyEnabled) then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

local frameCount = 0
local lastFpsUpdate = tick()
RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = tick()
    if now - lastFpsUpdate >= 1 then
        FPSText.Text = string.format("⚡ Hız: 20 | FPS: %d", math.floor(frameCount / (now - lastFpsUpdate)))
        frameCount = 0
        lastFpsUpdate = now
    end
end)
