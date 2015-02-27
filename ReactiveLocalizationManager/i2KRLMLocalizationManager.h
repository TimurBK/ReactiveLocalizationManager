//
//  LocalizationManager.h
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

#import "i2KRLMSingletonProtocol.h"

@class RACSignal;

@protocol i2KRLMLocalizationManager<i2KRLMSingletonProtocol>

/**
 *  On subscription this signal sends current locale value, then sends new locale each time it's changed.
 *
 *  @return Signal which sends 'next' event with NSLocale object on subscription and then each time localization
 *  changes.
 */
- (RACSignal *)localeSignal;

/**
 *  This signal sends index of current locale in languages array.
 *
 *  @return Signal which sends 'next' event with index of current language on subscription and after language changes.
 */
- (RACSignal *)selectedLanguageIndexSignal;

/**
 *  This signal sends array of localizable language names for displaying it somewhere.
 *
 *  @return Signal which sends 'next' each time when languages aaray changes(currently there will be only initial
 *value).
 */
- (RACSignal *)languagesSignal;

/**
 *  This method changes language based on language index. Index should be based on array from array provided by @code
 *  - (RACSignal *)languagesSignal @endcode
 *
 *  @param index index of language in provided languages array.
 */
- (void)selectLanguageAtIndex:(NSUInteger)index;

/**
 *  Gets string based on provided key from currently loaded language bundle.
 *
 *  @param key Key for string lookup.
 *
 *  @return String from language bundle based on key.
 */
- (NSString *)localizedStringForKey:(NSString *)key;

/**
 *  Gets string based on provided key in table with provided name from currently loaded language bundle.
 *
 *  @param key       Key for string lookup.
 *  @param tableName Table name for lookup.
 *
 *  @return String from language bundle based on key and table name.
 */
- (NSString *)localizedStringForKey:(NSString *)key table:(NSString *)tableName;

/**
 *  Gets string based on provided key in table with provided name from currently loaded language bundle. Default value
 *	is used if no string can be found.
 *
 *  @param key       Key for string lookup.
 *  @param value     Value to use if no string is found.
 *  @param tableName Table name for lookup.
 *
 *  @return String from language bundle based on key and table name.
 */
- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName;

@end
