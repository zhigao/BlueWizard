#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "FrameData.h"
#import "Reflector.h"
#import "CodingTable.h"

@interface Reflector (FrameDataTests)
-(instancetype)initWithKs:(float *)ks rms:(NSUInteger)rms;
@end

@interface FrameDataTests : XCTestCase

@end

@implementation FrameDataTests {
    FrameData *subject;
    Reflector *reflector;
}

-(void)setUp {
    [super setUp];
}

-(void)tearDown {
    [super tearDown];
}

-(void)testItHasAllParameters {
    float ks[] = { 0.1f, 0.1f };
    reflector = [[Reflector alloc] initWithKs:ks rms:32];

    subject = [[FrameData alloc] initWithReflector:reflector pitch:32 repeat:NO translate:NO];
    NSArray *paramterKeys = [[subject parameters] allKeys];
    XCTAssertTrue([paramterKeys containsObject:kParameterGain]);
    XCTAssertTrue([paramterKeys containsObject:kParameterRepeat]);
    XCTAssertTrue([paramterKeys containsObject:kParameterPitch]);
    XCTAssertTrue([paramterKeys containsObject:kParameterK1]);
    XCTAssertTrue([paramterKeys containsObject:kParameterK2]);
    XCTAssertTrue([paramterKeys containsObject:kParameterK3]);
    XCTAssertTrue([paramterKeys containsObject:kParameterK4]);
    XCTAssertTrue([paramterKeys containsObject:kParameterK5]);
    XCTAssertTrue([paramterKeys containsObject:kParameterK6]);
    XCTAssertTrue([paramterKeys containsObject:kParameterK7]);
    XCTAssertTrue([paramterKeys containsObject:kParameterK8]);
    XCTAssertTrue([paramterKeys containsObject:kParameterK9]);
    XCTAssertTrue([paramterKeys containsObject:kParameterK10]);
}

-(void)testItHasUnvoicedParameterWhenK1IsLarge {
    float ks[] = { 0.1f, 5.0f };
    reflector = [[Reflector alloc] initWithKs:ks rms:32];
    
    subject = [[FrameData alloc] initWithReflector:reflector pitch:32 repeat:NO translate:NO];
    NSArray *paramterKeys = [[subject parameters] allKeys];
    XCTAssertTrue([paramterKeys containsObject:kParameterGain]);
    XCTAssertTrue([paramterKeys containsObject:kParameterRepeat]);
    XCTAssertTrue([paramterKeys containsObject:kParameterPitch]);
    XCTAssertTrue([paramterKeys containsObject:kParameterK1]);
    XCTAssertTrue([paramterKeys containsObject:kParameterK2]);
    XCTAssertTrue([paramterKeys containsObject:kParameterK3]);
    XCTAssertTrue([paramterKeys containsObject:kParameterK4]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK5]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK6]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK7]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK8]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK9]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK10]);
}

-(void)testItHasUnvoicedParameterWhenPitchIsZero {
    float ks[] = { 0.1f, 0.1f };
    reflector = [[Reflector alloc] initWithKs:ks rms:32];
    
    subject = [[FrameData alloc] initWithReflector:reflector pitch:0 repeat:NO translate:NO];
    NSArray *paramterKeys = [[subject parameters] allKeys];
    XCTAssertTrue([paramterKeys containsObject:kParameterGain]);
    XCTAssertTrue([paramterKeys containsObject:kParameterRepeat]);
    XCTAssertTrue([paramterKeys containsObject:kParameterPitch]);
    XCTAssertTrue([paramterKeys containsObject:kParameterK1]);
    XCTAssertTrue([paramterKeys containsObject:kParameterK2]);
    XCTAssertTrue([paramterKeys containsObject:kParameterK3]);
    XCTAssertTrue([paramterKeys containsObject:kParameterK4]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK5]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK6]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK7]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK8]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK9]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK10]);
}

-(void)testItHasGainOnlyParametersWhenGainIsZero {
    float ks[] = { 0.0f, 0.0f };
    reflector = [[Reflector alloc] initWithKs:ks rms:0];
    
    subject = [[FrameData alloc] initWithReflector:reflector pitch:0 repeat:NO translate:NO];
    NSArray *paramterKeys = [[subject parameters] allKeys];
    XCTAssertTrue([paramterKeys containsObject:kParameterGain]);
    XCTAssertFalse([paramterKeys containsObject:kParameterRepeat]);
    XCTAssertFalse([paramterKeys containsObject:kParameterPitch]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK1]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK2]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK3]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK4]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK5]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK6]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK7]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK8]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK9]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK10]);
}

-(void)testItHasRepeatParameters {
    float ks[] = { 0.0f, 0.0f };
    reflector = [[Reflector alloc] initWithKs:ks rms:32];
    
    subject = [[FrameData alloc] initWithReflector:reflector pitch:32 repeat:YES translate:NO];
    NSArray *paramterKeys = [[subject parameters] allKeys];
    XCTAssertTrue([paramterKeys containsObject:kParameterGain]);
    XCTAssertTrue([paramterKeys containsObject:kParameterRepeat]);
    XCTAssertTrue([paramterKeys containsObject:kParameterPitch]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK1]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK2]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK3]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK4]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK5]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK6]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK7]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK8]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK9]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK10]);
}

@end