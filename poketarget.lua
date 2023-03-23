_addon.version = '0.1.0'
_addon.name = 'poketarget'
_addon.author = 'yyoshisaur'
_addon.commands = {'poketarget','pta'}

require('luau')
require('sendall')

local packets = require('packets')

local default_delay = 0.5
local send_all_order_mode = 'melast' -- melast, mefirst, alphabetical
local participants = T{}

local current_command = nil
local PLAYER_STATUS_EVENT = 4
local DIK_MAP = {
    [0x01] = 'escape',
    [0x1C] = 'enter',
    [0xC8] = 'up',
    [0xCB] = 'left',
    [0xCD] = 'right',
    [0xD0] = 'down',
}
local key_sync = true

local function order_participants(participants, order_mode)
    local player = windower.ffxi.get_mob_by_target('me').name
    if order_mode ~= 'alphabetical' then
        participants:delete(player)
    end
    table.sort(participants)
    if order_mode == 'melast' then
        participants:append(player)
    elseif order_mode == 'mefirst' then
        participants = T{player}:extend(participants)
    end
    return participants
end

local function get_party_members(local_members)
    local members = T{}
    for k, v in pairs(windower.ffxi.get_party()) do
        if type(v) == 'table' then
            if local_members:contains(v.name) then
                members:append(v.name)
            end
        end
    end

    return members
end

local function poke_npc(npc)

    if npc and math.sqrt(npc.distance) < 6 then
        local p = packets.new('outgoing', 0x01A, {
            ["Target"] = npc.id,
            ["Target Index"] = npc.index,
            ["Category"] = 0
        })
    
        packets.inject(p)
        -- log('[ '..npc.name..' ] ID:'..npc.id..' Index:'..npc.index)
    else
        error(npc.name..' found, but too far!')
    end
end

-- msg :
--     "id 123456"
--     "key 123 1" 1:down, 0:up
function receive_send_all(msg)
    -- print('received send cmd '..msg)
    local args = msg:split(' ')
    local cmd = args[1]
    if cmd == 'id' then
        if args[2] then
            local id = tonumber(args[2])
            if id == nil then
                return
            end

            local target = windower.ffxi.get_mob_by_id(id)
            if target and target.spawn_type  == 0x02 then
                poke_npc(target)
            else
                error('No NPC found!')
            end
        end
    elseif cmd == 'key' then
        if args[2] and args[3] then
            local key = DIK_MAP[tonumber(args[2])]
            local key_state = (tonumber(args[3]) == 1) and 'down' or 'up'

            if S{'up', 'down', 'left', 'right'}:contains(key) then
                local key_con_cmd = 'setkey '..key..' '..key_state
                windower.send_command(key_con_cmd)
            elseif S{'enter', 'escape'}:contains(key) and key_state == 'down' then
                local key_con_cmd = 'setkey '..key..' down; wait 0.3; '..'setkey '..key..' up;'
                windower.send_command(key_con_cmd)
            end
        end
    end
end

-- @all @party
windower.register_event('addon command', function (...)
    local args = T{...}
    local send_cmd = nil

    participants:clear()

    if args[1] then 
        if S{'all','a','@all'}:contains(args[1]:lower()) then
            args:remove(1) 
            participants = get_participants()
            current_command = 'all'
        elseif S{'party','p','@party'}:contains(args[1]:lower()) then
            args:remove(1) 
            participants = get_party_members(get_participants())
            current_command = 'party'
        end
    end

    participants = order_participants(participants, send_all_order_mode)

    if args[1] then
        if args[1]:find("^%d+$") then
            send_cmd = 'id '..args[1]
            send_all(send_cmd, default_delay, participants)
        else
            error('invalid argment.')
        end
    else
        local target = windower.ffxi.get_mob_by_target('t')
        if target then
            send_cmd = 'id '..target.id
            send_all(send_cmd, default_delay, participants)
        else
            error('invalid target.')
        end
    end
end)

windower.register_event('keyboard', function (dik, pressed, flags, blocked)
    local player = windower.ffxi.get_mob_by_target('me')

    if key_sync and S{'all', 'party'}:contains(current_command) and player and player.status == PLAYER_STATUS_EVENT then
          if DIK_MAP[dik] then
            local send_cmd = 'key '..dik..' '..(pressed and 1 or 0) 
            participants:delete(player.name)
            send_all(send_cmd, 0, participants)
         end
    end
end)

windower.register_event('status change', function (new_status_id, old_status_id)
    if new_status_id == PLAYER_STATUS_EVENT then
        -- pass
    elseif old_status_id == PLAYER_STATUS_EVENT then
        current_command = nil
    end
end)