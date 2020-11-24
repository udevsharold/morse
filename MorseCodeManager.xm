#import "MorseCodeManager.h"

#define defaultDitIntensity 1.0f
#define defaultDitSharpness 0.5f
#define defaultDahIntensity 0.81f
#define dafaultDahSharpness 0.8f
#define defaultIntermediate 500000.0f
#define defaultIntermediateSpace 1000000.0f
#define defaultIntermediateChar 600000.0f

#define NSLog(FORMAT, ...) fprintf(stdout, "%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);


@implementation MorseCodeManager

-(instancetype)init{
    if (self == [super init]) {
        
        if (!CHHapticEngine.capabilitiesForHardware.supportsHaptics) return nil;
        self.ditIntensity = defaultDitIntensity;
        self.ditSharpness = defaultDitSharpness;
        self.dahIntensity = defaultDahIntensity;
        self.dahSharpness = dafaultDahSharpness;
        self.intermediate = defaultIntermediate;
        self.intermediateSpace = defaultIntermediateSpace;
        self.intermediateChar = defaultIntermediateChar;
        self.showPart = NO;
        self. showOriginal = NO;
        
        [self igniteEngine];
        [self initializeCores];

    }
    return self;
}

-(instancetype)initWithParameters:(NSDictionary *)parameters{
    if (self == [super init]) {
        
        if (!CHHapticEngine.capabilitiesForHardware.supportsHaptics) return nil;
        
        self.ditIntensity = parameters[@"kDitIntensity"] ? [parameters[@"kDitIntensity"] floatValue] : defaultDitIntensity;
        self.ditSharpness = parameters[@"kDitSharpness"] ? [parameters[@"kDitSharpness"] floatValue] : defaultDitSharpness;
        self.dahIntensity = parameters[@"kDahIntensity"] ? [parameters[@"kDahIntensity"] floatValue] : defaultDahIntensity;
        self.dahSharpness = parameters[@"kDahSharpness"] ? [parameters[@"kDahSharpness"] floatValue] : dafaultDahSharpness;
        self.intermediate = parameters[@"kIntermediate"] ? [parameters[@"kIntermediate"] floatValue] : defaultIntermediate;
        self.intermediateSpace = parameters[@"kIntermediateSpace"] ? [parameters[@"kIntermediateSpace"] floatValue] : defaultIntermediateSpace;
        self.intermediateChar = parameters[@"kintermediateChar"] ? [parameters[@"kintermediateChar"] floatValue] : defaultIntermediateChar;
        self.showPart = NO;
        self.showOriginal = NO;
        
        [self igniteEngine];
        [self initializeCores];

    }
    return self;
}

-(void)initializeCores{
    NSError *error = nil;
    
    CHHapticEventParameter* ditIntensityParam = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticIntensity value:self.ditIntensity];
    CHHapticEventParameter* ditSharpnessParam = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticSharpness value:self.ditSharpness];
    CHHapticEvent *ditEvent = [[CHHapticEvent alloc] initWithEventType:CHHapticEventTypeHapticTransient parameters:@[ditIntensityParam, ditSharpnessParam] relativeTime:0];
    self.ditPattern = [[CHHapticPattern alloc] initWithEvents:@[ditEvent] parameters:@[] error:&error];
    
    CHHapticEventParameter* dahIntensityParam = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticIntensity value:self.dahIntensity];
    CHHapticEventParameter* dahSharpnessParam = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticSharpness value:self.dahSharpness];
    CHHapticEvent *dahEvent = [[CHHapticEvent alloc] initWithEventType:CHHapticEventTypeHapticContinuous parameters:@[dahIntensityParam, dahSharpnessParam] relativeTime:0 duration:0.12];
    self.dahPattern = [[CHHapticPattern alloc] initWithEvents:@[dahEvent] parameters:@[] error:&error];
    
    self.ditPlayer  = [self.engine createPlayerWithPattern:self.ditPattern error:&error];
    self.dahPlayer  = [self.engine createPlayerWithPattern:self.dahPattern error:&error];
    
    self.morseCodeMap = @{
        @"a":@".-",
        @"b":@"-...",
        @"c":@"-.-.",
        @"d":@"-..",
        @"e":@".",
        @"f":@"..-.",
        @"g":@"--.",
        @"h":@"....",
        @"i":@"..",
        @"j":@".---",
        @"k":@"-.-",
        @"l":@".-..",
        @"m":@"--",
        @"n":@"-.",
        @"o":@"---",
        @"p":@".--.",
        @"q":@"--.-",
        @"r":@".-.",
        @"s":@"...",
        @"t":@"-",
        @"u":@"..-",
        @"v":@"...-",
        @"w":@".--",
        @"x":@"-..-",
        @"y":@"-.--",
        @"z":@"--..",
        @"1":@".----",
        @"2":@"..---",
        @"3":@"...--",
        @"4":@"....-",
        @"5":@".....",
        @"6":@"-....",
        @"7":@"--...",
        @"8":@"---..",
        @"9":@"----.",
        @"0":@"-----",
        @".":@".-.-.-",
        @",":@"--..--",
        @"?":@"..--..",
        @"\'":@".----.",
        @"!":@"-.-.--",
        @"/":@"-..-.",
        @"(":@"-.--.",
        @")":@"-.--.-",
        @"&":@".-...",
        @":":@"---...",
        @";":@"-.-.-.",
        @"=":@"-...-",
        @"+":@".-.-.",
        @"-":@"-...-",
        @"_":@"..--.-",
        @"\"":@".-..-.",
        @"$":@"...-..-",
        @"@":@".--.-.",
        @" ":@"/",
        @" # ":@"#"
    };
}

