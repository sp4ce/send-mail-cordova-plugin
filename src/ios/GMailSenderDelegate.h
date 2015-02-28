#import <Pantomime/Pantomime.h>

@interface GMailSenderDelegate : NSObject
{
    @private
        CWSMTP *_smtp;
        NSString *_user;
        NSString *_password;
}

- (id) initWithUser: (NSString *) user password: (NSString *) password;

- (void) send: (CWMessage *) message;

- (void) authenticationCompleted: (NSNotification *) notification;
- (void) authenticationFailed: (NSNotification *) notification;
- (void) connectionEstablished: (NSNotification *) notification;
- (void) connectionLost: (NSNotification *) notification;
- (void) connectionTerminated: (NSNotification *) notification;
- (void) messageSent: (NSNotification *) notification;
- (void) serviceInitialized: (NSNotification *) notification;
- (void) transactionResetCompleted: (NSNotification *) notification;

@end
