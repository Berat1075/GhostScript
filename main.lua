--[[
    ══════════════════════════════════════════════════════════════════
    👻 GHOST SCRIPT | AUTO ROUND & RESUME SMART ENGINE
    - Otomatik Round Tespiti (El bitince durur, yeni elde başlar)
    - Ölüm Koruması (Ölünce otomatik kapatır, doğunca bekler)
    - Yerin Altından Kafa Dışarıda 20 Hızında Güvenli Farm
    - Tam Ekran Koyu Karşılama Ekranı & iPhone Dinamik Ada
    - Discord: https://discord.gg/KHVHAgQRCN & Anti-AFK
    ══════════════════════════════════════════════════════════════════
--]]

-- Eski Nesneleri & Motorları Temizle
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

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Xeno Güvenli GUI Taşıyıcı
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

-- Ayarlar (TÜMÜ VARSAYILAN OLARAK KAPALI)
local Config = {
    AutoCoin = false,        -- Kullanıcı Ana Şalteri
    UndergroundDepth = 1.8,  -- Kafa Dışarıda Yeraltı Seviyesi
    FlySpeed = 20,           -- Kicklemeyen Güvenli Hız
    FPSBoost = false,
    AntiAFK = false,
    CollectedCoins = {},
    FailedAttempts = {}
}

-- ══════════════════════════════════════════════════════════════════
-- 🛡️ ENTEGRE ANTI-AFK MOTORU
-- ══════════════════════════════════════════════════════════════════
LocalPlayer.Idled:Connect(function()
    if Config.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- ══════════════════════════════════════════════════════════════════
-- 🕊️ TİTREMESİZ VE DOĞAL FİZİK SİSTEMİ
-- ══════════════════════════════════════════════════════════════════
local isPhysicsActive = false
local bodyVel = nil
local bodyGyro = nil

local function restoreCharacterCollisions(char)
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if part.Name == "HumanoidRootPart" then
                part.CanCollide = false
            else
                part.CanCollide = true
            end
        end
    end
end

local function fullResetPhysics()
    isPhysicsActive = false
    local char = LocalPlayer.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        for _, desc in ipairs(char:GetDescendants()) do
            if desc:IsA("BodyVelocity") or desc:IsA("BodyGyro") or desc:IsA("BodyPosition") or desc:IsA("LinearVelocity") then
                desc:Destroy()
            end
        end
        
        restoreCharacterCollisions(char)
        
        if hum then
            hum.PlatformStand = false
            hum.Sit = false
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
    isPhysicsActive = true

    if bodyVel then bodyVel:Destroy() end
    bodyVel = Instance.new("BodyVelocity")
    bodyVel.MaxForce = Vector3.new(400000, 400000, 400000)
    bodyVel.Velocity = Vector3.zero
    bodyVel.Parent = root

    if bodyGyro then bodyGyro:Destroy() end
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
    bodyGyro.P = 3000
    bodyGyro.D = 300
    bodyGyro.CFrame = root.CFrame
    bodyGyro.Parent = root
end

getgenv().GhostCleanUp = fullResetPhysics

-- ══════════════════════════════════════════════════════════════════
-- 🎨 GUI ANA YAPISI & DİNAMİK ADA
-- ══════════════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GhostScript_AutoRound"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if getgenv then
    getgenv().GhostScriptGui = ScreenGui
end
ScreenGui.Parent = getSafeGuiParent()

-- 1. Dinamik Ada (Dynamic Island)
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

-- 2. Genişletilmiş Ana Panel
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 440)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -220)
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

-- Başlık Barı
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Color3.fromRGB(16, 18, 24)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local UICorner_Title = Instance.new("UICorner")
UICorner_Title.CornerRadius = UDim.new(0, 14)
UICorner_Title.Parent = TitleBar

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 12)
TitleFix.Position = UDim2.new(0, 0, 1, -12)
TitleFix.BackgroundColor3 = Color3.fromRGB(16, 18, 24)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

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
TitleText.Text = "GHOST SCRIPT"
TitleText.TextSize = 14
TitleText.Font = Enum.Font.GothamBold
TitleText.TextColor3 = Color3.fromRGB(245, 248, 255)
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, -100, 0, 16)
SubTitle.Position = UDim2.new(0, 52, 0, 27)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "KOENIGSEGG GHOST SQUADRON EDITION"
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
StatusText.Text = "● Sistem Hazır (Ghost Farm Kapalı)"
StatusText.Font = Enum.Font.GothamBold
StatusText.TextSize = 13
StatusText.TextColor3 = Color3.fromRGB(240, 160, 60)
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = StatsCard

