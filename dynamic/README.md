# Dynamic Modules

Dynamic modules are native extensions for Envoy that are compiled as shared libraries and loaded at runtime. These modules can be written in C++, Rust, or Go.

## Overview

Dynamic modules provide the highest performance and most direct integration with Envoy's core APIs. They are loaded as `.so` (Linux), `.dylib` (macOS), or `.dll` (Windows) files.

## Supported Languages

### C++
- Direct access to Envoy's C++ APIs
- Best performance characteristics
- Requires matching Envoy ABI version

### Rust
- Safe systems programming
- Can use FFI to interact with Envoy's C++ APIs
- Growing ecosystem of Envoy Rust bindings

### Go
- Uses cgo for C++ interop
- Note: For pure Go extensions, consider using the [Go SDK](../go/)

## Building Dynamic Modules

### Prerequisites
- Matching Envoy version and build environment
- Bazel or CMake build system
- C++ toolchain (for C++ modules)
- Rust toolchain (for Rust modules)
- Go toolchain with cgo support (for Go modules)

### Build Process
1. Match your build environment to the target Envoy version
2. Implement the required extension interfaces
3. Build as a shared library
4. Configure Envoy to load the module at runtime

## Module Structure

```
dynamic/
├── filters/           # HTTP/Network filters
├── access_loggers/    # Access logging extensions
├── tracers/          # Distributed tracing implementations
└── stats_sinks/      # Statistics output extensions
```

## Configuration

Dynamic modules are configured in Envoy using the `envoy.extensions.common.dynamic_modules` extension:

```yaml
static_resources:
  listeners:
  - filter_chains:
    - filters:
      - name: envoy.filters.http.dynamic_module
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.http.dynamic_module.v3.DynamicModule
          library_path: "/path/to/module.so"
          library_id: "my_module"
```

## Best Practices

1. **Version Compatibility**: Ensure your module is built against the same Envoy version it will run with
2. **Error Handling**: Implement robust error handling as crashes will take down the entire Envoy process
3. **Resource Management**: Properly manage memory and other resources
4. **Thread Safety**: Ensure your code is thread-safe as Envoy uses multiple worker threads

## Examples

See the `examples/` subdirectory for sample implementations in each language.

## Debugging

- Use `ldd` (Linux) or `otool -L` (macOS) to verify library dependencies
- Enable debug logging in Envoy to see module loading information
- Consider using AddressSanitizer or other debugging tools during development
