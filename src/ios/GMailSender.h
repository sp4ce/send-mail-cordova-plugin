#import <Pantomime/Pantomime.h>

#import "GMailSenderDelegate.h"

@interface GMailSender : NSObject {
    @private
        GMailSenderDelegate* _delegate;
}

-(id) initWithDelegate: (GMailSenderDelegate*) delegate;

-(void) send: (NSString*) body
    to: (NSString*) recipients
    subject: (NSString*) subject
    from: (NSString*) sender
    attach: (NSString*) attachment;

@end
