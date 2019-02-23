//
//  WKRValidation_Worker.m
//  DoubleNode Core
//
//  Created by Darren Ehlers on 2016/10/16.
//  Copyright © 2016 Darren Ehlers and DoubleNode, LLC. All rights reserved.
//

#import <DNCore/DNCUtilities.h>
#import <WKRCrash_Workers/WKRCrash_PasswordStrength_Worker.h>

#import "WKRCore_Validation_Worker.h"

#define WKRPWD_MINLEN   6

NSString* const kWkrRegexPasswordOneUppercase   = @"^(?=.*[A-Z]).*$";       // Should contains one or more uppercase letters
NSString* const kWkrRegexPasswordOneLowercase   = @"^(?=.*[a-z]).*$";       // Should contains one or more lowercase letters
NSString* const kWkrRegexPasswordOneNumber      = @"^(?=.*[0-9]).*$";       // Should contains one or more number
NSString* const kWkrRegexPasswordOneSymbol      = @"^(?=.*[!@#$%&_]).*$";   // Should contains one or more symbol

@implementation WKRCore_Validation_Worker

#define ERROR_DOMAIN_CLASS          [NSString stringWithFormat:@"com.doublenode.%@", NSStringFromClass([self class])]
#define ERROR_UNKNOWN               1001
#define ERROR_NO_BIRTHDAY           1002
#define ERROR_BIRTHDAY_TOO_YOUNG    1003
#define ERROR_BIRTHDAY_TOO_OLD      1004
#define ERROR_BAD_EMAIL             1005
#define ERROR_TOO_SHORT             1006
#define ERROR_TOO_LONG              1007
#define ERROR_TOO_LOW               1008
#define ERROR_TOO_HIGH              1009
#define ERROR_TOO_WEAK              1010
#define ERROR_NO_SELECTION          1011
#define ERROR_INVALID               1012

@synthesize nextBaseWorker;
@synthesize nextValidationWorker;

@synthesize minimumBirthdayAge;
@synthesize maximumBirthdayAge;

@synthesize minimumHandleLength;
@synthesize maximumHandleLength;

@synthesize minimumNameLength;
@synthesize maximumNameLength;

@synthesize minimumNumberValue;
@synthesize maximumNumberValue;

@synthesize requiredPasswordStrength;

@synthesize minimumPercentageValue;
@synthesize maximumPercentageValue;

@synthesize minimumPhoneLength;
@synthesize maximumPhoneLength;

@synthesize minimumUnsignedNumberValue;
@synthesize maximumUnsignedNumberValue;

+ (instancetype _Nonnull)worker   {   return [self worker:nil]; }

+ (instancetype _Nonnull)worker:(nullable id<PTCLValidation_Protocol>)nextValidationWorker
{
    return [[self.class alloc] initWithWorker:nextValidationWorker];
}

- (nonnull instancetype)init
{
    self = [super init];
    if (self)
    {
        self.nextValidationWorker = nil;
    }
    
    return self;
}

- (nonnull instancetype)initWithWorker:(nullable id<PTCLValidation_Protocol>)nextValidationWorker_
{
    self = [super initWithWorker:nextValidationWorker_];
    if (self)
    {
        self.nextValidationWorker = nextValidationWorker_;
    }
    
    return self;
}

#pragma mark - Configuration

- (void)configure
{
    [super configure];
    
    // Worker Dependency Injection
    self.passwordStrengthWorker = WKRCrash_PasswordStrength_Worker.worker;
}

#pragma mark - Common Methods

- (void)enableOption:(nonnull NSString*)option
{
}

- (void)disableOption:(nonnull NSString*)option
{
}

#pragma mark - Business Logic

