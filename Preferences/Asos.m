#import <Preferences/PSListController.h>
#import <Preferences/PSTableCell.h>
#import <Preferences/PSEditableListController.h>
#import <ManagedConfiguration/MCPasscodeManager.h>
#import "Interfaces.h"

#define DEBUG_PREFIX @" [Asos:Prefs]"
#import "../DebugLog.h"


//
// Interfaces
//
@interface AsosListController: PSListController <UIAlertViewDelegate>
@property (nonatomic, strong) NSMutableDictionary* prefs;
@property (nonatomic, strong) PSSpecifier *timeInputSpecifier;
@property (nonatomic, strong) UIView* sbWindow;
@property (nonatomic, strong) _UIBackdropView *blurView;
@property (nonatomic, strong) UIAlertView* passcodeAlert;
@property (nonatomic, assign) int randNum;
@end

@interface AsosCustomCell : PSTableCell
//- (NSString*)randomString;
@end

@interface Applications : PSListController
@end



//
// Globals
//
#define kSettingsPath [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.cortexdevteam.asos.plist"]
#define kSettingsIconPath	@"/Library/PreferenceBundles/Asos.bundle/Asos@2x.png"
#define kSettingsLogoPath	@"/Library/PreferenceBundles/Asos.bundle/Logo@2x.png"

static AsosListController *controller;



//
// Helpers
//

void showOrHideTimeInputCell() {
	DebugLogC(@"showOrHideTimeInputCell()");
	
	if (controller.specifiers) {
		if (controller && [controller.prefs[@"atTime"] boolValue]) {
			DebugLogC(@"showing the time input specifier...");
//			[controller insertSpecifier:controller.timeInputSpecifier afterSpecifierID:@"atTime" animated:YES];
			[controller insertSpecifier:controller.timeInputSpecifier atIndex:10 animated:YES];
		} else {
			DebugLogC(@"hiding the time input specifier...");
			[controller removeSpecifier:controller.timeInputSpecifier animated:YES];
		}
	}
}

void loadPreferences() {
	DebugLogC(@"loadPreferences()");
	
	if (controller) {
		controller.prefs = [NSMutableDictionary dictionaryWithContentsOfFile:kSettingsPath];
		DebugLogC(@"loaded prefs from disk: %@", controller.prefs);
	}
	showOrHideTimeInputCell();
}



