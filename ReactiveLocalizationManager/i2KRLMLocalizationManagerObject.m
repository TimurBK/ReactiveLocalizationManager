//
//  LocalizationManagerObject.m
//  ReactiveLocalizationManager
//
//  Created by Timur Kuchkarov on 18.09.14.
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Timur Kuchkarov, i-2K
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
// documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
// Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "i2KRLMLocalizationManagerObject.h"
#import <ReactiveCocoa.h>
#import "RACEXTScope.h"

static NSString *const LOCALEMANAGER_LanguageConfigFileName = @"LocalizationConfiguration";
static NSString *const LOCALEMANAGER_LanguageConfigFileType = @"plist";
static NSString *const LOCALEMANAGER_LanguageConfigReadError = @"Can't read order file.\nError = %@";
static NSString *const LOCALEMANAGER_LanguageConfigOrderKeyPath = @"Order";
static NSString *const LOCALEMANAGER_LanguageConfigDefaultLanguageKeyPath = @"DefaultLanguage";
static NSString *const LOCALEMANAGER_UserDefaultsSelectedLanguageKeyPath = @"SelectedLanguage";

static NSString *const LOCALEMANAGER_DefaultStringForLocalizedValue = @"--!NO TRANSLATION!--";
static NSString *const LOCALEMANAGER_LocalizationBundleType = @"lproj";
static NSString *const LOCALEMANAGER_BaseLocalizationName = @"Base";

@interface i2KRLMLocalizationManagerObject ()

@property (nonatomic, strong) NSBundle *languageBundle;
@property (nonatomic, strong) NSArray *languageCodes;
@property (nonatomic, strong) NSString *defaultLanguageCode;

@property (nonatomic, strong) RACReplaySubject *localeSignal;
@property (nonatomic, strong) RACReplaySubject *selectedLanguageIndexSignal;
@property (nonatomic, strong) RACReplaySubject *languagesSignal;

- (void)reloadBundleWithLocaleID:(NSString *)localeID;
- (void)changeToLocale:(NSLocale *)locale;

@end

@implementation i2KRLMLocalizationManagerObject

#pragma mark - Internal

#pragma mark - Configuration

- (void)initialConfiguration
{
	[self configureSignals];
	[self configureAppLocalizations];
}

- (void)configureSignals
{
	self.localeSignal = [RACReplaySubject replaySubjectWithCapacity:1];
	self.languagesSignal = [RACReplaySubject replaySubjectWithCapacity:1];
	self.selectedLanguageIndexSignal = [RACReplaySubject replaySubjectWithCapacity:1];
}

- (void)configureAppLocalizations
{
	NSArray *bundleLocalizations = [[NSBundle mainBundle] localizations];
	self.languageCodes = [[[bundleLocalizations rac_sequence] filter:^BOOL(NSString *value) {
		BOOL result = ![value isEqualToString:LOCALEMANAGER_BaseLocalizationName];
		return result;
	}] array];

	[self readConfiguration];

	NSArray *languageNames = [[[self.languageCodes rac_sequence] map:^id(NSString *value) {
		NSLocale *tempLocale = [NSLocale localeWithLocaleIdentifier:value];
		return [[tempLocale displayNameForKey:NSLocaleLanguageCode value:value] capitalizedStringWithLocale:tempLocale];
	}] array];

	[self.languagesSignal sendNext:languageNames];

	[self.selectedLanguageIndexSignal sendNext:@([self.languageCodes indexOfObject:self.defaultLanguageCode])];
	[self changeToLocale:[NSLocale localeWithLocaleIdentifier:self.defaultLanguageCode]];
}

- (void)readConfiguration
{
	NSString *plistPath = [[NSBundle mainBundle] pathForResource:LOCALEMANAGER_LanguageConfigFileName
														  ofType:LOCALEMANAGER_LanguageConfigFileType];

	NSString *storedLanguageCode =
		[[NSUserDefaults standardUserDefaults] objectForKey:LOCALEMANAGER_UserDefaultsSelectedLanguageKeyPath];

	if (storedLanguageCode != nil && [self.languageCodes indexOfObject:storedLanguageCode] != NSNotFound) {
		self.defaultLanguageCode = storedLanguageCode;
	}
	if (!plistPath) {
		if (!self.defaultLanguageCode) {
			self.defaultLanguageCode = [[[NSBundle mainBundle] preferredLocalizations] firstObject];
		}
		return;
	}
	NSData *plistData = [NSData dataWithContentsOfFile:plistPath];

	NSError *error = nil;
	NSDictionary *configuration =
		[NSPropertyListSerialization propertyListWithData:plistData options:0 format:NULL error:&error];

	NSAssert(error == nil, LOCALEMANAGER_LanguageConfigReadError, error.localizedDescription);
	NSString *defaultCode = [configuration valueForKeyPath:LOCALEMANAGER_LanguageConfigDefaultLanguageKeyPath];
	if (!self.defaultLanguageCode) {
		if ([defaultCode length] > 1) {
			self.defaultLanguageCode =
				[configuration valueForKeyPath:LOCALEMANAGER_LanguageConfigDefaultLanguageKeyPath];
		} else {
			self.defaultLanguageCode = [[[NSBundle mainBundle] preferredLocalizations] firstObject];
		}
	}

	@weakify(self);
	NSArray *languagesOrder = [[[[configuration valueForKeyPath:LOCALEMANAGER_LanguageConfigOrderKeyPath] rac_sequence]
		filter:^BOOL(NSString *value) {
			@strongify(self);
			return [self.languageCodes containsObject:value];
		}] array];

	NSMutableOrderedSet *languages = [NSMutableOrderedSet orderedSetWithArray:languagesOrder];
	[languages addObjectsFromArray:self.languageCodes];
	self.languageCodes = [NSArray arrayWithArray:[languages array]];
}

#pragma mark - Helpers

- (void)reloadBundleWithLocaleID:(NSString *)localeID
{
	NSString *path = [[NSBundle mainBundle] pathForResource:localeID ofType:LOCALEMANAGER_LocalizationBundleType];
	self.languageBundle = [NSBundle bundleWithPath:path];
}

- (void)changeToLocale:(NSLocale *)locale
{
	[self reloadBundleWithLocaleID:[locale localeIdentifier]];
	[self.localeSignal sendNext:locale];
}

#pragma mark - Protocols

#pragma mark - Singleton protocol

+ (instancetype)sharedInstance
{
	static i2KRLMLocalizationManagerObject *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[[self class] alloc] init];
		[sharedInstance initialConfiguration];
	});
	return sharedInstance;
}

#pragma mark - Localization manager protocol

- (void)selectLanguageAtIndex:(NSUInteger)index
{
	if (index < self.languageCodes.count) {
		NSString *localeID = self.languageCodes[index];
		[[NSUserDefaults standardUserDefaults] setObject:localeID
												  forKey:LOCALEMANAGER_UserDefaultsSelectedLanguageKeyPath];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[self.selectedLanguageIndexSignal sendNext:@(index)];
		[self changeToLocale:[NSLocale localeWithLocaleIdentifier:localeID]];
	}
}

- (NSString *)localizedStringForKey:(NSString *)key
{
	return [self localizedStringForKey:key table:nil];
}

- (NSString *)localizedStringForKey:(NSString *)key table:(NSString *)tableName
{
	return [self localizedStringForKey:key value:LOCALEMANAGER_DefaultStringForLocalizedValue table:tableName];
}

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName
{
	return [self.languageBundle localizedStringForKey:key value:value table:tableName];
}

@end
