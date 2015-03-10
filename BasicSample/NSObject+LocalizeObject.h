//
//  NSObject+LocalizeObject.h
//  ReactiveLocalizationManager
//
//  Created by Timur Kuchkarov on 10.03.15.
//  Copyright (c) 2015 i-2K. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACSignal;

typedef void (^LocalizationBlock)(id object, NSLocale *locale);

@interface NSObject (LocalizeObject)

- (void)setLocalizationSignal:(RACSignal *)signal withBlock:(LocalizationBlock)block;

@end
