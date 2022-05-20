# sigma_rb
Ruby wrapper around C bindings for ErgoLib from https://github.com/ergoplatform/sigma-rust

# Installation

### Build ErgoLib Dependencies
Checkout the supported SigmaRust version at https://github.com/ergoplatform/sigma-rust/releases/tag/ergo-lib-v0.16.0 .

Note: 0.1.3 supports 0.16.0 only  
Note: Going forward all releases will update the link above with the proper SigmaRust release version.  

#### Build the ergo-lib-c bindings
I will provide instructions below but it may be worth reading over the directions in SigmaRust too: https://github.com/ergoplatform/sigma-rust/tree/develop/bindings/ergo-lib-c  

After checking out the proper Sigma-Rust and starting at it's root directory.  
```
cd bindings/ergo-lib-c
cargo build --release -p ergo-lib-c
```
Note: You need Rust to build. 

This will build a release version of `libergo.a` located at `target/release/libergo.a` from the root directory.  You will need to copy/move this to a C LIBRARY path on your system. For my system I can use `/usr/local/lib` . This usually depends on OS.   

So I did this to copy `libergo.a` to `/usr/local/lib`. I had to use sudo because of root permissions on the `/usr/local/lib` directory.  
`sudo cp ../../target/release/libergo.a /usr/local/lib/`


### Build ErgoLib header file
TODO   
### Add to Gemfile
TODO  
# Examples
Check out `tests/sigma` for usage examples. 

# Thank You
Thank you to the Ergo Development community for consistent words of encouragement. Big thanks to Sigma-Rust maintainers for providing the C bindings which made this so much easier. Thank you to the iOS bindings developers as it was a constant reference for this work.


### TODO
- [x] Package up into gem
- [ ] Add installation instructions and target platforms to README
- [ ] Add pointers to example usage to README
- [ ] Add YARD documentation so docs can be generated and viewed at https://www.rubydoc.info/
