//
//  Project.h
//  Design Boxes Uploader
//
//  Created by Mike Brand on 6/08/11.
//  Copyright 2011 None. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Page.h"
@interface Project : NSObject{

    NSMutableArray *pages;
    NSString *name;

}

@property (retain) NSMutableArray *pages;
@property (retain) NSString *name;

-(void) addPageToProject:(Page *)aPage;

@end
