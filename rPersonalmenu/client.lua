ESX = nil

local actionCles, ShowName, gamerTags, invisible, hasCinematic = {select = {"Prêter", "Détruire"}, index = 1}, false, {}, false, false

local Rperso = {
    ItemSelected = {},
    ItemSelected2 = {},
    WeaponData = {},
    factures = {},
    cledevoiture = {},
    bank = nil,
    sale = nil,
    DoorState = {
		FrontLeft = false,
		FrontRight = false,
		BackLeft = false,
		BackRight = false,
		Hood = false,
		Trunk = false
	},
    Admin = {
        showcoords = false,
        NoClipP = false,
        godmode = false,
        affichername = false, 
        fantomemode = false
    },
	DoorIndex = 1,
	DoorList = {"Avant Gauche", "Avant Droite", "Arrière Gauche", "Arrière Droite"},
    minimap = true,
    cinema = false
}

local societymoney, societymoney2 = nil, nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(10)
    end

    ESX.PlayerData = ESX.GetPlayerData()

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    ESX.TriggerServerCallback('gPersonalmenu:getUsergroup', function(group)
        playergroup = group
    end)

    RefreshMoney()

	if Config.DoubleJob then
		RefreshMoney2()
	end

    Rperso.WeaponData = ESX.GetWeaponList()
	for i = 1, #Rperso.WeaponData, 1 do
		if Rperso.WeaponData[i].name == 'WEAPON_UNARMED' then
			Rperso.WeaponData[i] = nil
		else
			Rperso.WeaponData[i].hash = GetHashKey(Rperso.WeaponData[i].name)
		end
    end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(200)

		if ShowName then
			local pCoords = GetEntityCoords(GetPlayerPed(-1), false)
			for _, v in pairs(GetActivePlayers()) do
				local otherPed = GetPlayerPed(v)
			
				if otherPed ~= pPed then
					if #(pCoords - GetEntityCoords(otherPed, false)) < 250.0 then
						gamerTags[v] = CreateFakeMpGamerTag(otherPed, ('[%s] %s'):format(GetPlayerServerId(v), GetPlayerName(v)), false, false, '', 0)
						SetMpGamerTagVisibility(gamerTags[v], 4, 1)
					else
						RemoveMpGamerTag(gamerTags[v])
						gamerTags[v] = nil
					end
				end
			end
		else
			for _, v in pairs(GetActivePlayers()) do
				RemoveMpGamerTag(gamerTags[v])
			end
		end
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  ESX.PlayerData = xPlayer
end)

RegisterNetEvent('es:activateMoney')
AddEventHandler('es:activateMoney', function(money)
	  ESX.PlayerData.money = money
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
	RefreshMoney()
end)

RegisterNetEvent('esx:setJob2')
AddEventHandler('esx:setJob2', function(job2)
	ESX.PlayerData.job2 = job2
	RefreshMoney2()
end)

RegisterNetEvent('esx:setAccountMoney')
AddEventHandler('esx:setAccountMoney', function(account)
	for i=1, #ESX.PlayerData.accounts, 1 do
		if ESX.PlayerData.accounts[i].name == account.name then
			ESX.PlayerData.accounts[i] = account
			break
		end
	end
end)

--- Argent entreprise/orga

RegisterNetEvent('esx_addonaccount:setMoney')
AddEventHandler('esx_addonaccount:setMoney', function(society, money)
	if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' and 'society_' .. ESX.PlayerData.job.name == society then
		societymoney = ESX.Math.GroupDigits(money)
	end

	if ESX.PlayerData.job2 ~= nil and ESX.PlayerData.job2.grade_name == 'boss' and 'society_' .. ESX.PlayerData.job2.name == society then
		societymoney2 = ESX.Math.GroupDigits(money)
	end
end)

RegisterNetEvent('gPersonalmenu:Weapon_addAmmoToPedC')
AddEventHandler('gPersonalmenu:Weapon_addAmmoToPedC', function(value, quantity)
  local weaponHash = GetHashKey(value)

    if HasPedGotWeapon(PlayerPed, weaponHash, false) and value ~= 'WEAPON_UNARMED' then
        AddAmmoToPed(PlayerPed, value, quantity)
    end
end)


function RefreshMoney()
	if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' then
		ESX.TriggerServerCallback('esx_society:getSocietyMoney', function(money)
			societymoney = ESX.Math.GroupDigits(money)
		end, ESX.PlayerData.job.name)
	end
end

function RefreshMoney2()
	if ESX.PlayerData.job2 ~= nil and ESX.PlayerData.job2.grade_name == 'boss' then
		ESX.TriggerServerCallback('esx_society:getSocietyMoney', function(money)
			societymoney2 = ESX.Math.GroupDigits(money)
		end, ESX.PlayerData.job2.name)
	end
end

local function rPersonalmenuKeyboardInput(TextEntry, ExampleText, MaxStringLenght)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry)
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
    blockinput = true

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do 
        Citizen.Wait(0)
    end
        
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult() 
        Citizen.Wait(500) 
        blockinput = false
        return result 
    else
        Citizen.Wait(500) 
        blockinput = false 
        return nil 
    end
end

