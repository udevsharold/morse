#import "../MorseCodeManager.h"

#include <stdio.h>
#include <getopt.h>

#define NSLog(FORMAT, ...) fprintf(stdout, "%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);


void display_usage(){
    fprintf(stderr,
            "Usage: morse [parameters...]\n"
            "       -t, --text: input text\n"
            "       -p, --part: ouput part by part morse code, complete otherwise\n"
            "       -o, --original: ouput corresponding orginal character\n"
            "       -i, --ditintensity: intensity for dit, 0 to 1\n"
            "       -s, --ditsharpness: sharpness for dit, 0 to 1\n"
            "       -I, --dahintensity: intensity for dah, 0 to 1\n"
            "       -S, --dahsharpness: sharpness for dah, 0 to 1\n"
            "       -m, --intermediate: intermediate interval between dits/dahs, microseconds\n"
            "       -n, --space: intermediate interval for a space character, microseconds\n"
            "       -r, --char: intermediate interval for each character, microseconds\n"
            "       -h, --help: show this help message\n"
            );
    exit(-1);
}


int main(int argc, char *argv[], char *envp[]) {
    if (argc < 1) display_usage();
    int mandatoryArgsCount = 0;
    int expectedmandatoryArgsCount = 1;
    
    extern char *optarg;
    extern int optind;
    
    static struct option longopts[] = {
        { "text", required_argument, 0, 't' },
        { "part", no_argument, 0, 'p' },
        { "original", no_argument, 0, 'o'},
        { "ditintensity", required_argument, 0, 'i'},
        { "ditsharpness", required_argument, 0, 's'},
        { "dahintensity", required_argument, 0, 'I'},
        { "dahsharpness", required_argument, 0, 'S'},
        { "intermediate", required_argument, 0, 'm'},
        { "space", required_argument, 0, 'n'},
        { "char", required_argument, 0, 'r'},
        { "help", no_argument, 0, 'h'},
        { 0, 0, 0, 0 }
    };
    
    NSString *fullText = @"";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    BOOL showPart = NO;
    BOOL showOriginal = NO;
    
    int opt;
    while ((opt = getopt_long(argc, argv, "t:poi:s:I:S:m:n:r:h", longopts, NULL)) != -1){
        switch (opt){
            case 't':
                fullText = [NSString stringWithCString:optarg encoding:NSUTF8StringEncoding];
                mandatoryArgsCount += 1;
                break;
            case 'p':
                showPart = YES;
                break;
            case 'o':
                showOriginal = YES;
                break;
            case 'i':
                params[@"kDitIntensity"] = [NSString stringWithCString:optarg encoding:NSUTF8StringEncoding];
                break;
            case 's':
                params[@"kDitSharpness"] = [NSString stringWithCString:optarg encoding:NSUTF8StringEncoding];
                break;
            case 'I':
                params[@"kDahIntensity"] = [NSString stringWithCString:optarg encoding:NSUTF8StringEncoding];
                break;
            case 'S':
                params[@"kDahSharpness"] = [NSString stringWithCString:optarg encoding:NSUTF8StringEncoding];
                break;
            case 'm':
                params[@"kIntermediate"] = [NSString stringWithCString:optarg encoding:NSUTF8StringEncoding];
                break;
            case 'n':
                params[@"kIntermediateSpace"] = [NSString stringWithCString:optarg encoding:NSUTF8StringEncoding];
                break;
            case 'r':
                params[@"kintermediateChar"] = [NSString stringWithCString:optarg encoding:NSUTF8StringEncoding];
                break;
            default:
                display_usage();
        }
    }
    
    if (mandatoryArgsCount < expectedmandatoryArgsCount){
        NSLog(@"Not enough input arguments");
        display_usage();
    }
    
    MorseCodeManager *morseCodeManager;
    if (params){
        morseCodeManager = [[MorseCodeManager alloc] initWithParameters:params];
    }else{
        morseCodeManager = [[MorseCodeManager alloc] init];
    }
    morseCodeManager.showPart = showPart;
    morseCodeManager.showOriginal = showOriginal;
    [morseCodeManager playMorseCode:fullText];

    return 0;
}
