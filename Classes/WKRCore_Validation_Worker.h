//
//  WKRCore_Validation_Worker.h
//  DoubleNode Core
//
//  Created by Darren Ehlers on 2016/10/16.
//  Copyright © 2016 Darren Ehlers and DoubleNode, LLC. All rights reserved.
//

#import <DNCProtocols/PTCLPasswordStrength_Protocol.h>
#import <DNCProtocols/PTCLValidation_Protocol.h>
#import <DNCProtocols/__WKR_Base_Worker.h>

@interface WKRCore_Validation_Worker : WKR_Base_Worker<PTCLValidation_Protocol>

@property (strong, nonatomic)   id<PTCLPasswordStrength_Protocol>   passwordStrengthWorker;

@end
