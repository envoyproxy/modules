# Go Extensions

Go extensions for Envoy are built using the official Envoy Go SDK, providing a Go-native development experience with additional features beyond what's available in other extension mechanisms.

## Overview

The Envoy Go SDK enables writing Envoy extensions in pure Go, offering:
- Familiar Go development patterns
- Access to Go's standard library and ecosystem
- Simplified memory management with garbage collection
- Built-in concurrency primitives

## Features

### Unique Capabilities
- Direct manipulation of headers and body
- Async processing with goroutines
- Access to external services during request processing
- Dynamic configuration updates
- Native Go testing frameworks

### Supported Extension Points
- HTTP filters
- Network filters  
- Access loggers
- Custom protocols

## Getting Started

### Prerequisites
- Go 1.19 or later
- Envoy built with Go support enabled
- Basic understanding of Envoy's filter chain

### Installation

```bash
go get github.com/envoyproxy/go-control-plane
```

## Project Structure

```
go/
├── http/              # HTTP filter implementations
│   ├── auth/         # Authentication filters
│   ├── ratelimit/    # Rate limiting filters
│   └── transform/    # Request/response transformation
├── network/          # Network filter implementations
└── common/           # Shared utilities and helpers
```

## Example HTTP Filter

```go
package main

import (
    "github.com/envoyproxy/envoy/contrib/golang/common/go/api"
)

type myFilter struct {
    api.PassThroughStreamFilter
    config *filterConfig
}

func (f *myFilter) DecodeHeaders(headers api.RequestHeaderMap, endStream bool) api.StatusType {
    // Process request headers
    headers.Set("x-custom-header", "processed-by-go")
    return api.Continue
}

func (f *myFilter) EncodeHeaders(headers api.ResponseHeaderMap, endStream bool) api.StatusType {
    // Process response headers
    return api.Continue
}
```

## Configuration

Go extensions are configured using the `envoy.filters.http.golang` filter:

```yaml
http_filters:
- name: envoy.filters.http.golang
  typed_config:
    "@type": type.googleapis.com/envoy.extensions.filters.http.golang.v3alpha.Config
    library_id: "my-go-filter"
    library_path: "/path/to/filter.so"
    plugin_config:
      "@type": type.googleapis.com/xds.type.v3.TypedStruct
      value:
        key: "value"
```

## Building

### Build Command
```bash
go build -buildmode=c-shared -o filter.so .
```

### Build Flags
- `-buildmode=c-shared`: Required for Envoy integration
- `-trimpath`: Recommended for production builds
- `-ldflags="-s -w"`: Reduce binary size

## Performance Considerations

1. **Garbage Collection**: Be mindful of GC pauses in latency-sensitive paths
2. **Goroutine Usage**: Avoid spawning excessive goroutines per request
3. **Memory Allocation**: Reuse objects where possible
4. **Blocking Operations**: Use async patterns for I/O operations

## Testing

```go
func TestFilter(t *testing.T) {
    // Use the test harness provided by the SDK
    harness := test.NewFilterTestHarness()
    // Configure and run tests
}
```

## Best Practices

1. **Error Handling**: Always handle errors gracefully
2. **Logging**: Use structured logging for debugging
3. **Configuration**: Validate configuration during initialization
4. **Resource Cleanup**: Implement proper cleanup in filter destructors
5. **Panics**: Avoid panics - they will crash the Envoy process

## Examples

See the `examples/` directory for complete working examples including:
- JWT authentication filter
- Request routing based on custom logic  
- Response caching
- Custom metrics collection

## Resources

- [Envoy Go SDK Documentation](https://www.envoyproxy.io/docs/envoy/latest/configuration/http/http_filters/golang_filter)
- [Go Control Plane](https://github.com/envoyproxy/go-control-plane)
- [Example Filters](https://github.com/envoyproxy/envoy/tree/main/examples/golang)
