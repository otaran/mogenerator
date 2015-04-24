// mogenerator.m
//   Copyright (c) 2006-2014 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//   Some rights reserved: http://opensource.org/licenses/mit
//   http://github.com/rentzsch/mogenerator

#import "mogenerator.h"
#import <RegexKitLite/RegexKitLite.h>

#import <MiscMerge/MiscMergeTemplate.h>
#import <MiscMerge/MiscMergeEngine.h>
#import "FoundationAdditions.h"

#import "NSManagedObjectModel+MogeneratorExtensions.h"
#import "GlobalVariables.h"
#import "MogeneratorTemplateDesc.h"

static NSString * const kTemplateVar = @"TemplateVar";

static MiscMergeEngine* engineWithTemplateDesc(MogeneratorTemplateDesc *templateDesc_) {
    MiscMergeTemplate *template = [[[MiscMergeTemplate alloc] init] autorelease];
    [template setStartDelimiter:@"<$" endDelimiter:@"$>"];
    if ([templateDesc_ templatePath]) {
        [template parseContentsOfFile:[templateDesc_ templatePath]];
    } else {
        NSData *templateData = [[NSBundle mainBundle] objectForInfoDictionaryKey:[templateDesc_ templateName]];
        assert(templateData);
        NSString *templateString = [[[NSString alloc] initWithData:templateData encoding:NSASCIIStringEncoding] autorelease];
        [template setFilename:[@"x-__info_plist://" stringByAppendingString:[templateDesc_ templateName]]];
        [template parseString:templateString];
    }
    
    return [[[MiscMergeEngine alloc] initWithTemplate:template] autorelease];
}

@implementation MOGeneratorApp

@synthesize origModelBasePath;
@synthesize tempGeneratedMomFilePath;
@synthesize model;
@synthesize configuration;
@synthesize baseClass;
@synthesize baseClassImport;
@synthesize baseClassForce;
@synthesize includem;
@synthesize includeh;
@synthesize templatePath;
@synthesize outputDir;
@synthesize machineDir;
@synthesize humanDir;
@synthesize templateGroup;
@synthesize templateVar;

