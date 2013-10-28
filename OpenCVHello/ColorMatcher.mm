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
        
  
          cv::Mat colorCoords = cv::Mat(_colors.count,3,CV_32F);
//         cv::Mat colorCoords = cv::Mat(_colors.count,3,CV_32S);
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
        
        
        //cv::Mat colorCoords = cv::Mat(_colors.count,3,CV_32S);
        // cv::Mat sampleMat = cv::Mat(_colors.count,3,CV_8UC3);
        
          cv::Mat colorCoords = cv::Mat(_colors.count,3,CV_32F);
        
        for(int i=0; i<_colors.count; i++){
            
            //We have to bring the vals in from the dictionary as ints that NSinteger will accept
            //NSInteger r = [[[_colors objectAtIndex:i] objectForKey:@"r"] intValue];
            Float32 r = [[[_colors objectAtIndex:i] objectForKey:@"r"] floatValue];
            Float32 g = [[[_colors objectAtIndex:i] objectForKey:@"g"] floatValue];
            Float32 b = [[[_colors objectAtIndex:i] objectForKey:@"b"] floatValue];
            
            
            colorCoords.at<Float32>(i,0) = r;
            colorCoords.at<Float32>(i,1) = g;
            colorCoords.at<Float32>(i,2) = b;
        }
        _colorCoords = colorCoords.clone();
    }
    
    NSLog(@"Colors Count %i", _colors.count);
    return self;
}




-(BOOL)matchColorFromMat:(cv::Mat)sampleMat :(NSString*)targColor{
  
    ////Accept the mat
    ////Work through each pixel comparing it to our colors
    
    ////Use "Find Distance" to get the nearest color
    //Count up the "Votes"
    ///return
  
    cv::Mat img = sampleMat.clone();
    int votesForWinningColor =0;
    int threshold = (0.6 * sampleMat.rows * sampleMat.cols);
    NSLog(@"Rows %i Cols %i Thresh: %i", sampleMat.rows, sampleMat.cols, threshold);
    
    ///we have two options for the voting, make it so that the votes need to add
    ///up to more than half of the tested pixels
    ///or we need to make sure the votes are more than any other color
    ///Do we want to count all the "wrong" colors as the same votes against?
    ////Or do we vote for each returned color?
   NSNumber *B,*G,*R;


    for(int row = 0; row < img.rows; ++row){
        uchar* p = img.ptr(row);
       
        for(int col = 0; col < img.cols*3; ++col) {
   
            B = [NSNumber numberWithUnsignedChar:p[0]] ;
            G = [NSNumber numberWithUnsignedChar:p[1]] ;
            R = [NSNumber numberWithUnsignedChar:p[2]] ;
            NSArray * testArray = [NSArray arrayWithObjects:R,G,B, nil];
            
            if ([[self findDistance:testArray] isEqual:targColor]) {
                votesForWinningColor++;
            }

        }
        
    }
    NSLog(@"Vote count %i", votesForWinningColor);
    
    if (votesForWinningColor>threshold) {
        return true;
    }
    
    //NSLog(@"Inside Green Test Helper: B:%@ G:%@ R:%@ Number: %i", B,G,R,count);
    else
    return false;
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
   
  //      NSLog(@"%@, r %ld, g %ld b %ld",@"Sample", (long)r, (long)g, (long)b);
    
//    NSLog(@"%@ %@, r %@, g %@ b %@",[[_colors objectAtIndex:indexOfClosest] objectForKey:@"name"], [[_colors objectAtIndex:indexOfClosest] objectForKey:@"FriendlyName"],[[_colors objectAtIndex:indexOfClosest] objectForKey:@"r"], [[_colors objectAtIndex:indexOfClosest] objectForKey:@"g"],[[_colors objectAtIndex:indexOfClosest] objectForKey:@"b"]);
    
    return [[_colors objectAtIndex:indexOfClosest] objectForKey:@"FriendlyName"];
}




//-(NSString*)flannFinder:(cv::Mat)sampleMat{

-(NSString*)flannFinder:(NSArray*)sampleArray{
    
    
 
    
    
    NSLog(@"%@ %i rows %i", @"Color Coord columns", _colorCoords.cols, _colorCoords.rows);
 //   NSLog(@"%@ %i rows %i", @"Sample Mat columns", sampleMat.cols, sampleMat.rows);
    
    ///Creating kdtree with 5 random trees
   cv::flann::KMeansIndexParams indexParams(5);
    //cv::flann::AutotunedIndexParams indexParams(2);
    //cv::flann::LinearIndexParams indexParams;
    
 //   cv::flann::IndexParams indexParams;
    
    
    ///Create the index to search
    ///According to this: http://code.opencv.org/issues/1947
    ///I should directly use the flann index
    // cvflann::Index kdtree(_colorCoords,indexParams);
    
    cv::flann::Index kdtree(_colorCoords,indexParams);
    
    
    ///Creation of a single query. I guess it's a vector?
    
    cv::vector<Float32> singleQuery;
    cv::vector<int> index(1);
    cv::vector<Float32> dist(1);
    ///populate the query, in reverse order I guess
    Float32 r,g,b;
    r = [[sampleArray objectAtIndex:0] floatValue];
    g = [[sampleArray objectAtIndex:1] floatValue];
    b = [[sampleArray objectAtIndex:2] floatValue];
    

    singleQuery.push_back(r);
    singleQuery.push_back(g);
    singleQuery.push_back(b);
   // singleQuery.push_back(sampleMat.at<Float32>(0,1));
  //  singleQuery.push_back(sampleMat.at<Float32>(0,0));
    
    /*
    singleQuery.push_back(sampleMat.at<Float32>(0,2));
    singleQuery.push_back(sampleMat.at<Float32>(0,1));
    singleQuery.push_back(sampleMat.at<Float32>(0,0));
    */
     
    kdtree.knnSearch(singleQuery, index, dist, 1, cv::flann::SearchParams(64));
    
    NSLog(@"Index, %x ,  dist %f", index[0], dist[0]);
    
    int i = index[0];
    NSLog(@"Floats %f %f %f",  _colorCoords.at<Float32>(i,0),_colorCoords.at<Float32>(i,1),_colorCoords.at<Float32>(i,3));

    NSLog(@"Possible Color name: %@ r %@ g %@ b %@",
    
        [[_colors objectAtIndex:i] objectForKey:@"name"],
        [[_colors objectAtIndex:i] objectForKey:@"r"],
        [[_colors objectAtIndex:i] objectForKey:@"g"],
        [[_colors objectAtIndex:i] objectForKey:@"b"]);
    
    return @"String";
}





@end



