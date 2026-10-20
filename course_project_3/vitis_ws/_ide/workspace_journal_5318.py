# 2026-10-20T00:25:53.975754095
import vitis

client = vitis.create_client()
client.set_workspace(path="vitis_ws")

platform = client.get_component(name="driver_hub_75")
status = platform.build()

comp = client.get_component(name="app_hub_75")
comp.build()

status = platform.build()

comp.build()

vitis.dispose()

