local fix = require "sem.semfix"

local Sem = {}

local errs = {}

local function to_postfix (nts, ts, isp)
     local stack = {}

     while not fix.EEM[ts[isp][2]] do
          -- not operator, just push it
          if not fix.OPP[ts[isp][2]] then
               table.insert(nts, ts[isp])
          elseif #stack == 0 or stack[#stack][2] == "TK_OP" then
               table.insert(stack, ts[isp])
          -- '(' is aways pusehd into the stack
          elseif ts[isp][2] == "TK_OP" then
               table.insert(stack, ts[isp])
          elseif ts[isp][2] == "TK_CP" then
               -- when ')' appears pop the operators from the stack
               while stack[#stack][2] ~= "TK_OP" do
                    table.insert(nts, stack[#stack])

                    table.remove(stack, #stack)
               end

               table.remove(stack, #stack)
          -- incoming operator has greater precedence than the one on top of
          -- the stack
          elseif fix.OPP[ts[isp][2]] > fix.OPP[stack[#stack][2]] then
               table.insert(stack, ts[isp])
          elseif fix.OPP[ts[isp][2]] == fix.OPP[stack[#stack][2]] then
               table.insert(nts, stack[#stack])

               table.remove(stack, #stack)
               table.insert(stack, ts[isp])
          else
               -- pop until the precedence of the incomig operator is greater
               -- then the top of the stack
               while fix.OPP[ts[isp][2]] <= fix.OPP[stack[#stack][2]] do
                    table.insert(nts, stack[#stack])

                    table.remove(stack, #stack)

                    if #stack == 0 then break end
               end

               table.insert(stack, ts[isp])
          end

          isp = isp + 1
     end

     for i = 1, #stack do
          table.insert(nts, stack[#stack])
          table.remove(stack, #stack)
     end

     return isp
end

local function compat (tp, itrt)
     return tp == itrt[1] or tp == itrt[2]
end

local function get_types (es, cf, st, n)
     local tps = {}

     while n >= 1 do -- n indicates from how many operands the type must be
                     -- recovered
          if es[#es][2] == "TK_ID" then
               table.insert(tps, st[cf].body[es[#es][1]][1][2])
          elseif es[#es][2] == "TK_FC" then
               table.insert(tps, st[es[#es][1]].head.tp[2])
          else
               table.insert(tps, es[#es][2])
          end

          table.remove(es, #es)
          n = n - 1
     end

     return unpack(tps)
end

-- "solve" the expretion starting at isp
-- FIX !!
local function solve (cf, st, ts, isp)
     local evals = {} -- evaluation stack

     while not fix.EEM[ts[isp][2]] do -- not at the end of expression
          if not fix.OPP[ts[isp][2]] or ts[isp][2] == "TK_FC" then
               table.insert(evals, ts[isp])
          elseif ts[isp][2] ~= "TK_NOT" then -- binary operator
               local t1, t2 = get_types(evals, cf, st, 2)

               if t1 ~= t2 and fix.TPR[t1] ~= t2 then
                    print("Err: incompatible types for '" .. ts[isp][1] ..
                          "' at '" .. cf .. "'")
               elseif not (compat(t1, fix.OPT[ts[isp][2]]) and
                           compat(t2, fix.OPT[ts[isp][2]])) then
                    print("Err: unexpected for operands of operator" .. " '"
                          .. ts[isp][1] ..  "' at '" ..  cf .. "'")
               else
                    table.insert(evals, { nil, fix.OPT[ts[isp][2]][1] })
               end
          else -- unary operator
               local t1 = get_types(evals, cf, st, 1)

               if not compat(t1, fix.OPT[ts[isp][2]]) then
                    print("Err: unexpected for operands of operator" .. " '"
                          .. ts[isp][1] ..  "' at 'fun'")
               else
                    table.insert(evals, { nil, fix.OPT[ts[isp][2]][1] })
               end
          end

          isp = isp + 1
     end

     return isp, evals[#evals][2]
end

local function transform (st, ts)
     -- {{ Phase I
     -- function headers and function calls will be removed
     local ntsi = {} -- new token stream, phase i

     local isp = 1 -- input stream pointer
     while isp <= #ts do
          if ts[isp][2] == "TK_FKW" then
               table.insert(ntsi, ts[isp]) -- sotores function keyword

               -- create a new spcial "token", it will substitute the hole
               -- function header
               isp = isp + 1 -- goto token that holds the function name
               table.insert(ntsi, { ts[isp][1], "TK_FH" })

               while ts[isp][2] ~= "TK_RETI" do
                    isp = isp + 1
               end

               isp = isp + 2 -- jump the return type token
          elseif st[ts[isp][1]] then -- ts[isp] is a function call
               table.insert(ntsi, { ts[isp][1], "TK_FC" })

               while ts[isp][2] ~= "TK_CP" do -- dummy loop, just pass by the
                                              -- tokens composing call
                    isp = isp + 1
               end

               isp = isp + 1 -- avoid TK_CP
          else -- just add token to the new token stream
               table.insert(ntsi, ts[isp])
               isp = isp + 1
          end
     end
     -- }}

     -- {{ Phase II
     -- expressions will be turned into their postfix form
     local ntsii = {} -- new token stream, phase ii

     isp = 1
     while isp <= #ntsi do
          if fix.EBM[ntsi[isp][2]] then -- add the following expression to the
                                      -- new token stream, in postfix form
               table.insert(ntsii, ntsi[isp])
               isp = to_postfix(ntsii, ntsi, isp + 1)
          else -- just add token to the new token stream
               table.insert(ntsii, ntsi[isp])
               isp = isp + 1
          end
     end
     -- }}

     return ntsii
end

-- {{ Checking
-- check rules that may be checked using only the ST
local function trules (st)
     for f, t in pairs(st) do
          -- rules related to variable declarations
          for id, tps in pairs(t.body) do
               if #tps > 1 then
                    print("Err: variable '" .. id .. "' redeclaration at "
                          ..  "'" .. f .. "'")
               end
          end

          -- rules related to functions
          for c, alt in pairs(t.call) do
               if not st[c] then
                    print("Err: call for undefined function '" .. c .."'" ..
                          " at '" .. f .. "'")
               else
                    for _, al in pairs(alt) do
                         if #al ~= #st[c].head.parm then
                              print("Err: incompatible number of arguments"
                                    .. " for '" .. c .. "' at '" .. f .. "'")
                         else
                              for i = 1, #al do
                                   if t.body[al[i][1]][1][2] ~= st[c].head.parm[i][2][2] then
                                        print("Err: inconpatible type for" ..
                                              " argument '" .. al[i][1] .. "'"
                                              .. " of '" .. c .. "' at '" .. f
                                              .. "'")
                                   end
                              end
                         end
                    end
               end
          end
     end
end

local function crules (st, ts)
     local sid, cfun

     local isp = 1 -- input stream pointer
     while isp < #ts do
          if ts[isp][2] == "TK_ID" then
               sid = ts[isp][1]
          elseif ts[isp][2] == "TK_FH" and st[ts[isp][1]] then
               cfun = ts[isp][1]
          elseif ts[isp][2] == "TK_MAIN" then
               cfun = "main"
          elseif fix.EBM[ts[isp][2]] then
               local ltp
               local ebm = ts[isp][2]

               isp, ltp = solve(cfun, st, ts, isp + 1)

               -- check type depending on EBM
               if ebm == "TK_IF" and not compat(ltp, fix.STT[ebm]) then
                    print("Err: expected type 'bool' for expretion of 'if' "
                          .. "statement at '" ..  cfun .. "'")
               elseif ebm == "TK_WHILE" and not compat(ltp, fix.STT[ebm]) then
                    print("Err: expected type 'bool' for expression of "
                          .. "'while' statement at '" ..  cfun .. "'")
               elseif ebm == "TK_UNTIL" and not compat(ltp, fix.STT[ebm]) then
                    print("Err: expected type 'bool' for expression of "
                          .. "'repeat' statement at '" ..  cfun .. "'")
               elseif ebm == "TK_ASS" and
                      not ltp ~= st[cfun].body[sid][1][2] then
                    print("Err: wrong type for assignemt of '" .. sid .. "'"
                          ..  " at '" .. cfun .. "'")
               elseif ltp ~= st[cfun].head.tp[2] and
                      fix.TPR[ltp] ~= st[cfun].head.tp[2] then
                    print("Err: return type incompatible for function '"
                          ..  cfun .. "'")
               end
          end

          isp = isp + 1
     end
end
-- }}


function Sem.check (st, ts)
     local nts = {} -- new token stream

     errs = trules(st)
     nts = transform(st, ts)
     errs = crules(st, nts)

     return nts, errs
end

return Sem
