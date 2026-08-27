locals {
  kube_prism_port = 7445
  common_machine_configs = [
    {
      machine = {
        # NB the install section changes are only applied after a talos upgrade
        #    (which we do not do). instead, its preferred to create a custom
        #    talos image, which is created in the installed state.
        #install = {}
        features = {
          # see https://docs.siderolabs.com/kubernetes-guides/advanced-guides/kubeprism
          # see talosctl -n $c0 read /etc/kubernetes/kubeconfig-kubelet | yq .clusters[].cluster.server
          # NB if you use a non-default CNI, you must configure it to use the
          #    https://localhost:7445 kube-apiserver endpoint.
          kubePrism = {
            enabled = true
            port    = local.kube_prism_port
          }
          # see https://docs.siderolabs.com/talos/v1.13/networking/host-dns
          hostDNS = {
            enabled              = true
            forwardKubeDNSToHost = true
          }
        }
        kernel = {
          modules = [
            // piraeus dependencies.
            {
              name = "drbd"
              parameters = [
                "usermode_helper=disabled",
              ]
            },
            {
              name = "drbd_transport_tcp"
            },
          ]
        }
      }
      cluster = {
        # disable kubernetes discovery as its no longer compatible with k8s 1.32+.
        # NB we actually disable the discovery altogether, at the other discovery
        #    mechanism, service discovery, requires the public discovery service
        #    from https://discovery.talos.dev/ (or a custom and paid one running
        #    locally in your network).
        # NB without this, talosctl get members, always returns an empty set.
        # see https://docs.siderolabs.com/talos/v1.13/configure-your-talos-cluster/system-configuration/discovery
        # see https://docs.siderolabs.com/talos/v1.13/reference/configuration/v1alpha1/config#discovery
        # see https://github.com/siderolabs/talos/issues/9980
        # see https://github.com/siderolabs/talos/commit/c12b52491456d1e52204eb290d0686a317358c7c
        discovery = {
          enabled = false
          registries = {
            kubernetes = {
              disabled = true
            }
            service = {
              disabled = true
            }
          }
        }
        network = {
          cni = {
            name = "none"
          }
        }
        proxy = {
          disabled = true
        }
      }
    },
  ]
}