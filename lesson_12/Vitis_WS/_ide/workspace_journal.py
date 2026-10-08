# 2026-10-08T11:17:32.434600515
import vitis

client = vitis.create_client()
client.set_workspace(path="Vitis_WS")

platform = client.create_platform_component(name = "platform",hw_design = "$COMPONENT_LOCATION/../../Task_1/design_1_wrapper.xsa",os = "standalone",cpu = "microblaze_0",domain_name = "standalone_microblaze_0",compiler = "gcc")

comp = client.create_app_component(name="hello_world",platform = "$COMPONENT_LOCATION/../platform/export/platform/platform.xpfm",domain = "standalone_microblaze_0",template = "hello_world")

platform = client.get_component(name="platform")
status = platform.update_hw(hw_design = "$COMPONENT_LOCATION/../../Task_1/design_1_wrapper.xsa")

status = platform.build()

status = platform.build()

status = platform.build()

comp = client.get_component(name="hello_world")
comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

vitis.dispose()

