# 2026-10-19T22:41:33.052163377
import vitis

client = vitis.create_client()
client.set_workspace(path="vitis_ws")

platform = client.get_component(name="driver_hub_75")
status = platform.update_hw(hw_design = "$COMPONENT_LOCATION/../../driver_hub_75/design_1_wrapper.xsa")

status = platform.build()

status = platform.build()

comp = client.get_component(name="app_sym_test")
comp.build()

comp = client.create_app_component(name="app_hub_75",platform = "$COMPONENT_LOCATION/../driver_hub_75/export/driver_hub_75/driver_hub_75.xpfm",domain = "standalone_microblaze_0",template = "hello_world")

comp = client.get_component(name="app_hub_75")
comp.set_app_config(key = "USER_COMPILE_SOURCES", values = ["ui_graph.c", "platform.c"])

comp.set_app_config(key = "USER_COMPILE_SOURCES", values = ["ui_graph.c", "platform.c", "/home/serhii/workspace/fpga/fpga_dev_curses/course_project_3/vitis_ws/app_hub_75/src/ui_text.c"])

comp.set_app_config(key = "USER_COMPILE_SOURCES", values = ["ui_graph.c", "platform.c", "ui_text.c"])

comp.set_app_config(key = "USER_COMPILE_SOURCES", values = ["ui_graph.c", "platform.c", "ui_text.c", "/home/serhii/workspace/fpga/fpga_dev_curses/course_project_3/vitis_ws/app_hub_75/src/app_main.c"])

comp.set_app_config(key = "USER_COMPILE_SOURCES", values = ["ui_graph.c", "platform.c", "ui_text.c", "app_main.c", "/home/serhii/workspace/fpga/fpga_dev_curses/course_project_3/vitis_ws/app_hub_75/src/hub75_driver.c"])

comp.set_app_config(key = "USER_COMPILE_SOURCES", values = ["ui_graph.c", "platform.c", "ui_text.c", "app_main.c", "hub75_driver.c"])

status = platform.build()

comp.build()

status = platform.build()

comp.build()

comp.set_app_config(key = "USER_COMPILE_SOURCES", values = ["/home/serhii/workspace/fpga/fpga_dev_curses/course_project_3/vitis_ws/app_hub_75/src/app_main.c"])

comp.set_app_config(key = "USER_COMPILE_SOURCES", values = ["/home/serhii/workspace/fpga/fpga_dev_curses/course_project_3/vitis_ws/app_hub_75/src/app_main.c", "/home/serhii/workspace/fpga/fpga_dev_curses/course_project_3/vitis_ws/app_hub_75/src/hub75_driver.c", "/home/serhii/workspace/fpga/fpga_dev_curses/course_project_3/vitis_ws/app_hub_75/src/platform.c", "/home/serhii/workspace/fpga/fpga_dev_curses/course_project_3/vitis_ws/app_hub_75/src/ui_graph.c", "/home/serhii/workspace/fpga/fpga_dev_curses/course_project_3/vitis_ws/app_hub_75/src/ui_text.c"])

status = platform.build()

comp.build()

comp.set_app_config(key = "USER_INCLUDE_DIRECTORIES", values = ["/home/serhii/workspace/fpga/fpga_dev_curses/course_project_3/vitis_ws/app_hub_75/src"])

vitis.dispose()

