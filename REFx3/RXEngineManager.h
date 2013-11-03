//
//  RXEngines.h
//  REFx4
//
//  Created by Pim Snel on 24-09-13.
//
//

#import <Foundation/Foundation.h>
#import "REFx3AppDelegate.h"

@interface RXEngineManager : NSObject
{
    NSString *someProperty;
}

//@property (nonatomic, retain) NSString *someProperty;

+ (id)sharedEngineManager;
- (NSString *)engineDirectoryPath;
- (void)initEngineDirectory;
- (NSMutableArray *) enginesEnabledArray;

- (NSString *)pathToEngine:(NSString *)anEngine;
- (NSString *)pathToEngineContents:(NSString *)anEngine;
- (NSString *)pathToEngineResources:(NSString *)anEngine;

- (NSString *)urlToEngineApiDocs:(NSString *)anEngine;
- (void)insertEngineTestJob:(NSString *)anEngine;
- (BOOL)engineIsValid:(NSString *)anEngine;
- (id)engineInfoDict:(NSString*)anEngine objectForKey:(NSString*)key;
- (NSString *)pathToEngineRunner;
-(void)insertTestJobFor:(NSString*)engine withIndex:(NSInteger)testIndex;



@end
