//
//  MainViewController.m
//  How Much Off
//
//  Created by Mani on 29/07/14.
//  Copyright (c) 2014 leoAtWorkz. All rights reserved.
//

#import "MainViewController.h"
#import "LWButton.h"
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>
#import <Social/Social.h>

@interface MainViewController ()
{
    NumberSelectionView *numberSelectionView;
    NSUInteger currentOffer;
    NSTimer *typeTimer;
    NSMutableString* currentVal;
    
    BOOL bShowingMore;
    UITapGestureRecognizer *viewTapGesture;
    BOOL bAnimatingCursor;
}

@property(nonatomic, strong) IBOutlet UIView *offerPriceView;
@property(nonatomic, strong) IBOutlet UILabel *offerPriceLabel;
@property(nonatomic, strong) IBOutlet UILabel *discountLabel;
@property(nonatomic, strong) IBOutlet UILabel *actualPriceLabel;
@property(nonatomic, strong) IBOutlet UIView *dividerLine;
@property(nonatomic, strong) IBOutlet UIView *numberView;

@property(nonatomic, strong) IBOutlet UIView *topShadowView;
@property(nonatomic, strong) IBOutlet UIView *bottomShadowView;
@property(nonatomic, strong) IBOutlet UIView *rightShadowView;
@property(nonatomic, strong) IBOutlet UIView *leftShadowView;

@property(nonatomic, strong) IBOutlet UIView *holderView;
@property(nonatomic, strong) IBOutlet UIView *moreView;
@property(nonatomic, strong) IBOutlet UIButton *moreButton;
@property(nonatomic, strong) IBOutlet LWButton *rateButton;
@property(nonatomic, strong) IBOutlet LWButton *fbButton;
@property(nonatomic, strong) IBOutlet LWButton *twButton;
@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)prefersStatusBarHidden {return YES;}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    currentOffer = 10;
    currentVal = [NSMutableString stringWithString: @"0"];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:_topShadowView.bounds];
    _topShadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    _topShadowView.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    _topShadowView.layer.shadowOpacity = 0.5f;
    _topShadowView.layer.shadowPath = shadowPath.CGPath;
    
    shadowPath = [UIBezierPath bezierPathWithRect:_bottomShadowView.bounds];
    _bottomShadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    _bottomShadowView.layer.shadowOffset = CGSizeMake(0.0f, -3.0f);
    _bottomShadowView.layer.shadowOpacity = 0.5f;
    _bottomShadowView.layer.shadowPath = shadowPath.CGPath;
    
    shadowPath = [UIBezierPath bezierPathWithRect:_leftShadowView.bounds];
    _leftShadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    _leftShadowView.layer.shadowOffset = CGSizeMake(3.0f, 0.0f);
    _leftShadowView.layer.shadowOpacity = 0.5f;
    _leftShadowView.layer.shadowPath = shadowPath.CGPath;
    
    shadowPath = [UIBezierPath bezierPathWithRect:_rightShadowView.bounds];
    _rightShadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    _rightShadowView.layer.shadowOffset = CGSizeMake(-3.0f, 0.0f);
    _rightShadowView.layer.shadowOpacity = 0.5f;
    _rightShadowView.layer.shadowPath = shadowPath.CGPath;
    
    _holderView.layer.shadowColor = [UIColor blackColor].CGColor;
    _holderView.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    _holderView.layer.shadowOpacity = 0.75f;
    
    NSString *nib = IS_IPHONE_5?@"NumberSelectionView":IS_IPHONE?@"NumberSelectionView_Small":@"NumberSelectionView";
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:nib owner:self options:nil];
    numberSelectionView = (NumberSelectionView*)[topLevelObjects objectAtIndex:0];
    numberSelectionView.frame = CGRectMake(232.0f, 0, 88.0f, IS_IPHONE_5?568.0f:480.0f);
    numberSelectionView.delegate = self;
    [self.view insertSubview:numberSelectionView belowSubview:_numberView];
    
    _actualPriceLabel.frame = CGRectMake(10.0f, 100.0f, 200.0f, 40.0f);
    _offerPriceLabel.alpha = 0;
    _discountLabel.alpha = 0;
    _dividerLine.alpha = 0;
    
    //_moreButton.layer.cornerRadius = _moreButton.bounds.size.width/2;
    
    _rateButton.highlightedBgColor = [UIColor lightGrayColor];
    _rateButton.bgColor = [UIColor colorWithWhite:0.000 alpha:0.450];
    _rateButton.hideCornerRadius = YES;
    
    _fbButton.highlightedBgColor = [UIColor lightGrayColor];
    _fbButton.bgColor = [UIColor colorWithWhite:0.000 alpha:0.300];
    _fbButton.hideCornerRadius = YES;
    
    _twButton.highlightedBgColor = [UIColor lightGrayColor];
    _twButton.bgColor = [UIColor colorWithWhite:0.000 alpha:0.150];
    _twButton.hideCornerRadius = YES;
    
    _actualPriceLabel.text = @"|";
    _actualPriceLabel.alpha = 0;
    bAnimatingCursor = YES;
    [UIView animateWithDuration:0.5f delay:0.2f options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
        _actualPriceLabel.alpha = 1;
    } completion:nil];
    
    [UIView animateWithDuration:0.35f delay:0.75f options:UIViewAnimationOptionAllowUserInteraction animations:^{
        CGRect frame = _moreButton.frame;
        frame.origin.y = self.view.bounds.size.height-_moreButton.bounds.size.height;
        _moreButton.frame = frame;
    } completion:nil];
}

