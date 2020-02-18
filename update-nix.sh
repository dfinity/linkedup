#!/usr/bin/env bash

exec nix-shell                                  \
    -p nodePackages_12_x.node2nix               \
    --pure                                      \
    --command "node2nix -i package.json                         \
                        -l package-lock.json                    \
                        -c packages.nix                         \
                        --nodejs-12                             \
                        --include-peer-dependencies             \
                        --supplement-input supplement.json"
