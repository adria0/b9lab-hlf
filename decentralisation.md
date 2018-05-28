# Part 4. Decentralization.

## Native hosts

_You could run the nodes native in hosts. Why is this impractical?_

I see three reasons here:

- Docker provides a very good level of isolation, reduces the
  maintenance of cloned nodes using a common configuration, makes
  the updating process easy, helps to automatize all devops.

- Hyperledger itself provides a secure distribution with docker images
  that helps to upgrade the clients from a unified and trusted
  source.

- It helps to install in the same host more than 1 service ; in 
  some cases, when joining different blockchain networks, could be
  useful to run in the same host, nodes from those networks or additional
  services (if the workload is not too heavy)

## Kubernetes & Docker Swarm

_You could use various services, e.g. Docker Swarm or Kubernetes.
Explain briefly Swarm and Kubernetes. Name some sources for the next steps to use them for Hyperledger Fabric._

*Docker swarm* allows creating clusters with docker from a primary
docker service. Mainly creates multiple replicas of this instance,
and distributes the workload among those instances, providing load
balancing, autoscaling, as also running the same command into multiple
containers at the same time.

The main idea behind *Kubernetes* is allowing large and safe service
deployments by grouping containers in "pods".
When scaling, happens that usually needs to scale, not only one 
component, but a set of co-located components 
(database, monitor, worker nodes,...)
and the pod can be understood as a set of this "cooperating" 
containers as a scaling unit. Kubernetes
allows to manage these "pods" in a way that allows the cluster/
autoscaling/failsafe capabilities expected from large deployments
using a well-defined scalable architecture.

A very good comparation in
https://platform9.com/blog/kubernetes-docker-swarm-compared/

Nice sources about how to deploy fabric with kubernetes
- https://hackernoon.com/how-to-deploy-hyperledger-fabric-on-kubernetes-1-a2ceb3ada078
- https://medium.com/@zhanghenry/how-to-deploy-hyperledger-fabric-on-kubernetes-2-751abf44c807
- https://medium.com/kokster/simpler-setup-for-hyperledger-fabric-on-kubernetes-using-docker-in-docker-8346f70fbe80
- https://opensource.com/article/18/4/deploying-hyperledger-fabric-kubernetes

Sources about deploying fabric with swarm
- http://www.joemotacek.com/hyperledger-fabric-v1-0-on-a-raspberry-pi-docker-swarm-part-4/

## IBM Cloud

_You can use IBM Cloud. Tell us what it offers in regard to Hyperledger Fabric._

IBM Cloud offers HyperLedger fabric in SaaS mode (or BaaS, blockchain as a service) with some
clear advantages:

- is possible to manage the configuration and the hosts using an user interface
- running blockchains can be used as a service, paying for its usage instead of having dedicated
nodes for that. 
- everything is deployed in the IBM infraestructure, providing the programmable automation,
  monitorization and scaling that is currently available in this cloud.
- private keys are well stored in a hardware security module that is a expensive hardware

## Hyperledger cello

_There is a project called Hyperledger Cello. Explain, what it aims to do and
where one can learn more about it, as well how to get support_

Hyperledger cello is a tool to deploy blockchains over a pool of virtual server
hosts. It has a simple user interface with role-based dashboards:

- operator dashboard  allows system operators to add/remove
virtualization hosts (hosts that can run containers, like docker), add/remove
blockchains (specifying the number of nodes, and the orderer type), visualizing
the global system status, as user management.

- the user dashboard (for each chain) allows users to see blocks and transactions,
  install, initializem, query and invoke chaincodes 

A very good way to quickly see how it works is in the video
https://www.youtube.com/watch?v=4-pWlj8UgRg also the tutorial
helps to understand the functionality https://github.com/hyperledger/cello/blob/master/docs/tutorial.md

To get support, there's the https://chat.hyperledger.org/channel/cello chat
