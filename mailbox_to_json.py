#!/usr/bin/env python3

import mailbox
import datetime
import pytz
import locale
import json
import pickle
import os
from codecs import decode
from email.utils import parsedate_to_datetime, parseaddr, getaddresses
from email.header import decode_header, make_header

OWN_EMAIL_ADDRESSES = ('some@domain.com',)

def get_info(message):
	from_ = None
	to = None
	subject = None
	date = None
	try:
		from_ = message.get_all('from', None)
		to = message.get_all('to', None)
		subject = message.get('subject', None)
		date = message.get('date', None)
	except Exception as e:
		print("An exception occurred in get_info")
		print(e)

	return {
		'from': from_,
		'to': to,
		'subject': subject,
		'date': date,
	}

def main():
	locale.setlocale(locale.LC_ALL, 'en_US')
	mail = mailbox.mbox('mailbox.mbox')

	messages = []
	if not os.path.isfile('./processed_mailbox.pickle'):
		for i, message in enumerate(mail):
			messages.append(get_info(message))

		with open('processed_mailbox.pickle', 'wb') as f:
			pickle.dump(messages, f, pickle.HIGHEST_PROTOCOL)
	else:
		print("Loading from .pickle file...")
		with open('processed_mailbox.pickle', 'rb') as f:
			messages = pickle.load(f)

	sent_messages = []
	received_messages = []
	
	print(len(messages))

	for message in messages:
		fully_parsed_date = None
		try:
			parsed_date = parsedate_to_datetime(message['date'])
			fully_parsed_date = parsed_date if parsed_date.tzinfo == None else parsed_date.astimezone(pytz.timezone('Europe/Oslo')).replace(tzinfo=None)
		except Exception as e:
			print(e)
			pass

		from_ = None
		try:
			from_ = None if message['from'] == None else [a[1] for a in getaddresses(message['from'])]
		except Exception as e:
			print(e)
			pass

		to = None
		try:
			to = None if message['to'] == None else [a[1] for a in getaddresses(message['to'])]
		except Exception as e:
			print(e)
			pass

		subject = None
		try:
			subject = make_header(decode_header(message['subject'])).__str__()
		except Exception as e:
			print(e)
			pass
		message_dict = {
			'from': from_,
			'to': to,
			'subject': subject,
			'date': fully_parsed_date.isoformat(' ') if fully_parsed_date else None
		}

		if from_ == None:
			received_messages.append(message_dict)
			continue

		for address in from_:
			if address in OWN_EMAIL_ADDRESSES:
				sent_messages.append(message_dict)
				break
		else:
			received_messages.append(message_dict)

	with open('sent.json', 'w+') as f:
		json.dump(sent_messages, f)

	with open('received.json', 'w+') as f:
		json.dump(received_messages, f)

	return received_messages, sent_messages

if __name__ == "__main__":
	main()