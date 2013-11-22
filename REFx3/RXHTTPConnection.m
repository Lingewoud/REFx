#import "RXHTTPConnection.h"
#import "HTTPMessage.h"
#import "HTTPDataResponse.h"
#import "DDNumber.h"
#import "HTTPLogging.h"

#import "REFx3AppDelegate.h"
#import "RXREFxIntance.h"

#import "XMLDictionary.h"

#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabasePool.h"
#import "FMDatabaseQueue.h"

// Log levels : off, error, warn, info, verbose
// Other flags: trace
static const int httpLogLevel = HTTP_LOG_LEVEL_INFO; // | HTTP_LOG_FLAG_TRACE;


/**
 * All we have to do is override appropriate methods in HTTPConnection.
**/

@implementation RXHTTPConnection

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
	HTTPLogTrace();
	
	// Add support for POST
	
	if ([method isEqualToString:@"POST"])
	{
		if ([path isEqualToString:@"/rpc/jobs"])
		{
			// Let's be extra cautious, and make sure the upload isn't 5 gigs
			
			return requestContentLength < 50000;
		}

		if ([path isEqualToString:@"/post.html"])
		{
			// Let's be extra cautious, and make sure the upload isn't 5 gigs
			
			return requestContentLength < 50;
		}
	}
	
	return [super supportsMethod:method atPath:path];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
{
	HTTPLogTrace();
	
	// Inform HTTP server that we expect a body to accompany a POST request
	
	if([method isEqualToString:@"POST"])
		return YES;
	
	return [super expectsRequestBodyFromMethod:method atPath:path];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
	HTTPLogTrace();

    if ([method isEqualToString:@"POST"] && [path isEqualToString:@"/rpc/jobs"])
	{
		HTTPLogVerbose(@"%@[%p]: postContentLength: %qu", THIS_FILE, self, requestContentLength);
		
		NSString *postStr = nil;
		
		NSData *postData = [request body];
        
        NSDictionary* rpcDict = [NSDictionary dictionaryWithXMLData:postData];
        //    NSLog(@"show dict: %@",rpcDict);
        NSString *method = [rpcDict objectForKey:@"methodName"];
        NSLog(@"show method: %@",method);
        
        NSArray * paramMembers = [[[[[rpcDict objectForKey:@"params"] objectForKey:@"param"] objectForKey:@"value"] objectForKey:@"struct"] objectForKey:@"member"];
        
        //  NSLog(@"show members: %@",paramMembers);
        
        NSString *jobEngine = [[[paramMembers objectAtIndex:0] objectForKey:@"value"] objectForKey:@"string"];
        NSString *jobBody = [[[paramMembers objectAtIndex:1] objectForKey:@"value"] objectForKey:@"string"];
        long jobPriority = [[[[paramMembers objectAtIndex:2] objectForKey:@"value"] objectForKey:@"int"] integerValue];
        long jobMaxAttempt = [[[[paramMembers objectAtIndex:3] objectForKey:@"value"] objectForKey:@"int"] integerValue];
        
        NSLog(@"show job Dict: %@\n\n %@\n\n %li\n\n %li",jobEngine, jobBody, jobPriority, jobMaxAttempt);
        
        //NSString* dbPath = [[[NSApp delegate] refxInstance] getDbPath];
        FMDatabase *db = [FMDatabase databaseWithPath:[[[NSApp delegate] refxInstance] getDbPath]];
        db.traceExecution = YES;
        db.logsErrors = YES;
        
        if (![db open]) {
            NSLog(@"Could not open db.");
            return nil;
        }
                         //@"INSERT INTO jobs (priority,engine,body,status,max_attempt,attempt,returnbody) values (1,'%@','%@',1,1,0,'');",engine,body];
        NSString *sql = [NSString stringWithFormat:
                         @"INSERT INTO jobs (priority,engine,body,status,max_attempt,attempt,returnbody) values (%li,'%@','%@',1,%li,0,'');",
                         jobPriority,jobEngine,jobBody,jobMaxAttempt];
        
        [db executeUpdate:sql];
        long newid = (long)[db lastInsertRowId];
        NSLog(@"New id. %li",newid);
        
        [db close];
        
        
		/*if (postData)
		{
			postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
		}
         */
        
		HTTPLogVerbose(@"%@[%p]: postStr: %@", THIS_FILE, self, postStr);
		
		NSData *response = nil;
		response = [@"<html><body>Always ok<body></html>" dataUsingEncoding:NSUTF8StringEncoding];
		
		return [[HTTPDataResponse alloc] initWithData:response];
	}
    
	if ([method isEqualToString:@"POST"] && [path isEqualToString:@"/post.html"])
	{
		HTTPLogVerbose(@"%@[%p]: postContentLength: %qu", THIS_FILE, self, requestContentLength);
		
		NSString *postStr = nil;
		
		NSData *postData = [request body];
		if (postData)
		{
			postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
		}
		
		HTTPLogVerbose(@"%@[%p]: postStr: %@", THIS_FILE, self, postStr);
		
		// Result will be of the form "answer=..."
		
		int answer = [[postStr substringFromIndex:7] intValue];
		
		NSData *response = nil;
		if(answer == 10)
		{
			response = [@"<html><body>Correct<body></html>" dataUsingEncoding:NSUTF8StringEncoding];
		}
		else
		{
			response = [@"<html><body>Sorry - Try Again<body></html>" dataUsingEncoding:NSUTF8StringEncoding];
		}
		
		return [[HTTPDataResponse alloc] initWithData:response];
	}
	
	return [super httpResponseForMethod:method URI:path];
}

- (void)prepareForBodyWithSize:(UInt64)contentLength
{
	HTTPLogTrace();
	
	// If we supported large uploads,
	// we might use this method to create/open files, allocate memory, etc.
}

- (void)processBodyData:(NSData *)postDataChunk
{
	HTTPLogTrace();
	
	// Remember: In order to support LARGE POST uploads, the data is read in chunks.
	// This prevents a 50 MB upload from being stored in RAM.
	// The size of the chunks are limited by the POST_CHUNKSIZE definition.
	// Therefore, this method may be called multiple times for the same POST request.
	
	BOOL result = [request appendData:postDataChunk];
	if (!result)
	{
		HTTPLogError(@"%@[%p]: %@ - Couldn't append bytes!", THIS_FILE, self, THIS_METHOD);
	}
}

@end
