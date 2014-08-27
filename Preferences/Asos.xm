#import <Preferences/Preferences.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSTableCell.h>
#import <Preferences/PSEditableListController.h>
#import <AudioToolbox/AudioServices.h>
#import <notify.h>
#import "Interfaces.h"
#define kSettingsPath [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.phillipt.asos.plist"]

int width = [[UIScreen mainScreen] bounds].size.width;

@interface AsosListController: PSListController <UIAlertViewDelegate> {
}
@property (assign) NSMutableDictionary* prefs;
@end

UITextField *loginField;
_UIBackdropView *blurView;
UIView* sbWindow;
AsosListController* controller;
id timeInput;

@implementation AsosListController
@synthesize prefs;
- (id)specifiers {
	controller = self;
	timeInput = [self specifierAtIndex:1];

	prefs = [NSMutableDictionary dictionaryWithContentsOfFile:kSettingsPath];

	NSLog(@"[Asos] Prefs is %@", prefs);
	NSLog(@"[Asos] self.prefs is %@", self.prefs);

	if ([self.prefs objectForKey:@"passcode"] != nil && [self.prefs objectForKey:@"useRealPass"] != nil && [[self.prefs objectForKey:@"enabled"] boolValue] && prefs != nil && prefs.count != 0 && self.prefs.count != 0 && [[prefs objectForKey:@"enabled"] boolValue]) {
		sbWindow = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		[self.view addSubview:sbWindow];
		[sbWindow setBackgroundColor:[UIColor clearColor]];

		_UIBackdropViewSettings *settings = [_UIBackdropViewSettings settingsForPrivateStyle:3900];
		blurView = [[_UIBackdropView alloc] initWithFrame:CGRectZero autosizesToFitSuperview:YES settings:settings];

		blurView.alpha = 0;
		blurView.userInteractionEnabled=NO;
		[blurView setBlurQuality:@"default"];
		[sbWindow addSubview:blurView];

		[UIView animateWithDuration:0.4 animations:^{
			blurView.alpha = 1.0;
		}];
		UIAlertView* loginAlert = [[UIAlertView alloc] initWithTitle:@"Asos" message:@"Enter passcode to access Asos settings" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
		[loginAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
		loginField = [loginAlert textFieldAtIndex:0];
		[loginField setKeyboardType:UIKeyboardTypeNumberPad];
		loginField.autocorrectionType = UITextAutocorrectionTypeNo;
		loginField.enablesReturnKeyAutomatically = YES;
		[loginField setPlaceholder:@"15"];
		[loginAlert  show];
	}

	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Asos" target:self] retain];
	}
	NSLog(@"[Asos] specifiers is %@", _specifiers);
	NSLog(@"[Asos] specifiersByID is %@", _specifiersByID);

	return _specifiers;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString* passToUse;

	prefs = [NSMutableDictionary dictionaryWithContentsOfFile:kSettingsPath];
	NSLog(@"[Asos] prefs is %@", prefs);

	BOOL useRealPass = NO;
	NSString* settingsPass = [prefs objectForKey:@"passcode"];
	if (useRealPass) passToUse = prefs[@"userPass"];
	//else if (settingsPass) passToUse = settingsPass;

	if (buttonIndex != alertView.cancelButtonIndex) {
		if ([loginField.text isEqualToString:prefs[@"passcode"]] || [loginField.text isEqualToString:prefs[@"userPass"]]) {
			[UIView animateWithDuration:0.8 animations:^{
				blurView.alpha = 0.0;
				[blurView removeFromSuperview];
				[sbWindow removeFromSuperview];
				blurView = nil;
				sbWindow = nil;
			}];
		}
		else {
			[self.rootController popViewControllerAnimated:YES];
			AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
		}
	}
	else {
		[self.rootController popViewControllerAnimated:YES];
	}
}
@end

@protocol PreferencesTableCustomView
- (id)initWithSpecifier:(id)arg1;

@optional
- (CGFloat)preferredHeightForWidth:(CGFloat)arg1;
- (CGFloat)preferredHeightForWidth:(CGFloat)arg1 inTableView:(id)arg2;
@end

@interface AsosCustomCell : PSTableCell <PreferencesTableCustomView> {
	UILabel *_label;
	UILabel *underLabel;
	@public
	UILabel *randLabel;
}
-(NSString*)randomString;
@end

@implementation AsosCustomCell
- (id)initWithSpecifier:(PSSpecifier *)specifier
{
	//self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell" specifier:specifier];
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
	if (self) {
		CGRect frame = CGRectMake(0, -15, width, 60);
		CGRect botFrame = CGRectMake(0, 20, width, 60);
		CGRect randFrame = CGRectMake(0, 40, width, 60);
 
		_label = [[UILabel alloc] initWithFrame:frame];
		[_label setNumberOfLines:1];
		_label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:48];
		[_label setText:@"Asos"];
		[_label setBackgroundColor:[UIColor clearColor]];
		_label.textColor = [UIColor blackColor];
		//[_label setShadowColor:[UIColor blackColor]];
		//[_label setShadowOffset:CGSizeMake(1,1)];
		_label.textAlignment = NSTextAlignmentCenter;

		underLabel = [[UILabel alloc] initWithFrame:botFrame];
		[underLabel setNumberOfLines:1];
		underLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
		[underLabel setText:@"Keep your privacy private"];
		[underLabel setBackgroundColor:[UIColor clearColor]];
		underLabel.textColor = [UIColor grayColor];
		underLabel.textAlignment = NSTextAlignmentCenter;

		randLabel = [[UILabel alloc] initWithFrame:randFrame];
		[randLabel setNumberOfLines:1];
		randLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
		[randLabel setText:[self randomString]];
		[randLabel setBackgroundColor:[UIColor clearColor]];
		randLabel.textColor = [UIColor grayColor];
		randLabel.textAlignment = NSTextAlignmentCenter;
 
		[self addSubview:_label];
		[self addSubview:underLabel];
		[self addSubview:randLabel];
		//[_label release];
		//[underLabel release];
		//[randLabel release];

	}
	return self;
}
int randNum = 0;
-(NSString*)randomString {
	//int randNum = arc4random_uniform(10);
	if (randNum == 8) randNum = 0;
	switch (randNum) {
		case 0:
			if (randNum == 0) randNum++;
			else if (randNum < 8 && randNum != 0) randNum++;
			return @"Thank you for your purchase.";
		case 1:
			if (randNum == 0) randNum++;
			else if (randNum < 8 && randNum != 0) randNum++;
			return @"Enjoy.";
		case 2:
			if (randNum == 0) randNum++;
			else if (randNum < 8 && randNum != 0) randNum++;
			return @"From Phillip Tennen and the Cortex Dev Team";
			//return @"From Phillip Tennen";
		case 3:
			if (randNum == 0) randNum++;
			else if (randNum < 8 && randNum != 0) randNum++;
			return @"Use responsibly.";
		case 4:
			if (randNum == 0) randNum++;
			else if (randNum < 8 && randNum != 0) randNum++;
			return @"Follow @phillipten on Twitter.";
		case 5:
			if (randNum == 0) randNum++;
			else if (randNum < 8 && randNum != 0) randNum++;
			return @"Follow @CortexDevTeam on Twitter.";
			//return @"Is this thing on?";
		case 6:
			if (randNum == 0) randNum++;
			else if (randNum < 8 && randNum != 0) randNum++;
			return @"We love you, /r/jailbreak!";
		case 7:
			if (randNum == 0) randNum++;
			else if (randNum < 8 && randNum != 0) randNum++;
			//return @"Is this thing on?"; 
			return @"Aeeiii! I'm a bug.";
		default:
			return @"Aeeiii! I'm a bug.";
	}
}
 
- (CGFloat)preferredHeightForWidth:(CGFloat)arg1 {
	return 90.f;
}
@end

void loadPreferences() {
	NSMutableDictionary* prefs = [NSMutableDictionary dictionaryWithContentsOfFile:kSettingsPath];

	NSLog(@"[Asos] timeInput is %@", timeInput);
	NSLog(@"[Asos] spsecifierAtIndex 10 is %@", [controller specifierAtIndex:10]);

	if (![[prefs objectForKey:@"atTime"] boolValue]) {
		[controller removeSpecifier:timeInput animated:YES];
	}
	else {
		[controller insertSpecifier:timeInput atIndex:10 animated:YES];
	}
}

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
									NULL,
									(CFNotificationCallback)loadPreferences,
									CFSTR("com.phillipt.asos/settingschanged"),
									NULL,
									CFNotificationSuspensionBehaviorDeliverImmediately);
	
	loadPreferences();
}

@interface Applications: PSListController {
}
@end

// vim:ft=objc
