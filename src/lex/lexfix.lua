local LexFix = {}

-- {{ Tokens
-- it could occupy less space, but it is better to read it this way;
-- it duplicates entries as well but for now it will stay this way
LexFix.TK = {}

LexFix.TK[2] = "TK_NUMB"; LexFix.TK[5] = "TK_NUMB"
LexFix.TK[6] = "TK_ID";   LexFix.TK[8] = "TK_ID"

LexFix.TK[13] = "TK_NOT"; LexFix.TK[22] = "TK_EQ"; LexFix.TK[14] = "TK_NE"
LexFix.TK[10] = "TK_LT";  LexFix.TK[15] = "TK_GT"; LexFix.TK[12] = "TK_LE"
LexFix.TK[16] = "TK_GE"

LexFix.TK[9]  = "TK_RETI";
LexFix.TK[11] = "TK_ASS"

LexFix.TK[17] = "TK_ADD"; LexFix.TK[3] = "TK_SUB"; LexFix.TK[18] = "TK_MUL"
LexFix.TK[19] = "TK_DIV"

LexFix.TK[20] = "TK_OP"
LexFix.TK[21] = "TK_CP"
LexFix.TK[23] = "TK_CM"
LexFix.TK[25] = "TK_LF"
LexFix.TK[29] = "TK_STRG"

LexFix.TK[31] = "TK_LBL"
LexFix.TK[32] = "TK_LF"
-- }}

-- {{ Reserved Words
LexFix["RW"] = { ["strg"] = "TK_TSTRG", ["numb"] = "TK_TNUMB"
               , ["bool"] = "TK_TBOOL"

               , ["true"] = "TK_TRUE", ["false"] = "TK_FALSE"

               , ["end"] = "TK_END"

               , ["and"] = "TK_AND", ["or"] = "TK_OR"

               , ["read"] = "TK_INP", ["write"] = "TK_OUT"

               , ["do"] = "TK_DO"

               , ["for"]    = "TK_FOR", ["while"] = "TK_WHILE"
               , ["repeat"] = "TK_REP", ["until"] = "TK_UNTIL"

               , ["if"]   = "TK_IF",    ["then"] = "TK_THEN"
               , ["else"] = "TK_ELSE" , ["case"] = "TK_CASE"
               , ["when"] = "TK_WHEN"

               , ["jmp"] = "TK_JMP"

               , ["function"] = "TK_FKW", ["return"] = "TK_RET"

               , ["main"] = "TK_MAIN" }
-- }}

return LexFix
