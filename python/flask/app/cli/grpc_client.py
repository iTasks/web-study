#!/usr/bin/env python3
"""
gRPC client CLI tool
"""
import click
import grpc
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
import json

console = Console()

try:
    import sys
    import os
    sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../grpc_service')))
    import service_pb2
    import service_pb2_grpc
except ImportError:
    console.print("[red]Error: gRPC files not generated. Run: python -m grpc_tools.protoc -I. --python_out=. --grpc_python_out=. service.proto[/red]")
    sys.exit(1)


@click.group()
def cli():
    """gRPC API Testing CLI Tool"""
    pass


@cli.command()
@click.option('--host', default='localhost:50051', help='gRPC host')
def list_users(host):
    """List all users via gRPC"""
    try:
        with grpc.insecure_channel(host) as channel:
            stub = service_pb2_grpc.UserServiceStub(channel)
            response = stub.ListUsers(service_pb2.ListUsersRequest())
            
            table = Table(title="Users (gRPC)")
            table.add_column("ID", style="cyan")
            table.add_column("Username", style="green")
            table.add_column("Email", style="yellow")
            
            for user in response.users:
                table.add_row(
                    str(user.id),
                    user.username,
                    user.email
                )
            
            console.print(table)
    except Exception as e:
        console.print(f"[red]Error: {str(e)}[/red]")


@cli.command()
@click.option('--host', default='localhost:50051', help='gRPC host')
@click.option('--username', prompt=True, help='Username')
@click.option('--email', prompt=True, help='Email')
def create_user(host, username, email):
    """Create a new user via gRPC"""
    try:
        with grpc.insecure_channel(host) as channel:
            stub = service_pb2_grpc.UserServiceStub(channel)
            response = stub.CreateUser(
                service_pb2.CreateUserRequest(
                    username=username,
                    email=email
                )
            )
            
            user_data = {
                'id': response.user.id,
                'username': response.user.username,
                'email': response.user.email,
                'created_at': response.user.created_at
            }
            
            from rich.syntax import Syntax
            console.print(Panel(
                Syntax(json.dumps(user_data, indent=2), "json"),
                title="[green]User Created via gRPC[/green]"
            ))
    except Exception as e:
        console.print(f"[red]Error: {str(e)}[/red]")


@cli.command()
@click.option('--host', default='localhost:50051', help='gRPC host')
def list_tasks(host):
    """List all tasks via gRPC"""
    try:
        with grpc.insecure_channel(host) as channel:
            stub = service_pb2_grpc.TaskServiceStub(channel)
            response = stub.ListTasks(service_pb2.ListTasksRequest())
            
            table = Table(title="Tasks (gRPC)")
            table.add_column("ID", style="cyan")
            table.add_column("Title", style="green")
            table.add_column("Completed", style="yellow")
            
            for task in response.tasks:
                table.add_row(
                    str(task.id),
                    task.title,
                    '✓' if task.completed else '✗'
                )
            
            console.print(table)
    except Exception as e:
        console.print(f"[red]Error: {str(e)}[/red]")


if __name__ == '__main__':
    cli()
