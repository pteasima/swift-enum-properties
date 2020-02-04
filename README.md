# 🤝 swift-enum-properties

[![Swift 5.1](https://img.shields.io/badge/swift-5.1-ED523F.svg?style=flat)](https://swift.org/download/)
[![Build Status](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Factions-badge.atrox.dev%2Fpointfreeco%2Fswift-enum-properties%2Fbadge&style=flat)](https://actions-badge.atrox.dev/pointfreeco/swift-enum-properties/goto)
[![@pointfreeco](https://img.shields.io/badge/contact-@pointfreeco-5AA9E7.svg?style=flat)](https://twitter.com/pointfreeco)

Struct and enum data access in harmony.

## Motivation

In Swift, struct data access is far more ergonomic than enum data access by default.

A struct field can be accessed in less than a single line using expressive dot-syntax:

``` swift
user.name
```

An enum's associated value requires as many as _seven_ lines to bring it into the current scope:

``` swift
let optionalValue: String?
if case let .success(value) = result {
  optionalValue = value
} else {
  optionalValue = nil
}
optionalValue
```

That's a lot of boilerplate getting in the way of what we care about: getting at the value of a `success`.

This difference is also noticeable when working with higher-order functions like `map` and `compactMap`. 

An array of struct values can be transformed succinctly in a single expression:

``` swift
users.map { $0.name }
```

But transforming an array of enum values requires a version of the following incantation:

``` swift
results.compactMap { result -> String? in
  guard case let .success(value) = result else { return nil }
  return value
}
```

The imperative nature of unwrapping an associated value spills over multiple lines, which requires us to give Swift an explicit return type, name our closure argument, and provide _two_ explicit `return`s.

## Solution

We can recover all of the ergonomics of struct data access for enums by defining "enum properties": computed properties that optionally return a value when the case matches:

``` swift
extension Result {
  var success: Success? {
    guard case let .success(value) = self else { return nil }
    return value
  }
  
  var failure: Failure? {
    guard case let .failure(value) = self else { return nil }
    return value
  }
}
```

This is work we are used to doing in an ad hoc way throughout our code bases, but we can centralize it in a computed property and are free to access underlying data in a succinct fashion:

``` swift
// Optionally-chain into a successful result.
result.success?.count

// Collect a bunch of successful values.
results.compactMap { $0.success }
```

By defining a computed property, we bridge another gap: our enums now have key paths!

``` swift
\Result<String, Error>.success
// KeyPath<Result<String, Error>, String?>
```

Despite these benefits, defining enum properties from scratch is a tall ask. Instead, enter `generate-enum-properties`.

## Usage

```
usage: generate-enum-properties [--help|-h] [--dry-run|-n] [<file>...]

    -h, --help
        Print this message.

    -n, --dry-run
        Don't update files in place. Print to stdout instead.

    --version
        Print the version.
```

Once [installed](#installation), you can invoke `generate-enum-properties` from the command line and feed it any number of Swift source files:

``` bash
# Insert enum properties into every enum declaration. 
$ generate-enum-properties **/*.swift
```

It will automatically generate and inline enum properties for every enum with associated values. Please note that it updates source files _in place_. Use version control to avoid accidental insertions! You can use the `--dry-run` flag to preview the updated source.

``` bash
$ generate-enum-properties --dry-run **/*.swift
```

Without the `--dry-run` flag, the following source file as input:

``` swift
enum Validated<Valid, Invalid> {
  case valid(Valid)
  case invalid(Invalid)
}
```

Will have its contents replaced with the following output:

``` swift
enum Validated<Valid, Invalid> {
  case valid(Valid)
  case invalid(Invalid)

  var valid: Valid? {
    get {
      guard case let .valid(value) = self else { return nil }
      return value
    }
    set {
      guard case .valid = self, let newValue = newValue else { return }
      self = .valid(newValue)
    }
  }
}
```

Note that both a setter and getter are generated, which means you can also optionally dive into enum data and update a part of it.

``` swift
validatedUser.valid?.name = "Blob"
```

Running `generate-enum-properties` is idempotent: it will only insert properties that aren't already defined in the enum declaration. One caveat:

> ⚠️ If you have defined an enum property of the same name in an extension, it will collide with the one generated by `generate-enum-properties`.

Now you may be wondering: _why not generate extensions that can be hidden away in another file?_ Unfortunately, this is problematic for enums that depend on types that need to be imported and types that are nested. By inlining enum properties, we can ensure that every associated value's type is in scope.

## Xcode Code Snippets

If you or your team are not yet ready to use code generation in your code base, don't let that stop you from using enum properties! They are too useful to give up. Instead you can use our Xcode code snippet with a little bit of manual work to allow easy creation of enum properties in your code base:

![Sep-25-2019 09-45-56](https://user-images.githubusercontent.com/135203/65606830-8829fa00-df79-11e9-86f2-d3b3ff5f39fe.gif)

To install just add all of the code snippets in the [.xcode](.xcode) directory to the following directory:

```
~/Library/Developer/Xcode/UserData/CodeSnippets/
```

and restart Xcode.

Or run the following command from the root of the repository:

``` bash
$ make snippets
```

For more information about Xcode code snippets check out this informative NSHipster [article](https://nshipster.com/xcode-snippets/).

## Installation

### Homebrew

You can install `generate-enum-properties` using our custom tap:

``` bash
$ brew install pointfreeco/swift/generate-enum-properties
$ generate-enum-properties
```

### SwiftPM

#### As a dependency

If you want to use `generate-enum-properties` in a project that uses [SwiftPM](https://swift.org/package-manager/), it's as simple as adding a `dependencies` clause to your `Package.swift`:

``` swift
dependencies: [
  .package(url: "https://github.com/pointfreeco/swift-enum-properties.git", from: "0.1.0")
]
```

And invoking `swift run` from the command line:

``` swift
$ swift run generate-enum-properties
```

#### As a CLI

If you want to run `generate-enum-properties` using [SwiftPM](https://swift.org/package-manager/), it's as simple as cloning the repository and invoking `swift run`:

``` bash
$ git clone https://github.com/pointfreeco/swift-enum-properties.git
$ cd swift-enum-properties
$ swift run generate-enum-properties
```

### Make

If you want to build and install `generate-enum-properties` yourself:

``` bash
$ git clone https://github.com/pointfreeco/swift-enum-properties.git
$ cd swift-enum-properties
$ make install
```

### Mint

If you want to install with [Mint](https://github.com/yonaskolb/mint):

``` bash
$ mint install pointfreeco/swift-enum-properties
```

## Interested in learning more?

These concepts (and more) are explored thoroughly in [Point-Free](https://www.pointfree.co), a video series exploring functional programming and Swift hosted by [Brandon Williams](https://github.com/mbrandonw) and [Stephen Celis](https://github.com/stephencelis).

The design of this library was explored in the following [Point-Free](https://www.pointfree.co) episodes:

- [Episode 52](https://www.pointfree.co/episodes/ep52-enum-properties): Enum Properties
- [Episode 53](https://www.pointfree.co/episodes/ep53-swift-syntax-enum-properties): Swift Syntax Enum Properties
- [Episode 54](https://www.pointfree.co/episodes/ep54-advanced-swift-syntax-enum-properties): Advanced Swift Syntax Enum Properties
- [Episode 55](https://www.pointfree.co/episodes/ep55-swift-syntax-command-line-tool): Swift Syntax Command Line Tool 🆓

<a href="https://www.pointfree.co/episodes/ep52-enum-properties">
<img alt="video poster image" src="https://d1hf1soyumxcgv.cloudfront.net/0052-enum-properties/poster.jpg" width="480">
</a>

## License

All modules are released under the MIT license. See [LICENSE](LICENSE.md) for details.
