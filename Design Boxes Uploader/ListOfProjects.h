//
//  ListOfProjects.h
//  Design Boxes Uploader
//
//  Created by Mike Brand on 6/08/11.
//  Copyright 2011 None. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Project.h"
@interface ListOfProjects : NSObject{
    
    NSMutableArray *listOfProjects;
    
}

@property (retain) NSMutableArray *listOfProjects;

-(void) addProjectToList:(Project *)aProject;

@end
