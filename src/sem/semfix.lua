local SemFix = {}

-- expression ending markers
SemFix.EEM = { ["TK_END"] = true, ["TK_CM"] = true, ["TK_THEN"] = true
             , ["TK_LF"]  = true, ["TK_DO"] = true }

-- expression begining markers
SemFix.EBM = { ["TK_ASS"]   = true, ["TK_WHILE"] = true
             , ["TK_UNTIL"] = true, ["TK_IF"]    = true
             , ["TK_RET"]   = true }

-- types expected by some statements for thei expressions
SemFix.STT = { ["TK_WHILE"] = { "TK_BOOL", "TK_TBOOL" }
             , ["TK_UNTIL"] = { "TK_BOOL", "TK_TBOOL" }
             , ["TK_IF"]    = { "TK_BOOL", "TK_TBOOL" } }

-- operators precedence table
SemFix.OPP = { ["TK_FC"]  = 7
             , ["TK_NOT"] = 6
             , ["TK_MUL"] = 5, ["TK_DIV"] = 5
             , ["TK_ADD"] = 4, ["TK_SUB"] = 4
             , ["TK_EQ"]  = 3, ["TK_NE"]  = 3, ["TK_LT"] = 3
             , ["TK_GT"]  = 3, ["TK_LE"]  = 3, ["TK_GE"] = 3
             , ["TK_AND"] = 2
             , ["TK_OR"]  = 1

             -- not really operators but for postfix conversion purposes will
             -- be treated as such
             , ["TK_OP"] = 0, ["TK_CP"] = 0 }

-- "types relation"
SemFix.TPR = { ["TK_NUMB"] = "TK_TNUMB", ["TK_STRG"] = "TK_TSTRG"
             , ["TK_BOOL"] = "TK_TBOOL"

             , ["TK_TNUMB"] = "TK_NUMB", ["TK_TSTRG"] = "TK_STRG"
             , ["TK_TBOOL"] = "TK_BOOL" }

SemFix.OPT = { ["TK_NOT"] = { "TK_BOOL", "TK_TBOOL" }
             , ["TK_MUL"] = { "TK_NUMB", "TK_TNUMB" }
             , ["TK_DIV"] = { "TK_NUMB", "TK_TNUMB" }
             , ["TK_ADD"] = { "TK_NUMB", "TK_TNUMB" }
             , ["TK_SUB"] = { "TK_NUMB", "TK_TNUMB" }
             , ["TK_EQ"]  = { "TK_NUMB", "TK_TNUMB" }
             , ["TK_NE"]  = { "TK_NUMB", "TK_TNUMB" }
             , ["TK_LT"]  = { "TK_NUMB", "TK_TNUMB" }
             , ["TK_GT"]  = { "TK_NUMB", "TK_TNUMB" }
             , ["TK_LE"]  = { "TK_NUMB", "TK_TNUMB" }
             , ["TK_GE"]  = { "TK_NUMB", "TK_TNUMB" }
             , ["TK_AND"] = { "TK_BOOL", "TK_TBOOL" }
             , ["TK_OR"]  = { "TK_BOOL", "TK_TBOOL" } }

return SemFix
