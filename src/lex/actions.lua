local lf = require "lex/lexfix"

local Action = {}

-- {{ Util
-- cleans the lexeme l; it appears that there is no better way to do it
local function clean(l) for k in pairs(l) do l[k] = nil end end
-- }}

-- {{ Actions
function Action.err (inf, c, l, t, e)
     local pt = table.concat(l) -- partial token
     clean(l)

     local err_msg = "Err: unexpected char at " .. pt .. "$"
     table.insert(e, err_msg)

     inf.s = 1             -- back to initial state
     inf.isp = inf.isp + 1 -- avances on the input stream
end

function Action.tk (inf, c, l, t, e)
     -- for _, v in pairs(l) do print(v) end
     -- print()
     l[#l] = nil -- grants that the extra char read doesn't appear on token
     local lexm = table.concat(l)

     if lf.TK[inf.s] == 'TK_ID' and lf.RW[lexm] then
          table.insert(t, { lexm, lf.RW[lexm] })
     else
          table.insert(t, { lexm, lf.TK[inf.s] })
     end

     clean(l)
     inf.s = 1 -- back to state 1; do not advance on the input stream
end

function Action.cmnt (inf, c, l, t, e)
     l[1] = nil -- simpler than call clean(l); only applies here

     if c == "\n" then -- end of line => end of comment
          inf.s = 1    -- to state 1
     end

     inf.isp = inf.isp + 1 -- aways advances on the input stream
end

function Action.str (inf, c, l, t, e)
     inf.s = 27
     inf.isp = inf.isp + 1 -- "empty" transition for any char
end

function Action.ws (inf, c, l, t, e)
     clean(l)  -- avoid "poluted" lexemes
     inf.s = 1 -- back to initial state
end
-- }}

return Action
