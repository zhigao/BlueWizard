#import "ViewController.h"
#import "UserSettings.h"
#import "NotificationNames.h"
#import "WaveformView.h"
#import "CodingTable.h"
#import "FrameData.h"

static NSString * const kFrameDataTableViewIdentifier = @"parameter";
static NSString * const kFrameDataTableViewFrameKey = @"frame";

@interface ViewController ()
@property (nonatomic, strong) NSArray *frameData;
@property (nonatomic, strong) NSNumber *timestamp;
@end

@implementation ViewController

-(void)viewDidLoad {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInputWaveformView:) name:inputSignalReceived object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProcessedWaveformView:) name:bufferGenerated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateByteStreamView:) name:byteStreamGenerated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(frameDataGenerated:) name:frameDataGenerated object:nil];

    [super viewDidLoad];
    [self updateInputsToMatchUserSettings];
}

-(void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    [self updateInputsToMatchUserSettings];
}

-(void)updateInputsToMatchUserSettings {
    self.minFrequencyTextfield.stringValue         = [[[self userSettings] minPitchInHZ] stringValue];
    self.maxFrequencyTextfield.stringValue         = [[[self userSettings] maxPitchInHZ] stringValue];
    self.submultipleThresholdTextfield.stringValue = [[[self userSettings] subMultipleThreshold] stringValue];
    self.pitchValueTextfield.stringValue           = [[[self userSettings] pitchValue] stringValue];
    self.unvoicedThresholdTextfield.stringValue    = [[[self userSettings] unvoicedThreshold] stringValue];
    self.sampleRateTextfield.stringValue           = [[[self userSettings] sampleRate] stringValue];
    self.frameRateTextfield.stringValue            = [[[self userSettings] frameRate] stringValue];
    self.preEmphasisAlphaTextfield.stringValue     = [[[self userSettings] preEmphasisAlpha] stringValue];
    self.rmsLimitTextfield.stringValue             = [[[self userSettings] rmsLimit] stringValue];
    
    self.overridePitchButton.state  = [[self userSettings] overridePitch];
    self.preEmphasisButton.state    = [[self userSettings] preEmphasis];
    self.normalizeRMSButton.state   = [[self userSettings] normalizeRMS];
    
    [self overridePitchToggled:self.overridePitchButton];
    [self preEmphasisToggled:self.preEmphasisButton];
    [self normalizeRMSToggled:self.normalizeRMSButton];
}

-(void)updateInputWaveformView:(NSNotification *)notification {
    self.inputWaveformView.buffer = notification.object;
}

-(void)updateProcessedWaveformView:(NSNotification *)notification {
    self.processedWaveformView.buffer = notification.object;
}

-(void)updateByteStreamView:(NSNotification *)notification {
    self.byteStreamTextView.string = notification.object;
}

-(void)frameDataGenerated:(NSNotification *)notification {
    self.frameData = notification.object;
}

-(void)setFrameData:(NSArray *)frameData {
    _frameData = frameData;
    if (self.spinner.hidden) [self showSpinner];
    [self.frameDataTableView reloadData];
}

# pragma mark - Actions

-(IBAction)stopOriginalWasClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:stopOriginalWasClicked object:nil];
}

-(IBAction)playOriginalWasClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:playOriginalWasClicked object:self.playheadView];
}

-(IBAction)stopProcessedWasClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:stopProcessedWasClicked object:nil];
}

-(IBAction)playProcessedWasClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:playProcessedWasClicked object:self.playheadView];
}

-(IBAction)minFrequencyChanged:(NSTextField *)sender {
    [[self userSettings] setMinPitchInHZ:[self numberFromString:[sender stringValue]]];
    [self notifySettingsChanged];
}

-(IBAction)maxFrequencyChanged:(NSTextField *)sender {
    [[self userSettings] setMaxPitchInHZ:[self numberFromString:[sender stringValue]]];
    [self notifySettingsChanged];
}

-(IBAction)submultipleThresholdChanged:(NSTextField *)sender {
    [[self userSettings] setSubMultipleThreshold:[self numberFromString:[sender stringValue]]];
    [self notifySettingsChanged];
}

-(IBAction)pitchValueChanged:(NSTextField *)sender {
    [[self userSettings] setPitchValue:[self numberFromString:[sender stringValue]]];
    [self notifySettingsChanged];
}   

-(IBAction)overridePitchToggled:(NSButton *)sender {
    BOOL state = [sender state];

    [self.minFrequencyTextfield setEnabled:!state];
    [self.maxFrequencyTextfield setEnabled:!state];
    [self.pitchValueTextfield setEnabled:state];

    [[self userSettings] setOverridePitch:state];
    [self notifySettingsChanged];
}

