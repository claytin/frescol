local action = require "snt/actions"

local SntFix = {}

SntFix.PS = { { 'gprefix', 'functions' } -- #1
            , { 'TK_FKW' } -- #2
            , { 'somefun', 'program' } -- #3
            , { 'main' } -- #4
            , { 'id', 'parlst', 'TK_RETI', 'type', 'posfun' } -- #5
            , { 'TK_MAIN', 'TK_RETI', 'type', 'posfun' } -- #6
            , { 'TK_OP', 'facpl' } -- #7
            , { 'parms', 'TK_CP' } -- #8
            , { 'TK_CP' } -- #9
            , { 'type', 'id', 'facparm' } -- #10
            , { 'TK_CM', 'parms' } -- #11
            , { } -- #12
            , { 'stmts', 'TK_END' } -- #13
            , { 'stmt', 'TK_LF', 'stmts' } -- #14
            , { 'TK_LF', 'stmts' } -- #14
            , { 'return', 'TK_LF', "stmts'" } -- #15
            , { 'stmts' } -- #16
            , { } -- #17
            , { 'fcorass' } -- #18
            , { 'declare' } -- #19
            , { 'input' } -- #20
            , { 'output' } -- #21
            , { 'jmp' } -- #22
            , { 'label' } -- #23
            , { 'preif' } -- #24
            , { 'prefor' } -- #25
            , { 'while' } -- #26
            , { 'repeat' } -- #27
            , { 'precase' } -- #28
            , { 'fstmt', 'TK_LF', 'facfstmt' } -- #29
            , { 'TK_LF', 'facfstmt' } -- #29
            , { 'fstmts' } -- #30
            , { } -- #31
            , { 'fcorass' } -- #32
            , { 'declare' } -- #33
            , { 'input' } -- #34
            , { 'output' } -- #35
            , { 'return' } -- #36
            , { 'jmp' } -- #37
            , { 'label' } -- #38
            , { 'preif' } -- #39
            , { 'prefor' } -- #40
            , { 'while' } -- #41
            , { 'repeat' } -- #42
            , { 'precase' } -- #43
            , { 'id', 'tailfoa' } -- #44
            , { 'TK_ASS', 'expr' } -- #45
            , { 'arglst' } -- #46
            , { 'type', 'lstida' } -- #47
            , { 'headlida', 'faclstida' } -- #48
            , { 'id', 'taillida' } -- #49
            , { 'TK_ASS', 'expr' } -- #50
            , { } -- #52
            , { 'TK_CM', 'lstida' } -- #53
            , { } -- #54
            , { 'TK_INP', 'TK_OP', 'id', 'TK_CP' } -- #55
            , { 'TK_OUT', 'TK_OP', 'literal', 'TK_CP' } -- #56
            , { 'TK_RET', 'expr' } -- #57
            , { 'TK_JMP', 'label' } -- #58
            , { 'TK_LBL' } -- #59
            , { 'TK_IF', 'expr', 'TK_THEN', 'fstmts', 'posif' } -- #60
            , { 'TK_ELSE', 'fstmts', 'TK_END' } -- #61
            , { 'TK_END' } -- #62
            , { 'TK_FOR', 'lvar', 'TK_CM', 'lvar', 'posfor' } -- #63
            , { 'TK_CM', 'lvar', 'TK_DO', 'fstmts', 'TK_END' } -- #64
            , { 'TK_DO', 'fstmts', 'TK_END' } -- #65
            , { 'id' } -- #66
            , { 'numb' } -- #67
            , { 'TK_WHILE', 'expr', 'TK_DO', 'fstmts', 'TK_END' } -- #68
            , { 'TK_REP', 'fstmts', 'TK_UNTIL', 'expr', 'TK_END' } -- #69
            , { 'TK_CASE', 'id', 'whens', 'poscase' } -- #70
            , { 'TK_ELSE', 'fstmts', 'TK_END' } -- #71
            , { 'TK_END' } -- #72
            , { 'when', 'facwhen' } -- #73
            , { 'whens' } -- #74
            , { } -- #75
            , { 'TK_WHEN', 'literal', 'TK_THEN', 'fstmts', 'TK_END' } -- #76
            , { 'headexpr', "expr'" } -- #77
            , { 'TK_OP', 'expr', 'TK_CP', "expr'" } -- #78
            , { 'uop', 'expr', "expr'" } -- #79
            , { 'bop', 'expr', "expr'" } -- #80
            , { } -- #81
            , { 'numb' } -- #82
            , { 'strg' } -- #83
            , { 'bool' } -- #84
            , { 'id', 'tailexpr' } -- #85
            , { 'arglst' } -- #86
            , { } -- #87
            , { 'TK_OP', 'facal' } -- #88
            , { 'args', 'TK_CP' } -- #89
            , { 'TK_CP' } -- #90
            , { 'literal', 'facargs' } -- #91
            , { 'TK_CM', 'args' } -- #92
            , { } -- #93
            , { 'TK_ADD' } -- #94
            , { 'TK_SUB' } -- #95
            , { 'TK_MUL' } -- #96
            , { 'TK_DIV' } -- #97
            , { 'TK_EQ' } -- #98
            , { 'TK_NE' } -- #99
            , { 'TK_LT' } -- #100
            , { 'TK_GT' } -- #101
            , { 'TK_LE' } -- #102
            , { 'TK_GE' } -- #103
            , { 'TK_AND' } -- #104
            , { 'TK_OR' } -- #105
            , { 'TK_SUB' } -- #106
            , { 'TK_NOT' } -- #107
            , { 'id' } -- #108
            , { 'numb' } -- #108
            , { 'strg' } -- #109
            , { 'bool' } -- #110
            , { 'TK_ID' } -- #111
            , { 'TK_NUMB' } -- #112
            , { 'TK_STRG' } -- #113
            , { 'TK_BOOL' } -- #114
            , { 'TK_TSTRG' } -- #115
            , { 'TK_TNUMB' } -- #116
            , { 'TK_TBOOL' } }

SntFix.AM = { ["TK_FKW"] = action.fun

            , ["TK_TNUMB"] = action.dec, ["TK_TSTRG"] = action.dec
            , ["TK_TBOOL"] = action.dec

            , ["TK_FKW"] = action.fun

            , ["TK_RETI"] = action.rei

            , ["TK_JMP"] = action.jmp

            , ["TK_MAIN"] = action.main, ["TK_ID"] = action.id

            , ["TK_LBL"] = action.lbl

            , ["TK_NUMB"] = action.lit, ["TK_STRG"] = action.lit
            , ["TK_BOOL"] = action.lit

            , ["TK_LF"] = action.lf

            , ["TK_OP"] = action.op, ["TK_CP"] = action.cp

            , ["TK_CM"] = action.cm

            , ["default"] = action.default }

return SntFix
