-- 제조사 코드 → 디바이스 정의 라우터
-- 프로토콜별 device index 모듈을 하나로 통합합니다.

local protocol_modules = {
  "devices.ef00",
  "devices.hybrid",
  "devices.zcl",
}

local registry = {}
local fingerprint_index = nil
local model_only_index = nil

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
  model_only_index = {}

  for _, module_name in ipairs(protocol_modules) do
    local entries = require(module_name)

    for _, entry in ipairs(entries) do
      for _, fp in ipairs(entry.fingerprints) do
        local manufacturer = fp.manufacturer
        local model = fp.model

        if model ~= nil and manufacturer ~= nil then
          fingerprint_index[manufacturer] = fingerprint_index[manufacturer] or {}
          fingerprint_index[manufacturer][model] = copy_entry_without_fingerprints(entry)
        elseif model ~= nil then
          model_only_index[model] = copy_entry_without_fingerprints(entry)
        end
      end
    end
  end

  if next(model_only_index) ~= nil then
    fingerprint_index.__model_only = model_only_index
  end

  return fingerprint_index
end

function registry.find(manufacturer, model)
  local index = build_index()
  local by_manufacturer = index[manufacturer]
  if by_manufacturer and by_manufacturer[model] then
    return by_manufacturer[model]
  end

  local by_model_only = index.__model_only
  return by_model_only and by_model_only[model] or nil
end

function registry.all()
  return build_index()
end

return registry
