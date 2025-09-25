import os

project_structure = {
    'hadoop-spark-spring-boot-project': {
        'src': {
            'main': {
                'java': {
                    'com': {
                        'example': {
                            'HadoopSparkSpringBootApplication.java': 'public class HadoopSparkSpringBootApplication {}',
                            'config': {
                                'HadoopConfig.java': 'public class HadoopConfig {}',
                                'SparkConfig.java': 'public class SparkConfig {}'
                            },
                            'service': {
                                'HdfsService.java': 'public class HdfsService {}',
                                'SparkService.java': 'public class SparkService {}'
                            },
                            'controller': {
                                'HdfsController.java': 'public class HdfsController {}',
                                'SparkController.java': 'public class SparkController {}'
                            }
                        }
                    }
                },
                'resources': {
                    'application.properties': 'hadoop.fs.defaultFS=hdfs://localhost:9000\nspark.app.name=SpringBootSparkIntegration\nspark.master=local[*]'
                }
            },
            'test': {
                'java': {
                    'com': {
                        'example': {
                            'HadoopSparkSpringBootApplicationTests.java': 'public class HadoopSparkSpringBootApplicationTests {}'
                        }
                    }
                },
            'resources': {
                'application-test.properties': 'test.property=value'
            }
            }
        },
        'pom.xml': '<dependencies>...</dependencies>',
        '.gitignore': '*.class\n.DS_Store\nbuild/\ntarget/',
        'README.md': '# Project README',
        'RESOURCES.md': '# Resources',
        'RUNNING.md': '# Running the Application\n## Overview\nThis document guides through the process of running the generated Spring Boot application.'
    }
}

def create_project_structure(base_path, structure):
    """
    Recursively create directories and files based on the passed structure dictionary.

    :param base_path: str - The base path where the file structure begins.
    :param structure: dict - A nested dictionary where keys are directory or file names
                              and values are either another dict (representing subdirectories)
                              or strings (representing file contents).
    """
    for name, content in structure.items():
        path = os.path.join(base_path, name)
        if isinstance(content, dict):
            os.makedirs(path, exist_ok=True)
            create_project_structure(path, content)
        else:
            with open(path, 'w') as file:
                file.write(content)

if __name__ == "__main__":
    """
    Main execution point of the script.
    Generate the project structure in the current directory or a specified base path.
    """
    project_base_path = './'  # Adjust this path as necessary
    create_project_structure(project_base_path, project_structure)
    print("Project structure generated successfully at:", project_base_path)
