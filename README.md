Send mail cordova plugin
========================

This Cordova plugin allows to send an email using Android 7 and IOS platform without email composer. It connects to GMail SMTP service to send the email.

GMail account configuration
===========================

In order to be able to send an email, you need to activate some parameters in the
gmail account. First you need to unlock your account and then activate the less
secure appplication.
 - https://accounts.google.com/b/0/DisplayUnlockCaptcha
 - https://www.google.com/settings/security/lesssecureapps

Also, because you need to hard code the password in the app and deactivate basic
security on the gmail account, it is strongly advised to create a dedicated gmail
account to send email.

Add in Cordova/PhoneGap project
========================

cordova plugin add https://github.com/sp4ce/send-mail-cordova-plugin.git

IOS dependencies
================

IOS needs to add the Pantomime library to your project. To install the library on linux
you can use GNUstep framework and then visit [this wiki page](http://wiki.gnustep.org/index.php/Pantomime). To install the library on IOS
 you need to use mac port to install the framework: `port install Pantomime-Framework`

Example calling from index.js
========================

    var app = {
        // Application Constructor
        initialize: function() {
            this.bindEvents();
        },

        // Bind Event Listeners
        //
        // Bind any events that are required on startup. Common events are:
        // 'load', 'deviceready', 'offline', and 'online'.
        bindEvents: function() {
            document.addEventListener('deviceready', this.onDeviceReady, false);
        },

        // deviceready Event Handler
        //
        // The scope of 'this' is the event. In order to call the 'receivedEvent'
        // function, we must explicity call 'app.receivedEvent(...);'
        onDeviceReady: function() {
            app.receivedEvent('deviceready');
            sendmail.send(app.sendMailSuccess, app.sendMailError,
                '(subject)',
                'body',
                'yourmail@gmail.com', 'password',
                'tosomeone@email.com');
        },

        sendMailSuccess : function() {
            console.log('Email send');
        },

        sendMailError : function(error) {
            console.log('Error: ' + error);
        },

        // Update DOM on a Received Event
        receivedEvent: function(id) {
            var parentElement = document.getElementById(id);
            var listeningElement = parentElement.querySelector('.listening');
            var receivedElement = parentElement.querySelector('.received');

            listeningElement.setAttribute('style', 'display:none;');
            receivedElement.setAttribute('style', 'display:block;');

            console.log('Received Event: ' + id);
        }
    };


Attachment
==========

The library allows you to attach one file to the mail. You simply add the path
to the file when you call it:

    sendmail.send(app.sendMailSuccess, app.sendMailError,
        '(subject)',
        'body',
        'yourmail@gmail.com', 'password',
        'tosomeone@email.com'
        '/path/to/file');
