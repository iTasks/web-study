# Django Framework - Production Ready Project

[← Back to Python](../README.md) | [Main README](../../README.md)

## Purpose

This directory contains a fully production-ready Django project implementation. Django is a high-level Python web framework that encourages rapid development and clean, pragmatic design. This project demonstrates best practices for deploying Django applications in production environments.

## Features

### Core Features
- **Environment-based Configuration**: Using python-decouple for managing environment variables
- **REST API**: Full-featured REST API using Django REST Framework
- **Database Support**: PostgreSQL for production, SQLite for development
- **Static Files Management**: Whitenoise for efficient static file serving
- **Security**: Production-ready security settings (HTTPS, HSTS, XSS protection)
- **CORS Support**: Cross-Origin Resource Sharing enabled
- **Admin Interface**: Customized Django admin panel
- **Logging**: Comprehensive logging configuration
- **Docker Support**: Full containerization with Docker Compose
- **Production Server**: Gunicorn WSGI server with Nginx reverse proxy

### Project Structure
```
django/
├── config/                 # Project configuration
│   ├── __init__.py
│   ├── settings.py        # Main settings (production-ready)
│   ├── urls.py            # URL routing
│   ├── asgi.py            # ASGI config
│   └── wsgi.py            # WSGI config
├── core/                   # Main application
│   ├── models.py          # Database models (Task, Category)
│   ├── views.py           # Views and ViewSets
│   ├── serializers.py     # REST API serializers
│   ├── admin.py           # Admin customization
│   ├── urls.py            # App-specific URLs
│   └── migrations/        # Database migrations
├── templates/              # HTML templates
│   └── core/
│       ├── base.html
│       ├── home.html
│       └── task_list.html
├── static/                 # Static files (CSS, JS, images)
├── staticfiles/           # Collected static files
├── media/                  # User-uploaded files
├── logs/                   # Application logs
├── manage.py              # Django management script
├── requirements.txt       # Python dependencies
├── .env.example           # Environment variables template
├── Dockerfile             # Docker container definition
├── docker-compose.yml     # Multi-container Docker app
├── nginx.conf             # Nginx configuration
└── README.md              # This file
```

## Prerequisites

- Python 3.8 or higher
- pip package manager
- PostgreSQL (for production)
- Docker & Docker Compose (optional, for containerized deployment)

## Installation

### Method 1: Local Development Setup

1. **Clone the repository and navigate to the Django project**
   ```bash
   cd python/django
   ```

2. **Create and activate virtual environment**
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env file with your configuration
   ```

5. **Run database migrations**
   ```bash
   python manage.py migrate
   ```

6. **Create a superuser**
   ```bash
   python manage.py createsuperuser
   ```

7. **Collect static files**
   ```bash
   python manage.py collectstatic
   ```

8. **Run development server**
   ```bash
   python manage.py runserver
   ```

   Visit `http://127.0.0.1:8000` in your browser.

### Method 2: Docker Deployment

1. **Navigate to the Django project**
   ```bash
   cd python/django
   ```

2. **Build and start containers**
   ```bash
   docker-compose up -d --build
   ```

3. **Create superuser (in container)**
   ```bash
   docker-compose exec web python manage.py createsuperuser
   ```

4. **Access the application**
   - Web Application: `http://localhost`
   - Django Admin: `http://localhost/admin`
   - API: `http://localhost/api`

5. **Stop containers**
   ```bash
   docker-compose down
   ```

## Configuration

### Environment Variables

Create a `.env` file based on `.env.example`:

```bash
# Django Configuration
SECRET_KEY=your-secret-key-here-change-in-production
DEBUG=False
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com

# Database Configuration (PostgreSQL)
USE_POSTGRES=True
DB_NAME=django_db
DB_USER=postgres
DB_PASSWORD=your-secure-password
DB_HOST=localhost
DB_PORT=5432

# CORS Configuration
CORS_ALLOWED_ORIGINS=https://yourdomain.com

# Security Settings
SECURE_SSL_REDIRECT=True

# Logging
LOG_LEVEL=INFO
```

### Database Configuration

**Development (SQLite)**
```python
USE_POSTGRES=False
```

**Production (PostgreSQL)**
```python
USE_POSTGRES=True
DB_NAME=django_db
DB_USER=postgres
DB_PASSWORD=your-secure-password
DB_HOST=localhost
DB_PORT=5432
```

## Running the Application

### Development Mode
```bash
python manage.py runserver
```

### Production Mode with Gunicorn
```bash
gunicorn --bind 0.0.0.0:8000 --workers 3 config.wsgi:application
```

### With Nginx (Production)
1. Configure nginx with the provided `nginx.conf`
2. Start Gunicorn on port 8000
3. Nginx will proxy requests to Gunicorn

## API Endpoints

### API Root
- `GET /api/` - API information and available endpoints

