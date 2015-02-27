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
#import "LocalizationManagerObject.h"
#import "Utilities.h"

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
	RAC(self, languagesArray) = [[[LocalizationManagerObject sharedInstance] languagesSignal] doNext:^(NSArray *x) {
		// Why not just log it since there is no UI for selection?
		NSLog(@"languages = %@", x);
	}];

	// Almost all that is needed for basic usage of manager is to subscribe to locale signal and react to changes.
	// On subscription there will be initial locale value, so it will be called at least once.
	// If there is better/more FRP way to do this, I'd love to know.
	[[[LocalizationManagerObject sharedInstance] localeSignal] subscribeNext:^(NSLocale *locale) {
		@strongify(self);
		[self localizeUIWithLocale:locale];
	}];

	// Simply for initial value since manager stores selected value
	RAC(self, languageIndex) = [[[LocalizationManagerObject sharedInstance] selectedLanguageIndexSignal] take:1];

	// Button command - this is called whenever button is tapped(if you don't forget to send completed as I did many
	// times ;) )
	self.languageChangeButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * (id input) {
		return [RACSignal createSignal:^RACDisposable * (id<RACSubscriber> subscriber) {
			@strongify(self);

			self.languageIndex++;

			NSUInteger langIndex = (self.languageIndex % [self.languagesArray count]);

			// That's second part - if you need to change language, select index based on languages array.
			[[LocalizationManagerObject sharedInstance] selectLanguageAtIndex:langIndex];

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
- (void)localizeUIWithLocale:(NSLocale *)locale
{
	self.dateFormatter.locale = locale;
	self.dateFormatter.dateFormat =
		[NSDateFormatter dateFormatFromTemplate:kDisplayDateFormatString options:0 locale:locale];
	self.sampleLabel.text = i2KLocalizedStringForKey(@"samplelabel");
	self.dateLabel.text = [self.dateFormatter stringFromDate:self.dateToDisplay];
	[self.languageChangeButton setTitle:i2KLocalizedStringForKey(@"languagebutton") forState:UIControlStateNormal];
}

@end
