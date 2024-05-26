# Introduction 
This project is designed to fetch the currency of BTC in USDT and EUR every 2 minutes from the Binance API. The results are parsed and the average is calculated every 10 minutes and displayed.

# Getting Started
Follow these steps to get the project up and running on your own system:

## Installation process
1. Clone the repository to your local machine using Azure DevOps Repos. You can do this by navigating to the Repos section of Azure DevOps project, selecting the repository, and clicking on 'Clone'.
2. Navigate to the project directory using `cd [project_directory]`.
3. Install the required dependencies.

## Software dependencies
This project depends on the following software:
1. Docker for building container images.
2. Azure CLI for interacting with Azure services.
3. Kubernetes CLI (kubectl) for interacting with the Kubernetes cluster.
4. Helm for package management in Kubernetes.

## API references
This project uses the Binance API to fetch the currency of BTC. The API documentation can be found [here](https://api.binance.com/api/v3/ticker/price).

# Build
To build this project, follow these steps:
1. Build the Docker images using `docker build`.
2. Push the Docker images to a Docker registry using `docker push`.
3. Deploy the Docker images to the Kubernetes cluster using `kubectl apply` or `helm install`.


# Deployment
This project is deployed on an Azure Kubernetes Service (AKS) cluster. The cluster is created using an Infrastructure-as-code solution Terraform. The cluster has two Bitcoin services deployed in a Continuous Deployment (CD) pipeline, exposing two different endpoints. The cluster also has an nginx Ingress controller deployed, with corresponding ingress rules for Service USDT and Service EUR.

# CI/CD
This project uses Azure DevOps for Continuous Integration (CI) and Continuous Deployment (CD). The pipelines are defined in YAML files in the `.azure-pipelines` directory. The CI pipeline builds two Docker images that wrap the application, and the CD pipeline deploys these images to the AKS cluster.