local TargetInfoText = Instance.new("TextLabel")
TargetInfoText.Size = UDim2.new(0.6, -10, 0, 18)
TargetInfoText.Position = UDim2.new(0, 12, 0, 32)
TargetInfoText.BackgroundTransparency = 1
TargetInfoText.Text = "📍 Başlatmak için butona bas"
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

-- 1. Sınırsız Ghost Auto-Coin
addToggle("👻 Ghost Auto-Farm", "Otomatik round takibiyle sınırsız para toplar", Config.AutoCoin, 2, function(v)
    Config.AutoCoin = v
    if not v then
        fullResetPhysics()
        StatusText.Text = "● Ghost Modu Kapatıldı"
        StatusText.TextColor3 = Color3.fromRGB(240, 150, 60)
        IslandBadge.Text = "● PASİF"
        IslandBadge.TextColor3 = Color3.fromRGB(240, 150, 60)
        TargetInfoText.Text = "📍 Karakter Normalde"
    else
        StatusText.Text = "● Ghost Modu: Aktif (20 Hız)"
        StatusText.TextColor3 = Color3.fromRGB(120, 235, 160)
        IslandBadge.Text = "● AKTİF"
        IslandBadge.TextColor3 = Color3.fromRGB(100, 240, 160)
        TargetInfoText.Text = "📍 Yeraltı Otomatik Mod"
    end
end)

-- 2. Anti-AFK
addToggle("🛡️ Anti-AFK Koruması", "20 dakika hareketsizlik kickini %100 engeller", Config.AntiAFK, 3, function(v)
    Config.AntiAFK = v
end)

-- 3. FPS Boost
local function applyFPSBoost(enable)
    pcall(function()
        if enable then
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            for _, v in ipairs(Lighting:GetChildren()) do
                if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") then
                    v.Enabled = false
                end
            end
        else
            Lighting.GlobalShadows = true
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        end
    end)
end

addToggle("📉 Ultra FPS Boost", "Çoklu hesaplarda kasmayı ve ısınmayı önler", Config.FPSBoost, 4, function(v)
    Config.FPSBoost = v
    applyFPSBoost(v)
end)

-- Panel İçi Discord Kartı
local DiscordCard = Instance.new("TextButton")
DiscordCard.Name = "DiscordCard"
DiscordCard.Size = UDim2.new(1, 0, 0, 48)
DiscordCard.BackgroundColor3 = Color3.fromRGB(16, 19, 28)
DiscordCard.BorderSizePixel = 0
DiscordCard.AutoButtonColor = false
DiscordCard.LayoutOrder = 5
DiscordCard.Text = ""
DiscordCard.Parent = Container

local DiscordCorner = Instance.new("UICorner")
DiscordCorner.CornerRadius = UDim.new(0, 10)
DiscordCorner.Parent = DiscordCard

local DiscordStroke = Instance.new("UIStroke")
DiscordStroke.Color = Color3.fromRGB(60, 70, 95)
DiscordStroke.Thickness = 1.2
DiscordStroke.Parent = DiscordCard

local DiscordIcon = Instance.new("TextLabel")
DiscordIcon.Size = UDim2.new(0, 24, 0, 24)
DiscordIcon.Position = UDim2.new(0, 12, 0.5, -12)
DiscordIcon.BackgroundTransparency = 1
DiscordIcon.Text = "💬"
DiscordIcon.TextSize = 16
DiscordIcon.Parent = DiscordCard

local DiscordText = Instance.new("TextLabel")
DiscordText.Size = UDim2.new(1, -110, 0, 18)
DiscordText.Position = UDim2.new(0, 40, 0, 6)
DiscordText.BackgroundTransparency = 1
DiscordText.Text = "Discord: https://discord.gg/KHVHAgQRCN"
DiscordText.Font = Enum.Font.GothamBold
DiscordText.TextSize = 11
DiscordText.TextColor3 = Color3.fromRGB(230, 238, 255)
DiscordText.TextXAlignment = Enum.TextXAlignment.Left
DiscordText.Parent = DiscordCard

