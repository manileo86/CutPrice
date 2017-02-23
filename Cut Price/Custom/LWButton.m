//
//  LWButton.m
//  MyCalendar
//
//  Created by Manigandan Parthasarathi on 14/10/13.
//  Copyright (c) 2013 Manigandan Parthasarathi. All rights reserved.
//

#import "LWButton.h"

@implementation LWButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initControls];
    }
    return self;
}

-(void)awakeFromNib
{
    [self initControls];
}

-(void)setHideCornerRadius:(BOOL)bHideCornerRadius
{
    self.layer.cornerRadius = 0;
}

-(void)initControls
{
    self.layer.cornerRadius = self.bounds.size.width/2;
    
    _highlightedBgColor = [UIColor colorWithRed:254.0f/255.0f green:51.0f/255.0f blue:105.0f/255.0f alpha:1.0f];
    _bgColor = [UIColor clearColor];
}

- (void) setHighlighted:(BOOL)highlighted
{
    if (highlighted)
    {
        self.backgroundColor = _highlightedBgColor;
    }
    else
    {
        [UIView animateWithDuration:0.35f
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             self.backgroundColor = _bgColor;
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    }
    
    [super setHighlighted:highlighted];
}

@end