- (id)init {
    self = [super init];
    if (self) {
        templateVar = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc {
    [templateVar release];
    [super dealloc];
}

NSString *ApplicationSupportSubdirectoryName = @"mogenerator";
- (MogeneratorTemplateDesc*)templateDescNamed:(NSString*)fileName_ {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory;
    
    if (templatePath) {
        if ([fileManager fileExistsAtPath:templatePath isDirectory:&isDirectory] && isDirectory) {
            return [[[MogeneratorTemplateDesc alloc] initWithName:fileName_
                                                             path:[templatePath stringByAppendingPathComponent:fileName_]] autorelease];
        }
    } else if (templateGroup) {
        NSArray *appSupportDirectories = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask+NSLocalDomainMask, YES);
        assert(appSupportDirectories);
        
        for (NSString *appSupportDirectory in appSupportDirectories) {
            if ([fileManager fileExistsAtPath:appSupportDirectory isDirectory:&isDirectory]) {
                NSString *appSupportSubdirectory = [appSupportDirectory stringByAppendingPathComponent:ApplicationSupportSubdirectoryName];
                appSupportSubdirectory = [appSupportSubdirectory stringByAppendingPathComponent:templateGroup];
                if ([fileManager fileExistsAtPath:appSupportSubdirectory isDirectory:&isDirectory] && isDirectory) {
                    NSString *appSupportFile = [appSupportSubdirectory stringByAppendingPathComponent:fileName_];
                    if ([fileManager fileExistsAtPath:appSupportFile isDirectory:&isDirectory] && !isDirectory) {
                        return [[[MogeneratorTemplateDesc alloc] initWithName:fileName_ path:appSupportFile] autorelease];
                    }
                }
            }
        }
    } else {
        return [[[MogeneratorTemplateDesc alloc] initWithName:fileName_ path:nil] autorelease];
    }
    
    ddprintf(@"templateDescNamed:@\"%@\": file not found", fileName_);
    exit(EXIT_FAILURE);
    return nil;
}

- (void)application:(DDCliApplication*)app
   willParseOptions:(DDGetoptLongParser*)optionsParser;
{
    [optionsParser setGetoptLongOnly:YES];
    DDGetoptOption optionTable[] = 
    {
        // Long                 Short  Argument options
        {@"v2",                 '2',   DDGetoptNoArgument},
        
        {@"model",              'm',   DDGetoptRequiredArgument},
        {@"configuration",      'C',   DDGetoptRequiredArgument},
        {@"base-class",         0,     DDGetoptRequiredArgument},
        {@"base-class-import",  0,     DDGetoptRequiredArgument},
        {@"base-class-force",   0,     DDGetoptRequiredArgument},
        // For compatibility:
        {@"baseClass",          0,     DDGetoptRequiredArgument},
        {@"includem",           0,     DDGetoptRequiredArgument},
        {@"includeh",           0,     DDGetoptRequiredArgument},
        {@"template-path",      0,     DDGetoptRequiredArgument},
        // For compatibility:
        {@"templatePath",       0,     DDGetoptRequiredArgument},
        {@"output-dir",         'O',   DDGetoptRequiredArgument},
        {@"machine-dir",        'M',   DDGetoptRequiredArgument},
        {@"human-dir",          'H',   DDGetoptRequiredArgument},
        {@"template-group",     0,     DDGetoptRequiredArgument},
        {@"list-source-files",  0,     DDGetoptNoArgument},
        {@"orphaned",           0,     DDGetoptNoArgument},
        
        {@"help",               'h',   DDGetoptNoArgument},
        {@"version",            0,     DDGetoptNoArgument},
        {@"template-var",       0,     DDGetoptKeyValueArgument},
        {@"swift",              'S',   DDGetoptNoArgument},
        {nil,                   0,     0},
    };
    [optionsParser addOptionsFromTable:optionTable];
    [optionsParser setArgumentsFilename:@".mogenerator-args"];
}

- (void)printUsage {
    printf("\n"
           "Mogenerator Help\n"
           "================\n"
           "\n"
           "Mogenerator generates code from your Core Data model files.\n"
           "\n"
           "Typical Use\n"
           "-----------\n"
           "\n"
           "$ mogenerator --v2 --model MyModel.xcdatamodeld --output-dir MyModel\n"
           "\n"
           "The --v2 argument tells mogenerator to use modern Objective-C (ARC,\n"
           "Objective-C literals, modules). Otherwise mogenerator will generate old-style\n"
           "Objective-C.\n"
           "\n"
           "Use the --model argument to supply the required data model file.\n"
           "\n"
           "If --output-dir is optional but recommended. If not supplied, mogenerator will\n"
           "output generated files into the current directory.\n"
           "\n"
           "All Options\n"
           "-----------\n"
           "\n"
           "--model MODEL             Path to model\n"
           "--output-dir DIR          Output directory\n"
           "--swift                   Generate Swift templates instead of Objective-C\n"
           "--configuration CONFIG    Only consider entities included in the named\n"
           "                          configuration\n"
           "--base-class CLASS        Custom base class\n"
           "--base-class-import TEXT  Imports base class as #import TEXT\n"
           "--base-class-force CLASS  Same as --base-class except will force all entities to\n"
           "                          have the specified base class. Even if a super entity\n"
           "                          exists\n"
           "--includem FILE           Generate aggregate include file for .m files for both\n"
           "                          human and machine generated source files\n"
           "--includeh FILE           Generate aggregate include file for .h files for human\n"
           "                          generated source files only\n"
           "--template-path PATH      Path to templates (absolute or relative to model path)\n"
           "--template-group NAME     Name of template group\n"
           "--template-var KEY=VALUE  A key-value pair to pass to the template file. There\n"
           "                          can be many of these.\n"
           "--machine-dir DIR         Output directory for machine files\n"
           "--human-dir DIR           Output directory for human files\n"
           "--list-source-files       Only list model-related source files\n"
           "--orphaned                Only list files whose entities no longer exist\n"
           "--version                 Display version and exit\n"
           "--help                    Display this help and exit\n"
           );
}

- (NSString*)developerDirectoryPath {
    NSString *result = @"";
    
    @try {
        NSTask *task = [[[NSTask alloc] init] autorelease];
        task.launchPath = @"/usr/bin/xcode-select";
    
        task.arguments = @[@"-print-path"];
        
        NSPipe *pipe = [NSPipe pipe];
        task.standardOutput = pipe;
        //  Ensures that the current tasks output doesn't get hijacked
        task.standardInput = [NSPipe pipe];
        
        NSFileHandle *file = pipe.fileHandleForReading;
        
        [task launch];
        
        NSData *data = [file readDataToEndOfFile];
        result = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        result = [result substringToIndex:[result length]-1]; // trim newline
    } @catch(NSException *ex) {
        ddprintf(@"WARNING couldn't launch /usr/bin/xcode-select\n");
    }
    
    return result;
}

- (void)setModel:(NSString*)momOrXCDataModelFilePath {
    assert(!model); // Currently we only can load one model.
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if (![fm fileExistsAtPath:momOrXCDataModelFilePath]) {
        NSString *reason = [NSString stringWithFormat:@"error loading file at %@: no such file exists", momOrXCDataModelFilePath];
        @throw [DDCliParseException parseExceptionWithReason:reason exitCode:EX_NOINPUT];
    }
    
    origModelBasePath = [momOrXCDataModelFilePath stringByDeletingLastPathComponent];
    
    if ([momOrXCDataModelFilePath.pathExtension isEqualToString:@"xcdatamodeld"]) {
        model = [self compileXCDataModelDirectoryAtPath:momOrXCDataModelFilePath];
    } else if ([momOrXCDataModelFilePath.pathExtension isEqualToString:@"xcdatamodel"]) {
        model = [self compileXCDataModelFileAtPath:momOrXCDataModelFilePath];
    } else {
        model = [[[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:momOrXCDataModelFilePath]] autorelease];
    }
    
    assert(model);
}

- (NSManagedObjectModel *)compileXCDataModelDirectoryAtPath:(NSString *)path
{
    // If given a data model bundle (.xcdatamodeld) file, assume its "current" data model file.
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // xcdatamodeld bundles have a ".xccurrentversion" plist file in them with a
    // "_XCCurrentVersionName" key representing the current model's file name.
    NSString *xccurrentversionPath = [path stringByAppendingPathComponent:@".xccurrentversion"];
    
    NSDictionary *xccurrentversionPlist = [NSDictionary dictionaryWithContentsOfFile:xccurrentversionPath];
    if (xccurrentversionPlist) {
        NSString *currentModelName = [xccurrentversionPlist objectForKey:@"_XCCurrentVersionName"];
        if (currentModelName) {
            path = [path stringByAppendingPathComponent:currentModelName];
        }
    }
    else {
        // Freshly created models with only one version do NOT have a .xccurrentversion file, but only have one model
        // in them. Use that model.
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self endswith %@", @".xcdatamodel"];
        NSArray *xcdatamodels = [[fm contentsOfDirectoryAtPath:path error:NULL] filteredArrayUsingPredicate:predicate];
        if (xcdatamodels.count == 1) {
            path = [path stringByAppendingPathComponent:[xcdatamodels lastObject]];
        }
    }
    
    return [self compileXCDataModelFileAtPath:path];
}

- (NSManagedObjectModel *)compileXCDataModelFileAtPath:(NSString *)path
{
    NSString *momcTool = [self momcPath];
    assert(momcTool && "momc not found");
    
    NSMutableString *momcOptionsString = [NSMutableString string];
    NSArray *supportedMomcOptions = @[
        @"MOMC_NO_WARNINGS",
        @"MOMC_NO_INVERSE_RELATIONSHIP_WARNINGS",
        @"MOMC_SUPPRESS_INVERSE_TRANSIENT_ERROR",
    ];
    for (NSString *momcOption in supportedMomcOptions) {
        if ([[[NSProcessInfo processInfo] environment] objectForKey:momcOption]) {
            [momcOptionsString appendFormat:@" -%@ ", momcOption];
        }
    }
    
    NSString *tempGeneratedMomFileName = [[[NSProcessInfo processInfo] globallyUniqueString] stringByAppendingPathExtension:@"mom"];
    NSString *momFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:tempGeneratedMomFileName];
    NSString *momcInvocationString = [NSString stringWithFormat:@"%@ %@ \"%@\" \"%@\"",
                                                                momcTool,
                                                                momcOptionsString,
                                                                path,
                                                                momFilePath];
    
    system([momcInvocationString UTF8String]); // Ignore system() result since momc sadly doesn't return any relevent error codes.
    
    NSManagedObjectModel *managedObjectModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:momFilePath]] autorelease];

    [[NSFileManager defaultManager] removeItemAtPath:momFilePath error:NULL];
    
    return managedObjectModel;
}