local DiscordSub = Instance.new("TextLabel")
DiscordSub.Size = UDim2.new(1, -110, 0, 14)
DiscordSub.Position = UDim2.new(0, 40, 0, 26)
DiscordSub.BackgroundTransparency = 1
DiscordSub.Text = "Katılmak veya kopyalamak için tıkla"
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

local function copyDiscord()
    local link = "https://discord.gg/KHVHAgQRCN"
    if typeof(setclipboard) == "function" then
        setclipboard(link)
    end
    CopyBadge.Text = "✓ Alındı"
    CopyBadge.BackgroundColor3 = Color3.fromRGB(35, 120, 70)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Ghost Script Discord",
            Text = "Discord linki panoya kopyalandı!",
            Duration = 3
        })
    end)
    task.delay(2, function()
        CopyBadge.Text = "Kopyala"
        CopyBadge.BackgroundColor3 = Color3.fromRGB(28, 34, 50)
    end)
end
DiscordCard.MouseButton1Click:Connect(copyDiscord)

-- ══════════════════════════════════════════════════════════════════
-- 🌟 TAM EKRAN DERİN KOYU KARŞILAMA EKRANI (WELCOME SCREEN)
-- ══════════════════════════════════════════════════════════════════
local WelcomeOverlay = Instance.new("Frame")
WelcomeOverlay.Name = "WelcomeOverlay"
WelcomeOverlay.Size = UDim2.new(1, 0, 1, 0)
WelcomeOverlay.Position = UDim2.new(0, 0, 0, 0)
WelcomeOverlay.BackgroundColor3 = Color3.fromRGB(6, 7, 9)
WelcomeOverlay.BackgroundTransparency = 0.08
WelcomeOverlay.ZIndex = 50
WelcomeOverlay.Parent = ScreenGui

local WelcomeBox = Instance.new("Frame")
WelcomeBox.Size = UDim2.new(0, 520, 0, 330)
WelcomeBox.Position = UDim2.new(0.5, -260, 0.5, -165)
WelcomeBox.BackgroundColor3 = Color3.fromRGB(12, 14, 18)
WelcomeBox.BorderSizePixel = 0
WelcomeBox.ZIndex = 51
WelcomeBox.Parent = WelcomeOverlay

local WelcomeCorner = Instance.new("UICorner")
WelcomeCorner.CornerRadius = UDim.new(0, 16)
WelcomeCorner.Parent = WelcomeBox

local WelcomeStroke = Instance.new("UIStroke")
WelcomeStroke.Color = Color3.fromRGB(65, 75, 95)
WelcomeStroke.Thickness = 1.4
WelcomeStroke.Parent = WelcomeBox

local SplashLogo = Instance.new("ImageLabel")
SplashLogo.Size = UDim2.new(0, 42, 0, 42)
SplashLogo.Position = UDim2.new(0.5, -21, 0, 16)
SplashLogo.BackgroundTransparency = 1
SplashLogo.Image = "rbxassetid://15263884876"
SplashLogo.ImageColor3 = Color3.fromRGB(245, 248, 255)
SplashLogo.ScaleType = Enum.ScaleType.Fit
SplashLogo.ZIndex = 52
SplashLogo.Parent = WelcomeBox

local SplashTitle = Instance.new("TextLabel")
SplashTitle.Size = UDim2.new(1, 0, 0, 24)
SplashTitle.Position = UDim2.new(0, 0, 0, 62)
SplashTitle.BackgroundTransparency = 1
SplashTitle.Text = "GHOST SCRIPT"
SplashTitle.Font = Enum.Font.GothamBold
SplashTitle.TextSize = 18
SplashTitle.TextColor3 = Color3.fromRGB(250, 252, 255)
SplashTitle.ZIndex = 52
SplashTitle.Parent = WelcomeBox

