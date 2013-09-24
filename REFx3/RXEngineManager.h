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

@property (nonatomic, retain) NSString *someProperty;

+ (id)sharedEngineManager;
- (NSString *)engineDirectoryPath;
- (void)initEngineDirectory;

@end