function gPersonalmenu()
    local MPersonalmenu = RageUI.CreateMenu(Config.nomduserveur, "Interaction")
    local Minventaire = RageUI.CreateSubMenu(MPersonalmenu, Config.nomduserveur, "Interaction")
    local Minventaire2 = RageUI.CreateSubMenu(Minventaire, Config.nomduserveur, "Interaction")
    local Marmes = RageUI.CreateSubMenu(MPersonalmenu, Config.nomduserveur, "Interaction")
    local Marmes2 = RageUI.CreateSubMenu(Marmes, Config.nomduserveur, "Interaction")
    local Mportefeuille = RageUI.CreateSubMenu(MPersonalmenu, Config.nomduserveur, "Interaction")
    local Mportefeuilleli = RageUI.CreateSubMenu(Mportefeuille, Config.nomduserveur, "Interaction")
    local Mportefeuillesale = RageUI.CreateSubMenu(Mportefeuille, Config.nomduserveur, "Interaction")
    local Mfacture = RageUI.CreateSubMenu(MPersonalmenu, Config.nomduserveur, "Interaction")
    local Mvetements = RageUI.CreateSubMenu(MPersonalmenu, Config.nomduserveur, "Interaction")
    local Manimations = RageUI.CreateSubMenu(MPersonalmenu, Config.nomduserveur, "Interaction")
    local Mfestives = RageUI.CreateSubMenu(Manimations, Config.nomduserveur, "Interaction")
    local Msalutations = RageUI.CreateSubMenu(Manimations, Config.nomduserveur, "Interaction")
    local Mtravail = RageUI.CreateSubMenu(Manimations, Config.nomduserveur, "Interaction")
    local Mhumeurs = RageUI.CreateSubMenu(Manimations, Config.nomduserveur, "Interaction")
    local Msports = RageUI.CreateSubMenu(Manimations, Config.nomduserveur, "Interaction")
    local Manimationsdivers = RageUI.CreateSubMenu(Manimations, Config.nomduserveur, "Interaction")
    local Mattitudes = RageUI.CreateSubMenu(Manimations, Config.nomduserveur, "Interaction")
    local Mpegi18 = RageUI.CreateSubMenu(Manimations, Config.nomduserveur, "Interaction")
    local Mgestveh = RageUI.CreateSubMenu(MPersonalmenu, Config.nomduserveur, "Interaction")
    local Mgestentreprise = RageUI.CreateSubMenu(MPersonalmenu, Config.nomduserveur, "Interaction")
    local Mgestoraga = RageUI.CreateSubMenu(MPersonalmenu, Config.nomduserveur, "Interaction")
    local Mdivers = RageUI.CreateSubMenu(MPersonalmenu, Config.nomduserveur, "Interaction")
    local Mclef = RageUI.CreateSubMenu(MPersonalmenu, Config.nomduserveur, "Interaction")
    local Madmin = RageUI.CreateSubMenu(MPersonalmenu, Config.nomduserveur, "Interaction")
    MPersonalmenu:SetRectangleBanner(11, 11, 11, 1)
    Minventaire:SetRectangleBanner(11, 11, 11, 1)
    Minventaire2:SetRectangleBanner(11, 11, 11, 1)
    Marmes:SetRectangleBanner(11, 11, 11, 1)
    Marmes2:SetRectangleBanner(11, 11, 11, 1)
    Mportefeuille:SetRectangleBanner(11, 11, 11, 1)
    Mportefeuilleli:SetRectangleBanner(11, 11, 11, 1)
    Mportefeuillesale:SetRectangleBanner(11, 11, 11, 1)
    Mfacture:SetRectangleBanner(11, 11, 11, 1)
    Mvetements:SetRectangleBanner(11, 11, 11, 1)
    Manimations:SetRectangleBanner(11, 11, 11, 1)
    Mfestives:SetRectangleBanner(11, 11, 11, 1)
    Msalutations:SetRectangleBanner(11, 11, 11, 1)
    Mtravail:SetRectangleBanner(11, 11, 11, 1)
    Mhumeurs:SetRectangleBanner(11, 11, 11, 1)
    Msports:SetRectangleBanner(11, 11, 11, 1)
    Mattitudes:SetRectangleBanner(11, 11, 11, 1)
    Mpegi18:SetRectangleBanner(11, 11, 11, 1)
    Manimationsdivers:SetRectangleBanner(11, 11, 11, 1)
    Mgestveh:SetRectangleBanner(11, 11, 11, 1)
    Mgestentreprise:SetRectangleBanner(11, 11, 11, 1)
    Mgestoraga:SetRectangleBanner(11, 11, 11, 1)
    Mdivers:SetRectangleBanner(11, 11, 11, 1)
    Mclef:SetRectangleBanner(11, 11, 11, 1)
    Madmin:SetRectangleBanner(11, 11, 11, 1)
        RageUI.Visible(MPersonalmenu, not RageUI.Visible(MPersonalmenu))
            while MPersonalmenu do
            Citizen.Wait(0)
            RageUI.IsVisible(MPersonalmenu, true, true, true, function()
                RageUI.Separator('Votre Steam : ~b~'..GetPlayerName(PlayerId()))
                RageUI.Separator('Votre ID : ~b~'..GetPlayerServerId(PlayerId()))
                RageUI.ButtonWithStyle("Inventaire", nil, {RightLabel = "→→"}, true, function(Hovered,Active,Selected)
                end, Minventaire)
                RageUI.ButtonWithStyle("Gestion des Armes", nil, {RightLabel = "→→"}, true, function(Hovered,Active,Selected)
                end, Marmes)
                RageUI.ButtonWithStyle("Portefeuille", nil, {RightLabel = "→→"}, true, function(Hovered,Active,Selected)
                end, Mportefeuille)
                RageUI.ButtonWithStyle("Factures", nil, {RightLabel = "→→"}, true, function(Hovered,Active,Selected)
                end, Mfacture)
                RageUI.ButtonWithStyle("Vétements", nil, {RightLabel = "→→"}, true, function(Hovered,Active,Selected)
                end, Mvetements)
                RageUI.ButtonWithStyle("Animations", nil, {RightLabel = "→→"}, true, function(Hovered,Active,Selected)
                end, Manimations)
                if IsPedSittingInAnyVehicle(PlayerPedId()) then
                    RageUI.ButtonWithStyle("Gestion Véhicule", nil, {RightLabel = "→→"}, true, function(Hovered,Active,Selected)
                    end, Mgestveh)                       
                    else
                    RageUI.ButtonWithStyle('Gestion Véhicule', description, {RightBadge = RageUI.BadgeStyle.Lock }, false, function(Hovered, Active, Selected)
                            if (Selected) then
                                end 
                            end)
                        end

                if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' then
                        RageUI.ButtonWithStyle("Gestion Entreprise", nil, {RightLabel = "→→"}, true, function(Hovered,Active,Selected)
                    end, Mgestentreprise)
                else
                    RageUI.ButtonWithStyle('Gestion Entreprise', nil, {RightBadge = RageUI.BadgeStyle.Lock }, false, function(Hovered, Active, Selected)
                        if (Selected) then
                            end 
                        end)
                end
                if ESX.PlayerData.job2 ~= nil and ESX.PlayerData.job2.grade_name == 'boss' then
                    RageUI.ButtonWithStyle("Gestion Organisation", nil, {RightLabel = "→→"}, true, function(Hovered,Active,Selected)
                end, Mgestoraga)
            else
                RageUI.ButtonWithStyle('Gestion Organisation', nil, {RightBadge = RageUI.BadgeStyle.Lock }, false, function(Hovered, Active, Selected)
                    if (Selected) then
                        end 
                    end)
            end

            if playergroup == "admin" or playergroup == "superadmin" then
            RageUI.ButtonWithStyle("Administration", nil, {RightLabel = "→→"}, true, function(Hovered,Active,Selected)
            end, Madmin)
        else
            RageUI.ButtonWithStyle('Administration', nil, {RightBadge = RageUI.BadgeStyle.Lock }, false, function(Hovered, Active, Selected)
                if (Selected) then
                    end 
                end)
        end

        
        RageUI.ButtonWithStyle("Cle(s)", nil, {RightLabel = "→→"}, true, function(Hovered,Active,Selected)
            if (Selected) then
                RefreshCles()
            end
        end, Mclef)

            RageUI.ButtonWithStyle("Divers", nil, {RightLabel = "→→"}, true, function(Hovered,Active,Selected)
            end, Mdivers)

                end, function()
                end)

                RageUI.IsVisible(Minventaire, true, true, true, function()
                    RageUI.Separator('~b~↓ Votre Inventaire ↓')
                    ESX.PlayerData = ESX.GetPlayerData()
                    for i = 1, #ESX.PlayerData.inventory do
                        if ESX.PlayerData.inventory[i].count > 0 then
                            RageUI.ButtonWithStyle('[' ..ESX.PlayerData.inventory[i].count.. '] - ~s~' ..ESX.PlayerData.inventory[i].label, nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected) 
                                if (Selected) then 
                                    Rperso.ItemSelected = ESX.PlayerData.inventory[i]
                                    end 
                                end, Minventaire2)
                            end
                        end
                end, function()
                end)
                RageUI.IsVisible(Minventaire2, true, true, true, function()
                    RageUI.ButtonWithStyle("Utiliser", nil, {RightBadge = RageUI.BadgeStyle.Heart}, true, function(Hovered, Active, Selected)
                        if (Selected) then
                         if Rperso.ItemSelected.usable then
                             TriggerServerEvent('esx:useItem', Rperso.ItemSelected.name)
                            else
                                ESX.ShowNotification('l\'items n\'est pas utilisable', Rperso.ItemSelected.label)
                                end
                            end
                        end) 

                        RageUI.ButtonWithStyle("Jeter", nil, {RightBadge = RageUI.BadgeStyle.Alert}, true, function(Hovered, Active, Selected)
                            if (Selected) then
                                if Rperso.ItemSelected.canRemove then
                                    local quantity = rPersonalmenuKeyboardInput("Nombres d'items que vous voulez jeter", '', 25)
                                    if tonumber(quantity) then
                                        if not IsPedSittingInAnyVehicle(PlayerPedId()) then
                                            TriggerServerEvent('esx:removeInventoryItem', 'item_standard', Rperso.ItemSelected.name, tonumber(quantity))
                                        else
                                            ESX.ShowNotification("Vous ne pouvez pas faire ceci dans un véhicule !")
                                        end
                                    else
                                        ESX.ShowNotification("Nombres d'items invalid !")
                                    end
                                end
                            end
                        end)

                        RageUI.ButtonWithStyle("Donner", nil, {RightBadge = RageUI.BadgeStyle.Tick}, true, function(Hovered, Active, Selected)
                            if (Selected) then
                                local quantity = rPersonalmenuKeyboardInput("Nombres d'items que vous voulez donner", "", 25)
                                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                                local pPed = GetPlayerPed(-1)
                                local coords = GetEntityCoords(pPed)
                                local x,y,z = table.unpack(coords)
                                DrawMarker(2, x, y, z+1.5, 0, 0, 0, 180.0,nil,nil, 0.5, 0.5, 0.5, 0, 0, 255, 120, true, true, p19, true)
            
                                if tonumber(quantity) then
                                    if closestDistance ~= -1 and closestDistance <= 3 then
                                        local closestPed = GetPlayerPed(closestPlayer)
            
                                        if IsPedOnFoot(closestPed) then
                                                TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(closestPlayer), 'item_standard', Rperso.ItemSelected.name, tonumber(quantity))
                                            else
                                                ESX.ShowNotification("Nombres d'items invalid !")
                                            end
                                    else
                                        ESX.ShowNotification("Aucun joueur ~r~Proche~n~ !")
                                        end
                                    end
                                end
                            end)

                        end, function()
                        end)
                            RageUI.IsVisible(Marmes, true, true, true, function()
                                RageUI.Separator('~r~↓ Vos Armes ↓')
                                local weaponList = ESX.GetWeaponList()

                                for i=1, #weaponList, 1 do
                                    local weaponHash = GetHashKey(weaponList[i].name)
                                    local Ammo = GetAmmoInPedWeapon(PlayerPedId(), weaponHash)
                                    if HasPedGotWeapon(PlayerPedId(), weaponHash, false) and weaponList[i].name ~= 'WEAPON_UNARMED' then
                                    RageUI.ButtonWithStyle("["..Ammo.."] - "..weaponList[i].label, nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                                        if Selected then
                                            Rperso.ItemSelected2 = weaponList[i]
                                            Rperso.ItemSelected2.hash = weaponHash
                                    end
                                end, Marmes2)
                            end
                            end
                end, function()
                end)

                RageUI.IsVisible(Marmes2, true, true, true, function()
                    if HasPedGotWeapon(PlayerPedId(), Rperso.ItemSelected2.hash, false) then
                    RageUI.ButtonWithStyle('Donner des munitions', nil, {RightBadge = RageUI.BadgeStyle.Ammo}, true, function(Hovered, Active, Selected)
                        if (Selected) then
                            local quantity = rPersonalmenuKeyboardInput("Nombre de munitions", "", 25)
    
                            if tonumber(quantity) then
                                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    
                                if closestDistance ~= -1 and closestDistance <= 3 then
                                    local closestPed = GetPlayerPed(closestPlayer)
                                    local pPed = GetPlayerPed(-1)
                                    local coords = GetEntityCoords(pPed)
                                    local x,y,z = table.unpack(coords)
                                    DrawMarker(2, x, y, z+1.5, 0, 0, 0, 180.0,nil,nil, 0.5, 0.5, 0.5, 0, 0, 255, 120, true, true, p19, true)
    
                                    if IsPedOnFoot(closestPed) then
                                        local ammo = GetAmmoInPedWeapon(PlayerPedId(), Rperso.ItemSelected2.hash)
    
                                        if ammo > 0 then
                                            if quantity <= ammo and quantity >= 0 then
                                                local finalAmmo = math.floor(ammo - quantity)
                                                SetPedAmmo(PlayerPedId(), Rperso.ItemSelected2.name, finalAmmo)
    
                                                TriggerServerEvent('gPersonalmenu:Weapon_addAmmoToPedS', GetPlayerServerId(closestPlayer), Rperso.ItemSelected2.name, quantity)
                                                ESX.ShowNotification('Vous avez donné x%s munitions à %s', quantity, GetPlayerName(closestPlayer))
                                                --RageUI.CloseAll()
                                            else
                                                ESX.ShowNotification('Vous ne possédez pas autant de munitions')
                                            end
                                        else
                                            ESX.ShowNotification("Vous n'avez pas de munition")
                                        end
                                    else
                                        ESX.ShowNotification('Vous ne pouvez pas donner des munitions dans un ~~r~véhicule~s~', Rperso.ItemSelected2.label)
                                    end
                                else
                                    ESX.ShowNotification('Aucun joueur ~r~proche~s~ !')
                                end
                            else
                                ESX.ShowNotification('Nombre de munition ~r~invalid')
                            end
                        end
                    end)
                    
                    RageUI.ButtonWithStyle("Jeter l'arme", nil, {RightBadge = RageUI.BadgeStyle.Gun}, true, function(Hovered, Active, Selected)
                        if Selected then
                            if IsPedOnFoot(PlayerPedId()) then
                                TriggerServerEvent('esx:removeInventoryItem', 'item_weapon', Rperso.ItemSelected2.name)
                                --RageUI.CloseAll()
                            else
                                ESX.ShowNotification("~r~Impossible~s~ de jeter l'armes dans un véhicule", Rperso.ItemSelected2.label)
                            end
                        end
                    end)

                    
                        RageUI.ButtonWithStyle("Donner l'arme", nil, {RightBadge = RageUI.BadgeStyle.Gun}, true, function(Hovered, Active, Selected)
                            if Selected then
                                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    
                            if closestDistance ~= -1 and closestDistance <= 3 then
                                local closestPed = GetPlayerPed(closestPlayer)
                                local pPed = GetPlayerPed(-1)
                                local coords = GetEntityCoords(pPed)
                                local x,y,z = table.unpack(coords)
                                DrawMarker(2, x, y, z+1.5, 0, 0, 0, 180.0,nil,nil, 0.5, 0.5, 0.5, 0, 0, 255, 120, true, true, p19, true)
    
                                if IsPedOnFoot(closestPed) then
                                    local ammo = GetAmmoInPedWeapon(PlayerPedId(), Rperso.ItemSelected2.hash)
                                    TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(closestPlayer), 'item_weapon', Rperso.ItemSelected2.name, tonumber(ammo))
                                    --seAll()
                                else
                                    ESX.ShowNotification('~r~Impossible~s~ de donner une arme dans un véhicule', Rperso.ItemSelected2.label)
                                end
                            else
                                ESX.ShowNotification('Aucun joueur ~r~proche !')
                            end
                        end
                    end)
                end
            end, function()
            end)
            RageUI.IsVisible(Mportefeuille, true, true, true, function()

                RageUI.Separator('~g~Métier : '..ESX.PlayerData.job.label, ESX.PlayerData.job.grade_label)

                if Config.DoubleJob then
                RageUI.Separator('~r~Oganisation : '..ESX.PlayerData.job2.label, ESX.PlayerData.job2.grade_label)
                end

                RageUI.ButtonWithStyle('Liquide : ', description, {RightLabel = "~g~$"..ESX.Math.GroupDigits(ESX.PlayerData.money.."~s~ →")}, true, function(Hovered, Active, Selected) 
                    if (Selected) then 
                        end 
                    end, Mportefeuilleli)

                for i = 1, #ESX.PlayerData.accounts, 1 do
                        if ESX.PlayerData.accounts[i].name == 'black_money' then
                            Rperso.sale = RageUI.ButtonWithStyle('Argent Sale : ', description, {RightLabel = "~r~$"..ESX.Math.GroupDigits(ESX.PlayerData.accounts[i].money.."~s~ →")}, true, function(Hovered, Active, Selected) 
                                if (Selected) then 
                                        end 
                                end, Mportefeuillesale)

                            end
        
                    if ESX.PlayerData.accounts[i].name == 'bank' then
                        Rperso.bank = RageUI.ButtonWithStyle('Banque : ', description, {RightLabel = "~b~$"..ESX.Math.GroupDigits(ESX.PlayerData.accounts[i].money.."~s~")}, true, function(Hovered, Active, Selected) 
                            if (Selected) then 
                                    end 
                                end)


                    end
                end

        if Config.JSFourIDCard then

            RageUI.Separator('~y~ ↓ Vos papiers ↓')
            
			RageUI.ButtonWithStyle('Montrer sa carte d\'identité', nil, {}, true, function(Hovered, Active, Selected)
				if (Selected) then
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

					if closestDistance ~= -1 and closestDistance <= 3.0 then
						TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(closestPlayer))
					else
						ESX.ShowNotification('Aucun joueur ~r~proche !')
					end
				end
			end)

			RageUI.ButtonWithStyle('Regarder sa carte d\'identité', nil, {}, true, function(Hovered, Active, Selected)
				if (Selected) then
					TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()))
				end
			end)

			RageUI.ButtonWithStyle('Montrer son permis de conduire', nil, {}, true, function(Hovered, Active, Selected)
				if (Selected) then
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

					if closestDistance ~= -1 and closestDistance <= 3.0 then
						TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(closestPlayer), 'driver')
					else
						ESX.ShowNotification('Aucun joueur ~r~proche !')
					end
				end
			end)

			RageUI.ButtonWithStyle('Regarder son permis de conduire', nil, {}, true, function(Hovered, Active, Selected)
				if (Selected) then
					TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'driver')
				end
			end)

			RageUI.ButtonWithStyle('Montrer son permis port d\'armes', nil, {}, true, function(Hovered, Active, Selected)
				if (Selected) then
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

					if closestDistance ~= -1 and closestDistance <= 3.0 then
						TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(closestPlayer), 'weapon')
					else
						ESX.ShowNotification('Aucun joueur ~r~proche !')
					end
				end
			end)

			RageUI.ButtonWithStyle('Regarder son permis port d\'armes', nil, {}, true, function(Hovered, Active, Selected)
				if (Selected) then
					TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'weapon')
				end
			end)
		end

            end, function()
            end)
            RageUI.IsVisible(Mportefeuilleli, true, true, true, function()
                RageUI.ButtonWithStyle("Donner", nil, {RightBadge = RageUI.BadgeStyle.Lock}, true, function(Hovered,Active,Selected)
                    if Selected then
                        local quantity = rPersonalmenuKeyboardInput("Somme d'argent que vous voulez donner", '', 25)
                            if tonumber(quantity) then
                                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

                        if closestDistance ~= -1 and closestDistance <= 3 then
                            local closestPed = GetPlayerPed(closestPlayer)

                            if not IsPedSittingInAnyVehicle(closestPed) then
                                TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(closestPlayer), 'item_money', 'rien', tonumber(quantity))
                            else
                               ESX.ShowNotification('Vous ne pouvez pas donner de l\'argent dans un véhicles')
                            end
                        else
                           ESX.ShowNotification('Aucun joueur proche !')
                        end
                    else
                       ESX.ShowNotification('Somme invalid')
                    end
                end
            end)

            RageUI.ButtonWithStyle("Jeter", nil, {RightBadge = RageUI.BadgeStyle.Tick}, true, function(Hovered, Active, Selected)
                if Selected then
                    local quantity = rPersonalmenuKeyboardInput("Somme d'argent que vous voulez jeter", "", 25)
                    if tonumber(quantity) then
                        if not IsPedSittingInAnyVehicle(PlayerPedId()) then
                            TriggerServerEvent('esx:removeInventoryItem', 'item_money', 'rien', tonumber(quantity))
                            RageUI.CloseAll()
                        else
                            ESX.ShowNotification("~r~Cette action est impossible dans un véhicule !")
                        end
                    else
                        ESX.ShowNotification("~r~Les champs sont incorrects !")
                    end
                end
            end)

            end, function()
            end)

            RageUI.IsVisible(Mportefeuillesale, true, true, true, function()
                for i = 1, #ESX.PlayerData.accounts, 1 do
                    if ESX.PlayerData.accounts[i].name == 'black_money' then
                        RageUI.ButtonWithStyle("Donner", nil, {RightBadge = RageUI.BadgeStyle.Lock}, true, function(Hovered,Active,Selected)
                            if Selected then
                                local quantity = rPersonalmenuKeyboardInput("Somme d'argent que vous voulez jeter", "", 25)
                                if tonumber(quantity) then
                                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

                                if closestDistance ~= -1 and closestDistance <= 3 then
                                    local closestPed = GetPlayerPed(closestPlayer)

                                    if not IsPedSittingInAnyVehicle(closestPed) then
                                        TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(closestPlayer), 'item_account', ESX.PlayerData.accounts[i].name, tonumber(quantity))
                                        --RageUI.CloseAll()
                                    else
                                       ESX.ShowNotification(_U('Vous ne pouvez pas donner ', 'de l\'argent dans un véhicles'))
                                    end
                                else
                                   ESX.ShowNotification('Aucun joueur proche !')
                                end
                            else
                               ESX.ShowNotification('Somme invalid')
                            end
                        end
                    end)

                    RageUI.ButtonWithStyle("Jeter", nil, {RightBadge = RageUI.BadgeStyle.Tick}, true, function(Hovered, Active, Selected)
                        if Selected then
                            local quantity = rPersonalmenuKeyboardInput("Somme d'argent que vous voulez jeter", "", 25)
                            if tonumber(quantity) then
                                if not IsPedSittingInAnyVehicle(PlayerPed) then
                                    TriggerServerEvent('esx:removeInventoryItem', 'item_account', ESX.PlayerData.accounts[i].name, tonumber(quantity))
                                   -- RageUI.CloseAll()
                                        else
                                           ESX.ShowNotification('Vous pouvez pas jeter', 'de l\'argent')
                                            end
                                        else
                                           ESX.ShowNotification('Somme Invalid')
                                        end
                                    end
                                end)
                            end
                        end
            end, function()
            end)
            RageUI.IsVisible(Mfacture, true, true, true, function()
                ESX.TriggerServerCallback('rPersonalmenu:facture', function(bills) Rperso.factures = bills end)

                if #Rperso.factures == 0 then
                    RageUI.Separator("")
                    RageUI.Separator("~y~Aucune facture impayée")
                    RageUI.Separator("")
                end
                    
                for i = 1, #Rperso.factures, 1 do
                RageUI.ButtonWithStyle(Rperso.factures[i].label, nil, {RightLabel = '[~b~$' .. ESX.Math.GroupDigits(Rperso.factures[i].amount.."~s~] →")}, true, function(Hovered,Active,Selected)
                    if Selected then
                            ESX.TriggerServerCallback('esx_billing:payBill', function()
                            ESX.TriggerServerCallback('rPersonalmenu:facture', function(bills) Rperso.factures = bills end)
                                    end, Rperso.factures[i].id)
                                end
                            end)
                        end
            end, function()
            end)
            RageUI.IsVisible(Mvetements, true, true, true, function()

                RageUI.Separator('~g~↓ Vêtements ↓')

                RageUI.ButtonWithStyle("Haut", nil, {RightBadge = RageUI.BadgeStyle.Clothes}, true, function(Hovered, Active,Selected)
                    if (Selected) then
                       TriggerEvent('rPersonalmenu:actionhaut')   
                   end 
               end)
           
               RageUI.ButtonWithStyle("Pantalon", nil, {RightBadge = RageUI.BadgeStyle.Clothes}, true, function(Hovered, Active,Selected)
                    if (Selected) then
                       TriggerEvent('rPersonalmenu:actionpantalon')  
                   end 
               end)
           
               RageUI.ButtonWithStyle("Chaussure", nil, {RightBadge = RageUI.BadgeStyle.Clothes}, true, function(Hovered, Active,Selected)
                   if (Selected) then 
                   TriggerEvent('rPersonalmenu:actionchaussure')
                  end 
              end)
           
              RageUI.ButtonWithStyle("Sac", nil, {RightBadge = RageUI.BadgeStyle.Clothes}, true, function(Hovered, Active,Selected)
               if (Selected) then
                   TriggerEvent('rPersonalmenu:actionsac') 
                   end 
               end)
           
               RageUI.ButtonWithStyle("Gilet par balle", nil, {RightBadge = RageUI.BadgeStyle.Clothes}, true, function(Hovered, Active,Selected)
                   if (Selected) then
                       TriggerEvent('rPersonalmenu:actiongiletparballe') 
                   end 
               end)

               RageUI.Separator('~y~ ↓ Accessoires ↓')

            RageUI.ButtonWithStyle("Masque", nil, {RightBadge = RageUI.BadgeStyle.Clothes}, true, function(Hovered, Active,Selected)
                if (Selected) then
                    TriggerEvent('rPersonalmenu:masque')
                end 
            end)

            end, function()
            end)


            ----Menu Animations

            RageUI.IsVisible(Manimations, true, true, true, function()
            RageUI.ButtonWithStyle("Festives", nil, {RightLabel = "→→"}, true, function(Hovered,Active,Selected)
            end, Mfestives)
            RageUI.ButtonWithStyle("Salutations", nil, {RightLabel = "→→"}, true, function(Hovered,Active,Selected)
            end, Msalutations)
            RageUI.ButtonWithStyle("Travail", nil, {RightLabel = "→→"}, true, function(Hovered,Active,Selected)
            end, Mtravail)
            RageUI.ButtonWithStyle("Humeurs", nil, {RightLabel = "→→"}, true, function(Hovered,Active,Selected)
            end, Mhumeurs)
            RageUI.ButtonWithStyle("Sports", nil, {RightLabel = "→→"}, true, function(Hovered,Active,Selected)
            end, Msports)
            RageUI.ButtonWithStyle("Divers", nil, {RightLabel = "→→"}, true, function(Hovered,Active,Selected)
            end, Manimationsdivers)
            RageUI.ButtonWithStyle("Attitudes", nil, {RightLabel = "→→"}, true, function(Hovered,Active,Selected)
            end, Mattitudes)
            RageUI.ButtonWithStyle("Adulte +18", nil, {RightLabel = "→→"}, true, function(Hovered,Active,Selected)
            end, Mpegi18)
            end, function()
            end)  

            RageUI.IsVisible(Mfestives, true, true, true, function()

                RageUI.ButtonWithStyle("Fumer une cigarette", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startScenario('WORLD_HUMAN_SMOKING')
                    end
                end)
                RageUI.ButtonWithStyle("Jouer de la musique", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startScenario('WORLD_HUMAN_MUSICIAN')
                    end
                end)
                RageUI.ButtonWithStyle("Dj", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('anim@mp_player_intcelebrationmale@dj', 'dj')
                    end
                end)
                RageUI.ButtonWithStyle("Boire une biere", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startScenario('WORLD_HUMAN_DRINKING')
                    end
                end)
                RageUI.ButtonWithStyle("Bière en zik", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startScenario('WORLD_HUMAN_PARTYING')
                    end
                end)
                RageUI.ButtonWithStyle("Air Guitar", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('anim@mp_player_intcelebrationmale@air_guitar', 'air_guitar')
                    end
                end)
                RageUI.ButtonWithStyle("Air Shagging", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('anim@mp_player_intcelebrationfemale@air_shagging', 'air_shagging')
                    end
                end)
                RageUI.ButtonWithStyle("Rock'n'roll", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('mp_player_int_upperrock', 'mp_player_int_rock')
                    end
                end)
                RageUI.ButtonWithStyle("Fumer un joint", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startScenario('WORLD_HUMAN_SMOKING_POT')
                    end
                end)
                RageUI.ButtonWithStyle("Bourré sur place", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('amb@world_human_bum_standing@drunk@idle_a', 'idle_a')
                    end
                end)
                RageUI.ButtonWithStyle("Vomir en voiture", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('oddjobs@taxi@tie', 'vomit_outside')
                    end
                end)
            end, function()
            end)
            RageUI.IsVisible(Msalutations, true, true, true, function()
                RageUI.ButtonWithStyle("Saluer", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('gestures@m@standing@casual', 'gesture_hello')
                    end
                end)
                RageUI.ButtonWithStyle("Serrer la main", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('mp_common', 'givetake1_a')
                    end
                end)
                RageUI.ButtonWithStyle("Tchek", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('mp_ped_interaction', 'handshake_guy_a')
                    end
                end)
                RageUI.ButtonWithStyle("Salut bandit", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('mp_ped_interaction', 'hugs_guy_a')
                    end
                end)
                RageUI.ButtonWithStyle("Salut Militaire", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('mp_player_int_uppersalute', 'mp_player_int_salute')
                    end
                end)
            end, function()
            end)
            RageUI.IsVisible(Mtravail, true, true, true, function()
                RageUI.ButtonWithStyle("Suspect : se rendre à la police", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('random@arrests@busted','idle_c')
                    end
                end)
                RageUI.ButtonWithStyle("Pêcheur", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startScenario('world_human_stand_fishing')
                    end
                end)
                RageUI.ButtonWithStyle("Police : enquêter", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('amb@code_human_police_investigate@idle_b','idle_f')
                    end
                end)
                RageUI.ButtonWithStyle("Police : parler à la radio", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('random@arrests','generic_radio_chatter')
                    end
                end)
                RageUI.ButtonWithStyle("Police : circulation", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startScenario('WORLD_HUMAN_CAR_PARK_ATTENDANT')
                    end
                end)
                RageUI.ButtonWithStyle("Police : jumelles", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startScenario('WORLD_HUMAN_BINOCULARS')
                    end
                end)
                RageUI.ButtonWithStyle("Agriculture : récolter", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startScenario('world_human_gardener_plant')
                    end
                end)
                RageUI.ButtonWithStyle("Dépanneur : réparer le moteur", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('mini@repair', 'fixing_a_ped')
                    end
                end)
                RageUI.ButtonWithStyle("Médecin : observer", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startScenario('CODE_HUMAN_MEDIC_KNEEL')
                    end
                end)
                RageUI.ButtonWithStyle("Taxi : parler au client", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('oddjobs@taxi@driver', 'leanover_idle')
                    end
                end)
                RageUI.ButtonWithStyle("Taxi : donner la facture", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('oddjobs@taxi@cyi', 'std_hand_off_ps_passenger')
                    end
                end)
                RageUI.ButtonWithStyle("Epicier : donner les courses", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('mp_am_hold_up', 'purchase_beerbox_shopkeeper')
                    end
                end)
                RageUI.ButtonWithStyle("Barman : servir un shot", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('mini@drinking', 'shots_barman_b')
                    end
                end)
                RageUI.ButtonWithStyle("Journaliste : Prendre une photo", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startScenario('WORLD_HUMAN_PAPARAZZI')
                    end
                end)
                RageUI.ButtonWithStyle("Tout métiers : Prendre des notes", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startScenario('WORLD_HUMAN_CLIPBOARD')
                    end
                end)
                RageUI.ButtonWithStyle("Tout métiers : Coup de marteau", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startScenario('WORLD_HUMAN_HAMMERING')
                    end
                end)
                RageUI.ButtonWithStyle("Clochard : Faire la manche", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startScenario('WORLD_HUMAN_BUM_FREEWAY')
                    end
                end)
                RageUI.ButtonWithStyle("Clochard : Faire la statue", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startScenario('WORLD_HUMAN_HUMAN_STATUE')
                    end
                end)
            end, function()
            end)
            RageUI.IsVisible(Mhumeurs, true, true, true, function()
                RageUI.ButtonWithStyle("Féliciter", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startScenario('WORLD_HUMAN_CHEERING')
                    end
                end)
                RageUI.ButtonWithStyle("Super", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('mp_action', 'thanks_male_06')
                    end
                end)
                RageUI.ButtonWithStyle("Toi", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('gestures@m@standing@casual', 'gesture_point')
                    end
                end)
                RageUI.ButtonWithStyle("Viens", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('gestures@m@standing@casual', 'gesture_come_here_soft')
                    end
                end)
                RageUI.ButtonWithStyle("Keskya ?", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('gestures@m@standing@casual', 'gesture_bring_it_on')
                    end
                end)
                RageUI.ButtonWithStyle("A moi", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('gestures@m@standing@casual', 'gesture_me')
                    end
                end)
                RageUI.ButtonWithStyle("Je le savais", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('anim@am_hold_up@male', 'shoplift_high')
                    end
                end)
                RageUI.ButtonWithStyle("Etre épuisé", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('amb@world_human_jog_standing@male@idle_b', 'idle_d')
                    end
                end)
                RageUI.ButtonWithStyle("Je suis dans la merde", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('amb@world_human_bum_standing@depressed@idle_a', 'idle_a')
                    end
                end)
                RageUI.ButtonWithStyle("Facepalm", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('anim@mp_player_intcelebrationmale@face_palm', 'face_palm')
                    end
                end)
                RageUI.ButtonWithStyle("Calme-toi", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('gestures@m@standing@casual', 'gesture_easy_now')
                    end
                end)
                RageUI.ButtonWithStyle("Qu'est ce que j'ai fait", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('oddjobs@assassinate@multi@', 'react_big_variations_a')
                    end
                end)
                RageUI.ButtonWithStyle("Avoir peur", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('amb@code_human_cower_stand@male@react_cowering', 'base_right')
                    end
                end)
                RageUI.ButtonWithStyle("Fight ?", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('anim@deathmatch_intros@unarmed', 'intro_male_unarmed_e')
                    end
                end)
                RageUI.ButtonWithStyle("C'est pas Possible", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('gestures@m@standing@casual', 'gesture_damn')
                    end
                end)
                RageUI.ButtonWithStyle("Enlacer", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('mp_ped_interaction', 'kisses_guy_a')
                    end
                end)
                RageUI.ButtonWithStyle("Doigt d'honneur", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('mp_player_int_upperfinger', 'mp_player_int_finger_01_enter')
                    end
                end)
                RageUI.ButtonWithStyle("Branleur", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('mp_player_int_upperwank', 'mp_player_int_wank_01')
                    end
                end)
                RageUI.ButtonWithStyle("Balle dans la tete", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('mp_suicide', 'pistol')
                    end
                end)
            end, function()
            end)
            RageUI.IsVisible(Msports, true, true, true, function()
                RageUI.ButtonWithStyle("Montrer ses muscles", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('amb@world_human_muscle_flex@arms_at_side@base', 'base')
                    end
                end)
                RageUI.ButtonWithStyle("Barre de musculation", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('amb@world_human_muscle_free_weights@male@barbell@base', 'base')
                    end
                end)
                RageUI.ButtonWithStyle("Faire des pompes", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('amb@world_human_push_ups@male@base', 'base')
                    end
                end)
                RageUI.ButtonWithStyle("Faire des abdos", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('amb@world_human_sit_ups@male@base', 'base')
                    end
                end)
                RageUI.ButtonWithStyle("Faire du yoga", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('amb@world_human_yoga@male@base', 'base_a')
                    end
                end)
            end, function()
            end)
            RageUI.IsVisible(Manimationsdivers, true, true, true, function()
                RageUI.ButtonWithStyle("Boire un café", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('amb@world_human_aa_coffee@idle_a', 'idle_a')
                    end
                end)
                RageUI.ButtonWithStyle("S'asseoir", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('anim@heists@prison_heistunfinished_biztarget_idle', 'target_idle')
                    end
                end)
                RageUI.ButtonWithStyle("Attendre contre un mur", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startScenario('world_human_leaning')
                    end
                end)
                RageUI.ButtonWithStyle("Couché sur le dos", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startScenario('WORLD_HUMAN_SUNBATHE_BACK')
                    end
                end)
                RageUI.ButtonWithStyle("Couché sur le ventre", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startScenario('WORLD_HUMAN_SUNBATHE')
                    end
                end)
                RageUI.ButtonWithStyle("Nettoyer quelque chose", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startScenario('world_human_maid_clean')
                    end
                end)
                RageUI.ButtonWithStyle("Préparer à manger", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startScenario('PROP_HUMAN_BBQ')
                    end
                end)
                RageUI.ButtonWithStyle("Position de Fouille", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('mini@prostitutes@sexlow_veh', 'low_car_bj_to_prop_female')
                    end
                end)
                RageUI.ButtonWithStyle("Prendre un selfie", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startScenario('world_human_tourist_mobile')
                    end
                end)
                RageUI.ButtonWithStyle("Ecouter à une porte", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('mini@safe_cracking', 'idle_base')
                    end
                end)
            end, function()
            end)

            RageUI.IsVisible(Mattitudes, true, true, true, function()
                RageUI.ButtonWithStyle("Normal M", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAttitude('move_m@confident', 'move_m@confident')
                    end
                end)
                RageUI.ButtonWithStyle("Normal F", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAttitude('move_f@heels@c', 'move_f@heels@c')
                    end
                end)
                RageUI.ButtonWithStyle("Depressif M", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAttitude('move_m@depressed@a', 'move_m@depressed@a')
                    end
                end)
                RageUI.ButtonWithStyle("Depressif F", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAttitude('move_f@depressed@a', 'move_f@depressed@a')
                    end
                end)
                RageUI.ButtonWithStyle("Business", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAttitude('move_m@business@a', 'move_m@business@a')
                    end
                end)
                RageUI.ButtonWithStyle("Determine", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAttitude('move_m@brave@a', 'move_m@brave@a')
                    end
                end)
                RageUI.ButtonWithStyle("Casual", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAttitude('move_m@casual@a', 'move_m@casual@a')
                    end
                end)
                RageUI.ButtonWithStyle("Trop mange", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAttitude('move_m@fat@a', 'move_m@fat@a')
                    end
                end)
                RageUI.ButtonWithStyle("Hipster", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAttitude('move_m@hipster@a', 'move_m@hipster@a')
                    end
                end)
                RageUI.ButtonWithStyle("Blesse", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAttitude('move_m@injured', 'move_m@injured')
                    end
                end)
                RageUI.ButtonWithStyle("Intimide", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAttitude('move_m@hurry@a', 'move_m@hurry@a')
                    end
                end)
                RageUI.ButtonWithStyle("Hobo", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAttitude('move_m@hobo@a', 'move_m@hobo@a')
                    end
                end)
                RageUI.ButtonWithStyle("Malheureux", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAttitude('move_m@sad@a', 'move_m@sad@a')
                    end
                end)
                RageUI.ButtonWithStyle("Muscle", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAttitude('move_m@muscle@a', 'move_m@muscle@a')
                    end
                end)
                RageUI.ButtonWithStyle("Choc", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAttitude('move_m@shocked@a', 'move_m@shocked@a')
                    end
                end)
                RageUI.ButtonWithStyle("Sombre", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAttitude('move_m@shadyped@a', 'move_m@shadyped@a')
                    end
                end)
                RageUI.ButtonWithStyle("Fatigue", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAttitude('move_m@buzzed', 'move_m@buzzed')
                    end
                end)
                RageUI.ButtonWithStyle("Pressee", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAttitude('move_m@hurry_butch@a', 'move_m@hurry_butch@a')
                    end
                end)
                RageUI.ButtonWithStyle("Fier", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAttitude('move_m@money', 'move_m@money')
                    end
                end)
                RageUI.ButtonWithStyle("Petite course", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAttitude('move_m@quick', 'move_m@quick')
                    end
                end)
                RageUI.ButtonWithStyle("Mangeuse d'homme", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAttitude('move_f@maneater', 'move_f@maneater')
                    end
                end)
                RageUI.ButtonWithStyle("Impertinent", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAttitude('move_f@sassy', 'move_f@sassy')
                    end
                end)
                RageUI.ButtonWithStyle("Arrogante", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAttitude('move_f@arrogant@a', 'move_f@arrogant@a')
                    end
                end)
            end, function()
            end)

            RageUI.IsVisible(Mpegi18, true, true, true, function()
                RageUI.ButtonWithStyle("Homme se faire su*** en voiture", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('oddjobs@towing', 'm_blow_job_loop')
                    end
                end)
                RageUI.ButtonWithStyle("Femme faire une gaterie en voiture", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('oddjobs@towing', 'f_blow_job_loop')
                    end
                end)
                RageUI.ButtonWithStyle("Homme bais** en voiture", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('mini@prostitutes@sexlow_veh', 'low_car_sex_loop_player')
                    end
                end)
                RageUI.ButtonWithStyle("Femme bais** en voiture", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('mini@prostitutes@sexlow_veh', 'low_car_sex_loop_female')
                    end
                end)
                RageUI.ButtonWithStyle("Se gratter les couilles", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('mp_player_int_uppergrab_crotch', 'mp_player_int_grab_crotch')
                    end
                end)
                RageUI.ButtonWithStyle("Faire du charme", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('mini@strip_club@idles@stripper', 'stripper_idle_02')
                    end
                end)
                RageUI.ButtonWithStyle("Pose michto", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startScenario('WORLD_HUMAN_PROSTITUTE_HIGH_CLASS')
                    end
                end)
                RageUI.ButtonWithStyle("Montrer sa poitrine", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('mini@strip_club@backroom@', 'stripper_b_backroom_idle_b')
                    end
                end)
                RageUI.ButtonWithStyle("Strip Tease 1", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('mini@strip_club@lap_dance@ld_girl_a_song_a_p1', 'ld_girl_a_song_a_p1_f')
                    end
                end)
                RageUI.ButtonWithStyle("Strip Tease 2", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('mini@strip_club@private_dance@part2', 'priv_dance_p2')
                    end
                end)
                RageUI.ButtonWithStyle("Stip Tease au sol", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        startAnim('mini@strip_club@private_dance@part3', 'priv_dance_p3')
                    end
                end)
            end, function()
            end) ---- Fin de tous les menu animations


            RageUI.IsVisible(Mgestveh, true, true, true, function()

                local Ped = GetPlayerPed(-1)
                local GetSourcevehicle = GetVehiclePedIsIn(Ped, false)
                local Vengine = GetVehicleEngineHealth(GetSourcevehicle)/10
                local Vengine = math.floor(Vengine)
                local VehPed = GetVehiclePedIsIn(PlayerPedId(), false)

                if IsPedSittingInAnyVehicle(PlayerPedId()) then
                    RageUI.Separator("Plaque d'immatriculation = ~b~"..GetVehicleNumberPlateText(VehPed).." ")
                else
                    RageUI.GoBack()
                end

                RageUI.Separator("Etat du moteur~s~ =~b~ "..Vengine.."%")
                
                RageUI.ButtonWithStyle("Allumer/Eteindre le Moteur", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        if IsPedSittingInAnyVehicle(PlayerPedId()) then
                            local plyVeh = GetVehiclePedIsIn(PlayerPedId(), false)
        
                            if GetIsVehicleEngineRunning(plyVeh) then
                                SetVehicleEngineOn(plyVeh, false, false, true)
                                SetVehicleUndriveable(plyVeh, true)
                            elseif not GetIsVehicleEngineRunning(plyVeh) then
                                SetVehicleEngineOn(plyVeh, true, false, true)
                                SetVehicleUndriveable(plyVeh, false)
                            end
                        else
                            ESX.ShowNotification("Vous n'êtes pas dans un véhicule")
                        end
                    end
                end)


                RageUI.List("Ouvrir/Fermer Porte", Rperso.DoorList, Rperso.DoorIndex, nil, {}, true, function(Hovered, Active, Selected, Index)
                    if (Selected) then
                        if IsPedSittingInAnyVehicle(PlayerPedId()) then
                            local plyVeh = GetVehiclePedIsIn(PlayerPedId(), false)
        
                            if Index == 1 then
                                if not Rperso.DoorState.FrontLeft then
                                    Rperso.DoorState.FrontLeft = true
                                    SetVehicleDoorOpen(plyVeh, 0, false, false)
                                elseif Rperso.DoorState.FrontLeft then
                                    Rperso.DoorState.FrontLeft = false
                                    SetVehicleDoorShut(plyVeh, 0, false, false)
                                end
                            elseif Index == 2 then
                                if not Rperso.DoorState.FrontRight then
                                    Rperso.DoorState.FrontRight = true
                                    SetVehicleDoorOpen(plyVeh, 1, false, false)
                                elseif Rperso.DoorState.FrontRight then
                                    Rperso.DoorState.FrontRight = false
                                    SetVehicleDoorShut(plyVeh, 1, false, false)
                                end
                            elseif Index == 3 then
                                if not Rperso.DoorState.BackLeft then
                                    Rperso.DoorState.BackLeft = true
                                    SetVehicleDoorOpen(plyVeh, 2, false, false)
                                elseif Rperso.DoorState.BackLeft then
                                    Rperso.DoorState.BackLeft = false
                                    SetVehicleDoorShut(plyVeh, 2, false, false)
                                end
                            elseif Index == 4 then
                                if not Rperso.DoorState.BackRight then
                                    Rperso.DoorState.BackRight = true
                                    SetVehicleDoorOpen(plyVeh, 3, false, false)
                                elseif Rperso.DoorState.BackRight then
                                    Rperso.DoorState.BackRight = false
                                    SetVehicleDoorShut(plyVeh, 3, false, false)
                                end
                            end
                        else
                            ESX.ShowNotification("Vous n'êtes pas dans un véhicule")
                        end
                    end
        
                    Rperso.DoorIndex = Index
                end)

                RageUI.ButtonWithStyle("Ouvrir/Fermer Capot", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        if IsPedSittingInAnyVehicle(PlayerPedId()) then
                            local plyVeh = GetVehiclePedIsIn(PlayerPedId(), false)
        
                            if not Rperso.DoorState.Hood then
                                Rperso.DoorState.Hood = true
                                SetVehicleDoorOpen(plyVeh, 4, false, false)
                            elseif Rperso.DoorState.Hood then
                                Rperso.DoorState.Hood = false
                                SetVehicleDoorShut(plyVeh, 4, false, false)
                            end
                        else
                            ESX.ShowNotification("Vous n'êtes pas dans un véhicule")
                        end
                    end
                end)

                RageUI.ButtonWithStyle("Ouvrir/Fermer Coffre", nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        if IsPedSittingInAnyVehicle(PlayerPedId()) then
                            local plyVeh = GetVehiclePedIsIn(PlayerPedId(), false)
        
                            if not Rperso.DoorState.Trunk then
                                Rperso.DoorState.Trunk = true
                                SetVehicleDoorOpen(plyVeh, 5, false, false)
                            elseif Rperso.DoorState.Trunk then
                                Rperso.DoorState.Trunk = false
                                SetVehicleDoorShut(plyVeh, 5, false, false)
                            end
                        else
                            ESX.ShowNotification("Vous n'êtes pas dans un véhicule")
                        end
                    end
                end)
            end, function()
            end)

            RageUI.IsVisible(Mgestentreprise, true, true, true, function()
            RageUI.Separator("~y~Societé : "..ESX.PlayerData.job.label.." - "..ESX.PlayerData.job.grade_label)
            if societymoney ~= nil then
                RageUI.Separator("~b~Coffre Entreprise : "..societymoney.." $")
            end

            RageUI.ButtonWithStyle('Recruter une personne', nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if (Selected) then
                    if ESX.PlayerData.job.grade_name == 'boss' then
                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
   
                        if closestPlayer == -1 or closestDistance > 3.0 then
                            ESX.ShowNotification('Aucun joueur proche')
                        else
                            TriggerServerEvent('rPersonalmenu:Boss_recruterplayer', GetPlayerServerId(closestPlayer))
                            --TriggerServerEvent('rPersonalmenu:Boss_recruterplayer', GetPlayerServerId(closestPlayer), ESX.PlayerData.job.name, 0)
                        end
                    else
                        ESX.ShowNotification('Vous n\'avez pas les ~r~droits~w~')
                    end
                end
            end)

            RageUI.ButtonWithStyle('Virer une personne', nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if (Selected) then
                    if ESX.PlayerData.job.grade_name == 'boss' then
                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
   
                        if closestPlayer == -1 or closestDistance > 3.0 then
                            ESX.ShowNotification('Aucun joueur proche')
                        else
                            TriggerServerEvent('rPersonalmenu:Boss_virerplayer', GetPlayerServerId(closestPlayer))
                        end
                    else
                        ESX.ShowNotification('Vous n\'avez pas les ~r~droits~w~')
                    end
                end
            end)

            RageUI.ButtonWithStyle('Promouvoir une personne', nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if (Selected) then
                     if ESX.PlayerData.job.grade_name == 'boss' then
                         local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    
                         if closestPlayer == -1 or closestDistance > 3.0 then
                             ESX.ShowNotification('Aucun joueur proche')
                         else
                             TriggerServerEvent('rPersonalmenu:Boss_promouvoirplayer', GetPlayerServerId(closestPlayer))
                     end
                     else
                         ESX.ShowNotification('Vous n\'avez pas les ~r~droits~w~')
                     end
                 end
             end)
    
             RageUI.ButtonWithStyle('Destituer une personne', nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                 if (Selected) then
                     if ESX.PlayerData.job.grade_name == 'boss' then
                         local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    
                         if closestPlayer == -1 or closestDistance > 3.0 then
                                 ESX.ShowNotification('Aucun joueur proche')
                             else
                            TriggerServerEvent('rPersonalmenu:Boss_destituerplayer', GetPlayerServerId(closestPlayer))
                                 end
                             else
                                 ESX.ShowNotification('Vous n\'avez pas les ~r~droits~w~')
                             end
                         end
                     end)

                     RageUI.ButtonWithStyle("Message aux employés", nil, {}, true, function(Hovered, Active, Selected)
                        if (Selected) then
                            local info = 'patron'
                            local message = rPersonalmenuKeyboardInput('Veuillez mettre le messsage à envoyer', '', 40)
                            TriggerServerEvent('rPersonalmenu:envoyeremployer', info, message)
                        end
                    end)

            end, function()
            end)

            RageUI.IsVisible(Mgestoraga, true, true, true, function()
                RageUI.Separator("~r~Oganisation : "..ESX.PlayerData.job2.label.." - "..ESX.PlayerData.job2.grade_label)
                if societymoney2 ~= nil then
                    RageUI.Separator("~y~Coffre Organisation : "..societymoney2.." $")
                end
    
                RageUI.ButtonWithStyle('Recruter une personne', nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        if ESX.PlayerData.job2.grade_name == 'boss' then
                            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
       
                            if closestPlayer == -1 or closestDistance > 3.0 then
                                ESX.ShowNotification('Aucun joueur proche')
                            else
                                TriggerServerEvent('rPersonalmenu:Boss_recruterplayer2', GetPlayerServerId(closestPlayer))
                               --TriggerServerEvent('rPersonalmenu:Boss_recruterplayer2', GetPlayerServerId(closestPlayer), ESX.PlayerData.job2.name, 0)
                            end
                        else
                            ESX.ShowNotification('Vous n\'avez pas les ~r~droits~w~')
                        end
                    end
                end)
    
                RageUI.ButtonWithStyle('Virer une personne', nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        if ESX.PlayerData.job2.grade_name == 'boss' then
                            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
       
                            if closestPlayer == -1 or closestDistance > 3.0 then
                                ESX.ShowNotification('Aucun joueur proche')
                            else
                                TriggerServerEvent('rPersonalmenu:Boss_virerplayer2', GetPlayerServerId(closestPlayer))
                            end
                        else
                            ESX.ShowNotification('Vous n\'avez pas les ~r~droits~w~')
                        end
                    end
                end)
    
                RageUI.ButtonWithStyle('Promouvoir une personne', nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                         if ESX.PlayerData.job2.grade_name == 'boss' then
                             local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
        
                             if closestPlayer == -1 or closestDistance > 3.0 then
                                 ESX.ShowNotification('Aucun joueur proche')
                             else
                                 TriggerServerEvent('rPersonalmenu:Boss_promouvoirplayer2', GetPlayerServerId(closestPlayer))
                         end
                         else
                             ESX.ShowNotification('Vous n\'avez pas les ~r~droits~w~')
                         end
                     end
                 end)
        
                 RageUI.ButtonWithStyle('Destituer une personne', nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                     if (Selected) then
                         if ESX.PlayerData.job2.grade_name == 'boss' then
                             local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
        
                             if closestPlayer == -1 or closestDistance > 3.0 then
                                     ESX.ShowNotification('Aucun joueur proche')
                                 else
                                TriggerServerEvent('rPersonalmenu:Boss_destituerplayer2', GetPlayerServerId(closestPlayer))
                                     end
                                 else
                                     ESX.ShowNotification('Vous n\'avez pas les ~r~droits~w~')
                                 end
                             end
                         end)
    
                end, function()
                end)

                RageUI.IsVisible(Mdivers, true, true, true, function()

                RageUI.Checkbox("Afficher / Désactiver la map", nil, Rperso.minimap,{},function(Hovered,Ative,Selected,Checked)
                    if Selected then
                        Rperso.minimap = Checked
                        if Checked then
                            DisplayRadar(true)
                        else
                            DisplayRadar(false)
                        end
                    end
                end)


                local ragdolling = false
                RageUI.ButtonWithStyle('Dormir / Se Reveiller', description, {RightLabel = "→"}, true, function(Hovered, Active, Selected) 
                    if (Selected) then
                        ragdolling = not ragdolling
                        while ragdolling do
                         Wait(0)
                        local myPed = GetPlayerPed(-1)
                        SetPedToRagdoll(myPed, 1000, 1000, 0, 0, 0, 0)
                        ResetPedRagdollTimer(myPed)
                        AddTextEntry(GetCurrentResourceName(), ('Appuyez sur ~INPUT_JUMP~ pour vous ~b~Réveillé'))
                        DisplayHelpTextThisFrame(GetCurrentResourceName(), false)
                        ResetPedRagdollTimer(myPed)
                        if IsControlJustPressed(0, 22) then 
                        break
                            end
                        end
                    end
                end)

                RageUI.ButtonWithStyle("Faire un tweet", nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
                    if (Selected) then
                        local tweetMessage = rPersonalmenuKeyboardInput("Message?", "", 100)
                        TriggerServerEvent('rPersonalmenu:addTweet', tweetMessage)
                    end
                end)

                RageUI.Checkbox("Afficher / Désactiver le mode cinématique", nil, Rperso.cinema,{},function(Hovered,Ative,Selected,Checked)
                    if Selected then
                        Rperso.cinema = Checked
                        if Checked then
                            SendNUIMessage({openCinema = true})
                            ESX.UI.HUD.SetDisplay(0.0)
                            TriggerEvent('es:setMoneyDisplay', 0.0)
                            TriggerEvent('esx_status:setDisplay', 0.0)
                            DisplayRadar(false)
                            TriggerEvent('ui:toggle', false)
                            TriggerEvent('ui:togglevoit', false)
					cinematique = true
                        else
                            SendNUIMessage({openCinema = false})
                            ESX.UI.HUD.SetDisplay(1.0)
                            TriggerEvent('es:setMoneyDisplay', 0.0)
                            TriggerEvent('esx_status:setDisplay', 1.0)
                            DisplayRadar(true)
                            TriggerEvent('ui:toggle', true)
                            TriggerEvent('ui:togglevoit', true)
                            cinematique = false
                        end
                    end
                end)
        
                end, function()
                end)
                RageUI.IsVisible(Mclef, true, true, true, function()

                    if #getCles >= 1 then

                    RageUI.Separator('~y~↓ Vos clés ↓')

                    for k, v in ipairs(getCles) do
                        RageUI.List("Clés Numéro : [~g~" .. v.id .. "~s~] - [~b~" .. v.value .. "~s~]",actionCles.select,actionCles.index,nil,{},true,function(Hovered, Active, Selected, Index)
                                if Selected then
                                    if Index == 1 then
                                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                                        if closestDistance ~= -1 and closestDistance <= 3 then
                                            TriggerServerEvent("esx_vehiclelock:preterkey", GetPlayerServerId(closestPlayer), v.value)
                                            RageUI.GoBack()
                                        else
                                            ESX.ShowNotification("Aucun ~b~individus~s~ près de vous.")
                                        end
                                    elseif Index == 2 then
                                        TriggerServerEvent("rPersonalmenu:DeleteKey", v.id)
                                        ESX.ShowNotification("- Clés ~r~détruite~s~\n- Plaque : ~y~" ..v.value .. "~s~\n- Numéro : ~g~" .. v.id)
                                        RageUI.GoBack()
                                    end
                                end
                                actionCles.index = Index
                            end)
                    end
                else
                    RageUI.Separator("")
                    RageUI.Separator("~r~Aucune paire de clés")
                    RageUI.Separator("")
                end

                end, function()
                end)

                RageUI.IsVisible(Madmin, true, true, true, function()

                    if playergroup == "admin" then
                        RageUI.Separator("~r~[Administrateur] ~s~~y~"..GetPlayerName(PlayerId()))
                    elseif playergroup == "superadmin" then
                        RageUI.Separator("~r~[SuperAdmin] ~s~~y~"..GetPlayerName(PlayerId()))
                    end

                    RageUI.ButtonWithStyle("Téléporter sur son marqueur", nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
                        if (Selected) then   
                            local playerPed = GetPlayerPed(-1)
                            local WaypointHandle = GetFirstBlipInfoId(8)
                            if DoesBlipExist(WaypointHandle) then
                                local coord = Citizen.InvokeNative(0xFA7C7F0AADF25D09, WaypointHandle, Citizen.ResultAsVector())
                                SetEntityCoordsNoOffset(playerPed, coord.x, coord.y, -199.9, false, false, false, true)
                            else
                                ESX.ShowNotification("~r~Marqueur Introuvable !")
                            end
                        end
                    end)

                    RageUI.ButtonWithStyle("Afficher/Cacher coordonnées", nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
                        if (Selected) then   
                            Rperso.Admin.showcoords = not Rperso.Admin.showcoords    
                        end
                    end)

                    RageUI.Checkbox("Noclip", nil, Rperso.Admin.NoClipP,{},function(Hovered,Ative,Selected,Checked)
                        if Selected then
                            Rperso.Admin.NoClipP = Checked
                            if Checked then
                                rPersoNoClip()
                            else
                                rPersoNoClip()
                            end
                        end
                    end)

                    RageUI.Checkbox("Invincible", description, Rperso.Admin.godmode,{},function(Hovered,Ative,Selected,Checked)
                        if (Selected) then       
                            Rperso.Admin.godmode = Checked
                            if Checked then
                                SetEntityInvincible(PlayerPedId(), true)
                                ESX.ShowNotification('Invicible ~g~ON')
                            else
                                SetEntityInvincible(PlayerPedId(), false)
                                ESX.ShowNotification('Invicible ~r~OFF')
                            end
                        end
                    end)

                    RageUI.Checkbox("Invisible", description, Rperso.Admin.fantomemode,{},function(Hovered,Ative,Selected,Checked)
                        if (Selected) then       
                            Rperso.Admin.fantomemode = Checked
                            if Checked then
                                invisible = true
                            else
                                invisible = false
                            end
                        end
                    end)

                    RageUI.Checkbox("Afficher id + noms", description, Rperso.Admin.affichername,{},function(Hovered,Ative,Selected,Checked)
                        if Selected then
                            Rperso.Admin.affichername = Checked
                            if Checked then
                                ShowName = true
                            else
                                ShowName = false
                            end
                        end
                    end)

                    RageUI.Separator('~y~ ↓ Give Argent ↓')

                    RageUI.ButtonWithStyle("Argent cash", nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
                        if (Selected) then   
                            GiveArgentCash()
                        end
                    end)
    
                    RageUI.ButtonWithStyle("Argent sale", nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
                        if (Selected) then   
                            GiveArgentSale()  
                        end   
                    end)
    
                    RageUI.ButtonWithStyle("Argent banque", nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
                        if (Selected) then   
                            GiveArgentBanque()  
                        end   
                    end)

                    RageUI.Separator('~r~ ↓ Véhicule ↓')

                    RageUI.ButtonWithStyle("Faire apparaître un véhicule", nil, {RightLabel =  "→"}, true, function(Hovered, Active, Selected)
                            if (Selected) then
                            local ModelName = rPersonalmenuKeyboardInput("Nom Du model?", "", 100)
            
                            if ModelName and IsModelValid(ModelName) and IsModelAVehicle(ModelName) then
                                RequestModel(ModelName)
                                while not HasModelLoaded(ModelName) do
                                    Citizen.Wait(0)
                                end
                                    local veh = CreateVehicle(GetHashKey(ModelName), GetEntityCoords(GetPlayerPed(-1)), GetEntityHeading(GetPlayerPed(-1)), true, true)
                                    TaskWarpPedIntoVehicle(GetPlayerPed(-1), veh, -1)
                                    Wait(50)
                            else
                                ESX.ShowNotification("Erreur !")
                            end
                        end
                    end)

                    RageUI.ButtonWithStyle("Réparer", nil, {RightLabel =  "→"}, true, function(Hovered, Active, Selected)
						if (Selected) then   
						local plyVeh = GetVehiclePedIsIn(PlayerPedId(), false)
					        SetVehicleFixed(plyVeh)
					        SetVehicleDirtLevel(plyVeh, 0.0) 
						end   
					end)
					
					RageUI.ButtonWithStyle("Custom au maximum", nil, {RightLabel =  "→"}, true, function(Hovered, Active, Selected)
						if (Selected) then   
						    FullVehicleBoost()
						end   
					end)

                    RageUI.ButtonWithStyle("Changer la plaque", nil, {RightLabel =  "→"}, true, function(_, Active, Selected)
                            if (Selected) then
                            if IsPedSittingInAnyVehicle(GetPlayerPed(-1)) then
                                local plaqueVehicule = rPersonalmenuKeyboardInput("Plaque", "", 8)
                                SetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(-1), false), plaqueVehicule)
                                ESX.ShowNotification("La plaque du véhicule est désormais : ~g~"..plaqueVehicule)
                            else
                                ESX.ShowNotification("~r~Erreur\n~s~Vous n'êtes pas dans un véhicule !")
                            end
                        end
                    end)

					RageUI.ButtonWithStyle("Mettre en Fourrière", nil, {RightLabel =  "→"}, true, function(_, Active, Selected)
                        if Selected then
                            local playerPed = PlayerPedId()
    
                            if IsPedSittingInAnyVehicle(playerPed) then
                                local vehicle = GetVehiclePedIsIn(playerPed, false)
                
                                if GetPedInVehicleSeat(vehicle, -1) == playerPed then
                                    ESX.ShowNotification('Le véhicule a été mis en fourrière.')
                                    ESX.Game.DeleteVehicle(vehicle)
                                   
                                else
                                    ESX.ShowNotification('Mettez vous place conducteur ou sortez de la voiture.')
                                end
                            else
                                local vehicle = ESX.Game.GetVehicleInDirection()
                
                                if DoesEntityExist(vehicle) then
                                    ClearPedTasks(playerPed)
                                    ESX.ShowNotification('Le véhicule à été placer en fourrière.')
                                    ESX.Game.DeleteVehicle(vehicle)
                
                                else
                                    ESX.ShowNotification('Aucune voitures autour')
                                end
                            end
                            end
                        end)

                end, function()
                end)
            if not RageUI.Visible(MPersonalmenu) and not RageUI.Visible(Minventaire) and not RageUI.Visible(Minventaire2) and not RageUI.Visible(Marmes) and not RageUI.Visible(Marmes2) and not RageUI.Visible(Mportefeuille) and not RageUI.Visible(Mportefeuilleli) and not RageUI.Visible(Mportefeuillesale) and not RageUI.Visible(Mfacture) and not RageUI.Visible(Mvetements) and not RageUI.Visible(Manimations) and not RageUI.Visible(Mfestives) and not RageUI.Visible(Msalutations) and not RageUI.Visible(Mtravail) and not RageUI.Visible(Mhumeurs) and not RageUI.Visible(Msports) and not RageUI.Visible(Mattitudes) and not RageUI.Visible(Mpegi18) and not RageUI.Visible(Manimationsdivers) and not RageUI.Visible(Mgestveh) and not RageUI.Visible(Mgestentreprise) and not RageUI.Visible(Mgestoraga) and not RageUI.Visible(Mdivers) and not RageUI.Visible(Madmin) and not RageUI.Visible(Mclef) then
            MPersonalmenu = RMenu:DeleteType("MPersonalmenu", true)
        end
    end
