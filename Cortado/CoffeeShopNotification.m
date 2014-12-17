@import UIKit;

#import "Beverage.h"
#import "BeverageConsumption.h"
#import "PreferredDrinks.h"

#import "CoffeeShopNotification.h"

NSString * const NotificationCategoryBeverage  = @"BEVERAGE";
NSString * const NotificationActionOne = @"DRINK_ONE";
NSString * const NotificationActionTwo = @"DRINK_TWO";
NSString * const NotificationActionNone = @"DRINK_NONE";


@interface CoffeeShopNotification ()

@property (readonly, nonatomic, strong) UILocalNotification *notif;

@end

@implementation CoffeeShopNotification

#pragma mark -
+ (void)registerNotificationTypeWithPreferences:(PreferredDrinks *)preferences {
    NSMutableArray *actions = [[NSMutableArray alloc] init];

    if (preferences.second) {
        UIMutableUserNotificationAction *action = [[UIMutableUserNotificationAction alloc] init];
        action.identifier = NotificationActionOne;
        action.title = preferences.second.name;
        action.activationMode = UIUserNotificationActivationModeBackground;
        action.destructive = NO;
        action.authenticationRequired = NO;

        [actions addObject:action];
    }

    if (preferences.first) {
        UIMutableUserNotificationAction *action = [[UIMutableUserNotificationAction alloc] init];
        action.identifier = NotificationActionTwo;
        action.title = preferences.first.name;
        action.activationMode = UIUserNotificationActivationModeBackground;
        action.destructive = NO;
        action.authenticationRequired = NO;

        [actions addObject:action];
    }

    if (actions.count == 0) {
        UIMutableUserNotificationAction *action = [[UIMutableUserNotificationAction alloc] init];
        action.identifier = NotificationActionNone;
        action.title = @"Enter Drink";
        action.activationMode = UIUserNotificationActivationModeForeground;
        action.destructive = NO;

        [actions addObject:action];

    }

    UIMutableUserNotificationCategory *notificationCategory = [[UIMutableUserNotificationCategory alloc] init];
    notificationCategory.identifier = NotificationCategoryBeverage;
    [notificationCategory setActions:actions.copy forContext:UIUserNotificationActionContextDefault];
    [notificationCategory setActions:actions.copy forContext:UIUserNotificationActionContextMinimal];

    NSSet *category = [NSSet setWithObject:notificationCategory];

    UIUserNotificationType notificationType = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:notificationType categories:category];
    [UIApplication.sharedApplication registerUserNotificationSettings:notificationSettings];

    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:preferences];
    [NSUserDefaults.standardUserDefaults setObject:data forKey:@"notificationPreferences"];
}

+ (BeverageConsumption *)drinkForIdentifier:(NSString *)identifier notification:(UILocalNotification *)notif {
    if ([identifier isEqualToString:NotificationActionNone]) return nil;

    NSData *data = [NSUserDefaults.standardUserDefaults objectForKey:@"notificationPreferences"];
    PreferredDrinks *preferences = [NSKeyedUnarchiver unarchiveObjectWithData:data];

    NSDate *timestamp = notif.userInfo[@"timestamp"];
    Beverage *beverage;
    if ([identifier isEqualToString:NotificationActionOne]) {
        beverage = preferences.second;
    } else {
        beverage = preferences.first;
    }

    return [[BeverageConsumption alloc] initWithBeverage:beverage timestamp:timestamp];
}

#pragma mark -
- (id)initWithName:(NSString *)name
       application:(UIApplication *)application {
    self = [super init];
    if (!self) return nil;

    _name = name;
    _application = application;

    _notif = [[UILocalNotification alloc] init];
    _notif.category = NotificationCategoryBeverage;
    _notif.userInfo = @{@"timestamp":NSDate.date};
    _notif.alertBody = [NSString stringWithFormat:@"It looks like you're at %@. Whatcha drinkin'?", name];

    return self;
}

- (id)initWithName:(NSString *)name {
    return [self initWithName:name application:UIApplication.sharedApplication];
}

- (void)schedule {
    [self.application scheduleLocalNotification:self.notif];
}

@end