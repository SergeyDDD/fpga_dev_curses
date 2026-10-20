# 2026-10-19T23:51:11.701822380
import vitis

client = vitis.create_client()
client.set_workspace(path="vitis_ws")

comp = client.get_component(name="app_hub_75")
comp.set_app_config(key = "USER_COMPILE_SOURCES", values = ["/home/serhii/workspace/fpga/fpga_dev_curses/course_project_3/vitis_ws/app_hub_75/src/app_main.c"])

platform = client.get_component(name="driver_hub_75")
status = platform.build()

comp.build()

status = platform.build()

comp = client.get_component(name="app_sym_test")
comp.build()

status = platform.build()

comp = client.get_component(name="app_hub_75")
comp.build()

client.delete_component(name="app_hub_75")

client.delete_component(name="app_sym_test")

status = platform.build()

comp = client.get_component(name="app_sym_test")
comp.build()

comp = client.create_app_component(name="app_hub_75",platform = "$COMPONENT_LOCATION/../driver_hub_75/export/driver_hub_75/driver_hub_75.xpfm",domain = "standalone_microblaze_0",template = "hello_world")

comp = client.get_component(name="app_hub_75")
comp.set_app_config(key = "USER_COMPILE_SOURCES", values = ["platform.c"])

comp.set_app_config(key = "USER_COMPILE_SOURCES", values = ["platform.c", "/home/serhii/workspace/fpga/fpga_dev_curses/course_project_3/vitis_ws/app_hub_75/src/app_main.c"])

status = platform.build()

comp.build()

comp.set_app_config(key = "USER_INCLUDE_DIRECTORIES", values = [""])

comp.set_app_config(key = "USER_COMPILE_SOURCES", values = ["platform.c", "app_main.c", "/home/serhii/workspace/fpga/fpga_dev_curses/course_project_3/vitis_ws/app_hub_75/src/hub75_driver.c", "/home/serhii/workspace/fpga/fpga_dev_curses/course_project_3/vitis_ws/app_hub_75/src/ui_graph.c", "/home/serhii/workspace/fpga/fpga_dev_curses/course_project_3/vitis_ws/app_hub_75/src/ui_text.c"])

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

status = platform.build()

comp.build()

vitis.dispose()

