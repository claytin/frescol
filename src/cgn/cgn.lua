local fix = require "cgn.cgnfix"

local Cgn = {}

-- {{ Sections
-- not exactly a section, but will be threated as such
local macros = ".macro prol\n"
               .. "\tpushq %rbp\n"
               .. "\tmovq %rsp, %rbp\n"
               .. ".endm\n\n"
               .. ".macro epil\n"
               .. "\tmovq %rbp, %rsp\n"
               .. "\tpopq %rbp\n"
               .. "\tret\n"
               .. ".endm\n\n"
               .. ".macro precall\n"
               .. "\tpushq %rbx\n"
               .. "\tpushq %r12\n"
               .. "\tpushq %r13\n"
               .. "\tpushq %r14\n"
               .. "\tpushq %r15\n"
               .. ".endm\n\n"
               .. ".macro poscall\n"
               .. "\tpopq %r15\n"
               .. "\tpopq %r14\n"
               .. "\tpopq %r13\n"
               .. "\tpopq %r12\n"
               .. "\tpopq %rbx\n"
               .. ".endm\n\n"

-- data is initialized with string formats for input and output
local data = ".section .data\n"
              .. '\tostrg_frmt:\n\t\t.asciz "%s\\n"\n'
              .. '\tonumb_frmt:\n\t\t.asciz "%ld\\n"\n'
              .. '\tistrg_frmt:\n\t\t.asciz "%s"\n'
              .. '\tinumb_frmt:\n\t\t.asciz "%ld"\n'

-- holds most of data of the program
local bss  = ".section .bss\n"
-- will use gcc expected structure, cause of scanf and printf
local text = ".section .text\n"
             .. "\t.globl main\n\n"
-- }}

local function add_bss (stl)
     for f, t in pairs(stl) do
          -- parameters declared on funtion header
          for  _, p in pairs(t.head.parm) do
               if p[2][2] == "TK_TBOOL" then
                    bss = bss .. "\t.lcomm " .. f .. "_" .. p[1][1] .. ", 1\n"
               elseif p[2][2] == "TK_TNUMB" then
                    bss = bss .. "\t.lcomm " .. f .. "_" .. p[1][1] .. ", 8\n"
               else
                    bss = bss .. "\t.lcomm " .. f .. "_" .. p[1][1] .. ", 32\n"
               end
          end

          -- variables declared on funtion body
          for v, l in pairs(t.body) do
               if l[1][2] == "TK_TBOOL" then
                    bss = bss .. "\t.lcomm " .. f .. "_" .. v .. ", 1\n"
               elseif l[1][2] == "TK_TNUMB" then
                    bss = bss .. "\t.lcomm " .. f .. "_" .. v .. ", 8\n"
               else
                    bss = bss .. "\t.lcomm " .. f .. "_" .. v .. ", 32\n"
               end
          end
     end
end

function Cgn.to_asm (stl, ts)
     local cfun

     add_bss(stl)
     local secs = { ["data"] = data, ["bss"] = bss, ["text"] = text }

     local isp = 1
     while isp < #ts do
          if ts[isp][2] == "TK_FH" then
               cfun = ts[isp][1]
               isp, secs = fix.SOT[ts[isp][2]](ts, stl, cfun, isp, secs)
          elseif fix.SOT[ts[isp][2]] then
               isp, secs = fix.SOT[ts[isp][2]](ts, stl, cfun, isp + 1, secs)
          elseif fix.SET[ts[isp][2]] then
               isp, secs = fix.SET[ts[isp][2]](ts, stl, cfun, isp, secs)
          end

          isp = isp + 1
     end

     return macros .. secs.data .. secs.bss .. secs.text
end

return Cgn