local InfoTR = Instance.new("TextLabel")
InfoTR.Size = UDim2.new(1, -40, 0, 20)
InfoTR.Position = UDim2.new(0, 20, 0, 94)
InfoTR.BackgroundTransparency = 1
InfoTR.Text = "⌨️ Sağ Shift tuşuna basarak veya Dinamik Ada'ya tıklayarak menüyü açabilirsiniz."
InfoTR.Font = Enum.Font.GothamBold
InfoTR.TextSize = 11
InfoTR.TextColor3 = Color3.fromRGB(240, 245, 255)
InfoTR.ZIndex = 52
InfoTR.Parent = WelcomeBox

local InfoEN = Instance.new("TextLabel")
InfoEN.Size = UDim2.new(1, -40, 0, 18)
InfoEN.Position = UDim2.new(0, 20, 0, 114)
InfoEN.BackgroundTransparency = 1
InfoEN.Text = "Press Right Shift or click the Dynamic Island above to open the menu."
InfoEN.Font = Enum.Font.Gotham
InfoEN.TextSize = 10
InfoEN.TextColor3 = Color3.fromRGB(150, 160, 185)
InfoEN.ZIndex = 52
InfoEN.Parent = WelcomeBox

local SplashDiscordBtn = Instance.new("TextButton")
SplashDiscordBtn.Size = UDim2.new(1, -40, 0, 46)
SplashDiscordBtn.Position = UDim2.new(0, 20, 0, 142)
SplashDiscordBtn.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
SplashDiscordBtn.Text = ""
SplashDiscordBtn.AutoButtonColor = false
SplashDiscordBtn.ZIndex = 52
SplashDiscordBtn.Parent = WelcomeBox

local SplashDiscCorner = Instance.new("UICorner")
SplashDiscCorner.CornerRadius = UDim.new(0, 10)
SplashDiscCorner.Parent = SplashDiscordBtn

local SplashDiscStroke = Instance.new("UIStroke")
SplashDiscStroke.Color = Color3.fromRGB(65, 75, 105)
SplashDiscStroke.Thickness = 1.2
SplashDiscStroke.Parent = SplashDiscordBtn

local SplashDiscIcon = Instance.new("TextLabel")
SplashDiscIcon.Size = UDim2.new(0, 26, 0, 26)
SplashDiscIcon.Position = UDim2.new(0, 12, 0.5, -13)
SplashDiscIcon.BackgroundTransparency = 1
SplashDiscIcon.Text = "💬"
SplashDiscIcon.TextSize = 16
SplashDiscIcon.ZIndex = 53
SplashDiscIcon.Parent = SplashDiscordBtn

local SplashDiscText = Instance.new("TextLabel")
SplashDiscText.Size = UDim2.new(1, -120, 0, 18)
SplashDiscText.Position = UDim2.new(0, 44, 0, 6)
SplashDiscText.BackgroundTransparency = 1
SplashDiscText.Text = "Discord: https://discord.gg/KHVHAgQRCN"
SplashDiscText.Font = Enum.Font.GothamBold
SplashDiscText.TextSize = 11
SplashDiscText.TextColor3 = Color3.fromRGB(240, 245, 255)
SplashDiscText.TextXAlignment = Enum.TextXAlignment.Left
SplashDiscText.ZIndex = 53
SplashDiscText.Parent = SplashDiscordBtn

local SplashDiscSub = Instance.new("TextLabel")
SplashDiscSub.Size = UDim2.new(1, -120, 0, 14)
SplashDiscSub.Position = UDim2.new(0, 44, 0, 25)
SplashDiscSub.BackgroundTransparency = 1
SplashDiscSub.Text = "Kopyalamak veya katılmak için tıkla (Click to copy)"
SplashDiscSub.Font = Enum.Font.Gotham
SplashDiscSub.TextSize = 9
SplashDiscSub.TextColor3 = Color3.fromRGB(140, 155, 185)
SplashDiscSub.TextXAlignment = Enum.TextXAlignment.Left
SplashDiscSub.ZIndex = 53
SplashDiscSub.Parent = SplashDiscordBtn

