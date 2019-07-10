# ShellKit

Access local shell as well as remote over SSH for Swift NIO applications

### Install using SPM

```swift
.package(url: "https://github.com/Einstore/ShellKit.git", from: "1.0.0")
```

### Usage

#### Connec to a local terminal

```swift
let shell = try Shell(.local, on: eventLoop)
let futureResponse = shell.run(bash: "ls -a").map { output in
   print(output)
   return output
}
```

#### Connect to a remote service

```swift
let shell = try Shell(
    .ssh(
        host: "1292.168.1.2",
        username: "root",
        password: "sup3rS3cr3t"
    ),
    on: eventLoop
)
let futureResponse = shell.run(bash: "ls -a")
```

> Other means of SSH authentication are available!

#### Example

```swift
let eventLoop = EmbeddedEventLoop()
let shell = try Shell(.local, on: eventLoop)
let futureResponse = shell.run(bash: "cd /tmp/ ; pwd").map { output in
   print(output)
   return output
}.flatMapError { error in
   print(error)
   return error.localizedDescription
}
let out: String = try futureResponse.wait()
print(out)
```

### Author

Ondrej Rafaj @rafiki270

### License

MIT; Copyright 2019 - Einstore