-(void)observePlayerState{
    [self.engine notifyWhenPlayersFinished:^CHHapticEngineFinishedAction(NSError * _Nullable error) {
        if (error == NULL || error == nil) {
            if (!self.finishedMorseSequence){
                //NSLog(@"Engine running");
                return CHHapticEngineFinishedActionLeaveEngineRunning;
            }
            //NSLog(@"Engine stopped");
            [self.engine stopWithCompletionHandler:nil];
            return CHHapticEngineFinishedActionLeaveEngineRunning;
        } else{
            //NSLog(@"Engine stopped");
            return CHHapticEngineFinishedActionStopEngine;
        }
    }];
}

-(void)igniteEngine{
    if (CHHapticEngine.capabilitiesForHardware.supportsHaptics){
        self.engine = [[CHHapticEngine alloc] initAndReturnError:nil];
        self.engine.playsHapticsOnly = YES;
        self.engine.autoShutdownEnabled = YES;
        self.finishedMorseSequence = NO;
        [self.engine startAndReturnError:nil];
        [self observePlayerState];
        //[self.engine notifyWhenPlayersFinished:^CHHapticEngineFinishedAction(NSError * _Nullable error) {
        //[self.engine stopWithCompletionHandler:nil];
        //return CHHapticEngineFinishedActionStopEngine;
        //}];
    }
}

-(void)encodeToMorse:(NSString *)fullText{
    NSUInteger len = [fullText length];
    unichar buffer[len+1];
    [fullText getCharacters:buffer range:NSMakeRange(0, len)];
    NSMutableString *completeMorseCode = [[NSMutableString alloc] init];
     for(int i = 0; i < len; i++) {
         [completeMorseCode appendString:[self morseCodeForChar:buffer[i]]];
     }
    NSLog(@"%@", completeMorseCode);
}

-(BOOL)playMorseCode:(NSString *)fullText{
    fullText = [fullText lowercaseString];
    if (!self.showPart) [self encodeToMorse:fullText];
    NSUInteger len = [fullText length];
    unichar buffer[len+1];
    [fullText getCharacters:buffer range:NSMakeRange(0, len)];
    
    NSError* error = nil;
    
    if (error == nil){
        self.finishedMorseSequence = NO;
        for(int i = 0; i < len; i++) {
            if (i == (len-1)) self.finishedMorseSequence = YES;
            //NSLog(@"%C", buffer[i]);
            NSString *morseCode = [self morseCodeForChar:buffer[i]];
            if (self.showPart){
                if (self.showOriginal){
                    NSLog(@"%C: %@", buffer[i], morseCode);
                }else{
                    NSLog(@"%@", morseCode);
                }
            }
            if ([morseCode isEqualToString:@"/"]){
                usleep(self.intermediateSpace);
                continue;
            }
            if (i > 0) usleep(self.intermediateChar);
            NSUInteger lenMorse = [morseCode length];
            unichar bufferMorse[lenMorse+1];
            [morseCode getCharacters:bufferMorse range:NSMakeRange(0, lenMorse)];
            
            for (int j = 0; j < lenMorse; j++){
                //NSLog(@"%C", bufferMorse[j]);
                NSString *code = [NSString stringWithFormat: @"%C", bufferMorse[j]];
                if ([code isEqualToString:@"."]){
                    [self.ditPlayer startAtTime:0 error:&error];
                }else if ([code isEqualToString:@"-"]){
                    [self.dahPlayer startAtTime:0 error:&error];
                }
                //[self observePlayerState];
                usleep(self.intermediate);
            }
        }
    }else{
        NSLog(@"error: %@", error);
    }
    return error == nil ? YES : NO;
}



-(NSString *)morseCodeForChar:(unichar)letter{
    //NSLog(@"morseCodeMap: %@", morseCodeMap);
    //NSLog(@"letter: %C", letter);
    return self.morseCodeMap[[NSString stringWithFormat: @"%C", letter]];
}
@end