- (NSString *)momcPath
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *momcTool = nil;
    if (NO && [fm fileExistsAtPath:@"/usr/bin/xcrun"]) {
        // Cool, we can just use Xcode 3.2.6/4.x's xcrun command to find and execute momc for us.
        momcTool = @"/usr/bin/xcrun momc";
    } else {
        // Rats, don't have xcrun. Hunt around for momc in various places where various versions of Xcode stashed it.
        NSString *xcodeSelectMomcPath = [NSString stringWithFormat:@"%@/usr/bin/momc", [self developerDirectoryPath]];
        
        if ([fm fileExistsAtPath:xcodeSelectMomcPath]) {
            momcTool = [NSString stringWithFormat:@"\"%@\"", xcodeSelectMomcPath]; // Quote for safety.
        } else if ([fm fileExistsAtPath:@"/Applications/Xcode.app/Contents/Developer/usr/bin/momc"]) {
            // Xcode 4.3 - Command Line Tools for Xcode
            momcTool = @"/Applications/Xcode.app/Contents/Developer/usr/bin/momc";
        } else if ([fm fileExistsAtPath:@"/Developer/usr/bin/momc"]) {
            // Xcode 3.1.
            momcTool = @"/Developer/usr/bin/momc";
        } else if ([fm fileExistsAtPath:@"/Library/Application Support/Apple/Developer Tools/Plug-ins/XDCoreDataModel.xdplugin/Contents/Resources/momc"]) {
            // Xcode 3.0.
            momcTool = @"\"/Library/Application Support/Apple/Developer Tools/Plug-ins/XDCoreDataModel.xdplugin/Contents/Resources/momc\"";
        } else if ([fm fileExistsAtPath:@"/Developer/Library/Xcode/Plug-ins/XDCoreDataModel.xdplugin/Contents/Resources/momc"]) {
            // Xcode 2.4.
            momcTool = @"/Developer/Library/Xcode/Plug-ins/XDCoreDataModel.xdplugin/Contents/Resources/momc";
        }
    }
    return momcTool;
}

