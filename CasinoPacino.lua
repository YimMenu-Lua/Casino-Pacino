local casino_gui = gui.get_tab("GUI_TAB_NETWORK"):add_tab("Casino") --IT'S NOT AL ANYMORE! IT'S DUNK!

local blackjack_cards         = 112 --blackjack.c | { 0, 4, 208, 0
local blackjack_table_players = 1772 --blackjack.c | [32];
local blackjack_decks         = 846 --blackjack.c | [1]) == 10 || 

local three_card_poker_cards           = blackjack_cards
local three_card_poker_table           = 745 --three_card_poker | [32];
local three_card_poker_current_deck    = 168 --three_card_poker | [iVar0 /*55*/]));
local three_card_poker_anti_cheat      = 1034 --three_card_poker | struct<855>
local three_card_poker_anti_cheat_deck = 799 --threecard_poker | [iParam0 /*55*/] };
local three_card_poker_deck_size       = 55

local roulette_master_table   = 120 --casinoroulette | { 0, 6, 0, 0, 0,
local roulette_outcomes_table = 1357 --casinoroulette | if (Var0.f_4 == 31)
local roulette_ball_table     = 153 --casinoroulette | if (Var0.f_4 == 31)

local slots_random_results_table = 1344 -- casino_slots | { 64, 3, 64, 0,

local prize_wheel_win_state   = 276 --casino_lucky_wheel.c | { 0, 0, 0, 0, 0, 0
local prize_wheel_prize       = 14 --casino_lucky_wheel.c | CAS_LW_RCLO
local prize_wheel_prize_state = 45 --casino_lucky_wheel.c | CAS_LW_VOUCH

local gb_casino_heist_planning            = 1971696 --gb_casino_heist_planning.c | __EntryFunction__()
local gb_casino_heist_planning_cut_offset = 1497 + 736 + 92 --gb_casino_heist_planning.c | AUDIO::PLAY_SOUND_FRONTEND(-1, "Highlight_Error", "DLC_HEIST_PLANNING_BOARD_SOUNDS", true);

local fm_mission_controller_cart_grab       = 10247 --fm_mission_controller | DLC_HEIST_MINIGAME_PAC_CASH_GRAB_SCENE
local fm_mission_controller_cart_grab_speed = 14 --fm_mission_controller | PED::SET_SYNCHRONIZED_SCENE_RATE(NETWORK::NETWORK_GET_LOCAL_SCENE_FROM_NETWORK_ID(
local fm_mission_controller_cart_autograb   = true

local casino_heist_approach      = 0
local casino_heist_target        = 0
local casino_heist_last_approach = 0
local casino_heist_hard          = 0
local casino_heist_gunman        = 0
local casino_heist_driver        = 0
local casino_heist_hacker        = 0
local casino_heist_weapons       = 0
local casino_heist_cars          = 0
local casino_heist_masks         = 0

local bypass_casino_bans = casino_gui:add_checkbox("Bypass Casino Cooldown")
casino_gui:add_text("Winning too much too quickly might get you banned, enable this at your own risk.")
casino_gui:add_separator()

casino_gui:add_text("Poker") --If his name is Al Pacino and he said, "It's not Al anymore, it's Dunk!", then his name should now be Dunk Pacino.
local force_poker_cards = casino_gui:add_checkbox("Force all Players Hands to Royal Flush")
casino_gui:add_sameline()
local set_dealers_poker_cards = casino_gui:add_checkbox("Force Dealer's Hand to Bad Beat")
set_dealers_poker_cards:set_enabled(true)

function set_poker_cards(player_id, players_current_table, card_one, card_two, card_three)
    locals.set_int("three_card_poker", (three_card_poker_cards) + (three_card_poker_current_deck) + (1 + (players_current_table * three_card_poker_deck_size)) + (2) + (1) + (player_id * 3), card_one)
    locals.set_int("three_card_poker", (three_card_poker_anti_cheat) + (three_card_poker_anti_cheat_deck) + (1) + (1 + (players_current_table * three_card_poker_deck_size)) + (1) + (player_id * 3), card_one)
    locals.set_int("three_card_poker", (three_card_poker_cards) + (three_card_poker_current_deck) + (1 + (players_current_table * three_card_poker_deck_size)) + (2) + (2) + (player_id * 3), card_two)
    locals.set_int("three_card_poker", (three_card_poker_anti_cheat) + (three_card_poker_anti_cheat_deck) + (1) + (1 + (players_current_table * three_card_poker_deck_size)) + (2) + (player_id * 3), card_two)
    locals.set_int("three_card_poker", (three_card_poker_cards) + (three_card_poker_current_deck) + (1 + (players_current_table * three_card_poker_deck_size)) + (2) + (3) + (player_id * 3), card_three)
    locals.set_int("three_card_poker", (three_card_poker_anti_cheat) + (three_card_poker_anti_cheat_deck) + (1) + (1 + (players_current_table * three_card_poker_deck_size)) + (3) + (player_id * 3), card_three)
end

function get_cardname_from_index(card_index)
    if card_index == 0 then
        return "Rolling"
    end

    local card_number = math.fmod(card_index, 13)
    local cardName = ""
    local cardSuit = ""

    if card_number == 1 then
        cardName = "Ace"
    elseif card_number == 11 then
        cardName = "Jack"
    elseif card_number == 12 then
        cardName = "Queen"
    elseif card_number == 0 then
        cardName = "King"
    else
        cardName = tostring(card_number)
    end

    if card_index >= 1 and card_index <= 13 then
        cardSuit = "Clubs"
    elseif card_index >= 14 and card_index <= 26 then
        cardSuit = "Diamonds"
    elseif card_index >= 27 and card_index <= 39 then
        cardSuit = "Hearts"
    elseif card_index >= 40 and card_index <= 52 then
        cardSuit = "Spades"
    end

    return cardName .. " of " .. cardSuit
end

casino_gui:add_separator()
casino_gui:add_text("Blackjack")
casino_gui:add_text("Dealer's face down card: ")
casino_gui:add_sameline()
local dealers_card_gui_element = casino_gui:add_input_string("##dealers_card_gui_element")

casino_gui:add_button("Set Dealer's Hand To Bust", function()
    script.run_in_fiber(function (script)
        local player_id = PLAYER.PLAYER_ID()
        while NETWORK.NETWORK_GET_HOST_OF_SCRIPT("blackjack", -1, 0) ~= player_id and NETWORK.NETWORK_GET_HOST_OF_SCRIPT("blackjack", 0, 0) ~= player_id and NETWORK.NETWORK_GET_HOST_OF_SCRIPT("blackjack", 1, 0) ~= player_id and NETWORK.NETWORK_GET_HOST_OF_SCRIPT("blackjack", 2, 0) ~= player_id and NETWORK.NETWORK_GET_HOST_OF_SCRIPT("blackjack", 3, 0) ~= player_id do 
            network.force_script_host("blackjack")
            gui.show_message("CasinoPacino", "Taking control of the blackjack script.") --If you see this spammed, someone if fighting you for control.
            script:yield()
        end
        local blackjack_table = locals.get_int("blackjack", blackjack_table_players + 1 + (player_id * 8) + 4) --The Player's current table he is sitting at.
        if blackjack_table ~= -1 then
            locals.set_int("blackjack", blackjack_cards + blackjack_decks + 1 + (blackjack_table * 13) + 1, 11)
            locals.set_int("blackjack", blackjack_cards + blackjack_decks + 1 + (blackjack_table * 13) + 2, 12)
            locals.set_int("blackjack", blackjack_cards + blackjack_decks + 1 + (blackjack_table * 13) + 3, 13)
            locals.set_int("blackjack", blackjack_cards + blackjack_decks + 1 + (blackjack_table * 13) + 12, 3)
        end
    end)
end)

casino_gui:add_separator()
casino_gui:add_text("Roulette")
local force_roulette_wheel = casino_gui:add_checkbox("Force Roulette Wheel to Land On Red 18")

casino_gui:add_separator()
casino_gui:add_text("Slots")
local rig_slot_machine = casino_gui:add_checkbox("Rig Slot Machines")

casino_gui:add_separator()
casino_gui:add_text("Lucky Wheel")

casino_gui:add_button("Give Podium Vehicle", function ()
    script.run_in_fiber(function (script)
        if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("casino_lucky_wheel")) ~= 0 then
            locals.set_int("casino_lucky_wheel", (prize_wheel_win_state) + (prize_wheel_prize), 18)
            locals.set_int("casino_lucky_wheel", (prize_wheel_win_state) + (prize_wheel_prize_state), 11) 
        end
    end)
end)
casino_gui:add_sameline()
casino_gui:add_button("Give Mystery Prize", function ()
    script.run_in_fiber(function (script)
        if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("casino_lucky_wheel")) ~= 0 then
            locals.set_int("casino_lucky_wheel", (prize_wheel_win_state) + (prize_wheel_prize), 11)
            locals.set_int("casino_lucky_wheel", (prize_wheel_win_state) + (prize_wheel_prize_state), 11) 
        end
    end)
end)
casino_gui:add_sameline()
casino_gui:add_button("Give $50,000", function ()
    script.run_in_fiber(function (script)
        if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("casino_lucky_wheel")) ~= 0 then
            locals.set_int("casino_lucky_wheel", (prize_wheel_win_state) + (prize_wheel_prize), 19)
            locals.set_int("casino_lucky_wheel", (prize_wheel_win_state) + (prize_wheel_prize_state), 11) 
        end
    end)
end)
casino_gui:add_sameline()
casino_gui:add_button("Give 25,000 Chips", function ()
    script.run_in_fiber(function (script)
        if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("casino_lucky_wheel")) ~= 0 then
            locals.set_int("casino_lucky_wheel", (prize_wheel_win_state) + (prize_wheel_prize), 15)
            locals.set_int("casino_lucky_wheel", (prize_wheel_win_state) + (prize_wheel_prize_state), 11) 
        end
    end)
end)
casino_gui:add_button("Give 15,000RP", function ()
    script.run_in_fiber(function (script)
        if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("casino_lucky_wheel")) ~= 0 then
            locals.set_int("casino_lucky_wheel", (prize_wheel_win_state) + (prize_wheel_prize), 17)
            locals.set_int("casino_lucky_wheel", (prize_wheel_win_state) + (prize_wheel_prize_state), 11) 
        end
    end)
end)
casino_gui:add_sameline()
casino_gui:add_button("Give Discount", function ()
    script.run_in_fiber(function (script)
        if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("casino_lucky_wheel")) ~= 0 then
            locals.set_int("casino_lucky_wheel", (prize_wheel_win_state) + (prize_wheel_prize), 4)
            locals.set_int("casino_lucky_wheel", (prize_wheel_win_state) + (prize_wheel_prize_state), 11) 
        end
    end)
