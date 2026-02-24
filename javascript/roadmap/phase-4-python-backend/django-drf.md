# Django + Django REST Framework

[← Back to Phase 4](README.md) | [Roadmap](../README.md)

## Setup

```bash
pip install django djangorestframework djangorestframework-simplejwt django-cors-headers drf-spectacular

django-admin startproject config .
python manage.py startapp users
```

---

## Settings

```python
# config/settings.py (relevant sections)
INSTALLED_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "rest_framework",
    "rest_framework_simplejwt",
    "corsheaders",
    "drf_spectacular",
    "users",
]

MIDDLEWARE = [
    "corsheaders.middleware.CorsMiddleware",   # must be before CommonMiddleware
    "django.middleware.common.CommonMiddleware",
    # ...
]

REST_FRAMEWORK = {
    "DEFAULT_AUTHENTICATION_CLASSES": [
        "rest_framework_simplejwt.authentication.JWTAuthentication",
    ],
    "DEFAULT_PERMISSION_CLASSES": [
        "rest_framework.permissions.IsAuthenticated",
    ],
    "DEFAULT_PAGINATION_CLASS": "rest_framework.pagination.PageNumberPagination",
    "PAGE_SIZE": 20,
    "DEFAULT_SCHEMA_CLASS": "drf_spectacular.openapi.AutoSchema",
}

CORS_ALLOWED_ORIGINS = [
    "http://localhost:5173",
    "https://app.example.com",
]

SIMPLE_JWT = {
    "ACCESS_TOKEN_LIFETIME": timedelta(hours=1),
    "REFRESH_TOKEN_LIFETIME": timedelta(days=30),
}
```

---

## Model

```python
# users/models.py
from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
    class Role(models.TextChoices):
        ADMIN  = "admin",  "Admin"
        EDITOR = "editor", "Editor"
        VIEWER = "viewer", "Viewer"

    email = models.EmailField(unique=True)
    role  = models.CharField(max_length=10, choices=Role.choices, default=Role.VIEWER)

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = ["username"]

    class Meta:
        ordering = ["-date_joined"]
```

---

## Serializers

```python
# users/serializers.py
from rest_framework import serializers
from .models import User

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model  = User
        fields = ["id", "email", "first_name", "last_name", "role", "date_joined"]
        read_only_fields = ["id", "date_joined"]

class CreateUserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model  = User
        fields = ["email", "first_name", "last_name", "password", "role"]

    def create(self, validated_data):
        return User.objects.create_user(**validated_data)

class UpdateUserSerializer(serializers.ModelSerializer):
    class Meta:
        model  = User
        fields = ["first_name", "last_name", "role"]
```

---

## ViewSets

```python
# users/views.py
from rest_framework import viewsets, status, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from django_filters.rest_framework import DjangoFilterBackend
from .models import User
from .serializers import UserSerializer, CreateUserSerializer

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.filter(is_active=True).select_related()
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ["role"]
    search_fields    = ["email", "first_name", "last_name"]
    ordering_fields  = ["date_joined", "email"]
    ordering         = ["-date_joined"]

    def get_serializer_class(self):
        if self.action == "create":
            return CreateUserSerializer
        return UserSerializer

    def get_permissions(self):
        if self.action in ["create", "destroy"]:
            return [IsAdminUser()]
        return [IsAuthenticated()]

    @action(detail=False, methods=["get"])
    def me(self, request):
        serializer = UserSerializer(request.user)
        return Response(serializer.data)

    @action(detail=True, methods=["post"])
    def deactivate(self, request, pk=None):
        user = self.get_object()
        user.is_active = False
        user.save()
        return Response(status=status.HTTP_204_NO_CONTENT)
```

---

## URL Configuration

```python
# config/urls.py
from django.contrib import admin
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView
from users.views import UserViewSet

router = DefaultRouter()
router.register(r"users", UserViewSet, basename="user")

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/v1/", include(router.urls)),
    path("auth/login",   TokenObtainPairView.as_view(),  name="token_obtain"),
    path("auth/refresh", TokenRefreshView.as_view(),     name="token_refresh"),
    path("schema/",      SpectacularAPIView.as_view(),   name="schema"),
    path("docs/",        SpectacularSwaggerView.as_view(url_name="schema"), name="swagger"),
]
```

---

## ORM Optimization

```python
# Avoid N+1 queries — use select_related / prefetch_related
# select_related — SQL JOIN (FK, OneToOne)
users = User.objects.select_related("profile").filter(role="admin")

# prefetch_related — separate query (ManyToMany, reverse FK)
orders = Order.objects.prefetch_related("items__product").filter(user=user)

# Annotate for aggregations (avoid Python-side calculation)
from django.db.models import Count, Sum, Avg

stats = (
    Order.objects
    .values("status")
    .annotate(
        count=Count("id"),
        total=Sum("amount"),
    )
)

# only() / defer() — select subset of columns
users = User.objects.only("id", "email", "role")
```

---

## Resources

- [Django REST Framework](https://www.django-rest-framework.org/)
- [SimpleJWT](https://django-rest-framework-simplejwt.readthedocs.io/)
- [drf-spectacular (OpenAPI)](https://drf-spectacular.readthedocs.io/)
- [Django Filter](https://django-filter.readthedocs.io/)

---

→ [Phase 4 Overview](README.md) | [Phase 5 – Full-Stack Architecture](../phase-5-fullstack-architecture/README.md)
