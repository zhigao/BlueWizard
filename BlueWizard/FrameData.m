#import "FrameData.h"
#import "Reflector.h"
#import "CodingTable.h"
#import "ClosestValueFinder.h"

@interface FrameData ()

@property (nonatomic, strong) Reflector *reflector;
@property (nonatomic) double pitch;
@property (nonatomic) BOOL repeat;

@end

@implementation FrameData

-(instancetype)initWithReflector:(Reflector *)reflector
                           pitch:(NSUInteger)pitch
                          repeat:(BOOL)repeat {
    if (self = [super init]) {
        self.reflector = reflector;
        self.pitch     = pitch;
        self.repeat    = repeat;
    }
    return self;
}

-(NSDictionary *)parameters {
    return [self parametersWithTranslate:NO];
}

-(NSDictionary *)translatedParameters {
    return [self parametersWithTranslate:YES];
}

-(NSDictionary *)parametersWithTranslate:(BOOL)translate {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:13];
    
    parameters[kParameterGain] = [self parameterizedValueForRMS:self.reflector.rms translate:translate];
    if ([parameters[kParameterGain] doubleValue] > 0.0f) {
        
        parameters[kParameterRepeat] = [self parameterizedValueForRepeat:self.repeat];
        parameters[kParameterPitch]  = [self parameterizedValueForPitch:self.pitch translate:translate];
        
        if (![parameters[kParameterRepeat] boolValue]) {
            NSDictionary *ks = [self kParametersFrom:1 to:4 translate:translate];
            [parameters addEntriesFromDictionary:ks];
            
            if ([self.reflector isVoiced] && [parameters[kParameterPitch] unsignedIntegerValue]) {
                ks = [self kParametersFrom:5 to:10 translate:translate];
                [parameters addEntriesFromDictionary:ks];
            }
        }
    }
    
    return [parameters copy];
}

-(void)setParameter:(NSString *)parameter value:(NSNumber *)value {
    if ([parameter isEqualToString:kParameterGain]) {
        NSUInteger index = [value unsignedIntegerValue];
        NSNumber *value = [NSNumber numberWithFloat:[CodingTable rms][index]];
        self.reflector.rms = [value floatValue];
    } else if ([parameter isEqualToString:kParameterRepeat]) {
        self.repeat = [value boolValue];
    } else if ([parameter isEqualToString:kParameterPitch]) {
        NSUInteger index = [value unsignedIntegerValue];
        NSNumber *value = [NSNumber numberWithFloat:[CodingTable pitch][index]];
        self.pitch = [value doubleValue];
    } else {
        NSUInteger bin = [[parameter substringFromIndex:1] integerValue];
        NSUInteger index = [value unsignedIntegerValue];
        NSNumber *value = [NSNumber numberWithFloat:[CodingTable kBinFor:bin][index]];
        self.reflector.ks[bin] = [value doubleValue];
    }
}

-(NSNumber *)parameterizedValueForK:(double)k bin:(NSUInteger)bin translate:(BOOL)translate {
    NSUInteger index = [ClosestValueFinder indexFor:k
                                              table:[CodingTable kBinFor:bin]
                                               size:[CodingTable kSizeFor:bin]];

    if (translate) {
        return [NSNumber numberWithFloat:[CodingTable kBinFor:bin][index]];
    } else {
        return [NSNumber numberWithUnsignedInteger:index];
    }
}

-(NSNumber *)parameterizedValueForRMS:(double)rms translate:(BOOL)translate {
    NSUInteger index = [ClosestValueFinder indexFor:rms
                                              table:[CodingTable rms]
                                               size:[CodingTable rmsSize]];
    if (translate) {
        return [NSNumber numberWithFloat:[CodingTable rms][index]];
    } else {
        return [NSNumber numberWithUnsignedInteger:index];
    }
}

-(NSNumber *)parameterizedValueForPitch:(double)pitch translate:(BOOL)translate {
    if ([self.reflector isUnvoiced]) return @0;

    NSUInteger index = [ClosestValueFinder indexFor:pitch
                                              table:[CodingTable pitch]
                                               size:[CodingTable pitchSize]];
    if (translate) {
        return [NSNumber numberWithFloat:[CodingTable pitch][index]];
    } else {
        return [NSNumber numberWithUnsignedInteger:index];
    }
}

-(NSNumber *)parameterizedValueForRepeat:(BOOL)repeat {
    return [NSNumber numberWithBool:repeat];
}

-(NSDictionary *)kParametersFrom:(NSUInteger)from
                              to:(NSUInteger)to
                       translate:(BOOL)translate {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:to - from];
    for (NSUInteger k = from; k <= to; k++) {
        NSString *key = [self parameterKeyForK:k];
        parameters[key] = [self parameterizedValueForK:self.reflector.ks[k] bin:k translate:translate];
    }
    return [parameters copy];
}

-(NSString *)parameterKeyForK:(NSUInteger)k {
    return [NSString stringWithFormat:@"k%lu", k];
}

@end
