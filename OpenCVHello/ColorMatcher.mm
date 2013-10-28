//
//  ColorMatcher.m
//  IsItGreen2
//
//  Created by Brendan Hinman on 10/18/13.
//  Copyright (c) 2013 Brendan Hinman. All rights reserved.
//

#import "ColorMatcher.h"

@implementation ColorMatcher

@synthesize colors = _colors;
@synthesize colorCoords = _colorCoords;


-(id)initWithColorFileName:(NSString*)colorCoordsFileName{
    if (self = [super init]){
        
        NSString *path = [[NSBundle mainBundle] pathForResource:colorCoordsFileName ofType:@"plist"];
        
        _colors =  [[NSArray alloc] initWithContentsOfFile:path];
        
        
         cv::Mat colorCoords = cv::Mat(_colors.count,3,CV_32S);
       // cv::Mat sampleMat = cv::Mat(_colors.count,3,CV_8UC3);
        
     //  cv::Mat sampleMat = cv::Mat(_colors.count,3,CV_32F);

        for(int i=0; i<_colors.count; i++){
            
            //We have to bring the vals in from the dictionary as ints that NSinteger will accept
            NSInteger r = [[[_colors objectAtIndex:i] objectForKey:@"red"] intValue];
            NSInteger g = [[[_colors objectAtIndex:i] objectForKey:@"green"] intValue];
            NSInteger b = [[[_colors objectAtIndex:i] objectForKey:@"blue"] intValue];
       
      
            colorCoords.at<int>(i,0) = r;
            colorCoords.at<int>(i,1) = g;
            colorCoords.at<int>(i,2) = b;
        }
        _colorCoords = colorCoords.clone();
    }
    
    NSLog(@"Colors Count %i", _colors.count);
    return self;
}



-(id)initWithJSON:(NSArray*)colorJson{
    if (self = [super init]){
        
      //  NSString *path = [[NSBundle mainBundle] pathForResource:colorCoordsFileName ofType:@"plist"];
        
        _colors = colorJson;
        
        
        cv::Mat colorCoords = cv::Mat(_colors.count,3,CV_32S);
        // cv::Mat sampleMat = cv::Mat(_colors.count,3,CV_8UC3);
        
        //  cv::Mat sampleMat = cv::Mat(_colors.count,3,CV_32F);
        
        for(int i=0; i<_colors.count; i++){
            
            //We have to bring the vals in from the dictionary as ints that NSinteger will accept
            NSInteger r = [[[_colors objectAtIndex:i] objectForKey:@"r"] intValue];
            NSInteger g = [[[_colors objectAtIndex:i] objectForKey:@"g"] intValue];
            NSInteger b = [[[_colors objectAtIndex:i] objectForKey:@"b"] intValue];
            
            
            colorCoords.at<int>(i,0) = r;
            colorCoords.at<int>(i,1) = g;
            colorCoords.at<int>(i,2) = b;
        }
        _colorCoords = colorCoords.clone();
    }
    
    NSLog(@"Colors Count %i", _colors.count);
    return self;
}




-(NSString*)matchFromMat:(cv::Mat)sampleMat :(NSString*)targColor{
    
    
    ////Accept the mat
    ////Work through each pixel comparing it to our colors
    
    ////Use "Find Distance" to get the nearest color
    //Count up the "Votes"
    ///return
    
    
    
    
    cv::Mat sample = sampleMat.clone();
    int votesForWinningColor;
    ///we have two options for the voting, make it so that the votes need to add
    ///up to more than half of the tested pixels
    ///or we need to make sure the votes are more than any other color
    ///Do we want to count all the "wrong" colors as the same votes against?
    ////Or do we vote for each returned color?
    
    
    
    
    
    
    
    
    

    
    return @"Winning Color";
}

///TODO: Rename this function because it's more "find nearest"

-(NSString*)findDistance:(NSArray*)sample{
   
    float curShortest = FLT_MAX;
    int indexOfClosest = 0;
    
    NSInteger r = [[sample objectAtIndex:0] intValue];
    NSInteger g = [[sample objectAtIndex:1] intValue];
    NSInteger b = [[sample objectAtIndex:2] intValue];
  
    for(int i = 0; i<_colors.count; i++){
        NSInteger R = [[[_colors objectAtIndex:i] objectForKey:@"r"] intValue];
        NSInteger G = [[[_colors objectAtIndex:i] objectForKey:@"g"] intValue];
        NSInteger B = [[[_colors objectAtIndex:i] objectForKey:@"b"] intValue];
        
      ////Find Euclidean
        double dx = abs(R-r);
        double dy = abs(G-g);
        double dz = abs(B-b);
        double dist = sqrt(dx*dx + dy*dy + dz*dz);
        ///Update closest
        if(dist < curShortest){
            curShortest = dist;
            indexOfClosest = i;
        }
        
    }
   
        NSLog(@"%@, r %ld, g %ld b %ld",@"Sample", (long)r, (long)g, (long)b);
    
    NSLog(@"%@ %@, r %@, g %@ b %@",[[_colors objectAtIndex:indexOfClosest] objectForKey:@"name"], [[_colors objectAtIndex:indexOfClosest] objectForKey:@"FriendlyName"],[[_colors objectAtIndex:indexOfClosest] objectForKey:@"r"], [[_colors objectAtIndex:indexOfClosest] objectForKey:@"g"],[[_colors objectAtIndex:indexOfClosest] objectForKey:@"b"]);
    
    return [[_colors objectAtIndex:indexOfClosest] objectForKey:@"FriendlyName"];
}




@end



