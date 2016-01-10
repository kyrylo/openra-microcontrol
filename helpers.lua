------------------------------------------------------------
-- Support functions that make Lua suck less
------------------------------------------------------------

function TableSize(T)
  local count = 0

  for _ in pairs(T) do
    count = count + 1
  end

  return count
end

function FilterTable(t, filterIter)
  local out = {}

  for k, v in pairs(t) do
    if filterIter(v, k, t) then out[k] = v end
  end

  return out
end

function EndsWith(str, tail)
  return #str >= #tail and string.sub(str, 1 + #str - #tail) == tail
end

function IsHusk(actor)
  return EndsWith(string.lower(actor.Type), '.husk')
end
