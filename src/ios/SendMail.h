#import <Cordova/CDVPlugin.h>

#import "GMailSenderDelegate.h"

@interface SendMail : CDVPlugin

- (void) send: (CDVInvokedUrlCommand *) command;

@end

@interface GMailSenderPluginDelegate : GMailSenderDelegate
{
    @private
        SendMail *_plugin;
        (CDVInvokedUrlCommand *) _command;
        BOOL _success;
}

- (id) initWithPlugin: (SendMail *) plugin
    command: (CDVInvokedUrlCommand *) command
    user: (NSString *) user
    password: (NSString *) password;

@end
