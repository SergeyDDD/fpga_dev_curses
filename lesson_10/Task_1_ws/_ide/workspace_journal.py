# 2026-09-22T23:21:08.786799457
import vitis

client = vitis.create_client()
client.set_workspace(path="Task_1_ws")

platform = client.get_component(name="platform")
status = platform.build()

comp = client.get_component(name="hello_world")
comp.build()

vitis.dispose()

