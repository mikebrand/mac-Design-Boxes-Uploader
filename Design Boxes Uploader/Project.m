//
//  Project.m
//  Design Boxes Uploader
//
//  Created by Mike Brand on 6/08/11.
//  Copyright 2011 None. All rights reserved.
//

#import "Project.h"

@implementation Project
@synthesize pages, name;

- (id)init
{
    self = [super init];
    if (self) {
        pages = [[NSMutableArray alloc] initWithCapacity:0];
        // Initialization code here.
        
    }
    
    return self;
}

-(void) addPageToProject:(Page *)aPage{
    [pages addObject:aPage];
}

@end
