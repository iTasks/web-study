#!/usr/bin/env python3
"""
CLI tool for testing REST, GraphQL, and gRPC APIs
"""
import click
import requests
import json
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich.syntax import Syntax
from rich import print as rprint

console = Console()


@click.group()
def cli():
    """API Testing CLI Tool"""
    pass


@cli.group()
def rest():
    """Test REST API endpoints"""
    pass


@rest.command()
@click.option('--host', default='http://localhost:5000', help='API host')
def list_users(host):
    """List all users"""
    try:
        response = requests.get(f'{host}/api/v1/users')
        response.raise_for_status()
        
        users = response.json()
        
        table = Table(title="Users")
        table.add_column("ID", style="cyan")
        table.add_column("Username", style="green")
        table.add_column("Email", style="yellow")
        
        for user in users:
            table.add_row(
                str(user.get('id', '')),
                user.get('username', ''),
                user.get('email', '')
            )
        
        console.print(table)
    except Exception as e:
        console.print(f"[red]Error: {str(e)}[/red]")


@rest.command()
@click.option('--host', default='http://localhost:5000', help='API host')
@click.option('--username', prompt=True, help='Username')
@click.option('--email', prompt=True, help='Email')
def create_user(host, username, email):
    """Create a new user"""
    try:
        response = requests.post(
            f'{host}/api/v1/users',
            json={'username': username, 'email': email}
        )
        response.raise_for_status()
        
        user = response.json()
        console.print(Panel(
            Syntax(json.dumps(user, indent=2), "json"),
            title="[green]User Created Successfully[/green]"
        ))
    except Exception as e:
        console.print(f"[red]Error: {str(e)}[/red]")


@rest.command()
@click.option('--host', default='http://localhost:5000', help='API host')
def list_tasks(host):
    """List all tasks"""
    try:
        response = requests.get(f'{host}/api/v1/tasks')
        response.raise_for_status()
        
        tasks = response.json()
        
        table = Table(title="Tasks")
        table.add_column("ID", style="cyan")
        table.add_column("Title", style="green")
        table.add_column("Completed", style="yellow")
        
        for task in tasks:
            table.add_row(
                str(task.get('id', '')),
                task.get('title', ''),
                '✓' if task.get('completed') else '✗'
            )
        
        console.print(table)
    except Exception as e:
        console.print(f"[red]Error: {str(e)}[/red]")


@rest.command()
@click.option('--host', default='http://localhost:5000', help='API host')
@click.option('--title', prompt=True, help='Task title')
@click.option('--description', default='', help='Task description')
def create_task(host, title, description):
    """Create a new task"""
    try:
        response = requests.post(
            f'{host}/api/v1/tasks',
            json={'title': title, 'description': description}
        )
        response.raise_for_status()
        
        task = response.json()
        console.print(Panel(
            Syntax(json.dumps(task, indent=2), "json"),
            title="[green]Task Created Successfully[/green]"
        ))
    except Exception as e:
        console.print(f"[red]Error: {str(e)}[/red]")


@cli.group()
def graphql():
    """Test GraphQL API"""
    pass


@graphql.command()
@click.option('--host', default='http://localhost:5000', help='API host')
def query_users(host):
    """Query all users via GraphQL"""
    query = """
    {
        allUsers {
            id
            username
            email
        }
    }
    """
    
    try:
        response = requests.post(
            f'{host}/graphql',
            json={'query': query}
        )
        response.raise_for_status()
        
        result = response.json()
        
        if 'data' in result and 'allUsers' in result['data']:
            users = result['data']['allUsers']
            
            table = Table(title="Users (GraphQL)")
            table.add_column("ID", style="cyan")
            table.add_column("Username", style="green")
            table.add_column("Email", style="yellow")
            
            for user in users:
                table.add_row(
                    str(user.get('id', '')),
                    user.get('username', ''),
                    user.get('email', '')
                )
            
            console.print(table)
        else:
            console.print(Panel(
                Syntax(json.dumps(result, indent=2), "json"),
                title="GraphQL Response"
            ))
    except Exception as e:
        console.print(f"[red]Error: {str(e)}[/red]")


@graphql.command()
@click.option('--host', default='http://localhost:5000', help='API host')
@click.option('--username', prompt=True, help='Username')
@click.option('--email', prompt=True, help='Email')
def create_user_mutation(host, username, email):
    """Create user via GraphQL mutation"""
    mutation = f"""
    mutation {{
        createUser(username: "{username}", email: "{email}") {{
            user {{
                id
                username
                email
            }}
        }}
    }}
    """
    
    try:
        response = requests.post(
            f'{host}/graphql',
            json={'query': mutation}
        )
        response.raise_for_status()
        
        result = response.json()
        console.print(Panel(
            Syntax(json.dumps(result, indent=2), "json"),
            title="[green]User Created via GraphQL[/green]"
        ))
    except Exception as e:
        console.print(f"[red]Error: {str(e)}[/red]")


@cli.command()
@click.option('--host', default='http://localhost:5000', help='API host')
def health(host):
    """Check API health"""
    try:
        response = requests.get(f'{host}/api/v1/health')
        response.raise_for_status()
        
        data = response.json()
        console.print(Panel(
            Syntax(json.dumps(data, indent=2), "json"),
            title="[green]Health Check[/green]"
        ))
    except Exception as e:
        console.print(f"[red]Error: {str(e)}[/red]")


if __name__ == '__main__':
    cli()
