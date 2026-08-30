-- 제조사 코드 → 디바이스 정의 라우터
-- generated.package_registry가 manifest 순서대로 모든 package registration을 제공합니다.

local registrations = require "generated.package_registry"

local registry = {}
local fingerprint_index = nil

local function copy_entry_without_fingerprints(entry)
  local copied = {}
  if type(entry) ~= "table" then
    return copied
  end

  for key, value in pairs(entry) do
    if key ~= "fingerprints" then
      copied[key] = value
    end
  end

  return copied
end

local function build_index()
  if fingerprint_index then
    return fingerprint_index
  end

  fingerprint_index = {}

  for _, entry in ipairs(registrations) do
    for _, fp in ipairs(entry.fingerprints) do
      local manufacturer = fp.manufacturer
      local model = fp.model

      if model ~= nil and manufacturer ~= nil then
        fingerprint_index[manufacturer] = fingerprint_index[manufacturer] or {}
        fingerprint_index[manufacturer][model] = copy_entry_without_fingerprints(entry)
      end
    end
  end

  return fingerprint_index
end

function registry.find(manufacturer, model)
  local index = build_index()
  local by_manufacturer = index[manufacturer]
  if by_manufacturer and by_manufacturer[model] then
    return by_manufacturer[model]
  end

  return nil
end

function registry.all()
  return build_index()
end

return registry
