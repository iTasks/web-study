# Google Cloud Functions (Legacy)

[← Back to src](../readme.md) | [Main README](../../README.md)

## Topics:

1. **App-Engine**
   - Description: Google App Engine allows you to build and deploy applications on a fully managed platform.
   - References:
     - [Google App Engine Documentation](https://cloud.google.com/appengine/docs)
     - [Google Cloud's App Engine Overview](https://cloud.google.com/appengine)

2. **Cloud-Run**
   - Description: Cloud Run is a managed compute platform that automatically scales your stateless containers.
   - References:
     - [Cloud Run Documentation](https://cloud.google.com/run/docs)
     - [Getting Started with Cloud Run](https://cloud.google.com/run/docs/quickstarts/build-and-deploy)

3. **Compute Engine**
   - Description: Compute Engine offers scalable, high-performance virtual machines (VMs) with flexible configurations.
   - References:
     - [Compute Engine Documentation](https://cloud.google.com/compute/docs)
     - [Compute Engine Quickstart](https://cloud.google.com/compute/docs/quickstart)

4. **Kubernetes Engine**
   - Description: Google Kubernetes Engine (GKE) is a managed environment for deploying, managing, and scaling containerized applications using Kubernetes.
   - References:
     - [Kubernetes Engine Documentation](https://cloud.google.com/kubernetes-engine/docs)
     - [Kubernetes Engine Quickstart](https://cloud.google.com/kubernetes-engine/docs/quickstart)

5. **BigQuery**
   - Description: BigQuery is a fully-managed, serverless data warehouse that enables scalable analysis over petabytes of data.
   - References:
     - [BigQuery Documentation](https://cloud.google.com/bigquery/docs)
     - [BigQuery Quickstart](https://cloud.google.com/bigquery/docs/quickstarts)

## Resources:

- [Google Cloud Documentation](https://cloud.google.com/docs)
- [YouTube Playlist](https://www.youtube.com/playlist?list=PLIivdWyY5sqKh1gDR0WpP9iIOY00IE0xL)

### Files/Folders:
```
src/gcf
├── README.md
├── app-engine
│   └── chatbot
│       ├── ChatbotServlet.java
│       ├── app.yaml
│       ├── appengine-web.xml
│       ├── main.py
│       ├── pom.xml
│       ├── readme.md
│       └── web.xml
└── k8s
    └── ticket
        ├── BigtableApplication.java
        ├── Dockerfile
        ├── README.md
        ├── application.properties
        └── ticker-deployment.yaml
```
