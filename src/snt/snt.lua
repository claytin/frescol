local fix = require "snt/sntfix"
local stb = require "snt/symtb"

local Snt = {}

-- {{ LL(1) parsing table
local function load_ttbl ()
     local tt = {} -- tt (transition table), represents the transition sets
                   -- for the Frescol grammar

     -- State, global callback function which allows the easy build of tt
     function State (s) tt[s.id] = s end
     dofile("snt/transition.tb")

     return tt
end
-- }}

-- {{ Util
-- push_rhs, pushes righ hand side productions to the pasrsing stack
local function push_rhs (ps, pid)
     table.remove(ps)

     for i = #fix.PS[pid], 1, -1 do
          table.insert(ps, fix.PS[pid][i])
     end
end

-- for debugging purposes
local function show_ps (ps)
     for i = #ps, 1, -1 do
          print(ps[i])
     end
end
-- }}

-- Snt.parse, recieves a token stream and returns a list of simble tables for
-- that token stream
function Snt.parse (ts)
     local ll = load_ttbl()

     local isp = 1 -- input stream pointer
     local ps = {} -- parsing stack

     local errs = nil -- erros messages list
     local stl  = {} -- symbol table list

     -- initializing the parsing stack with special char '$', and the start
     -- grammar simbol (program); also adds ts ending mark ($)
     table.insert(ps, '$')
     table.insert(ps, 'program')
     table.insert(ts, {'', '$'}) -- a special token

     while ps[#ps] ~= '$' and ts[isp][2] ~= '$' do
          if ps[#ps] == ts[isp][2] then -- match
               -- print(ps[#ps], ts[isp][2])
               -- print('>')
               -- show_ps(ps)
               -- print('-------------')
               if (fix.AM[ps[#ps]]) then
                    -- print(ts[isp])
                    fix.AM[ps[#ps]](stl, ts[isp])
               else
                    fix.AM.default(nil, nil) -- maybe useless
               end

               table.remove(ps)
               isp = isp + 1
          elseif ll[ps[#ps]][ts[isp][2]] then -- push productions
               -- print(ps[#ps], ts[isp][2])
               -- print('>')
               -- show_ps(ps)
               -- print('-------------')

               push_rhs(ps, ll[ps[#ps]][ts[isp][2]])
          else
               -- print(ps[#ps], ts[isp][2])
               -- print('>')
               -- show_ps(ps)

               print("Error!")
               os.exit()
          end
     end

     if ps[#ps] == '$' and ts[isp][2] == '$' then -- no production left on ps
          -- print("ACCEPT")
          return stl, errs
     else
          print("Error!")
          os.exit()
     end
end

return Snt
