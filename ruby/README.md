# Ruby

[← Back to Main](../README.md) | [Web Study Repository](https://github.com/iTasks/web-study)

## Purpose

This directory contains Ruby programming language study materials and sample applications. Ruby is a dynamic, open-source programming language with a focus on simplicity and productivity, featuring an elegant syntax that is natural to read and easy to write.

## Contents

### Pure Language Samples
- **[Samples](samples/)**: Core Ruby language examples and applications
  - Authentication and OTP (One-Time Password) implementations
  - Redis pub/sub messaging demonstrations
  - AWS service integrations
  - Chat application examples

## Setup Instructions

### Prerequisites
- Ruby 3.0 or higher
- Bundler for dependency management
- Git for version control

### Installation
1. **Install Ruby**
   ```bash
   # On Ubuntu/Debian
   sudo apt update
   sudo apt install ruby-full build-essential zlib1g-dev
   
   # On macOS with Homebrew
   brew install ruby
   
   # Using RVM (Ruby Version Manager)
   curl -sSL https://get.rvm.io | bash -s stable
   rvm install ruby-3.1.0
   rvm use ruby-3.1.0 --default
   
   # Verify installation
   ruby --version
   gem --version
   ```

2. **Install Bundler**
   ```bash
   gem install bundler
   ```

### Building and Running

#### For samples directory:
```bash
cd ruby/samples
bundle install  # Install dependencies from Gemfile
ruby main_script.rb
```

## Usage

### Running Sample Applications
Each sample can be run independently:

```bash
# Run authentication example
ruby samples/auth_otp.rb

# Run Redis pub/sub demo
ruby samples/redis_pubsub_demo_chat.rb
```

## Project Structure

```
ruby/
├── README.md                    # This file
└── samples/                     # Pure Ruby language examples
    ├── auth_otp.rb             # OTP authentication implementation
    ├── aws/                    # AWS service examples
    └── redis_pubsub_demo_chat.rb # Redis messaging demo
```

## Key Learning Topics

- **Core Ruby Concepts**: Blocks, iterators, metaprogramming, modules
- **Object-Oriented Programming**: Classes, inheritance, mixins
- **Authentication**: OTP systems, secure token generation
- **Messaging**: Redis pub/sub patterns, real-time communication
- **Cloud Integration**: AWS services, API interactions
- **Testing**: RSpec, Minitest frameworks

## Contribution Guidelines

1. **Code Style**: Follow Ruby style guide conventions
2. **Documentation**: Include YARD documentation for methods
3. **Testing**: Write tests using RSpec or Minitest
4. **Dependencies**: Use Gemfile for dependency management

## Resources and References

- [Official Ruby Documentation](https://ruby-doc.org/)
- [Ruby Style Guide](https://rubystyle.guide/)
- [RubyGems](https://rubygems.org/)
- [Redis Ruby Client](https://github.com/redis/redis-rb)