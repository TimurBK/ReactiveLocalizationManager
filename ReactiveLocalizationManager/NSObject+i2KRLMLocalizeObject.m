//
//  NSObject+LocalizeObject.m
//  ReactiveLocalizationManager
//
//  Created by Timur Kuchkarov on 10.03.15.
//  Copyright (c) 2015 i-2K. All rights reserved.
//

#import "NSObject+i2KRLMLocalizeObject.h"
#import <ReactiveCocoa.h>
@import ObjectiveC.runtime;

@implementation NSObject (i2KRLMLocalizeObject)

- (void)i2KRLM_setLocalizationSignal:(RACSignal *)signal withBlock:(i2KRLMLocalizationBlock)block
{
	[self i2KRLM_setLocalizationBlock:block];
	[self rac_liftSelector:@selector(i2KRLM_localizeWithLocale:) withSignals:signal, nil];
}

- (void)i2KRLM_localizeWithLocale:(NSLocale *)locale
{
	[self i2KRLM_localizationBlock](self, locale);
}

- (void)i2KRLM_setLocalizationBlock:(i2KRLMLocalizationBlock)block
{
	objc_setAssociatedObject(self, @selector(i2KRLM_localizationBlock), block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (i2KRLMLocalizationBlock)i2KRLM_localizationBlock
{
	return objc_getAssociatedObject(self, @selector(i2KRLM_localizationBlock));
}

@end
