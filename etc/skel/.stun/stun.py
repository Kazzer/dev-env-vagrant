#!/usr/bin/env python
''' Utilises the STUN protocol to determine the originating IP '''
import binascii
import logging
import random
import socket
import time

LOG = logging.getLogger(__name__)

def stun_for_ip(
        retry=3,
        transaction_id=''.join(
            [random.choice('0123456789ABCDEF') for i in range(32)]
        )
):
    ''' Executes a reliable STUN and returns the IP '''
    stun_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    stun_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    while 1:
        try:
            stun_socket.bind(('0.0.0.0', 54320))
            stun_socket.sendto(
                binascii.a2b_hex(
                    ''.join(
                        ['0001', '0000', transaction_id, '']
                    )
                ),
                ('stun.stunprotocol.org', 3478)
            )
            response = stun_socket.recvfrom(2048)[0]
            assert binascii.b2a_hex(response[0:2]) == b'0101'
            assert (
                binascii.b2a_hex(response[4:20]).upper()
                == transaction_id.encode('utf-8').upper()
            )
        except (
                socket.gaierror,
                AssertionError
        ):
            if retry > 0:
                time.sleep(5)
                retry -= 1
                continue
            else:
                LOG.error(
                    'Could not determine IP using STUN.'
                )
                exit(3)
        else:
            response_length = int(binascii.b2a_hex(response[2:4]), 16)
            i = 20
            while i < response_length:
                if binascii.b2a_hex(
                        response[i:i+2]
                ) == b'0001':
                    ip_address = '.'.join([
                        str(int(binascii.b2a_hex(response[i+8:i+9]), 16)),
                        str(int(binascii.b2a_hex(response[i+9:i+10]), 16)),
                        str(int(binascii.b2a_hex(response[i+10:i+11]), 16)),
                        str(int(binascii.b2a_hex(response[i+11:i+12]), 16))
                    ])
                i += 4 + int(binascii.b2a_hex(response[i+2:i+4]), 16)
            return ip_address
        finally:
            stun_socket.close()

if __name__ == '__main__':
    print(stun_for_ip())
