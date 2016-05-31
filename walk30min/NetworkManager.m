//
//  NetworkManager.m
//  walk30min
//
//  Created by YuriHan on 13. 10. 15..
//  Copyright (c) 2013년 YuriHan. All rights reserved.
//

#import "NetworkManager.h"
#import "NetworkIndicatorManager.h"

#define baseUrl @"http://54.248.230.232/api/"
#define searchUrl baseUrl@"place/search"
#define infoUrl baseUrl@"place/"
#define reviewUrl baseUrl@"review"
#define likeUrl baseUrl@"like"

#define NW_TRACE    1
static const NSString* kStringBoundary = @"3i2ndDfv2rTHiSisAbouNdArYfORhtTPEefj3q2f";

NSString* urlEncode(NSString* sourceString)
{
    NSString *result = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                             NULL,
                                                                                             (__bridge CFStringRef)sourceString,
                                                                                             NULL,
                                                                                             (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                             kCFStringEncodingUTF8);
    return result;
}

@interface NetworkManager ()
+(NSString *)generateGetBody:(NSDictionary*)params;
+(NSData *)generateMultipartPostBody:(NSDictionary*)params;
+(NSDictionary*)getMessage:(NSURL*)url;
+(NSDictionary*)postMessage:(NSURL*)url body:(NSDictionary*)info err:(NSError**)err;
+(NSDictionary*)postMultipartMessage:(NSURL*)url body:(NSDictionary*)info err:(NSError**)err;
+(void)utfAppendBody:(NSMutableData *)body data:(NSString *)data;
@end

@implementation NetworkManager
+(NetworkManager*)shared
{
    static NetworkManager* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NetworkManager alloc] init];
    });
    return sharedInstance;
}

+(NSString *)generateGetBody:(NSDictionary*)params {
    if(params == nil || params.count == 0)
        return @"";
    
    NSMutableString *body = [NSMutableString stringWithString:@"?"];
    
    for (NSString* key in [params keyEnumerator]) {
        [body appendFormat:@"%@=%@&",key,urlEncode([params objectForKey:key])];
    }
    
    return [body substringToIndex:body.length-1];
}

+(NSString *)generatePostBody:(NSDictionary*)params {
    NSMutableString *body = [NSMutableString string];
    
    for (NSString* key in [params keyEnumerator]) {
        [body appendFormat:@"%@=%@&",key,urlEncode([params objectForKey:key])];
    }
    
    return [body substringToIndex:body.length-1];
}

+(void)utfAppendBody:(NSMutableData *)body data:(NSString *)data {
    [body appendData:[data dataUsingEncoding:NSUTF8StringEncoding]];
}

/**
 * Generate body for POST method
 */
+(NSMutableData *)generateMultipartPostBody:(NSDictionary*)params {
    NSMutableData *body = [NSMutableData data];
    NSString *endLine = [NSString stringWithFormat:@"\r\n--%@\r\n", kStringBoundary];
    NSString *endLine2 = [NSString stringWithFormat:@"\r\n--%@--\r\n", kStringBoundary];
    
    NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionary];
    
    [NetworkManager utfAppendBody:body data:[NSString stringWithFormat:@"--%@\r\n", kStringBoundary]];
    int paramCount = params.count;
    int cnt = 0;
    
    for (id key in [params keyEnumerator]) {
        if (([params[key] isKindOfClass:[UIImage class]])
            ||([params[key] isKindOfClass:[NSData class]])) {
            
            dataDictionary[key] = params[key];
            continue;
        }
        [NetworkManager utfAppendBody:body
                                 data:[NSString
                                       stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key]];
        [NetworkManager utfAppendBody:body data:[params[key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        cnt++;
        if (paramCount != cnt)
            [NetworkManager utfAppendBody:body data:endLine];
        else
            [NetworkManager utfAppendBody:body data:endLine2];
    }
    
    if ([dataDictionary count] > 0) {
        for (id key in dataDictionary) {
            NSObject *dataParam = [dataDictionary valueForKey:key];
            NSData* imageData = UIImageJPEGRepresentation((UIImage*)dataParam, 1.0);
            [NetworkManager utfAppendBody:body
                                     data:[NSString stringWithFormat:
                                           @"Content-Disposition: form-data; name=\"%@\"; filename=\"%@.jpg\"\r\n", key,key]];
            [NetworkManager utfAppendBody:body
                                     data:@"Content-Type: application/octet-stream\r\n\r\n"];
            [body appendData:imageData];
            
            cnt++;
            if (paramCount != cnt)
                [NetworkManager utfAppendBody:body data:endLine];
            else
                [NetworkManager utfAppendBody:body data:endLine2];
        }
    }
    return body;
}

+(id)getMessage:(NSURL*)url
{
#if NW_TRACE
    NSLog(@"URL =>\n%@",url);
#endif
	NSError* err = nil;
	NSString* res = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&err];
	res = [res stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
	res = [res stringByReplacingOccurrencesOfString:@"\r" withString:@""];
	NSData* data = [res dataUsingEncoding:NSUnicodeStringEncoding];
	if(err)
	{
		NSLog(@"%@",err);
		return [NSDictionary dictionaryWithObjectsAndKeys:@"false", @"result", err.description, @"errorMessage", nil];
	}
	id dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
	if(err)
	{
		NSLog(@"%@",err);
		return [NSDictionary dictionaryWithObjectsAndKeys:@"false", @"result", err.description, @"errorMessage", nil];
	}
	#if NW_TRACE
	//  NSLog(@"result = >\n");
	//  for(NSString* k in dic.allKeys)
	//  {
	//      NSLog(@"%@ => %@",k,[dic objectForKey:k]);
	//  }
	#endif

	return dic;
}

+(NSDictionary*)postMessage:(NSURL*)url body:(NSDictionary*)info err:(NSError**)err
{
#if NW_TRACE
    NSLog(@"URL =>\n%@",url);
#endif
    NSHTTPURLResponse* response = nil;
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:5];
    
    [request setHTTPMethod:@"POST"];
    if(info != nil)
    {
        NSString* body = [self generatePostBody:info];
        NSLog(@"body = %@",body);
        [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    }
	
    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:err];
    //NSLog(@"data = %@",[NSString stringWithUTF8String:data.bytes]);
    if(*err)
    {
        NSLog(@"%@",*err);
        return nil;
    }
	
	id dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:err];
	if(*err)
	{
		NSLog(@"%@",*err);
		return [NSDictionary dictionaryWithObjectsAndKeys:@"false", @"result", (*err).description, @"errorMessage", nil];
	}
	return dic;
    //return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //return [NSString stringWithUTF8String:data.bytes];
}