end

Citizen.CreateThread(function()
    while true do
        local Timer = 0
        if IsControlJustPressed(1,166) then
            ESX.TriggerServerCallback('rPersonalmenu:facture', function(bills)
                Rperso.factures = bills
                gPersonalmenu()
            end)
        end

        if IsControlJustReleased(0, 73) and IsInputDisabled(2) then
			ClearPedTasks(PlayerPedId())
		end
        
        Citizen.Wait(Timer)
    end
end)

function RefreshCles()
    getCles = {}
    ESX.TriggerServerCallback("rPersonalmenu:clevoiture", function(cles)
            for k, v in pairs(cles) do
                table.insert(getCles, {id = v.id, label = v.label, value = v.value})
            end
        end)
end

--- Animations

function startAttitude(lib, anim)
	ESX.Streaming.RequestAnimSet(lib, function()
		SetPedMovementClipset(PlayerPedId(), anim, true)
	end)
end

function startAnim(lib, anim)
	ESX.Streaming.RequestAnimDict(lib, function()
		TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0.0, false, false, false)
	end)
end

function startScenario(anim)
	TaskStartScenarioInPlace(PlayerPedId(), anim, 0, false)
end


---


RegisterNetEvent('rPersonalmenu:envoyeremployer')
AddEventHandler('rPersonalmenu:envoyeremployer', function(service, nom, message)
	if service == 'patron' then
		PlaySoundFrontend(-1, "Start_Squelch", "CB_RADIO_SFX", 1)
		ESX.ShowAdvancedNotification('INFO '..ESX.PlayerData.job.label, '~b~A lire', 'Patron: ~g~'..nom..'\n~w~Message: ~g~'..message..'', 'CHAR_MINOTAUR', 8)
		Wait(1000)
		PlaySoundFrontend(-1, "End_Squelch", "CB_RADIO_SFX", 1)	
	end
end)


