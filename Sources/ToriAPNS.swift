/**
 * Copyright boostco.de 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import CCurl
import Foundation
import SwiftyJSON

public enum APNSGateway: String {
    case sandbox = "https://api.development.push.apple.com"
    case production = "https://api.push.apple.com"
}

public enum APNSPriority: Int {
    case standard = 5
    case high = 10
}

// MARK: - Payload
public class APNSPayload {

    var badge: Int?
    var text = ""
    var sound: String?
    var ttl = 0
    var topic: String?
    var id: String?
    var extra: [String: String]?
    var priority = APNSPriority.high

    init(withText text: String, badge: Int? = nil, sound: String? = nil, ttl: Int = 0, topic: String? = nil, id: String? = nil, priority: APNSPriority = .high, extra: [String: String] = [:]) {
        self.text = text
        self.badge = badge
        self.sound = sound
        self.ttl = ttl
        self.topic = topic
        self.id = id
        self.extra = extra
        self.priority = priority
    }

    func toString() -> String? {
        var json: JSON = ["text": text]

        if let b = badge {
            json["badge"] = JSON(b)
        }

        if let s = sound {
            json["sound"] = JSON(s)
        }

        if let e = extra {
            json["extra"] = JSON(e)
        }

        return json.rawString()
    }
}

// MARK: - Certificate
public struct APNSCertificate {
    var certPath = ""
    var keyPath = ""
}

public class APNS {

    private var certs: APNSCertificate
    private var env: APNSGateway
    private var handle: UnsafeMutableRawPointer

    public init(withCerts certs: APNSCertificate, inSandbox isSandbox: Bool = true) {

        // setup curl
        handle = curl_easy_init()

        // verbose mode
        curlHelperSetOptBool(handle, CURLOPT_VERBOSE, 1)

        // set certs
        self.certs = certs

        if isSandbox {
            env = .sandbox
        } else {
            env = .production
        }

        // setup certificates
        curlHelperSetOptString(handle, CURLOPT_SSLCERT, certs.certPath)
        curlHelperSetOptString(handle, CURLOPT_SSLCERTTYPE, "PEM")
        curlHelperSetOptString(handle, CURLOPT_SSLKEY, certs.keyPath)
        curlHelperSetOptString(handle, CURLOPT_SSLKEYTYPE, "PEM")

        // force protocol to http2
        curlHelperSetOptInt(handle, CURLOPT_HTTP_VERSION, CURL_HTTP_VERSION_2_0)
    }

    public func send(payload push: APNSPayload, to token: String) {

        var headersList: UnsafeMutablePointer<curl_slist>?

        // set url for push according env
        curlHelperSetOptString(handle, CURLOPT_URL, (env.rawValue + "/3/device/\(token)"))

        // set port to 443 (we can omit it)
        curlHelperSetOptInt(handle, CURLOPT_PORT, 443)

        // follow location
        curlHelperSetOptBool(handle, CURLOPT_FOLLOWLOCATION, 1)

        // set POST request
        curlHelperSetOptBool(handle, CURLOPT_POST, 1)

        // setup payload
        guard let jsonString = push.toString() else { return }
        let payload = jsonString

        curlHelperSetOptString(handle, CURLOPT_POSTFIELDS, payload)

        // set headers
        curlHelperSetOptBool(handle, CURLOPT_HEADER, 1)
        headersList = curl_slist_append(headersList, "Accept: application/json")
        headersList = curl_slist_append(headersList, "Content-Type: application/json")
        headersList = curl_slist_append(headersList, "apns-priority: \(push.priority.rawValue)")
        headersList = curl_slist_append(headersList, "apns-expiration: \(push.ttl)")

        if let topic = push.topic {
            headersList = curl_slist_append(headersList, "apns-topic: \(topic)")
        }

        if let id = push.id {
            headersList = curl_slist_append(headersList, "apns-id: \(id)")
        }

        curlHelperSetOptList(handle, CURLOPT_HTTPHEADER, headersList)

        // TODO: improve response handler
        let ret = curl_easy_perform(handle)

        print("ret = \(ret)")

        if ret == CURLE_OK {
            //print(String(utf8String: error!)!)
        } else {
            let error = curl_easy_strerror(ret)
            print(String(utf8String: error!)!)
        }
    }

}
