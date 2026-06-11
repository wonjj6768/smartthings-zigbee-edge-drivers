local function load_modules(module_names)
  local entries = {}

  for _, module_name in ipairs(module_names or {}) do
    local module_entries = require(module_name)
    for _, entry in ipairs(module_entries) do
      entries[#entries + 1] = entry
    end
  end

  return entries
end

return {
  load_modules = load_modules,
}