-(void)typingStartAnimation
{
    if(typeTimer)
    {
        [typeTimer invalidate];
        typeTimer = nil;
    }
    numberSelectionView.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.2f
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         _actualPriceLabel.frame = CGRectMake(10.0f, 100.0f, 200.0f, 40.0f);
                         _offerPriceLabel.alpha = 0;
                         _discountLabel.alpha = 0;
                         _dividerLine.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         typeTimer = [NSTimer scheduledTimerWithTimeInterval:0.4f target:self selector:@selector(typingEndAnimation) userInfo:nil repeats:NO];
                     }];
}

-(void)typingEndAnimation
{
    float aPrice = [_actualPriceLabel.text floatValue];
    if(aPrice>0)
    {
        [UIView animateWithDuration:0.2f
                         animations:^{
                             _actualPriceLabel.frame = CGRectMake(10.0f, 44.0f, 200.0f, 40.0f);
                             _offerPriceLabel.alpha = 1.0f;
                             _discountLabel.alpha = 1.0f;
                             _dividerLine.alpha = 1.0f;
                             
                             
                         }
                         completion:^(BOOL finished) {
                             numberSelectionView.userInteractionEnabled = YES;
                         }];
    }
    else
    {
        numberSelectionView.userInteractionEnabled = YES;
    }
}

-(void)updatePrices
{
    if([currentVal isEqualToString:@"0"])
    {
        _actualPriceLabel.text = @"|";
        _actualPriceLabel.alpha = 0.1;
        bAnimatingCursor = YES;
        [UIView animateWithDuration:0.5f delay:0.2f options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
            _actualPriceLabel.alpha = 1;
        } completion:nil];
    }
    else
    {
        _actualPriceLabel.text = currentVal;
        if(bAnimatingCursor)
        {
            bAnimatingCursor = NO;
            [_actualPriceLabel.layer removeAllAnimations];
        }
    }
    
    float aPrice = [currentVal floatValue];
    float offer = aPrice * currentOffer/100;
    float oPrice = aPrice-offer;
    
    _offerPriceLabel.text = [NSString stringWithFormat:@"%.2f", oPrice];
    NSRange range = [_offerPriceLabel.text rangeOfString:@"." options:(NSCaseInsensitiveSearch)];
    NSString *decimals = [_offerPriceLabel.text substringFromIndex:range.location+1];
    if([decimals isEqualToString:@"00"])
    {
        _offerPriceLabel.text = [_offerPriceLabel.text substringToIndex:range.location];
    }
    
    _discountLabel.text = [NSString stringWithFormat:@"%.2f", offer*-1];
    range = [_discountLabel.text rangeOfString:@"." options:(NSCaseInsensitiveSearch)];
    decimals = [_discountLabel.text substringFromIndex:range.location+1];
    if([decimals isEqualToString:@"00"])
    {
        _discountLabel.text = [_discountLabel.text substringToIndex:range.location];
    }
}

-(IBAction)numberPressed:(id)sender
{
    AudioServicesPlaySystemSound (systemSoundID);
    
    NSRange range = [currentVal rangeOfString:@"." options:(NSCaseInsensitiveSearch)];
    if(range.location != NSNotFound)
    {
        NSString *decimals = [currentVal substringFromIndex:range.location+1];
        if(decimals.length>=2)
        {
            return;
        }
    }
    
    if(currentVal.length>=9)
    {
        return;
    }
    
    [self typingStartAnimation];
    NSMutableString * str = (NSMutableString *)[sender currentTitle];
	if ([currentVal isEqualToString:@"0"])
	{
		currentVal = str;
	}
	else
    {
		currentVal = [NSMutableString stringWithString:[currentVal stringByAppendingString:str]];
        [_actualPriceLabel.layer removeAllAnimations];
	}
    [self updatePrices];
}

