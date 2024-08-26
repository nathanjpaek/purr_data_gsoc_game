local move_chord = pd.Class:new():register("move_chord")

function move_chord:initialize(sel, atoms)
   self.inlets = 5
   self.outlets = 5
   return true
end

function move_chord:in_1_float(cp)
   self.cp = cp
end

function move_chord:in_2_float(next_move)
   self.next_move = next_move
end

function move_chord:in_3_float(c)
   self.c = c
end

function move_chord:in_4_float(r)
   self.r = r
end

function move_chord:in_5_float(l)
   self.l = l
   self:compute_move_chord()
end


--ZERO-C: 20
--ZERO-CC: 21
--ONE-C: 22
--ONE-CC: 23
--TWO-C: 24
--TWO-CC: 25
--THREE-C: 26
--THREE-CC: 27
--FOUR-C: 28
--FOUR-CC: 29
--FIVE-C: 30
--FIVE-CC: 31


function move_chord:compute_move_chord()
   local move_data = {
       [0] = {
           [0] = {22, 1, self.l + 7, self.l + 7, self.l},
           [1] = {21, 5, self.l, self.r, self.l + 7},
           [2] = {23, 5, self.l + 5, self.c, self.l},
           [3] = {13, 0, self.c + 5, self.c, self.l + 5},
           [4] = {14, 0, self.c + 8, self.r + 8, self.c},
           [5] = {20, 1, self.c + 3, self.r, self.c}
           --[5] = {20, 1, self.l + 3, self.r, self.c}
       },
       [1] = {
           [0] = {22, 2, self.c + 7, self.r, self.c},
           [1] = {24, 2, self.r, self.l + 4, self.l},
           [2] = {23, 0, self.l, self.r, self.l + 4},
           [3] = {25, 0, self.c + 5, self.c, self.l},
           [4] = {14, 1, self.c + 8, self.c, self.l + 8},
           [5] = {15, 1, self.c + 3, self.r + 3, self.c}
       },
       [2] = {
           [0] = {10, 2, self.c + 7, self.r + 7, self.c},
           [1] = {24, 3, self.r + 7, self.r, self.c},
           [2] = {26, 3, self.r, self.r + 5, self.l},
           [3] = {25, 1, self.l, self.r, self.r + 5},
           [4] = {27, 1, self.l + 3, self.c, self.l},
           [5] = {15, 2, self.c + 3, self.c, self.l + 3}
       },
       [3] = {
           [0] = {10, 3, self.c + 7, self.c, self.l + 7},
           [1] = {11, 3, self.c + 4, self.c + 4, self.c},
           [2] = {26, 4, self.r + 4, self.r, self.c},
           [3] = {28, 4, self.r, self.l + 5, self.l},
           [4] = {27, 2, self.l, self.r, self.l + 5},
           [5] = {29, 2, self.l + 7, self.c, self.l}
       },
       [4] = {
           [0] = {31, 3, self.c + 7, self.c, self.l},
           [1] = {11, 4, self.c + 4, self.c, self.l + 4},
           [2] = {12, 4, self.c + 9, self.r + 9, self.c},
           [3] = {28, 5, self.c + 5, self.r, self.c},
           [4] = {30, 5, self.r, self.r + 3, self.l},
           [5] = {29, 3, self.l, self.r, self.r + 3}
       },
       [5] = {
           [0] = {31, 4, self.l, self.r, self.r + 7},
           [1] = {21, 4, self.c + 4, self.c, self.l},
           [2] = {12, 5, self.c + 9, self.c, self.l + 9},
           [3] = {13, 5, self.c + 5, self.r + 5, self.c},
           [4] = {30, 0, self.r + 5, self.r, self.c},
           [5] = {20, 0, self.r, self.r + 7, self.l}
       }
   }

   pd.post(string.format("Computing move chord with cp: %f, next_move: %f", self.cp, self.next_move))


   local data = move_data[self.cp][self.next_move]
   local anim, np, new_c, new_r, new_l = data[1], data[2], data[3], data[4], data[5]

   pd.post(string.format("Outputting: anim: %f, np: %f, new_c: %f, new_r: %f, new_l: %f", 
                         anim, np, new_c, new_r, new_l))
   
   self:outlet(1, "float", {anim})
   self:outlet(2, "float", {np})
   self:outlet(3, "float", {new_c})
   self:outlet(4, "float", {new_r})
   self:outlet(5, "float", {new_l})
end
