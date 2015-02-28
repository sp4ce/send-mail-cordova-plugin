#import "GMailSenderDelegate.h"

@implementation GMailSenderDelegate

//
// Init the delegate with the user for
- (id) initWithUser: (NSString*) user password: (NSString*) password
{
    self = [super init];
    _user = user;
    _password = password;
    return self;
}

- (void) send: (CWMessage *) message
{
    _smtp = [[CWSMTP alloc] initWithName: @"smtp.gmail.com"  port: 465];
    [_smtp setDelegate: self];
    [_smtp setMessage: message];
    RELEASE(message);

    // We connect to the server _in background_. That means, this call
    // is non-blocking and methods will be invoked on the delegate
    // (or notifications will be posted) for further dialog with
    // the remote SMTP server.
    NSLog(@"Connecting to the %@ server...", @"smtp.gmail.com");
    [_smtp connectInBackgroundAndNotify];
}

//
// This method is automatically called once the SMTP authentication
// has completed. If it has failed, -authenticationFailed: will
// be invoked.
//
- (void) authenticationCompleted: (NSNotification *) notification
{
    NSLog(@"Authentication completed! Sending the message...");
    [_smtp sendMessage];
}

//
// This method is automatically called once the SMTP authentication
// has failed. If it has succeeded, -authenticationCompleted: will
// be invoked.
//
- (void) authenticationFailed: (NSNotification *) notification
{
    NSLog(@"Authentication failed! Closing the connection...");
    [_smtp close];
}

//
// This method is automatically called when the connection to
// the SMTP server was established.
//
- (void) connectionEstablished: (NSNotification *) notification
{
    NSLog(@"Connected!");

    NSLog(@"Now starting SSL...");
    [(CWTCPConnection *)[_smtp connection] startSSL];
}

//
// This method is automatically called when the connection to the
// server is abruptly closed by the server. GMail does that for example
// when you call close. You should make sure your message is sent
// in this delegate and not assume it only happens when after you
// invoke -close.
//
- (void) connectionLost: (NSNotification *) notification
{
    NSLog(@"Connection lost to the server!");
    RELEASE(_smtp);
}

//
// This method is automatically called when the connection to
// the SMTP server was terminated avec invoking -close on the
// SMTP instance.
//
- (void) connectionTerminated: (NSNotification *) notification
{
    NSLog(@"Connection closed.");
    RELEASE(_smtp);
}

//
// This method is automatically called when the message has been
// successfully sent.
//
- (void) messageSent: (NSNotification *) notification
{
    NSLog(@"Sent!\nClosing the connection.");
    [_smtp close];
}

//
// This method is automatically invoked once the SMTP service
// is fully initialized. One can send a message directly (if no
// SMTP authentication is required to relay the mail) or proceed
// with the authentication if needed.
//
- (void) serviceInitialized: (NSNotification *) notification
{
    NSLog(@"SSL handshaking completed.");
    NSLog(@"Available authentication mechanisms: %@", [_smtp supportedMechanisms]);
    [_smtp authenticate: _user  password: _password  mechanism: @"LOGIN"];
}

//
// This method is invoked once the transaction has been reset. This
// can be useful if one when to send more than one message over
// the same SMTP connection.
//
- (void) transactionResetCompleted: (NSNotification *) notification
{
    NSLog(@"Sending the message over the same connection...");
    [_smtp sendMessage];
}

@end
