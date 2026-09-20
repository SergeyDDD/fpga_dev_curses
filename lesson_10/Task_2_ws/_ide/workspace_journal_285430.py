# 2026-09-21T21:38:43.262954607
import vitis

client = vitis.create_client()
client.set_workspace(path="Task_2_ws")

platform = client.create_platform_component(name = "platform",hw_design = "$COMPONENT_LOCATION/../../Task_2/design_1_wrapper.xsa",os = "standalone",cpu = "microblaze_0",domain_name = "standalone_microblaze_0",compiler = "gcc")

platform = client.get_component(name="platform")
status = platform.build()

comp = client.create_app_component(name="hello_world",platform = "$COMPONENT_LOCATION/../platform/export/platform/platform.xpfm",domain = "standalone_microblaze_0",template = "hello_world")

status = platform.build()

comp = client.get_component(name="hello_world")
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

status = platform.update_hw(hw_design = "$COMPONENT_LOCATION/../../Task_2/design_1_wrapper.xsa")

domain = platform.get_domain(name="standalone_microblaze_0")

status = domain.regenerate()

status = domain.regenerate()

status = platform.build()

status = comp.clean()

status = platform.build()

comp.build()

vitis.dispose()

