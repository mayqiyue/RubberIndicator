RubberIndicator
====================

A rubber style control that gives users a fun way to browse between many segments.

![alt tag](https://raw.githubusercontent.com/mayqiyue/RubberIndicator/master/rubberIndicator.gif)

# How to install

###Manual:

You can manually add the files in `RubberIndicator` to your Xcode project. RubberIndicator requires iOS 6 or higher.


# Create the view

   	self.rubber = [[RubberIndicator alloc] initWithFrame:CGRectMake(0, 64.0f, 200.0f, 44.0f)];
    self.rubber.dataSource = self;
    self.rubber.delegate = self;
    [self.rubber selectIndex:0];
    
    [self.view addSubview:self.rubber];



# Implement the dataSource && delegate methods :

	// Delegate methods
	- (NSUInteger)numberOfIndicatorsForRubberIndicator:(RubberIndicator *)indicator;
	- (NSString *)titleOfIndicatorsAtIndex:(NSUInteger)index indicator:(RubberIndicator *)indicator;
	- (BOOL)shoulSelectIndicatorAtIndex:(NSUInteger)index indicator:(RubberIndicator *)indicator;
	
	// DataSource methods
	- (void)didSelectIndicatorAtIndex:(NSUInteger)index indicator:(RubberIndicator *)indicator;


# License

 This code is distributed under the terms and conditions of the MIT license.

 Copyright (c) 2016 Mayqiyue

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
