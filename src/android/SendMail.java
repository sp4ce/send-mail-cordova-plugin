package com.autentia.plugin.sendmail;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class SendMail extends CordovaPlugin {

	public static final String ACTION_SEND = "send";

	public boolean execute(
		String action,
		JSONArray jsonArgs,
		final CallbackContext callbackContext) throws JSONException {

		if (ACTION_SEND.equals(action)) {
			// Get the json arguments as final for thread usage.
			final String subject = jsonArgs.getString(0);
			final String body = jsonArgs.getString(1);
			final String sender = jsonArgs.getString(2);
			final String password = jsonArgs.getString(3);
			final String recipients = jsonArgs.getString(4);
			final String attachment = jsonArgs.getString(5);

			// Run in a thread to not block the webcore thread.
			cordova.getThreadPool().execute(new Runnable() {
				// Thread method.
				public void run() {
					// Try to send the the mail.
					try {
						// Create the sender
						GMailSender gmailSender = new GMailSender(sender, password);

						// Send the mail.
						gmailSender.sendMail(subject, body, sender, recipients, attachment);

						// Thread safe callback.
						callbackContext.success();
					} catch (Exception e) {
						// Catch error.
						callbackContext.error(e.getMessage());
						callbackContext.error(e.toString());
					}
				}
			});

			return true;
		}

		return false;
	}
}
