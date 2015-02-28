var sendmail = {

    send: function(successCallback, errorCallback, subject, body, sender, password, recipients, attachment){
        cordova.exec(successCallback,
            errorCallback,
            "SendMail",
            "send",
            [subject, body, sender, password, recipients, attachment]
        );
    }
}

module.exports = sendmail;
