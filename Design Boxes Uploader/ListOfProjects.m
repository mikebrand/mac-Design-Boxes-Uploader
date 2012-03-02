//
//  Project.m
//  Design Boxes Uploader
//
//  Created by Mike Brand on 6/08/11.
//  Copyright 2011 None. All rights reserved.
//

#import "ListOfProjects.h"

@implementation ListOfProjects
@synthesize listOfProjects;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        listOfProjects = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void) addProjectToList:(Project *)aProject{
    [listOfProjects addObject:aProject];
    
}

@end