-(IBAction)dotPressed:(id)sender
{
    AudioServicesPlaySystemSound (systemSoundID);
    
    NSRange range = [currentVal rangeOfString:@"." options:(NSCaseInsensitiveSearch)];
    if (range.location == NSNotFound) {
        [self typingStartAnimation];
        currentVal = [NSMutableString stringWithString:[currentVal stringByAppendingString:@"."]];
        [self updatePrices];
    }
}

-(IBAction)deletePressed:(id)sender
{
    AudioServicesPlaySystemSound (systemSoundID);
    
    NSString *str = currentVal;
    NSUInteger length = str.length;
    currentVal = [NSMutableString stringWithString:[str substringToIndex:length-1]];
    
    [self typingStartAnimation];
    
    if(length>2)
    {
        NSUInteger cLength = currentVal.length;
        NSString *lastChar = [currentVal substringWithRange:NSMakeRange(cLength-1, 1)];
        if([lastChar isEqualToString:@"."])
        {
            currentVal = [NSMutableString stringWithString:[str substringToIndex:cLength-1]];
        }
    }
    
    if([currentVal isEqualToString:@""])
    {
        currentVal = [NSMutableString stringWithString:@"0"];
    }
    [self updatePrices];
}

#pragma mark - NumberSelectionView delegate

-(void)numbersShown:(CGFloat)yPos
{
    float aPrice = [_actualPriceLabel.text floatValue];
    _offerPriceView.alpha = (aPrice>0);
    
    _actualPriceLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:20.0f];
    _offerPriceLabel.alpha = 1.0f;
    [UIView animateWithDuration:0.15f
                     animations:^{
                         CGRect frame = _offerPriceView.frame;
                         frame.origin.y = yPos-34.0f;
                         frame.size.height = 100.0f;
                         _offerPriceView.frame = frame;
                         
                         frame = _moreButton.frame;
                         frame.origin.y = self.view.bounds.size.height;
                         _moreButton.frame = frame;
                         
                         _discountLabel.alpha = 0;
                         
                         _actualPriceLabel.frame = CGRectMake(10.0f, 7.0f, 200.0f, 24.0f);
                         _offerPriceLabel.frame = CGRectMake(10.0f, 56.0f, 200.0f, 40.0f);
                         _dividerLine.frame = CGRectMake(10.0f, 40.0f, 205.0f, 1.0f);
                     }];
    
    [UIView animateWithDuration:0.25f
                     animations:^{
                         _numberView.transform = CGAffineTransformMakeScale(0, 0);
                     }];
}

-(void)numberSelectionMoved:(CGFloat)yPos number:(NSInteger)number
{
    currentOffer = number;
    [self updatePrices];
    
    [UIView animateWithDuration:0.1f
                     animations:^{
                         CGRect frame = _offerPriceView.frame;
                         frame.origin.y = yPos-34.0f;
                         _offerPriceView.frame = frame;
                     }];
}

- (void)numberSelected:(NSInteger)number
{
    _offerPriceView.alpha=1.0f;
    if(number!=-1)
    {
        currentOffer = number;
        [self updatePrices];
    }
    
    _actualPriceLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:40.0f];
    
    [UIView animateWithDuration:0.15f
                     animations:^{
                         CGRect frame = _offerPriceView.frame;
                         frame.origin.y = 0.0f;
                         frame.size.height = 200.0f;
                         _offerPriceView.frame = frame;
                         
                         frame = _moreButton.frame;
                         frame.origin.y = self.view.bounds.size.height-_moreButton.bounds.size.height;
                         _moreButton.frame = frame;
                         
                         _discountLabel.alpha = 1.0f;
                         _dividerLine.alpha = 1.0f;
                         
                         _actualPriceLabel.frame = CGRectMake(10.0f, 44.0f, 200.0f, 40.0f);
                         _offerPriceLabel.frame = CGRectMake(10.0f, 156.0f, 200.0f, 40.0f);
                         _dividerLine.frame = CGRectMake(10.0f, 140.0f, 205.0f, 1.0f);
                     }];
    
    [UIView animateWithDuration:0.25f
                     animations:^{
                         _numberView.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2f
                                          animations:^{
                                              _numberView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                                          }];
                     }];
    
    float aPrice = [_actualPriceLabel.text floatValue];
    if(aPrice==0)
    {
        _actualPriceLabel.frame = CGRectMake(10.0f, 100.0f, 200.0f, 40.0f);
        _offerPriceLabel.alpha = 0;
        _discountLabel.alpha = 0;
        _dividerLine.alpha = 0;
    }
}

