# sigma_rb
Ruby wrapper around C bindings for ErgoLib from [Sigma-Rust](https://github.com/ergoplatform/sigma-rust)

# Installation
This project wraps the C bindings of Sigma-Rust and so they are required for using this gem. As the Sigma-Rust API changes over time, gem versions are tied to specific Sigma-Rust versions.

| Sigma_rb Version | Sigma-Rust Version |
| ---------------- | -------------------|
| 0.1.3 - 0.1.4            | 0.16.0             |


## Build ErgoLib Dependencies
Checkout the supported Sigma-Rust version on the [releases](https://github.com/ergoplatform/sigma-rust/releases) page .

### Build the ergo-lib-c bindings
I will provide instructions below but it may be worth reading over the [directions in Sigma-Rust too](https://github.com/ergoplatform/sigma-rust/tree/develop/bindings/ergo-lib-c)  

Sigma-Rust uses Rust to generate these C bindings and so you will need Rust. I recommend downloading the nightly version of Rust as you will need nightly Rust for the next step.   

After checking out the proper Sigma-Rust and starting at it's root directory:
```
cd bindings/ergo-lib-c
cargo build --release -p ergo-lib-c
```

This will build a release version of `libergo.a` located at `target/release/libergo.a` from the root directory.  You will need to copy/move this to a C LIBRARY search path on your system. For my system I can use `/usr/local/lib` . This usually depends on OS.   

So I did this to copy `libergo.a` to `/usr/local/lib` :  
```
sudo cp ../../target/release/libergo.a /usr/local/lib/
```  

### Build ergo-lib-c header file
While still in the `bindings/ergo-lib_c` directory you can generate the header file with:
```
cbindgen --config cbindgen.toml --crate ergo-lib-c --output h/ergo_lib.h
```

You will need to copy/move this header to a C INCLUDE search path. On my system I can use `/usr/local/include` . So I ran the following command to copy the header:  
```  
sudo cp h/ergo_lib.h /usr/local/include/
```

## Add to Gemfile
Once you have `libergo.a` and `ergo_lib.h` downloaded and placed in locations your C compiler can find you should be able to to install the gem.  

In Gemfile
```
gem 'sigma_rb', '0.1.3'
```

Run bundle to install
```
bundle
```

After a successful install you can use it by requiring `sigma`  
```
require 'sigma'

puts Sigma::BoxValue.units_per_ergo
```

# Examples
Check out `tests/sigma` for usage examples. The transaction tests are probably the most involved, located at [tests/sigma/transaction_test.rb](https://github.com/thedlop/sigma_rb/blob/master/tests/sigma/transaction_test.rb).  

# Documentation
Generated documentation can be viewed on [RubyDoc](https://www.rubydoc.info/gems/sigma_rb). 

# Thank You
Thank you to the Ergo Development community for consistent words of encouragement. Big thanks to Sigma-Rust maintainers for providing the C bindings which made this possible. Thank you to the iOS bindings developers as it was a constant reference for this work.
