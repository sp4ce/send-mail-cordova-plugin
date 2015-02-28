#import "SendMail.h"
#import "GMailSender.h"

@implementation SendMail

- (void)send: (CDVInvokedUrlCommand*) command
{
    // Get the arguments.
    NSString* subject = [command.arguments objectAtIndex:0];
    NSString* body = [command.arguments objectAtIndex:1];
    NSString* sender = [command.arguments objectAtIndex:2];
    NSString* password = [command.arguments objectAtIndex:3];
    NSString* recipients = [command.arguments objectAtIndex:4];
    NSString* attachment = [command.arguments objectAtIndex:5];

    // The result of the plugin.
    CDVPluginResult* pluginResult = nil;

    // Create a new instance.
    GMailSender *gmailSender =
    [
        [GMailSender alloc] initWithDelegate:
        [
            [GMailSenderPluginDelegate alloc]
            initWithPlugin: self
            command: command
            user: sender
            password: password
        ]
    ];

    // Run in the background.
    [self.commandDelegate runInBackground:^{
        NSString* payload = nil;

        // Send the mail.
        [gmailSender send: body
            to: recipients
            subject: subject
            from: user
            attach: attachment];
    }];
}

@end

//
// Own implementation of the delegate to tell the
// plugin the result of the sending of the message.
//
@implementation GMailSenderPluginDelegate

- (id) initWithPlugin: (SendMail *) plugin
    command: (CDVInvokedUrlCommand *) command
    user: (NSString *) user
    password: (NSString *) password;
{
    self = [super initWithUser: user password: password];
    _plugin = plugin;
    _command = command;
    _success = false;
    return self;
}

//
// This method is automatically called once the SMTP authentication
// has failed. If it has succeeded, -authenticationCompleted: will
// be invoked.
//
- (void) authenticationFailed: (NSNotification *) notification
{
    [super authenticationFailed: notification];

    // Build the result.
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];

    // The sendPluginResult method is thread-safe.
    [_plugin.commandDelegate sendPluginResult:pluginResult callbackId:_command.callbackId];
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
    [super connectionLost: notification];

    if (!_success)
    {
        // Build the result.
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];

        // The sendPluginResult method is thread-safe.
        [_plugin.commandDelegate sendPluginResult: pluginResult callbackId:_command.callbackId];
    }
}

//
// This method is automatically called when the connection to
// the SMTP server was terminated avec invoking -close on the
// SMTP instance.
//
- (void) connectionTerminated: (NSNotification *) notification
{
    [super connectionTerminated: notification];

    _success = true;

    // Build the result.
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];

    // The sendPluginResult method is thread-safe.
    [self.commandDelegate sendPluginResult:pluginResult callbackId:_command.callbackId];
}

@end
