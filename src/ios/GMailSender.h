#import <Pantomime/Pantomime.h>

@interface GMailSender : NSObject {
    @private
        CWSMTP *_smtp;
        NSString* _user;
        NSString* _password;
}

-(void) setUser: (NSString*) u;
-(void) setPassword: (NSString*) p;

-(void) send: (NSString*) body
    to: (NSString*) recipients
    subject: (NSString*) subject
    from: (NSString*) sender
    attach: (NSString*) attachment;

@end
