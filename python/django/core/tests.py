from django.test import TestCase, Client
from django.contrib.auth.models import User
from django.urls import reverse
from rest_framework.test import APITestCase
from rest_framework import status
from .models import Task, Category


class TaskModelTest(TestCase):
    """Test cases for Task model"""
    
    def setUp(self):
        self.user = User.objects.create_user(
            username='testuser',
            password='testpass123'
        )
        self.task = Task.objects.create(
            title='Test Task',
            description='Test Description',
            status='todo',
            created_by=self.user
        )
    
    def test_task_creation(self):
        """Test task is created correctly"""
        self.assertEqual(self.task.title, 'Test Task')
        self.assertEqual(self.task.status, 'todo')
        self.assertEqual(self.task.created_by, self.user)
    
    def test_task_str(self):
        """Test task string representation"""
        self.assertEqual(str(self.task), 'Test Task')
    
    def test_task_ordering(self):
        """Test tasks are ordered by creation date"""
        task2 = Task.objects.create(
            title='Second Task',
            status='done',
            created_by=self.user
        )
        tasks = Task.objects.all()
        self.assertEqual(tasks[0], task2)  # Most recent first


class CategoryModelTest(TestCase):
    """Test cases for Category model"""
    
    def setUp(self):
        self.category = Category.objects.create(
            name='Work',
            description='Work-related tasks'
        )
    
    def test_category_creation(self):
        """Test category is created correctly"""
        self.assertEqual(self.category.name, 'Work')
        self.assertEqual(self.category.description, 'Work-related tasks')
    
    def test_category_str(self):
        """Test category string representation"""
        self.assertEqual(str(self.category), 'Work')


class TaskAPITest(APITestCase):
    """Test cases for Task API endpoints"""
    
    def setUp(self):
        self.user = User.objects.create_user(
            username='apiuser',
            password='apipass123'
        )
        self.client = Client()
        self.task_data = {
            'title': 'API Test Task',
            'description': 'Created via API',
            'status': 'todo'
        }
    
    def test_get_task_list(self):
        """Test retrieving task list"""
        response = self.client.get('/api/tasks/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
    
    def test_create_task_authenticated(self):
        """Test creating task with authentication"""
        self.client.force_login(self.user)
        response = self.client.post('/api/tasks/', self.task_data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
    
    def test_create_task_unauthenticated(self):
        """Test creating task without authentication fails"""
        response = self.client.post('/api/tasks/', self.task_data)
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)


class ViewTest(TestCase):
    """Test cases for views"""
    
    def setUp(self):
        self.client = Client()
        self.user = User.objects.create_user(
            username='viewuser',
            password='viewpass123'
        )
    
    def test_home_view(self):
        """Test home page loads"""
        response = self.client.get('/')
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, 'Django Production-Ready Project')
    
    def test_task_list_view(self):
        """Test task list page loads"""
        response = self.client.get('/tasks/')
        self.assertEqual(response.status_code, 200)
    
    def test_api_root(self):
        """Test API root endpoint"""
        response = self.client.get('/api/')
        self.assertEqual(response.status_code, 200)
        self.assertIn('endpoints', response.json())