local SplashCopyBadge = Instance.new("TextLabel")
SplashCopyBadge.Size = UDim2.new(0, 68, 0, 24)
SplashCopyBadge.Position = UDim2.new(1, -78, 0.5, -12)
SplashCopyBadge.BackgroundColor3 = Color3.fromRGB(30, 36, 54)
SplashCopyBadge.Text = "Kopyala"
SplashCopyBadge.Font = Enum.Font.GothamBold
SplashCopyBadge.TextSize = 10
SplashCopyBadge.TextColor3 = Color3.fromRGB(210, 225, 255)
SplashCopyBadge.ZIndex = 53
SplashCopyBadge.Parent = SplashDiscordBtn

local SplashCopyCorner = Instance.new("UICorner")
SplashCopyCorner.CornerRadius = UDim.new(0, 6)
SplashCopyCorner.Parent = SplashCopyBadge

SplashDiscordBtn.MouseButton1Click:Connect(function()
    local link = "https://discord.gg/KHVHAgQRCN"
    if typeof(setclipboard) == "function" then
        setclipboard(link)
    end
    SplashCopyBadge.Text = "✓ Alındı"
    SplashCopyBadge.BackgroundColor3 = Color3.fromRGB(35, 120, 70)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Ghost Script Discord",
            Text = "Discord linki panoya kopyalandı!",
            Duration = 3
        })
    end)
    task.delay(2, function()
        SplashCopyBadge.Text = "Kopyala"
        SplashCopyBadge.BackgroundColor3 = Color3.fromRGB(30, 36, 54)
    end)
end)

local ThanksTR = Instance.new("TextLabel")
ThanksTR.Size = UDim2.new(1, -40, 0, 20)
ThanksTR.Position = UDim2.new(0, 20, 0, 202)
ThanksTR.BackgroundTransparency = 1
ThanksTR.Text = "✨ Bizi tercih ettiğiniz için teşekkür ederiz!"
ThanksTR.Font = Enum.Font.GothamBold
ThanksTR.TextSize = 12
ThanksTR.TextColor3 = Color3.fromRGB(100, 235, 160)
ThanksTR.ZIndex = 52
ThanksTR.Parent = WelcomeBox

local ThanksEN = Instance.new("TextLabel")
ThanksEN.Size = UDim2.new(1, -40, 0, 16)
ThanksEN.Position = UDim2.new(0, 20, 0, 222)
ThanksEN.BackgroundTransparency = 1
ThanksEN.Text = "Thank you for choosing us!"
ThanksEN.Font = Enum.Font.GothamMedium
ThanksEN.TextSize = 10
ThanksEN.TextColor3 = Color3.fromRGB(140, 155, 180)
ThanksEN.ZIndex = 52
ThanksEN.Parent = WelcomeBox

local StartBtn = Instance.new("TextButton")
StartBtn.Size = UDim2.new(0, 180, 0, 36)
StartBtn.Position = UDim2.new(0.5, -90, 0, 272)
StartBtn.BackgroundColor3 = Color3.fromRGB(235, 240, 250)
StartBtn.Text = "Başla / Start"
StartBtn.TextColor3 = Color3.fromRGB(10, 12, 16)
StartBtn.TextSize = 13
StartBtn.Font = Enum.Font.GothamBold
StartBtn.AutoButtonColor = false
StartBtn.ZIndex = 52
StartBtn.Parent = WelcomeBox

local StartBtnCorner = Instance.new("UICorner")
StartBtnCorner.CornerRadius = UDim.new(0, 8)
StartBtnCorner.Parent = StartBtn

local function closeSplash()
    TweenService:Create(WelcomeOverlay, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    }):Play()
    TweenService:Create(WelcomeBox, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, -260, 1.2, 0)
    }):Play()
    task.delay(0.25, function()
        WelcomeOverlay:Destroy()
    end)
end

StartBtn.MouseButton1Click:Connect(closeSplash)

-- ══════════════════════════════════════════════════════════════════
-- 🔄 DİNAMİK ADA AÇILMA / KAPANMA ANİMASYONU
-- ══════════════════════════════════════════════════════════════════
local isExpanded = false
local isAnimating = false

