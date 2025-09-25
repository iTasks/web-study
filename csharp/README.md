# C#

## Purpose

This directory contains C# programming language study materials and sample applications. C# is a modern, object-oriented, and type-safe programming language developed by Microsoft as part of the .NET platform.

## Contents

### Pure Language Samples
- `samples/`: Core C# language examples and applications
  - Financial trading applications (FIX protocol implementations)
  - REST client implementations
  - Observer pattern implementations
  - Stock market simulation applications
  - Rate limiting and configuration examples

## Setup Instructions

### Prerequisites
- .NET 6.0 SDK or higher
- Visual Studio, Visual Studio Code, or JetBrains Rider (recommended IDEs)

### Installation
1. **Install .NET SDK**
   ```bash
   # On Ubuntu/Debian
   wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
   sudo dpkg -i packages-microsoft-prod.deb
   sudo apt-get update
   sudo apt-get install -y apt-transport-https
   sudo apt-get install -y dotnet-sdk-6.0
   
   # On macOS with Homebrew
   brew install --cask dotnet
   
   # On Windows, download from https://dotnet.microsoft.com/download
   
   # Verify installation
   dotnet --version
   ```

2. **Create New Project (if needed)**
   ```bash
   # Create console application
   dotnet new console -n MyApp
   
   # Create web API
   dotnet new webapi -n MyWebApi
   
   # Create class library
   dotnet new classlib -n MyLibrary
   ```

### Building and Running

#### For samples directory:
```bash
cd csharp/samples
dotnet restore
dotnet build
dotnet run
```

#### Running specific applications:
```bash
# Build the project
dotnet build RestFixClient.csproj

# Run the application
dotnet run --project RestFixClient.csproj
```

## Usage

### Running Sample Applications
Each sample in the `samples/` directory can be built and run independently:

```bash
# Build and run
cd csharp/samples
dotnet run

# Or build first, then run executable
dotnet build
dotnet bin/Debug/net6.0/RestFixClient.dll
```

### Working with FIX Protocol Examples
The samples include FIX (Financial Information eXchange) protocol implementations:

```bash
cd csharp/samples
dotnet run Program.cs
# This will start the FIX client/server applications
```

## Project Structure

```
csharp/
├── README.md                    # This file
└── samples/                     # Pure C# language examples
    ├── BaseObserver.cs          # Observer pattern base class
    ├── BuyShareController.cs    # Stock buying controller
    ├── FIX*.xml                 # FIX protocol configuration files
    ├── IStockClient.cs          # Stock client interface
    ├── MarketInfo.cs            # Market information model
    ├── MarketInfoController.cs  # Market data controller
    ├── Program.cs               # Main application entry point
    ├── QueryShareController.cs  # Stock query controller
    ├── README.md                # Samples specific documentation
    ├── RestFixClient.csproj     # Project file
    ├── SampleConfigRateLimiter.cs # Rate limiting configuration
    ├── ServiceLoader.cs         # Dependency injection setup
    ├── SimpleAcceptorApp.cs     # FIX acceptor application
    ├── StockClient.cs           # Stock client implementation
    ├── StockInfo.cs             # Stock information model
    ├── StockObserver.cs         # Stock price observer
    ├── TestAcceptor.cs          # Test acceptor for FIX protocol
    ├── TestClient.cs            # Test client implementation
    ├── launchSettings.json      # Launch configuration
    └── stockclient.cfg          # Stock client configuration
```

## Key Learning Topics

- **Core C# Concepts**: Classes, interfaces, generics, LINQ, async/await
- **Object-Oriented Programming**: Inheritance, polymorphism, encapsulation
- **Design Patterns**: Observer, Factory, Singleton, Dependency Injection
- **Financial Programming**: FIX protocol, trading systems, market data processing
- **Web Development**: ASP.NET Core, REST APIs, controllers
- **Testing**: Unit testing with xUnit, NUnit, or MSTest
- **Configuration**: appsettings.json, dependency injection, options pattern

## Contribution Guidelines

1. **Code Style**: Follow C# coding conventions and use EditorConfig
2. **Documentation**: Include XML documentation comments for public APIs
3. **Testing**: Write unit tests using xUnit or similar frameworks
4. **Dependencies**: Use NuGet for package management
5. **Project Structure**: Follow .NET project conventions

### Adding New Samples
1. Place pure C# examples in the `samples/` directory
2. Add framework-specific examples in appropriate subdirectories
3. Update this README with new content descriptions
4. Include proper .csproj files with necessary dependencies

### Code Quality Standards
- Use meaningful class, method, and variable names
- Follow C# naming conventions (PascalCase for public members)
- Handle exceptions appropriately
- Use async/await for asynchronous operations
- Write clean, readable code with appropriate comments

## Resources and References

- [Official .NET Documentation](https://docs.microsoft.com/en-us/dotnet/)
- [C# Programming Guide](https://docs.microsoft.com/en-us/dotnet/csharp/)
- [ASP.NET Core Documentation](https://docs.microsoft.com/en-us/aspnet/core/)
- [NuGet Package Manager](https://www.nuget.org/)
- [C# Coding Conventions](https://docs.microsoft.com/en-us/dotnet/csharp/programming-guide/inside-a-program/coding-conventions)
- [xUnit Testing Framework](https://xunit.net/)
- [FIX Protocol Documentation](https://www.fixtrading.org/)
- [Entity Framework Core](https://docs.microsoft.com/en-us/ef/core/)