- (BOOL)doValidateBirthday:(NSDate*)birthday
                     error:(NSError**)error
{
    BOOL    valid = (birthday != nil);
    if (!valid)
    {
        *error = [NSError errorWithDomain:ERROR_DOMAIN_CLASS
                                     code:ERROR_NO_BIRTHDAY
                                 userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"No birthday selected", nil) }];
        return NO;
    }
    
    NSInteger   age = [self utilityAge:birthday];
    
    if (self.minimumBirthdayAge > -1)
    {
        if (age < self.minimumBirthdayAge)
        {
            *error = [NSError errorWithDomain:ERROR_DOMAIN_CLASS
                                         code:ERROR_BIRTHDAY_TOO_YOUNG
                                     userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"Age is too young", nil) }];
            return NO;
        }
    }
    if (maximumBirthdayAge > -1)
    {
        if (age > self.maximumBirthdayAge)
        {
            *error = [NSError errorWithDomain:ERROR_DOMAIN_CLASS
                                         code:ERROR_BIRTHDAY_TOO_OLD
                                     userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"Age is too old", nil) }];
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)doValidateEmail:(NSString*)email
                  error:(NSError**)error
{
    //Create a regex string
    NSString*   stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    //Create predicate with format matching your regex string
    NSPredicate*    emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stricterFilterString];
    
    //return true if email address is valid
    BOOL    valid = [emailTest evaluateWithObject:email];
    if (!valid)
    {
        *error = [NSError errorWithDomain:ERROR_DOMAIN_CLASS
                                     code:ERROR_BAD_EMAIL
                                 userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"Invalid email address", nil) }];
        return NO;
    }
    
    return YES;
}

- (BOOL)doValidateHandle:(NSString*)handle
                   error:(NSError**)error
{
    if (self.minimumHandleLength != -1)
    {
        if (handle.length < self.minimumHandleLength)
        {
            *error = [NSError errorWithDomain:ERROR_DOMAIN_CLASS
                                         code:ERROR_TOO_SHORT
                                     userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"Handle is too short", nil) }];
            return NO;
        }
    }
    if (self.maximumHandleLength != -1)
    {
        if (handle.length < self.maximumHandleLength)
        {
            *error = [NSError errorWithDomain:ERROR_DOMAIN_CLASS
                                         code:ERROR_TOO_LONG
                                     userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"Handle is too long", nil) }];
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)doValidateName:(NSString*)name
                 error:(NSError**)error
{
    if (self.minimumNameLength != -1)
    {
        if (name.length < self.minimumNameLength)
        {
            *error = [NSError errorWithDomain:ERROR_DOMAIN_CLASS
                                         code:ERROR_TOO_SHORT
                                     userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"Name is too short", nil) }];
            return NO;
        }
    }
    if (self.maximumNameLength != -1)
    {
        if (name.length < self.maximumNameLength)
        {
            *error = [NSError errorWithDomain:ERROR_DOMAIN_CLASS
                                         code:ERROR_TOO_LONG
                                     userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"Name is too long", nil) }];
            return NO;
        }
    }

    return YES;
}

//@synthesize minimumNumberValue;
//@synthesize maximumNumberValue;

- (BOOL)doValidateNumber:(nonnull NSString*)numberString
                   error:(NSError*_Nullable*_Nullable)error
{
    BOOL    valid = (1 < numberString.length);
    if (!valid)
    {
        *error = [NSError errorWithDomain:ERROR_DOMAIN_CLASS
                                     code:ERROR_TOO_SHORT
                                 userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"Number is too short", nil) }];
        return NO;
    }
    
    NSNumberFormatter*  formatter = [NSNumberFormatter.alloc init];
    formatter.numberStyle   = NSNumberFormatterDecimalStyle;
    NSNumber*   number = [formatter numberFromString:numberString];
    if (!number)
    {
        *error = [NSError errorWithDomain:ERROR_DOMAIN_CLASS
                                     code:ERROR_INVALID
                                 userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"Number is invalid", nil) }];
        return NO;
    }
    
    if (self.minimumNumberValue != INT_MAX)
    {
        if (number.integerValue < self.minimumNumberValue)
        {
            *error = [NSError errorWithDomain:ERROR_DOMAIN_CLASS
                                         code:ERROR_TOO_LOW
                                     userInfo:@{ NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Number is less than %u", nil), self.minimumNumberValue] }];
            return NO;
        }
    }
    
    if (self.maximumNumberValue != INT_MAX)
    {
        if (number.integerValue > self.maximumNumberValue)
        {
            *error = [NSError errorWithDomain:ERROR_DOMAIN_CLASS
                                         code:ERROR_TOO_HIGH
                                     userInfo:@{ NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Number is greater than %u", nil), self.maximumNumberValue] }];
            return NO;
        }
    }
    
    return YES;
}

//@synthesize requiredPasswordStrength;

- (BOOL)doValidatePassword:(NSString*)password
                     error:(NSError**)error
{
    WKRPasswordStrengthType strengthType = [self.passwordStrengthWorker doCheckPasswordStrength:password];
    
    BOOL    valid = !(strengthType < self.requiredPasswordStrength);
    if (!valid)
    {
        *error = [NSError errorWithDomain:ERROR_DOMAIN_CLASS
                                     code:ERROR_TOO_WEAK
                                 userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"Password is too weak", nil) }];
        return NO;
    }
    
    return YES;
}

//@synthesize minimumPercentageValue;
//@synthesize maximumPercentageValue;

- (BOOL)doValidatePercentage:(nonnull NSString*)percentage
                       error:(NSError*_Nullable*_Nullable)error
{
    BOOL    valid = (1 < percentage.length);
    if (!valid)
    {
        *error = [NSError errorWithDomain:ERROR_DOMAIN_CLASS
                                     code:ERROR_TOO_SHORT
                                 userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"Percentage is too short", nil) }];
        return NO;
    }
    
    return YES;
}

