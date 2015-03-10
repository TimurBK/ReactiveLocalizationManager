//
//  NSObject+LocalizeObject.m
//  ReactiveLocalizationManager
//
//  Created by Timur Kuchkarov on 10.03.15.
//  Copyright (c) 2015 i-2K. All rights reserved.
//

#import "NSObject+LocalizeObject.h"
#import <ReactiveCocoa.h>
@import ObjectiveC.runtime;

@implementation NSObject (LocalizeObject)

- (void)setLocalizationSignal:(RACSignal *)signal withBlock:(LocalizationBlock)block
{
	[self setLocalizationBlock:block];
	[self rac_liftSelector:@selector(localizeWithLocale:) withSignals:signal, nil];
}

- (void)localizeWithLocale:(NSLocale *)locale
{
	[self localizationBlock](self, locale);
}

- (void)setLocalizationBlock:(LocalizationBlock)block
{
	objc_setAssociatedObject(self, @selector(localizationBlock), block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (LocalizationBlock)localizationBlock
{
	return objc_getAssociatedObject(self, @selector(localizationBlock));
}

@end
