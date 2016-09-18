![Tori APNS](https://github.com/boostcode/Tori-APNS/blob/master/.github/tori-apns-logo.png?raw=true)

[![Issues](https://img.shields.io/github/issues/boostcode/tori-APNS.svg?style=flat)](https://github.com/boostcode/tori-APNS/issues)
[![codebeat badge](https://codebeat.co/badges/193276f6-ea57-4cb5-9e8d-306df4169b01)](https://codebeat.co/projects/github-com-boostcode-tori-apns)

![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![Linux](https://img.shields.io/badge/os-linux-green.svg?style=flat)
![Swift 2.2 compatible](https://img.shields.io/badge/swift2-compatible-4BC51D.svg?style=flat)
![Apache 2](https://img.shields.io/badge/license-Apache2-blue.svg?style=flat)

`tori-APNS` is a simple lib that allows you to send Apple Push Notifications using `curl HTTP/2` protocol in linux & macOS, it is compatible starting from `swift 3`.

# Usage

A quick guide, step by step, about how to use this lib.
## 1- Install libcurl with http/2 support

In macOS using `brew` you can easily do with:

```shell
brew reinstall curl --with-openssl --with-nghttp2
brew link curl --force
```

## 2- Add tori-APNS to your project

Add this row to your `Package.swift` file:

```swift
.Package(url: "https://github.com/boostcode/tori-APNS.git", majorVersion: 0, minor: 2)
```

And then run `swift fetch` command.

## 3- Prepare certificates

Create your APNS certificates, then export as `P12` file without password then proceed in this way in your shell:

```shell
openssl pkcs12 -in path.p12 -out newfile.crt.pem -clcerts -nokeys
openssl pkcs12 -in path.p12 -out newfile.key.pem -nocerts -nodes
```

## 4- Integrate in your app

ToriAPNS is pretty easy to be used, first of all add this line on top of your file:

```swift
import ToriAPNS
```

then instantiate a `var` to handle pushes:

```swift
let push = APNS.init(withCerts: APNSCertificate(certPath: "/path/of/your file/apns-dev.crt.pem",
                                     keyPath: "/path/of/your file/apns-dev.key.pem"))
```

`APNS.init` takes a second parameter `inSandbox` that is `true` by default, if you switch to `false` pushes will be sent using production gateway.

Then create a payload for a push message:

```swift
let payload = APNSPayload(withText: "Test")
```

In this new implementation we have 7 parameters that we can manage:

- `badge`: take care of the badge counter
- `text`: is the message that will be shown in the push
- `ttl`: is the time to live of the push that is going to be sent (0 is max value)
- `topic`: allows you to tag a push for a type of content
- `id`: allows you to easily track the push
- `priority`: we can manage to send push with max priority `.high` or `.standard`
- `extra`: you can provide extra fields to the push message using a dictionary of type `[String: String]`

Finally you have to send your push using `send` passing the `payload` you created just before and the `pushToken` of the receiver:

```swift
push.send(payload: payload, to: "12345678")
```

So the overall structure in your app should look pretty similar to:

```swift
let push = APNS.init(withCerts: APNSCertificate(certPath: "/path/of/your file/apns-dev.crt.pem",
                                     keyPath: "/path/of/your file/apns-dev.key.pem"))

let payload = APNSPayload(withText: "Test")

push.send(payload: payload, to: "12345678")
```

And then use again `swift build` command.
