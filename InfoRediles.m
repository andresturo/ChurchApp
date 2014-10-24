//
//  InfoRediles.m
//  RedilApp
//
//  Created by Daniel Cardona on 9/12/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import "InfoRediles.h"

@interface InfoRediles()

@property (strong,nonatomic) NSArray* listOfHeadquarters;
@property (strong,nonatomic) NSArray* listOfContacts;
@end

@implementation InfoRediles
#pragma mark Utility methods

-(NSArray*)getJsonWithURL:(NSString*)urlString{
    NSError* error;
    
    UIAlertView* alert;
    
    NSURL* url = [NSURL URLWithString:urlString];
    NSData* jsonData = [NSData dataWithContentsOfURL:url options:NSUTF8StringEncoding error:&error];
    
    if (!jsonData) {
        NSLog(@"Error en descarga: %@",[error description]);
         alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"No hay contactos disponibles, por favor conectese a una red wifi" delegate:nil cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
        [alert show];
        return nil;
    }
    
    NSArray* responseArray = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
    if (!responseArray) {
        NSLog(@"Error al cargar los datos %@",[error description]);
        
    }
    return responseArray;
}

-(NSArray*)sortArrayOfDictionaries:(NSArray*)array UsingKey:(NSString*)keyName{
    
    NSSortDescriptor* nameDescriptor = [[NSSortDescriptor alloc] initWithKey:keyName ascending:YES];
    NSArray* sortDescriptors = [NSArray arrayWithObject:nameDescriptor];
    return [array sortedArrayUsingDescriptors:sortDescriptors];
}
//TODO: check if theres an updated version of remote JSON file

-(BOOL) shouldUpdateContactsFile{

    NSArray* checkArray =[self getJsonWithURL:@"http://danielcardonarojas.eu5.org/JSONRedilApp/contacts.json"];
    [[checkArray objectAtIndex:0] objectForKey:@"versionDate"];
    return YES;
}
-(BOOL) shouldUpdateSedesFile{
    return YES;
}

-(void)writeJsonResponse:(NSArray*) array toPlistNamed:(NSString*)plistName{
    //TODO: does this method have to check if file already exists? Or does it just overwrite?
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [path objectAtIndex:0];
    NSString *filePath = [documentFolder stringByAppendingFormat:plistName];
    [array writeToFile:filePath atomically:YES];
    NSLog(@"file Stored at %@",filePath);
}

-(void)saveDataFile:(NSData*)dataContent inDocumentsDirectory:(NSString*)directory withName:(NSString*)fileName{
    

	NSString *path;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	path = [[paths objectAtIndex:0] stringByAppendingPathComponent:directory];
	path = [path stringByAppendingPathComponent:fileName];
    
    [[NSFileManager defaultManager] createFileAtPath:path
                                            contents: dataContent
                                          attributes:nil];
}
-(void)loadFileInDirectory:(NSString*)directory named:(NSString*)name {
    
    NSString *path;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path = [[paths objectAtIndex:0] stringByAppendingPathComponent:directory];
    path = [path stringByAppendingPathComponent:name];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        //File exists
        NSData *file1 = [[NSData alloc] initWithContentsOfFile:path];
        if (file1)
        {
           // [self MyFunctionWantingAFile:file1];
            
        }
    }
    else
    {
        NSLog(@"File does not exist");
    }

}
#pragma mark public API
-(void)saveContactsJsonFile{
    
    if ([self shouldUpdateContactsFile]) {
        //TODO: download file to docs or main bundle
        
        
        
    }
}
-(void)saveSedesJsonFile {
    
    if ([self shouldUpdateSedesFile]) {
        //TODO: download file to docs or main bundle
    }
}

-(NSArray *)contactsInfoArrayUsingRemoteJSON{
    
    
    _listOfContacts = [self getJsonWithURL:@"http://danielcardonarojas.eu5.org/JSONRedilApp/contacts.json"];
    
    if ([self.delegate shouldSortContacts]) {
        _listOfContacts = [self sortArrayOfDictionaries:_listOfContacts UsingKey:@"name"];
    }
    return _listOfContacts;
}
-(NSArray *)sedesInfoArrayUsingRemoteJSON{
    
    _listOfHeadquarters = [self getJsonWithURL:@"http://danielcardonarojas.eu5.org/JSONRedilApp/sedes.json"];
    
    if ([self.delegate shouldSortSedes]) {
        _listOfHeadquarters = [self sortArrayOfDictionaries:_listOfHeadquarters UsingKey:@"nombre"];
    }
    return _listOfHeadquarters;
}
-(NSArray *)contactsInfoArrayUsingLocalPlist{
    
    NSString* path = [[NSBundle mainBundle]pathForResource:@"contacts" ofType:@"plist"];
    _listOfContacts = [[NSArray alloc]initWithContentsOfFile:path];
    return _listOfContacts;
}

-(NSArray *)sedesInfoArrayUsingLocalPlist{
    
    NSString* path = [[NSBundle mainBundle]pathForResource:@"sedes" ofType:@"plist"];
    _listOfHeadquarters = [[NSArray alloc]initWithContentsOfFile:path];
    return _listOfHeadquarters;
}





@end
