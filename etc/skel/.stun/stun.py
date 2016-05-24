#!/usr/bin/env python
"""Utilises the STUN protocol to determine the originating IP"""
import binascii
import random
import socket


def stun(transaction_id=''.join(random.choice('0123456789ABCDEF') for _ in range(32))):
    """Returns a STUN response using local port 54320"""
    stun_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    stun_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    try:
        stun_socket.bind(('0.0.0.0', 54320,))
        stun_socket.sendto(
            binascii.a2b_hex('00010000{}'.format(transaction_id)),
            ('stun.stunprotocol.org', 3478,),
        )
        response = stun_socket.recvfrom(2048)[0]
        assert binascii.b2a_hex(response[0:2]) == b'0101'
        assert binascii.b2a_hex(response[4:20]).upper() == transaction_id.encode('utf-8').upper()
    except (
            socket.gaierror,
            AssertionError,
    ):
        raise RuntimeError('Could not determine IP using STUN.')
    finally:
        stun_socket.close()
    return response


def extract_ip_from_stun(stun_response):
    """Returns the IP address from a STUN response"""
    response_length = int(binascii.b2a_hex(stun_response[2:4]), 16)
    position = 20
    ip_address = '0.0.0.0'
    while position < response_length:
        if binascii.b2a_hex(stun_response[position:position+2]) == b'0001':
            ip_address = '{}.{}.{}.{}'.format(
                int(binascii.b2a_hex(stun_response[position+8:position+9]), 16),
                int(binascii.b2a_hex(stun_response[position+9:position+10]), 16),
                int(binascii.b2a_hex(stun_response[position+10:position+11]), 16),
                int(binascii.b2a_hex(stun_response[position+11:position+12]), 16),
            )
        position += 4 + int(binascii.b2a_hex(stun_response[position+2:position+4]), 16)
    return ip_address


def stun_for_ip():
    """Returns the IP extracted by executing STUN response"""
    return extract_ip_from_stun(stun())

if __name__ == '__main__':
    print(stun_for_ip())
