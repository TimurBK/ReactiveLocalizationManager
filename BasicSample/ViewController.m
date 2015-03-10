//
//  ViewController.m
//  ReactiveLocalizationManager
//
//  Created by Timur Kuchkarov on 26.02.15.
//  Copyright (c) 2015 i-2K. All rights reserved.
//

#import "ViewController.h"

/// Reactive cocoa import
#import <ReactiveCocoa.h>

/// Localization manager import. Utilities are needed for shortcut function i2KLocalizedStringForKey("").
#import "i2KRLMLocalizationManagerObject.h"
#import "i2KRLMUtilities.h"

#import "NSObject+LocalizeObject.h"

static NSString *const kDisplayDateFormatString = @"dd.MM.yyyy j:mm";

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIButton *languageChangeButton;
@property (nonatomic, weak) IBOutlet UILabel *sampleLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSArray *languagesArray;
@property (nonatomic, strong) NSDate *dateToDisplay;
@property (nonatomic, assign) NSUInteger languageIndex;

@end

@implementation ViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.dateToDisplay = [NSDate dateWithTimeIntervalSinceReferenceDate:1000000];

	self.dateFormatter = [[NSDateFormatter alloc] init];

	[self setupSignals];
}

#pragma mark - RAC

- (void)setupSignals
{
	@weakify(self);

	// This array can be used for pickers but here it's used only for count
	RAC(self, languagesArray) =
		[[[i2KRLMLocalizationManagerObject sharedInstance] languagesSignal] doNext:^(NSArray *x) {
		  // Why not just log it since there is no UI for selection?
		  NSLog(@"languages = %@", x);
		}];

	// Almost all that is needed for basic usage of manager is to subscribe to locale signal and react to changes.
	// On subscription there will be initial locale value, so it will be called at least once. You also need to
	// implement corresponding selector.

	//	[[[i2KRLMLocalizationManagerObject sharedInstance] localeSignal] subscribeNext:^(NSLocale *locale) {
	//		@strongify(self);
	//		[self localizeWithLocale:locale];
	//	}];

	//  Another way to do the same is lifting localization selector with localization signal like this. Probably this is
	//  more FRP way.
	//	[self rac_liftSelector:@selector(localizeWithLocale:) withSignals:[[i2KRLMLocalizationManagerObject
	// sharedInstance] localeSignal], nil];

	// Below is basically the variation of lifting selector. #import "NSObject+LocalizeObject.h" imports a category with
	// 2 methods: @code - (void)setLocalizationSignal:(RACSignal *)signal @endcode and @code -
	// (void)localizeWithLocale:(NSLocale *)locale @endcode where second one is lifted with signal provided to first
	// one.

	// You can do this either for each thing you want to localize or just for view and do all localization there.

	[self.dateFormatter
		setLocalizationSignal:[[i2KRLMLocalizationManagerObject sharedInstance] localeSignal]
					withBlock:^(id object, NSLocale *locale) {
					  NSDateFormatter *dateFormatter = (NSDateFormatter *)object;
					  dateFormatter.locale = locale;
					  dateFormatter.dateFormat =
						  [NSDateFormatter dateFormatFromTemplate:kDisplayDateFormatString options:0 locale:locale];

					}];

	[self.sampleLabel setLocalizationSignal:[[i2KRLMLocalizationManagerObject sharedInstance] localeSignal]
								  withBlock:^(id object, NSLocale *locale) {
									UILabel *sampleLabel = (UILabel *)object;
									sampleLabel.text = i2KLocalizedStringForKey(@"samplelabel");
								  }];

	[self.dateLabel setLocalizationSignal:[[i2KRLMLocalizationManagerObject sharedInstance] localeSignal]
								withBlock:^(id object, NSLocale *locale) {
								  UILabel *dateLabel = (UILabel *)object;
								  dateLabel.text = [self.dateFormatter stringFromDate:self.dateToDisplay];
								}];

	[self.languageChangeButton
		setLocalizationSignal:[[i2KRLMLocalizationManagerObject sharedInstance] localeSignal]
					withBlock:^(id object, NSLocale *locale) {
					  UIButton *button = (UIButton *)object;
					  [button setTitle:i2KLocalizedStringForKey(@"languagebutton") forState:UIControlStateNormal];
					}];

	//	[self setLocalizationSignal:[[i2KRLMLocalizationManagerObject sharedInstance] localeSignal]
	//					  withBlock:^(id object, NSLocale *locale) {
	//						ViewController *vc = (ViewController *)object;
	//						vc.dateFormatter.locale = locale;
	//						vc.dateFormatter.dateFormat =
	//							[NSDateFormatter dateFormatFromTemplate:kDisplayDateFormatString options:0
	// locale:locale];
	//						vc.sampleLabel.text = i2KLocalizedStringForKey(@"samplelabel");
	//						vc.dateLabel.text = [vc.dateFormatter stringFromDate:vc.dateToDisplay];
	//						[vc.languageChangeButton setTitle:i2KLocalizedStringForKey(@"languagebutton")
	//												 forState:UIControlStateNormal];
	//					  }];

	// Simply for initial value since manager stores selected value
	RAC(self, languageIndex) = [[[i2KRLMLocalizationManagerObject sharedInstance] selectedLanguageIndexSignal] take:1];

	// Button command - this is called whenever button is tapped(if you don't forget to complete command signal in any
	// way as I did many times ;) )
	self.languageChangeButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
	  return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
		@strongify(self);

		self.languageIndex++;

		NSUInteger langIndex = (self.languageIndex % [self.languagesArray count]);

		// That's second part - if you need to change language, select index based on languages array.
		[[i2KRLMLocalizationManagerObject sharedInstance] selectLanguageAtIndex:langIndex];

		[subscriber sendCompleted];
		return nil;
	  }];
	}];
}

#pragma mark - Localization

/**
 *  This method is called whenever locale changes so react accordingly.
 *
 *  @param locale Latest locale value.
 */
//- (void)localizeWithLocale:(NSLocale *)locale
//{
//	self.dateFormatter.locale = locale;
//	self.dateFormatter.dateFormat =
//		[NSDateFormatter dateFormatFromTemplate:kDisplayDateFormatString options:0 locale:locale];
//	self.sampleLabel.text = i2KLocalizedStringForKey(@"samplelabel");
//	self.dateLabel.text = [self.dateFormatter stringFromDate:self.dateToDisplay];
//	[self.languageChangeButton setTitle:i2KLocalizedStringForKey(@"languagebutton") forState:UIControlStateNormal];
//}

@end
