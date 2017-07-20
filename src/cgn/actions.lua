local Actions = {}

-- {{ Counters
local strc = 0 -- number of strings on .data
local forc = 0 -- number of for loops
-- }}

-- {{ Control data structures
local cls_blk = {} -- a stack that controls the closing of blocks
local idata   = {} -- stores some initialized data
-- }}

-- {{ Should be on fix but ...
local TTRANS = { ["TK_STRG"] = "strg", ["TK_TSTRG"] = "strg"
               , ["TK_NUMB"] = "numb", ["TK_TNUMB"] = "numb" }
-- }}

function Actions.fh (ts, st, cf, isp, secs)
     secs.text = secs.text .. cf .. ":\n"

     if cf ~= "main" then
          secs.text = secs.text .. "\tprol\n"

          -- set local variables
          for  k, p in pairs(st[cf].head.parm) do
               secs.text = secs.text .. "\tmovq %r" .. (k + 7) .. ", (" .. cf
                                     .. "_" .. p[1][1] .. ")\n"
          end

          table.insert(cls_blk, "\tepil\n")
     else
          table.insert(cls_blk, "\n\tmovq $1, %rax\n"
                                .. "\tmovq $0, %rbx\n"
                                .. "\tint $0x80\n")
     end

     return isp, secs
end

function Actions.fc (ts, st, cf, isp, secs)
     isp = isp - 1 -- go back to the correct token

     -- add var to hold return
     if st[ts[isp][1]].head.tp[2] == "TK_TBOOL" and
        not idata[ts[isp][1] .. "_ret"] then
          secs.bss = secs.bss .. "\t.lcomm " .. ts[isp][1] .. "_ret, 1\n"
     elseif st[ts[isp][1]].head.tp[2] == "TK_TNUMB" and
            not idata[ts[isp][1] .. "_ret"] then
          secs.bss = secs.bss .. "\t.lcomm " .. ts[isp][1] .. "_ret, 8\n"
     elseif not idata[ts[isp][1] .. "_ret"] then
          secs.bss = secs.bss .. "\t.lcomm " .. ts[isp][1] .. "_ret, 32\n"
     end

     idata[ts[isp][1] .. "_ret"] = true -- grant a bss section without dups

     secs.text = secs.text .. "\tprecall\n"
     -- {{ arguments
     local l = st[cf].call[ts[isp][1]][1]

     for i = 1, #l do
          secs.text = secs.text .. "\tmovq $" .. cf .. "_" .. l[i][1] .. ", %r"
                                .. (i + 7) .. "\n"
     end

     table.remove(st[cf].call[ts[isp][1]], 1) -- remove arguments list for
                                              -- current call
     -- }}

     secs.text = secs.text .. "\tcall " .. ts[isp][1] .. "\n"
                           .. "\tposcall\n"

     return isp, secs
end

function Actions.endt (ts, st, cf, isp, secs)
     secs.text = secs.text .. cls_blk[#cls_blk]
     table.remove(cls_blk, #cls_blk)

     return isp, secs
end

function Actions.out (ts, st, cf, isp, secs)
     isp = isp + 1 -- pass by TK_OP

     if ts[isp][2] == "TK_STRG" then
          strc = strc + 1
          secs.data = secs.data .. "\tstr_cons_" .. strc .. ":\n"
                                .. "\t\t.asciz " .. ts[isp][1] .. "\n"

          secs.text = secs.text .. "\tmovq $ostrg_frmt, %rdi\n"
                                .. "\tmovq $str_cons_" .. strc .. ", %rsi\n"
                                .. "\txorq %rax, %rax\n"
                                .. "\tcall printf\n"
     else
          secs.text = secs.text .. "\tmovq $ostrg_frmt, %rdi\n"
                                .. "\tmovq $" .. cf .. "_" .. ts[isp][1]
                                .. ", %rsi\n"
                                .. "\txorq %rax, %rax\n"
                                .. "\tcall printf\n"
     end

     return isp, secs
end

function Actions.inp (ts, st, cf, isp, secs)
     isp = isp + 1 -- pass by TK_OP

     secs.text = secs.text .. "\tmovq $istrg_frmt, %rdi\n"
                           .. "\tleaq (" .. cf .. "_" .. ts[isp][1]
                           .. "), %rsi\n"
                           .. "\txorq %rax, %rax\n"
                           .. "\tcall scanf\n"

     return isp, secs
end

function Actions.frl (ts, st, cf, isp, secs)
     forc = forc + 1

     local lv = {}

     table.insert(lv, ts[isp]) -- get first loop "control variable"
     isp = isp + 2 -- jump TK_CM
     table.insert(lv, ts[isp]) -- second
     isp = isp + 1
     table.insert(lv, 1) -- default

     if ts[isp][2] ~= "TK_DO" then -- there is a third loop "control variable"
          isp = isp + 1 -- to next token

          table.remove(lv, #lv)     -- remove default value
          table.insert(lv, ts[isp]) -- add new one
     end

     secs.text = secs.text .. "\tmovq $" .. lv[1][1] .. ", %r14\n"
                           .. "\tmovq $" .. lv[2][1] .. ", %r15\n"
                           .. cf .. "_for" .. forc .. "_cc:\n"
                           .. "\tcmpq %r14, %r15\n"
                           .. "\tjg " .. cf .. "_for" .. forc .. "_beg\n"
                           .. "\tjmp " .. cf .. "_for" .. forc .. "_end\n\n"
                           .. cf .. "_for" .. forc .. "_beg:\n"

     table.insert(cls_blk, "\taddq $" .. lv[3] .. ", %r14\n"
                           .. "jmp " .. cf .. "_for" .. forc .. "_cc\n"
                           .. cf .. "_for" .. forc .. "_end:\n")

     return isp + 1, secs -- isp is set on TK_DO
end

return Actions