-- pour les Vétements Mettre/Enlever

RegisterNetEvent('rPersonalmenu:actionhaut')
AddEventHandler('rPersonalmenu:actionhaut', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skina)
        TriggerEvent('skinchanger:getSkin', function(skinb)
            local lib, anim = 'clothingtie', 'try_tie_neutral_a'
            ESX.Streaming.RequestAnimDict(lib, function()
                TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
            end)
            Citizen.Wait(1000)
            ClearPedTasks(PlayerPedId())

            if skina.torso_1 ~= skinb.torso_1 then
                vethaut = true
                TriggerEvent('skinchanger:loadClothes', skinb, {['torso_1'] = skina.torso_1, ['torso_2'] = skina.torso_2, ['tshirt_1'] = skina.tshirt_1, ['tshirt_2'] = skina.tshirt_2, ['arms'] = skina.arms})
            else
                TriggerEvent('skinchanger:loadClothes', skinb, {['torso_1'] = 15, ['torso_2'] = 0, ['tshirt_1'] = 15, ['tshirt_2'] = 0, ['arms'] = 15})
                vethaut = false
            end
        end)
    end)
end)

RegisterNetEvent('rPersonalmenu:actionpantalon')
AddEventHandler('rPersonalmenu:actionpantalon', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skina)
        TriggerEvent('skinchanger:getSkin', function(skinb)
            local lib, anim = 'clothingtrousers', 'try_trousers_neutral_c'

            ESX.Streaming.RequestAnimDict(lib, function()
                TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
            end)
            Citizen.Wait(1000)
            ClearPedTasks(PlayerPedId())

            if skina.pants_1 ~= skinb.pants_1 then
                TriggerEvent('skinchanger:loadClothes', skinb, {['pants_1'] = skina.pants_1, ['pants_2'] = skina.pants_2})
                vetbas = true
            else
                vetbas = false
                if skina.sex == 1 then
                    TriggerEvent('skinchanger:loadClothes', skinb, {['pants_1'] = 15, ['pants_2'] = 0})
                else
                    TriggerEvent('skinchanger:loadClothes', skinb, {['pants_1'] = 61, ['pants_2'] = 1})
                end
            end
        end)
    end)
