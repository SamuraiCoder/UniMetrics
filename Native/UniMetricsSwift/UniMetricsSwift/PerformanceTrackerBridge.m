//
//  PerformanceTrackerBridge.m
//  UniMetricsSwift
//
//  Created by Sam Alonso on 09/03/2024.
//

#import <UniMetricsSwift/UniMetricsSwift-Swift.h>

void startTracking(void)
{
    [[PerformanceTracker shared] startTracking];
}

const char* stopTracking(void)
{
    NSString* result = [[PerformanceTracker shared] stopTracking];
    return [result cStringUsingEncoding:NSUTF8StringEncoding];
}