local function toggleDynamicIsland()
    if isAnimating then return end
    isAnimating = true
    isExpanded = not isExpanded

    if isExpanded then
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 260, 0, 36)
        MainFrame.Position = DynamicIsland.Position
        DynamicIsland.Visible = false

        TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 420, 0, 440),
            Position = UDim2.new(0.5, -210, 0.5, -220)
        }):Play()

        task.delay(0.35, function()
            isAnimating = false
        end)
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 260, 0, 36),
            Position = DynamicIsland.Position
        }):Play()

        task.delay(0.25, function()
            MainFrame.Visible = false
            DynamicIsland.Visible = true
            isAnimating = false
        end)
    end
end

DynamicIsland.MouseButton1Click:Connect(toggleDynamicIsland)
CloseBtn.MouseButton1Click:Connect(toggleDynamicIsland)

-- Sürükleme Mantığı
local function makeDraggable(f, h)
    local drag, dInput, start, pStart
    h.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true
            start = i.Position
            pStart = f.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then drag = false end
            end)
        end
    end)
    f.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
            dInput = i
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if i == dInput and drag then
            local delta = i.Position - start
            f.Position = UDim2.new(pStart.X.Scale, pStart.X.Offset + delta.X, pStart.Y.Scale, pStart.Y.Offset + delta.Y)
        end
    end)
end
makeDraggable(MainFrame, TitleBar)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and (input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.Insert) then
        toggleDynamicIsland()
    end
end)

-- ══════════════════════════════════════════════════════════════════
-- 🚀 SIFIR KASAN NOCLIP ÖNBELLEĞİ & CAN / ÖLÜM TAKİBİ
-- ══════════════════════════════════════════════════════════════════
local charParts = {}
local function updateCharCache(char)
    table.clear(charParts)
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                table.insert(charParts, part)
            end
        end
        
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then
            hum.Died:Connect(function()
                fullResetPhysics()
                if Config.AutoCoin then
                    StatusText.Text = "● Öldün (Yeni Round Bekleniyor)"
                    StatusText.TextColor3 = Color3.fromRGB(240, 100, 100)
                    TargetInfoText.Text = "📍 Doğunca otomatik başlayacak"
                end
            end)
        end
    end
end

if LocalPlayer.Character then
    updateCharCache(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    fullResetPhysics()
    table.clear(Config.CollectedCoins)
    table.clear(Config.FailedAttempts)
    updateCharCache(char)
    char.DescendantAdded:Connect(function(p)
        if p:IsA("BasePart") then
            table.insert(charParts, p)
        end
    end)
end)

RunService.Stepped:Connect(function()
    if Config.AutoCoin and isPhysicsActive then
        for i = 1, #charParts do
            local p = charParts[i]
            if p and p.Parent and p.CanCollide then
                p.CanCollide = false
            end
        end
    end
end)

-- FPS Sayacı
local frameCount = 0
local lastFpsUpdate = tick()
RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = tick()
    if now - lastFpsUpdate >= 1 then
        local fps = math.floor(frameCount / (now - lastFpsUpdate))
        FPSText.Text = string.format("⚡ Hız: 20 | FPS: %d", fps)
        frameCount = 0
        lastFpsUpdate = now
    end
end)

-- ══════════════════════════════════════════════════════════════════
-- 🧠 EVRENSEL MM2 COIN TARAYICI
-- ══════════════════════════════════════════════════════════════════
local function findAllCoins()
    local coins = {}
    local char = LocalPlayer.Character

    for _, descendant in ipairs(workspace:GetDescendants()) do
        local name = descendant.Name
        if name == "CoinContainer" or name == "Coin_Container" or name == "CoinArea" then
            for _, item in ipairs(descendant:GetChildren()) do
                local part = nil
                if item:IsA("BasePart") then
                    part = item
                elseif item:IsA("Model") then
                    part = item:FindFirstChild("Coin") 
                        or item:FindFirstChild("CoinVisual") 
                        or item:FindFirstChild("Touch")
                        or item:FindFirstChildWhichIsA("BasePart")
                end

                if part and part.Parent and not Config.CollectedCoins[part] and not Config.CollectedCoins[item] and (Config.FailedAttempts[part] or 0) < 3 then
                    if not char or not part:IsDescendantOf(char) then
                        table.insert(coins, part)
                    end
                end
            end
        end
    end

    if #coins == 0 then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == "Coin_Server" or obj.Name == "CoinVisual" or (obj.Name == "Coin" and obj:IsA("BasePart")) then
                local p = obj:IsA("BasePart") and obj or (obj:FindFirstChild("Coin") or obj:FindFirstChild("CoinVisual") or obj:FindFirstChildWhichIsA("BasePart"))
                if p and p.Parent and not Config.CollectedCoins[p] and not Config.CollectedCoins[obj] and (Config.FailedAttempts[p] or 0) < 3 then
                    if not char or not p:IsDescendantOf(char) then
                        table.insert(coins, p)
                    end
                end
            end
        end
    end

    return coins
