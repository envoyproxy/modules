# Envoy Modules

This repository hosts buildable out-of-tree extensions for [Envoy Proxy](https://www.envoyproxy.io/). These modules extend Envoy's functionality without requiring modifications to the core Envoy codebase.

## Module Types

Envoy supports three primary approaches for building extensions:

### [Dynamic Modules](./dynamic/)
Native extensions written in C++, Rust, or Go that are compiled as shared libraries and loaded dynamically at runtime.

### [Go Extensions](./go/)
Extensions written using the Envoy Go SDK, providing additional features and a Go-native development experience.

### [WebAssembly (Wasm) Modules](./wasm/)
Cross-platform extensions compiled from C++, Rust, or other languages to WebAssembly bytecode.

## Getting Started

Each module type has its own development workflow and requirements. Please refer to the README in each directory for specific instructions:

- [Dynamic Modules Documentation](./dynamic/README.md)
- [Go Extensions Documentation](./go/README.md)
- [Wasm Modules Documentation](./wasm/README.md)

## Contributing

Contributions are welcome! Please ensure your modules:
- Follow Envoy's extension best practices
- Include comprehensive documentation
- Provide example configurations
- Include tests where applicable

## License

This repository is licensed under the same terms as Envoy Proxy. See [LICENSE](./LICENSE) for details.
