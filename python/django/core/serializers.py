from rest_framework import serializers
from .models import Task, Category


class TaskSerializer(serializers.ModelSerializer):
    """
    Serializer for Task model.
    """
    created_by = serializers.ReadOnlyField(source='created_by.username')
    
    class Meta:
        model = Task
        fields = [
            'id', 'title', 'description', 'status',
            'created_by', 'created_at', 'updated_at', 'due_date'
        ]
        read_only_fields = ['created_at', 'updated_at']


class CategorySerializer(serializers.ModelSerializer):
    """
    Serializer for Category model.
    """
    class Meta:
        model = Category
        fields = ['id', 'name', 'description', 'created_at']
        read_only_fields = ['created_at']