+(NSDictionary*)postMultipartMessage:(NSURL*)url body:(NSDictionary*)info err:(NSError**)err
{
#if NW_TRACE
    NSLog(@"URL =>\n%@",url);
#endif
    NSHTTPURLResponse* response = nil;
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                            timeoutInterval:5];
    
    [request setHTTPMethod:@"POST"];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",kStringBoundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSData* body = [self generateMultipartPostBody:info];
    [request setHTTPBody:body];
	//  NSString* str = [[NSString alloc]initWithData:body encoding:NSUTF8StringEncoding];
	//  NSLog(@"body = %@",str);
    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:err];
    
    if(*err)
    {
        return nil;
    }

	id dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:err];
	if(*err)
	{
		NSLog(@"%@",*err);
		return [NSDictionary dictionaryWithObjectsAndKeys:@"false", @"result", (*err).description, @"errorMessage", nil];
	}
	return dic;
}



+(NSArray*)placeSearch:(CLLocationCoordinate2D)coord distance:(int)dist
{
	[[NetworkIndicatorManager shared] showIndicator];
    NSString* urlString = [searchUrl stringByAppendingFormat:@"?katX=%d&katY=%d&distance=%d",(int)coord.longitude,(int)coord.latitude,dist];
	//NSString* urlString = [searchUrl stringByAppendingString:@"?katX=376000&katY=586400&distance=2000"];
    NSURL* url = [NSURL URLWithString:urlString];
    NSArray* ret = (NSArray*)[self getMessage:url];
    [[NetworkIndicatorManager shared] hideIndicator];
    return ret;
}

+(NSDictionary*)placeInfo:(NSString*)idx
{
	[[NetworkIndicatorManager shared] showIndicator];
    NSString* urlString = [infoUrl stringByAppendingFormat:@"%@",idx];
    NSURL* url = [NSURL URLWithString:urlString];
    NSDictionary* ret = (NSDictionary*)[self getMessage:url];
    [[NetworkIndicatorManager shared] hideIndicator];
    return ret;
}

+(NSDictionary*)review:(NSDictionary*)info
{
	[[NetworkIndicatorManager shared] showIndicator];
    NSURL* url = [NSURL URLWithString:reviewUrl];
	NSError* err = nil;
    NSDictionary* ret = (NSDictionary*)[self postMultipartMessage:url body:info err:&err];
	if(err != nil)
	{
		[[NetworkIndicatorManager shared] hideIndicator];
		return nil;
	}
	NSLog(@"%@",ret);
    [[NetworkIndicatorManager shared] hideIndicator];
	return ret;
}
+(NSDictionary*)like:(NSString*)idx
{
	[[NetworkIndicatorManager shared] showIndicator];
    NSURL* url = [NSURL URLWithString:likeUrl];
	NSError* err = nil;
    NSDictionary* ret = (NSDictionary*)[self postMessage:url body:@{@"id":idx} err:&err];
	if(err != nil)
	{
		[[NetworkIndicatorManager shared] hideIndicator];
		return nil;
	}
	NSLog(@"%@",ret);
    [[NetworkIndicatorManager shared] hideIndicator];
	return ret;
}
@end
