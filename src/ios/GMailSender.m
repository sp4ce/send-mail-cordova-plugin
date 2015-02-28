#import <AppKit/AppKit.h>

#import <Pantomime/Pantomime.h>

#import "GMailSender.h"

@implementation GMailSender

//
// Init the sender with an instance of the delegate that will handle the
// the notification after sending the message.
//
-(id) initWithDelegate: (GMailSenderDelegate*) delegate
{
    self = [super init];
    _delegate = delegate;
    return self;
}

//
// Send the message.
//
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
    address = [[CWInternetAddress alloc] initWithString: sender];
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

    // Add part 1.
    [multipart addPart:part];
    [part release];

    // Part 2 the attachment.
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

    // We set the Message's Content-Type, encoding and charset.
    [message setContentTransferEncoding: PantomimeEncodingNone];
    [message setContentType: @"multipart/mixed"];
    [message setContent: multipart];
    [multipart release];

    // Do no know what it does.
    [message setBoundary: [CWMIMEUtility globallyUniqueBoundary]];

    // Send the message using the delegate.
    [_delegate send: message];
}

@end
