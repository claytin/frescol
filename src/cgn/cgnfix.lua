local action = require "cgn.actions"

local CgnFix = {}

CgnFix.SOT = { ["TK_FH"] = action.fh

             , ["TK_FC"] = action.fc

             , ["TK_FOR"] = action.frl, ["TK_WHILE"] = action.whl
             , ["TK_REP"] = action.rpl

             , ["TK_OUT"] = action.out, ["TK_INP"] = action.inp }

CgnFix.SET = { ["TK_END"] = action.endt }

return CgnFix
