# 2026-10-11T18:49:44.870912955
import vitis

client = vitis.create_client()
client.set_workspace(path="lesson_15")

comp = client.create_hls_component(name = "moving_max_component",cfg_file = ["hls_config.cfg"],template = "empty_hls_component")

cfg = client.get_config_file(path="/home/serhii/workspace/fpga/fpga_dev_curses/lesson_15/moving_max_component/hls_config.cfg")

cfg.set_value(section="hls", key="syn.compile.pipeline_loops", value="0")

comp = client.get_component(name="moving_max_component")
comp.run(operation="C_SIMULATION")

comp.run(operation="SYNTHESIS")

cfg.set_value(section="hls", key="syn.top", value="moving_max")

comp.run(operation="SYNTHESIS")

comp.run(operation="C_SIMULATION")

comp.run(operation="SYNTHESIS")

comp.run(operation="SYNTHESIS")

comp.run(operation="SYNTHESIS")

comp.run(operation="CO_SIMULATION")

cfg.set_value(section="hls", key="cosim.wave_debug", value="1")

comp.run(operation="C_SIMULATION")

comp.run(operation="SYNTHESIS")

comp.run(operation="CO_SIMULATION")

comp.run(operation="C_SIMULATION")

comp.run(operation="SYNTHESIS")

comp.run(operation="CO_SIMULATION")

comp.run(operation="PACKAGE")

