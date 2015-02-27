#import <AppKit/AppKit.h>

#import <Pantomime/Pantomime.h>

#import "GMailSender.h"

@implementation GMailSender

-(void) setUser: (NSString*) u
{
    _user = u;
}

-(void) setPassword: (NSString*) p
{
    _password = p;
}

-(void) send: (NSString*) body
    to: (NSString*) recipients
    subject: (NSString*) subject
    from: (NSString*) sender
    attach:(NSString*) attachment
{
    CWInternetAddress *address;
    CWMessage *message;

    // We create a simple message object.
    message = [[CWMessage alloc] init];
    [message setSubject: subject];

    // We set the "From:" header.
    address = [[CWInternetAddress alloc] initWithString: _user];
    [message setFrom: address];
    RELEASE(address);

    // We set the "To: header.
    address = [[CWInternetAddress alloc] initWithString: recipients];
    [address setType: PantomimeToRecipient];
    [message addRecipient: address];
    RELEASE(address);

    // Multi part for attachment.
    CWMIMEMultipart *multipart = [[CWMIMEMultipart alloc] init];

    // Part 1: the body.
    CWPart *part = [[CWPart alloc] init];
    [part setContentType: @"text/plain"];
    [part setContentTransferEncoding: PantomimeEncodingQuotedPrintable];
    [part setFormat: PantomimeFormatUnknown];
    [part setCharset: @"UTF-8"];
    [part setContent: [body dataUsingEncoding:NSUTF8StringEncoding]];

    // Add part 1
    [multipart addPart:part];
    [part release];

    // Part 2 the attachment
    if (attachment != nil)
    {
        // Create the part.
        part = [[CWPart alloc] init];
        NSFileWrapper *file = [[NSFileWrapper alloc] initWithPath: attachment];
        [part setFilename: [[file filename] lastPathComponent]];
        [part setContentType: @"application/octet-stream"];
        [part setContentTransferEncoding: PantomimeEncodingBase64];
        [part setContentDisposition: PantomimeAttachmentDisposition];
        [part setContent: [file regularFileContents]];

        // Add the part.
        [multipart addPart:part];
        [part release];
        [file release];
    }

    // We set the Message's Content-Type, encoding and charset
    [message setContentTransferEncoding: PantomimeEncodingNone];
    [message setContentType: @"multipart/mixed"];
    [message setContent: multipart];
    [multipart release];

    // Do no know what it does.
    [message setBoundary: [CWMIMEUtility globallyUniqueBoundary]];

    // We initialize our SMTP instance
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
- (void) authenticationCompleted: (NSNotification *) theNotification
{
    NSLog(@"Authentication completed! Sending the message...");
    [_smtp sendMessage];
}

//
// This method is automatically called once the SMTP authentication
// has failed. If it has succeeded, -authenticationCompleted: will
// be invoked.
//
- (void) authenticationFailed: (NSNotification *) theNotification
{
    NSLog(@"Authentication failed! Closing the connection...");
    [_smtp close];
}


//
// This method is automatically called when the connection to
// the SMTP server was established.
//
- (void) connectionEstablished: (NSNotification *) theNotification
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
- (void) connectionLost: (NSNotification *) theNotification
{
    NSLog(@"Connection lost to the server!");
    RELEASE(_smtp);
}


//
// This method is automatically called when the connection to
// the SMTP server was terminated avec invoking -close on the
// SMTP instance.
//
- (void) connectionTerminated: (NSNotification *) theNotification
{
    NSLog(@"Connection closed.");
    RELEASE(_smtp);
}


//
// This method is automatically called when the message has been
// successfully sent.
//
- (void) messageSent: (NSNotification *) theNotification
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
- (void) serviceInitialized: (NSNotification *) theNotification
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
- (void) transactionResetCompleted: (NSNotification *) theNotification
{
  NSLog(@"Sending the message over the same connection...");
  [_smtp sendMessage];
}

@end
