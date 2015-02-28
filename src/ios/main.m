// This file is not part of the source plugin it is to test the plugin
// As I was coding under linux, I used GNUstep to compile.
// Compiling:  gcc `gnustep-config --objc-flags` -o main main.m GMailSenr.m  -lobjc -lgnustep-base -lgnustep-gui -lPantomime -L/usr/GNUstep/Local/Library/Libraries/
// Running: ./main user@gmail.com password

#import <stdio.h>

#import <AppKit/AppKit.h>

#import "GMailSender.h"

//
// Our class interface.
//
@interface SimpleSMTP : NSObject
{
    @private
        NSString *_user;
        NSString *_password;
}

-(void) setUser: (NSString*) u;
-(void) setPassword: (NSString*) p;

@end

//
// Our class implementation.
//
@implementation SimpleSMTP

-(void) setUser: (NSString*) u
{
    _user = u;
}

-(void) setPassword: (NSString*) p
{
    _password = p;
}

- (void) applicationDidFinishLaunching: (NSNotification *) notification
{
    // Create a new instance.
    GMailSender *gmailSender =
    [
        [GMailSender alloc] initWithDelegate:
        [
            [GMailSenderDelegate alloc]
            initWithUser: _user
            password: _password
        ]
    ];

    // Send the mail.
    [gmailSender send: [NSString stringWithFormat:@"%s", "This is a test"]
        to: [NSString stringWithFormat:@"%s" , "bapt@sp4ce.net"]
        subject: [NSString stringWithFormat:@"%s" , "test subject"]
        from: [NSString stringWithFormat:@"%s" , _user]
        attach: [NSString stringWithFormat:@"%s" , "/home/baptiste/Desktop/macholand.png"]];
}

@end

int main(int argc, const char *argv[])
{
    // Arguments check.
    if (argc < 3)
    {
        printf("please provide gmail user and password.\n");
        return 1;
    }

    NSAutoreleasePool *pool;
    SimpleSMTP *o;

    pool = [[NSAutoreleasePool alloc] init];
    o = [[SimpleSMTP alloc] init];
    [o setUser: [NSString stringWithFormat:@"%s", argv[1]]];
    [o setPassword: [NSString stringWithFormat:@"%s", argv[2]]];

    [NSApplication sharedApplication];
    [NSApp setDelegate: o];
    [NSApp run];
    RELEASE(o);
    RELEASE(pool);

    return 0;
}