//
// Settings Controller
//
@implementation AsosListController
- (id)initForContentSize:(CGSize)size {
	DebugLog(@"settings init'd.");
	
	self = [super initForContentSize:size];
	if (self) {
		controller = self;
		_randNum = 0;
		
		// add a Respring button to the navbar
		UIBarButtonItem *respringButton = [[UIBarButtonItem alloc]
										   initWithTitle:@"Respring"
										   style:UIBarButtonItemStyleDone
										   target:self
										   action:@selector(showRespringAlert)];
		
		respringButton.tintColor = [UIColor colorWithRed:212/255.0 green:86/255.0 blue:217/255.0 alpha:1];
		
		[self.navigationItem setRightBarButtonItem:respringButton];
		
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
										NULL,
										(CFNotificationCallback)loadPreferences,
										CFSTR("com.cortexdevteam.asos/settingschanged"),
										NULL,
										CFNotificationSuspensionBehaviorDeliverImmediately);
		
		// load user settings
		_prefs = [NSMutableDictionary dictionaryWithContentsOfFile:kSettingsPath];
		DebugLog(@"read prefs plist, prefs=%@", _prefs);
		
		// passcode protect Asos' settings
		DebugLog(@"Asos is passcode locked.");
		[self showPasscodeAlert];
	}
	return self;
}
- (id)specifiers {
	if (_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Asos" target:self];
		DebugLog(@"read specifiers from disk: %@", _specifiers);
		
		self.timeInputSpecifier = [self specifierForID:@"timeInterval"];
		DebugLog(@"got timeInput specifier: %@", self.timeInputSpecifier);
	}
	
	return _specifiers;
}
- (void)viewDidLoad {
	[super viewDidLoad];
	showOrHideTimeInputCell();
}
- (void)showRespringAlert {
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"Respring now?"
						  message:@"Please Respring to enable or disable this tweak."
						  delegate:self
						  cancelButtonTitle:@"NO"
						  otherButtonTitles:@"YES", nil];
	alert.tag = 996699;
	[alert show];
}
- (void)respring {
	NSLog(@"Notific8 called for a respring.");
	system("killall -HUP SpringBoard");
}
- (void)setTitle:(id)title {
	[super setTitle:title];
	
	UIImage *icon = [[UIImage alloc] initWithContentsOfFile:kSettingsIconPath];
	if (icon) {
		UIImageView *iconView = [[UIImageView alloc] initWithImage:icon];
		self.navigationItem.titleView = iconView;
	}
}
- (void)showPasscodeAlert {
	DebugLog0;
	
	if (!self.blurView) {
		self.blurView = [[_UIBackdropView alloc] initWithFrame:CGRectZero
												   autosizesToFitSuperview:YES
																  settings:[_UIBackdropViewSettings	settingsForPrivateStyle:3900]];
		[self.blurView setBlurQuality:@"default"];
		[[[UIApplication sharedApplication] keyWindow] addSubview:self.blurView];
	}
	
	if (!self.passcodeAlert) {
		self.passcodeAlert = [[UIAlertView alloc] initWithTitle:@"Asos"
															 message:@"Enter passcode to access Asos settings"
															delegate:self
												   cancelButtonTitle:@"Cancel"
												   otherButtonTitles:@"Ok", nil];
		[self.passcodeAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
		
		UITextField *loginField = [self.passcodeAlert textFieldAtIndex:0];
		[loginField setKeyboardType:UIKeyboardTypeNumberPad];
		loginField.autocorrectionType = UITextAutocorrectionTypeNo;
		loginField.enablesReturnKeyAutomatically = YES;
	}
	
	// show blur animation
	[UIView animateWithDuration:0.4 animations:^{
		self.blurView.alpha = 1.0;
	}];
	
	// show alert
	[self.passcodeAlert show];
}
- (void)hidePasscodeAlert {
	DebugLog0;
	
	[UIView animateWithDuration:0.4 animations:^{
		self.blurView.alpha = 0;
	}];
	[self.passcodeAlert dismissWithClickedButtonIndex:0 animated:YES];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	DebugLog(@"clicked button: %d", (int)buttonIndex);
	
	if (alertView.tag == 996699) {
		// Respring Alert
		if (buttonIndex == alertView.cancelButtonIndex) {
			[self respring];
		}
	} else {
		// Passcode Alert
		if (buttonIndex == alertView.cancelButtonIndex) { // cancel
			[self hidePasscodeAlert];
			[self.rootController popViewControllerAnimated:YES];
			
		} else {
			DebugLog(@"Checking passcode...");
			
			UITextField *loginField = [alertView textFieldAtIndex:0];
			NSString *code = loginField.text;
			BOOL codeIsGood = NO;
			
//			NSBundle *bundle = [NSBundle bundleWithPath:@"/System/Library/"];
//			NSError *err = nil;
//			if ([bundle loadAndReturnError:&err]) {

			//				Class $SBDeviceLockController = NSClassFromString(@"SBDeviceLockController");
			//				DebugLog(@"$SBDeviceLockController = %@", $SBDeviceLockController);
			//				[[$SBDeviceLockController sharedController] attemptDeviceUnlockWithPassword:code appRequested:nil];

			
			Class $MC = NSClassFromString(@"MCPasscodeManager");
			DebugLog(@"$MC = %@", $MC);
			
			NSError *error;
			[[$MC sharedManager] unlockDeviceWithPasscode:code outError:&error];
			
			DebugLog(@"error = %@", error);
			if (!error) {
				DebugLog(@"no error from MC, yippee!");
				codeIsGood = YES;
			}
			
			if (codeIsGood) {
				DebugLog(@"passcode accepted");
				[self hidePasscodeAlert];
			} else {
				DebugLog(@"passcode rejected.");
				[self hidePasscodeAlert];
				[self.rootController popViewControllerAnimated:YES];
			}
		}
	}
}
@end



//
// Logo Cell
//
@implementation AsosCustomCell
- (instancetype)initWithSpecifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:UITableViewCellStyleDefault
				reuseIdentifier:@"ASOSCell"
					  specifier:specifier];
	if (self) {
		UIImage *logo = [[UIImage alloc] initWithContentsOfFile:kSettingsLogoPath];
		UIImageView *logoView = [[UIImageView alloc] initWithImage:logo];
		[self.contentView addSubview:logoView];
	}
	return self;
}
- (CGFloat)preferredHeightForWidth:(CGFloat)arg1 {
	return 115.0f;
}
/*
- (NSString *)randomString {
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
*/
@end

