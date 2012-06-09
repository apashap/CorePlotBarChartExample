//
//  GraphView.m
//  CorePlotBarChartExample
//
//  Created by Anthony Perozzo on 8/06/12.
//  Copyright (c) 2012 Gilthonwe Apps. All rights reserved.
//

#import "GraphView.h"

@implementation GraphView

- (void)generateData
{
    NSMutableDictionary *dataTemp = [[NSMutableDictionary alloc] init];
    
    //Array containing all the dates that will be displayed on the X axis
    dates = [NSArray arrayWithObjects:@"2012-05-01", @"2012-05-02", @"2012-05-03", 
             @"2012-05-04", @"2012-05-05", @"2012-05-06", @"2012-05-07", nil];
    
    //Dictionary containing the name of the two sets and their associated color
    //used for the demo
    sets = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blueColor], @"Plot 1",
            [UIColor redColor], @"Plot 2",
            [UIColor greenColor], @"Plot 3", nil];

    //Generate random data for two sets of data that will be displayed for each day
    //Numbers between 1 and 10
    for (NSString *date in dates) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        for (NSString *set in sets) {
            NSNumber *num = [NSNumber numberWithInt:arc4random_uniform(10)+1];
            [dict setObject:num forKey:set];
        }
        [dataTemp setObject:dict forKey:date];
    }
    
    data = [dataTemp copy];
    [dataTemp release];

    NSLog(@"%@", data);
}