end)


RegisterNetEvent('rPersonalmenu:actionchaussure')
AddEventHandler('rPersonalmenu:actionchaussure', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skina)
        TriggerEvent('skinchanger:getSkin', function(skinb)
            local lib, anim = 'clothingshoes', 'try_shoes_positive_a'
            ESX.Streaming.RequestAnimDict(lib, function()
                TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
            end)
            Citizen.Wait(1000)
            ClearPedTasks(PlayerPedId())
            if skina.shoes_1 ~= skinb.shoes_1 then
                TriggerEvent('skinchanger:loadClothes', skinb, {['shoes_1'] = skina.shoes_1, ['shoes_2'] = skina.shoes_2})
                vetch = true
            else
                vetch = false
                if skina.sex == 1 then
                    TriggerEvent('skinchanger:loadClothes', skinb, {['shoes_1'] = 35, ['shoes_2'] = 0})
                else
                    TriggerEvent('skinchanger:loadClothes', skinb, {['shoes_1'] = 34, ['shoes_2'] = 0})
                end
            end
        end)
    end)
end)

RegisterNetEvent('rPersonalmenu:actionsac')
AddEventHandler('rPersonalmenu:actionsac', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skina)
        TriggerEvent('skinchanger:getSkin', function(skinb)
            local lib, anim = 'clothingtie', 'try_tie_neutral_a'
            ESX.Streaming.RequestAnimDict(lib, function()
                TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
            end)
            Citizen.Wait(1000)
            ClearPedTasks(PlayerPedId())
            if skina.bags_1 ~= skinb.bags_1 then
                TriggerEvent('skinchanger:loadClothes', skinb, {['bags_1'] = skina.bags_1, ['bags_2'] = skina.bags_2})
                vetsac = true
            else
                TriggerEvent('skinchanger:loadClothes', skinb, {['bags_1'] = 0, ['bags_2'] = 0})
                vetsac = false
            end
        end)
    end)
