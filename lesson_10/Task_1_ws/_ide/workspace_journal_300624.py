# 2026-09-20T21:09:51.409602209
import vitis

client = vitis.create_client()
client.set_workspace(path="Task_1_ws")

platform = client.create_platform_component(name = "platform",hw_design = "$COMPONENT_LOCATION/../../Task_1/design_1_wrapper.xsa",os = "standalone",cpu = "ps7_cortexa9_0",domain_name = "standalone_ps7_cortexa9_0",compiler = "gcc")

platform = client.get_component(name="platform")
status = platform.update_hw(hw_design = "$COMPONENT_LOCATION/../../Task_1/design_1_wrapper.xsa")

domain = platform.get_domain(name="zynq_fsbl")

status = domain.regenerate()

status = domain.set_config(option = "os", param = "standalone_stdin", value = "ps7_uart_1")

status = domain.set_config(option = "os", param = "standalone_stdout", value = "ps7_uart_1")

status = domain.regenerate()

domain = platform.get_domain(name="standalone_ps7_cortexa9_0")

status = domain.set_config(option = "os", param = "standalone_stdin", value = "ps7_uart_1")

status = domain.set_config(option = "os", param = "standalone_stdout", value = "ps7_uart_1")

status = domain.regenerate()

status = platform.build()

comp = client.create_app_component(name="hello_world",platform = "$COMPONENT_LOCATION/../platform/export/platform/platform.xpfm",domain = "standalone_ps7_cortexa9_0",template = "hello_world")

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