- (IBAction)unvoicedThresholdChanged:(NSTextField *)sender {
    [[self userSettings] setUnvoicedThreshold:[self numberFromString:[sender stringValue]]];
    [self notifySettingsChanged];
}

- (IBAction)sampleRateChanged:(NSTextField *)sender {
    [[self userSettings] setSampleRate:[self numberFromString:[sender stringValue]]];
    [self notifySettingsChanged];
}

-(IBAction)frameRateChanged:(NSTextField *)sender {
    [[self userSettings] setFrameRate:[self numberFromString:[sender stringValue]]];
    [self notifySettingsChanged];
}

- (IBAction)preEmphasisAlphaChanged:(NSTextField *)sender {
    [[self userSettings] setPreEmphasisAlpha:[self numberFromString:[sender stringValue]]];
    [self notifySettingsChanged];
}

- (IBAction)rmsLimitChanged:(NSTextField *)sender {
    [[self userSettings] setRmsLimit:[self numberFromString:[sender stringValue]]];
    [self notifySettingsChanged];
}

- (IBAction)preEmphasisToggled:(NSButton *)sender {
    BOOL state = [sender state];
    
    [self.preEmphasisAlphaTextfield setEnabled:state];
    [[self userSettings] setPreEmphasis:state];
    [self notifySettingsChanged];
}

- (IBAction)normalizeRMSToggled:(NSButton *)sender {
    BOOL state = [sender state];
    
    [self.rmsLimitTextfield setEnabled:state];
    [[self userSettings] setNormalizeRMS:state];
    [self notifySettingsChanged];
}

-(void)notifySettingsChanged {
    if (self.frameData) [self showSpinner];
    [[NSNotificationCenter defaultCenter] postNotificationName:settingsChanged object:nil];
}

-(IBAction)translateParametersToggled:(NSButton *)sender {
    self.frameData = self.frameData;
}

-(BOOL)translate {
    return [self.translateParametersCheckbox state];
}

-(UserSettings *)userSettings {
    return [UserSettings sharedInstance];
}

-(NSNumber *)numberFromString:(NSString *)string {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    return [formatter numberFromString:string];
}

-(void)showSpinner {
    self.spinner.hidden = NO;
    [self.spinner startAnimation:self];
}

-(void)hideSpinner {
    self.spinner.hidden = YES;
    [self.spinner stopAnimation:self];
}

# pragma mark - NSTextFieldDelegate

-(void)controlTextDidChange:(NSNotification *)notification {
//    NSTextField *textField = notification.object;
//    if (textField == self.minFrequencyTextfield) {
//        [self minFrequencyChanged:textField];
//    } else if (textField == self.maxFrequencyTextfield) {
//        [self maxFrequencyChanged:textField];
//    } else if (textField == self.submultipleThresholdTextfield) {
//        [self submultipleThresholdChanged:textField];
//    } else if (textField == self.pitchValueTextfield) {
//        [self pitchValueChanged:textField];
//    } else if (textField == self.unvoicedThresholdTextfield) {
//        [self unvoicedThresholdChanged:textField];
//    } else if (textField == self.sampleRateTextfield) {
//        [self sampleRateChanged:textField];
//    } else if (textField == self.frameRateTextfield) {
//        [self frameRateChanged:textField];
//    } else if (textField == self.preEmphasisAlphaTextfield) {
//        [self preEmphasisAlphaChanged:textField];
//    } else if (textField == self.rmsLimitTextfield) {
//        [self rmsLimitChanged:textField];
//    }
}

# pragma mark - NSTableViewDelegate

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTextField *result = [tableView makeViewWithIdentifier:kFrameDataTableViewIdentifier owner:self];
    if (!result) {
        result = [[NSTextField alloc] initWithFrame:NSZeroRect];
        result.font = [NSFont systemFontOfSize:8];
        result.bezeled = NO;
        result.backgroundColor = [NSColor clearColor];
        result.identifier  = kFrameDataTableViewIdentifier;
    }

    if ([tableColumn.identifier isEqualToString:kFrameDataTableViewFrameKey]) {
        result.stringValue = [NSString stringWithFormat:@"%i", (int)row + 1];
    } else {
        NSDictionary *frame;
        if (self.translate) {
            frame = [[self.frameData objectAtIndex:row] translatedParameters];
        } else {
            frame = [[self.frameData objectAtIndex:row] parameters];
        }
        NSString *value = [[frame objectForKey:tableColumn.identifier] stringValue];
        if (frame) {
            result.stringValue = value ? value : @"";
        }
    }
    
    if (row == 0) {
        [self performSelector:@selector(hideSpinner) withObject:nil afterDelay:0.5f];
    }
    
    return result;
}

# pragma mark - NSTableViewDataSource

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.frameData count];
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {

}

@end