### Tasks
- `GET /api/tasks/` - List all tasks
- `POST /api/tasks/` - Create a new task
- `GET /api/tasks/{id}/` - Retrieve a specific task
- `PUT /api/tasks/{id}/` - Update a task
- `PATCH /api/tasks/{id}/` - Partially update a task
- `DELETE /api/tasks/{id}/` - Delete a task

### Categories
- `GET /api/categories/` - List all categories
- `POST /api/categories/` - Create a new category
- `GET /api/categories/{id}/` - Retrieve a specific category
- `PUT /api/categories/{id}/` - Update a category
- `PATCH /api/categories/{id}/` - Partially update a category
- `DELETE /api/categories/{id}/` - Delete a category

### Authentication
- `GET /api-auth/login/` - API login page
- `GET /api-auth/logout/` - API logout

## Testing

### Run all tests
```bash
python manage.py test
```

### Run tests with coverage
```bash
pip install coverage
coverage run --source='.' manage.py test
coverage report
```

### Run specific app tests
```bash
python manage.py test core
```

## Database Management

### Create migrations
```bash
python manage.py makemigrations
```

### Apply migrations
```bash
python manage.py migrate
```

### Reset database
```bash
python manage.py flush
```

### Database shell
```bash
python manage.py dbshell
```

## Admin Interface

Access the Django admin panel at `/admin/` after creating a superuser:

```bash
python manage.py createsuperuser
```

Features:
- User management
- Task management with filters and search
- Category management
- Customized list displays and fieldsets

## Production Deployment

### Security Checklist

1. **Change SECRET_KEY**: Generate a new secret key
   ```bash
   python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'
   ```

2. **Set DEBUG=False**: Never run with DEBUG=True in production

3. **Configure ALLOWED_HOSTS**: Add your domain names

4. **Use HTTPS**: Set SECURE_SSL_REDIRECT=True

5. **Database**: Use PostgreSQL, not SQLite

6. **Static Files**: Run `collectstatic` and serve with Nginx/Whitenoise

7. **Environment Variables**: Use `.env` file, never commit secrets

### Deployment Steps

1. Set up PostgreSQL database
2. Configure environment variables
3. Collect static files: `python manage.py collectstatic`
4. Run migrations: `python manage.py migrate`
5. Create superuser: `python manage.py createsuperuser`
6. Start Gunicorn with systemd or supervisor
7. Configure Nginx as reverse proxy
8. Set up SSL certificate (Let's Encrypt)

### Example Systemd Service

Create `/etc/systemd/system/django.service`:

```ini
[Unit]
Description=Django Application
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory=/path/to/django
Environment="PATH=/path/to/venv/bin"
ExecStart=/path/to/venv/bin/gunicorn --workers 3 --bind unix:/run/gunicorn.sock config.wsgi:application

[Install]
WantedBy=multi-user.target
```

## Key Dependencies

- **Django 6.0.1**: Web framework
- **djangorestframework**: REST API toolkit
- **django-cors-headers**: CORS support
- **python-decouple**: Environment variable management
- **psycopg2-binary**: PostgreSQL adapter
- **gunicorn**: WSGI HTTP server
- **whitenoise**: Static file serving

## Project Models

### Task Model
```python
- title: CharField(max_length=200)
- description: TextField(blank=True)
- status: CharField (choices: todo, in_progress, done)
- created_by: ForeignKey(User)
- created_at: DateTimeField(auto_now_add=True)
- updated_at: DateTimeField(auto_now=True)
- due_date: DateField(null=True, blank=True)
```

### Category Model
```python
- name: CharField(max_length=100, unique=True)
- description: TextField(blank=True)
- created_at: DateTimeField(auto_now_add=True)
```

## Learning Topics

- Django project structure and configuration
- Environment-based settings management
- Database models and migrations
- Django ORM and querysets
- Class-based views and ViewSets
- Django REST Framework
- Template rendering with Django template language
- Django admin customization
- Static files and media handling
- Security best practices
- Production deployment with Docker
- WSGI servers (Gunicorn)
- Reverse proxy with Nginx

## Troubleshooting

### Static files not loading
```bash
python manage.py collectstatic --clear
python manage.py collectstatic
```

### Database connection errors
- Check PostgreSQL is running
- Verify database credentials in `.env`
- Ensure database exists: `createdb django_db`

### Migration errors
```bash
python manage.py migrate --run-syncdb
```

### Port already in use
```bash
# Find process using port 8000
lsof -i :8000
# Kill the process
kill -9 <PID>
```

## Resources

- [Django Documentation](https://docs.djangoproject.com/)
- [Django REST Framework](https://www.django-rest-framework.org/)
- [Django Deployment Checklist](https://docs.djangoproject.com/en/stable/howto/deployment/checklist/)
- [Gunicorn Documentation](https://docs.gunicorn.org/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Docker Documentation](https://docs.docker.com/)

## License

This project is part of the web-study repository and is intended for educational purposes.

## Contributing

Contributions are welcome! Please follow the existing code style and patterns.