end)


RegisterNetEvent('rPersonalmenu:actiongiletparballe')
AddEventHandler('rPersonalmenu:actiongiletparballe', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skina)
        TriggerEvent('skinchanger:getSkin', function(skinb)
            local lib, anim = 'clothingtie', 'try_tie_neutral_a'
            ESX.Streaming.RequestAnimDict(lib, function()
                TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
            end)
            Citizen.Wait(1000)
            ClearPedTasks(PlayerPedId())
            if skina.bproof_1 ~= skinb.bproof_1 then
                TriggerEvent('skinchanger:loadClothes', skinb, {['bproof_1'] = skina.bproof_1, ['bproof_2'] = skina.bproof_2})
                vetgilet = true
            else
                TriggerEvent('skinchanger:loadClothes', skinb, {['bproof_1'] = 0, ['bproof_2'] = 0})
                vetgilet = false
            end
        end)
    end)
end)

RegisterNetEvent('rPersonalmenu:masque')
AddEventHandler('rPersonalmenu:masque', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skina)
        TriggerEvent('skinchanger:getSkin', function(skinb)
            local lib, anim = 'clothingtie', 'try_tie_neutral_a'
            ESX.Streaming.RequestAnimDict(lib, function()
                TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
            end)
            Citizen.Wait(1000)
            ClearPedTasks(PlayerPedId())
            if skina.mask_1 ~= skinb.mask_1 then
                TriggerEvent('skinchanger:loadClothes', skinb, {['mask_1'] = skina.mask_1, ['mask_2'] = skina.mask_2})
                vetmask = true
            else
                TriggerEvent('skinchanger:loadClothes', skinb, {['mask_1'] = 0, ['mask_2'] = 0})
                vetmask = false
            end
        end)
    end)