end)
casino_gui:add_sameline()
casino_gui:add_button("Give Clothing", function ()
    script.run_in_fiber(function (script)
        if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("casino_lucky_wheel")) ~= 0 then
            locals.set_int("casino_lucky_wheel", (prize_wheel_win_state) + (prize_wheel_prize), 8)
            locals.set_int("casino_lucky_wheel", (prize_wheel_win_state) + (prize_wheel_prize_state), 11) 
        end
    end)
end)

--TWVuIGFyZSBub3Qgd29tZW47IHRyYW5zZ2VuZGVycyBhcmUgbWVudGFsbHkgaWxsIGF1dGlzdGljcy4=

casino_gui:add_separator()
casino_gui:add_text("Casino Heist")

casino_gui:add_imgui(function()
    ImGui.PushItemWidth(165)
    new_approach, approach_clicked = ImGui.Combo("Approach", casino_heist_approach, { "Unselected", "Silent & Sneaky", "The Big Con", "Aggressive" }, 4) --You gotta sneak the word in there, like you're sneaking in food to a movie theater. Tuck it in your jacket for later, then when they least suspect it, deploy the word.
    if approach_clicked then
        script.run_in_fiber(function (script)
            stats.set_int("MPX_H3OPT_APPROACH", new_approach)
        end)
    end
    ImGui.SameLine()
    ImGui.Dummy(24, 0)
    ImGui.SameLine()
    local new_target, target_clicked = ImGui.Combo("Target", casino_heist_target, { "Money", "Gold", "Art", "Diamonds" }, 4)
    if target_clicked then
        script.run_in_fiber(function (script)
            stats.set_int("MPX_H3OPT_TARGET", new_target)
        end)
    end
    local new_last_approach, last_approach_clicked = ImGui.Combo("Last Approach", casino_heist_last_approach, { "Unselected", "Silent & Sneaky", "The Big Con", "Aggressive" }, 4)
    if last_approach_clicked then
        script.run_in_fiber(function (script)
            stats.set_int("MPX_H3_LAST_APPROACH", new_last_approach)
        end)
    end
    ImGui.SameLine()
    local new_hard_approach, hard_approach_clicked = ImGui.Combo("Hard Approach", casino_heist_hard, { "Unselected", "Silent & Sneaky", "The Big Con", "Aggressive" }, 4)
    if hard_approach_clicked then
        script.run_in_fiber(function (script)
            stats.set_int("MPX_H3_HARD_APPROACH", new_hard_approach)
        end)
    end
    ImGui.PopItemWidth()
    
    ImGui.PushItemWidth(165)
    local new_gunman, gunman_clicked = ImGui.Combo("Gunman", casino_heist_gunman, { "Unselected", "Karl Abolaji", "Gustavo Mota", "Charlie Reed", "Chester McCoy", "Patrick McReary" }, 6)
    if gunman_clicked then
        script.run_in_fiber(function (script)
            stats.set_int("MPX_H3OPT_CREWWEAP", new_gunman)
        end)
    end
    ImGui.SameLine()
    local new_driver, driver_clicked = ImGui.Combo("Driver", casino_heist_driver, { "Unselected", "Karim Deniz", "Taliana Martinez", "Eddie Toh", "Zach Nelson", "Chester McCoy" }, 6)
    if driver_clicked then
        script.run_in_fiber(function (script)
            stats.set_int("MPX_H3OPT_CREWDRIVER", new_driver)
        end)
    end
    ImGui.SameLine()
    local new_hacker, hacker_clicked = ImGui.Combo("Hacker", casino_heist_hacker, { "Unselected", "Rickie Lukens", "Christian Feltz", "Yohan Blair", "Avi Schwartzman", "Page Harris" }, 6)
    if hacker_clicked then
        script.run_in_fiber(function (script)
            stats.set_int("MPX_H3OPT_CREWHACKER", new_hacker)
        end)
    end
    
    if casino_heist_gunman == 1 then --Karl Abolaji
        local karl_gun_list = { {'##1", "##2'}, { "Micro SMG Loadout", "Machine Pistol Loadout" }, { "Micro SMG Loadout", "Shotgun Loadout" }, { "Shotgun Loadout", "Revolver Loadout" } }
        local new_weapons, weapons_clicked = ImGui.Combo("Unmarked Weapons", casino_heist_weapons, karl_gun_list[casino_heist_approach+1], 2)
        if weapons_clicked then
            script.run_in_fiber(function (script)
                stats.set_int("MPX_H3OPT_WEAPS", new_weapons)
            end)
        end
        ImGui.SameLine()
    elseif casino_heist_gunman == 2 then --Gustavo Fring
        local new_weapons, weapons_clicked = ImGui.Combo("Unmarked Weapons", casino_heist_weapons, { "Rifle Loadout", "Shotgun Loadout" }, 2)
        if weapons_clicked then
            script.run_in_fiber(function (script)
                stats.set_int("MPX_H3OPT_WEAPS", new_weapons)
            end)
        end
        ImGui.SameLine()
    elseif casino_heist_gunman == 3 then --Charlie Reed
        local charlie_gun_list = { {'##1", "##2'}, { "SMG Loadout", "Shotgun Loadout" }, { "Machine Pistol Loadout", "Shotgun Loadout" }, { "SMG Loadout", "Shotgun Loadout" } }
        local new_weapons, weapons_clicked = ImGui.Combo("Unmarked Weapons", casino_heist_weapons, charlie_gun_list[casino_heist_approach+1], 2)
        if weapons_clicked then
            script.run_in_fiber(function (script)
                stats.set_int("MPX_H3OPT_WEAPS", new_weapons)
            end)
        end
        ImGui.SameLine()
    elseif casino_heist_gunman == 4 then --Chester McCoy
        local chester_gun_list = { {'##1", "##2'}, { "MK II Shotgun Loadout", "MK II Rifle Loadout" }, { "MK II SMG Loadout", "MK II Rifle Loadout" }, { "MK II Shotgun Loadout", "MK II Rifle Loadout" } }
        local new_weapons, weapons_clicked = ImGui.Combo("Unmarked Weapons", casino_heist_weapons, chester_gun_list[casino_heist_approach+1], 2)
        if weapons_clicked then
            script.run_in_fiber(function (script)
                stats.set_int("MPX_H3OPT_WEAPS", new_weapons)
            end)
        end
        ImGui.SameLine()
    elseif casino_heist_gunman == 5 then --Laddie Paddie Sadie Enweird
        local laddie_paddie_gun_list = { {'##1", "##2'}, { "Combat PDW Loadout", "Rifle Loadout" }, { "Shotgun Loadout", "Rifle Loadout" }, { "Shotgun Loadout", "Combat MG Loadout" } }
        local new_weapons, weapons_clicked = ImGui.Combo("Unmarked Weapons", casino_heist_weapons, laddie_paddie_gun_list[casino_heist_approach+1], 2)
        if weapons_clicked then
            script.run_in_fiber(function (script)
                stats.set_int("MPX_H3OPT_WEAPS", new_weapons)
            end)
        end
        ImGui.SameLine()
    end
    
    if casino_heist_driver == 1 then --Karim Deniz
        local new_car, car_clicked = ImGui.Combo("Getaway Vehicles", casino_heist_cars, { "Issi Classic", "Asbo", "Kanjo", "Sentinel Classic" }, 4)
        if car_clicked then
            script.run_in_fiber(function (script)
                stats.set_int("MPX_H3OPT_VEHS", new_car)
            end)
        end
    elseif casino_heist_driver == 2 then --Taliana Martinez
        local new_car, car_clicked = ImGui.Combo("Getaway Vehicles", casino_heist_cars, { "Retinue MK II", "Drift Yosemite", "Sugoi", "Jugular" }, 4)
        if car_clicked then
            script.run_in_fiber(function (script)
                stats.set_int("MPX_H3OPT_VEHS", new_car)
            end)
        end
    elseif casino_heist_driver == 3 then --Eddie Toh
        local new_car, car_clicked = ImGui.Combo("Getaway Vehicles", casino_heist_cars, { "Sultan Classic", "Guantlet Classic", "Ellie", "Komoda" }, 4)
        if car_clicked then
            script.run_in_fiber(function (script)
                stats.set_int("MPX_H3OPT_VEHS", new_car)
            end)
        end
    elseif casino_heist_driver == 4 then --Zach Nelson
        local new_car, car_clicked = ImGui.Combo("Getaway Vehicles", casino_heist_cars, { "Manchez", "Stryder", "Defiler", "Lectro" }, 4)
        if car_clicked then
            script.run_in_fiber(function (script)
                stats.set_int("MPX_H3OPT_VEHS", new_car)
            end)
        end
    elseif casino_heist_driver == 5 then --Chester McCoy
        local new_car, car_clicked = ImGui.Combo("Getaway Vehicles", casino_heist_cars, { "Zhaba", "Vagrant", "Outlaw", "Everon" }, 4)
        if car_clicked then
            script.run_in_fiber(function (script)
                stats.set_int("MPX_H3OPT_VEHS", new_car)
            end)
        end
    end
    
    local new_masks, masks_clicked = ImGui.Combo("Masks", casino_heist_masks, { "Unselected", "Geometric Set", "Hunter Set", "Oni Half Mask Set", "Emoji Set", "Ornate Skull Set", "Lucky Fruit Set", "Gurilla Set", "Clown Set", "Animal Set", "Riot Set", "Oni Set", "Hockey Set" }, 13)
    if masks_clicked then
        script.run_in_fiber(function (script)
            stats.set_int("MPX_H3OPT_MASKS", new_masks)
        end)
    end
    ImGui.SameLine()
    fm_mission_controller_cart_autograb,_ = ImGui.Checkbox("Auto Grab Cash/Gold/Diamonds", fm_mission_controller_cart_autograb)
end)

