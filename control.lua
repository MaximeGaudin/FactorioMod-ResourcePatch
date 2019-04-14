local inspect = require("includes.inspect")

local size_map = {
    tiny = 5,
    small = 10,
    medium = 30,
    big = 60,
    huge = 100,
    colossal = 500,
}

local type_map = {
    oil = "crude-oil",
    coal = "coal",
    stone = "stone",
    iron = "iron-ore",
    copper = "copper-ore",
    uranium = "uranium-ore",
    water = "water",
    wood = "tree-09"
}

function get_keys(t)
    local keyset = {}

    for k, v in pairs(t) do
        table.insert(keyset, k)
    end

    return keyset
end

function message(mes)
    game.player.print(mes)
end

function check_size_parameter(size)
    if size_map[size] == nil then
        message("Size '" .. size .. "' is invalid, please use one of the following : " .. inspect(get_keys(size_map)))
        return false
    end

    return true
end

function check_type_parameter(type)
    if type_map[type] == nil then
        message("Type '" .. type .. "' is invalid, please use one of the following : " .. inspect(get_keys(type_map)))
        return false
    end

    return true
end

function clear(from_position, size)
    local int_size = size_map[size]

    local entities = game.player.surface.find_entities({
        { from_position.x + 1, from_position.y - int_size },
        { from_position.x + int_size + 1, from_position.y }
    })

    for _, entity in pairs(entities) do
        entity.destroy()
    end

    spawn_land_patch(from_position, size)
end

function spawn_regular_patch(from_position, type, size)
    local int_size = size_map[size]

    for x = 1, int_size do
        for y = 1, int_size do
            game.player.surface.create_entity {
                name = type_map[type],
                position = { from_position.x + x, from_position.y - y },
                amount = 4294967295
            }
        end
    end
end

function spawn_land_patch(from_position, size)
    local int_size = size_map[size]
    local tiles = {}
    for x = 1, int_size do
        for y = 1, int_size do
            table.insert(
                    tiles,
                    {
                        name = game.player.surface.get_tile(from_position.x, from_position.y).name,
                        position = { from_position.x + x, from_position.y - y }
                    }
            )
        end
    end
    game.player.surface.set_tiles(tiles)
end

function spawn_water_patch(from_position, size)
    local int_size = size_map[size]
    local tiles = {}
    for x = 1, int_size do
        for y = 1, int_size do
            table.insert(
                    tiles,
                    {
                        name = "water",
                        position = { from_position.x + x, from_position.y - y }
                    }
            )
        end
    end
    game.player.surface.set_tiles(tiles)
end

function spawn_patch(from_position, type, size)
    clear(from_position, size)

    if type == "water" then
        spawn_water_patch(from_position, size)
        return
    end

    spawn_regular_patch(from_position, type, size)
end

commands.add_command("spawn_patch", "Spawn resource patch : spawn_patch [size] [type] ", function(event)
    local parameters_string = event["parameter"]
    if not string.match(parameters_string, " ") then
        game.players[event.player_index].print("Two parameters required : [size] and [type]")
        return
    end

    local parameters = {}
    for parameter in string.gmatch(parameters_string, "%w+") do
        table.insert(parameters, parameter)
    end

    if not check_size_parameter(parameters[1]) then
        return
    end

    if not check_type_parameter(parameters[2]) then
        return
    end

    spawn_patch(game.player.position, parameters[2], parameters[1])
end)

commands.add_command("clear_patch", "Clear resource patch : clear_patch [size]", function(event)
    local parameters_string = event["parameter"]
    if parameters_string == nil or parameters_string == "" then
        game.players[event.player_index].print("One parameter required : [size]")
        return
    end

    if not check_size_parameter(parameters_string) then
        return
    end

    clear(game.player.position, parameters_string)
end)

commands.add_command("create_start_patches", "All you need to start fast !", function(event)
    local position = game.player.position
    local size = "small"
    local int_size = size_map[size]
    local offset = 2

    spawn_patch(position, "water", size)
    spawn_patch({ x = position.x, y = position.y + int_size + offset }, "wood", size)
    position.x = position.x + int_size + offset

    spawn_patch(position, "coal", size)
    spawn_patch({ x = position.x, y = position.y + int_size + offset }, "stone", size)
    position.x = position.x + int_size + offset

    spawn_patch(position, "iron", size)
    spawn_patch({ x = position.x, y = position.y + int_size + offset }, "copper", size)
end)