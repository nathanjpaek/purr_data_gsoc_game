local cat_ai = pd.Class:new():register("cat_ai")

math.randomseed(os.time())



function table.indexOf(t, value)
    for i, v in ipairs(t) do
        if v == value then
            return i
        end
    end
    return nil
end



function table.contains(t, value)
    for _, v in ipairs(t) do
        if v == value then
            return true
        end
    end
    return false
end



function valid_moves(arr)
    local moves = {}
    local n = math.floor(math.sqrt(#arr))
    local cat_idx = table.indexOf(arr, 6)
    
    if not cat_idx then
        pd.post("cat not found in the array")
        return moves
    end
    
    local cat_i, cat_j = (cat_idx - 1) % n, math.floor((cat_idx - 1) / n)
    local directions = {
        {0, 0, -1},  -- North
        {1, 1, cat_i % 2 == 0 and -1 or 0},  -- Northeast
        {2, 1, cat_i % 2 == 0 and 0 or 1},  -- Southeast
        {3, 0, 1},  -- South
        {4, -1, cat_i % 2 == 0 and 0 or 1},  -- Southwest
        {5, -1, cat_i % 2 == 0 and -1 or 0}  -- Northwest
    }

    for _, dir in ipairs(directions) do
        local direction, di, dj = table.unpack(dir)
        local new_i, new_j = cat_i + di, cat_j + dj
        if new_i >= 0 and new_i < n and new_j >= 0 and new_j < n then
            local new_idx = new_j * n + new_i + 1
            if arr[new_idx] == 0 then
                table.insert(moves, direction)
            end
        end
    end
    return moves
end



function is_terminal(arr)
    local n = math.floor(math.sqrt(#arr))
    local cat_idx = table.indexOf(arr, 6)
    if not cat_idx then
        pd.post("cat not found in the array")
        return true
    end
    local cat_i, cat_j = (cat_idx - 1) % n, math.floor((cat_idx - 1) / n)
    return cat_i == 0 or cat_i == n-1 or cat_j == 0 or cat_j == n-1 or #valid_moves(arr) == 0
end



Game = {}
Game.__index = Game

function Game.new(arr)
    local self = setmetatable({}, Game)
    self.arr = arr
    self.size = math.floor(math.sqrt(#arr))
    self.reached_maxdepth = false
    return self
end



function Game:get_direction(move)
    local cat_idx = table.indexOf(self.arr, 6)
    if not cat_idx then
        pd.post("cat not found in the array")
        return {0, 0}
    end
    local cat_i = (cat_idx - 1) % self.size
    local directions = {
        {0, -1},  -- North
        {1, cat_i % 2 == 0 and -1 or 0},  -- Northeast
        {1, cat_i % 2 == 0 and 0 or 1},  -- Southeast
        {0, 1},  -- South
        {-1, cat_i % 2 == 0 and 0 or 1},  -- Southwest
        {-1, cat_i % 2 == 0 and -1 or 0}  -- Northwest
    }
    return directions[move + 1]
end



function Game:apply_move(move, maximizing_player)
    local n = self.size
    local cat_idx = table.indexOf(self.arr, 6)
    if not cat_idx then
        pd.post("Error: Cat (value 6) not found in the array")
        return
    end
    local cat_i, cat_j = (cat_idx - 1) % n, math.floor((cat_idx - 1) / n)
    local di, dj = table.unpack(self:get_direction(move))
    local new_i, new_j = cat_i + di, cat_j + dj
    local new_idx = new_j * n + new_i + 1
    local new_arr = {table.unpack(self.arr)}
    if maximizing_player then
        new_arr[cat_idx], new_arr[new_idx] = 0, 6
    else
        new_arr[new_idx] = 1
    end
    self.arr = new_arr
end



function Game:score_proximity(maximizing_player_turn)
    local distances = {100, 100}
    local cat_moves = valid_moves(self.arr)
    local cat_idx = table.indexOf(self.arr, 6)
    if not cat_idx then
        pd.post("cat not found in the array")
        return 0
    end
    local cat_i, cat_j = (cat_idx - 1) % self.size, math.floor((cat_idx - 1) / self.size)

    for _, move in ipairs(cat_moves) do
        local dist = 0
        local i, j = cat_i, cat_j
        local di, dj = table.unpack(self:get_direction(move))
        while true do
            dist = dist + 1
            i, j = i + di, j + dj
            if i < 0 or i >= self.size or j < 0 or j >= self.size then
                break
            end
            if self.arr[j * self.size + i + 1] ~= 0 then
                dist = dist * 5
                break
            end
        end
        table.insert(distances, dist)
    end
    table.sort(distances)
    return self.size * 2 - (maximizing_player_turn and distances[1] or distances[2])
end



function Game:count_open_paths()
    local n = self.size
    local cat_idx = table.indexOf(self.arr, 6)
    if not cat_idx then
        pd.post("cat not found in the array")
        return 0
    end
    local cat_i, cat_j = (cat_idx - 1) % n, math.floor((cat_idx - 1) / n)
    local directions = {{0, -1}, {1, -1}, {1, 0}, {0, 1}, {-1, 0}, {-1, -1}}
    local open_paths = 0

    for _, dir in ipairs(directions) do
        local di, dj = table.unpack(dir)
        local i, j = cat_i, cat_j
        while i >= 0 and i < n and j >= 0 and j < n do
            if self.arr[j * n + i + 1] ~= 0 and self.arr[j * n + i + 1] ~= 6 then
                break
            end
            if i == 0 or i == n-1 or j == 0 or j == n-1 then
                open_paths = open_paths + 1
                break
            end
            i, j = i + di, j + dj
        end
    end

    return open_paths
end



--###################

function Game:bfs_to_edge()
    local n = self.size
    local cat_idx = table.indexOf(self.arr, 6)
    if not cat_idx then
        pd.post("Error: Cat (value 6) not found in the array")
        return n * n  -- return max possible distance if cat not found
    end
    local start_i, start_j = (cat_idx - 1) % n, math.floor((cat_idx - 1) / n)
    
    local queue = {{start_i, start_j, 0}}  -- {i, j, distance}
    local visited = {}
    
    while #queue > 0 do
        local i, j, dist = table.unpack(table.remove(queue, 1))
        
        if i == 0 or i == n-1 or j == 0 or j == n-1 then
            return dist  -- return distance to edge when we reach it
        end
        
        local key = i * n + j
        if not visited[key] and self.arr[j * n + i + 1] ~= 1 then
            visited[key] = true
            local directions = {{0, -1}, {1, -1}, {1, 0}, {0, 1}, {-1, 0}, {-1, -1}}
            for _, dir in ipairs(directions) do
                local di, dj = table.unpack(dir)
                local new_i, new_j = i + di, j + dj
                if new_i >= 0 and new_i < n and new_j >= 0 and new_j < n then
                    table.insert(queue, {new_i, new_j, dist + 1})
                end
            end
        end
    end
    
    return n * n
end


function Game:evaluate()
    local n = self.size
    local cat_idx = table.indexOf(self.arr, 6)
    if not cat_idx then
        pd.post("cat not found in the array")
        return 0
    end
    local cat_i, cat_j = (cat_idx - 1) % n, math.floor((cat_idx - 1) / n)

    if cat_i == 0 or cat_i == n-1 or cat_j == 0 or cat_j == n-1 then
        return -10000000  -- cat wins, so this is very bad for the blocker
    end
    if #valid_moves(self.arr) == 0 then
        return 10000000  -- cat is trapped, so this is very good for the blocker
    end

    local score = 0

    -- proximity score
    local proximity_score = self:score_proximity(false)
    score = score - proximity_score * 500  -- negative because lower score is better for the cat

    -- distance from edges
    local edge_distance = math.min(cat_i, cat_j, n-1-cat_i, n-1-cat_j)
    score = score - edge_distance * 480  -- cat prefers to be closer to edges

    -- open paths to edges
    local open_paths = self:count_open_paths()
    score = score - open_paths * 300  -- more open paths is better for the cat

    -- center control
    local center = math.floor(n / 2)
    local distance_from_center = math.max(math.abs(cat_i - center), math.abs(cat_j - center))
    score = score + distance_from_center * 1450  -- cat prefers to be closer to the edges
    --1390 GOOD

    -- mobility
    local mobility = #valid_moves(self.arr)
    score = score - mobility * 14 -- more moves available is better for the cat

    -- BFS distance to edge
    local bfs_distance = self:bfs_to_edge()
    score = score - (n - bfs_distance) * 1997  -- cat prefers shorter paths to the edge

    -- reward 1 tile away
    local edge_proximity_bonus = 0
    if edge_distance == 1 then
        edge_proximity_bonus = -7500
    end
    score = score + edge_proximity_bonus

    return score
end

--###################



function Game:order_moves(moves)
    local n = self.size
    local cat_idx = table.indexOf(self.arr, 6)
    if not cat_idx then
        pd.post("Error: Cat (value 6) not found in the array")
        return moves
    end
    local cat_i, cat_j = (cat_idx - 1) % n, math.floor((cat_idx - 1) / n)
    
    local function move_score(move)
        local di, dj = table.unpack(self:get_direction(move))
        local new_i, new_j = cat_i + di, cat_j + dj
        return -math.min(new_i, new_j, n-1-new_i, n-1-new_j)
    end
    
    table.sort(moves, function(a, b) return move_score(a) > move_score(b) end)
    return moves
end



function Game:ab_max_Value(upper_game, move, alpha, beta, maximizing_player, depth, maxdepth)
    local game = Game.new({table.unpack(upper_game.arr)})
    if move ~= nil and move ~= -1 then
        maximizing_player = not maximizing_player
        game:apply_move(move, maximizing_player)
    end
    
    local legal_moves = valid_moves(game.arr)
    if #legal_moves == 0 or depth == maxdepth then
        if depth == maxdepth then
            self.reached_maxdepth = true
        end
        return nil, game:evaluate()
    end
    local v = -math.huge
    local best_moves = {}
    for _, s in ipairs(self:order_moves(legal_moves)) do
        local _, vtemp = game:ab_min_Value(game, s, alpha, beta, maximizing_player, depth + 1, maxdepth)
        if v < vtemp then
            v = vtemp
            best_moves = {s}
        elseif v == vtemp then
            table.insert(best_moves, s)
        end
        if v >= beta then
            return best_moves[math.random(#best_moves)], v
        end
        alpha = math.max(alpha, v)
    end
    return best_moves[math.random(#best_moves)], v
end



function Game:ab_min_Value(upper_game, move, alpha, beta, maximizing_player, depth, maxdepth)
    local game = Game.new({table.unpack(upper_game.arr)})
    maximizing_player = not maximizing_player
    game:apply_move(move, maximizing_player)
    
    if depth == maxdepth or is_terminal(game.arr) then
        if depth == maxdepth then
            self.reached_maxdepth = true
        end
        return nil, game:evaluate()
    end
    local v = math.huge
    local best_moves = {}
    for _, s in ipairs(self:order_moves(valid_moves(game.arr))) do
        local _, temp = game:ab_max_Value(game, s, alpha, beta, maximizing_player, depth + 1, maxdepth)
        if v > temp then
            v = temp
            best_moves = {s}
        elseif v == temp then
            table.insert(best_moves, s)
        end
        if v <= alpha then
            return best_moves[math.random(#best_moves)], v
        end
        beta = math.min(beta, v)
    end
    return best_moves[math.random(#best_moves)], v
end



function Game:alphabeta(max_depth, alpha, beta, maximizing_player)
    alpha = alpha or -math.huge
    beta = beta or math.huge
    maximizing_player = maximizing_player or true
    local best_move, best_val = self:ab_max_Value(self, -1, alpha, beta, maximizing_player, 0, max_depth)
    return best_move, best_val
end



function optimal_move(arr, max_depth)
    max_depth = max_depth or 7
    local game = Game.new(arr)
    local move, value = game:alphabeta(max_depth)
    
    -- Check if the move is valid
    local valid_move_list = valid_moves(arr)
    if not table.contains(valid_move_list, move) then
        pd.post("move not valid. valid moves: " .. table.concat(valid_move_list, ", "))
        return nil
    end
    
    return move
end



function cat_ai:initialize(sel, atoms)
    self.inlets = 1
    self.outlets = 1
    self.max_depth = type(atoms[1]) == "number" and atoms[1] or 7
    return true
end



function cat_ai:in_1_list(arr)
    if #arr ~= 121 then
        pd.post("input array should have 121 elements")
        return
    end

    local n = 11  -- size of the board
    local cat_idx = table.indexOf(arr, 6)
    if not cat_idx then
        pd.post("cat not found in the array")
        return
    end

    local cat_i, cat_j = (cat_idx - 1) % n, math.floor((cat_idx - 1) / n)

    -- check if the cat is already on the edge
    if cat_i == 0 or cat_i == n-1 or cat_j == 0 or cat_j == n-1 then
        self:outlet(1, "float", {69})
        return
    end

    local valid_move_list = valid_moves(arr)
    if #valid_move_list == 0 then
        self:outlet(1, "float", {68})
        return
    end

    local move = optimal_move(arr, self.max_depth)
    if move then
        self:outlet(1, "float", {move})
    else
        pd.post("could not generate a valid move")
    end
end