- (void)generateLayout
{
    //Create graph from theme
	graph                               = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
	[graph applyTheme:[CPTTheme themeNamed:kCPTStocksTheme]];
	self.hostedGraph                    = graph;
    graph.plotAreaFrame.masksToBorder   = NO;
    graph.paddingLeft                   = 0.0f;
    graph.paddingTop                    = 0.0f;
	graph.paddingRight                  = 0.0f;
	graph.paddingBottom                 = 0.0f;
    
    CPTMutableLineStyle *borderLineStyle    = [CPTMutableLineStyle lineStyle];
	borderLineStyle.lineColor               = [CPTColor whiteColor];
	borderLineStyle.lineWidth               = 2.0f;
	graph.plotAreaFrame.borderLineStyle     = borderLineStyle;
	graph.plotAreaFrame.paddingTop          = 10.0;
	graph.plotAreaFrame.paddingRight        = 10.0;
	graph.plotAreaFrame.paddingBottom       = 80.0;
	graph.plotAreaFrame.paddingLeft         = 70.0;
    
	//Add plot space
	CPTXYPlotSpace *plotSpace       = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.delegate              = self;
	plotSpace.yRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(0) 
                                                                   length:CPTDecimalFromInt(10 * sets.count)];
	plotSpace.xRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(-1) 
                                                                   length:CPTDecimalFromInt(8)];
 
    //Grid line styles
	CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
	majorGridLineStyle.lineWidth            = 0.75;
	majorGridLineStyle.lineColor            = [[CPTColor whiteColor] colorWithAlphaComponent:0.1];
    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
	minorGridLineStyle.lineWidth            = 0.25;
	minorGridLineStyle.lineColor            = [[CPTColor whiteColor] colorWithAlphaComponent:0.1];
    
    //Axes
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    
    //X axis
    CPTXYAxis *x                    = axisSet.xAxis;
    x.orthogonalCoordinateDecimal   = CPTDecimalFromInt(0);
	x.majorIntervalLength           = CPTDecimalFromInt(1);
	x.minorTicksPerInterval         = 0;
    x.labelingPolicy                = CPTAxisLabelingPolicyNone;
    x.majorGridLineStyle            = majorGridLineStyle;
    x.axisConstraints               = [CPTConstraints constraintWithLowerOffset:0.0];
    
    //X labels
    int labelLocations = 0;
    NSMutableArray *customXLabels = [NSMutableArray array];
    for (NSString *day in dates) {
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText:day textStyle:x.labelTextStyle];
        newLabel.tickLocation   = [[NSNumber numberWithInt:labelLocations] decimalValue];
        newLabel.offset         = x.labelOffset + x.majorTickLength;
        newLabel.rotation       = M_PI / 4;
        [customXLabels addObject:newLabel];
        labelLocations++;
        [newLabel release];
    }
    x.axisLabels                    = [NSSet setWithArray:customXLabels];
    
    //Y axis
	CPTXYAxis *y            = axisSet.yAxis;
	y.title                 = @"Value";
	y.titleOffset           = 50.0f;
    y.labelingPolicy        = CPTAxisLabelingPolicyAutomatic;
    y.majorGridLineStyle    = majorGridLineStyle;
    y.minorGridLineStyle    = minorGridLineStyle;
    y.axisConstraints       = [CPTConstraints constraintWithLowerOffset:0.0]; 
    
    //Create a bar line style
    CPTMutableLineStyle *barLineStyle   = [[[CPTMutableLineStyle alloc] init] autorelease];
    barLineStyle.lineWidth              = 1.0;
    barLineStyle.lineColor              = [CPTColor whiteColor];
    CPTMutableTextStyle *whiteTextStyle = [CPTMutableTextStyle textStyle];
	whiteTextStyle.color                = [CPTColor whiteColor];
    
    //Plot
    BOOL firstPlot = YES;
    for (NSString *set in [[sets allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]) {
        CPTBarPlot *plot        = [CPTBarPlot tubularBarPlotWithColor:[CPTColor blueColor] horizontalBars:NO];
        plot.lineStyle          = barLineStyle;
        CGColorRef color        = ((UIColor *)[sets objectForKey:set]).CGColor;
        plot.fill               = [CPTFill fillWithColor:[CPTColor colorWithCGColor:color]];
        if (firstPlot) {
            plot.barBasesVary   = NO;
            firstPlot           = NO;
        } else {
            plot.barBasesVary   = YES;
        }
        plot.barWidth           = CPTDecimalFromFloat(0.8f);
        plot.barsAreHorizontal  = NO;
        plot.dataSource         = self;
        plot.identifier         = set;
        [graph addPlot:plot toPlotSpace:plotSpace];
    }
    
    //Add legend
	CPTLegend *theLegend      = [CPTLegend legendWithGraph:graph];
	theLegend.numberOfRows	  = sets.count;
	theLegend.fill			  = [CPTFill fillWithColor:[CPTColor colorWithGenericGray:0.15]];
	theLegend.borderLineStyle = barLineStyle;
	theLegend.cornerRadius	  = 10.0;
	theLegend.swatchSize	  = CGSizeMake(15.0, 15.0);
	whiteTextStyle.fontSize	  = 13.0;
	theLegend.textStyle		  = whiteTextStyle;
	theLegend.rowMargin		  = 5.0;
	theLegend.paddingLeft	  = 10.0;
	theLegend.paddingTop	  = 10.0;
	theLegend.paddingRight	  = 10.0;
	theLegend.paddingBottom	  = 10.0;
	graph.legend              = theLegend;
    graph.legendAnchor        = CPTRectAnchorTopLeft;
    graph.legendDisplacement  = CGPointMake(80.0, -10.0);
}

- (void)createGraph
{
    //Generate data
    [self generateData];
    
    //Generate layout
    [self generateLayout];
}

- (void)dealloc
{
    [data release];
    [super dealloc];
}

#pragma mark - CPTPlotDataSource methods

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return dates.count;
}

- (double)doubleForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    double num = NAN;
    
    //X Value
    if (fieldEnum == 0) {
        num = index;
    }
    
    else {
        double offset = 0;
        if (((CPTBarPlot *)plot).barBasesVary) {
            for (NSString *set in [[sets allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]) {
                if ([plot.identifier isEqual:set]) {
                    break;
                }
                offset += [[[data objectForKey:[dates objectAtIndex:index]] objectForKey:set] doubleValue];
            }
        }
        
        //Y Value
        if (fieldEnum == 1) {
            num = [[[data objectForKey:[dates objectAtIndex:index]] objectForKey:plot.identifier] doubleValue] + offset;
        }
        
        //Offset for stacked bar
        else {
            num = offset;
        }
    }
    
    //NSLog(@"%@ - %d - %d - %f", plot.identifier, index, fieldEnum, num);
    
    return num;
}

@end
