//
//  TestLabel.m
//  Transient Events
//
//  Created by Steven L Ryland on 12/6/11.
//  Copyright (c) 2011 Diffraction Limited Design LLC. All rights reserved.
//

#import "UnderlinedUILabel.h"

@implementation UnderlinedUILabel

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
    CGContextSetLineWidth(ctx, 1.0f);
    
    CGSize stringSize = [self.text sizeWithFont:self.font];
    CGRect bounds = CGRectMake(self.frame.origin.x, 
                                   self.frame.origin.y, 
                                   stringSize.width, stringSize.height);

    
    CGContextMoveToPoint(ctx, 0, bounds.size.height - 1);
    CGContextAddLineToPoint(ctx, bounds.size.width, bounds.size.height - 1);
    
    CGContextStrokePath(ctx);
    
    [super drawRect:rect];  
}

@end
