// mogenerator.h
//   Copyright (c) 2006-2014 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//   Some rights reserved: http://opensource.org/licenses/mit
//   http://github.com/rentzsch/mogenerator

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <ddcli/DDCommandLineInterface.h>

@interface MOGeneratorApp : NSObject <DDCliApplicationDelegate>

@property (nonatomic, retain) NSString *origModelBasePath;
@property (nonatomic, retain) NSString *tempGeneratedMomFilePath;
@property (nonatomic, retain) NSManagedObjectModel *model;
@property (nonatomic, retain) NSString *configuration;
@property (nonatomic, retain) NSString *baseClass;
@property (nonatomic, retain) NSString *baseClassImport;
@property (nonatomic, retain) NSString *baseClassForce;
@property (nonatomic, retain) NSString *includem;
@property (nonatomic, retain) NSString *includeh;
@property (nonatomic, retain) NSString *templatePath;
@property (nonatomic, retain) NSString *outputDir;
@property (nonatomic, retain) NSString *machineDir;
@property (nonatomic, retain) NSString *humanDir;
@property (nonatomic, retain) NSString *templateGroup;
@property (nonatomic, assign) BOOL help;
@property (nonatomic, assign) BOOL version;
@property (nonatomic, assign) BOOL listSourceFiles;
@property (nonatomic, assign) BOOL orphaned;
@property (nonatomic, assign) BOOL swift;
@property (nonatomic, assign) BOOL v2;
@property (nonatomic, retain) NSMutableDictionary *templateVar;

@end
