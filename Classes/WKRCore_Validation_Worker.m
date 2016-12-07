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

#define ERROR_DOMAIN_CLASS      [NSString stringWithFormat:@"com.doublenode.%@", NSStringFromClass([self class])]
#define ERROR_UNKNOWN           1001
#define ERROR_NO_BIRTHDAY       1002
#define ERROR_BAD_EMAIL         1003
#define ERROR_TOO_SHORT         1004
#define ERROR_TOO_WEAK          1005
#define ERROR_NO_SELECTION      1006

@synthesize nextBaseWorker;
@synthesize nextValidationWorker;

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
    BOOL    valid = (3 < handle.length);
    if (!valid)
    {
        *error = [NSError errorWithDomain:ERROR_DOMAIN_CLASS
                                     code:ERROR_TOO_SHORT
                                 userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"Handle is too short", nil) }];
        return NO;
    }
    
    return YES;
}

- (BOOL)doValidateName:(NSString*)name
                 error:(NSError**)error
{
    BOOL    valid = (1 < name.length);
    if (!valid)
    {
        *error = [NSError errorWithDomain:ERROR_DOMAIN_CLASS
                                     code:ERROR_TOO_SHORT
                                 userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"Name is too short", nil) }];
        return NO;
    }
    
    return YES;
}

- (BOOL)doValidateNumber:(nonnull NSString*)number
                   error:(NSError*_Nullable*_Nullable)error
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

- (BOOL)doValidatePassword:(NSString*)password
                     error:(NSError**)error
{
    WKRPasswordStrengthType strengthType = [self.passwordStrengthWorker doCheckPasswordStrength:password];
    
    BOOL    valid = !(strengthType == WKRPasswordStrengthTypeWeak);
    if (!valid)
    {
        *error = [NSError errorWithDomain:ERROR_DOMAIN_CLASS
                                     code:ERROR_TOO_WEAK
                                 userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"Password is too weak", nil) }];
        return NO;
    }
    
    return YES;
}

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

@end