-(IBAction)morePressed:(id)sender
{
    if(bShowingMore)
    {
        [self.view removeGestureRecognizer:viewTapGesture];
        [UIView transitionFromView:_moreView
                            toView:_offerPriceView
                          duration:0.3f
                           options:UIViewAnimationOptionTransitionFlipFromBottom
                        completion:nil];
        
        [UIView animateWithDuration:0.35f
                              delay:0.15f
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             numberSelectionView.alpha = 1.0f;
                             _numberView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                         }
                         completion:^(BOOL finished) {
                             _moreView.alpha = 0;
                         }];
        
        [UIView animateWithDuration:0.25f
                         animations:^{
                             CGRect frame = _holderView.frame;
                             frame.origin.y = 0;
                             _holderView.frame = frame;
                             
                             frame = _moreButton.frame;
                             frame.origin.y = self.view.bounds.size.height-_moreButton.bounds.size.height;
                             _moreButton.frame = frame;
                         }];
    }
    else
    {
        viewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
        [self.view addGestureRecognizer:viewTapGesture];
        
        _moreView.alpha = 1.0f;
        [UIView transitionFromView:_offerPriceView
                            toView:_moreView
                          duration:0.3f
                           options:UIViewAnimationOptionTransitionFlipFromTop
                        completion:nil];
        
        [UIView animateWithDuration:0.15f
                         animations:^{
                             numberSelectionView.alpha = 0;
                             _numberView.transform = CGAffineTransformMakeScale(0, 0);
                             
                             CGRect frame = _holderView.frame;
                             frame.origin.y = (self.view.bounds.size.height/2) - 100.0f;
                             _holderView.frame = frame;
                             
                             frame = _moreButton.frame;
                             frame.origin.y = self.view.bounds.size.height;
                             _moreButton.frame = frame;
                         }];
    }
    
    bShowingMore = !bShowingMore;
}

-(IBAction)ratePressed:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=907878141"]];
}

-(IBAction)fbPressed:(id)sender
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        NSString *text = @"Check out this handy discount calculator - Cut Price";
        NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/app/cut-price/id907878141?mt=8"];
        UIImage *image = [UIImage imageNamed:@"logo"];
        
        SLComposeViewController *fbSheetOBJ = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [fbSheetOBJ setInitialText:text];
        [fbSheetOBJ addImage:image];
        [fbSheetOBJ addURL:url];
        [self presentViewController:fbSheetOBJ animated:YES completion:Nil];
    }
}

-(IBAction)twPressed:(id)sender
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        
        NSString *text = @"Check out this handy discount calculator - Cut Price";
        NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/app/cut-price/id907878141?mt=8"];
        UIImage *image = [UIImage imageNamed:@"logo"];
        
        SLComposeViewController *twSheetOBJ = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [twSheetOBJ setInitialText:text];
        [twSheetOBJ addImage:image];
        [twSheetOBJ addURL:url];
        [self presentViewController:twSheetOBJ animated:YES completion:Nil];
    }
}

-(void)viewTapped
{
    [self.view removeGestureRecognizer:viewTapGesture];
    [UIView transitionFromView:_moreView
                        toView:_offerPriceView
                      duration:0.3f
                       options:UIViewAnimationOptionTransitionFlipFromBottom
                    completion:nil];
    
    [UIView animateWithDuration:0.25f
                          delay:0.25f
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         numberSelectionView.alpha = 1.0f;
                         _numberView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                     }
                     completion:^(BOOL finished) {
                         _moreView.alpha = 0;
                     }];
    
    [UIView animateWithDuration:0.25f
                     animations:^{
                         CGRect frame = _holderView.frame;
                         frame.origin.y = 0;
                         _holderView.frame = frame;
                         
                         frame = _moreButton.frame;
                         frame.origin.y = self.view.bounds.size.height-_moreButton.bounds.size.height;
                         _moreButton.frame = frame;
                     }];
    
    bShowingMore = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
