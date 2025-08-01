import os
import ctypes
import numpy as np
import sibylengine as se
se.Configuration.set_config_file(os.path.dirname(os.path.abspath(__file__)) + "/runtime.config")

class RCVPass (se.rdg.ComputePass):
    def __init__(self):
        super().__init__()
        self.init("./_resources/render.slang")
        self.estimator_mode = se.Int32(0)
        self.spp = se.Int32(1)

    def reflect(self, reflector: se.rdg.PassReflection) -> se.rdg.PassReflection:
        reflector.add_output("Color").is_texture()\
            .with_format(se.rhi.TextureFormat.RGBA32_FLOAT)\
            .consume_as_storage_binding_in_compute()
        return reflector
        
    def execute(self, rdrCtx: se.rdg.RenderContext, rdrDat: se.rdg.RenderData):
        # binding the resources to pipeline
        scene = rdrDat.get_scene()
        self.update_binding_scene(rdrCtx, scene)
        color = rdrDat.get_texture("Color")
        self.update_bindings(rdrCtx, [
			["se_scene_tlas", scene.gpu_scene().binding_resource_tlas() ],
            ["rw_output", se.rhi.BindingResource(color.get_uav(0, 0, 1)) ]
        ])
        # prepare push constants
        pConst = se.make_struct("PushConstant", {
            "estimator": ctypes.c_int(self.estimator_mode.get()),
            "random_seed": ctypes.c_int(np.random.randint(0, 1000000)),
            "spp": ctypes.c_int(self.spp.get())
        })

        encoder = self.begin_pass(rdrCtx)
        encoder.push_constants(
            ctypes.addressof(pConst),
            se.rhi.ShaderStageEnum.COMPUTE, 
            0, ctypes.sizeof(pConst)
        )
        encoder.dispatch_workgroups(
            int((color.width() + 31) / 32), 
            int((color.height() + 3) / 4), 1)        
        encoder.end()
        
    def render_ui(self):
        se.imgui.combo("Estimator", self.estimator_mode,  ["PT", "RCV", "HR"])
        se.imgui.drag_int("SPP", self.spp, 1, 1, 1000)
        
class RCVGraph(se.rdg.Graph):
    def __init__(self):
        super().__init__()
        self.fwd_pass = RCVPass()
        self.accum_Pass = se.addon.AccumulatePass()
        self.add_pass(self.fwd_pass, "Render Pass")
        self.add_pass(self.accum_Pass, "Accum Pass")
        self.add_edge("Render Pass", "Color", "Accum Pass", "Input")
        self.mark_output("Accum Pass", "Output")

class EditorApplication(se.EditorApplicationBase):
    def __init__(self):
        super().__init__("Many-Light Example", 1280, 720,
            se.rhi.ContextExtensionEnum.DEBUG_UTILS |
            se.rhi.ContextExtensionEnum.USE_AFTERMATH |
            se.rhi.ContextExtensionEnum.RAY_TRACING)
        
        self.foo_graph = RCVGraph()
        self.foo_graph.set_standard_size(1024, 1024)
        self.foo_graph.build()
        
        self.scene = se.gfx.GFXContext.load_scene_xml("../scenes/livingroom3/scene.xml")
        # self.scene = se.gfx.GFXContext.load_scene_xml("../scenes/livingroom/scene.xml")
        # self.scene = se.gfx.GFXContext.load_scene_xml("../scenes/veachmis/scene.xml")
        se.editor.EditorContext.set_scene_display(self.scene)
        se.editor.EditorContext.set_graph_display(self.foo_graph)

    def on_update(self):
        self.scene.update_scripts()
        self.scene.update_gpu_scene()
        
    def on_command_record(self, encoder: se.rhi.CommandEncoder):
        self.foo_graph.get_render_data().set_scene(self.scene)
        self.foo_graph.execute(encoder)

        if self.foo_graph.get_output():
            se.editor.EditorContext.set_viewport_texture(self.foo_graph.get_output())
            
    def on_finalize(self):
        del self.foo_graph
        del self.scene
    

if __name__ == "__main__":
    app = EditorApplication()
    try: app.run()
    except KeyboardInterrupt: pass
    finally:
        app.end()
        print("Editor application exited gracefully.")