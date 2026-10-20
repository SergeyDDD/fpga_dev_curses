# 2026-10-18T17:08:45.641612612
import vitis

client = vitis.create_client()
client.set_workspace(path="vitis_ws")

platform = client.get_component(name="driver_hub_75")
status = platform.update_hw(hw_design = "$COMPONENT_LOCATION/../../driver_hub_75/design_1_wrapper.xsa")

status = platform.build()

status = platform.build()

comp = client.get_component(name="app_sym_test")
comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

vitis.dispose()

