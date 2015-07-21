//
//  NSObject+LocalizeObject.h
//  ReactiveLocalizationManager
//
//  Created by Timur Kuchkarov on 10.03.15.
//  Copyright (c) 2015 i-2K. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACSignal;

typedef void (^i2KRLMLocalizationBlock)(id object, NSLocale *locale);

@interface NSObject (i2KRLMLocalizeObject)

- (void)i2KRLM_setLocalizationSignal:(RACSignal *)signal withBlock:(i2KRLMLocalizationBlock)block;

@end
