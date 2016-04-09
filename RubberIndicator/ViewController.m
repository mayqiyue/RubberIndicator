//
//  ViewController.m
//  RubberIndicator
//
//  Created by Mayqiyue on 4/9/16.
//  Copyright © 2016 mayqiyue. All rights reserved.
//

#import "ViewController.h"
#import "RubberIndicator.h"

@interface ViewController ()<RubberIndicatorDelegate, RubberIndicatorDataSource>

@property (nonatomic, strong) IBOutlet UILabel         *titleLabel;
@property (weak, nonatomic  ) IBOutlet UIView          *containerView;

@property (nonatomic, strong) RubberIndicator *rubber;

@property (nonatomic, strong) NSArray *names;
@property (nonatomic, strong) NSArray *colors;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    self.names = @[@"one", @"two", @"three", @"four", @"five"];
    self.colors = @[
                    [UIColor redColor],
                    [UIColor blueColor],
                    [UIColor greenColor],
                    [UIColor yellowColor],
                    [UIColor brownColor]
                    ];
    
    [self configureViews];
}

- (void)configureViews
{
    self.rubber = [[RubberIndicator alloc] initWithFrame:CGRectMake(0, 64.0f, 200.0f, 44.0f)];
    self.rubber.center = CGPointMake(self.view.bounds.size.width*0.5f, self.rubber.center.y);
    self.rubber.dataSource = self;
    self.rubber.delegate = self;
    [self.rubber selectIndex:0];
    
    [self.view addSubview:self.rubber];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Indicatort delegate

- (NSUInteger)numberOfIndicatorsForRubberIndicator:(RubberIndicator *)indicator
{
    return 5;
}

- (NSString *)titleOfIndicatorsAtIndex:(NSUInteger)index indicator:(RubberIndicator *)indicator
{
    NSString *string = self.names[index];
    return string;
}

- (BOOL)shoulSelectIndicatorAtIndex:(NSUInteger)index indicator:(RubberIndicator *)indicator
{
    return YES;
}

- (void)didSelectIndicatorAtIndex:(NSUInteger)index indicator:(RubberIndicator *)indicator
{
    NSLog(@"+++++++++Did tap index %zd", index);
    self.containerView.backgroundColor = self.colors[index];
    self.titleLabel.text = self.names[index];
}

@end
