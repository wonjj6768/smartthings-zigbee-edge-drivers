local device_registry_helpers = {}
local function normalize_fingerprint_part(value)
if type(value) ~= "string" then
return value
end
value = value:gsub("\0", "")
value = value:gsub("^%s+", ""):gsub("%s+$", "")
return value
end
local function copy_entry_fields(source, target)
if type(source) ~= "table" then
return target
end
target = target or {}
for key, value in pairs(source) do
if key ~= "fingerprints" then
target[key] = value
end
end
return target
end
local function indexed_entries(source)
local list = {}
if type(source) ~= "table" then
return list
end
for _, value in ipairs(source) do
list[#list + 1] = value
end
return list
end
local function clear_indexed_entries(target)
if type(target) ~= "table" then
return target
end
for index = 1, #target do
target[index] = nil
end
return target
end
local function append_entries(target, entries)
if type(target) ~= "table" then
target = {}
end
if type(entries) ~= "table" then
return target
end
for _, entry in ipairs(entries) do
target[#target + 1] = entry
end
return target
end
local function has_named_fields(value)
if type(value) ~= "table" then
return false
end
for key, _ in pairs(value) do
if type(key) ~= "number" then
return true
end
end
return false
end
local function is_zcl_mapping(entry)
return type(entry) == "table" and entry.cluster_id ~= nil and entry.attribute_id ~= nil
end
local function is_zcl_mapping_list(value)
if type(value) ~= "table" or value[1] == nil then
return false
end
local count = 0
for _, entry in ipairs(value) do
if not is_zcl_mapping(entry) then
return false
end
count = count + 1
end
return count > 0
end
local function is_datapoint_mapping(entry)
return type(entry) == "table" and entry.dp ~= nil and entry.datatype ~= nil
end
local function is_datapoint_mapping_list(value)
if type(value) ~= "table" or value[1] == nil then
return false
end
local count = 0
for _, entry in ipairs(value) do
if not is_datapoint_mapping(entry) then
return false
end
count = count + 1
end
return count > 0
end
local function split_mapping_entries(entries)
local datapoints = {}
local zcl_clusters = {}
local unknown = {}
if type(entries) ~= "table" then
return datapoints, zcl_clusters, unknown
end
for _, entry in ipairs(entries) do
if is_zcl_mapping(entry) then
zcl_clusters[#zcl_clusters + 1] = entry
elseif is_datapoint_mapping(entry) then
datapoints[#datapoints + 1] = entry
else
unknown[#unknown + 1] = entry
end
end
return datapoints, zcl_clusters, unknown
end
local function normalize_structured_entry(definitions_or_table)
local entry = copy_entry_fields(definitions_or_table)
local list = indexed_entries(definitions_or_table)
local datapoints, zcl_clusters, unknown = split_mapping_entries(list)
if #unknown == 0 and (#datapoints > 0 or #zcl_clusters > 0) then
clear_indexed_entries(entry)
entry.datapoints = append_entries(entry.datapoints, datapoints)
entry.zcl_clusters = append_entries(entry.zcl_clusters, zcl_clusters)
end
return entry
end
function device_registry_helpers.create_fingerprint(manufacturer_name, model_name)
return {
manufacturer = normalize_fingerprint_part(manufacturer_name),
model = normalize_fingerprint_part(model_name),
}
end
function device_registry_helpers.create_model_fingerprint(model_name)
return {
model = normalize_fingerprint_part(model_name),
}
end
function device_registry_helpers.create_fingerprints(model_name, manufacturer_names)
local fingerprint_list = {}
for _, manufacturer_name in ipairs(manufacturer_names) do
local fingerprint_manufacturer = normalize_fingerprint_part(manufacturer_name)
local fingerprint_model = normalize_fingerprint_part(model_name)
local inline_manufacturer, inline_model = string.match(manufacturer_name, "^(.-):(.+)$")
if inline_manufacturer ~= nil and inline_model ~= nil then
fingerprint_manufacturer = normalize_fingerprint_part(inline_manufacturer)
fingerprint_model = normalize_fingerprint_part(inline_model)
end
fingerprint_list[#fingerprint_list + 1] = device_registry_helpers.create_fingerprint(fingerprint_manufacturer, fingerprint_model)
end
return fingerprint_list
end
function device_registry_helpers.definition_registry()
local device_definitions = {}
local function register_device_definition(definitions_or_table, fingerprint_list)
local entry = nil
local datapoints, zcl_clusters, unknown = split_mapping_entries(definitions_or_table)
if has_named_fields(definitions_or_table) then
entry = normalize_structured_entry(definitions_or_table)
elseif #unknown == 0 and (#datapoints > 0 or #zcl_clusters > 0) then
entry = {}
if #datapoints > 0 then
entry.datapoints = datapoints
end
if #zcl_clusters > 0 then
entry.zcl_clusters = zcl_clusters
end
elseif is_zcl_mapping_list(definitions_or_table) then
entry = {
zcl_clusters = definitions_or_table,
}
else
entry = {
datapoints = definitions_or_table,
}
end
entry.fingerprints = fingerprint_list
device_definitions[#device_definitions + 1] = entry
end
return device_definitions, register_device_definition
end
return device_registry_helpers
