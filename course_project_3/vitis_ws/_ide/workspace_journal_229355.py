# 2026-10-18T13:26:35.278892195
import vitis

client = vitis.create_client()
client.set_workspace(path="vitis_ws")

platform = client.create_platform_component(name = "driver_hub_75",hw_design = "$COMPONENT_LOCATION/../../driver_hub_75/design_1_wrapper.xsa",os = "standalone",cpu = "microblaze_0",domain_name = "standalone_microblaze_0",compiler = "gcc")

platform = client.get_component(name="driver_hub_75")
status = platform.build()

status = platform.build()

comp = client.create_app_component(name="hello_world",platform = "$COMPONENT_LOCATION/../driver_hub_75/export/driver_hub_75/driver_hub_75.xpfm",domain = "standalone_microblaze_0",template = "hello_world")

status = platform.build()

comp = client.get_component(name="hello_world")
comp.build()

client.delete_component(name="hello_world")

comp = client.create_app_component(name="app_sym_test",platform = "$COMPONENT_LOCATION/../driver_hub_75/export/driver_hub_75/driver_hub_75.xpfm",domain = "standalone_microblaze_0",template = "hello_world")

status = platform.build()

comp = client.get_component(name="app_sym_test")
comp.build()

status = platform.build()

comp.build()

comp.set_app_config(key = "USER_COMPILE_SOURCES", values = ["helloworld.c", "platform.c", "/home/serhii/workspace/fpga/fpga_dev_curses/course_project_3/vitis_ws/app_sym_test/src/app_main.c"])

comp.set_app_config(key = "USER_COMPILE_SOURCES", values = ["platform.c", "app_main.c"])

comp.set_app_config(key = "USER_COMPILE_SOURCES", values = ["platform.c", "app_main.c", "/home/serhii/workspace/fpga/fpga_dev_curses/course_project_3/vitis_ws/app_sym_test/src/hub75_driver.c"])

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

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

