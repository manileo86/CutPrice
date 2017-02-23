//
//  NumberSelectionView.m
//  Algos
//
//  Created by Manigandan Parthasarathi on 10/07/13.
//  Copyright (c) 2013 Manigandan Parthasarathi. All rights reserved.
//

#import "NumberSelectionView.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>

@interface NumberSelectionView ()
{
    NSUInteger currentOfferLabelTag;
    CGRect touchRect;
}

@property(nonatomic, strong) IBOutlet UIView *numberView;
@property(nonatomic, strong) IBOutlet UIView *offerView;
@property(nonatomic, strong) IBOutlet UILabel *offerLabel;
@property(nonatomic, strong) IBOutlet UILabel *percentLabel;

@end

@implementation NumberSelectionView

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

-(void)initControls
{
    _numberView.layer.shadowColor = [UIColor blackColor].CGColor;
    _numberView.layer.shadowOffset = CGSizeMake(-3.0f, 0.0f);
    _numberView.layer.shadowOpacity = 0;
    
    touchRect = CGRectMake(0, 0, 88.0f, 100.0f);
    currentOfferLabelTag = 2;
    
    _offerLabel.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    _offerLabel.layer.shadowOffset = CGSizeMake(-1.0f, -1.0f);
    _offerLabel.layer.shadowOpacity = 0.5f;
    
    // Build a triangular path
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:(CGPoint){88.0f, 0}];
    [path addLineToPoint:(CGPoint){88.0f,88.0f}];
    [path addLineToPoint:(CGPoint){0,0}];
    
    [path closePath];
    // Create a CAShapeLayer with this triangular path
    // Same size as the original View
    CAShapeLayer *mask = [CAShapeLayer new];
    mask.frame = _offerView.bounds;
    mask.path = path.CGPath;
    
    // Mask the View's layer with this shape
    _offerView.layer.mask = mask;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchPoint = [touch locationInView:_offerView];
    
    if(CGRectContainsPoint(touchRect, touchPoint))
    {
        AudioServicesPlaySystemSound (systemSoundID);
        [UIView animateWithDuration:0.20f
                         animations:^{
                             CGRect frame = _numberView.frame;
                             frame.origin.x = 0.0f;
                             _numberView.frame = frame;
                             
                             frame = _offerLabel.frame;
                             frame.origin.x = 15.0f;
                             _offerLabel.frame = frame;
                             
                             frame = _percentLabel.frame;
                             frame.origin.y = 20.0f;
                             _percentLabel.frame = frame;
                         }
                         completion:^(BOOL finished) {
                             _numberView.layer.shadowOpacity = 0.75f;
                         }];
        
        if(_delegate && [_delegate respondsToSelector:@selector(numbersShown:)])
        {
            UILabel *label = (UILabel*)[_numberView viewWithTag:currentOfferLabelTag];
            label.backgroundColor = [UIColor colorWithRed:221.0f/255.0f green:221.0f/255.0f blue:221.0f/255.0f alpha:1.0f];
            label.textColor = [UIColor colorWithRed:254.0f/255.0f green:51.0f/255.0f blue:105.0f/255.0f alpha:1.0f];
            [_delegate numbersShown:label.frame.origin.y];
        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchPoint = [touch locationInView:_numberView];
    
    if(CGRectContainsPoint(_offerLabel.frame, touchPoint))
    {
        return;
    }
    
    for(int i=0; i<13; i++)
    {
        UILabel *label = (UILabel*)[_numberView viewWithTag:i];
        if(CGRectContainsPoint(label.frame, touchPoint))
        {
            label.backgroundColor = [UIColor colorWithRed:221.0f/255.0f green:221.0f/255.0f blue:221.0f/255.0f alpha:1.0f];
            label.textColor = [UIColor colorWithRed:254.0f/255.0f green:51.0f/255.0f blue:105.0f/255.0f alpha:1.0f];
            _offerLabel.text = [NSString stringWithFormat:@"%@", label.text];
            
            if(_delegate && [_delegate respondsToSelector:@selector(numberSelectionMoved:number:)])
            {
                [_delegate numberSelectionMoved:label.frame.origin.y number:[label.text integerValue]];
            }
            
            currentOfferLabelTag = label.tag;
        }
        else
        {
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor whiteColor];
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    AudioServicesPlaySystemSound (systemSoundID);
    NSInteger num = -1;
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchPoint = [touch locationInView:_numberView];
    
    for(int i=0; i<13; i++)
    {
        UILabel *label = (UILabel*)[_numberView viewWithTag:i];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        if(CGRectContainsPoint(label.frame, touchPoint) && !_numberView.hidden)
        {
            currentOfferLabelTag = label.tag;
            num = [label.text integerValue];
        }
    }
    
    [UIView animateWithDuration:0.20f
                     animations:^{
                         CGRect frame = _numberView.frame;
                         frame.origin.x = 120.0f;
                         _numberView.frame = frame;
                         
                         frame = _offerLabel.frame;
                         frame.origin.x = 35.0f;
                         _offerLabel.frame = frame;
                         
                         frame = _percentLabel.frame;
                         frame.origin.y = 42.0f;
                         _percentLabel.frame = frame;
                         
                         _numberView.layer.shadowOpacity = 0;
                     }];
    
    if(_delegate && [_delegate respondsToSelector:@selector(numberSelected:)])
    {
        [_delegate numberSelected:num];
    }
    if(num!=-1)
        _offerLabel.text = [NSString stringWithFormat:@"%ld", (long)num];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [UIView animateWithDuration:0.25f
                     animations:^{
                         CGRect frame = _numberView.frame;
                         frame.origin.x = 120.0f;
                         _numberView.frame = frame;
                     }];
    
    if(_delegate && [_delegate respondsToSelector:@selector(numberSelected:)])
    {
        [_delegate numberSelected:-1];
    }
}

@end
