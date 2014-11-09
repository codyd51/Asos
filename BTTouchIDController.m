#import "BTTouchIDController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <objc/runtime.h>
#import "Interfaces.h"
//#import "Tweak.xm"

@implementation BTTouchIDController

+(id)sharedInstance {
	// Setup instance for current class once
	static id sharedInstance = nil;
	static dispatch_once_t token = 0;
	dispatch_once(&token, ^{
		sharedInstance = [self new];
	});
	// Provide instance
	return sharedInstance;
}

-(void)biometricEventMonitor:(id)monitor handleBiometricEvent:(unsigned)event {
	switch(event) {
		case TouchIDFingerDown:
			NSLog(@"[Asos] Touched Finger Down");
			break;
		case TouchIDFingerUp:
			NSLog(@"[Asos] Touched Finger Up");
			break;
		case TouchIDFingerHeld:
			NSLog(@"[Asos] Touched Finger Held");
			break;
		case TouchIDMatched:
			NSLog(@"[Asos] Touched Finger MATCHED :DDDDDDD");
			//If running in SpringBoard
			if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
				notify_post("com.phillipt.asos.touchunlock");
			}
			//else we're in preferences
			else {
				notify_post("com.phillipt.asos.prefstouchunlock");
			}
			[self stopMonitoring];
			break;
		case TouchIDMaybeMatched:
			NSLog(@"[Asos] Touched Finger Maybe Matched");
			//If running in SpringBoard
			if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
				notify_post("com.phillipt.asos.touchunlock");
			}
			//else we're in preferences
			else {
				notify_post("com.phillipt.asos.prefstouchunlock");
			}
			[self stopMonitoring]
			break;
		case TouchIDNotMatched:
			AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
			NSLog(@"[Asos] Touched Finger NOT MATCHED DDDDDDD:");
			break;
		case 10:
			AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
			NSLog(@"[Asos] Touched Finger NOT MATCHED DDDDDDD:");
			break;
		default:
			//log(@"Touched Finger Other Event"); // Unneeded and annoying
			break;
	}
}

-(void)startMonitoring {
	// If already monitoring, don't start again
	if(isMonitoring) {
		return;
	}
	isMonitoring = YES;

	// Get current monitor instance so observer can be added
	SBUIBiometricEventMonitor* monitor = [[objc_getClass("BiometricKit") manager] delegate];
	// Save current device matching state
	previousMatchingSetting = [monitor isMatchingEnabled];

	// Begin listening :D
	[monitor addObserver:self];
	[monitor _setMatchingEnabled:YES];
	[monitor _startMatching];

	NSLog(@"[Asos] Started monitoring");
}

-(void)stopMonitoring {
	// If already stopped, don't stop again
	if(!isMonitoring) {
		return;
	}
	isMonitoring = NO;

	// Get current monitor instance so observer can be removed
	SBUIBiometricEventMonitor* monitor = [[objc_getClass("BiometricKit") manager] delegate];
	
	// Stop listening
	[monitor removeObserver:self];
	[monitor _setMatchingEnabled:previousMatchingSetting];

	NSLog(@"[Asos] Stopped Monitoring");
}

@end