end)

-- Admin

local MainColor = {
	r = 225, 
	g = 55, 
	b = 55,
	a = 255
}

Citizen.CreateThread(function()
    while true do
    	if Rperso.Admin.showcoords then
            x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1),true))
            roundx=tonumber(string.format("%.2f",x))
            roundy=tonumber(string.format("%.2f",y))
            roundz=tonumber(string.format("%.2f",z))
            DrawTxt("~r~X:~s~ "..roundx,0.05,0.00)
            DrawTxt("     ~r~Y:~s~ "..roundy,0.11,0.00)
            DrawTxt("        ~r~Z:~s~ "..roundz,0.17,0.00)
            DrawTxt("             ~r~Angle:~s~ "..GetEntityHeading(PlayerPedId()),0.21,0.00)
        end
        if invisible then
            SetEntityVisible(GetPlayerPed(-1), 0, 0)
            NetworkSetEntityInvisibleToNetwork(GetPlayerPed(-1), 1)
        else
            SetEntityVisible(GetPlayerPed(-1), 1, 0)
            NetworkSetEntityInvisibleToNetwork(GetPlayerPed(-1), 0)
        end
    	Citizen.Wait(0)
    end
end)

--DrawTxt
function DrawTxt(text,r,z)
    SetTextColour(MainColor.r, MainColor.g, MainColor.b, 255)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(0.0,0.4)
    SetTextDropshadow(1,0,0,0,255)
    SetTextEdge(1,0,0,0,255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(r,z)
end


--NoClip
local noclip = false
local noclip_speed = 1.0

function rPersoNoClip()
  noclip = not noclip
  local ped = GetPlayerPed(-1)
  if noclip then -- activé
    SetEntityInvincible(ped, true)
	SetEntityVisible(ped, false, false)
	invisible = true
	ESX.ShowNotification("Noclip ~g~activé")
  else -- désactivé
    SetEntityInvincible(ped, false)
	SetEntityVisible(ped, true, false)
	invisible = false
	ESX.ShowNotification("Noclip ~r~désactivé")
  end
end

function getPosition()
    local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1),true))
    return x,y,z
  end
  
  function getCamDirection()
    local heading = GetGameplayCamRelativeHeading()+GetEntityHeading(GetPlayerPed(-1))
    local pitch = GetGameplayCamRelativePitch()
  
    local x = -math.sin(heading*math.pi/180.0)
    local y = math.cos(heading*math.pi/180.0)
    local z = math.sin(pitch*math.pi/180.0)
  
    local len = math.sqrt(x*x+y*y+z*z)
    if len ~= 0 then
      x = x/len
      y = y/len
      z = z/len
    end
  
    return x,y,z
