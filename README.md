<p align="center">
  <strong><em><code>resource</code></em></strong><br><small><code>0.3.2</code></small>
</p>

This package contains miscellaneous definitions useful for server applications. For the most part, the modules in this package refrain from vending complex implementations, as they only vend types intended to serve as a common medium-of-exchange between different downstream components.

Downstream consumers of this package are expected to provide additional functionality as extensions on the types in this package, as needed.

*   `MIME` 

    Vends a single type `MIME`, which contains `content-type` definitions.

*   `Resources`

    Vends a single type `Resource`, which wraps a `MIME` type and a backing storage payload ([`String`](https://swiftinit.org/reference/swift/string) or [`[UInt8]`](https://swiftinit.org/reference/swift/array))

*   `WebSemantics`

    Contains type definitions useful for applications that implement an HTTP or HTTP-like API, without needing to know the details of HTTP specifically.