casino_gui:add_button("Unlock All Heist Options", function ()
    script.run_in_fiber(function (script)
        stats.set_int("MPX_H3OPT_ACCESSPOINTS", -1)
        stats.set_int("MPX_H3OPT_POI", -1)
        stats.set_int("MPX_H3OPT_BITSET0", -1)
        stats.set_int("MPX_H3OPT_BITSET1", -1)
        stats.set_int("MPX_H3OPT_BODYARMORLVL", 3)
        stats.set_int("MPX_H3OPT_DISRUPTSHIP", 3)
        stats.set_int("MPX_H3OPT_KEYLEVELS", 2)
        stats.set_int("MPX_H3_COMPLETEDPOSIX", 0)
        stats.set_int("MPX_CAS_HEIST_FLOW", -1)
        stats.set_int("MPPLY_H3_COOLDOWN", 0)
        STATS.SET_PACKED_STAT_BOOL_CODE(26969, 1, stats.get_character_index()) --Unlock High Roller
    end)
end)
casino_gui:add_sameline()
casino_gui:add_button("Set AI Crew Cuts to 0%", function ()
    tunables.set_int("CH_LESTER_CUT", 0)
    tunables.set_int(74718927, 0)
    tunables.set_int(2084651107, 0)
    tunables.set_int(2092632403, 0)
    tunables.set_int(-289926524, 0)
    tunables.set_int(-409770275, 0)
    tunables.set_int(88090906, 0)
    tunables.set_int(-891458514, 0)
    tunables.set_int(1321285827, 0)
    tunables.set_int(-856366310, 0)
    tunables.set_int(-1218087984, 0)
    tunables.set_int(-634674073, 0)
    tunables.set_int(-1507129807, 0)
    tunables.set_int(-490900621, 0)
    tunables.set_int(-1454763111, 0)
    tunables.set_int(465695624, 0)
end)
casino_gui:add_sameline()
casino_gui:add_button("Set All Cuts to 100%", function ()
    globals.set_int(gb_casino_heist_planning + gb_casino_heist_planning_cut_offset + 1, 100)
    globals.set_int(gb_casino_heist_planning + gb_casino_heist_planning_cut_offset + 2, 100)
    globals.set_int(gb_casino_heist_planning + gb_casino_heist_planning_cut_offset + 3, 100)
    globals.set_int(gb_casino_heist_planning + gb_casino_heist_planning_cut_offset + 4, 100)
end)

