local SymbolTable = {}
SymbolTable.__index = SymbolTable

function SymbolTable.new ()
     return setmetatable({ -- the first section contains the function
                           -- parameters and types, and the function type
                           ["head"] = { ["parm"] = {} , ["tp"] = nil }
                           -- variables an their types
                         , ["body"] = {}
                           -- the list of function calls and their arguments
                         , ["call"] = {}
                           -- a list of labels found in the function body
                         , ["jump"] = {} }, SymbolTable)
end

function SymbolTable.add_parm (self, p, tp)
     table.insert(self.head.parm, { p, tp }) -- add tuple (parameter, type)
end

function SymbolTable.set_type (self, tp)
     self.head.tp = tp
end

function SymbolTable.add_var (self, id, tp)
     -- allows for multiples entries for the same id; inherent semantic error
     -- will be checked later
     if not self.body[id[1]] then
          self.body[id[1]] = {}
     end

     table.insert(self.body[id[1]], tp)
end

function SymbolTable.add_call (self, fname, idt)
     -- allows for multiples entries for the same id (more then one call)
     if not self.call[fname] then
          self.call[fname] = {}
     end

     table.insert(self.call[fname], idt)
end

function SymbolTable.add_jump (self, lbl)
     local elem_found = false

     for _, v in pairs(self) do
          if v == lbl then
               elem_found = true
               break
          end
     end

     if not elem_found then
          table.insert(self.jump, lbl)
     end
end
return SymbolTable
