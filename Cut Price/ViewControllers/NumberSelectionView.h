//
//  NumberSelectionView.h
//  Algos
//
//  Created by Manigandan Parthasarathi on 10/07/13.
//  Copyright (c) 2013 Manigandan Parthasarathi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NumberSelectionDelegate;

@interface NumberSelectionView : UIView

@property(nonatomic, assign) id<NumberSelectionDelegate> delegate;

@end

@protocol NumberSelectionDelegate <NSObject>

-(void)numbersShown:(CGFloat)yPos;
-(void)numberSelectionMoved:(CGFloat)yPos number:(NSInteger)number;
-(void)numberSelected:(NSInteger)number;

@end
