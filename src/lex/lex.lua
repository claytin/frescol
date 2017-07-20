local Lex = {}

-- {{ Automata
local function load_automata ()
     local tt = {} -- tt (transition table), ds representing the automata
                   -- specified on a '.at' file;
     -- State, gloabal callback function which allows the easy build of the
     -- transition table
     function State (s) tt[s.id] = s end
     dofile("lex/automata.at")

     return tt
end
-- }}

-- {{ Util
-- load_istream; transforms unmutable string to a table that represents the
-- source file as a input stream and returns it
local function load_istream (f)
     io.input(f) -- changes input from stdin to file f

     local is = {} -- input stream
     -- for each char c in the string add it to is
     for c in string.gmatch(io.read("*a"), ".") do
         table.insert(is, c)
     end

     return is
end
-- }}

function Lex.scan (file)
     local ttbl = load_automata()
     local istream = load_istream(file)

     local li = {} -- general info about the lexical analisys process
     li.s   = 1    -- automata state, 1 is the initial state
     li.isp = 1    -- input stream pointer

     local lxm, tks, errs = {}, {}, {} -- lexeme, token stream, error list

     repeat
          table.insert(lxm, istream[li.isp])

          if ttbl[li.s][istream[li.isp]] then     -- exists transtion for ...
               -- print(li.s)
               li.s = ttbl[li.s][istream[li.isp]] -- transition

               li.isp = li.isp + 1 -- advances on the input stream
          else -- action will determine what happens when no transition is
               -- defined for a certain char on a certain state
               ttbl[li.s].action(li, istream[li.isp], lxm, tks, errs)
          end
          -- add char to lexeme; must be here cause of the error message
     until not istream[li.isp] -- there is char on stream

     return tks, errs
end

return Lex
