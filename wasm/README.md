# WebAssembly (Wasm) Modules

WebAssembly modules provide a cross-platform, sandboxed environment for extending Envoy. Write your extensions in C++, Rust, AssemblyScript, or other languages that compile to Wasm.

## Overview

Wasm modules offer several advantages:
- **Portability**: Run the same binary across different platforms and Envoy builds
- **Isolation**: Sandboxed execution prevents crashes from affecting Envoy
- **Language Flexibility**: Use any language that compiles to Wasm
- **Dynamic Loading**: Load and update modules without restarting Envoy

## Supported Languages

### Rust
- Most mature ecosystem for Envoy Wasm development
- Uses `proxy-wasm-rust-sdk`
- Excellent memory safety guarantees

### C++
- Uses `proxy-wasm-cpp-sdk`  
- Familiar for developers with Envoy experience
- Direct mapping to proxy-wasm ABI

### AssemblyScript
- TypeScript-like syntax
- Quick development cycle
- Good for simpler filters

### TinyGo
- Go syntax with Wasm compilation
- Limited standard library support
- Smaller binary size than regular Go

## Architecture

Wasm modules interact with Envoy through the proxy-wasm ABI:

```
┌─────────────────┐
│   Envoy Host    │
├─────────────────┤
│ Proxy-Wasm ABI  │
├─────────────────┤
│   Wasm Module   │
│  (Your Filter)  │
└─────────────────┘
```

## Getting Started

### Prerequisites
- Language-specific toolchain (Rust, C++, etc.)
- `wasm-opt` for optimization (optional but recommended)
- Envoy with Wasm support enabled

### Quick Start (Rust)

1. Install Rust and wasm32 target:
```bash
rustup target add wasm32-wasi
```

2. Create a new project:
```bash
cargo new --lib my-filter
cd my-filter
```

3. Add dependencies to `Cargo.toml`:
```toml
[dependencies]
proxy-wasm = "0.2"
log = "0.4"

[lib]
crate-type = ["cdylib"]
```

4. Implement your filter:
```rust
use proxy_wasm::traits::*;
use proxy_wasm::types::*;

#[no_mangle]
pub fn _start() {
    proxy_wasm::set_log_level(LogLevel::Info);
    proxy_wasm::set_root_context(|_| -> Box<dyn RootContext> {
        Box::new(MyRootContext)
    });
}
```

## Module Structure

```
wasm/
├── filters/           # HTTP/Network filters
│   ├── auth/         # Authentication modules
│   ├── ratelimit/    # Rate limiting modules
│   └── transform/    # Transform modules
├── examples/         # Example implementations
└── tools/           # Build and test utilities
```

## Building

### Rust
```bash
cargo build --target wasm32-wasi --release
wasm-opt -Oz target/wasm32-wasi/release/my_filter.wasm -o my_filter.optimized.wasm
```

### C++
```bash
em++ -O3 -s WASM=1 -s EXPORTED_FUNCTIONS=['_start'] \
  --no-entry -o my_filter.wasm my_filter.cpp
```

## Configuration

Wasm modules are configured using the `envoy.filters.http.wasm` filter:

```yaml
http_filters:
- name: envoy.filters.http.wasm
  typed_config:
    "@type": type.googleapis.com/envoy.extensions.filters.http.wasm.v3.Wasm
    config:
      root_id: "my_filter"
      vm_config:
        vm_id: "my_filter_vm"
        runtime: "envoy.wasm.runtime.v8"
        code:
          local:
            filename: "/path/to/my_filter.wasm"
      configuration:
        "@type": type.googleapis.com/google.protobuf.StringValue
        value: |
          {
            "key": "value"
          }
```

## Performance Optimization

1. **Binary Size**: Use `wasm-opt` with `-Oz` flag
2. **Memory Usage**: Implement efficient data structures
3. **Host Calls**: Minimize calls across the Wasm boundary
4. **Compilation**: Use release builds with optimizations

## Debugging

### Logging
```rust
log::info!("Processing request: {:?}", path);
```

### Local Testing
Use `proxy-wasm-test-framework` for unit testing:
```rust
#[test]
fn test_request_headers() {
    let mut filter = MyHttpContext::new();
    filter.on_http_request_headers(1, false);
    // Assert expected behavior
}
```

## Best Practices

1. **Error Handling**: Always handle potential failures gracefully
2. **Configuration Validation**: Validate JSON/config during initialization
3. **Resource Management**: Clean up resources in `on_done()` callbacks
4. **State Management**: Use context effectively for per-request state
5. **Versioning**: Include version info in your module for debugging

## Common Patterns

### Authentication Check
```rust
fn on_http_request_headers(&mut self, _: usize, _: bool) -> Action {
    match self.get_http_request_header("authorization") {
        Some(token) => {
            if self.validate_token(&token) {
                Action::Continue
            } else {
                self.send_http_response(401, vec![], Some(b"Unauthorized"));
                Action::Pause
            }
        }
        None => {
            self.send_http_response(401, vec![], Some(b"Missing Authorization"));
            Action::Pause
        }
    }
}
```

## Examples

Complete examples available in `examples/`:
- Basic HTTP header manipulation
- JWT validation
- Rate limiting with shared state
- Request/response transformation
- External service callouts

## Resources

- [Proxy-Wasm Specification](https://github.com/proxy-wasm/spec)
- [Rust SDK](https://github.com/proxy-wasm/proxy-wasm-rust-sdk)
- [C++ SDK](https://github.com/proxy-wasm/proxy-wasm-cpp-sdk)
- [WebAssembly Hub](https://webassemblyhub.io/)