end

Citizen.CreateThread(function()
    while true do
        local Timer = 500
        if noclip then
        local ped = GetPlayerPed(-1)
        local x,y,z = getPosition()
        local dx,dy,dz = getCamDirection()
        local speed = noclip_speed
    
        -- reset du velocity
        SetEntityVelocity(ped, 0.0001, 0.0001, 0.0001)
        Timer = 0  
        -- aller vers le haut
        if IsControlPressed(0,32) then -- MOVE UP
            x = x+speed*dx
            y = y+speed*dy
            z = z+speed*dz
        end
    
        -- aller vers le bas
        if IsControlPressed(0,269) then -- MOVE DOWN
            x = x-speed*dx
            y = y-speed*dy
            z = z-speed*dz
        end
    
        SetEntityCoordsNoOffset(ped,x,y,z,true,true,true)
        end
        Citizen.Wait(Timer)
    end
end)

--Argent cash
function GiveArgentCash()
	local amount = rPersonalmenuKeyboardInput("Combien?", "", 8)

	if amount ~= nil then
		amount = tonumber(amount)
		
		if type(amount) == 'number' then
			TriggerServerEvent('rPersonalmenu:GiveArgentCash', amount)
            ESX.ShowNotification("~g~Give argent cash effectué~w~ "..amount.." €")
		end
	end
end

 --Argent sale
function GiveArgentSale()
	local amount = rPersonalmenuKeyboardInput("Combien?", "", 8)

	if amount ~= nil then
		amount = tonumber(amount)
		
		if type(amount) == 'number' then
			TriggerServerEvent('rPersonalmenu:GiveArgentSale', amount)
            ESX.ShowNotification("~g~Give argent sale effectué~w~ "..amount.." €")
		end
	end
end

 --Argent banque
function GiveArgentBanque()
	local amount = rPersonalmenuKeyboardInput("Combien?", "", 8)

	if amount ~= nil then
		amount = tonumber(amount)
		
		if type(amount) == 'number' then
			TriggerServerEvent('rPersonalmenu:GiveArgentBanque', amount)
            ESX.ShowNotification("~g~Give argent banque effectué~w~ "..amount.." €")
		end
	end
end

--Custom véhicule
function FullVehicleBoost()
	if IsPedInAnyVehicle(PlayerPedId(), false) then
		local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
		SetVehicleModKit(vehicle, 0)
		SetVehicleMod(vehicle, 14, 0, true)
		SetVehicleNumberPlateTextIndex(vehicle, 5)
		ToggleVehicleMod(vehicle, 18, true)
		SetVehicleColours(vehicle, 0, 0)
		SetVehicleCustomPrimaryColour(vehicle, 0, 0, 0)
		SetVehicleModColor_2(vehicle, 5, 0)
		SetVehicleExtraColours(vehicle, 111, 111)
		SetVehicleWindowTint(vehicle, 2)
		ToggleVehicleMod(vehicle, 22, true)
		SetVehicleMod(vehicle, 23, 11, false)
		SetVehicleMod(vehicle, 24, 11, false)
		SetVehicleWheelType(vehicle, 12) 
		SetVehicleWindowTint(vehicle, 3)
		ToggleVehicleMod(vehicle, 20, true)
		SetVehicleTyreSmokeColor(vehicle, 0, 0, 0)
		LowerConvertibleRoof(vehicle, true)
		SetVehicleIsStolen(vehicle, false)
		SetVehicleIsWanted(vehicle, false)
		SetVehicleHasBeenOwnedByPlayer(vehicle, true)
		SetVehicleNeedsToBeHotwired(vehicle, false)
		SetCanResprayVehicle(vehicle, true)
		SetPlayersLastVehicle(vehicle)
		SetVehicleFixed(vehicle)
		SetVehicleDeformationFixed(vehicle)
		SetVehicleTyresCanBurst(vehicle, false)
		SetVehicleWheelsCanBreak(vehicle, false)
		SetVehicleCanBeTargetted(vehicle, false)
		SetVehicleExplodesOnHighExplosionDamage(vehicle, false)
		SetVehicleHasStrongAxles(vehicle, true)
		SetVehicleDirtLevel(vehicle, 0)
		SetVehicleCanBeVisiblyDamaged(vehicle, false)
		IsVehicleDriveable(vehicle, true)
		SetVehicleEngineOn(vehicle, true, true)
		SetVehicleStrong(vehicle, true)
		RollDownWindow(vehicle, 0)
		RollDownWindow(vehicle, 1)
		SetVehicleNeonLightEnabled(vehicle, 0, true)
		SetVehicleNeonLightEnabled(vehicle, 1, true)
		SetVehicleNeonLightEnabled(vehicle, 2, true)
		SetVehicleNeonLightEnabled(vehicle, 3, true)
		SetVehicleNeonLightsColour(vehicle, 0, 0, 255)
		SetPedCanBeDraggedOut(PlayerPedId(), false)
		SetPedStayInVehicleWhenJacked(PlayerPedId(), true)
		SetPedRagdollOnCollision(PlayerPedId(), false)
		ResetPedVisibleDamage(PlayerPedId())
		ClearPedDecorations(PlayerPedId())
		SetIgnoreLowPriorityShockingEvents(PlayerPedId(), true)
		for i = 0,14 do
			SetVehicleExtra(veh, i, 0)
		end
		SetVehicleModKit(veh, 0)
		for i = 0,49 do
			local custom = GetNumVehicleMods(veh, i)
			for j = 1,custom do
				SetVehicleMod(veh, i, math.random(1,j), 1)
			end
		end
	end
end