end

-- Dokunma Tetikleyici
local function touchCoin(rootPart, coinPart)
    if typeof(firetouchinterest) == "function" then
        pcall(function()
            firetouchinterest(rootPart, coinPart, 0)
            task.wait()
            firetouchinterest(rootPart, coinPart, 1)
        end)
    end
end

-- ══════════════════════════════════════════════════════════════════
-- 🔄 ANA DÖNGÜ (OTOMATİK ROUND VE CAN TAKİP MOTORU)
-- ══════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(0.03)

        if Config.AutoCoin then
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")

            -- Karakter Yaşıyorsa ve Canı Varsa:
            if root and hum and hum.Health > 0 then
                local coins = findAllCoins()

                -- Haritada Coin Varsa (Oyun Başlamışsa):
                if #coins > 0 then
                    local closestCoin = nil
                    local shortestDist = math.huge

                    for _, coin in ipairs(coins) do
                        if coin and coin.Parent and not Config.CollectedCoins[coin] then
                            local d = (root.Position - coin.Position).Magnitude
                            if d < shortestDist then
                                shortestDist = d
                                closestCoin = coin
                            end
                        end
                    end

                    if closestCoin and closestCoin.Parent then
                        setupPhysics(root)
                        hum.PlatformStand = false

                        StatusText.Text = string.format("● Toplanıyor (%d Coin Kaldı)", #coins)
                        StatusText.TextColor3 = Color3.fromRGB(120, 235, 160)
                        TargetInfoText.Text = string.format("📍 Mesafe: %.1f metre", shortestDist)

                        local targetPeekPos = Vector3.new(
                            closestCoin.Position.X,
                            closestCoin.Position.Y - Config.UndergroundDepth,
                            closestCoin.Position.Z
                        )

                        local startTime = tick()

                        while Config.AutoCoin and closestCoin.Parent and not Config.CollectedCoins[closestCoin] and hum.Health > 0 do
                            local currentPos = root.Position
                            local dist = (currentPos - closestCoin.Position).Magnitude

                            if tick() - startTime > 2.2 then
                                Config.FailedAttempts[closestCoin] = (Config.FailedAttempts[closestCoin] or 0) + 1
                                break
                            end

                            if dist <= 3.2 then
                                touchCoin(root, closestCoin)
                                
                                Config.CollectedCoins[closestCoin] = true
                                if closestCoin.Parent then
                                    Config.CollectedCoins[closestCoin.Parent] = true
                                end
                                break
                            end

                            local delta = (targetPeekPos - currentPos)
                            if delta.Magnitude > 0.3 then
                                local dir = delta.Unit
                                bodyVel.Velocity = dir * Config.FlySpeed
                                bodyGyro.CFrame = CFrame.lookAt(currentPos, currentPos + Vector3.new(dir.X, 0, dir.Z))
                            else
                                bodyVel.Velocity = Vector3.zero
                            end

                            RunService.Heartbeat:Wait()
                        end
                    end
                else
                    -- Haritada coin kalmadığında (El bittiğinde / Lobideyken):
                    if isPhysicsActive then
                        fullResetPhysics()
                    end
                    StatusText.Text = "● Bekleme Modu (El Sonu / Lobi)"
                    StatusText.TextColor3 = Color3.fromRGB(240, 180, 70)
                    TargetInfoText.Text = "📍 Yeni el başlayınca otomatik açılacak"
                    task.wait(0.5)
                end
            else
                -- Karakter öldüyse hemen fiziği sıfırla
                if isPhysicsActive then
                    fullResetPhysics()
                end
                task.wait(0.3)
            end
        else
            if isPhysicsActive then
                fullResetPhysics()
            end
            task.wait(0.2)
        end
    end
end)
