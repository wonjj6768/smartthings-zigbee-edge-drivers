local e,g,c=require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family"local b=e.converter
local d,a=c.definition_registry()
local function f(name)
return assert(g[name],"missing Wave15 BOX switch emitter: "..name)()
end
local h={profile="switches-wave15-box-erc2202z",package_group="rf-dual-controller",magic_packet=true,query_on_configure=false,time_start="off",datapoints={e.dp_on_off(19,{name="switch",component="main",transaction=1,emit=g.switch()}),e.dp_on_off(20,{name="switch",component="switch2",transaction=1,emit=g.switch()}),e.dp_enum(102,{name="erc_two_record_rf",transaction=1,converter=b.lookup_from_to{record_l1=0,record_l2=1},emit=f"ercTwoRecordRf"}),e.dp_enum(102,{name="erc_two_clear_rf",transaction=1,converter=b.lookup_from_to{clear_l1=2,clear_l2=3},emit=f"ercTwoClearRf"}),e.dp_enum(103,{name="erc_two_rf_status",read_only=true,transaction=1,converter=b.from_only(b.lookup_value{[0]="ok",[1]="error"}),emit=f"ercTwoRfStatus"})}}a(h,c.create_fingerprints("TS0601",{"_TZE200_o7vduidq"}))return{id="ef00.switches.wave15_box",registrations=d}
