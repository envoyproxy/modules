#!/usr/bin/env python

import http.client

def verify_normal_request():
    conn = http.client.HTTPConnection("localhost", 10000)
    conn.request("GET", "/status/200")
    response = conn.getresponse()
    return response.status == 200


def verify_ip_restricted_request():
    conn = http.client.HTTPConnection("localhost", 10000)
    conn.request("GET", "/status/200", headers={"X-Forwarded-For": "192.168.22.33"})
    response = conn.getresponse()
    return response.status == 403


if __name__ == "__main__":
    assert verify_normal_request(), "Normal request failed"
    assert verify_ip_restricted_request(), "IP restricted request did not return 403"
    print("All verifications for IP Restriction Dynamic Module passed.")
