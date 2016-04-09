//
//  RubberIndicator.h
//  RubberIndicator
//
//  Created by Mayqiyue on 3/29/16.
//  Copyright © 2016 mayqiyue. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RubberIndicator;

// DataSource
@protocol RubberIndicatorDataSource  <NSObject>

@required

- (NSUInteger)numberOfIndicatorsForRubberIndicator:(RubberIndicator *)indicator;
- (NSString *)titleOfIndicatorsAtIndex:(NSUInteger)index indicator:(RubberIndicator *)indicator;

@optional

/**
 *  Determine the rubber indicator should switch to the new selected indicator item.
 *  Default return YES.
 */
- (BOOL)shoulSelectIndicatorAtIndex:(NSUInteger)index indicator:(RubberIndicator *)indicator;

@end

// Delegate
@protocol RubberIndicatorDelegate  <NSObject>

@optional

- (void)didSelectIndicatorAtIndex:(NSUInteger)index indicator:(RubberIndicator *)indicator;

@end

@interface RubberIndicator : UIControl

@property(nonatomic, weak) id<RubberIndicatorDelegate> delegate;
@property(nonatomic, weak) id<RubberIndicatorDataSource> dataSource;

@property(nonatomic, assign, readonly) NSUInteger selectedIndex;

@property(nonatomic, assign) UIEdgeInsets contentInsets; // Default is UIEdgeInsetsZero.
@property(nonatomic, assign) CGFloat itemSize; // Normal items' size, default is 16.0f.
@property(nonatomic, assign) CGFloat selectedItemSize; // Selected item's size, default is 20.0f.
@property(nonatomic, assign) CGFloat itemInternalSpacing; // The internal spacing between items, default is 10.0f.
@property(nonatomic, assign) CGFloat animationDuration; // The duration of item switching animation, default is 0.2f.

@property(nonatomic, copy) UIColor *selectedItemTintColor; // The selected item's tint color
@property(nonatomic, copy) UIColor *backLineViewColor; // the background color of backLineView

/**
 *  Select index.
 *
 *  This function will check shoulSelectIndicatorAtIndex:.
 */
- (void)selectIndex:(NSUInteger)index;

/**
 *  Select index forcibly.
 *  This function will not check shoulSelectIndicatorAtIndex:.
 */
- (void)selectIndexForcibly:(NSUInteger)index;

@end