//@synthesize minimumPhoneLength;
//@synthesize maximumPhoneLength;

- (BOOL)doValidatePhone:(nonnull NSString*)phone
                  error:(NSError*_Nullable*_Nullable)error
{
    if (self.minimumPhoneLength != -1)
    {
        if (phone.length < self.minimumPhoneLength)
        {
            *error = [NSError errorWithDomain:ERROR_DOMAIN_CLASS
                                         code:ERROR_TOO_SHORT
                                     userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"Phone Number is too short", nil) }];
            return NO;
        }
    }
    if (self.maximumPhoneLength != -1)
    {
        if (phone.length < self.maximumPhoneLength)
        {
            *error = [NSError errorWithDomain:ERROR_DOMAIN_CLASS
                                         code:ERROR_TOO_LONG
                                     userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"Phone Number is too long", nil) }];
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)doValidateSearch:(NSString*)search
                   error:(NSError**)error
{
    BOOL    valid = (2 < search.length);
    if (!valid)
    {
        *error = [NSError errorWithDomain:ERROR_DOMAIN_CLASS
                                     code:ERROR_TOO_SHORT
                                 userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"Search is too short", nil) }];
        return NO;
    }
    
    return YES;
}

- (BOOL)doValidateState:(NSString*)state
                  error:(NSError**)error
{
    BOOL    valid = (1 < state.length);
    if (!valid)
    {
        *error = [NSError errorWithDomain:ERROR_DOMAIN_CLASS
                                     code:ERROR_TOO_SHORT
                                 userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"State is too short", nil) }];
        return NO;
    }
    
    return YES;
}

//@synthesize minimumUnsignedNumberValue;
//@synthesize maximumUnsignedNumberValue;

- (BOOL)doValidateUnsignedNumber:(NSString*)number
                           error:(NSError**)error
{
    BOOL    valid = (1 < number.length);
    if (!valid)
    {
        *error = [NSError errorWithDomain:ERROR_DOMAIN_CLASS
                                     code:ERROR_TOO_SHORT
                                 userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"Number is too short", nil) }];
        return NO;
    }
    
    return YES;
}

#pragma mark - Utility methods

- (NSInteger)utilityAge:(NSDate*)birthday
{
    NSCalendar* calendar    = NSCalendar.currentCalendar;
    unsigned    unitFlags   = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents*   dateComponentsNow   = [calendar components:unitFlags
                                                          fromDate:NSDate.date];
    NSDateComponents*   dateComponentsBirth = [calendar components:unitFlags
                                                          fromDate:birthday];
    
    if ((dateComponentsNow.month < dateComponentsBirth.month) ||
        ((dateComponentsNow.month == dateComponentsBirth.month) && (dateComponentsNow.day < dateComponentsBirth.day)))
    {
        return (dateComponentsNow.year - dateComponentsBirth.year - 1);
    }

    return dateComponentsNow.year - dateComponentsBirth.year;
}

@end
