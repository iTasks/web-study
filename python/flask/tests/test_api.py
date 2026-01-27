import pytest
from app import create_app
from app.models import db, User, Task


@pytest.fixture
def app():
    """Create application for testing"""
    app = create_app('testing')
    
    with app.app_context():
        db.create_all()
        yield app
        db.session.remove()
        db.drop_all()


@pytest.fixture
def client(app):
    """Create test client"""
    return app.test_client()


@pytest.fixture
def runner(app):
    """Create CLI runner"""
    return app.test_cli_runner()


def test_app_creation(app):
    """Test app is created correctly"""
    assert app is not None
    assert app.config['TESTING'] is True


def test_health_endpoint(client):
    """Test health check endpoint"""
    response = client.get('/api/v1/health')
    assert response.status_code == 200
    data = response.get_json()
    assert data['status'] == 'healthy'


def test_create_user(client):
    """Test creating a user"""
    response = client.post('/api/v1/users', json={
        'username': 'testuser',
        'email': 'test@example.com'
    })
    assert response.status_code == 201
    data = response.get_json()
    assert data['username'] == 'testuser'
    assert data['email'] == 'test@example.com'


def test_list_users(client):
    """Test listing users"""
    # Create a user first
    client.post('/api/v1/users', json={
        'username': 'user1',
        'email': 'user1@example.com'
    })
    
    response = client.get('/api/v1/users')
    assert response.status_code == 200
    data = response.get_json()
    assert len(data) == 1
    assert data[0]['username'] == 'user1'


def test_create_task(client):
    """Test creating a task"""
    response = client.post('/api/v1/tasks', json={
        'title': 'Test Task',
        'description': 'This is a test task'
    })
    assert response.status_code == 201
    data = response.get_json()
    assert data['title'] == 'Test Task'
    assert data['completed'] is False


def test_list_tasks(client):
    """Test listing tasks"""
    # Create a task first
    client.post('/api/v1/tasks', json={
        'title': 'Task 1',
        'description': 'First task'
    })
    
    response = client.get('/api/v1/tasks')
    assert response.status_code == 200
    data = response.get_json()
    assert len(data) == 1
    assert data[0]['title'] == 'Task 1'


def test_graphql_query(client):
    """Test GraphQL query"""
    # Create a user first via REST API
    client.post('/api/v1/users', json={
        'username': 'graphql_user',
        'email': 'graphql@example.com'
    })
    
    # Query via GraphQL
    query = '{ allUsers { id username email } }'
    response = client.post('/graphql', json={'query': query})
    assert response.status_code == 200
    data = response.get_json()
    assert 'data' in data
    assert 'allUsers' in data['data']
    assert len(data['data']['allUsers']) == 1
