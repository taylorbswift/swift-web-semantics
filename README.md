<div align="center">
  
***`resource`***<br>`0.3.2`
  
[![ci status](https://github.com/kelvin13/swift-resource/actions/workflows/build.yml/badge.svg)](https://github.com/kelvin13/swift-hash/actions/workflows/build.yml)
[![ci status](https://github.com/kelvin13/swift-resource/actions/workflows/build-devices.yml/badge.svg)](https://github.com/kelvin13/swift-hash/actions/workflows/build-devices.yml)
[![ci status](https://github.com/kelvin13/swift-resource/actions/workflows/build-windows.yml/badge.svg)](https://github.com/kelvin13/swift-hash/actions/workflows/build-windows.yml)


[![swift package index versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fkelvin13%2Fswift-resource%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/kelvin13/swift-hash)
[![swift package index platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fkelvin13%2Fswift-resource%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/kelvin13/swift-hash)

</div>

This package contains miscellaneous definitions useful for server applications. For the most part, the modules in this package refrain from vending complex implementations, as they only vend types intended to serve as a common medium-of-exchange between different downstream components.

Downstream consumers of this package are expected to provide additional functionality as extensions on the types in this package, as needed.

*   `MIME` 

    Vends a single type `MIME`, which contains `content-type` definitions.

*   `Resources`

    Vends a single type `Resource`, which wraps a `MIME` type, a backing storage payload ([`String`](https://swiftinit.org/reference/swift/string) or [`[UInt8]`](https://swiftinit.org/reference/swift/array)), and an optional SHA-256 hash. The `Resources` module also provides convenience APIs for serializing and parsing a SHA-256 hash to and from an HTTP ETag string.

    Please note that the module is named *`Resources`*, but the type is named `Resource`.

*   `WebSemantics`

    Contains type definitions useful for applications that implement an HTTP or HTTP-like API, without needing to know the details of HTTP specifically.
