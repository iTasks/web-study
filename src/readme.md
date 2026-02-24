# src — Legacy Structure

[← Back to Main](../README.md) | [Web Study Repository](https://github.com/iTasks/web-study)

## Legacy Structure Notice

**⚠️ This directory contains the legacy structure and is maintained for backward compatibility.**

**For new content, please use the language-first structure in the root directory:**
- `java/` - Java language and frameworks
- `python/` - Python language and frameworks  
- `javascript/` - JavaScript/TypeScript and frameworks
- `go/` - Go language and frameworks
- `csharp/` - C# language examples
- `ruby/` - Ruby language examples
- `rust/` - Rust language examples
- `scala/` - Scala language examples
- `groovy/` - Groovy language examples
- `lisp/` - Lisp language examples
- `teavm/` - TeaVM examples

## Current Contents:
```
src
├── aws              # AWS services and tools
├── cucumber         # Testing framework examples
├── gcf              # Google Cloud Functions
├── kubernate        # Kubernetes examples
└── SharedResource.java
```

## Migration Status

Programming language directories have been moved to the root level:
- ✅ `src/java/` → `java/`
- ✅ `src/python/` → `python/`
- ✅ `src/nodejs/` + `src/react-native/` → `javascript/`
- ✅ `src/go/` → `go/`
- ✅ `src/c#/` → `csharp/`
- ✅ `src/ruby/` → `ruby/`
- ✅ `src/rust/` → `rust/`
- ✅ `src/scala/` → `scala/`
- ✅ `src/groovy/` → `groovy/`
- ✅ `src/lisp/` → `lisp/`
- ✅ `src/teavm/` → `teavm/`

Cloud services and infrastructure tools remain in this directory for now.
