#import <simd/simd.h>
#import "Renderer.h"
#include "imgui/imgui.h"
#include "imgui/examples/imgui_impl_metal.h"
#include "imgui/examples/imgui_impl_osx.h"

@implementation Renderer
{
  NVGcontext* ctx;
}

-(nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)view;
{
  self = [super init];
  if(self) {
    ctx = nvgCreateMTL((__bridge void *)(view.layer), NVG_ANTIALIAS /*| NVG_STENCIL_STROKES*/); // with stencil strokes enabled, strokewidth = 1. is invisible on non-retina screen
    
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGui::StyleColorsDark();
    
    ImGui_ImplMetal_Init(view.device);
  }

  return self;
}

- (void)drawInMTKView:(nonnull MTKView *)view
{
  float w = view.frame.size.width;
  float h = view.frame.size.height;
  float s = [[view window] backingScaleFactor];
  
  ImGuiIO &io = ImGui::GetIO();
  io.DisplaySize.x = w;
  io.DisplaySize.y = h;
  io.DisplayFramebufferScale = ImVec2(s, s);
  
  static float clear_color[4] = { 0.28f, 0.36f, 0.5f, 1.0f };
  id <MTLCommandQueue> commandQueue = (__bridge id <MTLCommandQueue>) mnvgCommandQueue(ctx);
  id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];

  MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
  if (renderPassDescriptor != nil)
  {
  
    mnvgClearWithColor(ctx, nvgRGBAf(clear_color[0], clear_color[1], clear_color[2], clear_color[3]));
    nvgBeginFrame(ctx, w, h, s);
    
    nvgRect(ctx, 10, 10, w - 20, h - 20);
    nvgStrokeWidth(ctx, 1.);
    nvgStrokeColor(ctx, nvgRGBA(0,0,0,255));
    nvgStroke(ctx);
    nvgFill(ctx);
    nvgEndFrame(ctx);
    
//    MTLRenderPassDescriptor* pDesc = [MTLRenderPassDescriptor renderPassDescriptor];
//    pDesc.colorAttachments[0].texture = [drawable texture];
//    pDesc.colorAttachments[0].clearColor = MTLClearColorMake(1.f, 0.f, 0.f, 1.f);
//    pDesc.colorAttachments[0].storeAction = MTLStoreActionStore;
    renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionLoad; //

    id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    [renderEncoder pushDebugGroup:@"ImGui demo"];
    
    // Start the Dear ImGui frame
    ImGui_ImplMetal_NewFrame(renderPassDescriptor);
    ImGui_ImplOSX_NewFrame(view);
    ImGui::NewFrame();

//    ImGui::ShowDemoWindow();
    ImGui::ColorEdit3("clear color", (float*)&clear_color); // Edit 3 floats representing a color

    // Rendering
    ImGui::Render();
    ImDrawData *drawData = ImGui::GetDrawData();
    ImGui_ImplMetal_RenderDrawData(drawData, commandBuffer, renderEncoder);
    
    [renderEncoder popDebugGroup];
    [renderEncoder endEncoding];
    
    [commandBuffer presentDrawable:view.currentDrawable];
  }
  [commandBuffer commit];
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size
{

}

@end
