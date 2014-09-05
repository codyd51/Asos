#import <Preferences/PSListController.h>
#import <Preferences/PSTableCell.h>
#import <Preferences/PSEditableListController.h>
#import <AudioToolbox/AudioServices.h>
#import "Interfaces.h"


#ifdef DEBUG
	#define DebugLog(s, ...) NSLog(@" [Asos Prefs] >> %@", [NSString stringWithFormat:(s), ##__VA_ARGS__])
#else
	#define DebugLog(s, ...)
#endif


// Interfaces //

@interface AsosListController: PSListController <UIAlertViewDelegate>
@property (nonatomic, strong) NSMutableDictionary* prefs;
@property (nonatomic, strong) PSSpecifier *timeInputSpecifier;
@property (nonatomic, strong) UIView* sbWindow;
@property (nonatomic, strong) _UIBackdropView *blurView;
@property (nonatomic, strong) UIAlertView* loginAlert;
@property (nonatomic, assign) int randNum;
@end


@interface AsosCustomCell : PSTableCell
- (NSString*)randomString;
@end


@interface Applications : PSListController
@end



// Globals //

#define kSettingsPath [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.phillipt.asos.plist"]
static AsosListController *controller;



// Helper Functions //

void showOrHideTimeInputCell() {
	DebugLog(@"showOrHideTimeInputCell()");
	
	if (controller.specifiers) {
		if (controller && [controller.prefs[@"atTime"] boolValue]) {
			DebugLog(@"showing the time input specifier...");
//			[controller insertSpecifier:controller.timeInputSpecifier afterSpecifierID:@"atTime" animated:YES];
			[controller insertSpecifier:controller.timeInputSpecifier atIndex:10 animated:YES];
		} else {
			DebugLog(@"hiding the time input specifier...");
			[controller removeSpecifier:controller.timeInputSpecifier animated:YES];
		}
	}
}

void loadPreferences() {
	DebugLog(@"loadPreferences()");
	
	if (controller) {
		controller.prefs = [NSMutableDictionary dictionaryWithContentsOfFile:kSettingsPath];
		DebugLog(@"loaded prefs from disk: %@", controller.prefs);
	}
	showOrHideTimeInputCell();
}


// Settings Controller //

@implementation AsosListController

- (id)initForContentSize:(CGSize)size {
	DebugLog(@"settings init");
	
	self = [super initForContentSize:size];
	if (self) {
		controller = self;
		_randNum = 0;
		
		// observe notifications
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
										NULL,
										(CFNotificationCallback)loadPreferences,
										CFSTR("com.phillipt.asos/settingschanged"),
										NULL,
										CFNotificationSuspensionBehaviorDeliverImmediately);
	}
	return self;
}

- (id)specifiers {
	if (_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Asos" target:self];
		DebugLog(@"read specifiers from disk: %@", _specifiers);
	}
//	
//	self.timeInputSpecifier = [self specifierForID:@"timeInterval"];
//	DebugLog(@"got timeInput specifier: %@", self.timeInputSpecifier);
//	
//	loadPreferences();
//	
//	if (self.prefs && [self.prefs[@"enabled"] boolValue]) {
//		if ((self.prefs[@"passcode"]) || [self.prefs[@"useRealPass"] boolValue]) {
//			[self showAlert];
//		}
//	}
	
	return _specifiers;
}
/*
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	DebugLog(@"alertView button clicked");
	
	if (buttonIndex == alertView.cancelButtonIndex) {
		[self.rootController popViewControllerAnimated:YES];
		
	} else {
		self.prefs = [NSMutableDictionary dictionaryWithContentsOfFile:kSettingsPath];
		DebugLog(@"prefs is %@", self.prefs);
		
		BOOL useRealPass = [[self.prefs objectForKey:@"useRealPass"] boolValue];
		DebugLog(@"using real passocde: %@", useRealPass?@"YES":@"NO");
		
		NSString *passToUse = (useRealPass) ? self.prefs[@"userPass"] : self.prefs[@"passcode"];
		DebugLog(@"using passocde: %@", passToUse);
		
		if (!passToUse) {
			DebugLog(@"NO PASSCODE FOUND IN SETTINGS, something went wrong.");
			[self hideAlert]; // probably should do something else here
			
		} else {
			UITextField *loginField = [self.loginAlert textFieldAtIndex:0];

			if ([loginField.text isEqualToString:passToUse]) {
				// correct code entered
				[self hideAlert];
			} else {
				// wrong code, very vibration
				[self.rootController popViewControllerAnimated:YES];
					AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
			}
		}
	}
}

- (void)showAlert {
	DebugLog(@"showAlert()");
	
	self.sbWindow = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.sbWindow.backgroundColor = UIColor.clearColor;
	[self.view addSubview:self.sbWindow];
	
	_UIBackdropViewSettings *settings = [_UIBackdropViewSettings settingsForPrivateStyle:3900];
	self.blurView = [[_UIBackdropView alloc] initWithFrame:CGRectZero autosizesToFitSuperview:YES settings:settings];
	
	self.blurView.alpha = 0;
	self.blurView.userInteractionEnabled = NO;
	[self.blurView setBlurQuality:@"default"];
	[self.sbWindow addSubview:self.blurView];
	
	self.loginAlert = [[UIAlertView alloc] initWithTitle:@"Asos" message:@"Enter passcode to access Asos settings" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
	[self.loginAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
	
	UITextField *loginField = [self.loginAlert textFieldAtIndex:0];
	[loginField setKeyboardType:UIKeyboardTypeNumberPad];
	loginField.autocorrectionType = UITextAutocorrectionTypeNo;
	loginField.enablesReturnKeyAutomatically = YES;
	[loginField setPlaceholder:@"15"];
	
	
	// show blur animation
	[UIView animateWithDuration:0.4 animations:^{
		self.blurView.alpha = 1.0;
	}];
	
	// show alert
	[self.loginAlert show];
}

- (void)hideAlert {
	DebugLog(@"hideAlert()");
	[UIView animateWithDuration:0.8 animations:^{
		self.blurView.alpha = 0;
	}];
	
	[self.blurView removeFromSuperview];
	[self.sbWindow removeFromSuperview];
	self.loginAlert = nil;
	self.blurView = nil;
	self.sbWindow = nil;
}
*/
@end



