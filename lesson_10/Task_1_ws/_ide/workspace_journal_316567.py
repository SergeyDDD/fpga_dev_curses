# 2026-09-21T01:04:51.637414612
import vitis

client = vitis.create_client()
client.set_workspace(path="Task_1_ws")

platform = client.get_component(name="platform")
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

vitis.dispose()

