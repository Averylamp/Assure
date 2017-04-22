#POST https://api.twilio.com/2010-04-01/Accounts/AC123456abc/Messages
#https://www.twilio.com/docs/libraries/python

# /usr/bin/env python
# Download the twilio-python library from http://twilio.com/docs/libraries
from twilio.rest import Client

# Find these values at https://twilio.com/user/account
account_sid = "AC8297f68c93c5374aec9089e8fabfc089"
auth_token = "118545b140865a4db481070ed8092699"
client = Client(account_sid, auth_token)

numbers = ["+19738738225","+19202860426","+16268727820","+13233948643"]

def send_message(text):
    for i in numbers:
        message = client.api.account.messages.create(to=i,
                                                from_="+16265514837",
                                                body=text)
        print(message.sid)

send_message("Grandpa Joe just fell down! You should check on him.")


