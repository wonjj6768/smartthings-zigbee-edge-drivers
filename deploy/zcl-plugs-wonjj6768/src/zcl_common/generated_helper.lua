local function load_generated_helper(zcl)
local cluster_base = require "st.zigbee.cluster_base"
local generated_clusters = require "st.zigbee.generated.zcl_clusters"
local cluster_cache = {}
local cluster_name_cache = {}
local attribute_cache = {}
local attribute_name_cache = {}
local server_command_cache = {}
local client_command_cache = {}
local dynamic_attribute_cache = {}
local function cache_key(cluster_id, item_id)
return string.format("%04X:%04X", cluster_id, item_id)
end
local function get_cluster(cluster_id)
local cached = cluster_cache[cluster_id]
if cached ~= nil then
return cached
end
local cluster = generated_clusters.get_cluster_from_id(cluster_id)
cluster_cache[cluster_id] = cluster or false
return cluster
end
local function get_cluster_by_name(cluster_name)
local cached = cluster_name_cache[cluster_name]
if cached ~= nil then
return cached
end
local cluster = generated_clusters[cluster_name]
cluster_name_cache[cluster_name] = cluster or false
if cluster ~= nil and cluster ~= false and cluster.ID ~= nil then
cluster_cache[cluster.ID] = cluster
end
return cluster
end
local function get_attribute(cluster_id, attribute_id)
local key = cache_key(cluster_id, attribute_id)
local cached = attribute_cache[key]
if cached ~= nil then
return cached
end
local cluster = get_cluster(cluster_id)
local attribute = nil
if cluster ~= nil and cluster ~= false then
local attr_name = cluster.attr_id_map and cluster.attr_id_map()[attribute_id] or nil
if attr_name ~= nil and cluster.server and cluster.server.attributes then
attribute = cluster.server.attributes[attr_name]
end
end
attribute_cache[key] = attribute or false
return attribute
end
local function get_attribute_by_name(cluster_name, attribute_name)
local key = string.format("%s:%s", tostring(cluster_name), tostring(attribute_name))
local cached = attribute_name_cache[key]
if cached ~= nil then
return cached
end
local attribute = nil
local cluster = get_cluster_by_name(cluster_name)
if cluster ~= nil and cluster ~= false and cluster.server and cluster.server.attributes then
attribute = cluster.server.attributes[attribute_name]
if attribute ~= nil and attribute ~= false and attribute.ID ~= nil then
attribute_cache[cache_key(cluster.ID, attribute.ID)] = attribute
end
end
attribute_name_cache[key] = attribute or false
return attribute
end
local function get_command(cluster_id, command_id, direction, cache)
local key = cache_key(cluster_id, command_id)
local cached = cache[key]
if cached ~= nil then
return cached
end
local cluster = get_cluster(cluster_id)
local command = nil
if cluster ~= nil and cluster ~= false then
local name = direction == "client" and cluster.client_id_map and cluster.client_id_map()[command_id]
or direction == "server" and cluster.server_id_map and cluster.server_id_map()[command_id]
or nil
if name ~= nil and cluster[direction] and cluster[direction].commands then
command = cluster[direction].commands[name]
end
end
cache[key] = command or false
return command
end
function zcl.get_generated_cluster(cluster_id)
local cluster = get_cluster(cluster_id)
return cluster ~= false and cluster or nil
end
function zcl.get_generated_cluster_by_name(cluster_name)
local cluster = get_cluster_by_name(cluster_name)
return cluster ~= false and cluster or nil
end
function zcl.get_generated_cluster_id(cluster_name)
local cluster = zcl.get_generated_cluster_by_name(cluster_name)
return cluster and cluster.ID or nil
end
function zcl.get_generated_attribute(cluster_id, attribute_id)
local attribute = get_attribute(cluster_id, attribute_id)
return attribute ~= false and attribute or nil
end
function zcl.get_generated_attribute_by_name(cluster_name, attribute_name)
local attribute = get_attribute_by_name(cluster_name, attribute_name)
return attribute ~= false and attribute or nil
end
function zcl.get_generated_server_command(cluster_id, command_id)
local command = get_command(cluster_id, command_id, "server", server_command_cache)
return command ~= false and command or nil
end
function zcl.get_generated_client_command(cluster_id, command_id)
local command = get_command(cluster_id, command_id, "client", client_command_cache)
return command ~= false and command or nil
end
function zcl.build_dynamic_attribute(cluster_id, attribute_id, base_type, writable, attribute_name, is_complex)
local cluster = get_cluster(cluster_id)
if cluster == nil or cluster == false or type(base_type) ~= "table" or base_type.ID == nil then
return nil
end
local key = table.concat({
tostring(cluster_id),
tostring(attribute_id),
tostring(base_type.ID),
writable == false and "0" or "1",
is_complex == true and "1" or "0",
tostring(attribute_name or ""),
}, ":")
local cached = dynamic_attribute_cache[key]
if cached ~= nil then
return cached ~= false and cached or nil
end
local attribute = cluster_base.build_cluster_attribute(
cluster,
attribute_id,
attribute_name or string.format("Attribute%04X", attribute_id),
base_type,
writable ~= false,
is_complex == true
)
dynamic_attribute_cache[key] = attribute or false
return attribute
end
end
return load_generated_helper
