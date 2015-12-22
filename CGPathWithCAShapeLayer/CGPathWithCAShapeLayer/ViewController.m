//
//  ViewController.m
//  CGPathWithCAShapeLayer
//
//  Created by ASHENG on 15/12/22.
//  Copyright © 2015年 ASHENG. All rights reserved.
//

#import "ViewController.h"
#import <CoreText/CoreText.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20.0f, 64.0f,
                                                            CGRectGetWidth(self.view.layer.bounds) - 40.0f,
                                                            CGRectGetWidth(self.view.layer.bounds) - 40.0f)];

    [self.view addSubview:view];
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointZero];
    [bezierPath appendPath:[UIBezierPath bezierPathWithCGPath:[self pathForString:@"Hello"]]];

    CAShapeLayer *pathLayer = [CAShapeLayer layer];
    pathLayer.frame = view.bounds;
    pathLayer.geometryFlipped = YES;
    pathLayer.path = bezierPath.CGPath;
    pathLayer.strokeColor = [UIColor blackColor].CGColor;
    pathLayer.lineWidth = 3.0;
    pathLayer.bounds = CGPathGetBoundingBox(bezierPath.CGPath);
    pathLayer.lineJoin = kCALineJoinBevel;
    pathLayer.fillColor = nil;
    
    [view.layer addSublayer:pathLayer];
    
    // start animation
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 5.0;
    pathAnimation.fromValue =  [NSNumber numberWithFloat:0.f];;
    pathAnimation.toValue =  [NSNumber numberWithFloat:1.0f];;
    [pathLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGPathRef)pathForString:(NSString *)string
{
    CGMutablePathRef mutablePath = CGPathCreateMutable();
    
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:CFBridgingRelease(CTFontCreateWithName(CFSTR("Helvetica-Bold"), 72.0, NULL)), kCTFontAttributeName, nil];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:string attributes:attrs];
    CTLineRef lineRef = CTLineCreateWithAttributedString((CFAttributedStringRef)attrString);
    CFArrayRef runArray = CTLineGetGlyphRuns(lineRef);
    
    for (CFIndex runIndex = 0; runIndex < CFArrayGetCount(runArray); runIndex ++) {
        // Get FONT For this run
        CTRunRef run = CFArrayGetValueAtIndex(runArray, runIndex);
        CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
        
        // for each
        for (CFIndex runGlyphIndex = 0; runGlyphIndex < CTRunGetGlyphCount(run); runGlyphIndex ++) {
            // get Glyph & Glyph-data
            CFRange thisGlyphRange = CFRangeMake(runGlyphIndex, 1);
            CGGlyph glyph;
            CGPoint position;
            CTRunGetGlyphs(run, thisGlyphRange, &glyph);
            CTRunGetPositions(run, thisGlyphRange, &position);
            
            // get path of outline
            {
                CGPathRef letter = CTFontCreatePathForGlyph(runFont, glyph, NULL);
                CGAffineTransform t = CGAffineTransformMakeTranslation(position.x, position.y);
                CGPathAddPath(mutablePath, &t, letter);
            }
        }
    }
    return mutablePath;
}

@end
