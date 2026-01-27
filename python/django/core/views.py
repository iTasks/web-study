from django.shortcuts import render
from django.views.generic import TemplateView, ListView
from rest_framework import viewsets, permissions
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Task, Category
from .serializers import TaskSerializer, CategorySerializer


class HomeView(TemplateView):
    """
    Home page view.
    """
    template_name = 'core/home.html'


class TaskListView(ListView):
    """
    List all tasks.
    """
    model = Task
    template_name = 'core/task_list.html'
    context_object_name = 'tasks'
    paginate_by = 10


@api_view(['GET'])
def api_root(request):
    """
    API root endpoint providing information about available endpoints.
    """
    return Response({
        'message': 'Welcome to Django Production-Ready API',
        'version': '1.0.0',
        'endpoints': {
            'tasks': '/api/tasks/',
            'categories': '/api/categories/',
            'admin': '/admin/',
        }
    })


class TaskViewSet(viewsets.ModelViewSet):
    """
    API endpoint for tasks CRUD operations.
    """
    queryset = Task.objects.all()
    serializer_class = TaskSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
    
    def perform_create(self, serializer):
        serializer.save(created_by=self.request.user)


class CategoryViewSet(viewsets.ModelViewSet):
    """
    API endpoint for categories CRUD operations.
    """
    queryset = Category.objects.all()
    serializer_class = CategorySerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
