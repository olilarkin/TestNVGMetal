#import <MetalKit/MetalKit.h>
#include "nanovg.h"
#include "nanovg_mtl.h"

@interface Renderer : NSObject <MTKViewDelegate>

-(nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)view;

@end

