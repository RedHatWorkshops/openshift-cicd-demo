# OpenShift CICD Demo

> :warning: Although in working order, this should be considered more of a "POC" for the time being.

This is a "self contained" and "self bootstrapping" OpenShift CI/CD Demo,
that uses OpenShift Pipelines (Tekton) in tandem with OpenShift GitOps
(Argo CD) to deliver a cloud native CI/CD solution.

Once deployed, you will have the following:

* OpenShift GitOps cluster scoped deployment installed
* Tekton installed
* Custom Cluster configurations

The OpenShift GitOps system will then install the following:

* "Tenant" Argo CD instance under the `welcome-gitops` namespace
* A GitTea instances to house all the manifests
  * It also imports all the needed repos
* Sample `welcome-app` application in the following namespaces
  * `welcome-dev`
  * `welcome-prod`
* Tekton Pipeline under `welcome-pipeline` set up with the following
  * Builds application from source (hosted on the GitTea service)
  * Image gets stored in the internal registry
  * Tekton will "write back" to the GitTea instance for ArgoCD to act on

# Installation

> :warning: I've tested this on OCP 4.7

To deploy this demo, you need to have the following

1. A "bare" OpenShift 4.7 cluster installed
2. Cluster Admin access to the cluster
3. `oc` and `kubectl` CLI installed.
4. Not required; but `kustomize` is useful (for debugging)

Once you have a cluster ready, login as `cluster-admin` and run the following:

```shell
kubectl apply -k https://github.com/RedHatWorkshops/openshift-cicd-demo/bootstrap/overlays/base.cluster/
```

If you have issues, please see the [troubleshooting section](#troubeshooting)


# Troubeshooting

Common issues that may arise.

## Installation

You're probably always going to end up here since the install won't work "first shot". Best way to install is to run the following:

```shell
until kubectl apply -k https://github.com/RedHatWorkshops/openshift-cicd-demo/bootstrap/overlays/base.cluster/
do
  sleep 5
done
```

WORK IN PROGRESS


Console Route: oc get route console -n openshift-console -o jsonpath='{.spec.host}{"\n"}'

OpenShift GitOps Route: oc get route openshift-gitops-server -n openshift-gitops -o jsonpath='{.spec.host}{"\n"}'
OpenShift GitOps Admin password: oc extract secret/openshift-gitops-cluster -n openshift-gitops --to=-

Tenat GitOps Route: oc get route welcome-argocd-server -n welcome-gitops -o jsonpath='{.spec.host}{"\n"}'
Tenat GitOps Admin password: oc extract secret/welcome-argocd-cluster -n welcome-gitops --to=-

GitTea Route: oc get route gitea -n scm -o jsonpath='{.spec.host}{"\n"}'

Application Dev Route: oc get route welcome-app -n welcome-dev -o jsonpath='{.spec.host}{"\n"}'
Application Prod Route: oc get route welcome-app -n welcome-prod -o jsonpath='{.spec.host}{"\n"}'



