local symtb = require "snt.symtb"

local Actions = { }

-- {{ Flags
-- keep track of various siuations/contexts while parsing
local fun = false -- TK_FKW
local rei = false -- TK_RETI
local jmp = false -- TK_JMP
local dec = false -- TK_TNUMB, TK_TNUMB, TK_TBOOL
local cll = false -- TK_OP
local idw = false -- TK_ID
-- }}

-- {{ Internal state controlers
local stype = nil -- some type; stores type to be associated with some obj
local sid   = nil -- some id; stores id for future checking
local fname = nil -- stores function name for ST call entries
local cfun  = nil -- current funtion; used for indexing the ST
local args  = {}  -- will store the functions arguments
-- }}

function Actions.fun (stl, tk)
     fun = true -- flag for checking two situations
                -- 1. the next id must be the name of a function
                -- 2. each possible declaration ahead define a parameter
end

function Actions.rei (stl, tk)
     fun = false -- already ahead of a possible parameters list
     rei = true  -- waiting for function type
end

function Actions.jmp (stl, tk)
     jmp = true -- will allow the needed checking on Actions.lbl
end

function Actions.lbl (stl, l)
     if not jmp then -- labels can't be added to the ST if preceded by TK_JMP
          stl[cfun].add_jump(stl[cfun], l)
     end

     jmp = false -- default behaviour
end

function Actions.dec (stl, t)
     stype = t
     dec = true

     if rei then -- special case when the function type is been declared
          stl[cfun].set_type(stl[cfun], stype)

          rei = false -- job is done, back to default value
          dec  = false
     end
end
-- ok
function Actions.main (stl, id)
     stl[id[1]] = symtb.new()
     cfun = id[1]
end

function Actions.id (stl, id)
     sid = id

     if fun and not dec then -- sid is a function name
          stl[sid[1]] = symtb.new()
          cfun = sid[1]

          return
     end

     if fun and dec then -- parameter declaration
          stl[cfun].add_parm(stl[cfun], sid, stype)

          return
     end

     if dec and not idw then -- var declaration
          stl[cfun].add_var(stl[cfun], sid, stype)

          return
     end

     if cll then
          table.insert(args, sid)

          return
     end

     idw = true
end

function Actions.lit (stl, tk)
     if cll then
          table.insert(args, tk)
     end
end

function Actions.lf (stl, tk)
     idw = false
     dec = false
end

function Actions.cm (stl, tk)
     idw = false
end

function Actions.op (stl, tk)
     cll = idw or false

     if cll then
          fname = sid[1]
     end
end

function Actions.cp (stl, tk)
     if cll then
          stl[cfun].add_call(stl[cfun], fname, args)

          args = {}
          cll = false
     end
end

function Actions.default (stlm, tk)
     idw = false
end

return Actions
