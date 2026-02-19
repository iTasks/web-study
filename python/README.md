# Python

[← Back to Main](../README.md) | [Web Study Repository](https://github.com/iTasks/web-study)

## Purpose

This directory contains Python programming language study materials, sample applications, and framework implementations. Python is a high-level, interpreted programming language known for its simplicity, readability, and extensive ecosystem of libraries and frameworks.

## Contents

### Frameworks
- **[Django](django/)**: High-level Python web framework for rapid development
  - Production-ready Django project with REST API, Docker support, and best practices
- **[Flask](flask/)**: Lightweight WSGI web application framework
  - Flask web application examples and utilities

### Pure Language Samples
- **[Samples](samples/)**: Core Python language examples and applications
  - Django web applications and models
  - Lambda function implementations
  - Server implementations
  - **Load Testing**: [Locust load testing samples](samples/load-testing/locust/) for concurrent user testing
  - File I/O and data processing utilities
  - Web scraping and automation scripts

## Setup Instructions

### Prerequisites
- Python 3.8 or higher
- pip (Python package installer)
- Virtual environment tool (venv or virtualenv)

### Installation
1. **Install Python**
   ```bash
   # On Ubuntu/Debian
   sudo apt update
   sudo apt install python3 python3-pip python3-venv
   
   # On macOS with Homebrew
   brew install python3
   
   # On Windows, download from python.org
   
   # Verify installation
   python3 --version
   pip3 --version
   ```

2. **Create Virtual Environment**
   ```bash
   cd python
   python3 -m venv venv
   
   # Activate virtual environment
   # On Linux/macOS:
   source venv/bin/activate
   
   # On Windows:
   venv\Scripts\activate
   ```

3. **Install Dependencies**
   ```bash
   # For Django framework
   cd django
   pip install -r requirements.txt
   
   # For Flask framework
   cd flask
   pip install flask
   
   # For web scraping
   pip install requests beautifulsoup4
   ```

### Building and Running

#### For Django framework:
```bash
cd python/django
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python3 manage.py migrate
python3 manage.py runserver
```

#### For samples directory:
```bash
cd python/samples
python3 manage.py runserver  # For Django applications
python3 main.py             # For standalone scripts
```

#### For Flask framework examples:
```bash
cd python/flask
export FLASK_APP=app.py
flask run
```

## Usage

### Running Sample Applications
Each sample in the `samples/` directory can be run independently:

```bash
# Run a specific Python file
python3 samples/first.py

# Run Django development server
cd samples
python3 manage.py runserver
```

### Working with Flask Framework Examples
Navigate to the Flask project directory:

```bash
cd python/flask
python3 app.py
# Or use Flask CLI
export FLASK_APP=app.py
flask run --debug
```

## Project Structure

```
python/
├── README.md                 # This file
├── django/                   # Django framework (production-ready)
│   ├── config/              # Project configuration
│   ├── core/                # Main application
│   ├── templates/           # HTML templates
│   ├── static/              # Static files
│   ├── requirements.txt     # Python dependencies
│   ├── Dockerfile           # Docker configuration
│   ├── docker-compose.yml   # Multi-container setup
│   └── README.md            # Django-specific documentation
├── samples/                  # Pure Python language examples
│   ├── __init__.py          # Python package marker
│   ├── admin.py             # Django admin configuration
│   ├── apps.py              # Django app configuration
│   ├── brython_startreck.html # Brython JavaScript bridge example
│   ├── db.sqlite3           # Sample SQLite database
│   ├── first.py             # Basic Python examples
│   ├── lambda/              # AWS Lambda function examples
│   ├── main.py              # Main application entry point
│   ├── manage.py            # Django management script
│   ├── minimal_server.py    # Simple HTTP server
│   ├── models.py            # Django data models
│   ├── tests.py             # Unit tests
│   └── views.py             # Django views
└── flask/                   # Flask framework examples
    └── [Flask applications] # Flask-specific implementations
```

## Key Learning Topics

- **Core Python Concepts**: Data types, control structures, functions, classes
- **Web Development**: Django framework, Flask microframework, REST APIs
- **Data Processing**: File I/O, JSON/XML parsing, data manipulation
- **Database Integration**: SQLite, ORM patterns, database migrations
- **Testing**: Unit testing, test-driven development
- **Cloud Integration**: AWS Lambda functions, serverless architecture
- **Web Scraping**: HTTP requests, HTML parsing, automation

## Contribution Guidelines

1. **Code Style**: Follow PEP 8 Python style guidelines
2. **Documentation**: Include docstrings for functions and classes
3. **Testing**: Write unit tests using unittest or pytest
4. **Dependencies**: Use requirements.txt for dependency management
5. **Virtual Environments**: Always use virtual environments for projects

### Adding New Samples
1. Place pure Python examples in the `samples/` directory
2. Add framework-specific examples in appropriate subdirectories under their framework folder
3. Update this README with new content descriptions
4. Include requirements.txt for any external dependencies

### Code Quality Standards
- Use meaningful variable and function names
- Include type hints where appropriate
- Follow the Zen of Python principles
- Write clean, readable code with appropriate comments
- Handle exceptions properly

## Resources and References

- [Official Python Documentation](https://docs.python.org/)
- [Django Documentation](https://docs.djangoproject.com/)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [PEP 8 Style Guide](https://pep8.org/)
- [Python Package Index (PyPI)](https://pypi.org/)
- [Real Python Tutorials](https://realpython.com/)
- [Python.org Tutorial](https://docs.python.org/3/tutorial/)

### Additional Learning Resources
- [Python AI Course](https://github.com/smaruf/python-ai-course) - Comprehensive Python AI/ML course materials
- [Python Study](https://github.com/smaruf/python-study) - Additional Python study materials and examples