- (void)validateOutputPath:(NSString*)path forType:(NSString*)type
{
    //  Ignore nil ones
    if (path == nil) {
        return;
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    
    if (![fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
        ddprintf(@"Couldn't create %@ Directory (%@): %@", type, path, error.localizedDescription);
        exit(EX_IOERR);
    }
}

- (int)application:(DDCliApplication*)app runWithArguments:(NSArray*)arguments {
    if (_help) {
        [self printUsage];
        return EXIT_SUCCESS;
    }
    
    if (_version) {
        printf("mogenerator 1.28. By Jonathan 'Wolf' Rentzsch + friends.\n");
        return EXIT_SUCCESS;
    }
    
    if (_v2) {
        [templateVar setObject:@YES forKey:@"arc"];
        [templateVar setObject:@YES forKey:@"literals"];
        [templateVar setObject:@YES forKey:@"modules"];
    }

    gSwift = _swift;

    if (baseClassForce) {
        gCustomBaseClassForced = [baseClassForce retain];
        gCustomBaseClass = gCustomBaseClassForced;
        gCustomBaseClassImport = [baseClassImport retain];
    } else {
        gCustomBaseClass = [baseClass retain];
        gCustomBaseClassImport = [baseClassImport retain];
    }

    NSString * mfilePath = includem;
    NSString * hfilePath = includeh;
    
    NSMutableString * mfileContent = [NSMutableString stringWithString:@""];
    NSMutableString * hfileContent = [NSMutableString stringWithString:@""];
    
    [self validateOutputPath:outputDir forType:@"Output"];
    [self validateOutputPath:machineDir forType:@"Machine Output"];
    [self validateOutputPath:humanDir forType:@"Human Output"];

    if (outputDir == nil)
        outputDir = @"";
    if (machineDir == nil)
        machineDir = outputDir;
    if (humanDir == nil)
        humanDir = outputDir;

    NSFileManager *fm = [NSFileManager defaultManager];
    
    if (_orphaned) {
        NSMutableDictionary *entityFilesByName = [NSMutableDictionary dictionary];
        
        NSArray *srcDirs = [NSArray arrayWithObjects:machineDir, humanDir, nil];
        for (NSString *srcDir in srcDirs) {
            if (![srcDir length]) {
                srcDir = [fm currentDirectoryPath];
            }
            for (NSString *srcFileName in [fm subpathsAtPath:srcDir]) {
                #define MANAGED_OBJECT_SOURCE_FILE_REGEX    @"_?([a-zA-Z0-9_]+MO).(h|m|mm)" // Sadly /^(*MO).(h|m|mm)$/ doesn't work.
                if ([srcFileName isMatchedByRegex:MANAGED_OBJECT_SOURCE_FILE_REGEX]) {
                    NSString *entityName = [[srcFileName captureComponentsMatchedByRegex:MANAGED_OBJECT_SOURCE_FILE_REGEX] objectAtIndex:1];
                    if (![entityFilesByName objectForKey:entityName]) {
                        [entityFilesByName setObject:[NSMutableSet set] forKey:entityName];
                    }
                    [[entityFilesByName objectForKey:entityName] addObject:srcFileName];
                }
            }
        }
        for (NSEntityDescription *entity in [model entitiesWithACustomSubclassInConfiguration:configuration verbose:NO]) {
            [entityFilesByName removeObjectForKey:[entity managedObjectClassName]];
        }
        for (NSSet *orphanedFiles in entityFilesByName) {
            for (NSString *orphanedFile in orphanedFiles) {
                ddprintf(@"%@\n", orphanedFile);
            }
        }
        
        return EXIT_SUCCESS;
    }
    
    if (templatePath) {
        
        NSString* absoluteTemplatePath = nil;
        
        if (![templatePath isAbsolutePath]) {
            absoluteTemplatePath = [[origModelBasePath stringByAppendingPathComponent:templatePath] stringByStandardizingPath];
            
            // Be kind and try a relative Path of the parent xcdatamodeld folder of the model, if it exists
            if ((![fm fileExistsAtPath:absoluteTemplatePath]) && ([[origModelBasePath pathExtension] isEqualToString:@"xcdatamodeld"])) {
                absoluteTemplatePath = [[[origModelBasePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:templatePath] stringByStandardizingPath];
            }
        } else {
            absoluteTemplatePath = templatePath;
        }

        
        // if the computed absoluteTemplatePath exists, use it.
        if ([fm fileExistsAtPath:absoluteTemplatePath]) {
            templatePath = absoluteTemplatePath;
        }
    }
    
    int machineFilesGenerated = 0;        
    int humanFilesGenerated = 0;
    
    if (model) {
        MiscMergeEngine *machineH = nil;
        MiscMergeEngine *machineM = nil;
        MiscMergeEngine *humanH = nil;
        MiscMergeEngine *humanM = nil;

        if (_swift) {
            machineH = engineWithTemplateDesc([self templateDescNamed:@"machine.swift.motemplate"]);
            assert(machineH);
            humanH = engineWithTemplateDesc([self templateDescNamed:@"human.swift.motemplate"]);
            assert(humanH);
        } else {
            machineH = engineWithTemplateDesc([self templateDescNamed:@"machine.h.motemplate"]);
            assert(machineH);
            machineM = engineWithTemplateDesc([self templateDescNamed:@"machine.m.motemplate"]);
            assert(machineM);
            humanH = engineWithTemplateDesc([self templateDescNamed:@"human.h.motemplate"]);
            assert(humanH);
            humanM = engineWithTemplateDesc([self templateDescNamed:@"human.m.motemplate"]);
            assert(humanM);
        }

        // Add the template var dictionary to each of the merge engines
        [machineH setEngineValue:templateVar forKey:kTemplateVar];
        [machineM setEngineValue:templateVar forKey:kTemplateVar];
        [humanH setEngineValue:templateVar forKey:kTemplateVar];
        [humanM setEngineValue:templateVar forKey:kTemplateVar];
        
        NSMutableArray  *humanMFiles = [NSMutableArray array],
                        *humanHFiles = [NSMutableArray array],
                        *machineMFiles = [NSMutableArray array],
                        *machineHFiles = [NSMutableArray array];
        
        for (NSEntityDescription *entity in [model entitiesWithACustomSubclassInConfiguration:configuration verbose:YES]) {
            NSString *generatedMachineH = [machineH executeWithObject:entity sender:nil];
            NSString *generatedMachineM = [machineM executeWithObject:entity sender:nil];
            NSString *generatedHumanH = [humanH executeWithObject:entity sender:nil];
            NSString *generatedHumanM = [humanM executeWithObject:entity sender:nil];
            
            // remove unnecessary empty lines
            generatedMachineH = [generatedMachineH stringByReplacingOccurrencesOfRegex:@"([ \t]*(\n|\r|\r\n)){2,}" withString:@"\n\n"];
            generatedMachineM = [generatedMachineM stringByReplacingOccurrencesOfRegex:@"([ \t]*(\n|\r|\r\n)){2,}" withString:@"\n\n"];
            generatedHumanH = [generatedHumanH stringByReplacingOccurrencesOfRegex:@"([ \t]*(\n|\r|\r\n)){2,}" withString:@"\n\n"];
            generatedHumanM = [generatedHumanM stringByReplacingOccurrencesOfRegex:@"([ \t]*(\n|\r|\r\n)){2,}" withString:@"\n\n"];
            
            NSString *entityClassName = [entity managedObjectClassName];
            BOOL machineDirtied = NO;
            
            // Machine header files.
            NSString *extension = (_swift ? @"swift" : @"h");
            NSString *machineHFileName = [machineDir stringByAppendingPathComponent:
                                    [NSString stringWithFormat:@"_%@.%@", entityClassName, extension]];
            if (_listSourceFiles) {
                [machineHFiles addObject:machineHFileName];
            } else {
                if (![fm regularFileExistsAtPath:machineHFileName] || ![generatedMachineH isEqualToString:[NSString stringWithContentsOfFile:machineHFileName encoding:NSUTF8StringEncoding error:nil]]) {
                    //  If the file doesn't exist or is different than what we just generated, write it out.
                    [generatedMachineH writeToFile:machineHFileName atomically:NO encoding:NSUTF8StringEncoding error:nil];
                    machineDirtied = YES;
                    machineFilesGenerated++;
                }
            }
            
            // Machine source files.
            NSString *machineMFileName = nil;
            if (!_swift) {
                machineMFileName = [machineDir stringByAppendingPathComponent:
                    [NSString stringWithFormat:@"_%@.m", entityClassName]];
                if (_listSourceFiles) {
                    [machineMFiles addObject:machineMFileName];
                } else {
                    if (![fm regularFileExistsAtPath:machineMFileName] || ![generatedMachineM isEqualToString:[NSString stringWithContentsOfFile:machineMFileName encoding:NSUTF8StringEncoding error:nil]]) {
                        //  If the file doesn't exist or is different than what we just generated, write it out.
                        [generatedMachineM writeToFile:machineMFileName atomically:NO encoding:NSUTF8StringEncoding error:nil];
                        machineDirtied = YES;
                        machineFilesGenerated++;
                    }
                }
            }
            
            // Human header files.
            NSString *humanHFileName = [humanDir stringByAppendingPathComponent:
                [NSString stringWithFormat:@"%@.%@", entityClassName, extension]];
            if (_listSourceFiles) {
                [humanHFiles addObject:humanHFileName];
            } else {
                if ([fm regularFileExistsAtPath:humanHFileName]) {
                    if (machineDirtied)
                        [fm touchPath:humanHFileName];
                } else {
                    [generatedHumanH writeToFile:humanHFileName atomically:NO encoding:NSUTF8StringEncoding error:nil];
                    humanFilesGenerated++;
                }
            }

            if (!_swift) {
                //  Human source files.
                NSString *humanMFileName = [humanDir stringByAppendingPathComponent:
                    [NSString stringWithFormat:@"%@.m", entityClassName]];
                NSString *humanMMFileName = [humanDir stringByAppendingPathComponent:
                    [NSString stringWithFormat:@"%@.mm", entityClassName]];
                if (![fm regularFileExistsAtPath:humanMFileName] && [fm regularFileExistsAtPath:humanMMFileName]) {
                    //  Allow .mm human files as well as .m files.
                    humanMFileName = humanMMFileName;
                }
                if (_listSourceFiles) {
                    [humanMFiles addObject:humanMFileName];
                } else {
                    if ([fm regularFileExistsAtPath:humanMFileName]) {
                        if (machineDirtied)
                            [fm touchPath:humanMFileName];
                    } else {
                        [generatedHumanM writeToFile:humanMFileName atomically:NO encoding:NSUTF8StringEncoding error:nil];
                        humanFilesGenerated++;
                    }
                }
                
                [mfileContent appendFormat:@"#import \"%@\"\n#import \"%@\"\n",
                    [humanMFileName lastPathComponent], [machineMFileName lastPathComponent]];
                [hfileContent appendFormat:@"#import \"%@\"\n", [humanHFileName lastPathComponent]];
            }
        }
        
        if (_listSourceFiles) {
            NSArray *filesList = [NSArray arrayWithObjects:humanMFiles, humanHFiles, machineMFiles, machineHFiles, nil];
            for (NSArray *files in filesList) {
                for (NSString *fileName in files) {
                    ddprintf(@"%@\n", fileName);
                }
            }
        }
    }
    
    bool mfileGenerated = NO;
    if (mfilePath && ![mfileContent isEqualToString:@""] && (![fm regularFileExistsAtPath:mfilePath] || ![[NSString stringWithContentsOfFile:mfilePath encoding:NSUTF8StringEncoding error:nil] isEqualToString:mfileContent])) {
        [mfileContent writeToFile:mfilePath atomically:NO encoding:NSUTF8StringEncoding error:nil];
        mfileGenerated = YES;
    }

    bool hfileGenerated = NO;
    if (hfilePath && ![hfileContent isEqualToString:@""] && (![fm regularFileExistsAtPath:hfilePath] || ![[NSString stringWithContentsOfFile:hfilePath encoding:NSUTF8StringEncoding error:nil] isEqualToString:hfileContent])) {
        [hfileContent writeToFile:hfilePath atomically:NO encoding:NSUTF8StringEncoding error:nil];
        hfileGenerated = YES;
    }

    if (!_listSourceFiles) {
        printf("%d machine files%s %d human files%s generated.\n", machineFilesGenerated,
               (mfileGenerated ? "," : " and"), humanFilesGenerated, (mfileGenerated ? " and one include.m file" : ""));

        if (hfileGenerated) {
            printf("Aggregate header file was also generated to %s.\n", [hfilePath fileSystemRepresentation]);
        }
    }
    
    return EXIT_SUCCESS;
}


@end