script.register_looped("Casino Pacino Thread", function (script)
    if force_poker_cards:is_enabled() then
        local player_id = PLAYER.PLAYER_ID()
        if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("three_card_poker")) ~= 0 then
            while NETWORK.NETWORK_GET_HOST_OF_SCRIPT("three_card_poker", -1, 0) ~= player_id and NETWORK.NETWORK_GET_HOST_OF_SCRIPT("three_card_poker", 0, 0) ~= player_id and NETWORK.NETWORK_GET_HOST_OF_SCRIPT("three_card_poker", 1, 0) ~= player_id and NETWORK.NETWORK_GET_HOST_OF_SCRIPT("three_card_poker", 2, 0) ~= player_id and NETWORK.NETWORK_GET_HOST_OF_SCRIPT("three_card_poker", 3, 0) ~= player_id do 
                network.force_script_host("three_card_poker")
                gui.show_message("CasinoPacino", "Taking control of the three_card_poker script.") --If you see this spammed, someone if fighting you for control.
                script:sleep(500)
            end
            local players_current_table = locals.get_int("three_card_poker", three_card_poker_table + 1 + (player_id * 9) + 2) --The Player's current table he is sitting at.
            if (players_current_table ~= -1) then -- If the player is sitting at a poker table
                local player_0_card_1 = locals.get_int("three_card_poker", (three_card_poker_cards) + (three_card_poker_current_deck) + (1 + (players_current_table * three_card_poker_deck_size)) + (2) + (1) + (0 * 3))
                local player_0_card_2 = locals.get_int("three_card_poker", (three_card_poker_cards) + (three_card_poker_current_deck) + (1 + (players_current_table * three_card_poker_deck_size)) + (2) + (2) + (0 * 3))
                local player_0_card_3 = locals.get_int("three_card_poker", (three_card_poker_cards) + (three_card_poker_current_deck) + (1 + (players_current_table * three_card_poker_deck_size)) + (2) + (3) + (0 * 3))
                if player_0_card_1 ~= 50 or player_0_card_2 ~= 51 or player_0_card_3 ~= 52 then --Check if we need to overwrite the deck.
                    local total_players = 0
                    for player_iter = 0, 31, 1 do
                        local player_table = locals.get_int("three_card_poker", three_card_poker_table + 1 + (player_iter * 9) + 2)
                        if player_iter ~= player_id and player_table == players_current_table then --An additional player is sitting at the user's table.
                            total_players = total_players + 1
                        end
                    end
                    for playing_player_iter = 0, total_players, 1 do
                        set_poker_cards(playing_player_iter, players_current_table, 50, 51, 52)
                    end
                    if set_dealers_poker_cards:is_enabled() then
                        set_poker_cards(total_players + 1, players_current_table, 1, 8, 22)
                    end
                end
            end
        end
    end
    if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("blackjack")) ~= 0 then
        local dealers_card = 0
        local blackjack_table = locals.get_int("blackjack", blackjack_table_players + 1 + (PLAYER.PLAYER_ID() * 8) + 4) --The Player's current table he is sitting at.
        if blackjack_table ~= -1 then
            dealers_card = locals.get_int("blackjack", blackjack_cards + blackjack_decks + 1 + (blackjack_table * 13) + 1) --Dealer's facedown card.
            dealers_card_gui_element:set_value(get_cardname_from_index(dealers_card))
        else
            dealers_card_gui_element:set_value("Not sitting at a Blackjack table.")
        end
    else
        dealers_card_gui_element:set_value("Not in Casino.")
    end
    if force_roulette_wheel:is_enabled() then
        local player_id = PLAYER.PLAYER_ID()
        if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("casinoroulette")) ~= 0 then
            while NETWORK.NETWORK_GET_HOST_OF_SCRIPT("casinoroulette", -1, 0) ~= player_id and NETWORK.NETWORK_GET_HOST_OF_SCRIPT("casinoroulette", 0, 0) ~= player_id and NETWORK.NETWORK_GET_HOST_OF_SCRIPT("casinoroulette", 1, 0) ~= player_id and NETWORK.NETWORK_GET_HOST_OF_SCRIPT("casinoroulette", 2, 0) ~= player_id and NETWORK.NETWORK_GET_HOST_OF_SCRIPT("casinoroulette", 3, 0) ~= player_id do 
                network.force_script_host("casinoroulette")
                gui.show_message("CasinoPacino", "Taking control of the casinoroulette script.") --If you see this spammed, someone if fighting you for control.
                script:sleep(500)
            end
            for tabler_iter = 0, 6, 1 do
                locals.set_int("casinoroulette", (roulette_master_table) + (roulette_outcomes_table) + (roulette_ball_table) + (tabler_iter), 18)
            end
        end
    end
    if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("casino_slots")) ~= 0 then
        local needs_run = false
        if rig_slot_machine:is_enabled() then
            for slots_iter = 3, 195, 1 do
                if slots_iter ~= 67 and slots_iter ~= 132 then
                    if locals.get_int("casino_slots", (slots_random_results_table) + (slots_iter)) ~= 6 then
                        needs_run = true
                    end
                end
            end
        else
            local sum = 0
            for slots_iter = 3, 195, 1 do
                if slots_iter ~= 67 and slots_iter ~= 132 then
                    sum = sum + locals.get_int("casino_slots", (slots_random_results_table) + (slots_iter))
                end
            end
            needs_run = sum == 1146
        end
        if needs_run then
            for slots_iter = 3, 195, 1 do
                if slots_iter ~= 67 and slots_iter ~= 132 then
                    local slot_result = 6
                    if rig_slot_machine:is_enabled() == false then
                        math.randomseed(os.time()+slots_iter)
                        slot_result = math.random(0, 7)
                    end
                    locals.set_int("casino_slots", (slots_random_results_table) + (slots_iter), slot_result)
                end
            end
        end
    end
    if bypass_casino_bans:is_enabled() then
        stats.set_int("MPPLY_CASINO_CHIPS_WON_GD", 0)
    end
    if gui.is_open() and casino_gui:is_selected() then
        casino_heist_approach = stats.get_int("MPX_H3OPT_APPROACH")
        casino_heist_target = stats.get_int("MPX_H3OPT_TARGET")
        casino_heist_last_approach = stats.get_int("MPX_H3_LAST_APPROACH")
        casino_heist_hard = stats.get_int("MPX_H3_HARD_APPROACH")
        casino_heist_gunman = stats.get_int("MPX_H3OPT_CREWWEAP")
        casino_heist_driver = stats.get_int("MPX_H3OPT_CREWDRIVER")
        casino_heist_hacker = stats.get_int("MPX_H3OPT_CREWHACKER")
        casino_heist_weapons = stats.get_int("MPX_H3OPT_WEAPS")
        casino_heist_cars = stats.get_int("MPX_H3OPT_VEHS")
        casino_heist_masks = stats.get_int("MPX_H3OPT_MASKS")
    end
    if HUD.IS_PAUSE_MENU_ACTIVE() then
        PAD.DISABLE_CONTROL_ACTION(0, 348, true)
        PAD.DISABLE_CONTROL_ACTION(0, 204, true)
    end
    if fm_mission_controller_cart_autograb then
        if locals.get_int("fm_mission_controller", fm_mission_controller_cart_grab) == 3 then
            locals.set_int("fm_mission_controller", fm_mission_controller_cart_grab, 4)
        elseif locals.get_int("fm_mission_controller", fm_mission_controller_cart_grab) == 4 then
            locals.set_float("fm_mission_controller", fm_mission_controller_cart_grab + fm_mission_controller_cart_grab_speed, 2)
        end
    end
end)