// Logo Cell //

@implementation AsosCustomCell

- (id)initWithSpecifier:(PSSpecifier *)specifier {
	DebugLog(@"custom cell init");
	
	self = [super initWithStyle:UITableViewCellStyleDefault
				reuseIdentifier:@"Cell"
					  specifier:specifier];
	if (self) {
		int width = self.bounds.size.width;
		CGRect frame = CGRectMake(0, -15, width, 60);
		CGRect botFrame = CGRectMake(0, 20, width, 60);
		CGRect randFrame = CGRectMake(0, 40, width, 60);
		
		// label 1
		UILabel *label = [[UILabel alloc] initWithFrame:frame];
		label.numberOfLines = 1;
		label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:48];
		label.text = @"Asos";
		label.backgroundColor = UIColor.clearColor;
		label.textColor = UIColor.blackColor;
		//[_label setShadowColor:[UIColor blackColor]];
		//[_label setShadowOffset:CGSizeMake(1,1)];
		label.textAlignment = NSTextAlignmentCenter;
		
		// label 2
		UILabel *underLabel = [[UILabel alloc] initWithFrame:botFrame];
		underLabel.numberOfLines = 1;
		underLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
		underLabel.text = @"Keep your privacy private.";
		underLabel.backgroundColor = UIColor.clearColor;
		underLabel.textColor = UIColor.grayColor;
		underLabel.textAlignment = NSTextAlignmentCenter;
		
		// label 3
		UILabel *randLabel = [[UILabel alloc] initWithFrame:randFrame];
		randLabel.numberOfLines = 1;
		randLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
		randLabel.text = [self randomString];
		randLabel.backgroundColor = UIColor.clearColor;
		randLabel.textColor = UIColor.grayColor;
		randLabel.textAlignment = NSTextAlignmentCenter;
		
		[self addSubview:label];
		[self addSubview:underLabel];
		[self addSubview:randLabel];
	}
	return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1 {
	return 90.0f;
}

- (NSString*)randomString {
	//randNum = arc4random_uniform(10);
	NSString *result;
	int randNum = controller.randNum;
	if (randNum == 8) randNum = 0;
	
	switch (randNum) {
		case 0:
			result = @"Thank you for your purchase.";
			break;
		case 1:
			result = @"Enjoy.";
			break;
		case 2:
			result = @"From Phillip Tennen and the Cortex Dev Team";
			//result = @"From Phillip Tennen";
			break;
		case 3:
			result = @"Use responsibly.";
			break;
		case 4:
			result = @"Follow @phillipten on Twitter.";
			break;
		case 5:
			result = @"Follow @CortexDevTeam on Twitter.";
			//result = @"Is this thing on?";
			break;
		case 6:
			result = @"We love you, /r/jailbreak!";
			break;
		case 7:
			result = @"Aeeiii! I'm a bug.";
			//result = @"Is this thing on?";
			break;
			
		default:
			result = @"Aeeiii! I'm a bug.";
			break;
	}
	
	DebugLog(@"RandomString chosen (%d): %@", randNum, result);
	randNum++;
	controller.randNum = randNum;
	
	return result;
}

@end

