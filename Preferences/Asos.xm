#import <Preferences/Preferences.h>
#import <AudioToolbox/AudioServices.h>
#import <notify.h>
#import "Interfaces.h"
#define kSettingsPath [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.phillipt.asos.plist"]

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
