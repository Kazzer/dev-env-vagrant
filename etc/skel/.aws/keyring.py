#!/usr/bin/env python
""" Manages AWS credentials using libsecret """
import boto3
import gi.repository.GObject
gi.require_version('Secret', '1')
import gi.repository.Secret
import os
import sys

INPUT = raw_input if hasattr(__builtins__, 'raw_input') else input
DISPLAY_MANAGER_AVAILABLE = True if os.getenv('DISPLAY') else False

SCHEMA = gi.repository.Secret.Schema.new(
    'org.freedesktop.Secret.Generic',
    gi.repository.Secret.SchemaFlags.NONE,
    {
        'type': gi.repository.Secret.SchemaAttributeType.STRING,
        'user-name': gi.repository.Secret.SchemaAttributeType.STRING,
    },
)


def passthrough_prompt(message):
    """ Uses stderr to prompt the user without tainting stdout """
    sys.stderr.write(message)
    return INPUT()


def create_item(collection, label, attributes, secret):
    """ Creates an item on a collection """
    return gi.repository.Secret.Item.create_sync(
        collection,
        SCHEMA,
        attributes,
        label,
        gi.repository.Secret.Value.new(
            secret,
            len(secret),
            'text/plain',
        ),
        gi.repository.Secret.ItemCreateFlags.REPLACE,
    )


def create_keyring(keyring):
    """ Creates a new keyring if one doesn't exist """
    service = gi.repository.Secret.Service.get_sync(
        gi.repository.Secret.ServiceFlags.LOAD_COLLECTIONS,
    )
    collections = {collection.get_label():collection for collection in service.get_collections()}

    if keyring in collections:
        return collections[keyring]

    return gi.repository.Secret.Collection.create_sync(
        service,
        keyring,
        None,
        gi.repository.Secret.CollectionCreateFlags.NONE,
    )


def update_api(collection, user_name):
    """ Updates an API key for a user name on a collection """
    return create_item(
        collection,
        passthrough_prompt('AwsAccessKeyId: '),
        {
            'type': 'AWS_KEY_PAIR',
            'user-name': user_name,
        },
        passthrough_prompt('AwsSecretAccessKey: '),
    )


def update_password(collection, user_name):
    """ Updates a password for a user name on a keyring """
    return create_item(
        collection,
        user_name,
        {
            'type': 'AWS_PASSWORD',
            'user-name': user_name,
        },
        passthrough_prompt('AwsPassword: '),
    )


def update(collection, user_name, update_type):
    """ Updates a password and an API for a user name given the update type """
    if update_type in ('user', 'password'):
        update_password(collection, user_name)
    if update_type in ('user', 'api'):
        update_api(collection, user_name)


def find_items(item_type, user_name):
    """ Gets all items with matching attributes """
    return gi.repository.Secret.password_search_sync(
        SCHEMA,
        {
            'type': item_type,
            'user-name': user_name,
        },
        gi.repository.Secret.SearchFlags.ALL,
    )


def get_serial_number(user_name, key):
    """ Gets the MFA serial number for the user name """
    iam_client = boto3.client(
        'iam',
        aws_access_key_id=key.get_label(),
        aws_secret_access_key=key.get_secret().get_text(),
    )
    return iam_client.list_mfa_devices(
        UserName=user_name,
    )['MFADevices'][0]['SerialNumber']


def get_session_token(key, serial_number=None, token_code=None):
    """ Obtains a session token with default duration """
    sts_client = boto3.client(
        'sts',
        aws_access_key_id=key.get_label(),
        aws_secret_access_key=key.get_secret().get_text(),
    )
    if serial_number:
        if not token_code:
            token_code = passthrough_prompt('MFA Token Code: ')

        return sts_client.get_session_token(
            SerialNumber=serial_number,
            TokenCode=token_code,
        )
    else:
        return sts_client.get_session_token()


def unlock(*objects):
    """ Unlocks a series of objects if they are locked """
    number, unlocked_objects = objects[0].get_service().unlock_sync(objects)
    if number == 0:
        raise RuntimeError(
            '''Objects "{}" could not be unlocked.'''
            .format(tuple(o.get_label() for o in objects))
        )
    return objects

if __name__ == '__main__':
    import argparse

    ARGS = argparse.ArgumentParser(
        description='Manage AWS credentials in libsecret'
    )
    ARGS.add_argument(
        'user_name',
        help='AWS user name'
    )
    ARGS.add_argument(
        '--new',
        choices=('user', 'api', 'password'),
        help='Create or Update user credentials'
    )
    ARGS.add_argument(
        '--process',
        action='store_true',
        help='Output in format compatible with credential_process',
    )
    ARGS.add_argument(
        '--raw',
        action='store_true',
        help='Use unrestricted credentials instead of restricted credentials',
    )
    ARGS.add_argument(
        '--token-code',
        help='Provides token code for MFA instead of prompting',
    )
    ARGS.add_argument(
        '--mfa-user-name',
        help='Overrides the user name for MFA (if different)',
    )
    ARGS = ARGS.parse_args()

    if ARGS.new:
        KEYRING = 'AWS-{}'.format(ARGS.user_name)

        try:
            COLLECTION = create_keyring(KEYRING)
            if COLLECTION.get_locked():
                unlock(COLLECTION)

            update(COLLECTION, ARGS.user_name, ARGS.new)
        finally:
            COLLECTION.get_service().lock_sync([COLLECTION])

        raise SystemExit(0)

    try:
        EXPORT = ['export']
        KEY = find_items(
            'AWS_KEY_PAIR',
            ARGS.user_name,
        )[0]
    except IndexError:
        sys.stderr.write(
            '''No AWS keys found for user "{}"\n'''
            .format(ARGS.user_name)
        )
    else:
        if KEY.get_locked():
            unlock(KEY)

        if not KEY.load_secret_sync():
            sys.stderr.write(
                '''Secret could not be loaded for user "{}"\n'''
                .format(ARGS.user_name)
            )
            raise SystemExit(1)

        STS_RESPONSE = (
            get_session_token(KEY, get_serial_number(ARGS.mfa_user_name or ARGS.user_name, KEY), ARGS.token_code)
            if ARGS.raw
            else get_session_token(KEY)
        )

        if ARGS.process:
            import json

            STS_RESPONSE['Credentials']['Version'] = 1
            STS_RESPONSE['Credentials']['Expiration'] = STS_RESPONSE['Credentials']['Expiration'].isoformat()
            print(json.dumps(STS_RESPONSE['Credentials']))
        else:
            EXPORT.append(
                'AWS_ACCESS_KEY_ID={}'
                .format(STS_RESPONSE['Credentials']['AccessKeyId'])
            )
            EXPORT.append(
                'AWS_SECRET_ACCESS_KEY={}'
                .format(STS_RESPONSE['Credentials']['SecretAccessKey'])
            )
            EXPORT.append(
                'AWS_SECURITY_TOKEN={0} AWS_SESSION_TOKEN={0}'
                .format(STS_RESPONSE['Credentials']['SessionToken'])
            )
            print(' '.join(EXPORT))
    finally:
        KEY.get_service().lock_sync([KEY])
