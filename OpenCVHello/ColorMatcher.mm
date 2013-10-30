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
@synthesize kdtree = _kdtree;
@synthesize replacementColors = _replacementColors;


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
    
    ///Create the index with x number of trees ////The following line was original functional
    cv::flann::KMeansIndexParams indexParams(8);

    //cv::flann::LinearIndexParams indexParams;

    _kdtree = new cv::flann::Index(_colorCoords, indexParams);

    
    
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
  //  NSLog(@"Rows %i Cols %i Thresh: %i", sampleMat.rows, sampleMat.cols, threshold);
    
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
//    NSLog(@"Vote count %i", votesForWinningColor);
    
    if (votesForWinningColor>threshold) {
        return true;
    }
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



-(NSString*)flannFinder:(cv::Mat)sampleMat :(NSString*)color{
    
    
    int votes = 0;
    int votesAgainst = 0;
    
    
 //   NSLog(@"%@ %i rows %i", @"Color Coord columns", _colorCoords.cols, _colorCoords.rows);
 //   NSLog(@"%@ %i rows %i", @"Sample Mat columns", sampleMat.cols, sampleMat.rows);
    
  //  NSLog(@"Pixels %i", (sampleMat.cols * sampleMat.rows));
  
    
///Creating kdtree with 5 random trees
  // cv::flann::KMeansIndexParams indexParams(5);

    
    
    ///Create the index to search
    ///According to this: http://code.opencv.org/issues/1947
    ///I should directly use the flann index
    // cvflann::Index kdtree(_colorCoords,indexParams);
    
    ///Switching to original
   ///cv::flann::Index kdtree(_colorCoords,indexParams);
    
  //Float32 r,g,b;

int threshold = (0.6 * sampleMat.rows * sampleMat.cols);

    ////First take the vals from the mat and make them floats
    for(int row = 0; row < sampleMat.rows; row++)
    {
        
        uchar* p = sampleMat.ptr(row);
        
        for(int col = 0; col < sampleMat.cols*4; col+=4 ) {
        Float32 r,g,b;

           
            b = [[NSNumber numberWithUnsignedChar:p[col]] floatValue] ;
            g = [[NSNumber numberWithUnsignedChar:p[col+1]] floatValue] ;
            r = [[NSNumber numberWithUnsignedChar:p[col+2]] floatValue] ;
         
//         NSLog(@"Floats %f %f %f, row %i, col %i", b, g, r, row, col);
    ///Creation of a single query. I guess it's a vector?
    
    cv::vector<Float32> singleQuery;
    cv::vector<int> index(1);
    cv::vector<Float32> dist(1);


    singleQuery.push_back(r);
    singleQuery.push_back(g);
    singleQuery.push_back(b);
    
    [self kdtree]->knnSearch(singleQuery, index, dist, 1, cv::flann::SearchParams(24));
    
  //  NSLog(@"Index, %x ,  dist %f", index[0], dist[0]);
    int i = index[0];
            
            if (   [[[_colors objectAtIndex:i] objectForKey:@"FriendlyName"] isEqual:color]) {
                votes++;
            }
            else
                votesAgainst++;
   
            
        }
    }

if(votes>threshold)
    return color;
    else
        return @"string";
}


/**
 Take mat and color, find any instance of the color and then change it to some other color
*/
-(cv::Mat)ColorReplacer:(cv::Mat)sampleMat :(NSString*)color :(UIImageView*)targetImage{

    
////First copy the mat
    /////create pointers to the various arguments
    ////Show "in progress" dialog
    ///
    ///Run a check on every pixel, find what's green, change it on the mat. Copy it to a UIImage.
    ////send it to target image.
    ////stop the in process feedback
    
   // cv::Mat finalMat = sampleMat.clone();
    _replacementColors = sampleMat.clone();
//    cv::Mat finalMat = sampleMat.clone();
    
    for(int row = 0; row < sampleMat.rows; row++)
    {
        
        uchar* p = sampleMat.ptr(row);
        uchar* fp = _replacementColors.ptr(row);
        for(int col = 0; col < sampleMat.cols*4; col+=4 ) {
            Float32 r,g,b;
            
            
            b = [[NSNumber numberWithUnsignedChar:p[col]] floatValue] ;
            g = [[NSNumber numberWithUnsignedChar:p[col+1]] floatValue] ;
            r = [[NSNumber numberWithUnsignedChar:p[col+2]] floatValue] ;
            
            //         NSLog(@"Floats %f %f %f, row %i, col %i", b, g, r, row, col);
            ///Creation of a single query. I guess it's a vector?
            
            cv::vector<Float32> singleQuery;
            cv::vector<int> index(1);
            cv::vector<Float32> dist(1);
            
            
            singleQuery.push_back(r);
            singleQuery.push_back(g);
            singleQuery.push_back(b);
            
            [self kdtree]->knnSearch(singleQuery, index, dist, 1, cv::flann::SearchParams(24));
            
            //  NSLog(@"Index, %x ,  dist %f", index[0], dist[0]);
            int i = index[0];
            
            if (   [[[_colors objectAtIndex:i] objectForKey:@"FriendlyName"] isEqual:color]) {
                //////Change the color at this location
                //NSLog(@"Change color");
                fp[col] = 0;
                fp[col+1] = 0;
                fp[col+2] = 255;
            }
            else{
                ////change the color here to grayscale
                //NSLog(@"Change to grayscale");
                fp[col] = 0;
                fp[col+1] = 0;
                fp[col+2] = 0;
            }
        }
    }
    NSLog(@"Complete");
    return _replacementColors;
}




@end



