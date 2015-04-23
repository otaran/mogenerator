// mogenerator.h
//   Copyright (c) 2006-2014 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//   Some rights reserved: http://opensource.org/licenses/mit
//   http://github.com/rentzsch/mogenerator

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <ddcli/DDCommandLineInterface.h>

@interface MOGeneratorApp : NSObject <DDCliApplicationDelegate> {
    NSString              *origModelBasePath;
    NSString              *tempGeneratedMomFilePath;
    NSManagedObjectModel  *model;
    NSString              *configuration;
    NSString              *baseClass;
    NSString              *baseClassImport;
    NSString              *baseClassForce;
    NSString              *includem;
    NSString              *includeh;
    NSString              *templatePath;
    NSString              *outputDir;
    NSString              *machineDir;
    NSString              *humanDir;
    NSString              *templateGroup;
    BOOL                  _help;
    BOOL                  _version;
    BOOL                  _listSourceFiles;
    BOOL                  _orphaned;
    BOOL                  _swift;
    BOOL                  _v2;
    NSMutableDictionary   *templateVar;
}
@end
