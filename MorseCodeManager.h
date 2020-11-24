#import <CoreHaptics/CoreHaptics.h>

@interface MorseCodeManager : NSObject
@property (nonatomic, strong) CHHapticEngine* engine;
@property (nonatomic, strong) id<CHHapticPatternPlayer> ditPlayer;
@property (nonatomic, strong) id<CHHapticPatternPlayer> dahPlayer;
@property (nonatomic, strong) CHHapticPattern* ditPattern;
@property (nonatomic, strong) CHHapticPattern* dahPattern;
@property (nonatomic, assign) float ditIntensity;
@property (nonatomic, assign) float ditSharpness;
@property (nonatomic, assign) float dahIntensity;
@property (nonatomic, assign) float dahSharpness;
@property (nonatomic, assign) float intermediate;
@property (nonatomic, assign) float intermediateSpace;
@property (nonatomic, assign) float intermediateChar;
@property (nonatomic, assign) BOOL finishedMorseSequence;
@property (nonatomic, strong) NSDictionary* morseCodeMap;
@property (nonatomic, assign) BOOL showPart;
@property (nonatomic, assign) BOOL showOriginal;


-(instancetype)init;
-(instancetype)initWithParameters:(NSDictionary *)parameters;
-(void)initializeCores;
-(void)igniteEngine;
-(BOOL)playMorseCode:(NSString *)fullText;
-(NSString *)morseCodeForChar:(unichar)letter;
-(void)encodeToMorse:(NSString *)fullText;
@end
